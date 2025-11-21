#!/bin/bash

# CURL pronto para importar no N8n
# 
# Como usar no N8n:
# 1. Vá em HTTP Request node
# 2. Clique em "Import from cURL"
# 3. Cole o comando curl abaixo (sem o #!/bin/bash e sem os comentários)
# 4. O N8n irá configurar automaticamente os headers e body
#
# IMPORTANTE: Ajuste o CPF e senha antes de usar!

curl -X POST "https://clickvenda.app/Acesso/Entrar" \
  -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Origin: https://clickvenda.app" \
  -H "Referer: https://clickvenda.app/acesso/Entrar" \
  -H "Sec-Ch-Ua: \"Chromium\";v=\"142\", \"Google Chrome\";v=\"142\", \"Not_A Brand\";v=\"99\"" \
  -H "Sec-Ch-Ua-Mobile: ?0" \
  -H "Sec-Ch-Ua-Platform: \"macOS\"" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -d "cpf=00640045200" \
  -d "senha=disal 2026"

