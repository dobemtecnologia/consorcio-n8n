# 📊 Análise de Infraestrutura AWS - Deploy com Terraform

**Projeto Base**: `api-gestao-plano-empresa`  
**Projeto Alvo**: `minerador-cotas-contemplada`  
**Data**: 15 de Outubro de 2025

---

## 📋 Índice

1. [Arquitetura Identificada](#-arquitetura-identificada)
2. [Recursos AWS Utilizados](#-recursos-aws-utilizados)
3. [Adaptações Necessárias](#-adaptações-necessárias)
4. [Estrutura de Arquivos Terraform](#-estrutura-de-arquivos-terraform)
5. [Fluxo de Deploy](#-fluxo-de-deploy)
6. [Estimativa de Custos](#-estimativa-de-custos)
7. [Próximos Passos](#-próximos-passos)

---

## 🏗️ Arquitetura Identificada

### Projeto de Referência: `api-gestao-plano-empresa`

```
Internet
    │
    ├─► Route 53 (DNS)
    │       │
    │       ▼
    ├─► ACM Certificate (SSL/TLS)
    │       │
    │       ▼
    └─► Application Load Balancer (ALB)
            │
            ├─► HTTP :80  → Redirect to HTTPS :443
            │
            └─► HTTPS :443 → Target Group
                              │
                              ▼
                         ECS Fargate Service
                         (1 Task Definition)
                              │
                              ├─► Container: api-gestao-plano-empresa
                              │   └─► Port: 8080
                              │   └─► Image: ECR
                              │   └─► Env: SPRING_PROFILES_ACTIVE=prod
                              │
                              └─► RDS PostgreSQL
                                  └─► postgres-db-17.cboyyg6aixgi.us-east-1.rds.amazonaws.com
```

### Componentes da Infraestrutura

| Componente              | Descrição                 | Configuração                                            |
| ----------------------- | ------------------------- | ------------------------------------------------------- |
| **VPC**                 | Virtual Private Cloud     | CIDR: `10.0.0.0/16`                                     |
| **Subnets**             | 2 subnets públicas        | `10.0.10.0/24` (us-east-1a), `10.0.2.0/24` (us-east-1b) |
| **Internet Gateway**    | Acesso à internet         | Anexado à VPC                                           |
| **Security Group**      | Firewall                  | Portas: 80, 443, 8080 (ingress)                         |
| **ALB**                 | Application Load Balancer | Internet-facing, HTTP/HTTPS                             |
| **Target Group**        | Grupo de destino ECS      | Port 8080, Health check: `/`                            |
| **ACM Certificate**     | Certificado SSL           | Domínio: `empresa.dobemtecnologia.com`                  |
| **ECS Cluster**         | Cluster Fargate           | Nome: `dobemtech-cluster`                               |
| **ECS Task Definition** | Definição da tarefa       | CPU: 512, Memory: 1024 MB                               |
| **ECS Service**         | Serviço ECS               | Desired count: 1, Launch type: FARGATE                  |
| **CloudWatch Logs**     | Logs centralizados        | Retenção: 7 dias                                        |
| **ECR**                 | Container Registry        | Imagem Docker da aplicação                              |
| **RDS PostgreSQL**      | Banco de dados            | Externo (já existente)                                  |

---

## 🔧 Recursos AWS Utilizados

### 1. **Network (network.tf)**

#### VPC e Subnets

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_b" {
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}
```

**Observações**:

- 2 AZs para alta disponibilidade do ALB
- Subnets públicas com IPs públicos automáticos
- Route table conectado ao Internet Gateway

#### Security Group

```hcl
resource "aws_security_group" "ecs_sg" {
  ingress {
    from_port   = 80    # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443   # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080  # Spring Boot
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0     # Permite todo tráfego de saída
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 2. **ECS (ecs.tf)**

#### Cluster

```hcl
resource "aws_ecs_cluster" "main" {
  name = "dobemtech-cluster"
}
```

#### IAM Role

```hcl
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  # Permite que ECS assuma esta role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}
```

#### Application Load Balancer

```hcl
resource "aws_lb" "app" {
  name               = "dobemtech-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}
```

**Características**:

- Internet-facing (público)
- Balanceamento em 2 AZs
- Health check configurado para `/`

#### Target Group

```hcl
resource "aws_lb_target_group" "app" {
  name        = "dobemtech-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"  # Para Fargate

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-399"
  }
}
```

#### ACM Certificate (SSL)

```hcl
resource "aws_acm_certificate" "cert" {
  domain_name       = "empresa.dobemtecnologia.com"
  validation_method = "DNS"
}
```

**Validação**:

- Requer criar registros DNS no Route 53
- Output mostra os registros necessários

#### Listeners (HTTP/HTTPS)

```hcl
# HTTP → Redirect para HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS → Forward para Target Group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
```

#### Task Definition

```hcl
resource "aws_ecs_task_definition" "app" {
  family                   = "dobemtech-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"    # 0.5 vCPU
  memory                   = "1024"   # 1 GB RAM
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "api-gestao-plano-empresa"
    image     = "061039793374.dkr.ecr.us-east-1.amazonaws.com/api-gestao-plano-empresa:0.0.16"
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://postgres-db-17.cboyyg6aixgi.us-east-1.rds.amazonaws.com:5432/gestaoplanoempresa" },
      { name = "SPRING_DATASOURCE_USERNAME", value = "postgres" },
      { name = "SPRING_DATASOURCE_PASSWORD", value = "jEdRpcDBzq" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/dobemtech"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}
```

#### ECS Service

```hcl
resource "aws_ecs_service" "app" {
  name            = "dobemtech-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "api-gestao-plano-empresa"
    container_port   = 8080
  }
}
```

---

## 🔄 Adaptações Necessárias

### Diferenças entre os Projetos

| Aspecto            | api-gestao-plano-empresa       | minerador-cotas-contemplada                               |
| ------------------ | ------------------------------ | --------------------------------------------------------- |
| **Aplicações**     | 1 (Web Angular + API)          | 2 (Web Angular + Mobile Ionic + API)                      |
| **Portas**         | 8080 (Spring Boot)             | 8080 (Spring Boot serve tudo)                             |
| **Build**          | `npm run webapp:prod`          | `npm run webapp:prod` (já inclui mobile)                  |
| **Rotas**          | `/` → Web App<br>`/api/` → API | `/` → Web App<br>`/mobile/` → Mobile App<br>`/api/` → API |
| **Domínio**        | empresa.dobemtecnologia.com    | **A DEFINIR**                                             |
| **Banco de Dados** | RDS PostgreSQL existente       | **A CRIAR ou USAR EXISTENTE**                             |
| **Versão**         | 0.0.16                         | 0.0.1-SNAPSHOT                                            |
| **Artifact ID**    | gestaoplanoempresa             | mieradorcotascontemplada                                  |

### Mudanças Necessárias no Terraform

#### 1. **provider.tf** - ✅ Sem mudanças

```hcl
provider "aws" {
  region = "us-east-1"
}
```

#### 2. **network.tf** - ⚠️ Ajustes nos nomes (opcional)

- Pode manter a mesma estrutura de rede
- **Opção 1**: Reusar VPC/Subnets existentes
- **Opção 2**: Criar VPC nova para este projeto

**Recomendação**: Criar VPC separada para isolamento

```hcl
# Mudanças sugeridas:
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"  # CIDR diferente para evitar conflito

  tags = {
    Name    = "minerador-cotas-vpc"
    Project = "minerador-cotas-contemplada"
  }
}
```

#### 3. **ecs.tf** - 🔴 Mudanças OBRIGATÓRIAS

##### a) Cluster Name

```hcl
resource "aws_ecs_cluster" "main" {
  name = "minerador-cotas-cluster"  # Novo nome
}
```

##### b) CloudWatch Logs

```hcl
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/minerador-cotas"  # Novo nome
  retention_in_days = 7
}
```

##### c) Load Balancer

```hcl
resource "aws_lb" "app" {
  name               = "minerador-cotas-alb"  # Novo nome
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}
```

##### d) Target Group

```hcl
resource "aws_lb_target_group" "app" {
  name        = "minerador-cotas-tg"  # Novo nome
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"  # ✅ OK - Spring Boot serve a raiz
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-399"
  }
}
```

##### e) ACM Certificate

```hcl
resource "aws_acm_certificate" "cert" {
  domain_name       = "minerador.dobemtecnologia.com"  # 🔴 NOVO DOMÍNIO
  validation_method = "DNS"
}
```

**⚠️ IMPORTANTE**: Você precisará definir o domínio antes de executar o Terraform!

##### f) Task Definition - 🔴 MUDANÇAS CRÍTICAS

```hcl
resource "aws_ecs_task_definition" "app" {
  family                   = "minerador-cotas-task"  # Novo nome
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"    # Pode aumentar para "1024" se necessário
  memory                   = "1024"   # Pode aumentar para "2048" se necessário
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "minerador-cotas-contemplada"  # Novo nome
    image     = "061039793374.dkr.ecr.us-east-1.amazonaws.com/minerador-cotas-contemplada:0.0.1"  # 🔴 NOVA IMAGEM
    essential = true
    memory    = 1024
    cpu       = 512

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://SEU-RDS-ENDPOINT:5432/mineradorcotas" },  # 🔴 DEFINIR
      { name = "SPRING_DATASOURCE_USERNAME", value = "postgres" },  # 🔴 DEFINIR
      { name = "SPRING_DATASOURCE_PASSWORD", value = "SENHA-SEGURA" }  # 🔴 DEFINIR (usar Secrets Manager!)
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/minerador-cotas"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}
```

##### g) ECS Service

```hcl
resource "aws_ecs_service" "app" {
  name            = "minerador-cotas-service"  # Novo nome
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "minerador-cotas-contemplada"  # 🔴 Mesmo nome do container
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.https]
}
```

#### 4. **output.tf** - ✅ OK (sem mudanças)

---

## 📁 Estrutura de Arquivos Terraform

### Estrutura Recomendada

```
minerador-cotas-contemplada/
├── infra/
│   ├── provider.tf          # Configuração AWS provider
│   ├── variables.tf         # 🆕 Variáveis parametrizáveis
│   ├── network.tf           # VPC, Subnets, Security Groups
│   ├── rds.tf              # 🆕 RDS PostgreSQL (se criar novo)
│   ├── ecr.tf              # 🆕 ECR Repository
│   ├── ecs.tf              # ECS Cluster, Task, Service, ALB
│   ├── outputs.tf          # Outputs (ALB DNS, ACM records)
│   ├── terraform.tfvars    # 🆕 Valores das variáveis (não commitar!)
│   └── .gitignore          # 🆕 Ignorar .tfstate e .tfvars
```

### Arquivos NOVOS a Criar

#### **variables.tf** (Parametrização)

```hcl
variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "minerador-cotas"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domínio da aplicação"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint do RDS PostgreSQL"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "mineradorcotas"
}

variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "app_version" {
  description = "Versão da aplicação (tag da imagem Docker)"
  type        = string
  default     = "latest"
}

variable "ecs_cpu" {
  description = "CPU para ECS Task (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "512"
}

variable "ecs_memory" {
  description = "Memória para ECS Task (512, 1024, 2048, 4096, 8192)"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Número de tasks desejadas"
  type        = number
  default     = 1
}
```

#### **terraform.tfvars** (Valores - NÃO COMMITAR!)

```hcl
project_name  = "minerador-cotas"
environment   = "prod"
aws_region    = "us-east-1"

# 🔴 DEFINIR VALORES REAIS
domain_name   = "minerador.dobemtecnologia.com"
db_endpoint   = "seu-rds-endpoint.us-east-1.rds.amazonaws.com"
db_name       = "mineradorcotas"
db_username   = "postgres"
db_password   = "SENHA-SUPER-SEGURA"  # Usar AWS Secrets Manager em produção!

app_version   = "0.0.1"
ecs_cpu       = "512"
ecs_memory    = "1024"
desired_count = 1
```

#### **ecr.tf** (Repository para imagens Docker)

```hcl
resource "aws_ecr_repository" "app" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-ecr"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Manter apenas as últimas 10 imagens"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "URL do repositório ECR"
}
```

#### **rds.tf** (OPCIONAL - Banco de dados)

```hcl
# ⚠️ CRIAR APENAS SE NÃO USAR RDS EXISTENTE

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project_name}-db-subnet"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]  # Apenas do ECS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t3.micro"  # Free tier elegível
  allocated_storage      = 20
  storage_type           = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible    = false
  skip_final_snapshot    = true  # ⚠️ Mudar para false em produção!
  backup_retention_period = 7

  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}

output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "Endpoint do RDS PostgreSQL"
  sensitive   = true
}
```

---

## 🚀 Fluxo de Deploy

### Pré-requisitos

1. ✅ **AWS CLI** configurado com credenciais

   ```bash
   aws configure
   ```

2. ✅ **Terraform** instalado (v1.0+)

   ```bash
   brew install terraform  # macOS
   # ou
   https://www.terraform.io/downloads
   ```

3. ✅ **Docker** instalado e rodando

   ```bash
   docker --version
   ```

4. ✅ **Domínio** registrado e apontado para AWS

   - Criar zona hospedada no Route 53
   - Ou ter acesso ao DNS do domínio

5. ✅ **Build da aplicação** funcionando
   ```bash
   npm run webapp:prod
   ./mvnw clean package -Pprod -DskipTests
   ```

### Passos do Deploy

#### 1️⃣ **Preparar Imagem Docker**

```bash
# Build da aplicação (web + mobile + API)
npm run webapp:prod
./mvnw clean package -Pprod -DskipTests

# Build da imagem Docker usando Jib
./mvnw compile jib:dockerBuild -Pprod

# Verificar imagem criada
docker images | grep minerador
```

#### 2️⃣ **Criar ECR Repository (via Terraform)**

```bash
cd infra

# Inicializar Terraform
terraform init

# Criar apenas o ECR primeiro
terraform apply -target=aws_ecr_repository.app
```

#### 3️⃣ **Fazer Login no ECR e Push da Imagem**

```bash
# Login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 061039793374.dkr.ecr.us-east-1.amazonaws.com

# Tag da imagem
docker tag mieradorcotascontemplada:0.0.1-SNAPSHOT 061039793374.dkr.ecr.us-east-1.amazonaws.com/minerador-cotas:0.0.1

# Push para ECR
docker push 061039793374.dkr.ecr.us-east-1.amazonaws.com/minerador-cotas:0.0.1
```

#### 4️⃣ **Criar Infraestrutura (Terraform)**

```bash
# Revisar plano de execução
terraform plan

# Aplicar infraestrutura
terraform apply

# Aguardar criação (pode levar 5-10 minutos)
```

#### 5️⃣ **Configurar DNS (Validação ACM)**

Após o `terraform apply`, você verá os outputs:

```
Outputs:

acm_validation_records = [
  {
    name  = "_abc123.minerador.dobemtecnologia.com."
    type  = "CNAME"
    value = "_xyz789.acm-validations.aws."
  }
]

alb_dns_name = "minerador-cotas-alb-123456789.us-east-1.elb.amazonaws.com"
```

**No Route 53 ou seu DNS**:

1. Criar registro CNAME para validação ACM
2. Aguardar validação (pode levar até 30 minutos)
3. Criar registro A/ALIAS apontando para o ALB

```
Type: A (Alias)
Name: minerador.dobemtecnologia.com
Value: minerador-cotas-alb-123456789.us-east-1.elb.amazonaws.com
```

#### 6️⃣ **Verificar Deploy**

```bash
# Verificar logs do ECS
aws logs tail /ecs/minerador-cotas --follow

# Verificar health check do Target Group
aws elbv2 describe-target-health --target-group-arn <ARN-DO-TARGET-GROUP>

# Testar aplicação
curl https://minerador.dobemtecnologia.com/
curl https://minerador.dobemtecnologia.com/mobile/
curl https://minerador.dobemtecnologia.com/api/
```

#### 7️⃣ **Monitoramento**

```bash
# CloudWatch Logs
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Fecs$252Fminerador-cotas

# ECS Service
https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/minerador-cotas-cluster/services

# Load Balancer
https://console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:
```

---

## 💰 Estimativa de Custos AWS

### Custos Mensais Estimados (us-east-1)

| Serviço                       | Configuração                    | Custo Mensal (USD)       |
| ----------------------------- | ------------------------------- | ------------------------ |
| **ECS Fargate**               | 1 task (0.5 vCPU, 1GB RAM) 24/7 | ~$15                     |
| **Application Load Balancer** | 1 ALB com tráfego baixo         | ~$16                     |
| **RDS PostgreSQL**            | db.t3.micro (Free Tier)         | $0 (1º ano) / $12 (após) |
| **NAT Gateway**               | Não usado (subnets públicas)    | $0                       |
| **Data Transfer**             | Saída de dados (estimado 10GB)  | ~$1                      |
| **CloudWatch Logs**           | 7 dias retenção (estimado 1GB)  | ~$0.50                   |
| **ECR Storage**               | Armazenamento de imagens        | ~$0.10                   |
| **Route 53**                  | Zona hospedada                  | $0.50                    |
| **ACM Certificate**           | SSL/TLS                         | **GRÁTIS** ✅            |

**TOTAL ESTIMADO**: **$33 - $45 USD/mês**

### Opções de Economia

1. **Usar RDS existente** → Economizar $12/mês
2. **Reduzir CPU/Memory do ECS** → Economizar $5-8/mês
3. **Usar Savings Plans** → Economizar 20-30%
4. **Desligar em horários ociosos** (dev/staging) → Economizar 50-70%

---

## ✅ Próximos Passos

### Antes de Executar (Decisões Necessárias)

- [ ] **1. Definir Domínio**

  - Qual domínio usar? (ex: `minerador.dobemtecnologia.com`)
  - Domínio já registrado?
  - DNS gerenciado no Route 53?

- [ ] **2. Banco de Dados**

  - **Opção A**: Criar RDS novo (Terraform)
  - **Opção B**: Usar RDS existente (informar endpoint)
  - **Opção C**: Usar banco externo (ex: Supabase, Neon)

- [ ] **3. Credenciais do Banco**

  - Username
  - Password (usar AWS Secrets Manager?)
  - Nome do banco

- [ ] **4. Revisar Custos**

  - Orçamento mensal aprovado?
  - Configurar AWS Budgets Alert?

- [ ] **5. Ambientes**
  - Apenas produção?
  - Criar também staging/dev?

### Arquivos a Criar

- [ ] Criar pasta `infra/`
- [ ] Criar `provider.tf`
- [ ] Criar `variables.tf`
- [ ] Criar `network.tf`
- [ ] Criar `ecs.tf`
- [ ] Criar `ecr.tf`
- [ ] Criar `rds.tf` (se aplicável)
- [ ] Criar `outputs.tf`
- [ ] Criar `terraform.tfvars`
- [ ] Criar `.gitignore` (ignorar .tfstate, .tfvars)

### Configurações no Projeto

- [ ] Configurar Jib no `pom.xml` (se ainda não estiver)
- [ ] Testar build Docker local
- [ ] Ajustar `application-prod.yml` para variáveis de ambiente
- [ ] Documentar processo de deploy

---

## 📝 Notas Importantes

### Diferenças do Projeto Mobile

✅ **Sem Impacto na Infraestrutura**:

- A aplicação mobile é servida pelo mesmo Spring Boot
- Não requer portas adicionais
- Não requer containers separados
- Routing é feito pelo `SpaWebFilter` já configurado

### Validação DNS do ACM

⚠️ **Atenção**:

- A validação do certificado ACM pode levar até 30 minutos
- Requer acesso ao DNS do domínio
- O `terraform apply` ficará aguardando até a validação completar

### Secrets Management

🔒 **Segurança**:

- Não commitar `terraform.tfvars` com senhas
- Considerar usar AWS Secrets Manager para credenciais do banco
- Rotar senhas regularmente

### Backups

💾 **Importante**:

- Configurar backups automáticos do RDS
- Snapshot final antes de destruir recursos
- Testar processo de restore

---

## 🎯 Resumo Executivo

### O Que Foi Analisado

✅ Infraestrutura completa do projeto `api-gestao-plano-empresa`  
✅ Todos os arquivos Terraform (provider, network, ecs, output)  
✅ Configurações do ECS Fargate, ALB, ACM, RDS  
✅ Processo de build e deploy com Jib

### Principais Descobertas

1. ✅ **Arquitetura simples e eficiente**: ALB → ECS Fargate → RDS
2. ✅ **SSL/TLS automático**: ACM Certificate com validação DNS
3. ✅ **Logs centralizados**: CloudWatch Logs
4. ✅ **Alta disponibilidade**: 2 AZs para o ALB
5. ✅ **Custo acessível**: ~$33-45/mês

### Adaptações para `minerador-cotas-contemplada`

1. 🔄 **Mudanças de nomes**: Cluster, services, repositories
2. 🔄 **Nova imagem Docker**: Build e push para ECR
3. 🔄 **Novo domínio**: Certificado ACM e DNS
4. 🔄 **Variáveis de ambiente**: Database, profiles
5. ✅ **Mesma arquitetura**: Pode reusar 90% do código Terraform

### Pronto para Próximo Passo

📋 **Aguardando suas decisões** sobre:

- Domínio a usar
- Estratégia de banco de dados (novo ou existente)
- Confirmação para criar os arquivos Terraform

---

**Data**: 15 de Outubro de 2025  
**Autor**: AI Assistant  
**Versão**: 1.0
