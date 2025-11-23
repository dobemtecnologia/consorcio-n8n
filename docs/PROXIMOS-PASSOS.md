# ✅ Próximos Passos - Deploy AWS

**Projeto**: Minerador de Cotas Contempladas  
**Data**: 15 de Outubro de 2025

---

## 🎯 Objetivo

Colocar a aplicação (Web + Mobile + API) em produção na AWS usando:

- **Infraestrutura**: Terraform
- **CI/CD**: GitHub Actions (automático)

---

## 📋 Checklist Completo

### FASE 1: Preparação (15 minutos)

#### 1.1 - Verificar Ferramentas Locais

```bash
# Terraform
terraform --version
# Deve mostrar: Terraform v1.0+
# Se não tiver: brew install terraform

# AWS CLI
aws --version
# Deve mostrar: aws-cli/2.x.x
# Se não tiver: brew install awscli

# Docker
docker --version
# Deve mostrar: Docker version 24.x.x
# Se não estiver rodando: abrir Docker Desktop
```

**Status**: [ ] Concluído

---

#### 1.2 - Configurar AWS CLI

```bash
aws configure

# Informar:
# AWS Access Key ID: [SUA-ACCESS-KEY]
# AWS Secret Access Key: [SUA-SECRET-KEY]
# Default region: us-east-1
# Default output format: json
```

**Testar**:

```bash
aws sts get-caller-identity
# Deve mostrar seu Account ID
```

**Status**: [ ] Concluído

---

#### 1.3 - Testar Build Local

```bash
# Build do frontend (Web + Mobile)
npm run webapp:prod

# Build do backend
./mvnw clean package -Pprod -DskipTests
```

**Status**: [ ] Concluído

---

### FASE 2: Deploy da Infraestrutura (30-45 minutos)

#### 2.1 - Executar Terraform

**Opção A: Script Interativo (Recomendado)**

```bash
cd infra
./deploy.sh

# Escolher: Opção 1 (Criar infraestrutura completa)
# Confirmar com: yes
# Aguardar: ~10 minutos
```

**Opção B: Terraform Manual**

```bash
cd infra
terraform init
terraform plan
terraform apply  # Confirmar com: yes
```

**Recursos que serão criados** (15 no total):

- VPC, Subnets, Internet Gateway
- Security Group
- Application Load Balancer
- Target Group
- ACM Certificate (SSL)
- ECR Repository
- ECS Cluster, Task Definition, Service
- CloudWatch Logs
- IAM Roles

**Tempo estimado**: 10-15 minutos

**Status**: [ ] Concluído

---

#### 2.2 - Copiar Outputs do Terraform

Após o `terraform apply`, você verá outputs importantes. **Copie e salve**:

```bash
# Ver todos os outputs
terraform output

# Ou outputs específicos:
terraform output acm_validation_records
terraform output alb_dns_name
terraform output ecr_repository_url
terraform output dns_instructions
```

**Anotar aqui**:

```
ACM Validation CNAME:
Name:  _________________
Value: _________________

ALB DNS Name: _________________
ECR URL: _________________
```

**Status**: [ ] Concluído

---

### FASE 3: Configuração DNS (30-45 minutos)

#### 3.1 - Validar Certificado ACM

**No Route 53 (ou seu provedor DNS)**:

1. Acessar: https://console.aws.amazon.com/route53/
2. Selecionar zona: `dobemtecnologia.com`
3. Criar novo registro **CNAME**:
   - **Name**: (copiar do output `acm_validation_records`)
   - **Type**: CNAME
   - **Value**: (copiar do output `acm_validation_records`)
   - **TTL**: 300

**Status**: [ ] Concluído

---

#### 3.2 - Aguardar Validação do Certificado

```bash
# Verificar status do certificado
aws acm list-certificates --region us-east-1

# Aguardar status: ISSUED
# Tempo: até 30 minutos
```

**Dica**: Enquanto aguarda, pode prosseguir para Fase 4!

**Status**: [ ] Certificado ISSUED

---

#### 3.3 - Apontar Domínio para ALB

**Após certificado validado**, criar registro para o domínio:

**No Route 53**:

1. Criar registro **A (Alias)**:
   - **Name**: `minerador`
   - **Type**: A - IPv4 address
   - **Alias**: Yes
   - **Alias target**: Application Load Balancer → selecionar `minerador-cotas-alb`
   - **Alias hosted zone ID**: (automático)

**Em outro DNS (CloudFlare, etc)**:

```
Type: CNAME
Name: minerador
Value: <ALB-DNS-NAME>  # do output do Terraform
```

**Status**: [ ] Concluído

---

### FASE 4: Build e Push da Imagem Docker (15-20 minutos)

#### 4.1 - Fazer Login no ECR

```bash
# Pegar URL do ECR
cd infra
ECR_URL=$(terraform output -raw ecr_repository_url)
echo $ECR_URL

# Login no ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URL
```

**Status**: [ ] Concluído

---

#### 4.2 - Build e Push da Imagem

**Opção A: Via Script**

```bash
cd infra
./deploy.sh

# Escolher: Opção 2 (Build e push da imagem Docker)
# Informar versão: 0.0.1
# Aguardar: ~10-15 minutos
```

**Opção B: Manual**

```bash
# Voltar para raiz do projeto
cd ..

# Build do frontend
npm run webapp:prod

# Build da imagem Docker com Jib
./mvnw compile jib:dockerBuild -Pprod

# Tag da imagem
docker tag mieradorcotascontemplada:0.0.1-SNAPSHOT $ECR_URL:0.0.1
docker tag mieradorcotascontemplada:0.0.1-SNAPSHOT $ECR_URL:latest

# Push para ECR
docker push $ECR_URL:0.0.1
docker push $ECR_URL:latest
```

**Status**: [ ] Concluído

---

#### 4.3 - Aguardar ECS Fazer Pull

```bash
# Ver logs do ECS em tempo real
aws logs tail /ecs/minerador-cotas --follow

# Ou via infra/deploy.sh → Opção 5
```

**O que esperar nos logs**:

```
Starting MieradorcotascontempladaApp...
Started MieradorcotascontempladaApp in X seconds
Application 'mieradorcotascontemplada' is running!
```

**Tempo**: 2-3 minutos para o ECS iniciar a task

**Status**: [ ] Task rodando

---

### FASE 5: Verificação (5 minutos)

#### 5.1 - Testar Aplicação

```bash
# Web App
curl -I https://minerador.dobemtecnologia.com/
# Deve retornar: HTTP/2 200

# Mobile App
curl -I https://minerador.dobemtecnologia.com/mobile/
# Deve retornar: HTTP/2 200

# API
curl https://minerador.dobemtecnologia.com/api/
# Deve retornar JSON
```

**Ou no navegador**:

- https://minerador.dobemtecnologia.com/
- https://minerador.dobemtecnologia.com/mobile/
- https://minerador.dobemtecnologia.com/api/

**Status**: [ ] Todas as URLs funcionando

---

#### 5.2 - Verificar Health Check

```bash
# Status do Target Group
aws elbv2 describe-target-health \
  --target-group-arn $(cd infra && terraform output -raw aws_lb_target_group.app.arn)

# Deve mostrar: State: healthy
```

**Status**: [ ] Target healthy

---

#### 5.3 - Verificar Logs

```bash
# CloudWatch Logs
aws logs tail /ecs/minerador-cotas --follow

# Ou no console:
# https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
```

**Status**: [ ] Logs normais, sem erros

---

### FASE 6: Configurar CI/CD GitHub Actions (15 minutos)

#### 6.1 - Adicionar GitHub Secrets

1. Acessar: https://github.com/SEU-USUARIO/minerador-cotas-contemplada/settings/secrets/actions
2. Clicar em **"New repository secret"**
3. Adicionar 3 secrets:

**Secret 1**: AWS_ACCESS_KEY_ID

```
Name: AWS_ACCESS_KEY_ID
Value: [SUA-AWS-ACCESS-KEY]
```

**Secret 2**: AWS_SECRET_ACCESS_KEY

```
Name: AWS_SECRET_ACCESS_KEY
Value: [SUA-AWS-SECRET-KEY]
```

**Secret 3**: DB_PASSWORD (fallback)

```
Name: DB_PASSWORD
Value: jEdRpcDBzq
```

**Status**: [ ] Secrets adicionados

---

#### 6.2 - (Opcional) Criar AWS Secrets Manager

```bash
aws secretsmanager create-secret \
  --name POSTGRES_MINERADOR_COTAS \
  --description "Credenciais PostgreSQL - Minerador Cotas" \
  --secret-string '{
    "host": "db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com",
    "port": "5432",
    "database": "mieradorcotascontemplada",
    "username": "postgres",
    "password": "jEdRpcDBzq"
  }'
```

**Status**: [ ] Secret criado (ou pulado)

---

#### 6.3 - (Opcional) Criar GitHub Environment

1. Acessar: https://github.com/SEU-USUARIO/minerador-cotas-contemplada/settings/environments
2. Clicar **"New environment"**
3. Nome: `PROD_AWS`
4. (Opcional) Configurar:
   - Required reviewers: você mesmo
   - Wait timer: 0 minutos

**Status**: [ ] Environment criado (ou pulado)

---

#### 6.4 - Testar CI/CD

```bash
# Fazer uma alteração qualquer
echo "# Deploy test" >> README.md

# Commit e push
git add .
git commit -m "test: verificar CI/CD"
git push origin main
```

**Acompanhar**:

- GitHub Actions: https://github.com/SEU-USUARIO/minerador-cotas-contemplada/actions

**O que deve acontecer**:

1. ✅ Build do frontend (Web + Mobile)
2. ✅ Build do backend
3. ✅ Criação de tag (v0.0.1)
4. ✅ Build da imagem Docker
5. ✅ Push para ECR
6. ✅ Deploy no ECS (rolling update)
7. ✅ Verificação de deploy

**Tempo**: 5-8 minutos

**Status**: [ ] CI/CD funcionando

---

### FASE 7: Finalização (5 minutos)

#### 7.1 - Criar Backup das Configurações

```bash
# Exportar outputs do Terraform
cd infra
terraform output > ../terraform-outputs.txt

# Salvar configurações importantes em algum lugar seguro:
# - AWS Account ID
# - ECR URL
# - ALB DNS Name
# - Credenciais AWS (em local seguro!)
```

**Status**: [ ] Backup criado

---

#### 7.2 - Documentar Acessos

Criar documento com:

```
APLICAÇÃO EM PRODUÇÃO - MINERADOR COTAS
========================================

🌐 URLs:
- Web App:    https://minerador.dobemtecnologia.com/
- Mobile App: https://minerador.dobemtecnologia.com/mobile/
- API REST:   https://minerador.dobemtecnologia.com/api/

🔧 AWS Resources:
- Account ID: [ANOTAR]
- Region: us-east-1
- ECS Cluster: minerador-cotas-cluster
- ECR Repository: minerador-cotas
- Load Balancer: minerador-cotas-alb

📊 Monitoramento:
- CloudWatch Logs: /ecs/minerador-cotas
- ECS Console: [URL]
- Target Group Health: [ARN]

🔐 Credenciais:
- AWS Access Key: [LOCAL SEGURO]
- DB Password: [AWS SECRETS MANAGER]

💰 Custo Mensal Estimado: $33 USD

📅 Data Deploy: [DATA]
📦 Versão Inicial: 0.0.1
```

**Status**: [ ] Documentação criada

---

#### 7.3 - Configurar Monitoramento (Opcional)

```bash
# Criar alarme de custo
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget.json

# Criar alarme CloudWatch para ECS
aws cloudwatch put-metric-alarm \
  --alarm-name minerador-cotas-high-cpu \
  --alarm-description "CPU alta no ECS" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold
```

**Status**: [ ] Monitoramento configurado (ou pulado)

---

## 🎉 DEPLOY CONCLUÍDO!

### ✅ Checklist Final

- [ ] Infraestrutura criada (Terraform)
- [ ] DNS configurado e validado
- [ ] Aplicação rodando no ECS
- [ ] Web App acessível
- [ ] Mobile App acessível
- [ ] API REST funcionando
- [ ] CI/CD configurado (GitHub Actions)
- [ ] Secrets configurados
- [ ] Documentação atualizada
- [ ] Monitoramento ativo

---

## 📊 Resumo do Deploy

**Infraestrutura AWS**:

- ✅ VPC com 2 AZs
- ✅ Application Load Balancer (HTTPS)
- ✅ ECS Fargate (0.5 vCPU, 1GB RAM)
- ✅ RDS PostgreSQL (existente)
- ✅ ECR Repository
- ✅ ACM Certificate (SSL/TLS)
- ✅ CloudWatch Logs

**Aplicações Deployadas**:

- ✅ Web App Angular (/)
- ✅ Mobile App Ionic (/mobile/)
- ✅ API REST Spring Boot (/api/)

**CI/CD**:

- ✅ GitHub Actions automático
- ✅ Deploy em cada push na main
- ✅ Versionamento automático
- ✅ Zero downtime

**Custo**: ~$33/mês

---

## 🔄 Próximas Atualizações

### Para deploy manual:

```bash
cd infra
./deploy.sh  # Opção 3 (Atualizar aplicação)
```

### Para deploy automático:

```bash
git add .
git commit -m "feat: nova funcionalidade"
git push origin main
# CI/CD faz tudo automaticamente!
```

---

## 📚 Documentação de Referência

- **Terraform**: `infra/README.md`
- **Deploy Rápido**: `infra/DEPLOY-GUIDE.md`
- **CI/CD**: `.github/workflows/README.md`
- **Mobile**: `MOBILE-DOCS.md`
- **Análise Infra**: `INFRA-ANALYSIS.md`

---

## 🆘 Suporte

### Problemas Comuns

**Certificado não valida**:

- Verificar registros DNS no Route 53
- Aguardar até 30 minutos

**ECS Task não inicia**:

- Ver logs: `aws logs tail /ecs/minerador-cotas --follow`
- Verificar imagem no ECR

**Target Group Unhealthy**:

- Verificar se app responde em `/`
- Verificar security group permite porta 8080

**CI/CD falha**:

- Verificar GitHub Secrets
- Ver logs no GitHub Actions

---

**Boa sorte com o deploy! 🚀**

**Data**: 15 de Outubro de 2025  
**Autor**: AI Assistant  
**Versão**: 1.0
