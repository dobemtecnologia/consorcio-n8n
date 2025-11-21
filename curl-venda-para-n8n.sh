#!/bin/bash

# CURL para importar no N8n - Requisição GET para /Venda/Venda
# 
# IMPORTANTE: 
# - Use APÓS fazer login E acessar a página /Venda/EscolherDN/...
# - Ajuste o Cookie para usar o Session ID do login anterior
# - No N8n, use no Cookie: ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}
# - O parâmetro _ é um timestamp (pode usar {{ Date.now() }} no N8n)

curl -X GET "https://clickvenda.app/Venda/Venda?_=1763745416458" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Connection: keep-alive" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI" \
  -H "Referer: https://clickvenda.app/Venda" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "X-Requested-With: XMLHttpRequest"

