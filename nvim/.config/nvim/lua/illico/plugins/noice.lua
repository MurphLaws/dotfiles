return {
	{
		"folke/noice.nvim",
		event = "CmdlineEnter",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		init = function()
			vim.o.cmdheight = 0
			vim.o.showmode = false

			-- disable native cmdline completion UI (bottom)
			vim.o.wildmenu = false
			vim.o.wildoptions = ""
		end,
		opts = {
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
			},
			popupmenu = {
				enabled = true,
				backend = "nui",
			},
			views = {
				cmdline_popup = {
					position = { row = "50%", col = "50%" },
					size = { width = 60, height = "auto" },
					border = { style = "rounded" },
				},
				popupmenu = {
					position = { row = "55%", col = "50%" }, -- completion menu near the cmdline popup
					size = { width = 60, height = 10 },
					border = { style = "rounded" },
				},
			},
		},
	},
}
