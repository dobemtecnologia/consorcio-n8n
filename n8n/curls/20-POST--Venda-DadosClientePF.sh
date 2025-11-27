#!/bin/bash

# CURL 20: POST https://clickvenda.app/Venda/DadosClientePF
# Importe este CURL no N8n usando: Options > Import from cURL

curl -X POST "https://clickvenda.app/Venda/DadosClientePF" \
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
  -F "cpf=832.054.622-20" \
  -F "nomeCompleto=ELTON+JHON+DIAS+GONCALVES" \
  -F "nomeCompletoWS=ELTON+JHON+DIAS+GONCALVES" \
  -F "dataNascimento=19%2F02%2F1986" \
  -F "ufNaturalidade=PA" \
  -F "naturalidade=BELEM" \
  -F "idCidadeNaturalidade=4565" \
  -F "idNacionalidade=BR" \
  -F "rg=4978939" \
  -F "orgaoExpedidor=SSP" \
  -F "ufOrgaoExpedidor=PA" \
  -F "dataExpedicao=08%2F08%2F2016" \
  -F "sexo=M" \
  -F "idEstadoCivil=6" \
  -F "valorRendaMensal=30000" \
  -F "idProfissao=5364" \
  -F "nomeMae=creuza+dias+gon%C3%A7alves" \
  -F "nomePai=eder+wilsom+machado+gon%C3%A7alves" \
  -F "pessoaExpostaPoliticamente=false" \
  -F "compartilhaDados=true" \
  -F "indicadoPorCPF=" \
  -F "indicadoPorNome=" \
  -F "sexoConjuge=" \
  -F "cpfConjuge=" \
  -F "nomeConjuge=" \
  -F "rgConjuge="

# IMPORTANTE: No N8n, substitua SEU_SESSION_ID_AQUI por: {{ $('Extrair Session ID').item.json.sessionId }}