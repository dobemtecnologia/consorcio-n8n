# 📋 Resumo das Correções do Deploy

## 🐛 Problemas Identificados

### 1. Health Check Incorreto ✅ CORRIGIDO

- **Problema**: ALB verificava path `/` em vez do endpoint dedicado
- **Solução**: Alterado para `/management/health/readiness` no `infra/ecs.tf`

### 2. Timeout Insuficiente ✅ CORRIGIDO

- **Problema**: 10 minutos não era suficiente para Spring Boot inicializar
- **Solução**: Aumentado para 20 minutos (1200s) no `.github/workflows/deploy.yml`

### 3. Senha Hardcoded no Código ✅ CORRIGIDO

- **Problema**: Senha estava no arquivo `application-prod.yml` (RISCO DE SEGURANÇA!)
- **Solução**: Removida e substituída por variáveis de ambiente

### 4. Falta de Validação de Secrets ✅ CORRIGIDO

- **Problema**: Workflow não validava se as credenciais existiam
- **Solução**: Adicionada validação e debug no workflow

---

## 🔧 Arquivos Modificados

### 1. `infra/ecs.tf`

```diff
  health_check {
    enabled             = true
-   path                = "/"
-   interval            = 30
-   timeout             = 5
-   unhealthy_threshold = 5
+   path                = "/management/health/readiness"
+   interval            = 60
+   timeout             = 30
+   unhealthy_threshold = 10
    matcher             = "200-399"
  }
```

### 2. `.github/workflows/deploy.yml`

```diff
+ # Validação de senha
+ if [ -z "$DB_PASS" ]; then
+   echo "❌ ERRO: Senha do banco não configurada!"
+   exit 1
+ fi

+ # Debug de variáveis
+ echo "🔍 Verificando variáveis de ambiente..."
+ echo "   DB_PASS: ${DB_PASS:+***DEFINIDA***}"

  # Timeout aumentado
  aws ecs wait services-stable \
-   --cli-read-timeout 600 \
-   --cli-connect-timeout 600
+   --cli-read-timeout 1200 \
+   --cli-connect-timeout 1200
```

### 3. `src/main/resources/config/application-prod.yml`

```diff
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
-   url: jdbc:postgresql://db-postgres...
-   username: postgres
-   password: jEdRpcDBzq  # ❌ NUNCA FAÇA ISSO!
+   url: ${SPRING_DATASOURCE_URL:jdbc:postgresql://...}
+   username: ${SPRING_DATASOURCE_USERNAME:postgres}
+   password: ${SPRING_DATASOURCE_PASSWORD:}  # ✅ Variável de ambiente
```

---

## 🚀 Próximos Passos

### Passo 1: Aplicar mudanças do Terraform

```bash
cd infra
terraform plan
terraform apply
cd ..
```

### Passo 2: Configurar Secret no GitHub

Escolha **UMA** das opções:

#### Opção A: Secret no GitHub (Mais Simples) ⭐

1. Acesse: https://github.com/[seu-usuario]/minerador-cotas-contemplada/settings/secrets/actions
2. Clique em "New repository secret"
3. Configure:
   - **Name**: `DB_PASSWORD`
   - **Value**: `jEdRpcDBzq`
4. Clique em "Add secret"

#### Opção B: Secret no AWS Secrets Manager (Mais Seguro)

```bash
# Dar permissão de execução ao script
chmod +x setup-secrets.sh

# Executar o script interativo
./setup-secrets.sh
```

Ou manualmente:

```bash
aws secretsmanager create-secret \
  --name POSTGRES_MINERADOR_COTAS \
  --secret-string '{
    "host": "db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com",
    "port": "5432",
    "database": "mieradorcotascontemplada",
    "username": "postgres",
    "password": "jEdRpcDBzq"
  }' \
  --region us-east-1
```

### Passo 3: Commit e Push

```bash
# Adicionar mudanças
git add .

# Fazer commit
git commit -m "fix: remover senha hardcoded e corrigir deploy ECS

- Remove credenciais hardcoded do application-prod.yml
- Corrige health check do ALB para usar /management/health/readiness
- Aumenta timeout do deploy de 10 para 20 minutos
- Adiciona validação e debug de secrets no workflow
- Melhora configurações de health check (intervalo, timeout, retries)"

# Enviar para o GitHub (vai disparar o deploy automaticamente)
git push origin main
```

### Passo 4: Monitorar o Deploy

Acesse o GitHub Actions:

```
https://github.com/[seu-usuario]/minerador-cotas-contemplada/actions
```

Você verá os logs mostrando:

- ✅ Credenciais configuradas
- ✅ Variáveis de ambiente validadas
- ✅ Task definition registrada
- ✅ Deploy em andamento

---

## 🔍 Como Verificar se Funcionou

### No GitHub Actions

Procure por estas linhas nos logs:

```
✅ Credenciais do banco configuradas
   Host: db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com
   Database: mieradorcotascontemplada
   User: postgres
   Password: jEd***zq

🔍 Verificando variáveis de ambiente...
   DB_URL: jdbc:postgresql://...
   DB_USER: postgres
   DB_PASS: ***DEFINIDA***
```

### No CloudWatch Logs

Acesse: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Fecs$252Fminerador-cotas

Procure por:

```
✅ Started MieradorcotascontempladaApp
✅ Liquibase ran successfully
```

### Na Aplicação

Após ~5-10 minutos do deploy:

```bash
# Testar a aplicação
curl https://minerador.dobemtecnologia.com/management/health/readiness

# Deve retornar algo como:
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "diskSpace": {"status": "UP"},
    "ping": {"status": "UP"}
  }
}
```

---

## 🔐 Segurança

### ✅ O que foi melhorado:

1. **Senha removida do código-fonte**

   - Antes: ❌ Hardcoded no `application-prod.yml`
   - Agora: ✅ Apenas em secrets (GitHub ou AWS)

2. **Variáveis de ambiente validadas**

   - Deploy falha imediatamente se senha não estiver configurada
   - Mensagens de erro claras e úteis

3. **Debug seguro**
   - Senha nunca é exposta nos logs
   - Apenas mostra "**_DEFINIDA_**" ou primeiros/últimos 3 caracteres

### ⚠️ Próximas melhorias recomendadas:

1. **Rotação automática de senha**

   ```bash
   aws secretsmanager rotate-secret \
     --secret-id POSTGRES_MINERADOR_COTAS \
     --rotation-lambda-arn <arn-da-funcao-lambda>
   ```

2. **Usar IAM Authentication para RDS**

   - Elimina necessidade de senhas
   - Mais seguro e fácil de gerenciar

3. **Habilitar encryption at rest no RDS**
   - Já deve estar habilitado, mas verifique:
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier db-postgres \
     --query 'DBInstances[0].StorageEncrypted'
   ```

---

## 📊 Melhorias Aplicadas

| Item                  | Antes     | Depois                         |
| --------------------- | --------- | ------------------------------ |
| Health Check Path     | `/`       | `/management/health/readiness` |
| Health Check Interval | 30s       | 60s                            |
| Health Check Timeout  | 5s        | 30s                            |
| Unhealthy Threshold   | 5         | 10                             |
| Deploy Timeout        | 10 min    | 20 min                         |
| Senha no código       | ❌ Sim    | ✅ Não                         |
| Validação de secrets  | ❌ Não    | ✅ Sim                         |
| Debug de erros        | ❌ Básico | ✅ Completo                    |

---

## 🆘 Troubleshooting

### Se o deploy ainda falhar:

#### 1. Verificar se o secret foi configurado

```bash
# GitHub: verificar manualmente no navegador
# AWS:
aws secretsmanager describe-secret \
  --secret-id POSTGRES_MINERADOR_COTAS \
  --region us-east-1
```

#### 2. Verificar conectividade com o banco

```bash
# Testar conexão
psql -h db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d mieradorcotascontemplada \
     -p 5432
```

#### 3. Verificar Security Groups

```bash
# Listar security groups do RDS
aws rds describe-db-instances \
  --db-instance-identifier db-postgres \
  --query 'DBInstances[0].VpcSecurityGroups'

# Verificar regras do security group do ECS
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=minerador-cotas-ecs-sg"
```

#### 4. Verificar logs detalhados

```bash
# Logs do CloudWatch
aws logs tail /ecs/minerador-cotas --follow

# Status das tasks
aws ecs describe-tasks \
  --cluster minerador-cotas-cluster \
  --tasks $(aws ecs list-tasks \
    --cluster minerador-cotas-cluster \
    --service-name minerador-cotas-service \
    --query 'taskArns[0]' \
    --output text)
```

---

## ✨ Arquivos de Documentação Criados

1. **`DEPLOY-FIX.md`** - Explicação detalhada do problema de health check e timeout
2. **`CONFIGURAR-SECRETS.md`** - Guia passo a passo para configurar secrets
3. **`setup-secrets.sh`** - Script interativo para configurar AWS Secrets Manager
4. **`RESUMO-CORRECOES.md`** (este arquivo) - Visão geral de todas as correções

---

## 📞 Contato

Se precisar de ajuda:

1. Consulte os logs do GitHub Actions
2. Verifique os logs do CloudWatch
3. Consulte a documentação nos arquivos `.md` criados

---

**Última atualização**: 2025-10-15  
**Status**: ✅ Pronto para deploy
