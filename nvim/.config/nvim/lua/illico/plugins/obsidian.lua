return {
	"obsidian-nvim/obsidian.nvim",
	-- Se sigue la rama `main` en vez del último tag: la release v3.16.6 llama
	-- `vim.pos.cursor(0)` con la firma antigua y rompe `:Obsidian toc` en
	-- Neovim 0.12 (nightly). `main` ya adoptó la nueva API de `vim.pos`.
	branch = "main",
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "work",
				path = "/Users/nicolaslasso/Library/CloudStorage/OneDrive-Slalom/Documentos/work",
			},
		},
		-- Completion se provee vía el LSP integrado (obsidian-ls); ya no se
		-- configura nvim_cmp aquí (removido en obsidian.nvim 4.0).
		completion = {
			min_chars = 2,
		},
		ui = {
			enable = false,
		},
	},
}
