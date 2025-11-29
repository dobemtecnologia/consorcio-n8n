#!/bin/bash

# Script para executar webhook minerador para múltiplos grupos
# Uso: ./executar-webhook-minerador.sh [arquivo-grupos]

# Caminho padrão do arquivo de grupos (relativo ao diretório do script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRUPOS_FILE="${1:-$SCRIPT_DIR/../../grupos.txt}"

# URL do webhook
WEBHOOK_URL="https://maestro.consorcio.dobemtech.com/webhook/minerador"

# Verificar se o arquivo existe
if [ ! -f "$GRUPOS_FILE" ]; then
    echo "Erro: Arquivo de grupos não encontrado: $GRUPOS_FILE"
    exit 1
fi

# Contador
total=0
sucesso=0
erro=0

echo "=========================================="
echo "Executando webhook minerador para grupos"
echo "Arquivo: $GRUPOS_FILE"
echo "=========================================="
echo ""

# Ler cada linha do arquivo (ignorando linhas vazias)
while IFS= read -r grupo || [ -n "$grupo" ]; do
    # Remover espaços em branco
    grupo=$(echo "$grupo" | tr -d '[:space:]')
    
    # Pular linhas vazias
    if [ -z "$grupo" ]; then
        continue
    fi
    
    total=$((total + 1))
    
    echo "[$total] Processando grupo: $grupo"
    
    # Executar curl
    response=$(curl -s -w "\n%{http_code}" --location "$WEBHOOK_URL" \
        --header 'Content-Type: application/json' \
        --data "{\"cdGrupo\": \"'$grupo'\"}")
    
    # Separar resposta e código HTTP
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    # Verificar resultado
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "  ✓ Sucesso (HTTP $http_code)"
        sucesso=$((sucesso + 1))
    else
        echo "  ✗ Erro (HTTP $http_code)"
        echo "  Resposta: $body"
        erro=$((erro + 1))
    fi
    
    echo ""
    
    # Pequeno delay para não sobrecarregar o servidor
    sleep 0.5
    
done < "$GRUPOS_FILE"

# Resumo final
echo "=========================================="
echo "Resumo da execução:"
echo "  Total processado: $total"
echo "  Sucesso: $sucesso"
echo "  Erro: $erro"
echo "=========================================="

