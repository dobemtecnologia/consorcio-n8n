# Correção do Erro de Deploy no ECS

## 🐛 Problema Identificado

O deploy estava falando com o erro:

```
Waiter ServicesStable failed: Max attempts exceeded
Error: Process completed with exit code 255.
```

### Causas Raiz:

1. **Health Check no path incorreto**: O ALB estava verificando o path `/` em vez do endpoint dedicado do Spring Boot Actuator
2. **Timeout muito curto**: 10 minutos não era suficiente para a aplicação Spring Boot inicializar completamente
3. **Configuração de health check muito restritiva**: Intervalos curtos e poucos retries

## ✅ Correções Aplicadas

### 1. Workflow do GitHub Actions (`.github/workflows/deploy.yml`)

#### Aumentado timeout do wait

- **Antes**: 600 segundos (10 minutos)
- **Depois**: 1200 segundos (20 minutos)
- **Motivo**: Aplicações Spring Boot/JHipster podem demorar vários minutos para inicializar, especialmente no primeiro deploy

#### Adicionado troubleshooting automático

- Novo step que executa quando o deploy falha
- Mostra status do serviço ECS
- Lista tasks em execução
- Exibe últimos logs do CloudWatch
- Fornece dicas de troubleshooting

### 2. Infraestrutura ECS (`infra/ecs.tf`)

#### Health Check Melhorado

```hcl
health_check {
  enabled             = true
  path                = "/management/health/readiness"  # Endpoint correto do Spring Boot Actuator
  interval            = 60                               # Intervalo aumentado de 30 para 60 segundos
  timeout             = 30                               # Timeout aumentado de 5 para 30 segundos
  healthy_threshold   = 2                                # Mantido (2 checks bem-sucedidos)
  unhealthy_threshold = 10                               # Aumentado de 5 para 10 (mais tolerante)
  matcher             = "200-399"                        # Mantido
}
```

**Mudanças**:

- ✅ Path alterado de `/` para `/management/health/readiness`
  - Este endpoint verifica tanto a aplicação quanto a conexão com o banco de dados
  - É específico para probes de prontidão (readiness) em ambientes de produção
- ✅ Intervalo aumentado: 60 segundos (mais tempo entre checks)
- ✅ Timeout aumentado: 30 segundos (mais tempo para a aplicação responder)
- ✅ Unhealthy threshold aumentado: 10 tentativas antes de marcar como não saudável

## 📋 Próximos Passos

### 1. Aplicar mudanças na infraestrutura

As mudanças no Terraform precisam ser aplicadas antes de executar um novo deploy:

```bash
cd infra
terraform plan
terraform apply
```

**IMPORTANTE**: Isso irá atualizar o Target Group do ALB com as novas configurações de health check.

### 2. Executar novo deploy

Após aplicar as mudanças do Terraform:

```bash
git add .
git commit -m "fix: corrigir health check e timeout do deploy ECS"
git push origin main
```

Ou execute manualmente via GitHub Actions:

1. Vá em: https://github.com/seu-repo/actions
2. Selecione "Release & Deploy Minerador Cotas to AWS ECS"
3. Clique em "Run workflow"

### 3. Monitoramento durante o deploy

Durante o deploy, você pode monitorar:

1. **GitHub Actions**: Acompanhe o progresso em tempo real
2. **AWS CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Fecs$252Fminerador-cotas
3. **ECS Service**: https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/minerador-cotas-cluster/services/minerador-cotas-service

## 🔍 Endpoints de Health Check do Spring Boot

A aplicação expõe os seguintes endpoints de health:

- `/management/health` - Status geral de saúde
- `/management/health/liveness` - Verifica se a aplicação está viva
- `/management/health/readiness` - Verifica se a aplicação está pronta para receber tráfego (inclui DB)

**Por que usar `/management/health/readiness`?**

- Verifica a conexão com o banco de dados
- Confirma que todos os componentes essenciais estão funcionando
- É o padrão recomendado para probes de readiness em Kubernetes e ECS

## 🚨 Troubleshooting Adicional

Se o deploy ainda falhar após estas mudanças:

### 1. Verificar logs no CloudWatch

```bash
aws logs tail /ecs/minerador-cotas --since 10m --follow
```

### 2. Verificar status do serviço ECS

```bash
aws ecs describe-services \
  --cluster minerador-cotas-cluster \
  --services minerador-cotas-service \
  --region us-east-1
```

### 3. Verificar tasks em execução

```bash
aws ecs list-tasks \
  --cluster minerador-cotas-cluster \
  --service-name minerador-cotas-service \
  --region us-east-1
```

### 4. Problemas comuns

#### Aplicação não inicia

- Verifique variáveis de ambiente no task definition
- Confirme que o banco de dados está acessível
- Verifique memória/CPU suficientes (512 CPU / 1024 MB pode ser pouco para Spring Boot)

#### Health check continua falhando

- Teste o endpoint manualmente: `curl http://<ALB-DNS>/management/health/readiness`
- Verifique se o Security Group permite tráfego na porta 8080
- Confirme que o banco de dados está respondendo

#### Timeout de conexão com banco

- Verifique o Security Group do RDS permite conexões do Security Group do ECS
- Confirme que as credenciais estão corretas
- Verifique se o RDS está no mesmo VPC

## 📊 Configuração de Recursos

Se a aplicação continuar lenta para iniciar, considere aumentar os recursos:

```hcl
# Em infra/variables.tf ou ao executar terraform apply
ecs_cpu    = "1024"  # De 512 para 1024 (1 vCPU)
ecs_memory = "2048"  # De 1024 para 2048 (2 GB)
```

Aplicações JHipster com frontend Angular podem consumir muita memória durante a inicialização.

## ✨ Resumo das Melhorias

✅ Timeout aumentado de 10 para 20 minutos  
✅ Health check usando endpoint correto do Spring Boot  
✅ Configurações mais tolerantes (intervalos maiores, mais retries)  
✅ Troubleshooting automático em caso de falha  
✅ Logs e status exibidos automaticamente quando há erro

---

**Nota**: Depois de aplicar o `terraform apply`, faça backup do arquivo `terraform.tfstate` que é crítico para o gerenciamento da infraestrutura.
