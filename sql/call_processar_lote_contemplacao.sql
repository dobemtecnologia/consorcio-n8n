-- Limpar dados anteriores
DELETE FROM contemplacao WHERE data_contemplacao = CURRENT_DATE;

-- Processar
CALL processar_lote_contemplacao('[
    {"cota": 871, "grupo_ini": "3301", "grupo_fim": "3302"},
    {"cota": 871, "grupo_ini": "3303", "grupo_fim": "3318"},
    {"cota": 8871, "grupo_ini": "3319", "grupo_fim": "3324"}
]'::jsonb);