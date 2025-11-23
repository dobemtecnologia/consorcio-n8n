-- =====================================================
-- INSTALAÇÃO - Sistema de Contemplações
-- =====================================================
-- Execute este arquivo completo no seu banco PostgreSQL
-- =====================================================

-- =====================================================
-- 1. SEQUENCE
-- =====================================================

CREATE SEQUENCE IF NOT EXISTS contemplacao_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE contemplacao_id_seq OWNER TO postgres;

-- =====================================================
-- 2. ÍNDICES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_contemplacao_data 
    ON public.contemplacao(data_contemplacao);

CREATE INDEX IF NOT EXISTS idx_contemplacao_grupo 
    ON public.contemplacao(grupo_id_grupo);

CREATE INDEX IF NOT EXISTS idx_contemplacao_data_grupo 
    ON public.contemplacao(data_contemplacao, grupo_id_grupo);

CREATE INDEX IF NOT EXISTS idx_contemplacao_numero_sorteado 
    ON public.contemplacao(numero_sorteado);

-- =====================================================
-- 3. VIEW
-- =====================================================

DROP VIEW IF EXISTS v_contemplacoes;

CREATE VIEW v_contemplacoes AS
SELECT 
    c.id,
    c.data_contemplacao,
    c.tipo_contemplacao,
    c.posicao_lance,
    c.numero_sorteado AS cota,
    c.status,
    c.assembleia_id,
    g.cd_grupo,
    p.cd_plano,
    p.desc_plano,
    b.cd_bem,
    b.desc_bem,
    b.vlr_cred_integral AS valor_bem
FROM public.contemplacao c
LEFT JOIN public.grupo g ON g.id_grupo = c.grupo_id_grupo
LEFT JOIN public.plano p ON p.id_plano = c.plano_id_plano
LEFT JOIN public.bem b ON b.id_bem = c.bem_id_bem;

-- =====================================================
-- 4. FUNÇÃO PRINCIPAL
-- =====================================================

CREATE OR REPLACE FUNCTION processar_contemplacao(
    p_cota_sorteada INTEGER,
    p_grupo_inicial VARCHAR(20),
    p_grupo_final VARCHAR(20) DEFAULT NULL,
    p_data_contemplacao DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    grupo VARCHAR(20),
    cota INTEGER,
    tipo VARCHAR(20)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_grupo_final VARCHAR(20);
    v_grupo RECORD;
    v_qtd_lance_fixo INTEGER;
    v_cota_atual INTEGER;
    v_posicao INTEGER;
    v_assembleia_id BIGINT;
    v_bem_id VARCHAR(30);
    v_plano_id BIGINT;
BEGIN
    -- Garantir que os códigos tenham 6 dígitos (ex: 3301 -> 003301)
    v_grupo_final := LPAD(COALESCE(p_grupo_final, p_grupo_inicial), 6, '0');
    p_grupo_inicial := LPAD(p_grupo_inicial, 6, '0');
    
    RAISE NOTICE '>>> Processando cota % - grupos % até %', p_cota_sorteada, p_grupo_inicial, v_grupo_final;
    
    FOR v_grupo IN 
        SELECT g.id_grupo, g.cd_grupo
        FROM public.grupo g
        WHERE g.cd_grupo >= p_grupo_inicial 
          AND g.cd_grupo <= v_grupo_final
        ORDER BY g.cd_grupo
    LOOP
        RAISE NOTICE '  Processando grupo %...', v_grupo.cd_grupo;
        
        -- Buscar última assembleia e lances fixos
        SELECT ag.id, COALESCE(ag.qtd_lance_fixo, 0)
        INTO v_assembleia_id, v_qtd_lance_fixo
        FROM public.assembleias_grupo ag
        WHERE ag.grupo_id_grupo = v_grupo.id_grupo
        ORDER BY ag.numero DESC, ag.data DESC
        LIMIT 1;
        
        IF v_assembleia_id IS NULL THEN
            RAISE NOTICE '  ⚠ Grupo % não possui assembleias. Pulando...', v_grupo.cd_grupo;
            CONTINUE;
        END IF;
        
        RAISE NOTICE '  ✓ Grupo % - Assembleia: %, Lances fixos: %', v_grupo.cd_grupo, v_assembleia_id, v_qtd_lance_fixo;
        
        -- Buscar bem e plano do grupo através da tabela grupo_selecionado
        SELECT gs.bem_id_bem, gs.plano_id_plano
        INTO v_bem_id, v_plano_id
        FROM public.grupo_selecionado gs
        WHERE gs.grupo_id_grupo = v_grupo.id_grupo
        LIMIT 1;
        
        IF v_bem_id IS NULL OR v_plano_id IS NULL THEN
            RAISE NOTICE '  ⚠ Grupo % não possui bem/plano cadastrado em grupo_selecionado. Pulando...', v_grupo.cd_grupo;
            CONTINUE;
        END IF;
        
        -- Validar se a relação plano-bem é válida
        IF NOT EXISTS (
            SELECT 1 FROM public.rel_plano__bens rpb
            WHERE rpb.plano_id_plano = v_plano_id
              AND rpb.bens_id_bem = v_bem_id
        ) THEN
            RAISE NOTICE '  ⚠ Grupo % - Relação plano % + bem % não existe em rel_plano__bens. Pulando...', 
                v_grupo.cd_grupo, v_plano_id, v_bem_id;
            CONTINUE;
        END IF;
        
        RAISE NOTICE '  ✓ Bem: %, Plano: % (relação validada)', v_bem_id, v_plano_id;
        
        -- Inserir sorteio
        INSERT INTO public.contemplacao (
            id, data_contemplacao, tipo_contemplacao, posicao_lance,
            numero_sorteado, assembleia_id, grupo_id_grupo,
            plano_id_plano, bem_id_bem, status
        ) VALUES (
            nextval('contemplacao_id_seq'),
            p_data_contemplacao, 'SORTEIO', 0,
            p_cota_sorteada, v_assembleia_id, v_grupo.id_grupo,
            v_plano_id, v_bem_id, 'ATIVA'
        ) ON CONFLICT DO NOTHING;
        
        RAISE NOTICE '  ✓ Inserido: SORTEIO cota %', p_cota_sorteada;
        
        grupo := v_grupo.cd_grupo;
        cota := p_cota_sorteada;
        tipo := 'SORTEIO';
        RETURN NEXT;
        
        -- Inserir lances fixos
        v_cota_atual := p_cota_sorteada - 1;
        v_posicao := 1;
        
        WHILE v_posicao <= v_qtd_lance_fixo AND v_cota_atual > 0 LOOP
            INSERT INTO public.contemplacao (
                id, data_contemplacao, tipo_contemplacao, posicao_lance,
                numero_sorteado, assembleia_id, grupo_id_grupo,
                plano_id_plano, bem_id_bem, status
            ) VALUES (
                nextval('contemplacao_id_seq'),
                p_data_contemplacao, 'LANCE_FIXO', v_posicao,
                v_cota_atual, v_assembleia_id, v_grupo.id_grupo,
                v_plano_id, v_bem_id, 'PROVISIONADA'
            ) ON CONFLICT DO NOTHING;
            
            grupo := v_grupo.cd_grupo;
            cota := v_cota_atual;
            tipo := 'LANCE_FIXO';
            RETURN NEXT;
            
            v_cota_atual := v_cota_atual - 1;
            v_posicao := v_posicao + 1;
        END LOOP;
        
        IF v_qtd_lance_fixo > 0 THEN
            RAISE NOTICE '  ✓ Inseridos % lances fixos', v_qtd_lance_fixo;
        END IF;
    END LOOP;
    
    RAISE NOTICE '<<< Processamento concluído!';
END;
$$;

-- =====================================================
-- 5. FUNÇÃO DE LOTE
-- =====================================================

CREATE OR REPLACE PROCEDURE processar_lote_contemplacao(
    p_sorteios JSONB,
    p_data_contemplacao DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sorteio JSONB;
    v_cota INTEGER;
    v_grupo_ini VARCHAR(20);
    v_grupo_fim VARCHAR(20);
    v_total INTEGER;
    v_contador INTEGER := 0;
BEGIN
    v_total := jsonb_array_length(p_sorteios);
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Processamento em Lote';
    RAISE NOTICE 'Total de sorteios: %', v_total;
    RAISE NOTICE '====================================';
    
    FOR v_sorteio IN SELECT * FROM jsonb_array_elements(p_sorteios)
    LOOP
        v_contador := v_contador + 1;
        v_cota := (v_sorteio->>'cota')::INTEGER;
        v_grupo_ini := v_sorteio->>'grupo_ini';
        v_grupo_fim := COALESCE(v_sorteio->>'grupo_fim', v_grupo_ini);
        
        RAISE NOTICE '';
        RAISE NOTICE '[%/%] Processando...', v_contador, v_total;
        PERFORM processar_contemplacao(v_cota, v_grupo_ini, v_grupo_fim, p_data_contemplacao);
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Lote concluído! % sorteios processados', v_total;
    RAISE NOTICE '====================================';
END;
$$;

-- =====================================================
-- INSTALAÇÃO CONCLUÍDA
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Instalação concluída com sucesso!';
    RAISE NOTICE 'Use: SELECT * FROM processar_contemplacao(871, ''3301'', ''3302'');';
END $$;

