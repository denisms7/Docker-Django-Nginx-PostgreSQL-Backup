# Documentação do Projeto

Esta documentação foi criada usando [MkDocs](https://www.mkdocs.org/) com o tema [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

## Como Visualizar

### Instalação

```bash
pip install mkdocs mkdocs-material
```

### Servir Localmente

```bash
# Na raiz do projeto
mkdocs serve
```

Acesse: `http://localhost:8000`

### Build

```bash
mkdocs build
```

Os arquivos HTML serão gerados na pasta `site/`.

### Deploy para GitHub Pages

```bash
mkdocs gh-deploy
```

## Estrutura

- `docs/` - Arquivos Markdown da documentação
- `mkdocs.yml` - Configuração do MkDocs
- `site/` - Site estático gerado (não commitar)

## Contribuindo

Para adicionar ou editar páginas:

1. Edite arquivos `.md` em `docs/`
2. Adicione novas páginas em `mkdocs.yml` na seção `nav:`
3. Teste localmente com `mkdocs serve`
4. Commit e push

## Recursos

- [Guia MkDocs](https://www.mkdocs.org/user-guide/)
- [Material Theme](https://squidfunk.github.io/mkdocs-material/)
- [Markdown Guide](https://www.markdownguide.org/)
