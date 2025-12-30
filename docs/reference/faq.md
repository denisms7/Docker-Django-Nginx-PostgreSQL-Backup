# Perguntas Frequentes (FAQ)

## Geral

### Por que usar Docker?

Docker garante que a aplicação rode da mesma forma em qualquer ambiente (desenvolvimento, staging, produção), eliminando o problema "funciona na minha máquina".

### Posso usar em produção?

Sim, mas implemente as melhorias de segurança descritas em [Boas Práticas](../security/best-practices.md).

### Qual o consumo de recursos?

Mínimo recomendado:
- 2GB RAM
- 2 CPU cores
- 10GB espaço em disco

## Docker

### Como ver os logs de um container?

```bash
docker-compose logs -f nome-do-container
```

### Container não inicia, o que fazer?

```bash
# Ver erro
docker-compose logs nome-do-container

# Tentar iniciar manualmente
docker-compose run --rm nome-do-container bash
```

### Como atualizar a versão de um serviço?

```bash
# Editar docker-compose.yml
# Mudar image: postgres:17.5 para postgres:17.6

# Recriar container
docker-compose up -d --no-deps --force-recreate postgres-db
```

### Volumes persistem após docker-compose down?

Sim, `docker-compose down` não remove volumes por padrão.

Para remover:
```bash
docker-compose down -v
```

## Django

### Como executar comandos do Django?

```bash
docker-compose exec django-app python manage.py comando
```

### Como acessar o shell do Django?

```bash
docker-compose exec django-app python manage.py shell
```

### Erro "no such table" ao acessar a aplicação?

Execute as migrations:
```bash
docker-compose exec django-app python manage.py migrate
```

### Como criar um superusuário?

```bash
docker-compose exec django-app python manage.py createsuperuser
```

### Arquivos estáticos não carregam?

```bash
# Coletar arquivos estáticos
docker-compose exec django-app python manage.py collectstatic --noinput

# Verificar configuração do Nginx
# Deve ter location /static/ configurado
```

### Como alterar entre SQLite e PostgreSQL?

Mude `DEBUG` no `.env`:
- `DEBUG=1` → SQLite (desenvolvimento)
- `DEBUG=0` → PostgreSQL (produção)

## PostgreSQL

### Como acessar o banco de dados?

```bash
docker-compose exec postgres-db psql -U postgres -d db-modelo
```

### Como fazer backup manual?

```bash
docker-compose exec postgres-db pg_dump -U postgres db-modelo > backup.sql
```

### Como restaurar backup?

```bash
docker-compose exec -T postgres-db psql -U postgres -d db-modelo < backup.sql
```

### Esqueci a senha do banco?

Altere no `.env` e recrie o container:
```bash
# Editar .env com nova senha
docker-compose up -d --force-recreate postgres-db
```

### Como ver o tamanho do banco?

```bash
docker-compose exec postgres-db psql -U postgres -c "
SELECT pg_size_pretty(pg_database_size('db-modelo'));
"
```

## Nginx

### Como acessar o painel do Nginx?

Acesse `http://localhost:81`

Credenciais padrão:
- Email: `admin@example.com`
- Senha: `changeme`

**ALTERE IMEDIATAMENTE!**

### Como configurar SSL/TLS?

No painel Nginx:
1. Vá em **SSL Certificates**
2. Clique em **Add SSL Certificate**
3. Escolha **Let's Encrypt**
4. Preencha seu domínio
5. Clique em **Save**

### Erro 502 Bad Gateway?

O Nginx não consegue acessar o Django.

Verificar:
```bash
# Django está rodando?
docker-compose ps django-app

# Testar conexão
docker-compose exec nginx-proxy curl http://django-app:8000
```

### Como ver os logs do Nginx?

```bash
docker-compose logs -f nginx-proxy

# Ou diretamente
docker-compose exec nginx-proxy cat /data/logs/proxy-host-1_access.log
```

## Backup

### Quando os backups são executados?

Diariamente às 3h (horário de Brasília).

### Como executar backup manualmente?

```bash
# Banco de dados
docker-compose exec postgres-db pg_dump -U postgres db-modelo > backup-manual.sql

# Mídia
docker-compose exec midia-backup rsync -av /data/source/ /data/backup/midia/
```

### Onde ficam os backups?

No volume Docker `backup`.

Para acessar:
```bash
docker-compose exec postgres-backup ls -lah /backups/
```

### Como restaurar um backup?

Veja [Restauração de Backup](../backup/restore.md).

### Backups ocupam muito espaço?

Verifique:
```bash
docker system df -v | grep backup
```

Ajuste a retenção no `.env` se necessário.

## Erros Comuns

### "port is already allocated"

Porta já está em uso.

Soluções:
1. Parar serviço que usa a porta
2. Alterar porta no `docker-compose.yml`:
   ```yaml
   ports:
     - '8080:80'  # Usa 8080 ao invés de 80
   ```

### "no space left on device"

Disco cheio.

Limpar:
```bash
docker system prune -a
docker volume prune
```

### "permission denied"

Problema de permissões (Linux).

Solução:
```bash
sudo chown -R $USER:$USER .
```

### "network not found"

Recriar rede:
```bash
docker-compose down
docker network prune
docker-compose up -d
```

### "image not found"

Build da imagem:
```bash
docker-compose build --no-cache
```

## Performance

### Aplicação está lenta?

1. Ver recursos:
```bash
docker stats
```

2. Ajustar workers do Gunicorn em `gunicorn_config.py`:
```python
workers = 8  # Aumentar
```

3. Adicionar mais recursos no `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 4G
```

### Como escalar horizontalmente?

```yaml
django-app:
  deploy:
    replicas: 3
```

Nginx fará load balancing automaticamente.

## Desenvolvimento

### Hot reload não funciona?

Verifique se o volume está mapeado:
```yaml
volumes:
  - ./:/app  # Código fonte
```

No Windows, pode ser necessário configurar polling.

### Como debugar a aplicação?

```bash
# Adicionar breakpoint no código
import pdb; pdb.set_trace()

# Ver logs
docker-compose logs -f django-app
```

### Como instalar uma nova dependência?

```bash
# Adicionar ao requirements.txt
echo "nova-lib==1.0.0" >> requirements.txt

# Rebuild
docker-compose build --no-cache django-app
docker-compose up -d --force-recreate django-app
```

## Produção

### Como fazer deploy?

Veja [Deploy em Produção](../deploy/production.md).

### Como monitorar a aplicação?

Use ferramentas como:
- Sentry (erros)
- Prometheus + Grafana (métricas)
- ELK Stack (logs)

### Como fazer backup antes de atualizar?

```bash
# Backup completo
docker-compose exec postgres-db pg_dump -U postgres db-modelo > pre-update-backup.sql

# Backup do volume
docker run --rm -v backup:/source -v $(pwd):/dest alpine tar czf /dest/backup-pre-update.tar.gz -C /source .
```

### Como reverter uma atualização?

```bash
# Restaurar código
git checkout versao-anterior

# Rebuild
docker-compose build --no-cache
docker-compose up -d

# Restaurar banco se necessário
docker-compose exec -T postgres-db psql -U postgres -d db-modelo < pre-update-backup.sql
```

## Segurança

### Arquivo .env deve ser commitado?

**NÃO!** Nunca commite o `.env`.

Use `.env.example` como template.

### Como gerar SECRET_KEY segura?

```python
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Como proteger a porta 81 do Nginx?

```yaml
ports:
  - '127.0.0.1:81:81'  # Apenas localhost
```

### Como habilitar HTTPS?

Use Let's Encrypt via painel do Nginx (porta 81).

## Ajuda Adicional

### Onde reportar bugs?

GitHub Issues: [Link do repositório]

### Como contribuir?

1. Fork o repositório
2. Crie uma branch
3. Faça suas alterações
4. Envie um Pull Request

### Documentação não respondeu minha dúvida?

Abra uma issue no GitHub com:
- Descrição do problema
- Logs relevantes
- Passos para reproduzir
- Ambiente (OS, versão do Docker)
