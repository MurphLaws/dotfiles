-- ftplugin loaded for every markdown buffer (incl. .ipynb files converted by jupytext).
-- Activates quarto LSP/runner and sets buffer-local notebook keymaps.
-- Keymaps are buffer-local so <localleader>=<space> doesn't compete with global leader.

-- Folds por secciones (headings) vía treesitter. Nativo, sin plugin.
--   za  toggle fold   zR  abrir todo   zM  cerrar todo   zo/zc abrir/cerrar
-- foldlevel = 0 -> arranca TODO PLEGADO; sube el número para arrancar más abierto.
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldenable = true
vim.opt_local.foldlevel = 0

-- Forzar el cálculo de folds al abrir: el parser de treesitter puede no estar
-- listo cuando corre el ftplugin, así que los folds no se cierran solos. Tras un
-- tick recalculamos (zx) y reaplicamos foldlevel=0 para dejar todo plegado.
local fold_buf = vim.api.nvim_get_current_buf()
vim.schedule(function()
  if vim.api.nvim_buf_is_valid(fold_buf) and vim.api.nvim_get_current_buf() == fold_buf then
    pcall(vim.cmd, "normal! zx")
    vim.wo.foldlevel = 0
  end
end)

-- Texto del fold: solo el título del heading (sin el relleno de "+--").
function _G.IllicoMdFoldtext()
  return vim.fn.getline(vim.v.foldstart)
end
vim.opt_local.foldtext = "v:lua.IllicoMdFoldtext()"

-- Triángulo de fold con statuscolumn propio (en vez de foldcolumn nativo, que
-- además metía los dígitos de nivel "2" que no se querían). Solo dibuja ▼/▶ en
-- la línea que INICIA un fold; el resto va en blanco. Conserva signos y números.
vim.opt_local.fillchars:append({ fold = " " }) -- quita los "····" del foldtext
function _G.IllicoMdFoldChar()
  local l = vim.v.lnum
  if vim.fn.foldlevel(l) > vim.fn.foldlevel(l - 1) then
    return vim.fn.foldclosed(l) == -1 and "▼" or "▶"
  end
  return " "
end
vim.opt_local.foldcolumn = "0"
vim.opt_local.numberwidth = 3
-- Color claro para la flecha de fold (antes heredaba un tono oscuro).
vim.api.nvim_set_hl(0, "IllicoFoldArrow", { fg = "#cdd6f4" })
-- [signo][triángulo claro][número relativo/absoluto] + espacio
vim.opt_local.statuscolumn = "%s%#IllicoFoldArrow#%{v:lua.IllicoMdFoldChar()}%* %=%{v:relnum?v:relnum:v:lnum} "

-- (Sin remap de teclas de fold: el borde de la tabla ya no se filtra porque está
-- desactivado en render-markdown; las teclas za/zM/zR/... funcionan normales.)

-- CriticMarkup: comentarios y sugerencias estilo Google Docs, resaltados con
-- matchadd (sin plugins). Sintaxis:
--   {>>comentario<<}      comentario al margen   (ámbar)
--   {==texto==}           resaltado tipo marcador (fondo ámbar)
--   {++añadir++}          sugerir inserción       (verde)
--   {--quitar--}          sugerir borrado         (rojo, tachado)
--   {~~viejo~>nuevo~~}    sugerir reemplazo       (cian)
vim.api.nvim_set_hl(0, "CriticComment", { fg = "#f9e2af", bg = "#3a3320", italic = true })
vim.api.nvim_set_hl(0, "CriticHighlight", { fg = "#1e1e2e", bg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "CriticAdd", { fg = "#a6e3a1", bg = "#1e3a2a" })
vim.api.nvim_set_hl(0, "CriticDel", { fg = "#f38ba8", strikethrough = true })
vim.api.nvim_set_hl(0, "CriticSub", { fg = "#89dceb", bg = "#1e3040" })

local critic_patterns = {
  { "CriticComment", [[{>>\_.\{-}<<}]] },
  { "CriticHighlight", [[{==\_.\{-}==}]] },
  { "CriticAdd", [[{++\_.\{-}++}]] },
  { "CriticDel", [[{--\_.\{-}--}]] },
  { "CriticSub", [[{\~\~\_.\{-}\~\~}]] },
}
local function critic_apply()
  for _, id in ipairs(vim.w.critic_match_ids or {}) do
    pcall(vim.fn.matchdelete, id)
  end
  local ids = {}
  for _, p in ipairs(critic_patterns) do
    ids[#ids + 1] = vim.fn.matchadd(p[1], p[2], 20)
  end
  vim.w.critic_match_ids = ids
end
critic_apply()
-- matchadd es por ventana: reaplicar al entrar al buffer/ventana.
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  buffer = fold_buf,
  callback = critic_apply,
})

-- Comandos para INSERTAR comentarios/sugerencias CriticMarkup. Prefijo <leader>m
-- (markdown), buffer-local. En NORMAL inserta el marcador vacío con el cursor
-- dentro (modo insert). En VISUAL envuelve la selección.
local function ins(pre, post) -- inserta pre..post y deja el cursor entre ambos
  return function()
    local r, c = unpack(vim.api.nvim_win_get_cursor(0))
    local l = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(l:sub(1, c) .. pre .. post .. l:sub(c + 1))
    vim.api.nvim_win_set_cursor(0, { r, c + #pre })
    vim.cmd("startinsert")
  end
end
local function vwrap(pre, post) -- envuelve la selección visual con pre/post
  return function()
    local k = vim.api.nvim_replace_termcodes('c' .. pre .. '<C-r>"' .. post .. '<Esc>', true, false, true)
    vim.api.nvim_feedkeys(k, "x", false)
  end
end
local cmap = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end
-- NORMAL: insertar marcador vacío
cmap("n", "<leader>mc", ins("{>>", "<<}"), "Critic: comentario")
cmap("n", "<leader>mh", ins("{==", "==}"), "Critic: resaltar")
cmap("n", "<leader>ma", ins("{++", "++}"), "Critic: añadir")
cmap("n", "<leader>md", ins("{--", "--}"), "Critic: borrar")
cmap("n", "<leader>ms", ins("{~~", "~>~~}"), "Critic: reemplazar")
-- VISUAL: envolver selección
cmap("x", "<leader>mh", vwrap("{==", "==}"), "Critic: resaltar selección")
cmap("x", "<leader>ma", vwrap("{++", "++}"), "Critic: añadir selección")
cmap("x", "<leader>md", vwrap("{--", "--}"), "Critic: borrar selección")
-- VISUAL comentar: resalta la selección y abre un comentario al lado
cmap("x", "<leader>mc", vwrap("{==", '==}{>><<}'), "Critic: resaltar + comentar")

local ok_quarto, quarto = pcall(require, "quarto")
if not ok_quarto then return end

quarto.activate()

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

-- Quarto runner (preferred — handles cell boundaries, language detection)
local runner = require("quarto.runner")
map("n", "<localleader>rc", runner.run_cell,                   "run cell")
map("n", "<localleader>ra", runner.run_above,                  "run cell and above")
map("n", "<localleader>rA", runner.run_all,                    "run all cells")
map("n", "<localleader>rl", runner.run_line,                   "run line")
map("v", "<localleader>r",  runner.run_range,                  "run visual range")
