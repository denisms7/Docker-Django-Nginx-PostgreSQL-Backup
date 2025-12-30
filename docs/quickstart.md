# Guia de Início Rápido

Este guia vai te ajudar a configurar e executar o projeto em menos de 10 minutos.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/) (versão 20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versão 2.0 ou superior)
- Git
- 2GB de espaço livre em disco
- Porta 80, 81, 443, 5432 e 8000 disponíveis

### Verificar Instalação

```bash
docker --version
# Docker version 24.0.0 ou superior

docker-compose --version
# Docker Compose version v2.0.0 ou superior
```

## Passo 1: Clonar o Repositório

```bash
git clone https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup.git
cd Docker-Django-Nginx-PostgreSQL-Backup
```

## Passo 2: Configurar Variáveis de Ambiente

O projeto usa um arquivo `.env` para configuração. Crie um arquivo `.env` na raiz do projeto:

```bash
# Windows
copy .env.example .env

# Linux/Mac
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações:

```env
# Django Settings
SECRET_KEY="sua-chave-secreta-aqui-gere-uma-nova"
DEBUG=0  # 0 = False (produção), 1 = True (desenvolvimento)
ALLOWED_HOSTS="seu-dominio.com, www.seu-dominio.com, localhost"

# PostgreSQL Configuration
POSTGRES_DB="nome_do_banco"
POSTGRES_USER="usuario_postgres"
POSTGRES_PASSWORD="senha_segura_aqui"
POSTGRES_HOST="postgres-db"
POSTGRES_PORT="5432"

# Backup Healthcheck
HEALTHCHECK_PORT="8069"
```

!!! warning "Segurança Importante"
    - **NUNCA** commite o arquivo `.env` no Git
    - Gere uma nova `SECRET_KEY` para produção
    - Use senhas fortes para o PostgreSQL
    - Adicione `.env` ao `.gitignore`

### Gerar SECRET_KEY do Django

```python
# Execute este comando Python para gerar uma chave segura
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## Passo 3: Construir os Containers

Construa as imagens Docker do projeto:

```bash
docker-compose build --no-cache
```

Este processo pode levar de 3 a 5 minutos dependendo da sua conexão de internet.

!!! info "O que acontece aqui?"
    - Download da imagem base Python 3.13
    - Instalação de dependências do sistema
    - Instalação de pacotes Python
    - Construção da imagem customizada do Django

## Passo 4: Iniciar os Serviços

Inicie todos os containers em segundo plano:

```bash
docker-compose up -d
```

Acompanhe os logs para verificar se tudo está funcionando:

```bash
docker-compose logs -f
```

Pressione `Ctrl+C` para sair dos logs.

## Passo 5: Verificar Status dos Containers

```bash
docker-compose ps
```

Você deve ver algo como:

```
NAME            IMAGE                               STATUS
django-app      docker-django-...:latest           Up (healthy)
nginx-proxy     jc21/nginx-proxy-manager:latest    Up (healthy)
postgres-db     postgres:17.5                      Up (healthy)
postgres-backup prodrigestivill/postgres-backup..  Up
midia-backup    fdrake/rsync-cron:latest          Up
```

!!! success "Tudo Funcionando!"
    Todos os containers devem estar com status "Up" e os principais devem mostrar "(healthy)".

## Passo 6: Acessar a Aplicação

### Interface Web do Nginx Proxy Manager

1. Acesse: `http://localhost:81`
2. Faça login com as credenciais padrão:
   - **Email**: `admin@example.com`
   - **Senha**: `changeme`

!!! danger "Primeira Coisa a Fazer"
    Altere a senha padrão imediatamente após o primeiro login!

### Configurar Proxy para o Django

1. No painel do Nginx, vá em **Hosts > Proxy Hosts**
2. Clique em **Add Proxy Host**
3. Preencha:
   - **Domain Names**: `localhost` (ou seu domínio)
   - **Scheme**: `http`
   - **Forward Hostname / IP**: `django-app`
   - **Forward Port**: `8000`
   - Marque: `Cache Assets`, `Block Common Exploits`, `Websockets Support`

4. Na aba **Advanced**, adicione:

```nginx
location /static/ {
    alias /var/www/staticfiles/;
    access_log off;
    expires 1y;
    add_header Cache-Control "public";
}

location /media/ {
    alias /var/www/media/;
    access_log off;
    expires 30d;
    add_header Cache-Control "public";
}
```

5. Clique em **Save**

### Acessar o Django

Agora você pode acessar a aplicação Django em `http://localhost`

## Passo 7: Criar Superusuário do Django

Para acessar o painel administrativo do Django:

```bash
docker-compose exec django-app python manage.py createsuperuser
```

Siga as instruções para criar o usuário admin.

Acesse: `http://localhost/admin`

## Comandos Úteis

### Ver Logs

```bash
# Todos os serviços
docker-compose logs -f

# Apenas Django
docker-compose logs -f django-app

# Apenas Nginx
docker-compose logs -f nginx-proxy

# Apenas PostgreSQL
docker-compose logs -f postgres-db
```

### Parar os Containers

```bash
docker-compose stop
```

### Reiniciar os Containers

```bash
docker-compose restart
```

### Parar e Remover Containers

```bash
docker-compose down
```

!!! warning "Atenção"
    O comando `down` **não remove** os volumes. Seus dados do banco e backups estão seguros.

### Remover Tudo (incluindo volumes)

```bash
docker-compose down -v
```

!!! danger "Cuidado!"
    Este comando **remove todos os dados**, incluindo banco de dados e backups!

### Executar Comandos Django

```bash
# Migrations
docker-compose exec django-app python manage.py migrate

# Criar app
docker-compose exec django-app python manage.py startapp nome_app

# Shell do Django
docker-compose exec django-app python manage.py shell

# Coletar arquivos estáticos
docker-compose exec django-app python manage.py collectstatic --no-input
```

### Acessar Bash do Container

```bash
# Django
docker-compose exec django-app bash

# PostgreSQL
docker-compose exec postgres-db bash
```

## Modo Desenvolvimento vs Produção

### Desenvolvimento (DEBUG=1)

```env
DEBUG=1
```

- Usa SQLite como banco de dados
- Servidor de desenvolvimento do Django
- Erros detalhados no navegador
- Arquivos estáticos servidos automaticamente

### Produção (DEBUG=0)

```env
DEBUG=0
```

- Usa PostgreSQL como banco de dados
- Gunicorn como servidor WSGI
- Erros genéricos (sem detalhes sensíveis)
- Arquivos estáticos via Nginx

## Problemas Comuns

### Porta já em uso

**Erro**: `Bind for 0.0.0.0:80 failed: port is already allocated`

**Solução**:
```bash
# Windows - Ver o que está usando a porta
netstat -ano | findstr :80

# Linux/Mac
sudo lsof -i :80

# Ou altere a porta no docker-compose.yml
ports:
  - '8080:80'  # Acesse via localhost:8080
```

### Container não inicia (unhealthy)

```bash
# Ver logs detalhados
docker-compose logs container-name

# Reiniciar container específico
docker-compose restart container-name
```

### Erro de migração do Django

```bash
# Forçar migrations
docker-compose exec django-app python manage.py migrate --run-syncdb
```

### Permissões negadas (Linux)

```bash
# Ajustar propriedade dos arquivos
sudo chown -R $USER:$USER .
```

## Próximos Passos

Agora que tudo está funcionando:

1. [Configure o SSL/TLS](nginx/ssl.md) para HTTPS
2. [Entenda a arquitetura](architecture/overview.md) do projeto
3. [Configure o backup](backup/strategy.md) adequadamente
4. [Prepare para produção](deploy/production.md)

## Checklist de Verificação

- [ ] Todos os containers estão rodando
- [ ] Consegue acessar o Django via browser
- [ ] Consegue acessar o painel do Nginx
- [ ] Consegue acessar o admin do Django
- [ ] Alterou a senha padrão do Nginx
- [ ] Configurou variáveis de ambiente seguras
- [ ] `.env` está no `.gitignore`
- [ ] Testou criar e acessar um objeto no Django admin

Se todos os itens estão marcados, você está pronto para começar a desenvolver!
