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
			backdrop = 0.5,
			width = 0.7,
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
		on_open = function()
			-- focus.nvim auto-resizes the active window and eats zen-mode's
			-- centering padding. Pause it while zen is on.
			vim.g._illico_zen_focus_was_enabled = vim.g.focus_disable ~= true
			vim.g.focus_disable = true
			pcall(vim.cmd, "FocusDisable")
		end,
		on_close = function()
			if vim.g._illico_zen_focus_was_enabled then
				vim.g.focus_disable = false
				pcall(vim.cmd, "FocusEnable")
			end
			vim.g._illico_zen_focus_was_enabled = nil
		end,
	},
}
