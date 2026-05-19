return {
	"folke/zen-mode.nvim",
	keys = {
		{
			"<leader>z",
			function()
				require("zen-mode").toggle()
			end,
			desc = "Zen: Toggle focus mode",
		},
	},
	opts = {
		window = {
			backdrop = 0.95,
			width = 0.85,
			height = 1,
			options = {
				signcolumn = "no",
				number = false,
				relativenumber = false,
				cursorline = false,
				cursorcolumn = false,
				foldcolumn = "0",
				list = false,
			},
		},
		plugins = {
			options = { enabled = true, ruler = false, showcmd = false },
			twilight = { enabled = false },
			gitsigns = { enabled = false },
			tmux = { enabled = false },
		},
	},
}
