return {
	"obsidian-nvim/obsidian.nvim",
	-- Se sigue la rama `main` en vez del último tag: la release v3.16.6 llama
	-- `vim.pos.cursor(0)` con la firma antigua y rompe `:Obsidian toc` en
	-- Neovim 0.12 (nightly). `main` ya adoptó la nueva API de `vim.pos`.
	branch = "main",
	ft = "markdown",
	-- Menú <leader>o (o = Obsidian). Los keys también actúan como triggers de
	-- carga perezosa del plugin.
	keys = {
		{ "<leader>on", "<cmd>Obsidian new<cr>", desc = "Obsidian: New note" },
		{ "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Obsidian: Open in app" },
		{ "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian: Search notes" },
		{ "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: Quick switch" },
		{ "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Obsidian: Today's daily note" },
		{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian: Backlinks" },
		{ "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Obsidian: Follow link" },
		{ "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Obsidian: List links" },
		{ "<leader>oL", "<cmd>Obsidian link<cr>", mode = "x", desc = "Obsidian: Link selection" },
		{ "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Obsidian: Rename note" },
		{ "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Obsidian: Toggle checkbox" },
		{ "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Obsidian: Insert template" },
		{ "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "Obsidian: Switch workspace" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "notes",
				path = vim.fn.expand("~/notes"),
			},
		},
		-- Completion se provee vía el LSP integrado (obsidian-ls); ya no se
		-- configura nvim_cmp aquí (removido en obsidian.nvim 4.0).
		completion = {
			min_chars = 2,
		},
		picker = {
			name = "snacks.pick",
		},
		ui = {
			enable = false,
		},
	},
}
