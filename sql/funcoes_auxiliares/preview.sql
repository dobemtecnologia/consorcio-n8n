-- =====================================================
-- FUNÇÃO AUXILIAR: Preview
-- =====================================================
-- Visualiza contemplações que seriam geradas SEM inserir
-- =====================================================

CREATE OR REPLACE FUNCTION preview_contemplacao(
    p_cota_sorteada INTEGER,
    p_grupo_inicial VARCHAR(20),
    p_grupo_final VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE (
    grupo VARCHAR(20),
    cota INTEGER,
    tipo VARCHAR(20),
    posicao_lance INTEGER,
    qtd_lances_fixos INTEGER
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_grupo_final VARCHAR(20);
    v_grupo RECORD;
    v_qtd_lance_fixo INTEGER;
    v_cota_atual INTEGER;
    v_posicao INTEGER;
BEGIN
    v_grupo_final := COALESCE(p_grupo_final, p_grupo_inicial);
    
    FOR v_grupo IN 
        SELECT g.id_grupo, g.cd_grupo
        FROM public.grupo g
        WHERE g.cd_grupo >= p_grupo_inicial 
          AND g.cd_grupo <= v_grupo_final
        ORDER BY g.cd_grupo
    LOOP
        SELECT COALESCE(ag.qtd_lance_fixo, 0)
        INTO v_qtd_lance_fixo
        FROM public.assembleias_grupo ag
        WHERE ag.grupo_id_grupo = v_grupo.id_grupo
        ORDER BY ag.numero DESC
        LIMIT 1;
        
        -- Sorteio
        grupo := v_grupo.cd_grupo;
        cota := p_cota_sorteada;
        tipo := 'SORTEIO';
        posicao_lance := 0;
        qtd_lances_fixos := v_qtd_lance_fixo;
        RETURN NEXT;
        
        -- Lances fixos
        v_cota_atual := p_cota_sorteada - 1;
        v_posicao := 1;
        
        WHILE v_posicao <= v_qtd_lance_fixo AND v_cota_atual > 0 LOOP
            grupo := v_grupo.cd_grupo;
            cota := v_cota_atual;
            tipo := 'LANCE_FIXO';
            posicao_lance := v_posicao;
            qtd_lances_fixos := v_qtd_lance_fixo;
            RETURN NEXT;
            
            v_cota_atual := v_cota_atual - 1;
            v_posicao := v_posicao + 1;
        END LOOP;
    END LOOP;
END;
$$;

-- =====================================================
-- EXEMPLO DE USO
-- =====================================================

-- Ver o que seria gerado
-- SELECT * FROM preview_contemplacao(871, '3301', '3302');

-- Resumo
-- SELECT 
--     grupo,
--     COUNT(*) AS total,
--     MAX(qtd_lances_fixos) AS lances_fixos
-- FROM preview_contemplacao(871, '3301', '3318')
-- GROUP BY grupo;




