# Recursos Adicionais

Links úteis, ferramentas e referências.

## Documentação Oficial

### Docker
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Hub](https://hub.docker.com/)

### Django
- [Django Documentation](https://docs.djangoproject.com/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
- [Django Security](https://docs.djangoproject.com/en/stable/topics/security/)

### Gunicorn
- [Gunicorn Documentation](https://docs.gunicorn.org/)
- [Gunicorn Settings](https://docs.gunicorn.org/en/stable/settings.html)

### PostgreSQL
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Backup Guide](https://www.postgresql.org/docs/current/backup.html)

### Nginx
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)

## Imagens Docker Utilizadas

### Nginx Proxy Manager
- **Docker Hub**: [jc21/nginx-proxy-manager](https://hub.docker.com/r/jc21/nginx-proxy-manager)
- **GitHub**: [NginxProxyManager/nginx-proxy-manager](https://github.com/NginxProxyManager/nginx-proxy-manager)

### PostgreSQL Backup
- **Docker Hub**: [prodrigestivill/postgres-backup-local](https://hub.docker.com/r/prodrigestivill/postgres-backup-local)
- **GitHub**: [prodrigestivill/docker-postgres-backup-local](https://github.com/prodrigestivill/docker-postgres-backup-local)

### Rsync Cron
- **Docker Hub**: [fdrake/rsync-cron](https://hub.docker.com/r/fdrake/rsync-cron)

### PostgreSQL
- **Docker Hub**: [postgres](https://hub.docker.com/_/postgres)
- **Official Image**: PostgreSQL 17.5

### Python
- **Docker Hub**: [python](https://hub.docker.com/_/python)
- **Base Image**: python:3.13.6-slim-bullseye

## Ferramentas de Desenvolvimento

### Editores e IDEs
- [Visual Studio Code](https://code.visualstudio.com/)
  - Extensões: Docker, Python, Django
- [PyCharm](https://www.jetbrains.com/pycharm/)
- [Sublime Text](https://www.sublimetext.com/)

### Cliente PostgreSQL
- [pgAdmin](https://www.pgadmin.org/)
- [DBeaver](https://dbeaver.io/)
- [DataGrip](https://www.jetbrains.com/datagrip/)

### Cliente Docker
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Portainer](https://www.portainer.io/)
- [Lazydocker](https://github.com/jesseduffield/lazydocker)

### Monitoramento
- [Sentry](https://sentry.io/) - Error tracking
- [Prometheus](https://prometheus.io/) - Métricas
- [Grafana](https://grafana.com/) - Visualização
- [Datadog](https://www.datadoghq.com/) - APM completo

## Segurança

### Análise de Vulnerabilidades
- [Trivy](https://github.com/aquasecurity/trivy) - Container scanner
- [Bandit](https://github.com/PyCQA/bandit) - Python security linter
- [Safety](https://github.com/pyupio/safety) - Python dependency checker

### Testes de Penetração
- [OWASP ZAP](https://www.zaproxy.org/)
- [Burp Suite](https://portswigger.net/burp)
- [SQLMap](https://sqlmap.org/)

### Referências
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Django Security Guide](https://docs.djangoproject.com/en/stable/topics/security/)

## Gerenciamento de Senhas
- [1Password](https://1password.com/)
- [Bitwarden](https://bitwarden.com/)
- [KeePassXC](https://keepassxc.org/)

## Cloud Storage para Backup
- [AWS S3](https://aws.amazon.com/s3/)
- [Google Cloud Storage](https://cloud.google.com/storage)
- [Azure Blob Storage](https://azure.microsoft.com/services/storage/blobs/)
- [Backblaze B2](https://www.backblaze.com/b2/cloud-storage.html)
- [Wasabi](https://wasabi.com/)

## Continuous Integration/Deployment
- [GitHub Actions](https://github.com/features/actions)
- [GitLab CI](https://docs.gitlab.com/ee/ci/)
- [Jenkins](https://www.jenkins.io/)
- [CircleCI](https://circleci.com/)

## MkDocs e Documentação

### MkDocs
- [MkDocs](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)

### Instalação
```bash
pip install mkdocs mkdocs-material
```

### Comandos
```bash
# Servir localmente
mkdocs serve

# Build
mkdocs build

# Deploy para GitHub Pages
mkdocs gh-deploy
```

## Cursos e Tutoriais

### Docker
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Docker Mastery - Udemy](https://www.udemy.com/course/docker-mastery/)
- [Play with Docker](https://labs.play-with-docker.com/)

### Django
- [Django Girls Tutorial](https://tutorial.djangogirls.org/)
- [Django for Beginners](https://djangoforbeginners.com/)
- [Two Scoops of Django](https://www.feldroy.com/books/two-scoops-of-django-3-x)

### DevOps
- [DevOps Roadmap](https://roadmap.sh/devops)
- [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/)

## Comunidades

### Fóruns e Discussões
- [Stack Overflow](https://stackoverflow.com/)
- [Django Forum](https://forum.djangoproject.com/)
- [Docker Community](https://www.docker.com/community/)
- [Reddit r/django](https://www.reddit.com/r/django/)
- [Reddit r/docker](https://www.reddit.com/r/docker/)

### Chat
- [Django Discord](https://discord.gg/django)
- [Docker Community Slack](https://www.docker.com/docker-community)

## Blogs e Newsletters

### Blogs
- [Django News](https://django-news.com/)
- [Docker Blog](https://www.docker.com/blog/)
- [Real Python](https://realpython.com/)
- [Full Stack Python](https://www.fullstackpython.com/)

### Newsletters
- [Django Newsletter](https://django-news.com/newsletter/)
- [Python Weekly](https://www.pythonweekly.com/)
- [DevOps Weekly](https://www.devopsweekly.com/)

## Podcasts

- [Django Chat](https://djangochat.com/)
- [Talk Python To Me](https://talkpython.fm/)
- [Python Bytes](https://pythonbytes.fm/)
- [The Changelog](https://changelog.com/podcast)

## Vídeos e Canais

### YouTube
- [Corey Schafer](https://www.youtube.com/user/schafer5) - Python/Django
- [TechWorld with Nana](https://www.youtube.com/c/TechWorldwithNana) - Docker/DevOps
- [NetworkChuck](https://www.youtube.com/c/NetworkChuck) - Docker
- [Django Con](https://www.youtube.com/c/DjangoCon) - Conferências Django

## Livros Recomendados

### Django
- Two Scoops of Django
- Django for Professionals
- Django for APIs

### Docker
- Docker Deep Dive (Nigel Poulton)
- Docker in Action
- Using Docker (O'Reilly)

### DevOps
- The Phoenix Project
- The DevOps Handbook
- Site Reliability Engineering (Google)

## Ferramentas CLI Úteis

### Docker Tools
```bash
# Lazydocker - Terminal UI
brew install lazydocker

# Dive - Analisa layers de imagem
brew install dive

# ctop - Top para containers
brew install ctop
```

### Python Tools
```bash
# Black - Code formatter
pip install black

# Flake8 - Linter
pip install flake8

# pylint - Análise de código
pip install pylint

# mypy - Type checker
pip install mypy
```

### Database Tools
```bash
# pgcli - PostgreSQL CLI melhorado
pip install pgcli

# mycli - MySQL CLI
pip install mycli
```

## Templates e Boilerplates

- [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django)
- [django-docker-bootstrap](https://github.com/django-docker/django-docker-bootstrap)
- [awesome-django](https://github.com/wsvincent/awesome-django)

## Este Projeto

### Repositório
- **GitHub**: [denisms7/Docker-Django-Nginx-PostgreSQL-Backup](https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup)

### Autor
- **Denis MS**
- [GitHub](https://github.com/denisms7)

### Licença
Veja o arquivo [LICENSE](../../LICENSE) para detalhes.

## Contribuindo

Contribuições são bem-vindas! Veja como:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

## Suporte

- **Issues**: [GitHub Issues](https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/denisms7/Docker-Django-Nginx-PostgreSQL-Backup/discussions)

---

**Última atualização**: 2025-12-30
