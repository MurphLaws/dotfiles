return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha",
			transparent_background = true, -- let ghostty/tmux blur show through
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

			-- Reaplicar la transparencia en cada ColorScheme. Hacerlo dentro del
			-- evento (y no solo una vez) mantiene `Normal` sin bg sincronizado con
			-- el caché de transparencia de snacks.nvim, que se invalida justo en
			-- este evento. Si no, snacks cachea "no transparente", luego Normal
			-- pierde el bg y revienta al mezclar el backdrop (fg nil en blend()).
			local function apply_transparency()
				for _, group in ipairs(transparent_groups) do
					-- Preservar fg y demás atributos; solo limpiar el fondo.
					-- Pasar { bg = "NONE" } a secas REEMPLAZA el grupo y borra el
					-- fg, lo que dejaba Normal/NormalFloat sin foreground y hacía
					-- crashear a snacks.gh al mezclar colores (fg nil en blend()).
					local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
					hl.bg = "NONE"
					hl.ctermbg = nil
					vim.api.nvim_set_hl(0, group, hl)
				end
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("illico_transparency", { clear = true }),
				callback = apply_transparency,
			})

			vim.cmd.colorscheme("catppuccin-mocha")
			apply_transparency()

			-- Catppuccin Mocha palette, mapped onto the accent keys the rest of
			-- the config already consumes (lualine, mini.icons, org/neorg overrides).
			-- Key names are historical handles — the values are pure Catppuccin Mocha.
			local p = {
				coral = "#fab387", -- peach
				peach = "#fab387", -- peach
				green = "#a6e3a1",
				amber = "#f9e2af", -- yellow
				gold = "#f9e2af", -- yellow
				sky = "#89dceb", -- sky
				blue = "#89b4fa",
				mauve = "#cba6f7", -- mauve
				purple = "#b4befe", -- lavender
				red = "#f38ba8",
				fg_dim = "#6c7086", -- overlay0 (comment)
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
			-- Global names kept for back-compat; values are Catppuccin Mocha.
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
