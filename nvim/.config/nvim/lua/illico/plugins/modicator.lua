return {
	"mawkler/modicator.nvim",
	event = "ModeChanged",
	dependencies = { "folke/tokyonight.nvim" }, -- Asegura que cargue después del tema
	init = function()
		-- Estas opciones aseguran que el cursorline se comporte bien
		vim.o.cursorline = true
		vim.o.number = true
		vim.o.termguicolors = true
	end,
	opts = {
		-- Muestra advertencias si algo va mal (opcional)
		show_warnings = false,
	},
}
