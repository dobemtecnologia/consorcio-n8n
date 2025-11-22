-- ============================================================================
-- ENCERRAR EXECUÇÕES NO N8N VIA BANCO DE DADOS
-- ============================================================================
-- 
-- Este arquivo contém todas as queries necessárias para encerrar execuções
-- em andamento no n8n diretamente pelo banco de dados.
--
-- ⚠️ IMPORTANTE: 
-- - Faça backup do banco antes de executar qualquer UPDATE ou DELETE
-- - Ajuste o nome da tabela se necessário:
--   - Versões novas: execution_entity
--   - Versões antigas: executions
--
-- ============================================================================

-- ============================================================================
-- PARTE 1: VERIFICAR ESTRUTURA DA TABELA (OPCIONAL)
-- ============================================================================
-- Execute esta query primeiro se quiser verificar quais colunas existem

-- Ver todas as colunas da tabela execution_entity
SELECT 
    column_name,
    data_type,
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_schema = 'public'
    AND table_name = 'execution_entity'
ORDER BY 
    ordinal_position;

-- Ver um registro de exemplo
-- SELECT * FROM execution_entity LIMIT 1;


-- ============================================================================
-- PARTE 2: VERIFICAR EXECUÇÕES EM ANDAMENTO
-- ============================================================================

-- Contar execuções em andamento por status
SELECT 
    COUNT(*) as total_para_cancelar,
    status,
    finished
FROM 
    execution_entity
WHERE 
    finished = false
    OR status IN ('running', 'waiting', 'new')
GROUP BY 
    status, finished
ORDER BY 
    status;

-- Ver detalhes das execuções em andamento
SELECT 
    id,
    workflow_id,
    mode,
    started_at,
    finished,
    status
FROM 
    execution_entity
WHERE 
    finished = false
    OR status IN ('running', 'waiting', 'new')
ORDER BY 
    started_at DESC
LIMIT 20;


-- ============================================================================
-- PARTE 3: ENCERRAR TODAS AS EXECUÇÕES EM ANDAMENTO
-- ============================================================================
-- ⚠️ ATENÇÃO: Esta query irá cancelar TODAS as execuções em andamento!

-- CANCELAR TODAS (descomente para executar)
-- UPDATE execution_entity
-- SET 
--     finished = true,
--     status = 'canceled'
-- WHERE 
--     finished = false
--     OR status IN ('running', 'waiting', 'new');

-- ALTERNATIVA: Marcar como erro em vez de cancelado
-- UPDATE execution_entity
-- SET 
--     finished = true,
--     status = 'error'
-- WHERE 
--     finished = false
--     OR status IN ('running', 'waiting', 'new');


-- ============================================================================
-- PARTE 4: ENCERRAR EXECUÇÕES DE UM WORKFLOW ESPECÍFICO
-- ============================================================================
-- Substitua 'WORKFLOW_ID_AQUI' pelo ID do workflow desejado

-- Ver execuções de um workflow específico
-- SELECT 
--     id,
--     workflow_id,
--     started_at,
--     finished,
--     status
-- FROM 
--     execution_entity
-- WHERE 
--     workflow_id = 'WORKFLOW_ID_AQUI'
--     AND (finished = false OR status IN ('running', 'waiting', 'new'))
-- ORDER BY 
--     started_at DESC;

-- Cancelar execuções de um workflow específico
-- UPDATE execution_entity
-- SET 
--     finished = true,
--     status = 'canceled'
-- WHERE 
--     workflow_id = 'WORKFLOW_ID_AQUI'
--     AND (finished = false OR status IN ('running', 'waiting', 'new'));


-- ============================================================================
-- PARTE 5: ENCERRAR EXECUÇÕES MAIS ANTIGAS QUE X HORAS
-- ============================================================================
-- Substitua '2' pelo número de horas desejado

-- Ver execuções antigas
-- SELECT 
--     id,
--     workflow_id,
--     started_at,
--     finished,
--     status,
--     NOW() - started_at as tempo_decorrido
-- FROM 
--     execution_entity
-- WHERE 
--     (finished = false OR status IN ('running', 'waiting', 'new'))
--     AND started_at < NOW() - INTERVAL '2 hours'
-- ORDER BY 
--     started_at ASC;

-- Cancelar execuções antigas
-- UPDATE execution_entity
-- SET 
--     finished = true,
--     status = 'canceled'
-- WHERE 
--     (finished = false OR status IN ('running', 'waiting', 'new'))
--     AND started_at < NOW() - INTERVAL '2 hours';


-- ============================================================================
-- PARTE 6: VERIFICAR RESULTADO APÓS CANCELAR
-- ============================================================================

-- Ver execuções canceladas recentemente
SELECT 
    COUNT(*) as total_canceladas,
    status
FROM 
    execution_entity
WHERE 
    status = 'canceled'
    AND finished = true
    AND started_at >= NOW() - INTERVAL '5 minutes'
GROUP BY 
    status;

-- Ver todas as execuções canceladas
SELECT 
    COUNT(*) as total_canceladas,
    status
FROM 
    execution_entity
WHERE 
    status = 'canceled'
    AND finished = true
GROUP BY 
    status;


-- ============================================================================
-- PARTE 7: LIMPAR EXECUÇÕES ANTIGAS (OPCIONAL - CUIDADO!)
-- ============================================================================
-- ⚠️ ATENÇÃO: Esta query DELETA execuções permanentemente!
-- Use apenas se quiser limpar o histórico de execuções antigas

-- Ver quantas execuções serão deletadas
-- SELECT 
--     COUNT(*) as total_para_deletar
-- FROM 
--     execution_entity
-- WHERE 
--     finished = true
--     AND started_at < NOW() - INTERVAL '30 days';

-- DELETAR execuções antigas (descomente para executar)
-- DELETE FROM execution_entity
-- WHERE 
--     finished = true
--     AND started_at < NOW() - INTERVAL '30 days';


-- ============================================================================
-- PARTE 8: QUERY RÁPIDA - TUDO EM UM (COPY & PASTE)
-- ============================================================================
-- Use esta seção para executar tudo de uma vez

-- 1. Verificar
SELECT COUNT(*) as total_em_andamento FROM execution_entity 
WHERE finished = false OR status IN ('running', 'waiting', 'new');

-- 2. Cancelar (descomente para executar)
-- UPDATE execution_entity
-- SET finished = true, status = 'canceled'
-- WHERE finished = false OR status IN ('running', 'waiting', 'new');

-- 3. Verificar resultado
-- SELECT COUNT(*) as total_canceladas FROM execution_entity 
-- WHERE status = 'canceled' AND finished = true;


-- ============================================================================
-- NOTAS E INFORMAÇÕES ÚTEIS
-- ============================================================================
-- 
-- Status possíveis no n8n:
-- - 'new': Execução criada mas ainda não iniciada
-- - 'running': Execução em andamento
-- - 'waiting': Execução aguardando (ex: aguardando webhook)
-- - 'success': Execução concluída com sucesso
-- - 'error': Execução falhou
-- - 'canceled': Execução cancelada
--
-- Para MySQL/MariaDB:
-- - Substitua INTERVAL 'X hours' por INTERVAL X HOUR
-- - Remova 'public.' do schema se necessário
--
-- Para SQLite:
-- - Substitua NOW() por datetime('now')
-- - Substitua INTERVAL 'X hours' por datetime('now', '-X hours')
-- - Substitua false por 0 e true por 1
--
-- ============================================================================

