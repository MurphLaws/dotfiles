return {
	{
		"leolaurindo/tunnelvision.nvim",
		-- Por defecto el texto atenuado usa el color de `Comment` (#6c7086),
		-- que se sigue leyendo bastante. Forzamos un fg más oscuro (surface1)
		-- para que las líneas fuera de foco recedan más y el símbolo resalte.
		opts = {
			dim = { fg = "#45475a" },
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
