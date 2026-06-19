-- VimTeX: edición LaTeX con compilación vía tectonic (sin TinyTeX/latexmk).
-- tectonic es un motor LaTeX autocontenido que descarga paquetes bajo demanda
-- y maneja la bibliografía internamente (no requiere biber/bibtex aparte).
--
-- Atajos principales (en modo normal, en un archivo .tex):
--   <leader>ll  -> compilar el documento (tectonic, one-shot)
--   <leader>lv  -> ver PDF (visor por defecto del sistema, p.ej. Preview)
--   <leader>lc  -> limpiar archivos auxiliares
--   <leader>lk  -> matar compilador en background
--   <leader>le  -> mostrar errores en quickfix
--   <leader>lt  -> mostrar TOC del documento
--
-- NOTA: tectonic no tiene modo "continuo" como latexmk -pvc; cada <leader>ll
-- hace una compilación completa. El forward/inverse search con SyncTeX requiere
-- Skim; sin él, <leader>lv abre el PDF con la app por defecto (sin sync).

return {
  "lervag/vimtex",
  lazy = false, -- VimTeX no soporta lazy-loading
  ft = { "tex", "plaintex", "bib" },
  init = function()
    -- Compilador: tectonic (motor LaTeX moderno y autocontenido).
    vim.g.vimtex_compiler_method = "tectonic"
    vim.g.vimtex_compiler_tectonic = {
      build_dir = "",
      callback = 1,
      continuous = 0, -- tectonic no soporta watch nativo; one-shot por compilación
      executable = "tectonic",
      hooks = {},
      options = {
        "--keep-logs",
        "--synctex",
      },
    }

    -- Visor PDF: usar Skim si está instalado (con SyncTeX forward/inverse),
    -- si no, caer al visor "general" que abre el PDF con la app por defecto.
    if vim.fn.isdirectory("/Applications/Skim.app") == 1 then
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
    else
      vim.g.vimtex_view_method = "general"
    end

    -- Quickfix sólo abre si hay errores (no para warnings).
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_quickfix_open_on_warning = 0

    -- Concealer apagado por defecto (cambia a 2 si quieres ver \alpha como α).
    vim.g.vimtex_syntax_conceal_disable = 1

    -- No abrir splits raros al ver el PDF.
    vim.g.vimtex_view_automatic = 1

    -- Espacios entre líneas en la salida de \ll.
    vim.g.vimtex_complete_enabled = 1
  end,
  config = function()
    -- Keymaps amigables. VimTeX ya provee <leader>l* por defecto, los re-expongo.
    local map = vim.keymap.set
    map("n", "<leader>ll", "<plug>(vimtex-compile)",          { desc = "TeX: compilar (toggle continuo)" })
    map("n", "<leader>lv", "<plug>(vimtex-view)",             { desc = "TeX: ver PDF" })
    map("n", "<leader>lc", "<plug>(vimtex-clean)",            { desc = "TeX: limpiar auxiliares" })
    map("n", "<leader>lC", "<plug>(vimtex-clean-full)",       { desc = "TeX: limpiar TODO (incluye PDF)" })
    map("n", "<leader>lk", "<plug>(vimtex-stop)",             { desc = "TeX: parar compilador" })
    map("n", "<leader>le", "<plug>(vimtex-errors)",           { desc = "TeX: mostrar errores" })
    map("n", "<leader>lt", "<plug>(vimtex-toc-open)",         { desc = "TeX: tabla de contenido" })
    map("n", "<leader>lr", "<plug>(vimtex-reload)",           { desc = "TeX: recargar VimTeX" })
    map("n", "<leader>li", "<plug>(vimtex-info)",             { desc = "TeX: info del documento" })
  end,
}
