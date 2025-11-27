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

