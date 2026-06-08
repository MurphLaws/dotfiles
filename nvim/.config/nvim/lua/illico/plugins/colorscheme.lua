return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night", -- darkest variant — matches the near-black, transparent setup
			transparent = true, -- let ghostty/tmux blur show through
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = false },
				floats = "transparent",
				sidebars = "transparent",
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight-night")

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

			-- Tokyo Night (Night) palette, mapped onto the accent keys the rest of
			-- the config already consumes (lualine, mini.icons, org/neorg overrides).
			-- Key names are historical handles — the values are pure Tokyo Night.
			local p = {
				coral = "#ff9e64", -- orange
				peach = "#ff9e64", -- orange
				green = "#9ece6a",
				amber = "#e0af68", -- yellow
				gold = "#e0af68", -- yellow
				sky = "#7dcfff", -- cyan
				blue = "#7aa2f7",
				mauve = "#bb9af7", -- magenta
				purple = "#9d7cd8",
				red = "#f7768e",
				fg_dim = "#565f89", -- comment
			}

			-- Orgmode
			vim.api.nvim_set_hl(0, "@org.keyword.todo", { fg = p.coral, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.keyword.done", { fg = p.green, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.checked", { fg = p.green, bg = "NONE", bold = true })
			vim.api.nvim_set_hl(0, "@org.checkbox.half_checked", { fg = p.amber, bg = "NONE", bold = true })

			-- Neorg markup
			vim.api.nvim_set_hl(0, "@neorg.markup.bold", { fg = p.amber, bold = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.italic", { fg = p.mauve, italic = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.underline", { fg = p.sky, underline = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.strikethrough", { fg = p.fg_dim, strikethrough = true })
			vim.api.nvim_set_hl(0, "@neorg.markup.verbatim", { fg = p.green })

			local heading_palette = { p.coral, p.amber, p.green, p.sky, p.mauve, p.peach }
			for i, color in ipairs(heading_palette) do
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title", { fg = color, bold = true })
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix", { fg = color, bold = true })
			end

			-- Expose accents to other plugins (lualine, mini.icons, incline, etc).
			-- Global names kept for back-compat; values are Tokyo Night.
			_G.superset_palette = p
			_G.superset_accents = p
			_G.tokyonight_accents = {
				pink = p.coral,
				pink_glow = p.peach,
				cyan = p.sky,
				cyan_glow = p.sky,
				purple = p.purple,
				magenta = p.mauve,
				green = p.green,
				lime = p.green,
				yellow = p.amber,
				orange = p.coral,
				red = p.red,
				blue = p.blue,
				muted = p.fg_dim,
			}
		end,
	},
}
