return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm",
				transparent = true,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { bold = true },
					sidebars = "transparent",
					floats = "transparent",
				},
			})
			vim.cmd.colorscheme("tokyonight-storm")

			-- 🔹 CHANGE SIDE INDICATORS (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })
			vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#3b4261", bg = "NONE" })

			--  FORCE TRANSPARENCY & FIX BORDERS
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
				vim.api.nvim_set_hl(0, group, { bg = "NONE" })
			end

			-- 🌊 Tokyonight Storm palette accents
			local pink = "#ff7eb6"
			local pink_glow = "#ff9ec7"
			local cyan = "#7dcfff"
			local cyan_glow = "#b4f9f8"
			local purple = "#9d7cd8"
			local magenta = "#bb9af7"
			local green = "#9ece6a"
			local lime = "#73daca"
			local yellow = "#e0af68"
			local orange = "#ff9e64"
			local red = "#f7768e"
			local blue = "#7aa2f7"
			local muted = "#565f89"

			-- 🟢 ORGMODE COLORS
			vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = red, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = green, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.checked", { fg = green, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.half_checked", { fg = green, bg = "NONE", bold = true })

			-- 🟣 Neorg markup aligned with tokyonight storm palette
			vim.api.nvim_set_hl(0, "@neorg.markup.bold", { fg = yellow, bold = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.italic", { fg = purple, italic = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.underline", { fg = cyan, underline = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.strikethrough", { fg = muted, strikethrough = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.verbatim", { fg = lime })

			-- Headings: cycle through the tokyonight storm accents
			local heading_palette = { blue, cyan, purple, pink, lime, orange }
			for i, color in ipairs(heading_palette) do
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title", { fg = color, bold = true })
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix", { fg = color, bold = true })
			end

			-- Keep accents available to callers that want them
			_G.tokyonight_accents = {
				pink = pink,
				pink_glow = pink_glow,
				cyan = cyan,
				cyan_glow = cyan_glow,
				purple = purple,
				magenta = magenta,
				green = green,
				lime = lime,
				yellow = yellow,
				orange = orange,
				red = red,
				blue = blue,
				muted = muted,
			}
		end,
	},
}
