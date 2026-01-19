return {
	{
		"filipjanevski/0x96f.nvim",
		priority = 1000,
		config = function()
			require("0x96f").setup()
			vim.cmd.colorscheme("0x96f")

			-- 🔹 CHANGE SIDE INDICATORS (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })
			vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#ffffff", bg = "none" })

			--  FORCE TRANSPARENCY & FIX BORDERS
			local highlights = {
				"Normal",
				"NormalFloat",
				"NormalNC",
				"SignColumn",
				"Pmenu",
				"FloatBorder",
				"TelescopeNormal",
				"TelescopeBorder",
				"TelescopePromptNormal",
				"TelescopePromptBorder",
				"TelescopeResultsNormal",
				"TelescopeResultsBorder",
				"TelescopePreviewNormal",
				"TelescopePreviewBorder",
				"WhichKeyFloat",
				"WhichKeyBorder",
				"SnacksPicker",
				"SnacksPickerNormal",
				"SnacksPickerBorder",
				"SnacksPickerTitle",
				"SnacksPickerPrompt",
				"SnacksPickerInput",
				"SnacksPickerList",
			}

			for _, group in ipairs(highlights) do
				vim.api.nvim_set_hl(0, group, { bg = "none" })
			end

			-- 🟢 FIX ORGMODE COLORS
			local lime_green = "#C6E472"
			local theme_red = "#fb5e5b" -- Red from 0x96f palette

			-- Set TODO to Red
			vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = theme_red, bg = "none", bold = true })

			-- Keep DONE and Checks as Green
			vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = lime_green, bg = "none", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.checked", { fg = lime_green, bg = "none", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.half_checked", { fg = lime_green, bg = "none", bold = true })
		end,
	},
}
