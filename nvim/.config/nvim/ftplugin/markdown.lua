-- ftplugin para markdown (incl. .qmd). Vanilla: sin folds ni statuscolumn
-- personalizados; el render lo hace render-markdown.nvim. Solo se añaden:
--   1) resaltado + comandos de comentarios CriticMarkup
--   2) el runner de quarto (cuando el plugin está disponible)

-- ── CriticMarkup ───────────────────────────────────────────────────────────
-- Comentarios y sugerencias estilo Google Docs, resaltados con matchadd:
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
local md_buf = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  buffer = md_buf,
  callback = critic_apply,
})

-- Comandos para insertar/envolver comentarios. Prefijo <leader>m, buffer-local.
local function ins(pre, post) -- inserta pre..post y deja el cursor entre ambos
  return function()
    local r, c = unpack(vim.api.nvim_win_get_cursor(0))
    local l = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(l:sub(1, c) .. pre .. post .. l:sub(c + 1))
    vim.api.nvim_win_set_cursor(0, { r, c + #pre })
    vim.cmd("startinsert")
  end
end
local function vwrap(pre, post) -- envuelve la selección visual
  return function()
    local k = vim.api.nvim_replace_termcodes('c' .. pre .. '<C-r>"' .. post .. '<Esc>', true, false, true)
    vim.api.nvim_feedkeys(k, "x", false)
  end
end
local cmap = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end
cmap("n", "<leader>mc", ins("{>>", "<<}"), "Critic: comentario")
cmap("n", "<leader>mh", ins("{==", "==}"), "Critic: resaltar")
cmap("n", "<leader>ma", ins("{++", "++}"), "Critic: añadir")
cmap("n", "<leader>md", ins("{--", "--}"), "Critic: borrar")
cmap("n", "<leader>ms", ins("{~~", "~>~~}"), "Critic: reemplazar")
cmap("x", "<leader>mh", vwrap("{==", "==}"), "Critic: resaltar selección")
cmap("x", "<leader>ma", vwrap("{++", "++}"), "Critic: añadir selección")
cmap("x", "<leader>md", vwrap("{--", "--}"), "Critic: borrar selección")
cmap("x", "<leader>mc", vwrap("{==", "==}{>><<}"), "Critic: resaltar + comentar")

-- ── Quarto runner ──────────────────────────────────────────────────────────
local ok_quarto, quarto = pcall(require, "quarto")
if not ok_quarto then
  return
end

quarto.activate()

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

local runner = require("quarto.runner")
map("n", "<localleader>rc", runner.run_cell, "run cell")
map("n", "<localleader>ra", runner.run_above, "run cell and above")
map("n", "<localleader>rA", runner.run_all, "run all cells")
map("n", "<localleader>rl", runner.run_line, "run line")
map("v", "<localleader>r", runner.run_range, "run visual range")
