-- =====================================================
-- CONSULTAS ÚTEIS
-- =====================================================

-- =====================================================
-- 1. Ver contemplações de hoje
-- =====================================================

SELECT 
    cota,
    cd_grupo,
    tipo_contemplacao,
    posicao_lance,
    status
FROM v_contemplacoes
WHERE data_contemplacao = CURRENT_DATE
ORDER BY cd_grupo, cota DESC;

-- =====================================================
-- 2. Resumo por grupo
-- =====================================================

SELECT 
    cd_grupo,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE tipo_contemplacao = 'SORTEIO') AS sorteios,
    COUNT(*) FILTER (WHERE tipo_contemplacao = 'LANCE_FIXO') AS lances_fixos,
    MIN(cota) AS menor_cota,
    MAX(cota) AS maior_cota
FROM v_contemplacoes
WHERE data_contemplacao = CURRENT_DATE
GROUP BY cd_grupo
ORDER BY cd_grupo;

-- =====================================================
-- 3. Buscar contemplação específica
-- =====================================================

SELECT *
FROM v_contemplacoes
WHERE cota = 871
  AND cd_grupo = '3301';

-- =====================================================
-- 4. Ver lances fixos configurados por grupo
-- =====================================================

SELECT 
    g.cd_grupo,
    ag.qtd_lance_fixo,
    ag.numero AS assembleia_numero,
    ag.data AS assembleia_data
FROM grupo g
LEFT JOIN LATERAL (
    SELECT qtd_lance_fixo, numero, data
    FROM assembleias_grupo
    WHERE grupo_id_grupo = g.id_grupo
    ORDER BY numero DESC
    LIMIT 1
) ag ON TRUE
WHERE g.cd_grupo BETWEEN '3301' AND '3324'
ORDER BY g.cd_grupo;

-- =====================================================
-- 5. Relatório mensal
-- =====================================================

SELECT 
    TO_CHAR(data_contemplacao, 'DD/MM/YYYY') AS data,
    COUNT(*) AS total,
    COUNT(DISTINCT cd_grupo) AS grupos
FROM v_contemplacoes
WHERE DATE_TRUNC('month', data_contemplacao) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY data_contemplacao
ORDER BY data_contemplacao DESC;

-- =====================================================
-- 6. Exportar para relatório (formato CSV)
-- =====================================================

SELECT 
    TO_CHAR(data_contemplacao, 'DD/MM/YYYY') AS "Data",
    cota AS "Cota",
    cd_grupo AS "Grupo",
    tipo_contemplacao AS "Tipo",
    COALESCE(posicao_lance::TEXT, '-') AS "Posição",
    desc_plano AS "Plano",
    desc_bem AS "Bem",
    TO_CHAR(valor_bem, 'FM999,999,999.00') AS "Valor",
    status AS "Status"
FROM v_contemplacoes
WHERE data_contemplacao = CURRENT_DATE
ORDER BY cd_grupo, cota DESC;

-- =====================================================
-- 7. Verificar grupos sem assembleias
-- =====================================================

SELECT 
    g.cd_grupo,
    g.primeira_assembleia,
    'SEM ASSEMBLEIAS' AS status
FROM grupo g
LEFT JOIN assembleias_grupo ag ON ag.grupo_id_grupo = g.id_grupo
WHERE ag.id IS NULL
ORDER BY g.cd_grupo;

-- =====================================================
-- 8. Estatísticas gerais
-- =====================================================

SELECT 
    COUNT(*) AS total_contemplacoes,
    COUNT(DISTINCT cd_grupo) AS grupos_distintos,
    COUNT(*) FILTER (WHERE tipo_contemplacao = 'SORTEIO') AS total_sorteios,
    COUNT(*) FILTER (WHERE tipo_contemplacao = 'LANCE_FIXO') AS total_lances_fixos,
    MIN(data_contemplacao) AS data_mais_antiga,
    MAX(data_contemplacao) AS data_mais_recente
FROM v_contemplacoes;

-- =====================================================
-- 9. Grupos mais contemplados
-- =====================================================

SELECT 
    cd_grupo,
    COUNT(*) AS total_contemplacoes,
    MAX(data_contemplacao) AS ultima_contemplacao
FROM v_contemplacoes
GROUP BY cd_grupo
ORDER BY total_contemplacoes DESC
LIMIT 20;

-- =====================================================
-- 10. Ver últimas contemplações processadas
-- =====================================================

SELECT 
    cota,
    cd_grupo,
    tipo_contemplacao,
    data_contemplacao
FROM v_contemplacoes
ORDER BY id DESC
LIMIT 50;




