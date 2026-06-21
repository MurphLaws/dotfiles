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

-- Texto del fold: solo el título del heading (la flecha de estado va en la
-- columna de folds, no aquí, para no duplicarla).
function _G.IllicoMdFoldtext()
  return vim.fn.getline(vim.v.foldstart)
end
vim.opt_local.foldtext = "v:lua.IllicoMdFoldtext()"

-- Columna de folds con triángulo según estado: ▼ abierto, ▶ cerrado. nvim lo
-- alterna solo en la línea del heading. foldsep en blanco para no dibujar la
-- línea vertical de anidamiento; fold en blanco quita los "····" del foldtext.
vim.opt_local.foldcolumn = "1"
vim.opt_local.fillchars:append({ fold = " ", foldopen = "▼", foldclose = "▶", foldsep = " " })

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
