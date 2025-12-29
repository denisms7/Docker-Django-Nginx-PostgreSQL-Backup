# Docker + Django + Nginx + PostgreSQL – Sistema com Backup

Modelo de sistema completo utilizando **Docker**, integrado com **Django**, **Nginx** e **PostgreSQL**, incluindo funcionalidades de **backup automatizado** e configuração pronta para desenvolvimento e produção.

## 🐳 Configuração do Docker

## 🐍 Configuração do Django

## 🗄️ Configuração do PostgreSQL

## 🌐 Configuração do Nginx

Acesse o painel do Nginx em [http://localhost:81](http://localhost:81) e faça login com o usuário e senha abaixo:

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
