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
			min_width = 30,
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = false, -- en markdown muestra todos los headings, sin filtrar por tipo
		close_on_select = true, -- al saltar a un heading, cierra el panel (modo TOC)
		-- Cerrar el panel con q (default), Q o Esc, para no quedar atrapado.
		keymaps = {
			["Q"] = "actions.close",
			["<Esc>"] = "actions.close",
		},
	},
	cmd = { "AerialToggle", "AerialOpen" },
	keys = {
		{ "<leader>O", "<cmd>AerialToggle<CR>", desc = "Toggle outline (aerial)" },
	},
}
