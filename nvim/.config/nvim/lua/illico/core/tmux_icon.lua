-- Publica el icono del archivo actual (glifo + color de mini.icons) como
-- opciones de pane de tmux (@nvim_icon / @nvim_icon_color) para que
-- tmux-tabicon muestre el icono del filetype en la pestaña en vez del icono
-- genérico de nvim. Al salir de nvim se limpian y la pestaña vuelve al normal.
local M = {}

function M.setup()
	if not vim.env.TMUX then
		return
	end

	local function update()
		local name = vim.api.nvim_buf_get_name(0)
		if name == "" or vim.bo.buftype ~= "" then
			return
		end
		local ok, icons = pcall(require, "mini.icons")
		if not ok then
			return
		end
		local icon, hl = icons.get("file", name)
		local fg = vim.api.nvim_get_hl(0, { name = hl }).fg
		local color = fg and ("#%06x"):format(fg) or ""
		vim.system({ "tmux", "set", "-p", "@nvim_icon", icon })
		vim.system({ "tmux", "set", "-p", "@nvim_icon_color", color })
	end

	local group = vim.api.nvim_create_augroup("illico_tmux_icon", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, { group = group, callback = update })
	-- Síncrono a propósito: en VimLeavePre los jobs async ya no llegan a correr
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			vim.fn.system("tmux set -pu @nvim_icon \\; set -pu @nvim_icon_color")
		end,
	})
end

return M
