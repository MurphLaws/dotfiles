return {
	{
		"leolaurindo/tunnelvision.nvim",
		-- Por defecto el texto atenuado usa el color de `Comment` (#6c7086),
		-- que se sigue leyendo bastante. Forzamos un fg algo más oscuro
		-- (surface2) para que las líneas fuera de foco recedan sin desaparecer.
		opts = {
			dim = { fg = "#585b70" },
			-- Rastrea el símbolo en TODO el archivo, no solo en la función
			-- que contiene el cursor. Así funciona igual con variables que
			-- con funciones (sus llamadas viven en otras funciones del buffer).
			scope = "buffer",
			-- Combina LSP + emparejado por texto. Con el default "lsp_else_word",
			-- cuando hay LSP se usan SOLO sus líneas y el LSP de Godot/GDScript
			-- devuelve los usos pero NO la línea de declaración (`func nombre(...)`),
			-- que quedaba atenuada. "lsp_and_word" suma el match por palabra, que
			-- sí captura la declaración que el LSP omite.
			source = "lsp_and_word",
		},
		keys = {
			-- Persistente: fija el símbolo donde estás parado y lo mantiene
			-- resaltado aunque muevas el cursor (modo static, el de siempre).
			{
				"<leader>tv",
				"<cmd>TunnelVision toggle<CR>",
				desc = "TunnelVision (fija el símbolo actual)",
			},
			-- Tiempo real: re-apunta automáticamente al símbolo bajo el cursor
			-- a medida que te mueves (modo dynamic del plugin). El modo se pasa
			-- por buffer, así que no pisa el toggle estático de arriba.
			{
				"<leader>tV",
				function()
					local tv = require("tunnelvision")
					local buf = vim.api.nvim_get_current_buf()
					local st = tv.status(buf)
					if st.active and st.mode == "dynamic" then
						tv.off()
					else
						tv.on({ mode = "dynamic" })
					end
				end,
				desc = "TunnelVision en tiempo real (sigue el símbolo bajo el cursor)",
			},
		},
	},
}
