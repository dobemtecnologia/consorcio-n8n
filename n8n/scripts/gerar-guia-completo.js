const fs = require('fs');
const path = require('path');

// Mapeamento das requisições (índice -> nome)
const requisicoes = [
  { num: 1, method: 'POST', endpoint: 'Acesso/Entrar', descricao: 'Login inicial' },
  { num: 2, method: 'POST', endpoint: 'Acesso/Entrar', descricao: 'Login (segunda tentativa)' },
  { num: 3, method: 'GET', endpoint: 'Venda/Venda', descricao: 'Buscar dados de venda' },
  { num: 4, method: 'GET', endpoint: 'Venda/BuscaAndamento', descricao: 'Buscar andamento' },
  { num: 5, method: 'GET', endpoint: 'Venda/BuscarModelos', descricao: 'Buscar modelos' },
  { num: 6, method: 'POST', endpoint: 'Venda/BuscaPrazo', descricao: 'Buscar prazo' },
  { num: 7, method: 'POST', endpoint: 'Venda/BuscaPlano', descricao: 'Buscar plano' },
  { num: 8, method: 'POST', endpoint: 'Venda/BuscaMarca', descricao: 'Buscar marca' },
  { num: 9, method: 'POST', endpoint: 'Venda/BuscaBem', descricao: 'Buscar bem' },
  { num: 10, method: 'POST', endpoint: 'Venda/BuscaAndamento', descricao: 'Buscar andamento (POST)' },
  { num: 11, method: 'GET', endpoint: 'Venda/SelecaoGrupo', descricao: 'Seleção de grupo (GET)' },
  { num: 12, method: 'POST', endpoint: 'Venda/SelecaoGrupo', descricao: 'Seleção de grupo (POST)' },
  { num: 13, method: 'GET', endpoint: 'Venda/SelecaoCota', descricao: 'Seleção de cota (GET)' },
  { num: 14, method: 'POST', endpoint: 'Venda/SelecaoCota', descricao: 'Seleção de cota (POST)' },
  { num: 15, method: 'GET', endpoint: 'Venda/DadosBemSelecionadoAndamento', descricao: 'Dados do bem selecionado (GET)' },
  { num: 16, method: 'POST', endpoint: 'Venda/DadosBemSelecionadoAndamento', descricao: 'Dados do bem selecionado (POST)' },
  { num: 17, method: 'GET', endpoint: 'Venda/DadosCliente', descricao: 'Dados do cliente (GET)' },
  { num: 18, method: 'GET', endpoint: 'Venda/BuscarCPF', descricao: 'Buscar CPF' },
  { num: 19, method: 'GET', endpoint: 'ApiVD/cidade/PA', descricao: 'Buscar cidades (PA)' },
  { num: 20, method: 'POST', endpoint: 'Venda/DadosClientePF', descricao: 'Dados do cliente PF (POST)' },
  { num: 21, method: 'GET', endpoint: 'Venda/EnderecoCliente', descricao: 'Endereço do cliente (GET)' },
  { num: 22, method: 'GET', endpoint: 'Venda/BuscarCEP', descricao: 'Buscar CEP (1)' },
  { num: 23, method: 'GET', endpoint: 'Venda/BuscarCEP', descricao: 'Buscar CEP (2)' },
  { num: 24, method: 'GET', endpoint: 'ApiVD/cidade/PA', descricao: 'Buscar cidades (PA) (2)' },
  { num: 25, method: 'GET', endpoint: 'ApiVD/cidade/PA', descricao: 'Buscar cidades (PA) (3)' },
  { num: 26, method: 'POST', endpoint: 'Venda/EnderecoCliente', descricao: 'Endereço do cliente (POST 1)' },
  { num: 27, method: 'POST', endpoint: 'Venda/EnderecoCliente', descricao: 'Endereço do cliente (POST 2)' },
  { num: 28, method: 'GET', endpoint: 'Venda/DadosBancarios', descricao: 'Dados bancários (GET)' },
  { num: 29, method: 'POST', endpoint: 'Venda/DadosBancarios', descricao: 'Dados bancários (POST)' },
  { num: 30, method: 'GET', endpoint: 'Venda/DadosPagamento', descricao: 'Dados de pagamento' },
];

// Caminhos relativos à raiz do projeto
const projectRoot = path.join(__dirname, '../..');
const curlsDir = path.join(projectRoot, 'n8n/curls');
const workflowsDir = path.join(projectRoot, 'n8n/workflows');
const docsDir = path.join(projectRoot, 'n8n/docs');

// Lê todos os CURLs
const curls = [];
const curlFiles = fs.readdirSync(curlsDir).filter(f => f.endsWith('.sh')).sort();

curlFiles.forEach((file, index) => {
  const req = requisicoes[index];
  if (req) {
    const fileName = path.join(curlsDir, file);
    if (fs.existsSync(fileName)) {
      const content = fs.readFileSync(fileName, 'utf8');
      // Extrai apenas o comando curl (remove comentários iniciais e finais)
      const lines = content.split('\n');
      let curlStart = -1;
      let curlEnd = -1;
      for (let i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('curl')) {
          curlStart = i;
          break;
        }
      }
      for (let i = lines.length - 1; i >= 0; i--) {
        if (lines[i].trim() && !lines[i].startsWith('#')) {
          curlEnd = i;
          break;
        }
      }
      if (curlStart !== -1 && curlEnd !== -1) {
        curls.push({
          ...req,
          curl: lines.slice(curlStart, curlEnd + 1).join('\n')
        });
      }
    }
  }
});

console.log(`Encontrados ${curls.length} CURLs`);
console.log('\n=== Gerando guia completo ===\n');

// Gera o guia completo
let guia = `# Passo-a-Passo Completo no N8n - ClickVenda

## 📋 Índice das Requisições

Esta documentação contém **todas as 30 requisições** do fluxo completo, na ordem exata que o navegador executa.

### Setup Inicial (Nós Fixos)

1. **Login** - HTTP Request
2. **Extrair Session ID** - Code
3. **Inicializar Sessão** - HTTP Request (OBRIGATÓRIO!)

### Requisições do Fluxo (Ordem Exata)

`;

curls.forEach((req, index) => {
  const num = index + 1;
  guia += `${num}. **${req.method} ${req.endpoint}** - ${req.descricao}\n`;
});

guia += `\n---

## 🔧 Setup Inicial (Execute APENAS UMA VEZ)

### **Nó 1: HTTP Request - Login**

1. Adicione um nó **HTTP Request** no N8n
2. Clique em **Options** (⚙️) no canto superior direito
3. Selecione **Import from cURL**
4. Cole este comando:

\`\`\`bash
${curls[0].curl}
\`\`\`

5. **Ajuste os valores de CPF e senha** no Body:
   - Vá em **Body** > você verá \`cpf\` e \`senha\`
   - Edite os valores ou use expressões do N8n como \`{{ $json.cpf }}\`

6. **Configure para retornar headers completos**:
   - Vá em **Options** (⚙️)
   - Em **Response**, selecione **Full Response**
   - Isso é necessário para capturar o Session ID

7. Renomeie o nó para: **"Login"**

---

### **Nó 2: Code - Extrair Session ID**

1. Adicione um nó **Code** após o nó de Login
2. Configure o modo como **"Run Once for All Items"**
3. Cole este código JavaScript (arquivo: \`extrair-session-id.js\`):

\`\`\`javascript
`;

const extrairSessionId = fs.readFileSync(path.join(workflowsDir, 'extrair-session-id.js'), 'utf8');
guia += extrairSessionId.replace(/```/g, '');

guia += `\`\`\`

4. Renomeie o nó para: **"Extrair Session ID"**

---

### **Nó 3: HTTP Request - Inicializar Sessão (⚠️ OBRIGATÓRIO!)**

**Este passo é essencial! Sem ele, as requisições subsequentes não funcionam.**

1. Adicione outro nó **HTTP Request** após o nó "Extrair Session ID"
2. Clique em **Options** (⚙️) > **Import from cURL**
3. **IMPORTANTE**: Você precisa acessar a página HTML primeiro. Use este CURL:

\`\`\`bash
curl -X GET "https://clickvenda.app/Venda/EscolherDN/?idLead=&idEquipe=42&idPedidoOrigem=&TipoVenda=Automovel" \\
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \\
  -H "Accept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7" \\
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \\
  -H "Cookie: ASP.NET_SessionId=SEU_SESSION_ID_AQUI"
\`\`\`

4. **Ajuste o Cookie para usar o Session ID do login**:
   - Vá em **Parameters** (Headers)
   - Encontre o campo **"Cookie"**
   - No valor, substitua \`SEU_SESSION_ID_AQUI\` por: \`{{ $('Extrair Session ID').item.json.sessionId }}\`
   - Ou use: \`ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}\`

5. Renomeie o nó para: **"Inicializar Sessão"**

---

## 📦 Todas as Requisições do Fluxo

Agora você pode adicionar as requisições abaixo na ordem exata. **IMPORTANTE**: Todas as requisições autenticadas precisam do Cookie com o Session ID.

`;

curls.slice(1).forEach((req, index) => {
  const num = index + 2; // Começa do 2 porque o primeiro já foi no setup
  guia += `### **Requisição ${num}: ${req.method} ${req.endpoint}**\n\n`;
  guia += `**Descrição**: ${req.descricao}\n\n`;
  guia += `1. Adicione um nó **HTTP Request**\n`;
  guia += `2. Clique em **Options** (⚙️) > **Import from cURL**\n`;
  guia += `3. Cole este comando:\n\n`;
  guia += `\`\`\`bash\n${req.curl}\n\`\`\`\n\n`;
  
  if (req.curl.includes('Cookie') || req.curl.includes('SEU_SESSION_ID_AQUI')) {
    guia += `4. **Ajuste o Cookie** (se necessário):\n`;
    guia += `   - Vá em **Parameters** (Headers)\n`;
    guia += `   - Encontre o campo **"Cookie"**\n`;
    guia += `   - No valor, substitua \`SEU_SESSION_ID_AQUI\` por: \`ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}\`\n\n`;
  }
  
  if (req.curl.includes('?_=')) {
    guia += `5. **Ajuste o timestamp** (opcional):\n`;
    guia += `   - O parâmetro \`_=\` pode ser substituído por \`{{ Date.now() }}\` para gerar timestamp atual\n\n`;
  }
  
  guia += `---\n\n`;
});

guia += `## ⚠️ Pontos Importantes

1. **SEMPRE configure "Full Response" no nó de Login** - necessário para capturar os headers com o Session ID

2. **SEMPRE execute o nó "Inicializar Sessão" após o login** - sem ele, as requisições retornam \`{"status":"logar"}\` em vez de funcionar

3. **Use o mesmo Session ID em todas as requisições subsequentes** - \`{{ $('Extrair Session ID').item.json.sessionId }}\`

4. **Mantenha a ordem dos nós** - A ordem exata importa! Siga a sequência do índice acima.

5. **Para requisições POST com form-data**: Use \`-F\` no CURL. Para form-urlencoded, use \`-d\` (que é o padrão neste caso).

---

## 🔧 Expressões Úteis do N8n

- **Usar Session ID em Cookie**: \`ASP.NET_SessionId={{ $('Extrair Session ID').item.json.sessionId }}\`
- **Gerar timestamp atual**: \`{{ Date.now() }}\`
- **Usar CPF de um nó anterior**: \`{{ $('Nome do Nó').item.json.cpf }}\`

---

## 📁 Arquivos CURL Individuais

Todos os CURLs individuais estão disponíveis na pasta \`curls/\`:
- \`curls/01-POST--Acesso-Entrar.sh\` - Login
- \`curls/02-POST--Acesso-Entrar.sh\` - Login (segunda tentativa)
- ... e assim por diante

Você pode copiar o conteúdo de qualquer arquivo \`.sh\` e colar no "Import from cURL" do N8n.

---

## ❓ Se algo não funcionar

- Verifique se o Session ID está sendo extraído corretamente
- Confirme que o nó "Inicializar Sessão" está sendo executado ANTES das requisições autenticadas
- Verifique se o Cookie está sendo enviado com o Session ID correto em todas as requisições
- Confirme que a ordem das requisições está correta (seguindo o índice acima)
`;

// Salva o guia
const outputPath = path.join(docsDir, 'PASSO-A-PASSO-N8N.md');
fs.writeFileSync(outputPath, guia);
console.log(`✅ Guia completo gerado em ${outputPath}`);

