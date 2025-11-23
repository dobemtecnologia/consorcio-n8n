# 📚 Documentação do Projeto - Minerador de Cotas Contempladas

Bem-vindo à documentação completa do sistema de mineração de cotas contempladas.

## 📖 Índice Geral

### 🚀 Deploy e Infraestrutura

- **[Checklist de Deploy](deploy/CHECKLIST-DEPLOY.md)** - Passo a passo para realizar deploy
- **[Configurar Secrets](deploy/CONFIGURAR-SECRETS.md)** - Como configurar credenciais no GitHub/AWS
- **[Correções do Deploy](deploy/RESUMO-CORRECOES.md)** - Resumo de todas as correções aplicadas
- **[Script de Configuração](deploy/setup-secrets.sh)** - Script automatizado para AWS Secrets Manager
- **[Análise de Infraestrutura](infra/INFRA-ANALYSIS.md)** - Análise completa da infraestrutura AWS

### 📱 Mobile

- **[Documentação Mobile](mobile/MOBILE-DOCS.md)** - Guia completo do aplicativo móvel Ionic

### 📋 Planejamento

- **[Próximos Passos](PROXIMOS-PASSOS.md)** - Roadmap e melhorias futuras

---

## 🎯 Início Rápido

### Para Deploy

1. Configure os secrets: [Configurar Secrets](deploy/CONFIGURAR-SECRETS.md)
2. Siga o checklist: [Checklist de Deploy](deploy/CHECKLIST-DEPLOY.md)
3. Monitore via [GitHub Actions](https://github.com/dobemtecnologia/minerador-cotas-contemplada/actions)

### Para Desenvolvimento

```bash
# Backend
./mvnw

# Frontend
npm start

# Mobile
cd mobile && npm start
```

---

## 📁 Estrutura da Documentação

```
docs/
├── README.md                    # Este arquivo - índice geral
├── deploy/                      # Tudo sobre deploy
│   ├── CHECKLIST-DEPLOY.md     # Checklist passo a passo
│   ├── CONFIGURAR-SECRETS.md   # Configuração de credenciais
│   ├── RESUMO-CORRECOES.md     # Correções aplicadas
│   └── setup-secrets.sh        # Script automatizado
├── infra/                       # Infraestrutura AWS
│   └── INFRA-ANALYSIS.md       # Análise da infraestrutura
├── mobile/                      # Aplicativo móvel
│   └── MOBILE-DOCS.md          # Documentação do app
└── PROXIMOS-PASSOS.md          # Roadmap do projeto
```

---

## 🆘 Precisa de Ajuda?

### Deploy não funciona?

→ Consulte: [Correções do Deploy](deploy/RESUMO-CORRECOES.md)

### Erro de senha no banco?

→ Consulte: [Configurar Secrets](deploy/CONFIGURAR-SECRETS.md)

### Dúvidas sobre infraestrutura?

→ Consulte: [Análise de Infraestrutura](infra/INFRA-ANALYSIS.md)

### Desenvolvimento mobile?

→ Consulte: [Documentação Mobile](mobile/MOBILE-DOCS.md)

---

## 🔗 Links Úteis

- **Repositório**: https://github.com/dobemtecnologia/minerador-cotas-contemplada
- **GitHub Actions**: https://github.com/dobemtecnologia/minerador-cotas-contemplada/actions
- **Produção**: https://minerador.dobemtecnologia.com/
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1
- **ECS**: https://console.aws.amazon.com/ecs/home?region=us-east-1

---

Última atualização: 2025-10-15
