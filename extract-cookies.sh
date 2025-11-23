#!/bin/bash

# Script para extrair cookies do navegador e formatar para uso em cURL/N8N
# Use: copie os cookies do DevTools do navegador e cole aqui

echo "=== Extrator de Cookies para cURL/N8N ==="
echo ""
echo "Cole abaixo os cookies do navegador (formato: name=value; name2=value2)"
echo "Ou copie direto do DevTools na aba Cookies"
echo "Pressione Enter após colar, depois Ctrl+D para finalizar:"
echo ""

# Lê os cookies
COOKIES=$(cat)

# Remove espaços e quebras de linha
COOKIES=$(echo "$COOKIES" | tr -d '\n' | sed 's/; /;/g')

# Extrai o ASP.NET_SessionId especificamente
SESSION_ID=$(echo "$COOKIES" | grep -oE 'ASP\.NET_SessionId=[^;]+' | cut -d'=' -f2)

echo ""
echo "=== Cookies Formatados ==="
echo ""
echo "String completa de cookies:"
echo "$COOKIES"
echo ""
echo "ASP.NET_SessionId encontrado:"
echo "$SESSION_ID"
echo ""
echo "=== Comando cURL ==="
echo "Use assim no cURL:"
echo ""
echo "curl -H 'Cookie: $COOKIES' ..."
echo ""
echo "=== Para N8N ==="
echo "No N8N, adicione no header Cookie:"
echo "$COOKIES"
echo ""
echo "Ou apenas o ASP.NET_SessionId:"
if [ -n "$SESSION_ID" ]; then
    echo "ASP.NET_SessionId=$SESSION_ID"
else
    echo "⚠️ ASP.NET_SessionId não encontrado!"
fi


