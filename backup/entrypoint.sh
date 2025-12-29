#!/bin/bash
set -e

echo "🔧 Configurando ambiente..."

# Cria script wrapper que carrega variáveis (ESCAPANDO o heredoc)
cat > /backup/run-backup.sh << 'EOF'
#!/bin/bash
export POSTGRES_HOST="${POSTGRES_HOST:-postgres-db}"
export POSTGRES_USER="${POSTGRES_USER}"
export POSTGRES_DB="${POSTGRES_DB}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export TZ="${TZ}"
/backup/backup.sh
EOF

chmod +x /backup/run-backup.sh

# Cria arquivo .pgpass
if [ -n "${POSTGRES_PASSWORD:-}" ]; then
    echo "${POSTGRES_HOST:-postgres-db}:5432:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" > /root/.pgpass
    chmod 600 /root/.pgpass
    echo "✅ .pgpass criado"
fi

# Cria crontab do zero (sem caracteres Windows)
cat > /etc/cron.d/backup-cron << 'CRONTAB'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 3 * * * root /backup/run-backup.sh >> /backup/backup.log 2>&1

CRONTAB

chmod 0644 /etc/cron.d/backup-cron
touch /backup/backup.log
chmod 666 /backup/backup.log

echo "✅ Configuração concluída"
echo "🧪 Testando backup manual..."
/backup/run-backup.sh

echo ""
echo "🚀 Iniciando cron..."
exec cron -f -L 15