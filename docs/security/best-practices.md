# Boas Práticas de Segurança

Guia completo de segurança para seu projeto Docker + Django.

## Problemas Identificados no Projeto Atual

### Críticos (Corrigir Imediatamente)

#### 1. Arquivo .env Versionado no Git

**Problema**: O arquivo `.env` contém credenciais sensíveis e está no repositório.

**Risco**: Exposição de senhas, SECRET_KEY, e outras informações confidenciais.

**Solução**:
```bash
# 1. Remover do histórico do Git
git rm --cached .env

# 2. Adicionar ao .gitignore
echo ".env" >> .gitignore

# 3. Criar template
cp .env .env.example
# Edite .env.example e substitua valores reais por placeholders

# 4. Commitar mudanças
git add .gitignore .env.example
git commit -m "Remove .env do controle de versão

Adiciona .env.example como template"
```

**Conteúdo do .env.example**:
```env
SECRET_KEY="CHANGE-ME-GENERATE-NEW-KEY"
DEBUG=0
ALLOWED_HOSTS="localhost,your-domain.com"

POSTGRES_DB="database_name"
POSTGRES_USER="db_user"
POSTGRES_PASSWORD="CHANGE-ME-USE-STRONG-PASSWORD"
POSTGRES_HOST="postgres-db"
POSTGRES_PORT="5432"

HEALTHCHECK_PORT="8069"
```

#### 2. SECRET_KEY Exposta

**Problema**: A SECRET_KEY padrão está no código e é insegura.

**Risco**: Comprometimento de sessões, CSRF tokens, assinaturas.

**Solução**:
```python
# Gerar nova chave
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Atualizar no .env
SECRET_KEY="sua-nova-chave-aqui-bem-longa-e-aleatoria"
```

#### 3. Senha Fraca do PostgreSQL

**Problema**: Senha "123postgres456" é facilmente quebrável.

**Risco**: Acesso não autorizado ao banco de dados.

**Solução**:
```bash
# Gerar senha forte
openssl rand -base64 32

# Atualizar no .env
POSTGRES_PASSWORD="X7k2#mP9$vL3@qR8^wN5*tY6&jH4!fG1"
```

**Requisitos mínimos**:
- 16+ caracteres
- Letras maiúsculas e minúsculas
- Números
- Símbolos especiais

### Médios (Corrigir em Breve)

#### 4. Porta Admin do Nginx Exposta

**Problema**: Porta 81 acessível externamente.

**Risco**: Interface de administração exposta à internet.

**Solução no docker-compose.yml**:
```yaml
nginx-proxy:
  ports:
    - '80:80'
    - '443:443'
    # Apenas localhost
    - '127.0.0.1:81:81'  # ⬅️ Mudar esta linha
```

#### 5. Credenciais Padrão do Nginx

**Problema**: Login padrão `admin@example.com` / `changeme`

**Risco**: Acesso não autorizado ao painel Nginx.

**Solução**:
1. Acesse `http://localhost:81`
2. Faça login
3. Vá em **Users > Edit**
4. Altere email e senha imediatamente

#### 6. Loop de Debug em settings.py

**Problema**: Código de debug em produção (linhas 20-21)

```python
for x in range(5):
    print(f"DEBUG: {DEBUG}")
```

**Solução**: Remover estas linhas
```python
# Simplesmente delete as linhas 20-21
```

### Baixos (Melhorias Recomendadas)

#### 7. Volume de Mídia Duplicado

**Problema**: Configuração confusa no docker-compose.yml

```yaml
volumes:
  - media:/app/media          # Volume nomeado
  - ./media:/app/media        # Bind mount (sobrescreve)
```

**Solução**: Escolher uma abordagem
```yaml
# Opção 1: Apenas bind mount (mais simples)
volumes:
  - ./media:/app/media

# Remover da seção volumes:
volumes:
  postgres_data:
  backup:
  # media:  ⬅️ Remover
```

#### 8. Healthcheck com Rota Inexistente

**Problema**: Healthcheck aponta para `/health/` que não existe

```yaml
test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
```

**Solução 1: Criar a rota**

`app/urls.py`:
```python
from django.http import JsonResponse
from django.db import connection

def health_check(request):
    try:
        # Testa conexão com banco
        connection.ensure_connection()
        return JsonResponse({'status': 'healthy'})
    except Exception as e:
        return JsonResponse({'status': 'unhealthy', 'error': str(e)}, status=500)

urlpatterns = [
    # ...
    path('health/', health_check, name='health'),
]
```

**Solução 2: Usar rota existente**
```yaml
test: ["CMD", "curl", "-f", "http://localhost:8000/admin/login/?next=/admin/"]
```

## Configurações Essenciais de Segurança

### Django settings.py

```python
# Quando DEBUG=False, SEMPRE configure:

# 1. ALLOWED_HOSTS - Apenas seus domínios
ALLOWED_HOSTS = [
    'meusite.com',
    'www.meusite.com',
]

# 2. CSRF_TRUSTED_ORIGINS - Para requests POST
CSRF_TRUSTED_ORIGINS = [
    'https://meusite.com',
    'https://www.meusite.com',
]

# 3. SECURE_SSL_REDIRECT - Forçar HTTPS
SECURE_SSL_REDIRECT = True

# 4. SECURE_HSTS_SECONDS - HSTS Header
SECURE_HSTS_SECONDS = 31536000  # 1 ano
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# 5. SECURE_BROWSER_XSS_FILTER
SECURE_BROWSER_XSS_FILTER = True

# 6. SECURE_CONTENT_TYPE_NOSNIFF
SECURE_CONTENT_TYPE_NOSNIFF = True

# 7. X_FRAME_OPTIONS - Previne clickjacking
X_FRAME_OPTIONS = 'DENY'

# 8. SESSION_COOKIE_SECURE - Cookies apenas via HTTPS
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# 9. SESSION_COOKIE_HTTPONLY
SESSION_COOKIE_HTTPONLY = True

# 10. SECURE_REFERRER_POLICY
SECURE_REFERRER_POLICY = 'same-origin'
```

### Configuração Completa por Ambiente

```python
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.getenv('SECRET_KEY')
DEBUG = bool(int(os.getenv('DEBUG', 0)))

if DEBUG:
    # Desenvolvimento
    ALLOWED_HOSTS = ['*']
    CSRF_COOKIE_SECURE = False
    SESSION_COOKIE_SECURE = False
    SECURE_SSL_REDIRECT = False
else:
    # Produção
    ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')
    CSRF_TRUSTED_ORIGINS = [
        f'https://{host}' for host in ALLOWED_HOSTS if host
    ]

    # Segurança HTTPS
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

    # Cookies seguros
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True

    # Headers de segurança
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    X_FRAME_OPTIONS = 'DENY'
    SECURE_REFERRER_POLICY = 'same-origin'
```

## Segurança Docker

### 1. Não Executar Como Root

**Problema**: Django roda como root no container

**Solução no Dockerfile**:
```dockerfile
FROM python:3.13.6-slim-bullseye AS base

# ... instalações ...

# Criar usuário não-privilegiado
RUN groupadd -r django && useradd -r -g django django

# Ajustar permissões
RUN chown -R django:django /app
RUN chown -R django:django /app/media
RUN chown -R django:django /app/staticfiles

# Mudar para usuário não-root
USER django

# ... resto do Dockerfile ...
```

### 2. Scan de Vulnerabilidades

```bash
# Instalar Trivy
# Linux
sudo apt-get install trivy

# Mac
brew install trivy

# Escanear imagem
trivy image docker-django-app:latest

# Apenas vulnerabilidades HIGH e CRITICAL
trivy image --severity HIGH,CRITICAL docker-django-app:latest
```

### 3. Limitar Recursos

No `docker-compose.yml`:
```yaml
django-app:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        memory: 512M
```

### 4. Rede Read-Only

Para serviços que não escrevem no filesystem:
```yaml
postgres-backup:
  read_only: true
  tmpfs:
    - /tmp
```

## Segurança PostgreSQL

### 1. Usuário Específico (Não usar postgres)

```sql
-- Conectar ao PostgreSQL
docker-compose exec postgres-db psql -U postgres

-- Criar usuário dedicado
CREATE USER django_app WITH PASSWORD 'senha_forte_aqui';

-- Criar banco
CREATE DATABASE projeto_db OWNER django_app;

-- Conceder permissões mínimas
GRANT CONNECT ON DATABASE projeto_db TO django_app;
GRANT USAGE ON SCHEMA public TO django_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO django_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO django_app;

-- Permissões para futuras tabelas
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO django_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO django_app;
```

Atualizar `.env`:
```env
POSTGRES_USER="django_app"
POSTGRES_PASSWORD="senha_forte_aqui"
```

### 2. Conexões SSL (Produção)

```python
# settings.py
if not DEBUG:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            # ... outras configs ...
            'OPTIONS': {
                'sslmode': 'require',
            }
        }
    }
```

### 3. Configurações do postgresql.conf

```conf
# Limitar conexões
max_connections = 100

# Log de queries lentas
log_min_duration_statement = 1000  # ms

# Log de conexões
log_connections = on
log_disconnections = on
```

## Segurança Nginx

### 1. Configuração Avançada

No painel Nginx, seção **Advanced**:

```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;
limit_req zone=mylimit burst=20 nodelay;

# Hide version
server_tokens off;

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

# Block user agents
if ($http_user_agent ~* (bot|crawler|spider|scraper)) {
    return 403;
}

# Protect sensitive files
location ~ /\. {
    deny all;
}

location ~* \.(env|git|gitignore|sql|log)$ {
    deny all;
}

# Static files
location /static/ {
    alias /var/www/staticfiles/;
    access_log off;
    expires 1y;
    add_header Cache-Control "public, immutable";
}

location /media/ {
    alias /var/www/media/;
    access_log off;
    expires 30d;
    add_header Cache-Control "public";

    # Bloquear execução de scripts
    location ~ \.php$ {
        deny all;
    }
}
```

### 2. SSL/TLS Forte

- Use Let's Encrypt (renovação automática)
- TLS 1.2 e 1.3 apenas
- Ciphers fortes
- HSTS habilitado

No Nginx Proxy Manager:
1. **SSL > Force SSL**: ON
2. **SSL > HTTP/2 Support**: ON
3. **SSL > HSTS Enabled**: ON
4. **SSL > HSTS Subdomains**: ON (se aplicável)

### 3. Fail2Ban (Opcional)

Protege contra brute force:

```bash
# Instalar no host (não no container)
sudo apt-get install fail2ban

# Configurar jail para Nginx
sudo nano /etc/fail2ban/jail.local
```

```ini
[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 3600

[nginx-noscript]
enabled = true
logpath = /var/log/nginx/access.log
maxretry = 6
bantime = 3600
```

## Backup Seguro

### 1. Criptografar Backups

Modificar backup do PostgreSQL:

```yaml
postgres-backup:
  environment:
    # ... outras vars ...
    POSTGRES_EXTRA_OPTS: "-Z9 --format=custom"
    # Adicionar criptografia
    BACKUP_ENCRYPTION_KEY: "${BACKUP_ENCRYPTION_KEY}"
```

### 2. Backup Offsite

Configure sincronização para cloud:

```bash
# Exemplo com rclone para AWS S3
docker run --rm \
  -v backup:/backups \
  -v ~/.config/rclone:/config/rclone \
  rclone/rclone \
  sync /backups s3:meu-bucket/backups/
```

### 3. Testar Restauração

```bash
# Regularmente teste se os backups funcionam
docker-compose exec postgres-db pg_restore \
  --dbname=postgres \
  --verbose \
  /backups/ultimo-backup.sql.gz
```

## Monitoramento de Segurança

### 1. Logs Centralizados

Configure o ELK Stack ou similar:

```yaml
django-app:
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
      labels: "app,env"
```

### 2. Alertas

Configure alertas para:
- Múltiplas tentativas de login falhas
- Acessos a rotas administrativas
- Queries SQL lentas
- Erros 500
- Uso de disco/memória alto

### 3. Auditoria

```python
# Django middleware para logging de ações
class AuditMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Log request
        logger.info(f"{request.method} {request.path} - {request.user}")

        response = self.get_response(request)

        # Log response
        logger.info(f"Status: {response.status_code}")

        return response
```

## Checklist de Segurança Completo

Veja [Checklist de Segurança](checklist.md) para lista verificável.

## Ferramentas Recomendadas

### Análise de Vulnerabilidades

- **Bandit**: Análise de código Python
  ```bash
  pip install bandit
  bandit -r app/
  ```

- **Safety**: Verifica dependências vulneráveis
  ```bash
  pip install safety
  safety check -r requirements.txt
  ```

- **Trivy**: Scan de containers
  ```bash
  trivy image django-app:latest
  ```

### Testes de Penetração

- **OWASP ZAP**: Scanner de vulnerabilidades web
- **Burp Suite**: Proxy para análise de tráfego
- **SQLMap**: Teste de SQL injection

### Monitoramento

- **Sentry**: Tracking de erros
- **New Relic**: APM
- **Datadog**: Monitoramento completo

## Conformidade e Regulamentações

### LGPD (Brasil)

- Criptografia de dados sensíveis
- Logs de acesso a dados pessoais
- Capacidade de deletar dados (direito ao esquecimento)
- Termo de consentimento
- Política de privacidade

### GDPR (Europa)

Similar à LGPD, com requisitos adicionais:
- Data Protection Officer (DPO)
- Privacy by Design
- Notificação de vazamentos em 72h

## Recursos Adicionais

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Django Security Guide](https://docs.djangoproject.com/en/stable/topics/security/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

## Próximos Passos

- [Checklist de Segurança](checklist.md)
- [Deploy em Produção](../deploy/production.md)
- [Troubleshooting](../deploy/troubleshooting.md)
