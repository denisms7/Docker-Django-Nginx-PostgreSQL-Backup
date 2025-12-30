# Visão Geral da Arquitetura

Este documento descreve a arquitetura completa do projeto, explicando como todos os componentes se integram para formar uma aplicação web robusta e escalável.

## Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                        Cliente (Browser)                     │
└────────────────────────────┬────────────────────────────────┘
                             │ HTTP/HTTPS
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Nginx Proxy Manager                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Porta 80/443: Proxy Reverso                          │   │
│  │ Porta 81: Interface Admin                            │   │
│  │ - SSL/TLS Termination                                │   │
│  │ - Load Balancing                                     │   │
│  │ - Static Files (/static/, /media/)                   │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────┘
                             │ Porta 8000
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      Django Application                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Gunicorn WSGI Server                                 │   │
│  │ - 4 Workers                                          │   │
│  │ - 4 Threads por Worker                               │   │
│  │ - 1000 Conexões por Worker                           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Django Framework                                     │   │
│  │ - Business Logic                                     │   │
│  │ - ORM                                                │   │
│  │ - Admin Interface                                    │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────┘
                             │ Porta 5432
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      PostgreSQL 17.5                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Database: db-modelo                                  │   │
│  │ User: postgres                                       │   │
│  │ Persistent Volume: postgres_data                     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                             ▲
                             │
          ┌──────────────────┴──────────────────┐
          │                                     │
┌─────────▼──────────┐              ┌───────────▼────────────┐
│ PostgreSQL Backup  │              │    Mídia Backup        │
│                    │              │                        │
│ - Backup diário    │              │ - Rsync diário         │
│ - Rotação 7/4/4    │              │ - Pasta ./media        │
│ - Volume: backup   │              │ - Volume: backup       │
└────────────────────┘              └────────────────────────┘
```

## Fluxo de Requisição

### 1. Requisição HTTP/HTTPS
O cliente faz uma requisição para o servidor.

```
Cliente → Nginx (porta 80/443)
```

### 2. SSL/TLS Termination
O Nginx gerencia certificados SSL e descriptografa a conexão HTTPS.

```
HTTPS → Nginx [SSL Termination] → HTTP interno
```

### 3. Roteamento de Arquivos Estáticos
O Nginx serve arquivos estáticos diretamente, sem passar pelo Django.

```
/static/* → Nginx serve de /var/www/staticfiles/
/media/*  → Nginx serve de /var/www/media/
```

**Benefícios**:
- Performance muito superior
- Reduz carga no Django
- Cache eficiente (1 ano para static, 30 dias para media)

### 4. Proxy para Django
Requisições dinâmicas são encaminhadas para o Django.

```
Nginx → django-app:8000 → Gunicorn → Django
```

### 5. Processamento da Aplicação
O Django processa a requisição:

```python
URL Router → View → Model (ORM) → PostgreSQL
                  ↓
            Template Rendering
                  ↓
            HTTP Response
```

### 6. Acesso ao Banco de Dados
Django se conecta ao PostgreSQL via rede Docker.

```
Django ORM → postgres-db:5432 → PostgreSQL
```

### 7. Resposta ao Cliente
A resposta percorre o caminho inverso:

```
Django → Gunicorn → Nginx → Cliente
```

## Componentes Principais

### 1. Nginx Proxy Manager

**Função**: Proxy reverso e gerenciador de certificados SSL

**Características**:
- Interface web amigável (porta 81)
- Geração automática de certificados Let's Encrypt
- Gerenciamento de múltiplos hosts
- Logs em tempo real
- Proteção contra ataques comuns

**Volumes**:
- `./data:/data` - Configurações e banco SQLite
- `./letsencrypt:/etc/letsencrypt` - Certificados SSL
- `./staticfiles:/var/www/staticfiles:ro` - Arquivos estáticos (read-only)

**Portas Expostas**:
- `80` - HTTP
- `443` - HTTPS
- `81` - Interface Admin (remover em produção)

### 2. Django Application

**Função**: Aplicação web principal

**Tecnologias**:
- Python 3.13.6
- Django 6.0
- Gunicorn 23.0.0

**Configuração Gunicorn**:
```python
bind = "0.0.0.0:8000"
workers = 4              # 2 x CPU + 1
threads = 4              # Paralelização I/O
worker_connections = 1000
timeout = 120            # Requisições longas
```

**Volumes**:
- `./:/app` - Código fonte (desenvolvimento)
- `./staticfiles:/app/staticfiles` - Arquivos estáticos coletados
- `./media:/app/media` - Upload de arquivos

**Healthcheck**:
```yaml
test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
interval: 30s
timeout: 10s
retries: 3
start_period: 40s
```

### 3. PostgreSQL Database

**Função**: Banco de dados relacional

**Versão**: PostgreSQL 17.5

**Configuração**:
- Usuário, senha e database via `.env`
- Volume persistente: `postgres_data`
- Exposto apenas na rede Docker (não externamente)

**Healthcheck**:
```yaml
test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
interval: 10s
timeout: 5s
retries: 5
```

### 4. PostgreSQL Backup

**Função**: Backup automatizado do banco de dados

**Imagem**: `prodrigestivill/postgres-backup-local:latest`

**Agendamento**: Diário às 3h (horário de Brasília)

**Política de Retenção**:
- **Diário**: 7 dias
- **Semanal**: 4 semanas
- **Mensal**: 4 meses

**Volume**: `backup:/backups`

### 5. Mídia Backup

**Função**: Sincronização de arquivos de mídia

**Imagem**: `fdrake/rsync-cron:latest`

**Agendamento**: Diário às 3h (horário de Brasília)

**Operação**: `rsync -av --delete`
- `-a`: Archive mode (preserva permissões, timestamps, etc.)
- `-v`: Verbose
- `--delete`: Remove arquivos que não existem mais na origem

**Volumes**:
- `./media:/data/source:ro` - Origem (read-only)
- `backup:/data/backup` - Destino

## Rede Docker

### nginx-network (Bridge)

Todos os serviços estão conectados a uma rede bridge customizada.

**Vantagens**:
- DNS automático entre containers
- Isolamento de outros containers Docker
- Comunicação eficiente

**Resolução de Nomes**:
```
django-app       → 172.18.0.x
postgres-db      → 172.18.0.y
nginx-proxy      → 172.18.0.z
postgres-backup  → 172.18.0.w
midia-backup     → 172.18.0.v
```

Os containers se comunicam usando os nomes dos serviços:
```
http://django-app:8000
postgresql://postgres-db:5432
```

## Volumes Docker

### Volumes Nomeados

```yaml
volumes:
  postgres_data:  # Dados do PostgreSQL
  backup:         # Backups (DB + Mídia)
```

**Características**:
- Gerenciados pelo Docker
- Persistem após `docker-compose down`
- Backup e restore mais complexos

### Bind Mounts

```yaml
- ./:/app                    # Código fonte
- ./media:/app/media         # Uploads
- ./staticfiles:/app/staticfiles  # Arquivos estáticos
- ./data:/data               # Config Nginx
- ./letsencrypt:/etc/letsencrypt  # Certificados SSL
```

**Características**:
- Mapeamento direto do sistema de arquivos host
- Ideal para desenvolvimento (hot reload)
- Fácil acesso e backup

## Dependências entre Serviços

```yaml
django-app:
  depends_on:
    postgres-db:
      condition: service_healthy  # Espera PostgreSQL estar saudável
    nginx-proxy:
      condition: service_started  # Espera Nginx iniciar

postgres-backup:
  depends_on:
    postgres-db:
      condition: service_healthy  # Espera PostgreSQL estar saudável
```

**Ordem de Inicialização**:
1. `nginx-proxy` (inicia primeiro)
2. `postgres-db` (aguarda healthcheck)
3. `django-app` (após postgres-db healthy)
4. `postgres-backup` (após postgres-db healthy)
5. `midia-backup` (sem dependências)

## Modos de Operação

### Modo Desenvolvimento (DEBUG=1)

```python
DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

**Características**:
- SQLite como banco (arquivo local)
- Servidor de desenvolvimento Django
- Hot reload automático
- Erros detalhados
- Não usa Gunicorn

### Modo Produção (DEBUG=0)

```python
DEBUG = False

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': os.getenv('POSTGRES_HOST'),
        # ... outras configs
    }
}
```

**Características**:
- PostgreSQL como banco
- Gunicorn como servidor WSGI
- Sem hot reload
- Erros genéricos (segurança)
- Performance otimizada

## Escalabilidade

### Horizontal

Para escalar o Django:

```yaml
django-app:
  deploy:
    replicas: 3  # Múltiplas instâncias
```

O Nginx fará load balancing automaticamente.

### Vertical

Ajuste recursos de cada serviço:

```yaml
django-app:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
```

### Otimizações

1. **Gunicorn Workers**: `(2 x CPU cores) + 1`
2. **Nginx Cache**: Ative cache para requisições frequentes
3. **PostgreSQL**: Configure `shared_buffers`, `work_mem`
4. **CDN**: Para arquivos estáticos em produção

## Segurança

### Camadas de Proteção

1. **Nginx**: Primeira linha de defesa
   - Rate limiting
   - Block common exploits
   - SSL/TLS termination

2. **Django**: Segurança da aplicação
   - CSRF protection
   - XSS prevention
   - SQL injection prevention (ORM)

3. **PostgreSQL**: Segurança de dados
   - Credenciais via .env
   - Não exposto externamente
   - Conexões apenas de containers autorizados

4. **Docker**: Isolamento
   - Containers isolados
   - Rede privada
   - Volumes segregados

## Monitoramento

### Healthchecks

Todos os serviços críticos possuem healthchecks:

```bash
# Ver status
docker-compose ps

# Detalhes do healthcheck
docker inspect django-app --format='{{json .State.Health}}'
```

### Logs

```bash
# Todos os logs
docker-compose logs -f

# Logs específicos
docker-compose logs -f django-app
docker-compose logs -f nginx-proxy
```

### Métricas

Para produção, considere adicionar:
- Prometheus + Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Sentry (tracking de erros)

## Backup e Recuperação

### Estratégia 3-2-1

- **3** cópias dos dados (original + 2 backups)
- **2** tipos de mídia diferentes (local + cloud)
- **1** cópia offsite (fora do servidor)

### Automação

- Backups diários às 3h
- Retenção automática
- Volume compartilhado para DB + Mídia

### Recuperação

Veja [Restauração de Backup](../backup/restore.md) para detalhes.

## Próximos Passos

- [Serviços Docker Detalhados](services.md)
- [Rede e Volumes](networking.md)
- [Configuração de Produção](../deploy/production.md)
