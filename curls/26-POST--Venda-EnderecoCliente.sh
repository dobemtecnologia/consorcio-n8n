#!/bin/bash

# CURL 26: POST https://clickvenda.app/Venda/EnderecoCliente
# Importe este CURL no N8n usando: Options > Import from cURL

curl -X POST "https://clickvenda.app/Venda/EnderecoCliente" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Origin: https://clickvenda.app" \
  -H "Referer: https://clickvenda.app/Venda" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "sec-ch-ua: "Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: "macOS"" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI" \
  -F "cep=66093-047" \
  -F "logradouro=TRAVESSA+HUMAIT%C3%81" \
  -F "numero=2240" \
  -F "complemento=Apt+1804A" \
  -F "bairro=MARCO" \
  -F "cidade=BELEM" \
  -F "uf=PA" \
  -F "telResidencial=(91)983538941" \
  -F "idCidadeResidencial=4565" \
  -F "cepComercial=66093-047" \
  -F "logradouroComercial=TRAVESSA+HUMAIT%C3%81" \
  -F "numeroComercial=2240" \
  -F "complementoComercial=Apt+1804A" \
  -F "bairroComercial=MARCO" \
  -F "cidadeComercial=BELEM" \
  -F "ufComercial=PA" \
  -F "telComercial=(91)983538941" \
  -F "idCidadeComercial=4565" \
  -F "usarCorrespondencia=R" \
  -F "email=elton.jd.goncalves%40gmail.com" \
  -F "email2=elton.jd.goncalves%40gmail.com" \
  -F "aceitaSMS=true" \
  -F "ufCelular=PA" \
  -F "idCidadeCelular=4565" \
  -F "cidadeCelular=BELEM" \
  -F "celular=(91)983538941" \
  -F "celular2=(91)983538941" \
  -F "ufTelAdicional=PA" \
  -F "idCidadeTelAdicional=4565" \
  -F "cidadeTelAdicional=BELEM" \
  -F "telAdicional=(91)983538941" \
  -F "aderiuSeguroVidaPrestamista=true" \
  -F "aceitaDivulgarDados=true" \
  -F "aceitaRepresentanteGrupo=true"

# IMPORTANTE: No N8n, substitua SEU_SESSION_ID_AQUI por: {{ $('Extrair Session ID').item.json.sessionId }}