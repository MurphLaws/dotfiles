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
					position = { row = 1, col = "50%" },
					size = { width = 60, height = "auto" },
					border = { style = "rounded" },
				},
				popupmenu = {
					position = { row = 3, col = "50%" }, -- completion menu below cmdline
					size = { width = 60, height = 10 },
					border = { style = "rounded" },
				},
			},
		},
	},
	{
		-- Normal es transparente a propósito (heredamos el fondo de Ghostty), así
		-- que nvim-notify no encuentra un color de fondo del que partir y avisa en
		-- cada notificación. Le damos el bg del terminal explícitamente.
		"rcarriga/nvim-notify",
		opts = {
			background_colour = "#1f2329",
		},
	},
}
