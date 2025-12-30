# Ambiente de Desenvolvimento

Configuração para desenvolvimento local.

## Configuração

### 1. Clonar Repositório

```bash
git clone https://github.com/seu-usuario/projeto.git
cd projeto
```

### 2. Criar .env

```bash
cp .env.example .env
```

Configurar para desenvolvimento:
```env
DEBUG=1
SECRET_KEY="dev-key-not-for-production"
ALLOWED_HOSTS="*"
POSTGRES_DB="projeto_dev"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="postgres"
```

### 3. Iniciar Containers

```bash
docker-compose up -d
```

### 4. Aplicar Migrations

```bash
docker-compose exec django-app python manage.py migrate
```

### 5. Criar Superusuário

```bash
docker-compose exec django-app python manage.py createsuperuser
```

## Desenvolvimento

### Hot Reload

Com `DEBUG=1`, o Django recarrega automaticamente ao detectar mudanças no código.

### Ver Logs

```bash
docker-compose logs -f django-app
```

### Django Shell

```bash
docker-compose exec django-app python manage.py shell
```

### Executar Testes

```bash
docker-compose exec django-app python manage.py test
```

### Instalar Nova Dependência

```bash
# Adicionar ao requirements.txt
echo "nova-lib==1.0.0" >> requirements.txt

# Rebuild
docker-compose build django-app
docker-compose up -d django-app
```

## Banco de Dados

Em desenvolvimento, usa SQLite por padrão (`DEBUG=1`).

Para testar com PostgreSQL:
```env
DEBUG=0
```

```bash
docker-compose restart django-app
```

## Próximos Passos

- [Comandos Docker](../reference/docker-commands.md)
- [FAQ](../reference/faq.md)
