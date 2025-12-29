# Docker + Django + Nginx + PostgreSQL – Sistema com Backup

Modelo de sistema completo utilizando Docker, integrado com Django, Nginx e PostgreSQL, incluindo funcionalidades de backup automatizado e configuração pronta para desenvolvimento e produção.

### Configuração do Docker

### Configuração do Django

### Configuração do PostgreSQL

### Configuração do Nginx

Acesse o painel do Nginx em http://localhost:81 e faça login com o usuário e senha abaixo:

Usuário: admin@example.com
Senha: changeme

No painel do sistema, vá até Hosts > Proxy Hosts.

Clique em Add Proxy Host.

Em Domain Names, insira seu DNS ou IP.

Em Forward Hostname/IP, coloque o nome do container Docker onde o Django está rodando.

Em Forward Port, informe a porta que o Django está utilizando (no exemplo, 8000).

Expanda a seção Advanced e adicione o seguinte código para configurar os diretórios de arquivos estáticos e mídia:
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