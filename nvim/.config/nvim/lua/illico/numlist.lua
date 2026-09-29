-- Numeración jerárquica (1., 1.1., 2.3.4) al inicio de línea: ni markdown ni
-- norg la reconocen como lista, así que se resalta a mano (un color por nivel)
-- y <leader><CR> continúa el ítem. Compartido por ftplugin/markdown.lua y
-- ftplugin/norg.lua.
local M = {}

vim.api.nvim_set_hl(0, "NumListLvl1", { fg = "#ed8796", bold = true })
vim.api.nvim_set_hl(0, "NumListLvl2", { fg = "#eed49f", bold = true })
vim.api.nvim_set_hl(0, "NumListLvl3", { fg = "#a6da95", bold = true })
vim.api.nvim_set_hl(0, "NumListLvl4", { fg = "#c6a0f6", bold = true })

-- El `\ze\s` limita cada patrón a su profundidad exacta, sin solaparse.
M.levels = {
	{ "NumListLvl1", [[^\s*\d\+\.\ze\s]] },
	{ "NumListLvl2", [[^\s*\d\+\%(\.\d\+\)\{1}\.\?\ze\s]] },
	{ "NumListLvl3", [[^\s*\d\+\%(\.\d\+\)\{2}\.\?\ze\s]] },
	{ "NumListLvl4", [[^\s*\d\+\%(\.\d\+\)\{3,}\.\?\ze\s]] },
}

-- Aplica los matches del nivel `from` en adelante (los matches son por
-- ventana; se re-aplican al re-entrar).
function M.attach(from)
	local function apply()
		for _, id in ipairs(vim.w.numlist_ids or {}) do
			pcall(vim.fn.matchdelete, id)
		end
		local ids = {}
		for i = from, #M.levels do
			ids[#ids + 1] = vim.fn.matchadd(M.levels[i][1], M.levels[i][2], 20)
		end
		vim.w.numlist_ids = ids
	end
	apply()
	vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
		buffer = vim.api.nvim_get_current_buf(),
		callback = apply,
	})
end

return M
