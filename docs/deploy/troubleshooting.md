# Troubleshooting

Soluções para problemas comuns.

## Container não inicia

### Sintomas
Container aparece como "Exited" ou "Restarting"

### Diagnóstico
```bash
docker-compose logs container-name
docker-compose ps
```

### Soluções
1. Verificar logs para erro específico
2. Verificar se portas estão disponíveis
3. Verificar se volumes têm permissões corretas
4. Tentar iniciar manualmente: `docker-compose run --rm container-name bash`

## Erro 502 Bad Gateway

### Sintomas
Nginx retorna erro 502

### Causas Comuns
- Django não está rodando
- Configuração incorreta no Nginx

### Soluções
```bash
# Verificar se Django está rodando
docker-compose ps django-app

# Testar conexão
docker-compose exec nginx-proxy curl http://django-app:8000

# Reiniciar Django
docker-compose restart django-app
```

## Banco de dados não conecta

### Sintomas
Django mostra erro de conexão ao banco

### Soluções
```bash
# Verificar se PostgreSQL está saudável
docker-compose ps postgres-db

# Verificar variáveis de ambiente
docker-compose exec django-app env | grep POSTGRES

# Testar conexão manualmente
docker-compose exec django-app python manage.py dbshell
```

## Arquivos estáticos não carregam

### Sintomas
CSS e JS não aparecem no site

### Soluções
```bash
# Coletar arquivos estáticos
docker-compose exec django-app python manage.py collectstatic --noinput

# Verificar volume do Nginx
docker-compose exec nginx-proxy ls -la /var/www/staticfiles/

# Verificar configuração no Nginx
# Deve ter location /static/ configurado
```

## Porta já em uso

### Sintomas
Erro: "port is already allocated"

### Soluções
```bash
# Linux/Mac - Ver o que usa a porta
sudo lsof -i :80

# Windows
netstat -ano | findstr :80

# Alterar porta no docker-compose.yml
ports:
  - '8080:80'
```

## Sem espaço em disco

### Sintomas
Erro: "no space left on device"

### Soluções
```bash
# Ver uso de espaço
docker system df

# Limpar imagens não usadas
docker image prune -a

# Limpar containers parados
docker container prune

# Limpar volumes não usados (CUIDADO!)
docker volume prune

# Limpeza completa
docker system prune -a
```

## Permissões negadas (Linux)

### Sintomas
Erro: "permission denied"

### Soluções
```bash
# Ajustar propriedade
sudo chown -R $USER:$USER .

# Ajustar permissões
chmod -R 755 .
```

## Migrations não aplicam

### Sintomas
Tabelas não existem no banco

### Soluções
```bash
# Ver status das migrations
docker-compose exec django-app python manage.py showmigrations

# Aplicar migrations
docker-compose exec django-app python manage.py migrate

# Se necessário, forçar
docker-compose exec django-app python manage.py migrate --run-syncdb
```

## Backup não executa

### Sintomas
Backups não aparecem no volume

### Soluções
```bash
# Ver logs do backup
docker-compose logs postgres-backup

# Verificar agendamento
docker-compose exec postgres-backup env | grep SCHEDULE

# Executar manualmente
docker-compose exec postgres-db pg_dump -U postgres db-modelo > teste-backup.sql
```

## Performance ruim

### Sintomas
Aplicação lenta

### Diagnóstico
```bash
# Ver uso de recursos
docker stats

# Ver queries lentas (se configurado)
docker-compose exec postgres-db cat /var/log/postgresql/postgresql.log
```

### Soluções
1. Aumentar workers do Gunicorn
2. Adicionar índices no banco de dados
3. Implementar cache (Redis)
4. Otimizar queries N+1
5. Adicionar mais recursos aos containers

## SSL não funciona

### Sintomas
Let's Encrypt falha ao gerar certificado

### Soluções
1. Verificar se portas 80 e 443 estão abertas
2. Verificar se domínio aponta para o servidor
3. Verificar logs do Nginx
4. Tentar gerar manualmente no painel

## Container reinicia constantemente

### Sintomas
Container fica em loop de restart

### Diagnóstico
```bash
docker-compose logs --tail=100 container-name
```

### Soluções
1. Verificar healthcheck
2. Verificar se comando inicial falha
3. Ver dependências (`depends_on`)
4. Remover `restart: always` temporariamente para debug

## Mais Ajuda

Se o problema persistir:

1. Verifique o [FAQ](../reference/faq.md)
2. Busque nos logs: `docker-compose logs -f`
3. Abra uma issue no GitHub
4. Consulte a documentação oficial das ferramentas
