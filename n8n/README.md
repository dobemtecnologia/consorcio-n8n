# 🔄 N8N - Automação de Vendas ClickVenda

Este diretório contém todos os arquivos relacionados à automação de vendas de consórcio via N8N, integrando com o sistema ClickVenda.

## 📁 Estrutura

```
n8n/
├── workflows/          # Scripts JavaScript para uso no N8N
│   └── extrair-session-id.js
├── curls/              # 30 requisições CURL do fluxo completo
│   ├── 01-POST--Acesso-Entrar.sh
│   ├── 02-POST--Acesso-Entrar.sh
│   └── ... (30 arquivos)
├── scripts/            # Scripts Node.js para gerar arquivos
│   ├── gerar-todos-curl.js
│   └── gerar-guia-completo.js
├── utils/              # Utilitários e scripts auxiliares
│   ├── extract-cookies.sh
│   └── curl-inicializar-sessao.sh
├── data/               # Dados de captura
│   └── clickvenda.app.har
└── docs/               # Documentação
    └── PASSO-A-PASSO-N8N.md
```

## 🚀 Início Rápido

### 1. Configurar Workflow no N8N

Siga o guia completo:
- **[PASSO-A-PASSO-N8N.md](docs/PASSO-A-PASSO-N8N.md)** - Guia passo a passo completo

### 2. Usar Requisições CURL

Todas as 30 requisições estão em `curls/`:
- Copie o conteúdo de qualquer arquivo `.sh`
- No N8N: Options > Import from cURL
- Cole o conteúdo

### 3. Extrair Session ID

Use o script em `workflows/extrair-session-id.js`:
- Adicione um nó **Code** no N8N
- Configure como "Run Once for All Items"
- Cole o código do arquivo

## 📋 Fluxo Completo

O fluxo completo consiste em:

1. **Login** → Autenticação no ClickVenda
2. **Extrair Session ID** → Capturar cookie de sessão
3. **Inicializar Sessão** → ⚠️ OBRIGATÓRIO!
4. **30 Requisições Sequenciais** → Processo completo de cadastro

## 🔧 Scripts de Geração

### Gerar CURLs a partir do HAR

```bash
cd n8n/scripts
node gerar-todos-curl.js
```

Isso gera os arquivos CURL em `n8n/curls/` a partir de `n8n/data/clickvenda.app.har`.

### Gerar Documentação Completa

```bash
cd n8n/scripts
node gerar-guia-completo.js
```

Isso gera o arquivo `n8n/docs/PASSO-A-PASSO-N8N.md` com todas as instruções.

## ⚠️ Requisitos Importantes

1. **Inicializar Sessão**: O passo de inicialização é **OBRIGATÓRIO**. Sem ele, todas as requisições retornam `{"status":"logar"}`.

2. **Full Response**: Configure o nó de Login com "Full Response" para capturar os headers.

3. **Ordem das Requisições**: A ordem exata importa! Siga a sequência documentada.

4. **Session ID**: Use `{{ $('Extrair Session ID').item.json.sessionId }}` em todas as requisições autenticadas.

## 📚 Documentação

- **[PASSO-A-PASSO-N8N.md](docs/PASSO-A-PASSO-N8N.md)** - Guia completo
- **[../docs/README.md](../docs/README.md)** - Documentação geral do projeto

## 🔗 Links Relacionados

- [Documentação Geral](../docs/README.md)
- [Análise do Projeto](../ANALISE-PROJETO.md)
- [SQL - Processamento de Contemplações](../sql/README.md)

