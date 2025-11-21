#!/bin/bash

# CURL para acessar o recurso Venda após o login
# Requer o Session ID do cookie obtido no login
#
# IMPORTANTE: 
# - Substitua ASP.NET_SessionId=hqc1kehqc3hmfyqjfdd1vbjv pelo Session ID real
# - O parâmetro _ é um timestamp (pode usar {{ Date.now() }} no N8n)

curl -X GET "https://clickvenda.app/Venda/Venda?_=1763745416458" \
  -H "Accept: */*" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Referer: https://clickvenda.app/Venda" \
  -H "Cookie: ASP.NET_SessionId=hqc1kehqc3hmfyqjfdd1vbjv" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"

