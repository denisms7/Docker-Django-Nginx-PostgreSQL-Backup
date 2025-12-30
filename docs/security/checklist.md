# Checklist de Segurança

Use este checklist antes de fazer deploy em produção.

## Arquivos e Configuração

- [ ] Arquivo `.env` não está versionado no Git
- [ ] Arquivo `.env` está no `.gitignore`
- [ ] Existe um `.env.example` como template
- [ ] `SECRET_KEY` do Django foi gerada aleatoriamente
- [ ] Senha do PostgreSQL é forte (16+ caracteres)
- [ ] Credenciais padrão do Nginx foram alteradas

## Django Settings

- [ ] `DEBUG = False` em produção
- [ ] `ALLOWED_HOSTS` contém apenas domínios reais
- [ ] `CSRF_TRUSTED_ORIGINS` está configurado
- [ ] `SECURE_SSL_REDIRECT = True`
- [ ] `SECURE_HSTS_SECONDS` configurado (31536000)
- [ ] `SESSION_COOKIE_SECURE = True`
- [ ] `CSRF_COOKIE_SECURE = True`
- [ ] `X_FRAME_OPTIONS` configurado
- [ ] `SECURE_CONTENT_TYPE_NOSNIFF = True`
- [ ] `SECURE_BROWSER_XSS_FILTER = True`

## Docker

- [ ] Porta 81 do Nginx não exposta publicamente
- [ ] Containers não rodam como root
- [ ] Limites de recursos configurados
- [ ] Healthchecks implementados
- [ ] Imagens escaneadas para vulnerabilidades
- [ ] Volumes com permissões corretas

## PostgreSQL

- [ ] Não usa usuário `postgres` (criar usuário específico)
- [ ] Conexões SSL habilitadas
- [ ] Senha forte configurada
- [ ] Banco não exposto publicamente
- [ ] Logs de conexão habilitados

## Nginx

- [ ] SSL/TLS configurado (Let's Encrypt)
- [ ] Apenas TLS 1.2+ habilitado
- [ ] HSTS habilitado
- [ ] Headers de segurança configurados
- [ ] Rate limiting configurado
- [ ] Server tokens desabilitado (`server_tokens off`)

## Backup

- [ ] Backups automáticos configurados
- [ ] Política de retenção definida
- [ ] Backup offsite configurado (cloud)
- [ ] Testes de restauração realizados
- [ ] Backups criptografados

## Monitoramento

- [ ] Logs centralizados
- [ ] Alertas configurados
- [ ] Monitoramento de erro (Sentry)
- [ ] Healthcheck endpoints funcionando
- [ ] Métricas de performance coletadas

## Geral

- [ ] Documentação atualizada
- [ ] Plano de rollback definido
- [ ] Backup antes do deploy
- [ ] Teste em staging antes de produção
- [ ] Equipe treinada nos procedimentos
