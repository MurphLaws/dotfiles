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
					-- ⚠️ This helps, but custom_highlights below finishes the job
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

			-- 🟢 FORCE TELESCOPE TRANSPARENCY
			custom_highlights = function(colors)
				return {
					-- Force transparent backgrounds for all Telescope elements
					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { bg = "NONE" },
					TelescopePromptNormal = { bg = "NONE" },
					TelescopePromptBorder = { bg = "NONE" },
					TelescopeResultsNormal = { bg = "NONE" },
					TelescopeResultsBorder = { bg = "NONE" },
					TelescopePreviewNormal = { bg = "NONE" },
					TelescopePreviewBorder = { bg = "NONE" },

					-- Optional: Make the selection transparent too (or keep it colored)
					-- TelescopeSelection = { bg = "NONE", fg = colors.red },
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
