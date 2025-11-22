SELECT 
    * 
FROM 
    public.grupo_selecionado gs
LEFT JOIN 
    public.plano p  ON p.id_plano = gs.plano_id_plano
LEFT JOIN 
    public.bem b    ON b.id_bem   = gs.bem_id_bem
LEFT JOIN 
    public.grupo g  ON g.id_grupo = gs.grupo_id_grupo
WHERE   
    gs.cd_grupo IN (
        '003301', '003302', '003303','003304', '003305', '003306',
        '003307','003308','003309','003310','003311','003312',
        '003313','003314','003315','003316','003317','003318',
        '003319','003320','003321','003322','003323','003324'
    )
    AND gs.plano_id_plano IN (
        SELECT DISTINCT plano_id_plano FROM public.cotas_mineradas
    )
    AND gs.bem_id_bem IN (
        SELECT DISTINCT bem_id_bem FROM public.cotas_mineradas
    )
ORDER BY  
    gs.grupo_id_grupo ASC