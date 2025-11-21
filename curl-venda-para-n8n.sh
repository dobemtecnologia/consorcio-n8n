#!/bin/bash

# CURL para importar no N8n - Requisição GET para /Venda/Venda
# 
# IMPORTANTE: 
# - Após importar, ajuste o Cookie para usar o Session ID do login anterior
# - No N8n, use no Cookie: ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}
# - O parâmetro _ é um timestamp (pode usar {{ Date.now() }} no N8n)

curl -X GET "https://clickvenda.app/Venda/Venda?_=1763745416458" \
  -H "Accept: */*" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Referer: https://clickvenda.app/Venda" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI"

