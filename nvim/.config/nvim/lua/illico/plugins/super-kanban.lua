return {
	"hasansujon786/super-kanban.nvim",
	dependencies = {
		"folke/snacks.nvim",
		"nvim-orgmode/orgmode",
	},
	ft = { "markdown", "org" },
	cmd = { "SuperKanban", "SuperKanbanCreate" },
	keys = {
		{ "<leader>ko", "<cmd>SuperKanban<cr>", desc = "Kanban: open current file" },
		{ "<leader>kn", "<cmd>SuperKanbanCreate<cr>", desc = "Kanban: create new board" },
	},
	opts = {},
}
