-- VimTeX: edición LaTeX con auto-compilación y sync con Skim PDF viewer.
-- Requisitos externos: latexmk + biber (vienen con TinyTeX) y Skim.app.
--
-- Atajos principales (en modo normal, en un archivo .tex):
--   <leader>ll  -> arrancar/parar compilación continua (latexmk -pvc)
--   <leader>lv  -> ver PDF en Skim (forward search)
--   <leader>lc  -> limpiar archivos auxiliares
--   <leader>lk  -> matar compilador en background
--   <leader>le  -> mostrar errores en quickfix
--   <leader>lt  -> mostrar TOC del documento
--
-- Forward search: <leader>lv salta a la línea actual en el PDF.
-- Inverse search: Cmd+Shift+click en Skim te devuelve al .tex.

return {
  "lervag/vimtex",
  lazy = false, -- VimTeX no soporta lazy-loading
  ft = { "tex", "plaintex", "bib" },
  init = function()
    -- Asegurar que latexmk/biber/pdflatex (TinyTeX) estén en PATH.
    local tinytex_bin = vim.fn.expand("$HOME/Library/TinyTeX/bin/universal-darwin")
    if vim.fn.isdirectory(tinytex_bin) == 1 then
      vim.env.PATH = vim.env.PATH .. ":" .. tinytex_bin
    end

    -- Visor PDF: Skim con SyncTeX (forward + inverse).
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1        -- forward search al recompilar
    vim.g.vimtex_view_skim_activate = 1    -- traer Skim al frente al ver

    -- Compilador: latexmk (corre pdflatex + biber + pdflatex × 2 automáticamente).
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = "",
      out_dir = "",
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      hooks = {},
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-pdf",
      },
    }

    -- Bib backend: biber (lo usa biblatex-apa).
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-pdf",
    }

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
