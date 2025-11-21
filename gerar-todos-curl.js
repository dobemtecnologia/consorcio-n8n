const fs = require('fs');

const har = JSON.parse(fs.readFileSync('clickvenda.app.har', 'utf8'));
const entries = har.log.entries;

// Cria diretório para os CURLs
if (!fs.existsSync('curls')) {
  fs.mkdirSync('curls');
}

console.log('Gerando CURLs de todas as requisições...\n');

entries.forEach((entry, index) => {
  const req = entry.request;
  const method = req.method;
  let url = req.url;
  
  // Remove query string da URL (será adicionado separadamente se necessário)
  const urlParts = url.split('?');
  const baseUrl = urlParts[0];
  const queryString = urlParts[1];
  
  // Identifica o endpoint
  const endpoint = baseUrl.replace('https://clickvenda.app', '').replace(/[^a-zA-Z0-9]/g, '-') || 'root';
  const endpointName = endpoint.substring(0, 50); // Limita tamanho
  
  // Nome do arquivo
  const num = String(index + 1).padStart(2, '0');
  const fileName = `curls/${num}-${method}-${endpointName}.sh`;
  
  // Constrói o CURL
  let curl = '#!/bin/bash\n\n';
  curl += `# CURL ${num}: ${method} ${baseUrl}\n`;
  curl += '# Importe este CURL no N8n usando: Options > Import from cURL\n';
  
  // URL com query string se existir
  if (queryString) {
    url = `${baseUrl}?${queryString}`;
  } else {
    url = baseUrl;
  }
  
  curl += '\n';
  curl += `curl -X ${method} "${url}"`;
  
  // Headers (exceto alguns)
  const skipHeaders = ['host', 'content-length', 'connection', 'cookie'];
  req.headers.forEach(header => {
    const name = header.name.toLowerCase();
    if (!skipHeaders.includes(name)) {
      curl += ` \\\n  -H "${header.name}: ${header.value}"`;
    }
  });
  
  // Cookie separado (importante!)
  if (req.cookies && req.cookies.length > 0) {
    const cookieValue = req.cookies.map(c => `${c.name}=SEU_SESSION_ID_AQUI`).join('; ');
    curl += ` \\\n  -H "Cookie: ${cookieValue}"`;
  }
  
  // Body
  if (req.postData) {
    const mimeType = req.postData.mimeType || '';
    
    if (mimeType.includes('multipart/form-data') || mimeType.includes('form-data')) {
      // Usa -F para form-data
      if (req.postData.params) {
        req.postData.params.forEach(param => {
          curl += ` \\\n  -F "${param.name}=${param.value}"`;
        });
      }
    } else if (mimeType.includes('application/x-www-form-urlencoded')) {
      // Usa -d para form-urlencoded
      if (req.postData.params) {
        req.postData.params.forEach(param => {
          curl += ` \\\n  -d "${param.name}=${param.value}"`;
        });
      } else if (req.postData.text) {
        curl += ` \\\n  -d "${req.postData.text}"`;
      }
    } else if (req.postData.text) {
      // JSON ou outro formato
      curl += ` \\\n  --data-raw '${req.postData.text.replace(/'/g, "'\\''")}'`;
    }
  }
  
  curl += '\n';
  
  // Adiciona instruções importantes no final
  if (req.cookies && req.cookies.length > 0) {
    curl += '\n# IMPORTANTE: No N8n, substitua SEU_SESSION_ID_AQUI por: {{ $(\'Extrair Session ID\').item.json.sessionId }}';
  }
  
  // Salva o arquivo
  fs.writeFileSync(fileName, curl);
  console.log(`✓ ${fileName}`);
});

console.log(`\n✅ Total: ${entries.length} CURLs gerados!`);

