# Regra de Contemplação por Lance Fixo

## Descrição

A contemplação de cotas em um consórcio segue uma regra específica quando há lances fixos no grupo. Quando um número é sorteado em uma assembleia, além da cota sorteada, as cotas imediatamente anteriores são automaticamente contempladas por lance fixo.

## Regra de Negócio

**Se o número sorteado é 40 e há 10 lances fixos:**

- **Cota 40**: Contemplada por SORTEIO
- **Cota 39**: Contemplada por LANCE_FIXO (posição 1)
- **Cota 38**: Contemplada por LANCE_FIXO (posição 2)
- **Cota 37**: Contemplada por LANCE_FIXO (posição 3)
- **...** (continuando)
- **Cota 30**: Contemplada por LANCE_FIXO (posição 10)

## Implementação

### Localização

**Classe**: `com.dobemtecnologia.custom.service.ContemplacaoCustomService`  
**Endpoint REST**: `POST /api/custom/contemplacaos/gerar-por-sorteio`

> ⚠️ **Importante**: Este código está no pacote `custom` e **NÃO será sobrescrito** pelo JHipster.

### Método Principal

```java
public List<ContemplacaoDTO> gerarContemplacoesPorSorteio(
    AssembleiasGrupoDTO assembleia,
    Integer numeroSorteado,
    Integer quantidadeLancesFixos,
    GrupoDTO grupo,
    PlanoDTO plano,
    BemDTO bem,
    LocalDate dataContemplacao
)
```

### Exemplo de Uso via Código Java

```java
@Autowired
private ContemplacaoCustomService contemplacaoCustomService; // ← Usar o serviço CUSTOM

@Autowired
private AssembleiasGrupoService assembleiasGrupoService;

@Autowired
private GrupoService grupoService;

@Autowired
private PlanoService planoService;

@Autowired
private BemService bemService;

public void processarSorteio() {
  // Dados do sorteio
  Long assembleiaId = 1L;
  Integer numeroSorteado = 40;
  Integer quantidadeLancesFixos = 10;

  // Buscar entidades relacionadas
  AssembleiasGrupoDTO assembleia = assembleiasGrupoService.findOne(assembleiaId).get();
  GrupoDTO grupo = grupoService.findOne(assembleia.getGrupo().getIdGrupo()).get();
  PlanoDTO plano = planoService.findOne(grupo.getPlano().getIdPlano()).get();
  BemDTO bem = bemService.findOne(grupo.getBem().getIdBem()).get();

  // Gerar contemplações
  List<ContemplacaoDTO> contemplacoes = contemplacaoCustomService.gerarContemplacoesPorSorteio(
    assembleia,
    numeroSorteado,
    quantidadeLancesFixos,
    grupo,
    plano,
    bem,
    LocalDate.now()
  );

  // Resultado: 11 contemplações criadas (1 sorteio + 10 lances fixos)
  System.out.println("Total de contemplações: " + contemplacoes.size());
}

```

### Exemplo de Uso via API REST

```bash
# Endpoint
POST /api/custom/contemplacaos/gerar-por-sorteio

# Request Body
{
  "assembleia": {
    "id": 1
  },
  "numeroSorteado": 40,
  "quantidadeLancesFixos": 10,
  "grupo": {
    "idGrupo": "GRP001"
  },
  "plano": {
    "idPlano": "PLN001"
  },
  "bem": {
    "idBem": "BEM001"
  },
  "dataContemplacao": "2025-10-17"
}

# Response: Array com 11 contemplações
[
  { "id": 1, "numeroCota": 40, "tipoContemplacao": "SORTEIO", ... },
  { "id": 2, "numeroCota": 39, "tipoContemplacao": "LANCE_FIXO", "posicaoLance": 1, ... },
  { "id": 3, "numeroCota": 38, "tipoContemplacao": "LANCE_FIXO", "posicaoLance": 2, ... },
  ...
]
```

### Exemplo com cURL

```bash
curl -X POST http://localhost:8080/api/custom/contemplacaos/gerar-por-sorteio \
  -H "Content-Type: application/json" \
  -d '{
    "assembleia": { "id": 1 },
    "numeroSorteado": 40,
    "quantidadeLancesFixos": 10,
    "grupo": { "idGrupo": "GRP001" },
    "plano": { "idPlano": "PLN001" },
    "bem": { "idBem": "BEM001" },
    "dataContemplacao": "2025-10-17"
  }'
```

## Fluxo de Processamento

1. **Assembleia Realizada**

   - Número sorteado: 40
   - Quantidade de lances fixos: 10

2. **Sistema Processa Automaticamente**

   - Busca a Cota com numeroCota = 40 do grupo
   - Cria 1 Contemplacao com tipo = SORTEIO
   - Para i de 1 até 10:
     - Busca a Cota com numeroCota = (40 - i)
     - Cria Contemplacao com tipo = LANCE_FIXO e posicaoLance = i

3. **Persistência**
   - Todas as 11 contemplações são salvas no banco de dados
   - Cada contemplação está vinculada à:
     - Assembleia
     - Grupo
     - Plano
     - Bem
     - Cota específica

## Validações

### Número de Cota Inválido

Se durante o processamento de lances fixos o número da cota for <= 0, o sistema:

- Registra um warning no log
- Continua processando as próximas cotas
- Exemplo: Se numeroSorteado = 5 e lancesFixos = 10, apenas as cotas 4, 3, 2, 1 serão contempladas

### Cota Não Encontrada

Se uma cota não existir no grupo:

- Registra um warning no log
- Não cria a contemplação
- Continua processando as próximas cotas

## Estrutura das Entidades

### Contemplacao

```java
{
  "id": 1,
  "dataContemplacao": "2025-10-17",
  "tipoContemplacao": "SORTEIO", // ou "LANCE_FIXO"
  "posicaoLance": null, // ou 1, 2, 3, ..., 10 para lances fixos
  "numeroSorteado": 40,
  "valorLance": null,
  "assembleia": { ... },
  "grupo": { ... },
  "plano": { ... },
  "bem": { ... },
  "cota": { "numeroCota": 40, ... }
}
```

## Repository Customizado

Foi adicionado um método no `CotaRepository` para buscar cotas por grupo e número:

```java
Optional<Cota> findByCdGrupoAndNumeroCota(String cdGrupo, Integer numeroCota);

```

## Logs

O sistema registra logs em diferentes níveis:

- **DEBUG**: Detalhes do processamento
- **INFO**: Total de contemplações geradas
- **WARN**: Problemas encontrados (cota inválida, cota não encontrada)

Exemplo de logs:

```
DEBUG - Request to generate Contemplacoes - numeroSorteado: 40, lancesFixos: 10, grupo: GRP001
DEBUG - Buscando cota - Grupo: GRP001, Número: 40
DEBUG - Buscando cota - Grupo: GRP001, Número: 39
...
INFO  - Geradas 11 contemplações para o grupo GRP001
```

## Tipos de Contemplação

```java
enum TipoContemplacao {
  SORTEIO, // Cota sorteada
  LANCE_FIXO, // Lances fixos automáticos
  LANCE_LIVRE, // Lances livres (futuro)
  LANCE_LIMITADO, // Lances limitados (futuro)
  LANCE_FIDELIDADE, // Lances de fidelidade (futuro)
  SEGUNDO_LANCE_FIXO, // Segundo lance fixo (futuro)
}

```

## Considerações

1. O método é transacional - se houver erro, todas as alterações são revertidas
2. As cotas devem existir previamente no banco de dados
3. O código do grupo (`cdGrupo`) é usado para buscar as cotas
4. A posição do lance fixo começa em 1 (primeira cota após o sorteio)
