return {
	"mvllow/modes.nvim",
	tag = "v0.2.0",
	event = "ModeChanged",
	config = function()
		require("modes").setup({
			colors = {
				-- Estos colores son ejemplos que combinan bien,
				-- pero puedes poner "red", "green", "blue" si quieres.
				copy = "#f5c359",
				delete = "#c75c6a",
				insert = "#78ccc5",
				visual = "#9745be",
			},

			-- Opacidad de la línea (0.0 a 1.0).
			-- 0.3 es bastante visible. Súbelo si quieres que sea MÁS obvio.
			line_opacity = 0.30,

			-- Habilitar características
			set_cursor = true,
			set_cursorline = true, -- ESTO es lo que pinta toda la línea
			set_number = true, -- Esto reemplaza a 'modicator'

			-- No pintar la línea en estas ventanas para no molestar
			ignore_filetypes = { "NvimTree", "TelescopePrompt", "dashboard", "alpha" },
		})
	end,
}
