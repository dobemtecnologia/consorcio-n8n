# Exemplos de Curl - Cadastro Pessoa Física

## 1. Cadastro Completo com Todos os Dados

```bash
curl -X POST http://localhost:8080/api/cadastro-pessoa-fisica \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva Santos",
  "nomeCompletoWS": "JOAO DA SILVA SANTOS",
  "dataNascimento": "1985-03-15",
  "rg": "12.345.678-9",
  "orgaoExpedidor": "SSP",
  "dataExpedicao": "2005-06-20",
  "sexo": "M",
  "valorRendaMensal": 8500.00,
  "nomeMae": "Maria Aparecida da Silva",
  "nomePai": "José Carlos Santos",
  "pessoaExpostaPoliticamente": false,
  "compartilhaDados": true,
  "indicadoPorCPF": "987.654.321-00",
  "indicadoPorNome": "Pedro Oliveira",
  "cpfConjuge": "234.567.890-11",
  "nomeCompletoConjugeReceitaFederal": "ANA PAULA OLIVEIRA SANTOS",
  "nomeCompletoConjuge": "Ana Paula Oliveira Santos",
  "sexoConjuge": "F",
  "rgConjuge": "23.456.789-0",
  "bancoId": 1,
  "agencia": "1234",
  "contaCorrente": "98765-4",
  "possuiDadosBancarios": true,
  "profissaoId": 1,
  "estadoCivilId": 2,
  "ufNaturalidadeSigla": "SP",
  "naturalidadeId": 5000,
  "nacionalidadeSigla": "BRAS",
  "ufOrgaoExpedidorSigla": "SP",
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "numero": "1578",
  "complemento": "Conjunto 1401",
  "bairro": "Bela Vista",
  "cidade": "São Paulo",
  "idCidadeResidencial": "3550308",
  "telResidencial": "(11) 3456-7890",
  "ufSigla": "SP",
  "cepComercial": "01310-200",
  "logradouroComercial": "Rua Augusta",
  "numeroComercial": "2690",
  "complementoComercial": "Sala 801",
  "bairroComercial": "Cerqueira César",
  "idCidadeComercial": "3550308",
  "cidadeComercial": "São Paulo",
  "telComercial": "(11) 3456-7891",
  "ufComercialSigla": "SP",
  "cidadeCelular": "São Paulo",
  "idCidadeCelular": "3550308",
  "celular": "(11) 98765-4321",
  "ufCelularSigla": "SP",
  "idCidadeTelAdicional": "3550308",
  "cidadeTelAdicional": "São Paulo",
  "telAdicional": "(11) 91234-5678",
  "ufTelAdicionalSigla": "SP",
  "usarCorrespondencia": "R",
  "email": "joao.silva@email.com",
  "aceitaSMS": true,
  "aderiuSeguroVidaPrestamista": true,
  "aceitaDivulgarDados": true,
  "aceitaRepresentanteGrupo": false,
  "parcelaComSVP": "R$ 850,00",
  "parcelaSemSVP": "R$ 780,00",
  "svpDiario": "R$ 2,33",
  "planoDiferenciado": false,
  "parcelaDiferenciada": null,
  "qtdaParcelaDiferenciado": null
}'
```

## 2. JSON para Postman (Formato Formatado)

Cole este JSON na aba "Body" > "raw" > "JSON" no Postman:

```json
{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva Santos",
  "nomeCompletoWS": "JOAO DA SILVA SANTOS",
  "dataNascimento": "1985-03-15",
  "rg": "12.345.678-9",
  "orgaoExpedidor": "SSP",
  "dataExpedicao": "2005-06-20",
  "sexo": "M",
  "valorRendaMensal": 8500.0,
  "nomeMae": "Maria Aparecida da Silva",
  "nomePai": "José Carlos Santos",
  "pessoaExpostaPoliticamente": false,
  "compartilhaDados": true,
  "indicadoPorCPF": "987.654.321-00",
  "indicadoPorNome": "Pedro Oliveira",

  "cpfConjuge": "234.567.890-11",
  "nomeCompletoConjugeReceitaFederal": "ANA PAULA OLIVEIRA SANTOS",
  "nomeCompletoConjuge": "Ana Paula Oliveira Santos",
  "sexoConjuge": "F",
  "rgConjuge": "23.456.789-0",

  "bancoId": 1,
  "agencia": "1234",
  "contaCorrente": "98765-4",
  "possuiDadosBancarios": true,

  "profissaoId": 1,
  "estadoCivilId": 2,
  "ufNaturalidadeSigla": "SP",
  "naturalidadeId": 5000,
  "nacionalidadeSigla": "BRAS",
  "ufOrgaoExpedidorSigla": "SP",

  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "numero": "1578",
  "complemento": "Conjunto 1401",
  "bairro": "Bela Vista",
  "cidade": "São Paulo",
  "idCidadeResidencial": "3550308",
  "telResidencial": "(11) 3456-7890",
  "ufSigla": "SP",

  "cepComercial": "01310-200",
  "logradouroComercial": "Rua Augusta",
  "numeroComercial": "2690",
  "complementoComercial": "Sala 801",
  "bairroComercial": "Cerqueira César",
  "idCidadeComercial": "3550308",
  "cidadeComercial": "São Paulo",
  "telComercial": "(11) 3456-7891",
  "ufComercialSigla": "SP",

  "cidadeCelular": "São Paulo",
  "idCidadeCelular": "3550308",
  "celular": "(11) 98765-4321",
  "ufCelularSigla": "SP",

  "idCidadeTelAdicional": "3550308",
  "cidadeTelAdicional": "São Paulo",
  "telAdicional": "(11) 91234-5678",
  "ufTelAdicionalSigla": "SP",

  "usarCorrespondencia": "R",
  "email": "joao.silva@email.com",
  "aceitaSMS": true,
  "aderiuSeguroVidaPrestamista": true,
  "aceitaDivulgarDados": true,
  "aceitaRepresentanteGrupo": false,
  "parcelaComSVP": "R$ 850,00",
  "parcelaSemSVP": "R$ 780,00",
  "svpDiario": "R$ 2,33",
  "planoDiferenciado": false,
  "parcelaDiferenciado": null,
  "qtdaParcelaDiferenciado": null
}
```

## 3. Cadastro Mínimo (Apenas Campos Obrigatórios)

```bash
curl -X POST http://localhost:8080/api/cadastro-pessoa-fisica \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
  "cpf": "111.222.333-44",
  "nomeCompleto": "Maria José da Silva",
  "dataNascimento": "1990-07-20",
  "sexo": "F",
  "estadoCivilId": 1
}'
```

## 4. Cadastro com Cônjuge

```bash
curl -X POST http://localhost:8080/api/cadastro-pessoa-fisica \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
  "cpf": "222.333.444-55",
  "nomeCompleto": "Carlos Eduardo Mendes",
  "dataNascimento": "1988-11-10",
  "sexo": "M",
  "estadoCivilId": 2,
  "valorRendaMensal": 6500.00,
  "cpfConjuge": "333.444.555-66",
  "nomeCompletoConjuge": "Juliana Rodrigues Mendes",
  "sexoConjuge": "F"
}'
```

## 5. Cadastro com Dados Bancários

```bash
curl -X POST http://localhost:8080/api/cadastro-pessoa-fisica \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
  "cpf": "444.555.666-77",
  "nomeCompleto": "Roberto Alves Costa",
  "dataNascimento": "1982-05-30",
  "sexo": "M",
  "estadoCivilId": 1,
  "bancoId": 1,
  "agencia": "5678",
  "contaCorrente": "12345-0",
  "possuiDadosBancarios": true
}'
```

## 6. Cadastro com Endereço Completo

```bash
curl -X POST http://localhost:8080/api/cadastro-pessoa-fisica \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
  "cpf": "555.666.777-88",
  "nomeCompleto": "Fernanda Lima Souza",
  "dataNascimento": "1995-02-14",
  "sexo": "F",
  "estadoCivilId": 1,
  "cep": "22041-001",
  "logradouro": "Avenida Atlântica",
  "numero": "1000",
  "bairro": "Copacabana",
  "cidade": "Rio de Janeiro",
  "ufSigla": "RJ",
  "celular": "(21) 98888-7777",
  "email": "fernanda.lima@email.com"
}'
```

## Configuração do Postman

### Passo 1: Criar Nova Requisição

1. Abra o Postman
2. Clique em "New" > "HTTP Request"
3. Selecione o método **POST**
4. Cole a URL: `http://localhost:8080/api/cadastro-pessoa-fisica`

### Passo 2: Configurar Headers

Na aba "Headers", adicione:

```
Content-Type: application/json
Accept: application/json
```

### Passo 3: Configurar Body

1. Vá para a aba "Body"
2. Selecione "raw"
3. No dropdown ao lado, selecione "JSON"
4. Cole o JSON do exemplo desejado

### Passo 4: Enviar Requisição

Clique em "Send" e veja a resposta!

## Respostas Esperadas

### Sucesso (201 Created)

```json
{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva Santos",
  "dataNascimento": "1985-03-15",
  "sexo": "M"
}
```

### Erro - Campo Obrigatório Faltando (400 Bad Request)

```json
{
  "type": "https://www.jhipster.tech/problem/problem-with-message",
  "title": "Bad Request",
  "status": 400,
  "detail": "Os seguintes campos obrigatórios não foram informados: Data de Nascimento",
  "path": "/api/cadastro-pessoa-fisica",
  "message": "error.camposobrigatorios"
}
```

### Erro - CPF Duplicado (400 Bad Request)

```json
{
  "type": "https://www.jhipster.tech/problem/problem-with-message",
  "title": "Bad Request",
  "status": 400,
  "detail": "Já existe uma pessoa física cadastrada com este CPF",
  "path": "/api/cadastro-pessoa-fisica",
  "message": "error.cpfjacadastrado"
}
```

## Health Check

Para verificar se o endpoint está funcionando:

```bash
curl -X GET http://localhost:8080/api/cadastro-pessoa-fisica/health
```

**Resposta:**

```
Endpoint de cadastro de pessoa física está funcionando
```

## Notas Importantes

### Antes de Testar:

1. **Iniciar a aplicação:**

   ```bash
   ./mvnw spring-boot:run
   ```

2. **Verificar se o banco está rodando:**

   ```bash
   docker-compose -f src/main/docker/postgresql.yml up -d
   ```

3. **Garantir que as tabelas auxiliares têm dados:**
   - Estado Civil (tabela `estado_civil`)
   - Profissão (tabela `profissao`)
   - Banco (tabela `banco`)
   - Estado (tabela `estado`)
   - Nacionalidade (tabela `nacionalidade`)

### IDs que você precisa verificar no banco:

```sql
-- Ver estados civis disponíveis
SELECT * FROM estado_civil;

-- Ver profissões disponíveis
SELECT * FROM profissao;

-- Ver bancos disponíveis
SELECT * FROM banco;

-- Ver estados disponíveis
SELECT * FROM estado;

-- Ver nacionalidades disponíveis
SELECT * FROM nacionalidade;

-- Ver cidades disponíveis
SELECT * FROM cidade WHERE nome = 'São Paulo';
```

### Estados Civis Disponíveis (Pré-carregados):

A tabela `estado_civil` já vem com os seguintes dados:

| ID  | Descrição                 |
| --- | ------------------------- |
| 1   | Solteiro(a)               |
| 2   | Casado(a)                 |
| 3   | Divorciado(a)             |
| 4   | Viúvo(a)                  |
| 5   | União Estável             |
| 6   | Separado(a) Judicialmente |

> 💡 **Dica:** Use `estadoCivilId: 1` para Solteiro(a) ou `estadoCivilId: 2` para Casado(a) nos seus testes.

### Ajustar os IDs no JSON:

Depois de consultar o banco, ajuste os IDs no JSON:

- `estadoCivilId`: Use o ID da tabela `estado_civil` (1 a 6 - ver tabela acima)
- `profissaoId`: Use o ID real da tabela `profissao`
- `bancoId`: Use o ID real da tabela `banco`
- `ufNaturalidadeSigla`: Use a sigla real da tabela `estado` (ex: "SP", "RJ")
- `naturalidadeId`: Use o ID real da tabela `cidade`
- `nacionalidadeSigla`: Use a sigla real da tabela `nacionalidade` (ex: "BRAS")

## Collection do Postman

Você pode importar esta collection no Postman:

```json
{
  "info": {
    "name": "Cadastro Pessoa Física API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Cadastro Completo",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"cpf\": \"123.456.789-00\",\n  \"nomeCompleto\": \"João da Silva Santos\",\n  \"dataNascimento\": \"1985-03-15\",\n  \"sexo\": \"M\",\n  \"estadoCivilId\": 2\n}"
        },
        "url": {
          "raw": "http://localhost:8080/api/cadastro-pessoa-fisica",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "cadastro-pessoa-fisica"]
        }
      }
    },
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": {
          "raw": "http://localhost:8080/api/cadastro-pessoa-fisica/health",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "cadastro-pessoa-fisica", "health"]
        }
      }
    }
  ]
}
```

Salve este JSON em um arquivo `.json` e importe no Postman via "Import" > "File".
