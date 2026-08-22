return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",

		---@type Flash.Config
		opts = {
			-- A diferencia de leap (2 caracteres fijos), flash es incremental:
			-- se sigue escribiendo el patrón y las etiquetas se recalculan sobre
			-- los matches que quedan. Sin límite de longitud.
			search = {
				-- Coincidencia literal e insensible a mayúsculas, igual que el
				-- leap anterior (que forzaba ignorecase vía vim_opts). Los modos
				-- integrados ("exact"/"search") respetan la opción `ignorecase`
				-- de Vim, que aquí está apagada, así que el patrón se construye
				-- a mano: \V literal + \c case-insensitive.
				mode = function(str)
					return "\\V\\c" .. vim.fn.escape(str, "\\")
				end,
				-- Bidireccional en toda la ventana, como el `leap_window` anterior.
				forward = true,
				wrap = true,
				incremental = true,
			},

			jump = {
				-- Deja el salto en la jumplist para poder volver con <C-o>.
				jumplist = true,
				nohlsearch = true,
			},

			label = {
				-- Etiqueta después del match (no encima), así no tapa el texto
				-- que se está leyendo para decidir el salto.
				before = false,
				after = true,
				-- Una sola tecla siempre que sea posible; reusa la etiqueta del
				-- match ya escrito cuando coincide.
				reuse = "lowercase",
				-- Home row primero, igual criterio que las labels de leap.
				uppercase = false,
			},

			highlight = {
				-- Backdrop nativo: atenúa el texto visible y deja solo matches y
				-- etiquetas. Reemplaza las ~110 líneas de extmarks que necesitaba
				-- leap (su LeapBackdrop estaba deprecado).
				backdrop = true,
			},

			modes = {
				-- f/t/F/T se quedan como los de Vim. Flash los reemplaza por
				-- defecto; se desactiva para no cambiar dos cosas a la vez.
				char = { enabled = false },
				-- Etiquetas de salto sobre los resultados de `/` y `?`.
				search = { enabled = true },
			},
		},

		keys = {
			-- `s` sigue siendo el salto principal, ahora incremental.
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({ search = { multi_window = false } })
				end,
				desc = "Flash: buffer actual (bidireccional)",
			},
			-- `S` mantiene el alcance del leap anterior: todas las ventanas visibles.
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({ search = { multi_window = true } })
				end,
				desc = "Flash: todas las ventanas",
			},
			-- Selección por nodo de treesitter (función, bloque, tabla…).
			{
				"gs",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash: seleccionar nodo treesitter",
			},
			-- Operador remoto: `yr` + salto + motion opera lejos y vuelve al cursor.
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Flash: operador remoto",
			},
		},

		config = function(_, opts)
			require("flash").setup(opts)

			-- Mismo rosa que usaban LeapMatch/LeapLabel, para no cambiar el look.
			local PINK = "#ff6ac1"
			local function set_hl()
				vim.api.nvim_set_hl(0, "FlashBackdrop", { link = "Comment", default = false })
				vim.api.nvim_set_hl(0, "FlashMatch", { fg = PINK, bold = true, nocombine = true })
				vim.api.nvim_set_hl(0, "FlashCurrent", { fg = PINK, bold = true, nocombine = true })
				vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#1e222a", bg = PINK, bold = true, nocombine = true })
			end

			set_hl()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("illico_flash_hl", { clear = true }),
				callback = set_hl,
			})
		end,
	},
}
