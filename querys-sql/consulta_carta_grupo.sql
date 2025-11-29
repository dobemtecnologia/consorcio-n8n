SELECT b.vlr_cred_integral FROM public.grupo_selecionado gs
inner join public.bem b ON b.id_bem = gs.bem_id_bem
inner join public.grupo g ON g.id_grupo = gs.grupo_id_grupo
where g.cd_grupo = '003311'
ORDER BY b. vlr_cred_integral desc 