-- ============================================================================
-- SCRIPT: DESCOBRIR TABELA DE EXECUÇÕES DO N8N
-- ============================================================================
-- 
-- Este script lista todas as tabelas disponíveis no banco de dados,
-- com foco especial em tabelas relacionadas a execuções do N8N.
--
-- Execute este script para identificar o nome correto da tabela de execuções
-- antes de usar as procedures de encerramento.
--
-- ============================================================================

-- Listar TODAS as tabelas do banco de dados
SELECT 
    table_schema,
    table_name,
    'Todas as tabelas' as categoria
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

-- Separador visual
SELECT '============================================================================' as separador;

-- Listar tabelas que podem ser de execuções (busca por nome)
SELECT 
    table_schema,
    table_name,
    'Possíveis tabelas de execuções' as categoria
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
AND (
    table_name ILIKE '%execution%' 
    OR table_name ILIKE '%exec%'
    OR table_name ILIKE '%run%'
    OR table_name ILIKE '%workflow%'
)
ORDER BY table_schema, table_name;

-- Separador visual
SELECT '============================================================================' as separador;

-- Verificar especificamente as tabelas conhecidas do N8N
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = 'execution_entity'
        ) THEN '✓ ENCONTRADA: execution_entity (schema: public)'
        ELSE '✗ NÃO ENCONTRADA: execution_entity (schema: public)'
    END as status_execution_entity,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = 'executions'
        ) THEN '✓ ENCONTRADA: executions (schema: public)'
        ELSE '✗ NÃO ENCONTRADA: executions (schema: public)'
    END as status_executions;

-- Separador visual
SELECT '============================================================================' as separador;

-- Listar schemas disponíveis
SELECT 
    schema_name,
    'Schema disponível' as tipo
FROM information_schema.schemata
WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY schema_name;

-- Separador visual
SELECT '============================================================================' as separador;

-- Buscar tabelas de execuções em TODOS os schemas (não apenas public)
SELECT 
    table_schema,
    table_name,
    'Tabelas de execuções em todos os schemas' as categoria
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
AND (
    table_name ILIKE '%execution%' 
    OR table_name ILIKE '%exec%'
)
AND table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY table_schema, table_name;

