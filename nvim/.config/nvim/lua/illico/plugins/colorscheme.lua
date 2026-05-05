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

			-- 🟣 Neorg markup aligned with 0x96f palette (acentos típicos)
			local orange = "#FC9D6F"
			local yellow = "#FFCA58"
			local p_green = "#BCDF59"
			local cyan = "#AEE8F4"
			local blue = "#49CAE4"
			local purple = "#A093E2"
			local muted = "#7A7682"

			-- Inline markup
			vim.api.nvim_set_hl(0, "@neorg.markup.bold", { fg = yellow, bold = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.italic", { fg = purple, italic = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.underline", { fg = cyan, underline = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.strikethrough", { fg = muted, strikethrough = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.verbatim", { fg = p_green })

			-- Headings: paleta cohesiva (cycle through the 0x96f accents)
			local heading_palette = { orange, yellow, p_green, cyan, blue, purple }
			for i, color in ipairs(heading_palette) do
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title", { fg = color, bold = true })
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix", { fg = color, bold = true })
				-- Lists comparten color con su heading equivalente
				vim.api.nvim_set_hl(0, "@neorg.lists.unordered." .. i .. ".content", { fg = color })
				vim.api.nvim_set_hl(0, "@neorg.lists.ordered." .. i .. ".content", { fg = color })
			end
		end,
	},
}
