# Docker + Django + Nginx + PostgreSQL - Documentação Completa

Bem-vindo à documentação completa do projeto de infraestrutura Docker para aplicações Django com Nginx e PostgreSQL, incluindo sistema automatizado de backup.

## O que é este projeto?

Este é um template completo e pronto para produção que integra:

- **Django 6.0** - Framework web Python
- **Gunicorn** - Servidor WSGI para aplicações Python
- **Nginx Proxy Manager** - Proxy reverso com interface gráfica
- **PostgreSQL 17.5** - Banco de dados relacional
- **Sistema de Backup Automatizado** - Para banco de dados e arquivos de mídia

## Características Principais

### Containerização Completa
Todos os serviços são executados em containers Docker isolados, facilitando o desenvolvimento, teste e deploy.

### Ambiente Dual
- **Desenvolvimento**: SQLite + Django Dev Server
- **Produção**: PostgreSQL + Gunicorn + Nginx

### Backup Automatizado
- Backup diário do PostgreSQL com rotação inteligente
- Sincronização automática de arquivos de mídia
- Retenção configurável (7 dias, 4 semanas, 4 meses)

### Proxy Reverso Gerenciado
Interface web para configuração do Nginx, incluindo:
- Gerenciamento de hosts
- Certificados SSL/TLS automáticos (Let's Encrypt)
- Logs em tempo real

### Healthchecks
Todos os serviços possuem verificações de saúde configuradas para garantir disponibilidade.

## Estrutura do Projeto

```
Docker-Django-Nginx-PostgreSQL-Backup/
├── app/                    # Aplicação Django
│   ├── settings.py         # Configurações do Django
│   ├── urls.py             # Rotas
│   └── wsgi.py             # WSGI application
├── data/                   # Dados persistentes do Nginx
│   ├── nginx/              # Configurações do Nginx
│   └── logs/               # Logs
├── media/                  # Arquivos de mídia (uploads)
├── staticfiles/            # Arquivos estáticos coletados
├── letsencrypt/            # Certificados SSL
├── docker-compose.yml      # Orquestração dos containers
├── Dockerfile              # Imagem do Django
├── requirements.txt        # Dependências Python
├── gunicorn_config.py      # Configuração do Gunicorn
├── .env                    # Variáveis de ambiente (não commitar!)
└── docs/                   # Esta documentação
```

## Início Rápido

### Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git

### Instalação Básica

```bash
# Clone o repositório
git clone https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup.git
cd Docker-Django-Nginx-PostgreSQL-Backup

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações

# Construa e inicie os containers
docker-compose build --no-cache
docker-compose up -d

# Verifique o status
docker-compose ps
```

### Acesso aos Serviços

- **Aplicação Django**: `http://localhost` (via Nginx Proxy)
- **Painel Nginx**: `http://localhost:81`
  - Usuário: `admin@example.com`
  - Senha: `changeme`
- **PostgreSQL**: `localhost:5432` (apenas interno ao Docker)

## Próximos Passos

1. [Guia de Início Rápido](quickstart.md) - Configure o ambiente em minutos
2. [Arquitetura](architecture/overview.md) - Entenda como tudo funciona
3. [Configuração](configuration/environment.md) - Personalize o projeto
4. [Deploy em Produção](deploy/production.md) - Prepare para o ambiente de produção

## Problemas Conhecidos e Soluções

### Volume de Mídia Duplicado
**Problema**: O `docker-compose.yml` declara dois volumes para `/app/media`, causando conflito.

**Solução**: Remover o volume nomeado `media:` e usar apenas o bind mount `./media:/app/media`.

### Healthcheck do Django
**Problema**: O healthcheck está configurado para `/health/` mas a rota não existe.

**Solução**: Implementar uma view de healthcheck ou mudar para uma rota existente como `/admin/`.

### Arquivo .env no Repositório
**Problema**: Credenciais sensíveis estão versionadas.

**Solução**:
1. Remover o `.env` do repositório
2. Criar um `.env.example` como template
3. Adicionar `.env` ao `.gitignore`

## Suporte e Contribuições

- **Issues**: [GitHub Issues](https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup/issues)
- **Discussões**: [GitHub Discussions](https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup/discussions)
- **Email**: Confira o repositório para contato

## Licença

Este projeto está sob a licença especificada no arquivo [LICENSE](../LICENSE).

---

**Desenvolvido por**: [Denis MS](https://github.com/denisms7)
**Última atualização**: 2025-12-30
