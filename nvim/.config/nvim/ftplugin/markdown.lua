-- ftplugin loaded for every markdown buffer (incl. .ipynb files converted by jupytext).
-- Activates quarto LSP/runner and sets buffer-local notebook keymaps.
-- Keymaps are buffer-local so <localleader>=<space> doesn't compete with global leader.

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

-- Molten direct commands
map("n", "<localleader>e",  ":MoltenEvaluateOperator<CR>",     "molten evaluate operator")
map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>",       "molten re-eval cell")
map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>","molten enter output")
map("n", "<localleader>oh", ":MoltenHideOutput<CR>",           "molten hide output")
map("n", "<localleader>md", ":MoltenDelete<CR>",               "molten delete cell")
map("n", "<localleader>mi", ":MoltenInit<CR>",                 "molten init kernel")

-- Recovery: clear stuck images and force terminal redraw
map("n", "<localleader>oc", function()
  vim.cmd("MoltenHideOutput")
  pcall(function() require("image").clear() end)
  vim.cmd("redraw!")
end, "clear images + redraw")
