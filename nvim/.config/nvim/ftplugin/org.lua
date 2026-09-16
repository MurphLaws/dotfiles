-- Conceal en buffers org: con conceallevel=2 los enlaces [[url][descripción]]
-- se muestran solo como la descripción (la URL queda oculta), y los marcadores
-- de énfasis (*negrita*, /cursiva/) desaparecen si org_hide_emphasis_markers
-- está activo. concealcursor vacío = la línea bajo el cursor se muestra
-- completa, así se puede editar el enlace crudo sin pelear con el conceal.
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""