-- =====================================================
-- FUNÇÃO AUXILIAR: Remover Contemplações
-- =====================================================
-- Remove contemplações de uma data específica
-- =====================================================

CREATE OR REPLACE FUNCTION remover_contemplacoes_por_data(
    p_data_contemplacao DATE,
    p_confirmar BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    total_removido BIGINT,
    grupos_afetados TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
    v_grupos TEXT;
BEGIN
    IF NOT p_confirmar THEN
        RAISE EXCEPTION 'Para remover, passe p_confirmar := TRUE';
    END IF;
    
    -- Buscar informações antes de remover
    SELECT 
        COUNT(*),
        STRING_AGG(DISTINCT g.cd_grupo, ', ' ORDER BY g.cd_grupo)
    INTO v_total, v_grupos
    FROM public.contemplacao c
    LEFT JOIN public.grupo g ON g.id_grupo = c.grupo_id_grupo
    WHERE c.data_contemplacao = p_data_contemplacao;
    
    -- Remover
    DELETE FROM public.contemplacao
    WHERE data_contemplacao = p_data_contemplacao;
    
    total_removido := v_total;
    grupos_afetados := COALESCE(v_grupos, 'Nenhum');
    RETURN NEXT;
END;
$$;

-- =====================================================
-- EXEMPLO DE USO
-- =====================================================

-- Ver o que seria removido
-- SELECT COUNT(*) 
-- FROM contemplacao 
-- WHERE data_contemplacao = '2025-10-31';

-- Remover (CUIDADO!)
-- SELECT * FROM remover_contemplacoes_por_data('2025-10-31', TRUE);




