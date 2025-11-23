#!/bin/bash

# Script para configurar secrets do banco de dados no AWS Secrets Manager
# Uso: ./setup-secrets.sh

set -e

echo "🔐 Configuração de Secrets para Deploy"
echo "======================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações padrão (do Terraform)
DEFAULT_HOST="db-postgres.cboyyg6aixgi.us-east-1.rds.amazonaws.com"
DEFAULT_PORT="5432"
DEFAULT_DB="mieradorcotascontemplada"
DEFAULT_USER="postgres"
DEFAULT_REGION="us-east-1"

# Solicitar senha
echo -e "${YELLOW}📝 Informações do banco de dados:${NC}"
echo ""
read -p "Host do banco [$DEFAULT_HOST]: " DB_HOST
DB_HOST=${DB_HOST:-$DEFAULT_HOST}

read -p "Porta [$DEFAULT_PORT]: " DB_PORT
DB_PORT=${DB_PORT:-$DEFAULT_PORT}

read -p "Nome do banco [$DEFAULT_DB]: " DB_NAME
DB_NAME=${DB_NAME:-$DEFAULT_DB}

read -p "Usuário [$DEFAULT_USER]: " DB_USER
DB_USER=${DB_USER:-$DEFAULT_USER}

read -sp "Senha do banco: " DB_PASS
echo ""

if [ -z "$DB_PASS" ]; then
    echo -e "${RED}❌ Senha não pode estar vazia!${NC}"
    exit 1
fi

read -p "Região AWS [$DEFAULT_REGION]: " AWS_REGION
AWS_REGION=${AWS_REGION:-$DEFAULT_REGION}

echo ""
echo -e "${YELLOW}🔍 Verificando se o secret já existe...${NC}"

# Verificar se o secret já existe
if aws secretsmanager describe-secret --secret-id POSTGRES_MINERADOR_COTAS --region $AWS_REGION &>/dev/null; then
    echo -e "${YELLOW}⚠️  Secret POSTGRES_MINERADOR_COTAS já existe!${NC}"
    read -p "Deseja atualizar? (s/N): " UPDATE_SECRET
    
    if [ "$UPDATE_SECRET" = "s" ] || [ "$UPDATE_SECRET" = "S" ]; then
        echo -e "${YELLOW}🔄 Atualizando secret...${NC}"
        aws secretsmanager update-secret \
            --secret-id POSTGRES_MINERADOR_COTAS \
            --secret-string "{
                \"host\": \"$DB_HOST\",
                \"port\": \"$DB_PORT\",
                \"database\": \"$DB_NAME\",
                \"username\": \"$DB_USER\",
                \"password\": \"$DB_PASS\"
            }" \
            --region $AWS_REGION
        
        echo -e "${GREEN}✅ Secret atualizado com sucesso!${NC}"
    else
        echo -e "${YELLOW}⏭️  Mantendo secret existente.${NC}"
    fi
else
    echo -e "${YELLOW}➕ Criando novo secret...${NC}"
    aws secretsmanager create-secret \
        --name POSTGRES_MINERADOR_COTAS \
        --description "Credenciais do banco PostgreSQL para Minerador de Cotas" \
        --secret-string "{
            \"host\": \"$DB_HOST\",
            \"port\": \"$DB_PORT\",
            \"database\": \"$DB_NAME\",
            \"username\": \"$DB_USER\",
            \"password\": \"$DB_PASS\"
        }" \
        --region $AWS_REGION
    
    echo -e "${GREEN}✅ Secret criado com sucesso!${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Configuração concluída!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📋 Resumo da configuração:"
echo "   Secret Name: POSTGRES_MINERADOR_COTAS"
echo "   Região: $AWS_REGION"
echo "   Host: $DB_HOST"
echo "   Porta: $DB_PORT"
echo "   Database: $DB_NAME"
echo "   Usuário: $DB_USER"
echo ""
echo "🔍 Para verificar o secret:"
echo "   aws secretsmanager get-secret-value \\"
echo "     --secret-id POSTGRES_MINERADOR_COTAS \\"
echo "     --region $AWS_REGION \\"
echo "     --query SecretString --output text | jq"
echo ""
echo "🚀 Próximo passo:"
echo "   Execute um novo deploy com: git push"
echo "   Ou manualmente via GitHub Actions"
echo ""
echo -e "${GREEN}✅ Tudo pronto!${NC}"

