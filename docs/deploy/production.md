# Deploy em Produção

Guia para fazer deploy seguro em produção.

## Pré-requisitos

- Servidor Linux (Ubuntu 22.04+ recomendado)
- Docker e Docker Compose instalados
- Domínio apontando para o servidor
- SSH configurado
- Firewall configurado

## Passos de Deploy

### 1. Preparar o Servidor

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo apt install docker-compose-plugin

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
```

### 2. Configurar Firewall

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 3. Clonar Projeto

```bash
git clone https://github.com/seu-usuario/projeto.git
cd projeto
```

### 4. Configurar Variáveis de Ambiente

```bash
cp .env.example .env
nano .env
```

Configure valores seguros:
- `SECRET_KEY` nova e aleatória
- `DEBUG=0`
- `ALLOWED_HOSTS` com seus domínios
- Senhas fortes do PostgreSQL

### 5. Ajustar docker-compose.yml

```yaml
# Remover porta 81 do público
nginx-proxy:
  ports:
    - '80:80'
    - '443:443'
    - '127.0.0.1:81:81'  # Apenas localhost
```

### 6. Build e Deploy

```bash
docker-compose build --no-cache
docker-compose up -d
```

### 7. Verificar Status

```bash
docker-compose ps
docker-compose logs -f
```

### 8. Configurar SSL

1. Acesse `http://SEU-IP:81`
2. Configure proxy host para seu domínio
3. Adicione certificado Let's Encrypt

### 9. Criar Superusuário

```bash
docker-compose exec django-app python manage.py createsuperuser
```

### 10. Verificar Segurança

Execute o [Checklist de Segurança](../security/checklist.md).

## Manutenção

### Atualizar Aplicação

```bash
git pull origin main
docker-compose build --no-cache
docker-compose up -d
```

### Ver Logs

```bash
docker-compose logs -f django-app
```

### Backup Manual

```bash
# Banco de dados
docker-compose exec postgres-db pg_dump -U postgres db-modelo > backup-$(date +%Y%m%d).sql

# Volume completo
docker run --rm -v backup:/source -v $(pwd):/dest alpine tar czf /dest/backup-$(date +%Y%m%d).tar.gz -C /source .
```

## Rollback

```bash
# Voltar para versão anterior
git checkout commit-anterior
docker-compose build --no-cache
docker-compose up -d

# Restaurar banco se necessário
docker-compose exec -T postgres-db psql -U postgres -d db-modelo < backup-anterior.sql
```

## Monitoramento

Configure ferramentas de monitoramento:
- Sentry para erros
- Prometheus + Grafana para métricas
- UptimeRobot para disponibilidade

## Próximos Passos

- [Troubleshooting](troubleshooting.md)
- [Checklist de Segurança](../security/checklist.md)
