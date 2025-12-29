# Docker + Django + Nginx + PostgreSQL – Sistema com Backup

Modelo de sistema completo utilizando **Docker**, integrado com **Django**, **Nginx** e **PostgreSQL**, incluindo funcionalidades de **backup automatizado** e configuração pronta para desenvolvimento e produção.

## 🐳 Configuração do Docker
Você pode alterar os nomes dos containers e volumes diretamente no arquivo `docker-compose.yml` conforme suas necessidades.
Para criar os containers, utilize o comando:

```
docker-compose build --no-cache
```
- docker-compose build: cria as imagens dos containers definidas no docker-compose.yml.
- no-cache: força o Docker a ignorar o cache e reconstruir a imagem do zero, útil se você fez alterações em arquivos ou dependências e quer garantir que elas sejam aplicadas.

Para executar os containers, utilize:
```
docker-compose up
```

- docker-compose up: inicia todos os containers definidos no docker-compose.yml.
- Se as imagens ainda não existirem, o Docker vai tentar construí-las automaticamente antes de iniciar os containers.

---

## 🐍 Configuração do Django
- Crie seu projeto Django normalmente.  
- Utilize a **app** existente como core ou crie um novo app chamado **app** para servir como núcleo do sistema.
- Com `DEBUG=False` o Django roda com o Gunicorn que esta configurado no arquivo `gunicorn_config.py` e se conecta no Nginx posteriormente.

---

## 🗄️ Configuração do PostgreSQL
- Altere os nomes das variáveis de ambiente no arquivo **.env** conforme sua configuração.  
- O `settings.py` está configurado para usar **SQLite** quando `DEBUG=True` e **PostgreSQL** quando `DEBUG=False`, extraindo os dados do arquivo **.env**:

```python
if DEBUG:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'HOST': os.getenv('POSTGRES_HOST', 'postgres-db'),
            'PORT': os.getenv('POSTGRES_PORT', '5432'),
            'NAME': os.getenv('POSTGRES_DB', 'postgres'),
            'USER': os.getenv('POSTGRES_USER', 'postgres'),
            'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'postgres'),
        }
    }
```

> ⚠️ **Segurança:**  
> Adicione o arquivo **.env** ao **.gitignore** do seu projeto real para **não expor variáveis sensíveis de produção** no GitHub.

---

## 🌐 Configuração do Nginx

Acesse o painel do Nginx em [http://localhost:81](http://localhost:81) e faça login com o usuário e senha abaixo (usuário e senha padrão):

Usuário:
```
admin@example.com
```
Senha:
```
changeme
```

No painel do sistema, siga os passos:

1. Vá até **Hosts > Proxy Hosts**.  
2. Clique em **Add Proxy Host**.  
3. Em **Domain Names**, insira seu **DNS ou IP**.  
4. Em **Forward Hostname/IP**, coloque o **nome do container Docker** onde o Django está rodando.  
5. Em **Forward Port**, informe a **porta do Django** (exemplo: `8000`).  

### 🔧 Configuração Avançada

Expanda a seção **Advanced** e adicione o seguinte código para configurar os diretórios de arquivos estáticos e de mídia:

```
location /static/ {
    alias /var/www/staticfiles/;
    access_log off;
    expires 1y;
    add_header Cache-Control "public";
}

location /media/ {
    alias /var/www/media/;
    access_log off;
    expires 30d;
    add_header Cache-Control "public";
}
```

Isso garante que os arquivos estáticos (/static/) e de mídia (/media/) sejam servidos corretamente pelo Nginx, com cache otimizado.

---

## 💾 Backup do PostgreSQL
O backup do banco de dados é realizado diariamente às 03:00 (horário de Brasília), utilizando agendamento via cron dentro do container Docker.

```
SCHEDULE: "0 3 * * *"   # todos os dias às 03:00
BACKUP_KEEP_DAYS: 7
BACKUP_KEEP_WEEKS: 4
BACKUP_KEEP_MONTHS: 4
```

### 🗂️ Política de Retenção
- Diário: mantém os backups dos últimos 7 dias.
- Semanal: mantém 1 backup por semana das últimas 4 semanas.
- Mensal: mantém 1 backup por mês dos últimos 4 meses.

Link da imagem de backup do PostgresSQL:
[https://hub.docker.com/r/prodrigestivill/postgres-backup-local](postgres-backup-local)
