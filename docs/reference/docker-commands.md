# Referência Rápida de Comandos Docker

Guia de referência rápida para comandos Docker e Docker Compose mais utilizados.

## Docker Compose

### Gerenciamento de Containers

```bash
# Construir imagens
docker-compose build

# Construir sem cache
docker-compose build --no-cache

# Construir um serviço específico
docker-compose build django-app

# Iniciar todos os serviços
docker-compose up

# Iniciar em background
docker-compose up -d

# Iniciar um serviço específico
docker-compose up django-app

# Parar todos os serviços
docker-compose stop

# Parar um serviço específico
docker-compose stop django-app

# Reiniciar todos os serviços
docker-compose restart

# Reiniciar um serviço específico
docker-compose restart django-app

# Parar e remover containers
docker-compose down

# Parar, remover containers e volumes
docker-compose down -v

# Parar, remover tudo incluindo imagens
docker-compose down --rmi all -v
```

### Visualização de Status

```bash
# Ver status dos containers
docker-compose ps

# Ver logs de todos os serviços
docker-compose logs

# Ver logs em tempo real
docker-compose logs -f

# Logs de um serviço específico
docker-compose logs -f django-app

# Últimas 100 linhas de log
docker-compose logs --tail=100 django-app

# Ver processos rodando
docker-compose top
```

### Execução de Comandos

```bash
# Executar comando em container rodando
docker-compose exec django-app bash

# Executar sem TTY
docker-compose exec -T django-app python manage.py migrate

# Executar como root
docker-compose exec -u root django-app bash

# Executar comando único
docker-compose exec django-app python manage.py createsuperuser

# Rodar container temporário
docker-compose run --rm django-app python manage.py shell
```

## Django Management

### Migrações

```bash
# Criar migrations
docker-compose exec django-app python manage.py makemigrations

# Aplicar migrations
docker-compose exec django-app python manage.py migrate

# Ver status das migrations
docker-compose exec django-app python manage.py showmigrations

# Reverter migration
docker-compose exec django-app python manage.py migrate app_name 0001

# Fazer squash de migrations
docker-compose exec django-app python manage.py squashmigrations app_name 0001 0005
```

### Superusuário

```bash
# Criar superusuário interativo
docker-compose exec django-app python manage.py createsuperuser

# Criar superusuário programaticamente
docker-compose exec django-app python manage.py shell -c "
from django.contrib.auth import get_user_model;
User = get_user_model();
User.objects.create_superuser('admin', 'admin@example.com', 'senha123')
"
```

### Arquivos Estáticos

```bash
# Coletar arquivos estáticos
docker-compose exec django-app python manage.py collectstatic --noinput

# Limpar e recoletar
docker-compose exec django-app python manage.py collectstatic --clear --noinput

# Ver quais arquivos serão coletados
docker-compose exec django-app python manage.py collectstatic --dry-run
```

### Shell e Debug

```bash
# Django shell
docker-compose exec django-app python manage.py shell

# Django shell_plus (se django-extensions instalado)
docker-compose exec django-app python manage.py shell_plus

# IPython shell
docker-compose exec django-app python manage.py shell -i ipython

# Executar script Python
docker-compose exec django-app python manage.py shell < script.py
```

### Testes

```bash
# Rodar todos os testes
docker-compose exec django-app python manage.py test

# Rodar testes de uma app
docker-compose exec django-app python manage.py test app_name

# Rodar teste específico
docker-compose exec django-app python manage.py test app_name.tests.TestClass.test_method

# Rodar com coverage
docker-compose exec django-app coverage run --source='.' manage.py test
docker-compose exec django-app coverage report
docker-compose exec django-app coverage html
```

### Outros Comandos Django

```bash
# Ver todas as rotas
docker-compose exec django-app python manage.py show_urls

# Validar models
docker-compose exec django-app python manage.py check

# Limpar sessões expiradas
docker-compose exec django-app python manage.py clearsessions

# Criar app
docker-compose exec django-app python manage.py startapp nome_app

# Gerar requirements
docker-compose exec django-app pip freeze > requirements.txt
```

## PostgreSQL

### Acesso ao Banco

```bash
# Acessar psql
docker-compose exec postgres-db psql -U postgres -d db-modelo

# Executar query diretamente
docker-compose exec postgres-db psql -U postgres -d db-modelo -c "SELECT * FROM django_migrations;"

# Executar arquivo SQL
docker-compose exec -T postgres-db psql -U postgres -d db-modelo < script.sql
```

### Backup e Restore

```bash
# Backup manual
docker-compose exec postgres-db pg_dump -U postgres db-modelo > backup_manual.sql

# Backup comprimido
docker-compose exec postgres-db pg_dump -U postgres db-modelo | gzip > backup_manual.sql.gz

# Restaurar backup
docker-compose exec -T postgres-db psql -U postgres -d db-modelo < backup_manual.sql

# Restaurar backup comprimido
gunzip -c backup_manual.sql.gz | docker-compose exec -T postgres-db psql -U postgres -d db-modelo
```

### Informações do Banco

```bash
# Listar bancos
docker-compose exec postgres-db psql -U postgres -c "\l"

# Listar tabelas
docker-compose exec postgres-db psql -U postgres -d db-modelo -c "\dt"

# Descrever tabela
docker-compose exec postgres-db psql -U postgres -d db-modelo -c "\d nome_tabela"

# Ver tamanho do banco
docker-compose exec postgres-db psql -U postgres -c "
SELECT pg_size_pretty(pg_database_size('db-modelo'));
"

# Ver conexões ativas
docker-compose exec postgres-db psql -U postgres -c "
SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;
"
```

## Nginx

### Logs

```bash
# Ver logs de acesso
docker-compose exec nginx-proxy cat /data/logs/fallback_access.log

# Ver logs de erro
docker-compose exec nginx-proxy cat /data/logs/fallback_error.log

# Logs em tempo real
docker-compose exec nginx-proxy tail -f /data/logs/proxy-host-1_access.log
```

### Configuração

```bash
# Ver configuração gerada
docker-compose exec nginx-proxy cat /data/nginx/proxy_host/1.conf

# Testar configuração
docker-compose exec nginx-proxy nginx -t

# Recarregar configuração
docker-compose exec nginx-proxy nginx -s reload

# Ver versão do Nginx
docker-compose exec nginx-proxy nginx -v
```

## Docker (sem Compose)

### Containers

```bash
# Listar containers rodando
docker ps

# Listar todos os containers
docker ps -a

# Parar container
docker stop container_id

# Remover container
docker rm container_id

# Forçar remoção
docker rm -f container_id

# Ver logs
docker logs container_id

# Logs em tempo real
docker logs -f container_id

# Inspecionar container
docker inspect container_id

# Ver estatísticas
docker stats

# Ver processos
docker top container_id
```

### Imagens

```bash
# Listar imagens
docker images

# Remover imagem
docker rmi image_id

# Forçar remoção
docker rmi -f image_id

# Baixar imagem
docker pull python:3.13

# Construir imagem
docker build -t nome:tag .

# Inspecionar imagem
docker inspect image_id

# Ver histórico
docker history image_id
```

### Volumes

```bash
# Listar volumes
docker volume ls

# Inspecionar volume
docker volume inspect volume_name

# Criar volume
docker volume create volume_name

# Remover volume
docker volume rm volume_name

# Remover volumes não usados
docker volume prune

# Ver tamanho dos volumes
docker system df -v
```

### Rede

```bash
# Listar redes
docker network ls

# Inspecionar rede
docker network inspect network_name

# Criar rede
docker network create network_name

# Remover rede
docker network rm network_name

# Conectar container a rede
docker network connect network_name container_id

# Desconectar
docker network disconnect network_name container_id
```

### Limpeza

```bash
# Remover containers parados
docker container prune

# Remover imagens não usadas
docker image prune

# Remover volumes não usados
docker volume prune

# Remover redes não usadas
docker network prune

# Limpar tudo (CUIDADO!)
docker system prune

# Limpar tudo incluindo volumes
docker system prune -a --volumes

# Ver espaço usado
docker system df
```

## Backup e Manutenção

### Backup do Projeto

```bash
# Backup completo do projeto
tar -czf backup-projeto-$(date +%Y%m%d).tar.gz \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='node_modules' \
  .

# Backup do volume de backup
docker run --rm \
  -v docker-django-nginx-postgresql-backup_backup:/source \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/backup-volume-$(date +%Y%m%d).tar.gz -C /source .

# Backup do banco de dados
docker-compose exec postgres-db pg_dump -U postgres db-modelo | \
  gzip > backup-db-$(date +%Y%m%d).sql.gz
```

### Verificações de Saúde

```bash
# Ver healthcheck de todos os containers
docker-compose ps

# Healthcheck detalhado
docker inspect --format='{{json .State.Health}}' django-app | jq

# Testar conectividade entre containers
docker-compose exec django-app ping postgres-db

# Testar porta do Django
docker-compose exec nginx-proxy curl http://django-app:8000

# Testar banco de dados
docker-compose exec postgres-db pg_isready -U postgres
```

### Monitoramento

```bash
# Ver uso de recursos em tempo real
docker stats

# Ver uso de disco
docker system df

# Ver eventos do Docker
docker events

# Inspecionar logs do sistema
journalctl -u docker.service

# Ver configuração do Docker
docker info
```

## Troubleshooting

### Container não inicia

```bash
# Ver erro completo
docker-compose logs container_name

# Iniciar em modo interativo
docker-compose run --rm container_name bash

# Ver o que está impedindo
docker-compose up --no-start container_name
docker start -ai container_name
```

### Problemas de Rede

```bash
# Verificar IP do container
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_id

# Testar DNS
docker-compose exec django-app nslookup postgres-db

# Recriar rede
docker-compose down
docker network rm project_network
docker-compose up -d
```

### Problemas de Permissão

```bash
# Ajustar permissões de arquivos (Linux)
sudo chown -R $USER:$USER .

# Ver usuário que está rodando no container
docker-compose exec django-app whoami

# Ver permissões de arquivo
docker-compose exec django-app ls -la /app
```

### Limpar e Reiniciar

```bash
# Reset completo (CUIDADO: perde dados!)
docker-compose down -v
docker system prune -a
docker volume prune
docker network prune
docker-compose build --no-cache
docker-compose up -d
```

## Produção

### Deploy

```bash
# Build para produção
docker-compose -f docker-compose.prod.yml build

# Deploy
docker-compose -f docker-compose.prod.yml up -d

# Ver logs sem parar
docker-compose -f docker-compose.prod.yml logs -f --tail=100

# Atualizar serviço sem downtime
docker-compose -f docker-compose.prod.yml up -d --no-deps --build django-app
```

### Healthchecks em Produção

```bash
# Verificar todos os serviços
curl http://localhost:8069  # Backup healthcheck

# Endpoint customizado
curl https://seu-dominio.com/health/

# Verificar SSL
curl -vI https://seu-dominio.com 2>&1 | grep -i ssl
```

## Aliases Úteis

Adicione ao seu `~/.bashrc` ou `~/.zshrc`:

```bash
# Docker Compose shortcuts
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dcp='docker-compose ps'
alias dcr='docker-compose restart'

# Django shortcuts
alias dj='docker-compose exec django-app python manage.py'
alias djm='docker-compose exec django-app python manage.py migrate'
alias djmm='docker-compose exec django-app python manage.py makemigrations'
alias djs='docker-compose exec django-app python manage.py shell'
alias djt='docker-compose exec django-app python manage.py test'

# Docker shortcuts
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dv='docker volume ls'
alias dn='docker network ls'

# Limpeza
alias docker-clean='docker system prune -a --volumes'
alias docker-clean-safe='docker system prune'
```

Recarregar:
```bash
source ~/.bashrc  # ou ~/.zshrc
```

## Variáveis de Ambiente

```bash
# Usar arquivo .env diferente
docker-compose --env-file .env.production up -d

# Sobrescrever variável
POSTGRES_PASSWORD=nova_senha docker-compose up -d

# Ver variáveis no container
docker-compose exec django-app env

# Ver variável específica
docker-compose exec django-app printenv POSTGRES_HOST
```

## Scripts Úteis

### Start Script

`start.sh`:
```bash
#!/bin/bash
set -e

echo "Iniciando aplicação..."

# Verificar se .env existe
if [ ! -f .env ]; then
    echo "Erro: .env não encontrado!"
    exit 1
fi

# Build e start
docker-compose build
docker-compose up -d

# Aguardar PostgreSQL
echo "Aguardando PostgreSQL..."
sleep 10

# Migrations
docker-compose exec -T django-app python manage.py migrate

# Collect static
docker-compose exec -T django-app python manage.py collectstatic --noinput

echo "Aplicação iniciada com sucesso!"
docker-compose ps
```

### Stop Script

`stop.sh`:
```bash
#!/bin/bash

echo "Parando aplicação..."
docker-compose stop
echo "Aplicação parada."
```

Tornar executável:
```bash
chmod +x start.sh stop.sh
./start.sh
```

## Próximos Passos

- [FAQ](faq.md)
- [Troubleshooting](../deploy/troubleshooting.md)
- [Recursos Adicionais](resources.md)
