# Passo-a-Passo Completo no N8n - ClickVenda

## 📋 Índice das Requisições

Esta documentação contém **todas as 30 requisições** do fluxo completo, na ordem exata que o navegador executa.

### Setup Inicial (Nós Fixos)

1. **Login** - HTTP Request
2. **Extrair Session ID** - Code
3. **Inicializar Sessão** - HTTP Request (OBRIGATÓRIO!)

### Requisições do Fluxo (Ordem Exata)

1. **POST Acesso/Entrar** - Login inicial
2. **POST Acesso/Entrar** - Login (segunda tentativa)
3. **GET Venda/Venda** - Buscar dados de venda
4. **GET Venda/BuscaAndamento** - Buscar andamento
5. **GET Venda/BuscarModelos** - Buscar modelos
6. **POST Venda/BuscaPrazo** - Buscar prazo
7. **POST Venda/BuscaPlano** - Buscar plano
8. **POST Venda/BuscaMarca** - Buscar marca
9. **POST Venda/BuscaBem** - Buscar bem
10. **POST Venda/BuscaAndamento** - Buscar andamento (POST)
11. **GET Venda/SelecaoGrupo** - Seleção de grupo (GET)
12. **POST Venda/SelecaoGrupo** - Seleção de grupo (POST)
13. **GET Venda/SelecaoCota** - Seleção de cota (GET)
14. **POST Venda/SelecaoCota** - Seleção de cota (POST)
15. **GET Venda/DadosBemSelecionadoAndamento** - Dados do bem selecionado (GET)
16. **POST Venda/DadosBemSelecionadoAndamento** - Dados do bem selecionado (POST)
17. **GET Venda/DadosCliente** - Dados do cliente (GET)
18. **GET Venda/BuscarCPF** - Buscar CPF
19. **GET ApiVD/cidade/PA** - Buscar cidades (PA)
20. **POST Venda/DadosClientePF** - Dados do cliente PF (POST)
21. **GET Venda/EnderecoCliente** - Endereço do cliente (GET)
22. **GET Venda/BuscarCEP** - Buscar CEP (1)
23. **GET Venda/BuscarCEP** - Buscar CEP (2)
24. **GET ApiVD/cidade/PA** - Buscar cidades (PA) (2)
25. **GET ApiVD/cidade/PA** - Buscar cidades (PA) (3)
26. **POST Venda/EnderecoCliente** - Endereço do cliente (POST 1)
27. **POST Venda/EnderecoCliente** - Endereço do cliente (POST 2)
28. **GET Venda/DadosBancarios** - Dados bancários (GET)
29. **POST Venda/DadosBancarios** - Dados bancários (POST)
30. **GET Venda/DadosPagamento** - Dados de pagamento

---

## 🔧 Setup Inicial (Execute APENAS UMA VEZ)

### **Nó 1: HTTP Request - Login**

1. Adicione um nó **HTTP Request** no N8n
2. Clique em **Options** (⚙️) no canto superior direito
3. Selecione **Import from cURL**
4. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Acesso/Entrar" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Origin: https://clickvenda.app" \
  -H "Referer: https://clickvenda.app/acesso/Entrar" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "sec-ch-ua: "Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: "macOS"" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI" \
  -F "cpf=00640045200" \
  -F "senha=disal+2026"
```

5. **Ajuste os valores de CPF e senha** no Body:
   - Vá em **Body** > você verá `cpf` e `senha`
   - Edite os valores ou use expressões do N8n como `{{ $json.cpf }}`

6. **Configure para retornar headers completos**:
   - Vá em **Options** (⚙️)
   - Em **Response**, selecione **Full Response**
   - Isso é necessário para capturar o Session ID

7. Renomeie o nó para: **"Login"**

---

### **Nó 2: Code - Extrair Session ID**

1. Adicione um nó **Code** após o nó de Login
2. Configure o modo como **"Run Once for All Items"**
3. Cole este código JavaScript (arquivo: `n8n/workflows/extrair-session-id.js`):

```javascript
// Code node: Mode = "Run Once for All Items"
// Extrai o Session ID do cookie retornado pelo login

const item = $input.first();                  // pega o item do HTTP Request

// Acessa os headers - o N8n pode retornar em diferentes estruturas
const headers = (item?.json?.headers) || {};

// Procura pelo cookie em diferentes formatos (case-insensitive)
const raw = headers['set-cookie'] || headers['Set-Cookie'] || headers['SET-COOKIE'] || [];

// Converte para array se necessário
const list = Array.isArray(raw) ? raw : (raw ? [raw] : []);


let sessionId = null;

// Processa cada linha de cookie
for (const line of list) {
  if (!line || typeof line !== 'string') continue;
  
  // Pega apenas a primeira parte antes do ';' (nome=valor)
  const first = line.split(';')[0].trim();
  const idx = first.indexOf('=');
  
  if (idx === -1) continue;
  
  const name = first.slice(0, idx).trim();
  const value = first.slice(idx + 1).trim();
  
  if (!name) continue;

  // Verifica se é o Session ID (case-insensitive)
  if (name.toLowerCase() === 'asp.net_sessionid') {
    sessionId = value;
  }
}


// Retorne SEMPRE um array de objetos (requisito do N8n)
return [
  {
    json: {
      sessionId,            // ex: "212yl23pw4gpmehgq1ru4nig"
    },
  },
];

```

4. Renomeie o nó para: **"Extrair Session ID"**

---

### **Nó 3: HTTP Request - Inicializar Sessão (⚠️ OBRIGATÓRIO!)**

**Este passo é essencial! Sem ele, as requisições subsequentes não funcionam.**

1. Adicione outro nó **HTTP Request** após o nó "Extrair Session ID"
2. Clique em **Options** (⚙️) > **Import from cURL**
3. **IMPORTANTE**: Você precisa acessar a página HTML primeiro. Use este CURL:

```bash
curl -X GET "https://clickvenda.app/Venda/EscolherDN/?idLead=&idEquipe=42&idPedidoOrigem=&TipoVenda=Automovel" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI"
```

4. **Ajuste o Cookie para usar o Session ID do login**:
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `{{ $('Extrair Session ID').item.json.sessionId }}`
   - Ou use: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. Renomeie o nó para: **"Inicializar Sessão"**

---

## 📦 Todas as Requisições do Fluxo

Agora você pode adicionar as requisições abaixo na ordem exata. **IMPORTANTE**: Todas as requisições autenticadas precisam do Cookie com o Session ID.

### **Requisição 2: POST Acesso/Entrar**

**Descrição**: Login (segunda tentativa)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Acesso/Entrar" \
  -H "Accept: */*" \
  -H "Accept-Encoding: gzip, deflate, br, zstd" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Origin: https://clickvenda.app" \
  -H "Referer: https://clickvenda.app/Acesso/Entrar" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "sec-ch-ua: "Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: "macOS"" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI" \
  -F "cpf=00640045200" \
  -F "senha=disal+2026"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 3: GET Venda/Venda**

**Descrição**: Buscar dados de venda

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/Venda?_=1763750921747" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 4: GET Venda/BuscaAndamento**

**Descrição**: Buscar andamento

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/BuscaAndamento?_=1763750921748" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 5: GET Venda/BuscarModelos**

**Descrição**: Buscar modelos

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/BuscarModelos?idMarca=null&minCredito=null&maxCredito=null&tipo=andamento&_=1763750921749" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 6: POST Venda/BuscaPrazo**

**Descrição**: Buscar prazo

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/BuscaPrazo" \
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
  -F "tipoFiltro=parcela" \
  -F "idProduto=2"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 7: POST Venda/BuscaPlano**

**Descrição**: Buscar plano

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/BuscaPlano" \
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
  -F "prazo=" \
  -F "parcelaAte=5000" \
  -F "idProduto=2"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 8: POST Venda/BuscaMarca**

**Descrição**: Buscar marca

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/BuscaMarca" \
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
  -F "prazo=" \
  -F "planoId=3233"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 9: POST Venda/BuscaBem**

**Descrição**: Buscar bem

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/BuscaBem" \
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
  -F "prazo=" \
  -F "planoId=3233" \
  -F "marca=" \
  -F "creditoReferenciado=true" \
  -F "idProduto=2"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 10: POST Venda/BuscaAndamento**

**Descrição**: Buscar andamento (POST)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/BuscaAndamento" \
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
  -F "tipoFiltro=parcela" \
  -F "prazo=" \
  -F "plano=3233" \
  -F "idMarca=" \
  -F "idBem=1000763" \
  -F "creditoReferenciado=true" \
  -F "minParcela=" \
  -F "maxParcela=5000"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 11: GET Venda/SelecaoGrupo**

**Descrição**: Seleção de grupo (GET)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/SelecaoGrupo?idProduto=2&_=1763750921750" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 12: POST Venda/SelecaoGrupo**

**Descrição**: Seleção de grupo (POST)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/SelecaoGrupo" \
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
  -F "idGrupo=10196" \
  -F "idPlano=3233" \
  -F "prazoCota=056" \
  -F "idTaxaPlano=9650" \
  -F "qtdApagarContemplacao=0" \
  -F "idProduto=2"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 13: GET Venda/SelecaoCota**

**Descrição**: Seleção de cota (GET)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/SelecaoCota?idProduto=2&_=1763750921751" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 14: POST Venda/SelecaoCota**

**Descrição**: Seleção de cota (POST)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/SelecaoCota" \
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
  -F "cota=1421" \
  -F "idProduto=2"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 15: GET Venda/DadosBemSelecionadoAndamento**

**Descrição**: Dados do bem selecionado (GET)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/DadosBemSelecionadoAndamento?_=1763750921752" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 16: POST Venda/DadosBemSelecionadoAndamento**

**Descrição**: Dados do bem selecionado (POST)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/DadosBemSelecionadoAndamento" \
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
  -F "continuar=true"
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 17: GET Venda/DadosCliente**

**Descrição**: Dados do cliente (GET)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/DadosCliente?_=1763750921753" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 18: GET Venda/BuscarCPF**

**Descrição**: Buscar CPF

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/BuscarCPF?cpf=832.054.622-20&_=1763750921754" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 19: GET ApiVD/cidade/PA**

**Descrição**: Buscar cidades (PA)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/ApiVD/cidade/PA?_=1763750921755" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 20: POST Venda/DadosClientePF**

**Descrição**: Dados do cliente PF (POST)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 21: GET Venda/EnderecoCliente**

**Descrição**: Endereço do cliente (GET)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/EnderecoCliente?idProduto=2&_=1763750921756" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 22: GET Venda/BuscarCEP**

**Descrição**: Buscar CEP (1)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/BuscarCEP?cep=66093-047&_=1763750921757" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 23: GET Venda/BuscarCEP**

**Descrição**: Buscar CEP (2)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 24: GET ApiVD/cidade/PA**

**Descrição**: Buscar cidades (PA) (2)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/ApiVD/cidade/PA?_=1763750921759" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 25: GET ApiVD/cidade/PA**

**Descrição**: Buscar cidades (PA) (3)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/ApiVD/cidade/PA?_=1763750921760" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 26: POST Venda/EnderecoCliente**

**Descrição**: Endereço do cliente (POST 1)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 27: POST Venda/EnderecoCliente**

**Descrição**: Endereço do cliente (POST 2)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
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
  -F "telResidencial=" \
  -F "idCidadeResidencial=4565" \
  -F "cepComercial=66093-047" \
  -F "logradouroComercial=TRAVESSA+HUMAIT%C3%81" \
  -F "numeroComercial=2240" \
  -F "complementoComercial=Apt+1804A" \
  -F "bairroComercial=MARCO" \
  -F "cidadeComercial=BELEM" \
  -F "ufComercial=PA" \
  -F "telComercial=" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 28: GET Venda/DadosBancarios**

**Descrição**: Dados bancários (GET)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/DadosBancarios?_=1763750921761" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

### **Requisição 29: POST Venda/DadosBancarios**

**Descrição**: Dados bancários (POST)

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Venda/DadosBancarios" \
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
  -F "autorizaDeposito=false" \
  -F "naoTenhoConta=true" \
  -F "idBancoDeposito=" \
  -F "agenciaDeposito=" \
  -F "contaCorrenteDeposito="
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

---

### **Requisição 30: GET Venda/DadosPagamento**

**Descrição**: Dados de pagamento

1. Adicione um nó **HTTP Request**
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/DadosPagamento?_=1763750921762" \
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
```

4. **Ajuste o Cookie** (se necessário):
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua `SEU_SESSION_ID_AQUI` por: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o timestamp** (opcional):
   - O parâmetro `_=` pode ser substituído por `{{ Date.now() }}` para gerar timestamp atual

---

## ⚠️ Pontos Importantes

1. **SEMPRE configure "Full Response" no nó de Login** - necessário para capturar os headers com o Session ID

2. **SEMPRE execute o nó "Inicializar Sessão" após o login** - sem ele, as requisições retornam `{"status":"logar"}` em vez de funcionar

3. **Use o mesmo Session ID em todas as requisições subsequentes** - `{{ $('Extrair Session ID').item.json.sessionId }}`

4. **Mantenha a ordem dos nós** - A ordem exata importa! Siga a sequência do índice acima.

5. **Para requisições POST com form-data**: Use `-F` no CURL. Para form-urlencoded, use `-d` (que é o padrão neste caso).

---

## 🔧 Expressões Úteis do N8n

- **Usar Session ID em Cookie**: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`
- **Gerar timestamp atual**: `{{ Date.now() }}`
- **Usar CPF de um nó anterior**: `{{ $('Nome do Nó').item.json.cpf }}`

---

## 📁 Arquivos CURL Individuais

Todos os CURLs individuais estão disponíveis na pasta `n8n/curls/`:
- `n8n/curls/01-POST--Acesso-Entrar.sh` - Login
- `n8n/curls/02-POST--Acesso-Entrar.sh` - Login (segunda tentativa)
- ... e assim por diante

Você pode copiar o conteúdo de qualquer arquivo `.sh` e colar no "Import from cURL" do N8n.

---

## ❓ Se algo não funcionar

- Verifique se o Session ID está sendo extraído corretamente
- Confirme que o nó "Inicializar Sessão" está sendo executado ANTES das requisições autenticadas
- Verifique se o Cookie está sendo enviado com o Session ID correto em todas as requisições
- Confirme que a ordem das requisições está correta (seguindo o índice acima)
