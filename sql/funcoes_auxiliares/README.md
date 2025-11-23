# Funções Auxiliares

Funções e consultas extras (não essenciais, mas úteis).

---

## 📁 Arquivos

### `preview.sql`

Visualiza contemplações que seriam geradas **SEM inserir** no banco.

**Instalação:**

```sql
\i sql/funcoes_auxiliares/preview.sql
```

**Uso:**

```sql
-- Ver o que seria gerado
SELECT * FROM preview_contemplacao(871, '3301', '3302');

-- Resumo por grupo
SELECT
    grupo,
    COUNT(*) AS total,
    MAX(qtd_lances_fixos) AS lances_fixos
FROM preview_contemplacao(871, '3301', '3318')
GROUP BY grupo;
```

---

### `remover.sql`

Remove contemplações de uma data específica.

**Instalação:**

```sql
\i sql/funcoes_auxiliares/remover.sql
```

**Uso:**

```sql
-- Ver quantas seriam removidas
SELECT COUNT(*)
FROM contemplacao
WHERE data_contemplacao = '2025-10-31';

-- Remover (CUIDADO!)
SELECT * FROM remover_contemplacoes_por_data('2025-10-31', TRUE);
```

---

### `consultas.sql`

Consultas úteis para relatórios e diagnósticos.

**Não precisa instalar**, apenas copie e execute as consultas que precisar.

**Consultas disponíveis:**

1. Ver contemplações de hoje
2. Resumo por grupo
3. Buscar contemplação específica
4. Ver lances fixos configurados
5. Relatório mensal
6. Exportar para CSV
7. Verificar grupos sem assembleias
8. Estatísticas gerais
9. Grupos mais contemplados
10. Últimas contemplações processadas

---

## 💡 Quando Usar

- **preview.sql**: Sempre antes de processar contemplações novas
- **remover.sql**: Quando processar por engano ou precisar reprocessar
- **consultas.sql**: Para relatórios, diagnósticos e análises

---

## ⚠️ Importante

Estas funções são **opcionais**. O sistema funciona perfeitamente apenas com o `install.sql`.
