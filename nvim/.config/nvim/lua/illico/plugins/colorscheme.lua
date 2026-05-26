return {
	{
		-- Superset palette — local colorscheme at colors/superset.lua
		name = "superset",
		dir = vim.fn.stdpath("config"),
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("superset")

			-- Side indicators (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })

			-- Force transparency on common float/sidebar groups
			local transparent_groups = {
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
			for _, group in ipairs(transparent_groups) do
				vim.api.nvim_set_hl(0, group, { bg = "NONE" })
			end

			-- Superset palette accents
			local p = _G.superset_palette or {}
			local coral = p.coral or "#d1734a"
			local peach = p.peach or "#d18960"
			local green = p.green or "#67a367"
			local amber = p.amber or "#d1a72a"
			local gold = p.gold or "#ae8a3c"
			local sky = p.sky or "#74a5af"
			local mauve = p.mauve or "#9780b2"
			local purple = p.purple or "#7e689f"
			local red = p.red or "#b85c5c"
			local fg_dim = p.fg_dim or "#6e6863"

			-- Orgmode
			vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = coral, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = green, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.checked", { fg = green, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.half_checked", { fg = amber, bg = "NONE", bold = true })

			-- Neorg markup
			vim.api.nvim_set_hl(0, "@neorg.markup.bold", { fg = amber, bold = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.italic", { fg = mauve, italic = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.underline", { fg = sky, underline = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.strikethrough", { fg = fg_dim, strikethrough = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.verbatim", { fg = green })

			local heading_palette = { coral, amber, green, sky, mauve, peach }
			for i, color in ipairs(heading_palette) do
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title", { fg = color, bold = true })
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix", { fg = color, bold = true })
			end

			-- Expose accents to other plugins (lualine, incline, etc)
			_G.superset_accents = {
				coral = coral,
				peach = peach,
				green = green,
				amber = amber,
				gold = gold,
				sky = sky,
				mauve = mauve,
				purple = purple,
				red = red,
				fg_dim = fg_dim,
			}
			-- Back-compat shim so code that still references tokyonight_accents keeps working
			_G.tokyonight_accents = {
				pink = coral,
				pink_glow = peach,
				cyan = sky,
				cyan_glow = sky,
				purple = purple,
				magenta = mauve,
				green = green,
				lime = green,
				yellow = amber,
				orange = coral,
				red = red,
				blue = sky,
				muted = fg_dim,
			}
		end,
	},
}
