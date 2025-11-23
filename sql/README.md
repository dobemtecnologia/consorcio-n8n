# Sistema de Processamento de Contemplações

Sistema SQL para processar contemplações de consórcio (sorteios + lances fixos) e inserir na tabela `contemplacao`.

---

## ⚡ Início Rápido

```sql
-- 1. Instalar
\i sql/install.sql

-- 2. Processar
CALL processar_lote_contemplacao('[
    {"cota": 871, "grupo_ini": "3301", "grupo_fim": "3302"},
    {"cota": 871, "grupo_ini": "3303", "grupo_fim": "3318"}
]'::jsonb);

-- 3. Consultar
SELECT * FROM v_contemplacoes WHERE data_contemplacao = CURRENT_DATE;
```

---

## 📦 Instalação

### Passo único

Execute o arquivo `install.sql` no seu banco PostgreSQL:

```sql
\i sql/install.sql
```

Ou copie e cole o conteúdo completo do arquivo no seu cliente SQL.

**Isso irá criar:**

- Sequence `contemplacao_id_seq`
- 4 índices
- 1 view `v_contemplacoes`
- 2 funções: `processar_contemplacao()` e `processar_lote_contemplacao()`

---

## 🚀 Como Usar

### Uso Básico

```sql
-- Processar uma cota sorteada
SELECT * FROM processar_contemplacao(871, '3301');

-- Processar range de grupos
SELECT * FROM processar_contemplacao(871, '3301', '3302');
```

### Processar Múltiplos Sorteios

```sql
CALL processar_lote_contemplacao('[
    {"cota": 871, "grupo_ini": "3301", "grupo_fim": "3302"},
    {"cota": 871, "grupo_ini": "3303", "grupo_fim": "3318"},
    {"cota": 8871, "grupo_ini": "3319", "grupo_fim": "3324"}
]'::jsonb);
```

### Consultar Resultados

```sql
-- Ver contemplações de hoje
SELECT * FROM v_contemplacoes
WHERE data_contemplacao = CURRENT_DATE
ORDER BY cd_grupo, cota DESC;

-- Buscar contemplação específica
SELECT * FROM v_contemplacoes
WHERE cota = 871 AND cd_grupo = '3301';
```

---

## 📋 Funções Disponíveis

### `processar_contemplacao(cota, grupo_ini, grupo_fim, data)`

Processa contemplações para uma cota e range de grupos.

**Parâmetros:**

- `cota` (INTEGER) - Número da cota sorteada
- `grupo_ini` (VARCHAR) - Código do grupo inicial
- `grupo_fim` (VARCHAR, opcional) - Código do grupo final
- `data` (DATE, opcional) - Data da contemplação (default: hoje)

**Exemplo:**

```sql
SELECT * FROM processar_contemplacao(871, '3301', '3318');
```

### `processar_lote_contemplacao(sorteios, data)`

Processa múltiplos sorteios de uma vez.

**Parâmetros:**

- `sorteios` (JSONB) - Array JSON com sorteios
- `data` (DATE, opcional) - Data da contemplação (default: hoje)

**Formato JSON:**

```json
[
  { "cota": 871, "grupo_ini": "3301", "grupo_fim": "3302" },
  { "cota": 1523, "grupo_ini": "4401", "grupo_fim": "4410" }
]
```

**Exemplo:**

```sql
CALL processar_lote_contemplacao('[
    {"cota": 871, "grupo_ini": "3301", "grupo_fim": "3302"}
]'::jsonb);
```

---

## 📊 View Disponível

### `v_contemplacoes`

View com informações completas das contemplações incluindo dados de grupo, plano e bem.

**Colunas:**

- `id` - ID da contemplação
- `data_contemplacao` - Data
- `tipo_contemplacao` - SORTEIO ou LANCE_FIXO
- `posicao_lance` - Posição (0 = sorteio, 1+ = lance fixo)
- `cota` - Número da cota
- `status` - Status da contemplação
- `cd_grupo` - Código do grupo
- `cd_plano` - Código do plano
- `desc_plano` - Descrição do plano
- `cd_bem` - Código do bem
- `desc_bem` - Descrição do bem
- `valor_bem` - Valor do bem

**Exemplo:**

```sql
SELECT cota, cd_grupo, tipo_contemplacao, valor_bem
FROM v_contemplacoes
WHERE data_contemplacao >= '2025-10-01';
```

---

## 🎯 Como Funciona

### Regra de Negócio

1. **Cota Sorteada** → Inserida com tipo `SORTEIO`
2. **Busca Lances Fixos** → Na tabela `assembleias_grupo` (campo `qtd_lance_fixo`)
3. **Gera Lances Fixos** → Decrementando a partir da cota sorteada
4. **Insere Tudo** → Na tabela `contemplacao`

### Exemplo

**Entrada:**

- Cota: 871
- Grupo: 3301
- Lances fixos do grupo: 5

**Resultado na tabela `contemplacao`:**

| cota | tipo_contemplacao | posicao_lance | grupo |
| ---- | ----------------- | ------------- | ----- |
| 871  | SORTEIO           | 0             | 3301  |
| 870  | LANCE_FIXO        | 1             | 3301  |
| 869  | LANCE_FIXO        | 2             | 3301  |
| 868  | LANCE_FIXO        | 3             | 3301  |
| 867  | LANCE_FIXO        | 4             | 3301  |
| 866  | LANCE_FIXO        | 5             | 3301  |

---

## 📁 Estrutura

```
sql/
├── install.sql                 # Arquivo de instalação (execute este)
├── README.md                   # Este arquivo
└── funcoes_auxiliares/         # Funções extras (opcional)
    ├── preview.sql             # Visualizar antes de inserir
    ├── remover.sql             # Remover contemplações
    └── consultas.sql           # Consultas úteis
```

---

## ⚠️ Observações

1. **Sequence**: O sistema usa `contemplacao_id_seq` para gerar IDs
2. **Bem/Plano**: A função pega o primeiro bem/plano disponível. Ajuste se necessário.
3. **Cota FK**: O campo `cota_id_cota` será NULL se a cota não existir na tabela `cota`
4. **Duplicatas**: Usa `ON CONFLICT DO NOTHING` para evitar duplicatas

---

## 🔧 Consultas Úteis

```sql
-- Ver contemplações de hoje
SELECT * FROM v_contemplacoes
WHERE data_contemplacao = CURRENT_DATE;

-- Contar por grupo
SELECT cd_grupo, COUNT(*)
FROM v_contemplacoes
GROUP BY cd_grupo;

-- Buscar cota específica
SELECT * FROM v_contemplacoes
WHERE cota = 871 AND cd_grupo = '3301';

-- Ver lances fixos configurados
SELECT g.cd_grupo, ag.qtd_lance_fixo
FROM grupo g
LEFT JOIN LATERAL (
    SELECT qtd_lance_fixo
    FROM assembleias_grupo
    WHERE grupo_id_grupo = g.id_grupo
    ORDER BY numero DESC LIMIT 1
) ag ON TRUE
ORDER BY g.cd_grupo;
```

---

## 📞 Funções Auxiliares

Funções extras estão na pasta `funcoes_auxiliares/` (opcional):

- **preview.sql** - Ver o que seria inserido sem inserir
- **remover.sql** - Remover contemplações de uma data
- **consultas.sql** - Consultas de diagnóstico e relatórios

Execute conforme necessário:

```sql
\i sql/funcoes_auxiliares/preview.sql
```

---

**Versão**: 1.0  
**Data**: Outubro 2025
