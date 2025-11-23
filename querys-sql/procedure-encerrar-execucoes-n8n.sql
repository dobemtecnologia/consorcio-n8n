-- ============================================================================
-- STORED PROCEDURE: ENCERRAR EXECUÇÕES NO N8N
-- ============================================================================
-- 
-- Esta procedure permite encerrar execuções em andamento no n8n de forma
-- segura e controlada, com diferentes opções de filtro e status.
--
-- ⚠️ IMPORTANTE: 
-- - Faça backup do banco antes de criar/executar procedures
-- - Ajuste o nome da tabela se necessário (execution_entity ou executions)
--
-- ============================================================================

-- ============================================================================
-- PROCEDURE PRINCIPAL: encerrar_execucoes_n8n
-- ============================================================================

CREATE OR REPLACE FUNCTION encerrar_execucoes_n8n(
    p_workflow_id TEXT DEFAULT NULL,           -- ID do workflow específico (NULL = todos)
    p_status_final TEXT DEFAULT 'canceled',     -- 'canceled' ou 'error'
    p_horas_antigas INTEGER DEFAULT NULL,       -- Cancelar apenas execuções mais antigas que X horas (NULL = todas)
    p_modo_dry_run BOOLEAN DEFAULT FALSE       -- TRUE = apenas simular, FALSE = executar
)
RETURNS TABLE (
    total_afetadas BIGINT,
    status_anterior TEXT,
    status_novo TEXT,
    mensagem TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_afetadas BIGINT;
    v_status_condicao TEXT;
    v_mensagem TEXT;
    v_status_anterior TEXT;
BEGIN
    -- Validação do status final
    IF p_status_final NOT IN ('canceled', 'error') THEN
        RAISE EXCEPTION 'Status final inválido. Use "canceled" ou "error"';
    END IF;
    
    -- Construir condição WHERE
    v_status_condicao := 'finished = false OR status IN (''running'', ''waiting'', ''new'')';
    
    -- Adicionar filtro por workflow se fornecido
    IF p_workflow_id IS NOT NULL THEN
        v_status_condicao := v_status_condicao || ' AND workflow_id = ''' || p_workflow_id || '''';
    END IF;
    
    -- Adicionar filtro por horas se fornecido
    IF p_horas_antigas IS NOT NULL AND p_horas_antigas > 0 THEN
        v_status_condicao := v_status_condicao || ' AND started_at < NOW() - INTERVAL ''' || p_horas_antigas || ' hours''';
    END IF;
    
    -- Contar execuções que serão afetadas
    EXECUTE format('
        SELECT COUNT(*)
        FROM execution_entity
        WHERE %s
    ', v_status_condicao) INTO v_total_afetadas;
    
    -- Se modo dry_run, apenas retornar informações
    IF p_modo_dry_run THEN
        v_mensagem := 'MODO SIMULAÇÃO: ' || v_total_afetadas || ' execuções seriam afetadas';
        RETURN QUERY SELECT 
            v_total_afetadas,
            'running/waiting/new'::TEXT,
            p_status_final,
            v_mensagem;
        RETURN;
    END IF;
    
    -- Executar o UPDATE
    EXECUTE format('
        UPDATE execution_entity
        SET 
            finished = true,
            status = %L
        WHERE %s
    ', p_status_final, v_status_condicao);
    
    -- Retornar resultado
    v_mensagem := 'Executado com sucesso: ' || v_total_afetadas || ' execuções foram encerradas';
    
    RETURN QUERY SELECT 
        v_total_afetadas,
        'running/waiting/new'::TEXT,
        p_status_final,
        v_mensagem;
        
EXCEPTION
    WHEN OTHERS THEN
        v_mensagem := 'ERRO: ' || SQLERRM;
        RETURN QUERY SELECT 
            0::BIGINT,
            NULL::TEXT,
            NULL::TEXT,
            v_mensagem;
END;
$$;


-- ============================================================================
-- PROCEDURE AUXILIAR: verificar_execucoes_em_andamento
-- ============================================================================

CREATE OR REPLACE FUNCTION verificar_execucoes_em_andamento(
    p_workflow_id TEXT DEFAULT NULL
)
RETURNS TABLE (
    total BIGINT,
    status TEXT,
    finished BOOLEAN,
    workflow_id TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_workflow_id IS NOT NULL THEN
        RETURN QUERY
        SELECT 
            COUNT(*)::BIGINT,
            e.status::TEXT,
            e.finished,
            e.workflow_id::TEXT
        FROM 
            execution_entity e
        WHERE 
            (e.finished = false OR e.status IN ('running', 'waiting', 'new'))
            AND e.workflow_id = p_workflow_id
        GROUP BY 
            e.status, e.finished, e.workflow_id
        ORDER BY 
            e.status;
    ELSE
        RETURN QUERY
        SELECT 
            COUNT(*)::BIGINT,
            e.status::TEXT,
            e.finished,
            NULL::TEXT as workflow_id
        FROM 
            execution_entity e
        WHERE 
            e.finished = false OR e.status IN ('running', 'waiting', 'new')
        GROUP BY 
            e.status, e.finished
        ORDER BY 
            e.status;
    END IF;
END;
$$;


-- ============================================================================
-- PROCEDURE AUXILIAR: limpar_execucoes_antigas
-- ============================================================================

CREATE OR REPLACE FUNCTION limpar_execucoes_antigas(
    p_dias INTEGER DEFAULT 30,
    p_modo_dry_run BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    total_deletadas BIGINT,
    mensagem TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_deletadas BIGINT;
    v_mensagem TEXT;
BEGIN
    -- Validar dias
    IF p_dias IS NULL OR p_dias < 1 THEN
        RAISE EXCEPTION 'Número de dias deve ser maior que 0';
    END IF;
    
    -- Contar execuções que serão deletadas
    SELECT COUNT(*)
    INTO v_total_deletadas
    FROM execution_entity
    WHERE 
        finished = true
        AND started_at < NOW() - (p_dias || ' days')::INTERVAL;
    
    -- Se modo dry_run, apenas retornar informações
    IF p_modo_dry_run THEN
        v_mensagem := 'MODO SIMULAÇÃO: ' || v_total_deletadas || ' execuções seriam deletadas';
        RETURN QUERY SELECT 
            v_total_deletadas,
            v_mensagem;
        RETURN;
    END IF;
    
    -- Executar DELETE
    DELETE FROM execution_entity
    WHERE 
        finished = true
        AND started_at < NOW() - (p_dias || ' days')::INTERVAL;
    
    v_mensagem := 'Executado com sucesso: ' || v_total_deletadas || ' execuções foram deletadas';
    
    RETURN QUERY SELECT 
        v_total_deletadas,
        v_mensagem;
        
EXCEPTION
    WHEN OTHERS THEN
        v_mensagem := 'ERRO: ' || SQLERRM;
        RETURN QUERY SELECT 
            0::BIGINT,
            v_mensagem;
END;
$$;


-- ============================================================================
-- EXEMPLOS DE USO
-- ============================================================================

-- 1. Verificar execuções em andamento (todas)
-- SELECT * FROM verificar_execucoes_em_andamento();

-- 2. Verificar execuções de um workflow específico
-- SELECT * FROM verificar_execucoes_em_andamento('WORKFLOW_ID_AQUI');

-- 3. SIMULAR cancelamento de todas as execuções (não executa, apenas mostra)
-- SELECT * FROM encerrar_execucoes_n8n(
--     p_workflow_id := NULL,
--     p_status_final := 'canceled',
--     p_horas_antigas := NULL,
--     p_modo_dry_run := TRUE
-- );

-- 4. CANCELAR todas as execuções em andamento
-- SELECT * FROM encerrar_execucoes_n8n(
--     p_workflow_id := NULL,
--     p_status_final := 'canceled',
--     p_horas_antigas := NULL,
--     p_modo_dry_run := FALSE
-- );

-- 5. CANCELAR execuções de um workflow específico
-- SELECT * FROM encerrar_execucoes_n8n(
--     p_workflow_id := 'WORKFLOW_ID_AQUI',
--     p_status_final := 'canceled',
--     p_horas_antigas := NULL,
--     p_modo_dry_run := FALSE
-- );

-- 6. CANCELAR apenas execuções mais antigas que 2 horas
-- SELECT * FROM encerrar_execucoes_n8n(
--     p_workflow_id := NULL,
--     p_status_final := 'canceled',
--     p_horas_antigas := 2,
--     p_modo_dry_run := FALSE
-- );

-- 7. MARCAR como ERRO em vez de cancelado
-- SELECT * FROM encerrar_execucoes_n8n(
--     p_workflow_id := NULL,
--     p_status_final := 'error',
--     p_horas_antigas := NULL,
--     p_modo_dry_run := FALSE
-- );

-- 8. SIMULAR limpeza de execuções antigas (30 dias)
-- SELECT * FROM limpar_execucoes_antigas(
--     p_dias := 30,
--     p_modo_dry_run := TRUE
-- );

-- 9. DELETAR execuções antigas (30 dias)
-- SELECT * FROM limpar_execucoes_antigas(
--     p_dias := 30,
--     p_modo_dry_run := FALSE
-- );


-- ============================================================================
-- QUERY RÁPIDA - USO MAIS COMUM
-- ============================================================================

-- Verificar antes de cancelar
-- SELECT * FROM verificar_execucoes_em_andamento();

-- Cancelar todas (descomente para executar)
-- SELECT * FROM encerrar_execucoes_n8n();


-- ============================================================================
-- REMOVER PROCEDURES (se necessário)
-- ============================================================================

-- DROP FUNCTION IF EXISTS encerrar_execucoes_n8n(TEXT, TEXT, INTEGER, BOOLEAN);
-- DROP FUNCTION IF EXISTS verificar_execucoes_em_andamento(TEXT);
-- DROP FUNCTION IF EXISTS limpar_execucoes_antigas(INTEGER, BOOLEAN);


-- ============================================================================
-- NOTAS
-- ============================================================================
-- 
-- Parâmetros da função encerrar_execucoes_n8n:
-- - p_workflow_id: NULL = todas as execuções, ou ID específico do workflow
-- - p_status_final: 'canceled' ou 'error'
-- - p_horas_antigas: NULL = todas, ou número de horas (ex: 2 = apenas > 2 horas)
-- - p_modo_dry_run: TRUE = simular sem executar, FALSE = executar de verdade
--
-- A função retorna:
-- - total_afetadas: Quantidade de execuções afetadas
-- - status_anterior: Status anterior das execuções
-- - status_novo: Novo status aplicado
-- - mensagem: Mensagem descritiva do resultado
--
-- ============================================================================

