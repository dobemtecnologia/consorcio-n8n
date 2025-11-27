#!/bin/bash

# CURL 23: GET https://clickvenda.app/Venda/BuscarCEP
# Importe este CURL no N8n usando: Options > Import from cURL

curl -X GET "https://clickvenda.app/Venda/BuscarCEP?cep=66093-047&_=1763750921758" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Referer: https://clickvenda.app/Venda" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "sec-ch-ua: "Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: "macOS"" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI"

# IMPORTANTE: No N8n, substitua SEU_SESSION_ID_AQUI por: {{ $('Extrair Session ID').item.json.sessionId }}