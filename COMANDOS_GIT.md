# 🔐 Comandos Git - Remover .env do Repositório

## ⚠️ IMPORTANTE

O arquivo `.env` ainda está no histórico do Git, mesmo após adicionar ao `.gitignore`. É necessário removê-lo do controle de versão.

---

## 📋 Comandos Para Executar

### Opção 1: Remoção Simples (Recomendado)

Execute estes comandos na ordem:

```bash
# 1. Verificar status atual
git status

# 2. Adicionar .env ao .gitignore (já foi feito)
# Verificar se está no .gitignore:
cat .gitignore | grep "^\.env$"

# 3. Remover .env do índice do Git (não apaga o arquivo local)
git rm --cached .env

# 4. Adicionar novos arquivos criados
git add .gitignore .env.example

# 5. Adicionar correções nos outros arquivos
git add requirements.txt
git add docker-compose.yml
git add app/settings.py
git add app/urls.py

# 6. Criar commit
git commit -m "Correções de segurança e configuração

- Remove .env do controle de versão (segurança crítica)
- Adiciona .env.example como template seguro
- Corrige requirements.txt (encoding)
- Protege porta 81 do Nginx (apenas localhost)
- Remove volume duplicado de mídia
- Remove loop de debug do settings.py
- Implementa endpoint de healthcheck (/health/)

IMPORTANTE: As credenciais no .env foram renovadas:
- Nova SECRET_KEY gerada
- Nova senha forte do PostgreSQL
- Consulte CORRECOES_APLICADAS.md para detalhes"

# 7. Push para o repositório remoto
git push origin main
```

### Opção 2: Remover do Histórico Completo (Avançado)

⚠️ **Use apenas se necessário!** Isso reescreve o histórico do Git.

```bash
# Instalar git-filter-repo (se não tiver)
# Windows:
pip install git-filter-repo

# Linux/Mac:
brew install git-filter-repo
# ou
pip install git-filter-repo

# Backup do repositório
cd ..
cp -r Docker-Django-Nginx-PostgreSQL-Backup Docker-Django-Nginx-PostgreSQL-Backup-BACKUP
cd Docker-Django-Nginx-PostgreSQL-Backup

# Remover .env de TODO o histórico
git filter-repo --invert-paths --path .env

# Push forçado (CUIDADO!)
git push origin --force --all
```

---

## 📝 Comandos Adicionais

### Adicionar Documentação ao Git

```bash
# Adicionar documentação MkDocs
git add mkdocs.yml
git add docs/

# Adicionar arquivos de análise
git add ANALISE_E_DOCUMENTACAO.md
git add LEIA-ME-PRIMEIRO.md
git add CORRECOES_APLICADAS.md
git add COMANDOS_GIT.md

# Commit
git commit -m "Adiciona documentação completa em MkDocs

- Configuração MkDocs com tema Material
- 13+ páginas de documentação técnica
- Guias de início rápido, segurança, backup e deploy
- Análise completa do projeto
- FAQ e troubleshooting
- Referência de comandos Docker"

# Push
git push origin main
```

### Verificar Se .env Foi Removido

```bash
# Verificar se .env está no índice
git ls-files | grep "^\.env$"
# Se retornar vazio, foi removido com sucesso!

# Verificar histórico recente
git log --oneline -5

# Ver o que está sendo rastreado
git ls-files
```

### Criar Branch para Testes (Opcional)

```bash
# Criar branch de desenvolvimento
git checkout -b desenvolvimento

# Fazer alterações
# ...

# Commit
git commit -m "Testes no ambiente de desenvolvimento"

# Push
git push origin desenvolvimento

# Voltar para main
git checkout main

# Merge quando estiver pronto
git merge desenvolvimento
```

---

## 🚨 Troubleshooting Git

### Problema: "git rm --cached .env" não funciona

**Erro:**
```
fatal: pathspec '.env' did not match any files
```

**Solução:**
O arquivo já foi removido ou nunca foi commitado. Continue com os próximos passos.

### Problema: Conflito ao fazer push

**Erro:**
```
! [rejected] main -> main (fetch first)
```

**Solução:**
```bash
# Atualizar repositório local
git pull origin main

# Resolver conflitos se houver
# Editar arquivos conflitantes

# Adicionar arquivos resolvidos
git add .

# Commit
git commit -m "Resolve conflitos"

# Push novamente
git push origin main
```

### Problema: .env ainda aparece no histórico

**Verificar:**
```bash
# Buscar .env em commits antigos
git log --all --full-history -- .env
```

**Solução:**
Use a Opção 2 (git-filter-repo) para remover do histórico completo.

---

## 📊 Status Atual do Git

```bash
# Ver status completo
git status

# Ver diferenças
git diff

# Ver arquivos rastreados
git ls-files

# Ver último commit
git log -1

# Ver branches
git branch -a
```

---

## ✅ Checklist Git

Antes de fazer push:

- [ ] `.env` está no `.gitignore`
- [ ] `.env` foi removido do índice (`git rm --cached .env`)
- [ ] `.env.example` foi criado e adicionado
- [ ] Todas as correções foram adicionadas (`git add`)
- [ ] Commit criado com mensagem descritiva
- [ ] Testado localmente (`docker-compose up -d`)
- [ ] Verificado que tudo funciona
- [ ] Push para o repositório remoto

---

## 🎯 Resumo - Sequência Completa

```bash
# 1. Remover .env do Git
git rm --cached .env

# 2. Adicionar arquivos corrigidos
git add .gitignore .env.example requirements.txt docker-compose.yml app/

# 3. Adicionar documentação
git add mkdocs.yml docs/ *.md

# 4. Commit tudo
git commit -m "Correções de segurança, configuração e documentação completa"

# 5. Push
git push origin main

# 6. Verificar
git ls-files | grep "\.env$"  # Deve retornar vazio
```

---

## 📚 Recursos

- [Git Documentation](https://git-scm.com/doc)
- [git-filter-repo](https://github.com/newren/git-filter-repo)
- [Removing Sensitive Data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

---

**Criado em**: 2025-12-30
**Objetivo**: Remover credenciais sensíveis do controle de versão
