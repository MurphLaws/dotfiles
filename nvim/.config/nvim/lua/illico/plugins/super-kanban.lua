return {
	"hasansujon786/super-kanban.nvim",
	dependencies = {
		"folke/snacks.nvim",
		"nvim-orgmode/orgmode",
	},
	cmd = { "SuperKanban" },
	keys = {
		{
			"<leader>ko",
			function()
				local f = vim.fn.expand("%:p")
				if f ~= "" and (f:match("%.md$") or f:match("%.org$")) then
					require("super-kanban").open(f)
				else
					require("super-kanban").open(nil, true)
				end
			end,
			desc = "Kanban: open board (picker if not on md/org)",
		},
		{
			"<leader>kn",
			function()
				require("super-kanban").create(nil, true)
			end,
			desc = "Kanban: create new board",
		},
		{ "<leader>kp", "<cmd>SuperKanban<cr>", desc = "Kanban: command palette" },
	},
	opts = {},
}
