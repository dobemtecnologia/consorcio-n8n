#!/bin/bash

# CURL 26: POST https://clickvenda.app/Venda/EnderecoCliente
# Importe este CURL no N8n usando: Options > Import from cURL

curl -X POST "https://clickvenda.app/Venda/EnderecoCliente" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
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
  -d "cep=66093-047" \
  -d "logradouro=TRAVESSA+HUMAIT%C3%81" \
  -d "numero=2240" \
  -d "complemento=Apt+1804A" \
  -d "bairro=MARCO" \
  -d "cidade=BELEM" \
  -d "uf=PA" \
  -d "telResidencial=(91)983538941" \
  -d "idCidadeResidencial=4565" \
  -d "cepComercial=66093-047" \
  -d "logradouroComercial=TRAVESSA+HUMAIT%C3%81" \
  -d "numeroComercial=2240" \
  -d "complementoComercial=Apt+1804A" \
  -d "bairroComercial=MARCO" \
  -d "cidadeComercial=BELEM" \
  -d "ufComercial=PA" \
  -d "telComercial=(91)983538941" \
  -d "idCidadeComercial=4565" \
  -d "usarCorrespondencia=R" \
  -d "email=elton.jd.goncalves%40gmail.com" \
  -d "email2=elton.jd.goncalves%40gmail.com" \
  -d "aceitaSMS=true" \
  -d "ufCelular=PA" \
  -d "idCidadeCelular=4565" \
  -d "cidadeCelular=BELEM" \
  -d "celular=(91)983538941" \
  -d "celular2=(91)983538941" \
  -d "ufTelAdicional=PA" \
  -d "idCidadeTelAdicional=4565" \
  -d "cidadeTelAdicional=BELEM" \
  -d "telAdicional=(91)983538941" \
  -d "aderiuSeguroVidaPrestamista=true" \
  -d "aceitaDivulgarDados=true" \
  -d "aceitaRepresentanteGrupo=true"

# IMPORTANTE: No N8n, substitua SEU_SESSION_ID_AQUI por: {{ $('Extrair Session ID').item.json.sessionId }}