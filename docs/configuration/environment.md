# Variáveis de Ambiente

Este documento detalha todas as variáveis de ambiente utilizadas no projeto.

## Arquivo .env

O arquivo `.env` na raiz do projeto contém todas as configurações sensíveis e específicas do ambiente.

!!! danger "Segurança Crítica"
    **NUNCA** commite o arquivo `.env` em repositórios públicos!

    ```bash
    # Adicione ao .gitignore
    echo ".env" >> .gitignore
    ```

## Template Completo

Crie um arquivo `.env` na raiz do projeto com o seguinte conteúdo:

```env
# ============================================
# Django Settings
# ============================================

# Chave secreta do Django - GERE UMA NOVA PARA PRODUÇÃO!
# python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
SECRET_KEY="django-insecure-CHANGE-THIS-IN-PRODUCTION"

# Debug mode: 0 = False (produção), 1 = True (desenvolvimento)
DEBUG=0

# Hosts permitidos (separados por vírgula)
# Em produção, liste apenas seus domínios reais
ALLOWED_HOSTS="localhost,127.0.0.1,seu-dominio.com,www.seu-dominio.com"

# ============================================
# PostgreSQL Configuration
# ============================================

# Nome do banco de dados
POSTGRES_DB="meu_projeto_db"

# Usuário do PostgreSQL
POSTGRES_USER="meu_usuario"

# Senha do PostgreSQL - USE UMA SENHA FORTE!
POSTGRES_PASSWORD="SenhaForteAqui123!@#"

# Host do PostgreSQL (nome do container)
POSTGRES_HOST="postgres-db"

# Porta do PostgreSQL
POSTGRES_PORT="5432"

# ============================================
# Backup Configuration
# ============================================

# Porta do healthcheck do backup
HEALTHCHECK_PORT="8069"
```

## Variáveis Django

### SECRET_KEY

**Obrigatório**: Sim
**Padrão**: Nenhum
**Exemplo**: `"django-insecure-tn1e31md6pc0c9f@yqi#h0vfyatcx##i!kuy-hab3xeu@jx03l"`

Chave criptográfica usada pelo Django para:
- Assinatura de cookies e sessões
- Tokens CSRF
- Hashing de senhas
- Geração de tokens diversos

#### Como gerar uma nova chave:

**Método 1: Python**
```python
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

**Método 2: Django Shell**
```bash
docker-compose exec django-app python manage.py shell
>>> from django.core.management.utils import get_random_secret_key
>>> print(get_random_secret_key())
```

**Método 3: Online (menos seguro)**
[Djecrety - Django Secret Key Generator](https://djecrety.ir/)

!!! warning "Importante"
    - Use chaves diferentes para cada ambiente (dev, staging, prod)
    - Nunca reutilize a chave padrão do repositório
    - Se a chave vazar, regenere imediatamente

### DEBUG

**Obrigatório**: Sim
**Padrão**: `0` (False)
**Valores**: `0` (False) ou `1` (True)

Controla o modo de debug do Django.

#### DEBUG=1 (Desenvolvimento)
```env
DEBUG=1
```

**Comportamento**:
- Erros detalhados no navegador
- Stacktrace completo
- Usa SQLite (configurado em settings.py)
- Servidor de desenvolvimento
- Arquivos estáticos servidos automaticamente

**NÃO use em produção!**

#### DEBUG=0 (Produção)
```env
DEBUG=0
```

**Comportamento**:
- Erros genéricos (sem detalhes)
- Usa PostgreSQL
- Gunicorn como servidor
- Melhor performance
- Segurança reforçada

### ALLOWED_HOSTS

**Obrigatório**: Sim (quando DEBUG=0)
**Padrão**: Lista vazia
**Formato**: String separada por vírgulas

Lista de hosts/domínios permitidos para acessar a aplicação.

```env
# Desenvolvimento local
ALLOWED_HOSTS="localhost,127.0.0.1"

# Produção
ALLOWED_HOSTS="meusite.com,www.meusite.com,api.meusite.com"

# Com IP
ALLOWED_HOSTS="meusite.com,203.0.113.45"

# Wildcard de subdomínios (cuidado!)
ALLOWED_HOSTS="meusite.com,.meusite.com"
```

!!! danger "Segurança"
    Com `DEBUG=False`, se o host não estiver na lista, Django retorna erro 400.
    Nunca use `*` (allow all) em produção!

## Variáveis PostgreSQL

### POSTGRES_DB

**Obrigatório**: Sim
**Padrão**: Nenhum
**Exemplo**: `"meu_projeto_db"`

Nome do banco de dados a ser criado/usado.

**Convenções**:
- Use snake_case: `meu_projeto_db`
- Sem espaços ou caracteres especiais
- Descritivo e único

```env
# Desenvolvimento
POSTGRES_DB="projeto_dev"

# Produção
POSTGRES_DB="projeto_prod"
```

### POSTGRES_USER

**Obrigatório**: Sim
**Padrão**: `postgres`
**Exemplo**: `"app_user"`

Usuário do PostgreSQL com permissões no banco.

!!! tip "Boa Prática"
    Não use `postgres` (superuser) em produção. Crie um usuário específico com permissões limitadas.

```env
# Evite
POSTGRES_USER="postgres"

# Melhor
POSTGRES_USER="django_app_user"
```

### POSTGRES_PASSWORD

**Obrigatório**: Sim
**Padrão**: Nenhum
**Exemplo**: `"SenhaForte123!@#"`

Senha do usuário do PostgreSQL.

#### Requisitos de Senha Forte:

- Mínimo 12 caracteres
- Letras maiúsculas e minúsculas
- Números
- Caracteres especiais
- Não use palavras do dicionário

#### Geradores de Senha:

**Método 1: OpenSSL**
```bash
openssl rand -base64 32
```

**Método 2: pwgen**
```bash
pwgen -s 32 1
```

**Método 3: Python**
```python
import secrets
import string

alphabet = string.ascii_letters + string.digits + string.punctuation
password = ''.join(secrets.choice(alphabet) for i in range(32))
print(password)
```

!!! danger "Nunca"
    - Use senhas simples como "123456"
    - Reutilize senhas
    - Commite a senha no Git
    - Compartilhe senhas via email/chat

### POSTGRES_HOST

**Obrigatório**: Sim
**Padrão**: `"postgres-db"`
**Exemplo**: `"postgres-db"`

Hostname ou IP do servidor PostgreSQL.

**Em Docker Compose**: Use o nome do serviço
```env
POSTGRES_HOST="postgres-db"
```

**PostgreSQL externo**: Use IP ou hostname
```env
POSTGRES_HOST="192.168.1.100"
# ou
POSTGRES_HOST="db.meuservidor.com"
```

### POSTGRES_PORT

**Obrigatório**: Não
**Padrão**: `"5432"`
**Exemplo**: `"5432"`

Porta do PostgreSQL.

```env
# Porta padrão
POSTGRES_PORT="5432"

# Porta customizada
POSTGRES_PORT="15432"
```

## Variáveis de Backup

### HEALTHCHECK_PORT

**Obrigatório**: Não
**Padrão**: `"8080"`
**Exemplo**: `"8069"`

Porta usada pelo serviço de backup para healthcheck HTTP.

```env
HEALTHCHECK_PORT="8069"
```

O container `postgres-backup` expõe esta porta para verificação de saúde.

## Variáveis Adicionais (Opcionais)

Você pode adicionar outras variáveis conforme necessário:

### Django Extras

```env
# Timezone
TZ="America/Sao_Paulo"

# Configuração de Email
EMAIL_HOST="smtp.gmail.com"
EMAIL_PORT="587"
EMAIL_HOST_USER="seu-email@gmail.com"
EMAIL_HOST_PASSWORD="senha-do-app"
EMAIL_USE_TLS="1"

# AWS S3 (para arquivos de mídia)
AWS_ACCESS_KEY_ID="sua-access-key"
AWS_SECRET_ACCESS_KEY="sua-secret-key"
AWS_STORAGE_BUCKET_NAME="nome-do-bucket"
AWS_S3_REGION_NAME="us-east-1"

# Redis (cache)
REDIS_URL="redis://redis:6379/0"

# Sentry (monitoramento de erros)
SENTRY_DSN="https://xxxxx@sentry.io/yyyy"
```

### Usando no Django

No `settings.py`, acesse as variáveis com `os.getenv()`:

```python
import os
from dotenv import load_dotenv

load_dotenv()

# Com valor padrão
EMAIL_HOST = os.getenv('EMAIL_HOST', 'localhost')

# Obrigatória (levanta exceção se não existir)
AWS_KEY = os.environ['AWS_ACCESS_KEY_ID']

# Conversão para int
EMAIL_PORT = int(os.getenv('EMAIL_PORT', '587'))

# Conversão para bool
EMAIL_USE_TLS = bool(int(os.getenv('EMAIL_USE_TLS', '0')))
```

## Ambientes Múltiplos

### Estrutura Recomendada

```
.env.example          # Template (commitado)
.env                  # Local (não commitar)
.env.development      # Dev (não commitar)
.env.staging          # Staging (não commitar)
.env.production       # Prod (não commitar)
```

### .env.example (Template)

```env
# Django
SECRET_KEY="CHANGE-ME"
DEBUG=0
ALLOWED_HOSTS="localhost"

# PostgreSQL
POSTGRES_DB="database_name"
POSTGRES_USER="db_user"
POSTGRES_PASSWORD="CHANGE-ME"
POSTGRES_HOST="postgres-db"
POSTGRES_PORT="5432"

# Backup
HEALTHCHECK_PORT="8069"
```

### Usando em Docker Compose

```yaml
services:
  django-app:
    env_file:
      - .env.${ENVIRONMENT:-production}
```

```bash
# Desenvolvimento
ENVIRONMENT=development docker-compose up

# Produção
ENVIRONMENT=production docker-compose up
```

## Validação e Troubleshooting

### Verificar Variáveis Carregadas

```bash
# Ver variáveis no container
docker-compose exec django-app env | grep POSTGRES

# Django shell
docker-compose exec django-app python manage.py shell
>>> import os
>>> print(os.getenv('POSTGRES_HOST'))
```

### Problemas Comuns

#### 1. Variável não encontrada

**Erro**: `KeyError: 'SECRET_KEY'`

**Solução**: Arquivo `.env` não está sendo carregado
```bash
# Verifique se o arquivo existe
ls -la .env

# Verifique se docker-compose.yml referencia o .env
grep env_file docker-compose.yml
```

#### 2. Valor incorreto

**Erro**: Senha do banco não funciona

**Solução**: Caracteres especiais podem precisar de escape
```env
# Se a senha tem caracteres especiais, use aspas
POSTGRES_PASSWORD="senha@com#especiais"
```

#### 3. DEBUG não muda

**Erro**: Django continua em modo debug

**Solução**: Conversão incorreta da string
```python
# Errado
DEBUG = os.getenv('DEBUG', False)  # String "0" é truthy!

# Correto
DEBUG = bool(int(os.getenv('DEBUG', 0)))
```

## Segurança - Checklist

- [ ] `.env` está no `.gitignore`
- [ ] `SECRET_KEY` foi gerada aleatoriamente
- [ ] `POSTGRES_PASSWORD` é forte (12+ caracteres)
- [ ] `DEBUG=0` em produção
- [ ] `ALLOWED_HOSTS` lista apenas domínios reais
- [ ] Variáveis sensíveis não estão em logs
- [ ] Backup do `.env` está em local seguro
- [ ] Cada ambiente tem seu próprio `.env`
- [ ] Senhas são rotacionadas periodicamente

## Ferramentas Úteis

### python-dotenv

Já instalado no projeto:
```python
from dotenv import load_dotenv
load_dotenv()
```

### django-environ

Alternativa mais robusta:
```bash
pip install django-environ
```

```python
import environ

env = environ.Env(
    DEBUG=(bool, False)
)

environ.Env.read_env()

SECRET_KEY = env('SECRET_KEY')
DEBUG = env('DEBUG')
```

### Vault (Produção)

Para gerenciamento avançado de segredos:
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager

## Próximos Passos

- [Configuração do Docker Compose](docker-compose.md)
- [Configuração do Dockerfile](dockerfile.md)
- [Deploy em Produção](../deploy/production.md)
