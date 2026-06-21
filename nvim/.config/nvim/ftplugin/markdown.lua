-- ftplugin loaded for every markdown buffer (incl. .ipynb files converted by jupytext).
-- Activates quarto LSP/runner and sets buffer-local notebook keymaps.
-- Keymaps are buffer-local so <localleader>=<space> doesn't compete with global leader.

-- Folds por secciones (headings) vía treesitter. Nativo, sin plugin.
--   za  toggle fold   zR  abrir todo   zM  cerrar todo   zo/zc abrir/cerrar
-- foldlevel = 99 -> arranca todo ABIERTO; ponlo en 0 o 1 para arrancar plegado.
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldenable = true
vim.opt_local.foldlevel = 99

-- Texto del fold: flecha + título del heading, sin nada más.
function _G.IllicoMdFoldtext()
  return "▸ " .. vim.fn.getline(vim.v.foldstart)
end
vim.opt_local.foldtext = "v:lua.IllicoMdFoldtext()"
-- Quitar los "····" de relleno a la derecha del fold (fillchar `fold` = espacio).
vim.opt_local.fillchars:append({ fold = " " })

-- render-markdown re-renderiza por eventos y nvim NO tiene evento de fold, así
-- que al plegar una sección con tabla/elementos virtuales esos quedan pegados.
-- Tras un comando de fold re-emitimos WinScrolled (que render-markdown sí
-- escucha) para que vuelva a pintar respetando los folds (usa foldclosed).
for _, key in ipairs({ "za", "zA", "zo", "zO", "zc", "zC", "zM", "zR", "zr", "zm", "zv", "zx" }) do
  vim.keymap.set("n", key, function()
    local cnt = vim.v.count > 0 and tostring(vim.v.count) or ""
    vim.cmd("normal! " .. cnt .. key)
    vim.schedule(function()
      pcall(vim.api.nvim_exec_autocmds, "WinScrolled", { modeline = false })
    end)
  end, { buffer = true, silent = true, desc = "fold + refrescar render-markdown" })
end

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
