# Arquitetura de Contemplações Múltiplas

## 📋 Problema Identificado

A arquitetura anterior tinha uma inconsistência: uma **cota provisionada** poderia ter **múltiplas ocorrências** na tabela `cotas_mineradas`, mas o sistema tentava vincular apenas uma única cota (1:1).

### Exemplo do Problema

Quando a cota **39** é provisionada (lance fixo), ela pode existir várias vezes na base minerada:

- Cota 39 → Grupo X → **Plano A** → **Bem B** → Valor R$ 80.000
- Cota 39 → Grupo X → **Plano C** → **Bem D** → Valor R$ 150.000
- Cota 39 → Grupo X → **Plano E** → **Bem F** → Valor R$ 200.000

A mesma cota pode ter **planos e bens diferentes**, resultando em diferentes valores e condições.

---

## ✅ Solução Implementada

### Nova Entidade: Status de Contemplação

Adicionado o enum `StatusContemplacao` para rastrear o ciclo de vida da contemplação:

```java
public enum StatusContemplacao {
  PROVISIONADA, // Criada a partir do sorteio/lance fixo, ainda não vinculada
  ENCONTRADA, // Vinculada com cota(s) minerada(s)
  NAO_ENCONTRADA, // Não existe na base de cotas mineradas
}

```

### Fluxo de Processamento

#### 1️⃣ **Provisionar Contemplações**

Quando ocorre um sorteio (ex: número 40) com 10 lances fixos:

```
Contemplação 1: número=40, tipo=SORTEIO,     status=PROVISIONADA
Contemplação 2: número=39, tipo=LANCE_FIXO,  status=PROVISIONADA
Contemplação 3: número=38, tipo=LANCE_FIXO,  status=PROVISIONADA
...
Contemplação 11: número=30, tipo=LANCE_FIXO, status=PROVISIONADA
```

Todas são criadas com:

- `plano = null`
- `bem = null`
- `status = PROVISIONADA`

#### 2️⃣ **Vincular com Cotas Mineradas**

O método `vincularCotaMinerada()` busca **TODAS** as cotas mineradas correspondentes:

##### Caso A: Nenhuma Cota Encontrada (0)

```
Contemplação: número=39, status=PROVISIONADA
    ↓ (busca na base)
Resultado: 0 cotas encontradas
    ↓
Contemplação: número=39, status=NAO_ENCONTRADA
```

##### Caso B: Uma Cota Encontrada (1)

```
Contemplação: número=39, status=PROVISIONADA
    ↓ (busca na base)
Resultado: 1 cota encontrada (Plano A, Bem B, R$ 80k)
    ↓
Contemplação: número=39, plano=A, bem=B, status=ENCONTRADA
```

##### Caso C: Múltiplas Cotas Encontradas (2+)

```
Contemplação: número=39, status=PROVISIONADA
    ↓ (busca na base)
Resultado: 3 cotas encontradas
    ├─ Cota 1: Plano A, Bem B, R$ 80k
    ├─ Cota 2: Plano C, Bem D, R$ 150k
    └─ Cota 3: Plano E, Bem F, R$ 200k
    ↓
Contemplações resultantes:
    ├─ Contemplação ID 1: número=39, plano=A, bem=B, status=ENCONTRADA  [atualizada]
    ├─ Contemplação ID 2: número=39, plano=C, bem=D, status=ENCONTRADA  [nova]
    └─ Contemplação ID 3: número=39, plano=E, bem=F, status=ENCONTRADA  [nova]
```

A primeira atualiza o registro provisionado, as demais criam **novos registros** (clones).

---

## 🔧 Alterações Técnicas

### 1. JDL (diagrama.jdl)

```jdl
enum StatusContemplacao {
  PROVISIONADA,
  ENCONTRADA,
  NAO_ENCONTRADA
}

entity Contemplacao {
  dataContemplacao LocalDate required,
  tipoContemplacao TipoContemplacao required,
  posicaoLance Integer,
  numeroSorteado Integer,
  valorLance BigDecimal,
  status StatusContemplacao  // ← NOVO CAMPO
}
```

### 2. Repository (CotasMineradasRepository.java)

Adicionado método para buscar **TODAS** as cotas mineradas:

```java
@Query(
  "select distinct cotasMineradas from CotasMineradas cotasMineradas " +
  "left join fetch cotasMineradas.plano " +
  "left join fetch cotasMineradas.bem " +
  "left join fetch cotasMineradas.grupo " +
  "left join fetch cotasMineradas.cotaRel " +
  "where cotasMineradas.cota = :cota and cotasMineradas.cdGrupo = :cdGrupo"
)
List<CotasMineradas> findAllByCotaAndCdGrupoWithRelationships(@Param("cota") String cota, @Param("cdGrupo") String cdGrupo);

```

### 3. Service (ContemplacaoCustomService.java)

#### Método: `criarContemplacao()`

- Define `status = PROVISIONADA` ao criar
- Chama automaticamente `vincularCotaMinerada()`

#### Método: `vincularCotaMinerada()` (reescrito)

- Busca **todas** as cotas mineradas (não apenas uma)
- Implementa lógica de 3 casos (0, 1, múltiplas)
- Cria novos registros quando múltiplas cotas são encontradas

#### Novos métodos auxiliares:

- `atualizarContemplacaoComCotaMinerada()`: atualiza a contemplação provisionada
- `criarContemplacaoClone()`: cria uma nova contemplação para cotas adicionais

---

## 📊 Exemplo Completo

### Entrada: Sorteio

```json
{
  "assembleia": { "id": 1, "numeroSorteado": 40 },
  "grupo": { "cdGrupo": "G123" },
  "quantidadeLancesFixos": 2
}
```

### Passo 1: Provisionar (3 contemplações)

```
ID | Número | Tipo        | Status         | Plano | Bem
---|--------|-------------|----------------|-------|-----
1  | 40     | SORTEIO     | PROVISIONADA   | null  | null
2  | 39     | LANCE_FIXO  | PROVISIONADA   | null  | null
3  | 38     | LANCE_FIXO  | PROVISIONADA   | null  | null
```

### Passo 2: Vincular (buscar na base minerada)

**Busca cota 40:** encontrou 1
**Busca cota 39:** encontrou 3  
**Busca cota 38:** encontrou 0

### Resultado Final

```
ID | Número | Tipo        | Status         | Plano | Bem | Valor
---|--------|-------------|----------------|-------|-----|--------
1  | 40     | SORTEIO     | ENCONTRADA     | P1    | B1  | 100k
2  | 39     | LANCE_FIXO  | ENCONTRADA     | P2    | B2  | 80k
4  | 39     | LANCE_FIXO  | ENCONTRADA     | P3    | B3  | 150k   ← NOVA
5  | 39     | LANCE_FIXO  | ENCONTRADA     | P4    | B4  | 200k   ← NOVA
3  | 38     | LANCE_FIXO  | NAO_ENCONTRADA | null  | null| null
```

---

## 🎯 Benefícios da Nova Arquitetura

### ✅ Vantagens

1. **Completude**: Não perde nenhuma cota minerada
2. **Transparência**: Status claro (provisionada → encontrada/não encontrada)
3. **Rastreabilidade**: Histórico completo do processo
4. **Flexibilidade**: Suporta múltiplas combinações de plano/bem
5. **Sem redundância**: Não cria entidade intermediária desnecessária

### ⚠️ Considerações

- Múltiplas contemplações podem ter o **mesmo número** (com planos/bens diferentes)
- Filtros e relatórios devem considerar o campo `status`
- A quantidade de contemplações pode crescer significativamente

---

## 🚀 Próximos Passos

### 1. Regenerar Entidades a Partir do JDL

```bash
# No diretório raiz do projeto
jhipster import-jdl projeto/diagrama.jdl
```

Isso irá:

- ✅ Criar o enum `StatusContemplacao`
- ✅ Adicionar o campo `status` em `Contemplacao` (entidade, DTO, mapper, etc.)
- ✅ Criar migration do Liquibase para atualizar a tabela no banco
- ✅ Atualizar o frontend (TypeScript models, componentes, etc.)

### 2. Executar Migrations

```bash
# Aplicar mudanças no banco de dados
./mvnw liquibase:update

# Ou simplesmente rodar a aplicação
./mvnw
```

### 3. Compilar e Testar

```bash
# Compilar backend
./mvnw clean install

# Rodar testes
./mvnw test

# Rodar aplicação completa
./mvnw
```

### 4. Testar o Fluxo

1. Criar uma assembleia com sorteio
2. Provisionar contemplações via API
3. Verificar no banco que múltiplas cotas foram criadas
4. Validar os diferentes status (PROVISIONADA, ENCONTRADA, NAO_ENCONTRADA)

---

## 📝 Observações Importantes

### Customizações Protegidas

Todos os arquivos customizados estão no pacote `custom`:

- `ContemplacaoCustomService.java` → pacote `custom.service`
- `CotasMineradasRepository.java` → métodos marcados como CUSTOM

✅ Esses arquivos **NÃO serão sobrescritos** ao executar `jhipster import-jdl`

### Nomenclatura

Os termos escolhidos deixam claro o propósito:

- **PROVISIONADA**: criada pelo sistema, aguardando vinculação
- **ENCONTRADA**: vinculada com sucesso a cota(s) minerada(s)
- **NAO_ENCONTRADA**: não existe na base de cotas mineradas

---

## 📚 Referências

- **Diagrama JDL**: `projeto/diagrama.jdl`
- **Service Custom**: `src/main/java/com/dobemtecnologia/custom/service/ContemplacaoCustomService.java`
- **Repository Custom**: `src/main/java/com/dobemtecnologia/repository/CotasMineradasRepository.java`
- **Enum Status**: `src/main/java/com/dobemtecnologia/domain/enumeration/StatusContemplacao.java`

---

**Data da Implementação**: 22/10/2025  
**Autor**: Sistema de IA (Claude) + Elton Gonçalves  
**Versão**: 1.0
