# 🔄 Consórcio N8N - Sistema de Automação e Processamento

Sistema completo para automação de vendas de consórcio via N8N e processamento de contemplações.

## 📋 Visão Geral

Este projeto é composto por dois sistemas principais:

1. **🔄 Automação N8N**: Integração com o sistema ClickVenda para automatizar o processo completo de cadastro de vendas
2. **💾 Processamento SQL**: Sistema para processar e registrar contemplações (sorteios e lances fixos) no banco de dados

## 📁 Estrutura do Projeto

```
consorcio-n8n/
├── n8n/                    # Automação de vendas via N8N
│   ├── workflows/          # Scripts JavaScript para N8N
│   ├── curls/             # 30 requisições CURL do fluxo
│   ├── scripts/           # Scripts de geração
│   ├── utils/             # Utilitários
│   ├── data/               # Dados de captura (HAR)
│   └── docs/               # Documentação N8N
│
├── sql/                    # Processamento de contemplações
│   ├── install.sql        # Instalação do sistema
│   └── funcoes_auxiliares/ # Funções extras
│
├── docs/                   # Documentação técnica geral
│   ├── deploy/            # Deploy e infraestrutura
│   └── infra/             # Análise de infraestrutura
│
└── querys-sql/             # Queries de manutenção
```

## 🚀 Início Rápido

### Automação N8N

1. **Leia o guia completo**: [`n8n/docs/PASSO-A-PASSO-N8N.md`](n8n/docs/PASSO-A-PASSO-N8N.md)
2. **Use os CURLs**: Copie arquivos de [`n8n/curls/`](n8n/curls/) e importe no N8N
3. **Script de extração**: Use [`n8n/workflows/extrair-session-id.js`](n8n/workflows/extrair-session-id.js) no N8N

📖 **Documentação completa**: [`n8n/README.md`](n8n/README.md)

### Processamento SQL

1. **Instale o sistema**: Execute [`sql/install.sql`](sql/install.sql)
2. **Leia a documentação**: [`sql/README.md`](sql/README.md)
3. **Use as funções**: `processar_contemplacao()` ou `processar_lote_contemplacao()`

## 📚 Documentação

### Documentação Principal

- **[Análise do Projeto](ANALISE-PROJETO.md)** - Análise completa e organização dos arquivos
- **[N8N - Automação](n8n/README.md)** - Guia completo da automação N8N
- **[SQL - Contemplações](sql/README.md)** - Sistema de processamento SQL

### Documentação Técnica

- **[Documentação Geral](docs/README.md)** - Índice geral da documentação
- **[Deploy](docs/deploy/CHECKLIST-DEPLOY.md)** - Guia de deploy
- **[Infraestrutura](docs/infra/INFRA-ANALYSIS.md)** - Análise de infraestrutura

## 🔧 Scripts Úteis

### Gerar CURLs a partir do HAR

```bash
cd n8n/scripts
node gerar-todos-curl.js
```

### Gerar Documentação Completa

```bash
cd n8n/scripts
node gerar-guia-completo.js
```

## ⚠️ Requisitos Importantes

### N8N

1. **Inicializar Sessão**: O passo de inicialização é **OBRIGATÓRIO**
2. **Full Response**: Configure o nó de Login com "Full Response"
3. **Ordem das Requisições**: A ordem exata importa!

### SQL

1. **Sequence**: Certifique-se de que `contemplacao_id_seq` existe
2. **Bem/Plano**: A função pega o primeiro bem/plano disponível

## 📊 Estatísticas

- **30 Requisições CURL** para o fluxo completo de venda
- **2 Funções SQL** principais para processamento
- **15+ Documentos** de referência técnica

## 🔗 Links Úteis

- [Análise Completa do Projeto](ANALISE-PROJETO.md)
- [Guia N8N Passo a Passo](n8n/docs/PASSO-A-PASSO-N8N.md)
- [Sistema SQL de Contemplações](sql/README.md)
- [Documentação Técnica](docs/README.md)

## 📝 Licença

Este projeto é privado e de uso interno.

---

**Última atualização**: Janeiro 2025

