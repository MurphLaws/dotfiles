return {
	"stevearc/aerial.nvim",
	-- master exige Neovim >= 0.12; este nvim es 0.11.5. La rama nvim-0.11 es la
	-- mantenida para esta versión. Quitar este branch al actualizar a nvim 0.12+.
	branch = "nvim-0.11",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		-- Para markdown/quarto usa treesitter (headings); LSP donde haya symbols.
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = {
			default_direction = "right",
			-- El max_width por defecto (0.2 del ancho) dejaba el float angosto y
			-- truncaba los títulos. Lo ampliamos para que quepan los headings.
			min_width = 40,
			max_width = { 80, 0.5 },
		},
		float = {
			-- Limpio: sin borde. El fondo es transparente (NormalFloat, que la
			-- config global ya fuerza a bg=NONE) y winblend=0 hace que el float
			-- ocluya el buffer => se ve el ESCRITORIO a través del menú, no el
			-- texto de abajo.
			border = "none",
			relative = "editor", -- centrado en el editor
			max_height = 0.8,
			min_height = 0.4,
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = false, -- en markdown muestra todos los headings, sin filtrar por tipo
		close_on_select = true, -- al saltar a un heading, cierra (modo TOC)
		-- Cerrar con q (default), Q o Esc para no quedar atrapado.
		keymaps = {
			["Q"] = "actions.close",
			["<Esc>"] = "actions.close",
		},
	},
	cmd = { "AerialToggle", "AerialOpen" },
	keys = {
		{ "<leader>O", "<cmd>AerialToggle right<CR>", desc = "Outline lateral (aerial)" },
		{ "<leader>a", "<cmd>AerialToggle float<CR>", desc = "Outline flotante (aerial)" },
	},
}
