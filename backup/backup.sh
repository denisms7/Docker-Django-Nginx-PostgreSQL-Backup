#!/bin/bash
set -euo pipefail

# Carrega variáveis de ambiente se o arquivo existir
if [ -f /root/env.sh ]; then
    source /root/env.sh
fi

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backup/output"  # ✅ Mudou de /backup para /backup/output

# Garante que o diretório existe
mkdir -p "$BACKUP_DIR"

echo "======================================"
echo "🚀 Backup iniciado em $(date)"
echo "======================================"

# Verifica variáveis necessárias
echo "🔍 Verificando variáveis de ambiente..."
echo "POSTGRES_HOST: ${POSTGRES_HOST:-postgres-db}"
echo "POSTGRES_USER: ${POSTGRES_USER:-NOT_SET}"
echo "POSTGRES_DB: ${POSTGRES_DB:-NOT_SET}"
echo "POSTGRES_PASSWORD: $(if [ -n "${POSTGRES_PASSWORD:-}" ]; then echo "***SET***"; else echo "NOT_SET"; fi)"

# Backup do banco PostgreSQL
if [ -n "${POSTGRES_USER:-}" ] && [ -n "${POSTGRES_DB:-}" ]; then
    echo "💾 Fazendo backup do banco de dados..."
    
    export PGPASSWORD="${POSTGRES_PASSWORD:-}"
    
    if pg_dump \
        -h "${POSTGRES_HOST:-postgres-db}" \
        -U "$POSTGRES_USER" \
        "$POSTGRES_DB" \
        > "$BACKUP_DIR/db_$DATE.sql" 2>&1; then
        
        BACKUP_SIZE=$(du -h "$BACKUP_DIR/db_$DATE.sql" | cut -f1)
        echo "✅ Backup do banco finalizado ($BACKUP_SIZE)"
    else
        echo "❌ ERRO ao fazer backup do banco!"
        cat "$BACKUP_DIR/db_$DATE.sql" 2>/dev/null || true
        rm -f "$BACKUP_DIR/db_$DATE.sql"
    fi
else
    echo "⚠️ Variáveis POSTGRES_USER ou POSTGRES_DB não definidas, pulando backup do banco"
fi

# Backup da pasta de mídia
if [ -d "/media" ]; then
    echo "📁 Fazendo backup da pasta de mídia..."
    if tar czf "$BACKUP_DIR/media_$DATE.tar.gz" -C /media . 2>&1; then
        MEDIA_SIZE=$(du -h "$BACKUP_DIR/media_$DATE.tar.gz" | cut -f1)
        echo "✅ Backup da mídia finalizado ($MEDIA_SIZE)"
    else
        echo "❌ ERRO ao fazer backup da mídia!"
    fi
else
    echo "⚠️ Pasta /media não encontrada, pulando backup da mídia"
fi

# Backup do volume de dados do PostgreSQL (extra)
if [ -d "/pgdata" ]; then
    echo "🗄️ Fazendo backup do volume do PostgreSQL..."
    if tar czf "$BACKUP_DIR/pgdata_$DATE.tar.gz" -C /pgdata . 2>&1; then
        PGDATA_SIZE=$(du -h "$BACKUP_DIR/pgdata_$DATE.tar.gz" | cut -f1)
        echo "✅ Backup do volume do banco finalizado ($PGDATA_SIZE)"
    else
        echo "❌ ERRO ao fazer backup do volume do banco!"
    fi
else
    echo "⚠️ Pasta /pgdata não encontrada, pulando backup do volume do banco"
fi

# Limpeza de backups antigos (mais de 7 dias)
echo "🧹 Removendo backups com mais de 7 dias..."
DELETED=$(find "$BACKUP_DIR" -type f \( -name "*.sql" -o -name "*.tar.gz" \) -mtime +7 -delete -print | wc -l)
echo "✅ Limpeza concluída ($DELETED arquivos removidos)"

echo "======================================"
echo "🎉 Backup finalizado em $(date)"
echo "======================================"
echo ""