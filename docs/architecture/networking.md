# Rede e Volumes

## Rede Docker

### nginx-network

Rede bridge customizada que conecta todos os serviços.

**Tipo**: Bridge
**Driver**: bridge

**Vantagens**:
- DNS automático entre containers
- Isolamento de outros containers
- Comunicação eficiente

**Resolução de Nomes**:
```
django-app → http://django-app:8000
postgres-db → postgresql://postgres-db:5432
nginx-proxy → http://nginx-proxy:80
```

## Volumes

### Volumes Nomeados

**postgres_data**
- Dados do PostgreSQL
- Persistente após `docker-compose down`
- Gerenciado pelo Docker

**backup**
- Backups do banco de dados
- Backups de arquivos de mídia
- Compartilhado entre postgres-backup e midia-backup

### Bind Mounts

**./:/app**
- Código fonte da aplicação
- Permite desenvolvimento com hot reload

**./media:/app/media**
- Arquivos de upload (imagens, documentos)
- Acessível diretamente do host

**./staticfiles:/app/staticfiles**
- Arquivos CSS, JS, imagens estáticas
- Coletados via collectstatic

**./data:/data**
- Configurações do Nginx Proxy Manager
- Banco SQLite interno
- Logs

**./letsencrypt:/etc/letsencrypt**
- Certificados SSL/TLS
- Renovados automaticamente

## Diagrama de Volumes

```
Host                          Docker Volumes
────────────────────────    ─────────────────

./media ──────────────────► Volume: backup
    │                             │
    └──────────────────────► /app/media (django-app)
                                  │
                                  └──► /data/source (midia-backup)

./staticfiles ────────────► /app/staticfiles (django-app)
                                  │
                                  └──► /var/www/staticfiles (nginx-proxy)

postgres_data ────────────► /var/lib/postgresql/data (postgres-db)
                                  │
                                  └──► Backups → Volume: backup
```
