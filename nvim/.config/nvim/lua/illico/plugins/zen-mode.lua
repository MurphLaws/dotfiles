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
			backdrop = 1,
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
			-- Barras laterales: EXACTAMENTE el color del colorscheme (mocha base
			-- #1e1e2e) al 90% de opacidad. El color sólido va en ZenBg; el 90% lo
			-- da winblend = 10 (winblend es el % transparente, así que 10 = 90%
			-- opaco). fg = bg deja los "·" del eob invisibles.
			vim.api.nvim_set_hl(0, "ZenBg", { bg = "#1e1e2e", fg = "#1e1e2e" })
			-- winblend se aplica diferido porque zen-mode resetea winblend=0 al
			-- ajustar el layout. Sube el número para más transparencia.
			vim.schedule(function()
				local view = require("zen-mode.view")
				if view.bg_win and vim.api.nvim_win_is_valid(view.bg_win) then
					vim.wo[view.bg_win].winblend = 10
				end
			end)
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
