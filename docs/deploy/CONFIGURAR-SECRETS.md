# 🔐 Configurar Secrets para Deploy

## Problema Identificado

O deploy estava falhando porque:

1. ❌ **A senha estava hardcoded** no arquivo `application-prod.yml`
2. ❌ **Variáveis de ambiente não estavam configuradas** no GitHub Actions
3. ❌ **Conflito entre configuração estática e dinâmica**

Erro original:

```
PSQLException: The server requested SCRAM-based authentication, but no password was provided.
```

## ✅ Correções Aplicadas

1. **Removida senha hardcoded** do `application-prod.yml`
2. **Configurado placeholders** para usar variáveis de ambiente:
   ```yaml
   url: ${SPRING_DATASOURCE_URL:jdbc:postgresql://...}
   username: ${SPRING_DATASOURCE_USERNAME:postgres}
   password: ${SPRING_DATASOURCE_PASSWORD:}
   ```
3. **Adicionada validação** no workflow do GitHub Actions

## Solução: Escolha UMA das opções abaixo

### ✅ Opção 1: Configurar Secret no GitHub (Recomendado)

Esta é a opção mais simples e rápida.

#### Passo a Passo:

1. **Acesse o repositório no GitHub**

   ```
   https://github.com/[seu-usuario]/minerador-cotas-contemplada/settings/secrets/actions
   ```

2. **Clique em "New repository secret"**

3. **Configure o secret:**

   - **Name**: `DB_PASSWORD`
   - **Value**: `jEdRpcDBzq` (a senha do seu banco RDS PostgreSQL)

4. **Clique em "Add secret"**

5. **Execute o workflow novamente**
   - Vá em: Actions → "Release & Deploy Minerador Cotas to AWS ECS" → "Run workflow"

---

### ✅ Opção 2: Configurar Secret no AWS Secrets Manager

Esta opção é mais segura e profissional para ambientes de produção.

#### Passo a Passo:

1. **Criar o secret via AWS CLI:**

```bash
aws secretsmanager create-secret \
  --name POSTGRES_MINERADOR_COTAS \
  --description "Credenciais do banco PostgreSQL para Minerador de Cotas" \
  --secret-string '{
    "host": "db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com",
    "port": "5432",
    "database": "mieradorcotascontemplada",
    "username": "postgres",
    "password": "jEdRpcDBzq"
  }' \
  --region us-east-1
```

2. **Ou criar via Console AWS:**

   - Acesse: https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/listSecrets
   - Clique em "Store a new secret"
   - Selecione "Other type of secret"
   - Adicione os pares chave/valor:
     ```
     host: db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com
     port: 5432
     database: mieradorcotascontemplada
     username: postgres
     password: jEdRpcDBzq
     ```
   - Nome do secret: `POSTGRES_MINERADOR_COTAS`
   - Clique em "Next" → "Next" → "Store"

3. **Executar o workflow novamente**

---

## 🔍 Como Verificar se Está Funcionando

Após configurar o secret, execute o workflow. Você verá nos logs:

```
✅ Credenciais do banco configuradas
   Host: db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com
   Port: 5432
   Database: mieradorcotascontemplada
   User: postgres
   Password: jEd***zq
```

E no próximo passo:

```
🔍 Verificando variáveis de ambiente...
   DB_URL: jdbc:postgresql://db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com:5432/mieradorcotascontemplada
   DB_USER: postgres
   DB_PASS: ***DEFINIDA***
```

---

## ⚠️ IMPORTANTE: Nunca commite senhas no código!

As senhas devem estar SEMPRE em:

- GitHub Secrets (para CI/CD)
- AWS Secrets Manager (para produção)
- Variáveis de ambiente locais (para desenvolvimento)

**NUNCA** coloque senhas em:

- ❌ Arquivos de configuração (`.yml`, `.properties`)
- ❌ Código-fonte
- ❌ Commits do Git
- ❌ Logs

---

## 🔄 Mudanças Aplicadas no Workflow

O workflow agora:

1. ✅ **Valida se a senha foi fornecida** antes de continuar
2. ✅ **Mostra mensagens de erro claras** se algum secret estiver faltando
3. ✅ **Exibe debug** das variáveis (sem expor a senha completa)
4. ✅ **Falha rapidamente** se detectar problema de configuração

---

## 🚨 Troubleshooting

### Se o erro persistir:

#### 1. Verificar se o secret está configurado no GitHub:

```bash
# Não há comando para ver secrets do GitHub (são privados)
# Você precisa verificar manualmente em:
# https://github.com/[seu-usuario]/minerador-cotas-contemplada/settings/secrets/actions
```

#### 2. Verificar se o secret existe no AWS:

```bash
aws secretsmanager describe-secret \
  --secret-id POSTGRES_MINERADOR_COTAS \
  --region us-east-1
```

#### 3. Verificar o valor do secret (com cuidado!):

```bash
aws secretsmanager get-secret-value \
  --secret-id POSTGRES_MINERADOR_COTAS \
  --region us-east-1 \
  --query SecretString \
  --output text | jq
```

#### 4. Testar conexão com o banco:

```bash
psql -h db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d mieradorcotascontemplada \
     -p 5432
```

---

## 📊 Ordem de Precedência

O workflow busca as credenciais nesta ordem:

1. **AWS Secrets Manager** (`POSTGRES_MINERADOR_COTAS`) - Mais seguro ✅
2. **GitHub Secret** (`DB_PASSWORD`) - Fallback

Se nenhum estiver configurado, o deploy **falhará imediatamente** com mensagem clara.

---

## ✨ Recomendações de Segurança

### Para Produção:

- ✅ Use **AWS Secrets Manager**
- ✅ Habilite **rotação automática de senha**
- ✅ Use **IAM roles** em vez de access keys quando possível
- ✅ Configure **encryption at rest** para o RDS

### Para Desenvolvimento:

- ✅ Use **variáveis de ambiente locais**
- ✅ Crie um arquivo `.env.local` (e adicione ao `.gitignore`)
- ✅ Use **senhas diferentes** de produção

---

## 📝 Próximos Passos

1. **Configure o secret** (Opção 1 ou 2 acima)
2. **Execute o workflow**: `git push` ou "Run workflow" manualmente
3. **Monitore os logs** para verificar se as credenciais foram carregadas
4. **Aguarde o deploy** (até 20 minutos)

Se ainda houver problemas, os logs de debug mostrarão exatamente onde está o problema!
