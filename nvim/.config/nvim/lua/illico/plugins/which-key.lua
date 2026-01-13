return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")

		wk.setup({
			-- Use helix preset for bottom-right positioning
			preset = "helix",

			-- ⚡️ CORRECCIÓN DE VELOCIDAD:
			-- Establecer el retardo a 0 hace que el menú aparezca instantáneamente.
			-- Por defecto usa 'timeoutlen' (300ms), lo que causa la sensación de lentitud.
			delay = 0,

			win = {
				no_overlap = true,
				border = "single",
				padding = { 1, 2 },
				title = false,
			},
			layout = {
				spacing = 3,
			},
			icons = {
				mappings = true,
			},
		})

		-- Register keymap groups
		wk.add({
			{ "<leader>f", group = "Find" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>g", group = "Git" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>s", group = "Search" },
			{ "<leader>t", group = "Toggle" },
			{ "<leader>w", group = "Window" },
		})
	end,
}
