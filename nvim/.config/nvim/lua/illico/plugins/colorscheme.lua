return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "macchiato",
			transparent_background = false,
			term_colors = true,
			styles = {
				comments = { "italic" },
				keywords = {},
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)

			-- Side indicators (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })

			vim.cmd.colorscheme("catppuccin-macchiato")

			-- Catppuccin Macchiato palette, mapped onto the accent keys the rest of
			-- the config already consumes (lualine, mini.icons, org/neorg overrides).
			-- Key names are historical handles — the values are pure Catppuccin Macchiato.
			local p = {
				coral = "#f5a97f", -- peach
				peach = "#f5a97f", -- peach
				green = "#a6da95",
				amber = "#eed49f", -- yellow
				gold = "#eed49f", -- yellow
				sky = "#91d7e3", -- sky
				blue = "#8aadf4",
				mauve = "#c6a0f6", -- mauve
				purple = "#b7bdf8", -- lavender
				red = "#ed8796",
				fg_dim = "#6e738d", -- overlay0 (comment)
			}

			-- Borderless "block" menus (estilo oxocarbon): sin bordes, cada menú
			-- se diferencia por un fondo plano distinto. Tonos base de Macchiato.
			local crust = "#181926"
			local mantle = "#1e2030"
			local surface0 = "#363a4f"
			local surface1 = "#494d64"
			local text = "#cad3f5"

			-- Floats genéricos (LSP hover, diagnósticos, which-key, etc.)
			vim.api.nvim_set_hl(0, "NormalFloat", { fg = text, bg = mantle })
			vim.api.nvim_set_hl(0, "FloatBorder", { fg = mantle, bg = mantle })
			vim.api.nvim_set_hl(0, "FloatTitle", { fg = crust, bg = p.mauve, bold = true })

			-- Menú de completado (pmenu + ventanas de nvim-cmp)
			vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = surface0 })
			vim.api.nvim_set_hl(0, "PmenuSel", { fg = crust, bg = p.peach, bold = true })
			vim.api.nvim_set_hl(0, "PmenuSbar", { bg = surface0 })
			vim.api.nvim_set_hl(0, "PmenuThumb", { bg = surface1 })
			vim.api.nvim_set_hl(0, "CmpNormal", { fg = text, bg = surface0 })
			vim.api.nvim_set_hl(0, "CmpDoc", { fg = text, bg = mantle })

			-- Telescope: bloques de color, títulos como "chips" de acento
			vim.api.nvim_set_hl(0, "TelescopeNormal", { fg = text, bg = mantle })
			vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = mantle, bg = mantle })
			vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = text, bg = surface0 })
			vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = surface0, bg = surface0 })
			vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = crust, bg = p.peach, bold = true })
			vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = crust, bg = p.green, bold = true })
			vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = mantle, bg = mantle })
			vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = text, bg = surface1, bold = true })

			-- Which-key como bloque sólido
			vim.api.nvim_set_hl(0, "WhichKeyNormal", { fg = text, bg = mantle })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = mantle, bg = mantle })

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
			-- Global names kept for back-compat; values are Catppuccin Macchiato.
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
