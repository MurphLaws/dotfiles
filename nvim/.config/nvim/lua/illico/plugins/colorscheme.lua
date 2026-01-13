return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha",
			background = {
				light = "latte",
				dark = "mocha",
			},
			transparent_background = true, -- Must be true
			term_colors = true,
			dim_inactive = {
				enabled = false,
			},
			styles = {
				comments = { "italic" },
				keywords = { "italic" },
				functions = {},
				variables = {},
			},
			integrations = {
				treesitter = true,
				lualine = true,
				cmp = true,
				gitsigns = true,
				telescope = {
					enabled = true,
				},
				which_key = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
				mason = true,
			},

			-- 🟢 CUSTOM HIGHLIGHTS (The Source of Truth)
			custom_highlights = function(colors)
				return {
					-- 1. TELESCOPE TRANSPARENCY
					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { bg = "NONE" },
					TelescopePromptNormal = { bg = "NONE" },
					TelescopePromptBorder = { bg = "NONE" },
					TelescopeResultsNormal = { bg = "NONE" },
					TelescopeResultsBorder = { bg = "NONE" },
					TelescopePreviewNormal = { bg = "NONE" },
					TelescopePreviewBorder = { bg = "NONE" },

					-- 2. ORGMODE HEADLINES (Official Catppuccin Palette)
					-- Using the colors object ensures perfect theme integration
					OrgHeadlineLevel1 = { fg = colors.red, bold = true },
					OrgHeadlineLevel2 = { fg = colors.peach, bold = true },
					OrgHeadlineLevel3 = { fg = colors.yellow, bold = true },
					OrgHeadlineLevel4 = { fg = colors.green, bold = true },
					OrgHeadlineLevel5 = { fg = colors.sapphire, bold = true },
					OrgHeadlineLevel6 = { fg = colors.mauve, bold = true },
					OrgHeadlineLevel7 = { fg = colors.teal, bold = true },
					OrgHeadlineLevel8 = { fg = colors.maroon, bold = true },

					-- 3. MARKDOWN HEADLINES (Standard Syntax)
					markdownH1 = { link = "OrgHeadlineLevel1" },
					markdownH2 = { link = "OrgHeadlineLevel2" },
					markdownH3 = { link = "OrgHeadlineLevel3" },
					markdownH4 = { link = "OrgHeadlineLevel4" },
					markdownH5 = { link = "OrgHeadlineLevel5" },
					markdownH6 = { link = "OrgHeadlineLevel6" },

					-- 4. MARKDOWN HEADLINES (Treesitter Syntax)
					["@markup.heading.1.markdown"] = { link = "OrgHeadlineLevel1" },
					["@markup.heading.2.markdown"] = { link = "OrgHeadlineLevel2" },
					["@markup.heading.3.markdown"] = { link = "OrgHeadlineLevel3" },
					["@markup.heading.4.markdown"] = { link = "OrgHeadlineLevel4" },
					["@markup.heading.5.markdown"] = { link = "OrgHeadlineLevel5" },
					["@markup.heading.6.markdown"] = { link = "OrgHeadlineLevel6" },
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
