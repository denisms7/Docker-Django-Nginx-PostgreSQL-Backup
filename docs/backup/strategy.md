# Estratégia de Backup

Documentação completa da estratégia de backup implementada no projeto.

## Visão Geral

O projeto implementa uma estratégia de backup automatizado com dois componentes principais:

1. **Backup do PostgreSQL** - Base de dados completa
2. **Backup de Mídia** - Arquivos de upload (imagens, documentos, etc.)

Ambos os backups são armazenados no mesmo volume Docker (`backup:/backups`) para facilitar o gerenciamento.

## Regra 3-2-1

A estratégia de backup ideal segue a regra **3-2-1**:

- **3** cópias dos seus dados (original + 2 backups)
- **2** tipos de mídia diferentes (ex: disco local + cloud)
- **1** cópia offsite (fora do servidor principal)

### Como Implementar

```
┌─────────────────────────────────────────────────────────┐
│ Servidor de Produção                                    │
│                                                          │
│  Original (PostgreSQL) ─────► Backup Local (Volume)     │
│                                     │                    │
│  Original (Mídia)      ─────► Backup Local (Volume)     │
└──────────────────────────────────────┬──────────────────┘
                                       │
                                       │ Sincronização
                                       │
                         ┌─────────────▼─────────────┐
                         │   Cloud Storage (AWS S3)  │
                         │   Backup Offsite          │
                         └───────────────────────────┘
```

## Backup do PostgreSQL

### Configuração

```yaml
postgres-backup:
  image: prodrigestivill/postgres-backup-local:latest
  container_name: postgres-backup
  depends_on:
    postgres-db:
      condition: service_healthy
  environment:
    POSTGRES_HOST: ${POSTGRES_HOST}
    POSTGRES_PORT: ${POSTGRES_PORT:-5432}
    POSTGRES_USER: ${POSTGRES_USER}
    POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    POSTGRES_DB: ${POSTGRES_DB}
    TZ: America/Sao_Paulo
    SCHEDULE: "0 3 * * *"
    BACKUP_KEEP_DAYS: 7
    BACKUP_KEEP_WEEKS: 4
    BACKUP_KEEP_MONTHS: 4
    HEALTHCHECK_PORT: ${HEALTHCHECK_PORT:-8080}
  volumes:
    - backup:/backups
  restart: always
  expose:
    - "${HEALTHCHECK_PORT:-8080}"
  networks:
    - nginx-network
```

### Agendamento

```
SCHEDULE: "0 3 * * *"
```

**Formato Cron**: `minuto hora dia mês dia_da_semana`

| Componente | Valor | Descrição |
|------------|-------|-----------|
| Minuto | 0 | No minuto zero |
| Hora | 3 | Às 3h da manhã |
| Dia | * | Todos os dias |
| Mês | * | Todos os meses |
| Dia da semana | * | Todos os dias da semana |

#### Exemplos de Agendamento

```bash
# A cada 6 horas
SCHEDULE: "0 */6 * * *"

# Diário às 2h30
SCHEDULE: "30 2 * * *"

# Duas vezes ao dia (2h e 14h)
SCHEDULE: "0 2,14 * * *"

# Apenas em dias úteis às 3h
SCHEDULE: "0 3 * * 1-5"

# Semanalmente aos domingos às 4h
SCHEDULE: "0 4 * * 0"
```

### Política de Retenção

```env
BACKUP_KEEP_DAYS: 7      # Mantém backups diários dos últimos 7 dias
BACKUP_KEEP_WEEKS: 4     # Mantém 1 backup por semana das últimas 4 semanas
BACKUP_KEEP_MONTHS: 4    # Mantém 1 backup por mês dos últimos 4 meses
```

#### Como Funciona

1. **Diários**: Backup completo todos os dias, mantém os últimos 7
   - Dia 1: `db-modelo_2025-12-30_03-00-00.sql.gz`
   - Dia 2: `db-modelo_2025-12-31_03-00-00.sql.gz`
   - ...
   - Dia 7: `db-modelo_2026-01-05_03-00-00.sql.gz`
   - Dia 8: Remove o backup do Dia 1

2. **Semanais**: Mantém o backup de domingo de cada semana, últimas 4 semanas
   - `db-modelo_weekly_2025-W52.sql.gz`
   - `db-modelo_weekly_2026-W01.sql.gz`
   - ...

3. **Mensais**: Mantém o backup do último dia de cada mês, últimos 4 meses
   - `db-modelo_monthly_2025-12.sql.gz`
   - `db-modelo_monthly_2026-01.sql.gz`
   - ...

#### Ajustar Retenção

Para mais tempo de retenção:

```env
# Manter por mais tempo
BACKUP_KEEP_DAYS: 14      # 2 semanas
BACKUP_KEEP_WEEKS: 8      # 2 meses
BACKUP_KEEP_MONTHS: 12    # 1 ano
```

Para espaço limitado:

```env
# Manter menos backups
BACKUP_KEEP_DAYS: 3
BACKUP_KEEP_WEEKS: 2
BACKUP_KEEP_MONTHS: 2
```

### Formato do Backup

Os backups são criados no formato **gzip** comprimido:

```
/backups/
├── db-modelo_2025-12-30_03-00-00.sql.gz
├── db-modelo_2025-12-31_03-00-00.sql.gz
└── db-modelo_weekly_2025-W52.sql.gz
```

**Características**:
- Compressão gzip (economiza espaço)
- Formato SQL plain text (compatível com pg_restore)
- Nomenclatura com timestamp
- Fácil identificação

### Verificar Backups

```bash
# Listar backups
docker-compose exec postgres-backup ls -lah /backups/

# Ver tamanho total
docker-compose exec postgres-backup du -sh /backups/

# Ver últimos backups
docker-compose exec postgres-backup ls -lt /backups/ | head -10

# Copiar backup para o host
docker cp postgres-backup:/backups/db-modelo_2025-12-30_03-00-00.sql.gz ./
```

### Healthcheck

O serviço de backup expõe um endpoint HTTP para monitoramento:

```bash
# Verificar saúde do serviço
curl http://localhost:8069

# Dentro da rede Docker
docker-compose exec django-app curl http://postgres-backup:8069
```

## Backup de Mídia

### Configuração

```yaml
midia-backup:
  image: fdrake/rsync-cron:latest
  container_name: midia-backup
  volumes:
    - ./media:/data/source:ro
    - backup:/data/backup
  environment:
    CRON: "0 3 * * *"
    RSYNC_SOURCE: "/data/source/"
    RSYNC_DEST: "/data/backup/midia/"
    RSYNC_OPTIONS: "-av --delete"
    TZ: America/Sao_Paulo
  restart: always
  networks:
    - nginx-network
```

### Como Funciona

O backup de mídia usa **rsync** para sincronizar arquivos:

```bash
rsync -av --delete /data/source/ /data/backup/midia/
```

**Opções**:
- `-a` (archive): Preserva permissões, timestamps, links simbólicos
- `-v` (verbose): Mostra progresso
- `--delete`: Remove arquivos no destino que não existem mais na origem

### Estrutura de Diretórios

```
backup volume:
├── [Backups do PostgreSQL]
│   ├── db-modelo_2025-12-30_03-00-00.sql.gz
│   └── ...
└── midia/
    ├── uploads/
    │   ├── perfil/
    │   │   ├── usuario1.jpg
    │   │   └── usuario2.png
    │   └── documentos/
    │       ├── arquivo1.pdf
    │       └── arquivo2.docx
    └── ...
```

### Opções do Rsync

Você pode customizar o comportamento:

```yaml
# Backup incremental (mais rápido)
RSYNC_OPTIONS: "-av --delete --partial --progress"

# Manter arquivos deletados (não usar --delete)
RSYNC_OPTIONS: "-av"

# Comprimir durante transferência
RSYNC_OPTIONS: "-avz --delete"

# Excluir padrões
RSYNC_OPTIONS: "-av --delete --exclude='*.tmp' --exclude='cache/'"

# Dry run (testar sem executar)
RSYNC_OPTIONS: "-av --delete --dry-run"
```

### Verificar Sincronização

```bash
# Listar arquivos sincronizados
docker-compose exec midia-backup ls -lah /data/backup/midia/

# Comparar origem e destino
docker-compose exec midia-backup du -sh /data/source/
docker-compose exec midia-backup du -sh /data/backup/midia/

# Ver logs do rsync
docker-compose logs midia-backup
```

## Gerenciamento de Volumes

### Localização dos Volumes

```bash
# Listar volumes
docker volume ls

# Inspecionar volume de backup
docker volume inspect docker-django-nginx-postgresql-backup_backup

# Ver localização no sistema
docker volume inspect docker-django-nginx-postgresql-backup_backup \
  --format='{{.Mountpoint}}'
```

**Localização típica (Linux)**:
```
/var/lib/docker/volumes/docker-django-nginx-postgresql-backup_backup/_data/
```

### Tamanho dos Volumes

```bash
# Ver tamanho do volume de backup
docker system df -v | grep backup

# Entrar no volume via container temporário
docker run --rm -it \
  -v docker-django-nginx-postgresql-backup_backup:/backups \
  alpine sh

# Dentro do container
du -sh /backups/*
```

### Backup do Volume Docker

```bash
# Criar backup do volume completo
docker run --rm \
  -v docker-django-nginx-postgresql-backup_backup:/source \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/backup-volume-$(date +%Y%m%d).tar.gz -C /source .

# Restaurar backup do volume
docker run --rm \
  -v docker-django-nginx-postgresql-backup_backup:/target \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/backup-volume-20251230.tar.gz -C /target
```

## Sincronização com Cloud

### AWS S3

Adicione ao `docker-compose.yml`:

```yaml
backup-sync:
  image: amazon/aws-cli
  container_name: backup-sync
  volumes:
    - backup:/backups:ro
  environment:
    AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
    AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
    AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}
  command: >
    sh -c "
    while true; do
      aws s3 sync /backups s3://meu-bucket/backups/ --delete
      sleep 86400
    done
    "
  restart: always
```

### Google Cloud Storage

```yaml
backup-sync:
  image: google/cloud-sdk:alpine
  container_name: backup-sync
  volumes:
    - backup:/backups:ro
    - ./gcloud-credentials.json:/credentials.json:ro
  environment:
    GOOGLE_APPLICATION_CREDENTIALS: /credentials.json
  command: >
    sh -c "
    while true; do
      gsutil -m rsync -r -d /backups gs://meu-bucket/backups/
      sleep 86400
    done
    "
  restart: always
```

### Azure Blob Storage

```yaml
backup-sync:
  image: mcr.microsoft.com/azure-cli
  container_name: backup-sync
  volumes:
    - backup:/backups:ro
  environment:
    AZURE_STORAGE_ACCOUNT: ${AZURE_STORAGE_ACCOUNT}
    AZURE_STORAGE_KEY: ${AZURE_STORAGE_KEY}
  command: >
    sh -c "
    while true; do
      az storage blob upload-batch \
        --destination backups \
        --source /backups \
        --overwrite
      sleep 86400
    done
    "
  restart: always
```

### Rclone (Universal)

Suporta 40+ cloud providers:

```yaml
backup-sync:
  image: rclone/rclone:latest
  container_name: backup-sync
  volumes:
    - backup:/backups:ro
    - ./rclone.conf:/config/rclone/rclone.conf:ro
  command: >
    sync /backups remote:backups
    --config /config/rclone/rclone.conf
    --progress
  restart: always
```

## Monitoramento de Backups

### Script de Verificação

Crie `check-backups.sh`:

```bash
#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Verificação de Backups ==="
echo ""

# 1. Verificar se o container de backup está rodando
if docker ps | grep -q postgres-backup; then
    echo -e "${GREEN}✓${NC} Container postgres-backup está rodando"
else
    echo -e "${RED}✗${NC} Container postgres-backup NÃO está rodando"
    exit 1
fi

# 2. Verificar último backup
LAST_BACKUP=$(docker exec postgres-backup ls -t /backups/*.sql.gz 2>/dev/null | head -1)

if [ -z "$LAST_BACKUP" ]; then
    echo -e "${RED}✗${NC} Nenhum backup encontrado!"
    exit 1
fi

BACKUP_DATE=$(docker exec postgres-backup stat -c %y "$LAST_BACKUP" | cut -d' ' -f1)
TODAY=$(date +%Y-%m-%d)

if [ "$BACKUP_DATE" == "$TODAY" ]; then
    echo -e "${GREEN}✓${NC} Backup de hoje existe: $(basename $LAST_BACKUP)"
else
    echo -e "${YELLOW}!${NC} Último backup é de: $BACKUP_DATE"
fi

# 3. Verificar tamanho do backup
BACKUP_SIZE=$(docker exec postgres-backup du -h "$LAST_BACKUP" | cut -f1)
echo -e "${GREEN}✓${NC} Tamanho do último backup: $BACKUP_SIZE"

# 4. Verificar sincronização de mídia
MEDIA_COUNT=$(docker exec midia-backup find /data/backup/midia -type f | wc -l)
echo -e "${GREEN}✓${NC} Arquivos de mídia no backup: $MEDIA_COUNT"

# 5. Verificar espaço em disco
DISK_USAGE=$(docker exec postgres-backup df -h /backups | tail -1 | awk '{print $5}')
echo -e "${GREEN}✓${NC} Uso do disco de backups: $DISK_USAGE"

echo ""
echo "=== Verificação Concluída ==="
```

Executar:
```bash
chmod +x check-backups.sh
./check-backups.sh
```

### Cron Job para Verificação

```bash
# Adicionar ao crontab do host
crontab -e

# Verificar backups diariamente às 4h
0 4 * * * /caminho/para/check-backups.sh >> /var/log/backup-check.log 2>&1
```

### Healthcheck Endpoints

Monitorar via HTTP:

```bash
# PostgreSQL Backup
curl http://localhost:8069 || echo "Backup service down!"

# Adicionar ao seu sistema de monitoramento
# (Prometheus, UptimeRobot, Pingdom, etc.)
```

## Teste de Recuperação

### Por que Testar?

> "Backups não testados são backups que não funcionam"

**Teste regularmente** (pelo menos mensalmente):

```bash
# 1. Criar banco de teste
docker-compose exec postgres-db createdb -U postgres teste_restore

# 2. Restaurar backup
docker-compose exec postgres-backup gunzip -c /backups/latest.sql.gz | \
  docker-compose exec -T postgres-db psql -U postgres -d teste_restore

# 3. Verificar dados
docker-compose exec postgres-db psql -U postgres -d teste_restore -c "\dt"

# 4. Limpar
docker-compose exec postgres-db dropdb -U postgres teste_restore
```

### Automação do Teste

Adicione ao `docker-compose.yml`:

```yaml
backup-test:
  image: postgres:17.5
  container_name: backup-test
  environment:
    POSTGRES_PASSWORD: test
  volumes:
    - backup:/backups:ro
  command: >
    sh -c "
    echo 'Aguardando PostgreSQL...'
    sleep 10
    echo 'Testando restauração...'
    gunzip -c /backups/*.sql.gz | head -100
    echo 'Teste OK'
    "
  profiles:
    - test
```

Executar:
```bash
docker-compose --profile test up backup-test
```

## Recuperação de Desastres

Veja [Restauração de Backup](restore.md) para procedimentos detalhados.

## Próximos Passos

- [Backup do Banco de Dados](database.md) - Detalhes técnicos
- [Backup de Mídia](media.md) - Configurações avançadas
- [Restauração](restore.md) - Procedimentos de recovery
- [Deploy em Produção](../deploy/production.md)
