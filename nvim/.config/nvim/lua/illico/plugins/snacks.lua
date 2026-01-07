return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,

		opts = {
			notifier = {
				enabled = true,
				timeout = 3000,
				level = vim.log.levels.INFO,
				style = "compact",
				top_down = true,
				margin = { top = 0, right = 1, bottom = 0 },
				padding = true,
				border = true,
				icons = {
					error = " ",
					warn = " ",
					info = " ",
					debug = " ",
					trace = " ",
				},
			},
		},

		keys = {
			-- Git integrations
			{
				"<leader>lg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Open Lazygit",
			},
			{
				"<leader>gl",
				function()
					require("snacks").lazygit.log()
				end,
				desc = "Open Lazygit Log",
			},

			-- Rename & buffer actions
			{
				"<leader>rN",
				function()
					require("snacks").rename_file.rename_file()
				end,
				desc = "Rename Current File",
			},
			{
				"<leader>dB",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete Current Buffer",
			},

			-- Pickers
			{
				"<leader>pf",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>pc",
				function()
					require("snacks").picker.files({ cwd = "~/.config/nvim/lua" })
				end,
				desc = "Find Config Files",
			},
			{
				"<leader>po",
				function()
					require("snacks").picker.files({ cwd = "~/notes", glob = "*.norg" })
				end,
				desc = "Find Neorg Files",
			},
			{
				"<leader>ps",
				function()
					require("snacks").picker.grep()
				end,
				desc = "Grep Search",
			},
			{
				"<leader>pws",
				function()
					require("snacks").picker.grep_word()
				end,
				desc = "Search Word Under Cursor or Selection",
				mode = { "n", "x" },
			},
			{
				"<leader>pk",
				function()
					require("snacks").picker.keymaps({ layout = "ivy" })
				end,
				desc = "Search Keymaps",
			},
			{
				"<leader>vh",
				function()
					require("snacks").picker.help()
				end,
				desc = "Search Help Pages",
			},

			-- Todo Comments integrations
			{
				"<leader>pt",
				function()
					require("snacks").picker.todo_comments()
				end,
				desc = "Todo",
			},
			{
				"<leader>pT",
				function()
					require("snacks").picker.todo_comments({
						keywords = { "TODO", "FIX", "FIXME" },
					})
				end,
				desc = "Todo/Fix/Fixme",
			},

			-- Notification history
			{
				"<leader>nh",
				function()
					local snacks = require("snacks")
					if snacks and snacks.notifier and snacks.notifier.show_history then
						snacks.notifier.show_history({
							sort = { "level", "added" },
							reverse = true,
						})
					else
						vim.notify("Snacks Notifier history not available", vim.log.levels.WARN)
					end
				end,
				desc = "Show Notification History",
			},

			-- Zen mode
			{
				"<leader>tz",
				function()
					require("snacks").zen()
				end,
				desc = "Toggle Zen Mode",
			},
		},
	},
}
