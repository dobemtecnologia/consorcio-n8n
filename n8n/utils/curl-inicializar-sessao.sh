#!/bin/bash

# CURL para importar no N8n - Inicializar Sessão
# Esta requisição é necessária APÓS o login e ANTES de fazer requisições autenticadas
# 
# IMPORTANTE: Use este CURL depois do login e antes de /Venda/Venda

curl -X GET "https://clickvenda.app/Venda/EscolherDN/?idLead=&idEquipe=42&idPedidoOrigem=&TipoVenda=Automovel" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI"

