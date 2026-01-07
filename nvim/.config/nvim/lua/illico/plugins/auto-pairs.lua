-- lua/plugins/leap.lua
return {
	"ggandor/leap.nvim",
	config = function()
		local leap = require("leap")

		-- Set up leap with default mappings (includes 's' and 'S')
		leap.add_default_mappings()

		-- If you want to customize the mapping explicitly:
		vim.keymap.set({ "n", "x", "o" }, "s", function()
			leap.leap({ target_windows = { vim.fn.win_getid() } })
		end, { desc = "Leap forward/backward within current window" })

		vim.keymap.set({ "n", "x", "o" }, "S", function()
			leap.leap({ target_windows = require("leap.util").get_enterable_windows() })
		end, { desc = "Leap across windows" })

		-- Optional highlight tweaks
		vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
		vim.api.nvim_set_hl(0, "LeapMatch", { fg = "red", bold = true, nocombine = true })
	end,
}
