# Passo-a-Passo no N8n - Autenticação ClickVenda

## ✅ Sequência Completa que Funciona

### **Nó 1: HTTP Request - Login**

1. Adicione um nó **HTTP Request** no N8n
2. Clique em **Options** (⚙️) no canto superior direito
3. Selecione **Import from cURL**
4. Cole este comando:

```bash
curl -X POST "https://clickvenda.app/Acesso/Entrar" \
  -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Accept: */*" \
  -H "Origin: https://clickvenda.app" \
  -H "Referer: https://clickvenda.app/acesso/Entrar" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -d "cpf=00640045200" \
  -d "senha=disal 2026"
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
3. Cole este código JavaScript:

```javascript
// Extrai o Session ID do cookie retornado
const item = $input.first();
const httpResponse = item.json;

// Acessa os headers da resposta
let headers = {};
if (httpResponse.headers) {
  headers = httpResponse.headers;
}

// Procura pelo cookie em diferentes formatos
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
    break;
  }
}

// Retorne SEMPRE um array de objetos (requisito do N8n)
return [
  {
    json: {
      sessionId: sessionId,
      loginSuccess: !!sessionId,
    },
  },
];
```

4. Renomeie o nó para: **"Extrair Session ID"**

---

### **Nó 3: HTTP Request - Inicializar Sessão (IMPORTANTE!)**

**Este passo é essencial! Sem ele, as requisições subsequentes não funcionam.**

1. Adicione outro nó **HTTP Request** após o nó "Extrair Session ID"
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

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

### **Nó 4: HTTP Request - Requisição de Venda**

1. Adicione outro nó **HTTP Request** após o nó "Inicializar Sessão"
2. Clique em **Options** (⚙️) > **Import from cURL**
3. Cole este comando:

```bash
curl -X GET "https://clickvenda.app/Venda/Venda?_=1763745416458" \
  -H "Accept: */*" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Referer: https://clickvenda.app/Venda" \
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI"
```

4. **Ajuste o Cookie**:
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, use: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`

5. **Ajuste o parâmetro `_` (timestamp)**:
   - Vá em **Query String** ou na URL
   - O parâmetro `_=1763745416458` pode ser substituído por `_={{ Date.now() }}` para gerar timestamp atual

6. Renomeie o nó para: **"Requisição Venda"**

---

## 📋 Resumo da Sequência

```
[Login] → [Extrair Session ID] → [Inicializar Sessão] → [Requisição Venda]
   ↓              ↓                       ↓                      ↓
Retorna      Extrai o          Inicializa a          Funciona!
Session ID   Session ID        sessão (essencial!)
```

---

## ⚠️ Pontos Importantes

1. **SEMPRE configure "Full Response" no nó de Login** - necessário para capturar os headers com o Session ID

2. **SEMPRE execute o nó "Inicializar Sessão" após o login** - sem ele, as requisições retornam `{"status":"logar"}` em vez de funcionar

3. **Use o mesmo Session ID em todas as requisições subsequentes** - `{{ $('Extrair Session ID').item.json.sessionId }}`

4. **Mantenha a ordem dos nós** - Login → Extrair Session ID → Inicializar Sessão → Requisições Autenticadas

---

## 🧪 Testando

1. Execute o workflow
2. Verifique que:
   - Nó "Login" retorna `{"status":"logado"}`
   - Nó "Extrair Session ID" mostra `sessionId` preenchido
   - Nó "Inicializar Sessão" executa (pode retornar 302, é normal)
   - Nó "Requisição Venda" retorna `{"success":true,"data":{...}}`

---

## 🔧 Expressões Úteis do N8n

- **Usar Session ID em Cookie**: `ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}`
- **Gerar timestamp atual**: `{{ Date.now() }}`
- **Usar CPF de um nó anterior**: `{{ $('Nome do Nó').item.json.cpf }}`

---

## ❓ Se algo não funcionar

- Verifique se o Session ID está sendo extraído corretamente
- Confirme que o nó "Inicializar Sessão" está sendo executado ANTES das requisições autenticadas
- Verifique se o Cookie está sendo enviado com o Session ID correto em todas as requisições

