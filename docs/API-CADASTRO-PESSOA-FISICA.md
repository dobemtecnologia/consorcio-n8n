# API - Cadastro de Pessoa Física

## Endpoint Personalizado

**POST** `/api/cadastro-pessoa-fisica`

Endpoint para cadastro completo de pessoa física, incluindo dados pessoais, do cônjuge, bancários e endereço.

> 📝 **Exemplos Práticos:** Veja [EXEMPLOS-CURL-CADASTRO.md](./EXEMPLOS-CURL-CADASTRO.md) para exemplos completos de curl e configuração do Postman.

## Campos Obrigatórios

Os seguintes campos **DEVEM** ser informados:

- `cpf` - CPF da pessoa (formato: 999.999.999-99)
- `nomeCompleto` - Nome completo
- `dataNascimento` - Data de nascimento (formato: YYYY-MM-DD)
- `sexo` - Sexo (M ou F)
- `estadoCivilId` - ID do estado civil

## Exemplo de Requisição

```json
{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva Santos",
  "nomeCompletoWS": "JOAO DA SILVA SANTOS",
  "dataNascimento": "1990-05-15",
  "rg": "12.345.678-9",
  "orgaoExpedidor": "SSP",
  "dataExpedicao": "2010-01-20",
  "sexo": "M",
  "valorRendaMensal": 5000.0,
  "nomeMae": "Maria da Silva",
  "nomePai": "José Santos",
  "pessoaExpostaPoliticamente": false,
  "compartilhaDados": true,

  "estadoCivilId": 2,
  "profissaoId": 15,
  "ufNaturalidadeSigla": "SP",
  "naturalidadeId": 5000,
  "nacionalidadeSigla": "BRAS",
  "ufOrgaoExpedidorSigla": "SP",

  "cpfConjuge": "987.654.321-00",
  "nomeCompletoConjugeReceitaFederal": "MARIA OLIVEIRA SANTOS",
  "nomeCompletoConjuge": "Maria Oliveira Santos",
  "sexoConjuge": "F",
  "rgConjuge": "98.765.432-1",

  "bancoId": 1,
  "agencia": "1234",
  "contaCorrente": "12345-6",
  "possuiDadosBancarios": true,

  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "numero": "1000",
  "complemento": "Apto 101",
  "bairro": "Bela Vista",
  "cidade": "São Paulo",
  "ufSigla": "SP",
  "celular": "(11) 98765-4321",
  "email": "joao.silva@email.com",

  "aceitaSMS": true,
  "aderiuSeguroVidaPrestamista": false,
  "aceitaDivulgarDados": true,
  "aceitaRepresentanteGrupo": false
}
```

## Exemplo de Resposta - Sucesso (201 Created)

```json
{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva Santos",
  "dataNascimento": "1990-05-15",
  "sexo": "M"
}
```

**Headers:**

```
Location: /api/pessoa-fisicas/123.456.789-00
Content-Type: application/json
```

## Exemplos de Erros

### 1. Campos Obrigatórios Faltando

**Status:** 400 Bad Request

```json
{
  "type": "https://www.jhipster.tech/problem/problem-with-message",
  "title": "Bad Request",
  "status": 400,
  "detail": "Os seguintes campos obrigatórios não foram informados: CPF, Data de Nascimento",
  "path": "/api/cadastro-pessoa-fisica",
  "message": "error.camposobrigatorios"
}
```

### 2. CPF Já Cadastrado

**Status:** 400 Bad Request

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

### 3. Estado Civil Inválido

**Status:** 400 Bad Request

```json
{
  "type": "https://www.jhipster.tech/problem/problem-with-message",
  "title": "Bad Request",
  "status": 400,
  "detail": "Estado Civil informado não existe no sistema",
  "path": "/api/cadastro-pessoa-fisica",
  "message": "error.estadocivilinvalido"
}
```

### 4. Profissão Inválida

**Status:** 400 Bad Request

```json
{
  "type": "https://www.jhipster.tech/problem/problem-with-message",
  "title": "Bad Request",
  "status": 400,
  "detail": "Profissão informada não existe no sistema",
  "path": "/api/cadastro-pessoa-fisica",
  "message": "error.profissaoinvalida"
}
```

### 5. Banco Inválido

**Status:** 400 Bad Request

```json
{
  "type": "https://www.jhipster.tech/problem/problem-with-message",
  "title": "Bad Request",
  "status": 400,
  "detail": "Banco informado não existe no sistema",
  "path": "/api/cadastro-pessoa-fisica",
  "message": "error.bancoinvalido"
}
```

## Health Check

**GET** `/api/cadastro-pessoa-fisica/health`

Verifica se o endpoint está funcionando.

**Resposta:** 200 OK

```json
"Endpoint de cadastro de pessoa física está funcionando"
```

## Fluxo de Validação

O endpoint executa as seguintes validações na ordem:

1. **Validação de Campos Obrigatórios**

   - Verifica se CPF, Nome Completo, Data de Nascimento, Sexo e Estado Civil foram informados

2. **Validação de Entidades Relacionadas**

   - Verifica se Estado Civil, Profissão, Banco, UFs e Nacionalidade existem no sistema

3. **Validação de CPF Duplicado**

   - Verifica se já existe pessoa física cadastrada com o CPF informado

4. **Salvamento da Pessoa Física**

   - Salva os dados na tabela `pessoa_fisica`

5. **Salvamento do Endereço**
   - Se houver dados de endereço/contato, salva na tabela `endereco_pf`

## Notas Importantes

- Todos os campos são opcionais, **exceto** os listados em "Campos Obrigatórios"
- O CPF deve ser único no sistema
- Os IDs de entidades relacionadas (estadoCivilId, profissaoId, etc) devem existir no banco de dados
- Os dados do cônjuge são salvos apenas se informados
- Os dados bancários são salvos apenas se informados
- O endereço é criado automaticamente se pelo menos um dos campos de contato (CEP, logradouro, celular) for informado
- O campo `sexo` aceita apenas os valores: `M` (Masculino) ou `F` (Feminino)
- As datas devem estar no formato ISO 8601: `YYYY-MM-DD`

## Integração com Frontend

O endpoint pode ser chamado diretamente do Angular usando o serviço HTTP:

```typescript
cadastrarPessoaFisica(dados: CadastroPessoaFisicaDTO): Observable<PessoaFisicaDTO> {
  return this.http.post<PessoaFisicaDTO>(
    `${this.resourceUrl}/cadastro-pessoa-fisica`,
    dados
  );
}
```
