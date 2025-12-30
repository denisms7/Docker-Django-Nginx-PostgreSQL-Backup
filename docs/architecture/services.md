# Serviços Docker

Detalhamento de cada serviço do `docker-compose.yml`.

## nginx-proxy

Proxy reverso com interface de gerenciamento.

**Imagem**: `jc21/nginx-proxy-manager:latest`

**Portas**:
- 80: HTTP
- 443: HTTPS
- 81: Interface Admin

**Volumes**:
- `./data:/data` - Configurações e banco SQLite
- `./letsencrypt:/etc/letsencrypt` - Certificados SSL
- `./staticfiles:/var/www/staticfiles:ro` - Arquivos estáticos

**Healthcheck**: Verifica se o serviço está respondendo

## django-app

Aplicação Django principal.

**Build**: `./Dockerfile`

**Porta**: 8000 (exposta apenas internamente)

**Volumes**:
- `./:/app` - Código fonte
- `./staticfiles:/app/staticfiles` - Arquivos estáticos
- `./media:/app/media` - Arquivos de mídia

**Comando**: Executa migrations, collectstatic e inicia Gunicorn

**Depende de**: postgres-db e nginx-proxy

## postgres-db

Banco de dados PostgreSQL 17.5.

**Porta**: 5432 (apenas rede Docker)

**Volume**: `postgres_data:/var/lib/postgresql/data`

**Healthcheck**: `pg_isready` verifica disponibilidade

## postgres-backup

Backup automatizado do PostgreSQL.

**Imagem**: `prodrigestivill/postgres-backup-local:latest`

**Agendamento**: Diário às 3h (América/São_Paulo)

**Retenção**: 7 dias, 4 semanas, 4 meses

**Volume**: `backup:/backups`

**Porta Healthcheck**: 8069

## midia-backup

Sincronização de arquivos de mídia.

**Imagem**: `fdrake/rsync-cron:latest`

**Agendamento**: Diário às 3h

**Volumes**:
- `./media:/data/source:ro` - Origem (read-only)
- `backup:/data/backup` - Destino

**Operação**: `rsync -av --delete`
