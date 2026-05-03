return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>e",
				function()
					require("oil").toggle_float()
				end,
				desc = "Oil: Floating file explorer",
			},
			{
				"<leader>E",
				"<cmd>vsplit | vertical resize 32 | Oil<cr>",
				desc = "Oil: Side panel file explorer",
			},
		},
		opts = {
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name:match("%.uid$") ~= nil
				end,
			},
			float = {
				padding = 4,
				max_width = 0.6,
				max_height = 0.7,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},
			keymaps = {
				["q"] = "actions.close",
				["<esc>"] = "actions.close",
			},
		},
	},
}
