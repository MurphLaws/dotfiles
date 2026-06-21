return {
	"stevearc/aerial.nvim",
	-- main exige Neovim >= 0.12; este nvim es 0.11.5. La rama nvim-0.x es la
	-- versión mantenida para 0.x. Quitar este branch al actualizar a nvim 0.12+.
	branch = "nvim-0.x",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		-- Para markdown/quarto usa treesitter (headings); LSP donde haya symbols.
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = {
			default_direction = "right",
			min_width = 30,
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = false, -- en markdown muestra todos los headings, sin filtrar por tipo
	},
	cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
	keys = {
		{ "<leader>O", "<cmd>AerialToggle<CR>", desc = "Toggle outline (aerial)" },
		{ "<leader>a", "<cmd>AerialNavToggle<CR>", desc = "Outline flotante (aerial nav)" },
	},
}
