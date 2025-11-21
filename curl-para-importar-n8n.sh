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
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Accept: */*" \
  -H "Origin: https://clickvenda.app" \
  -H "Referer: https://clickvenda.app/acesso/Entrar" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -F "cpf=00640045200" \
  -F "senha=disal 2026"

