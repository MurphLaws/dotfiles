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

			-- Fondo de los menús/flotantes: panel oscuro un poco más opaco que el
			-- editor transparente. Con la opacidad de Ghostty (0.95) se ve como un
			-- panel sólido que resalta sobre el área transparente del editor.
			local float_bg = "#181825" -- Catppuccin mantle

			-- El editor sí queda 100% transparente (deja ver Ghostty/tmux).
			local editor_transparent = {
				"Normal",
				"NormalNC",
				"SignColumn",
			}

			-- Menús y ventanas flotantes: fondo float_bg (panel opaco), fg intacto.
			local float_groups = {
				"NormalFloat",
				"Pmenu",
				"TelescopeNormal",
				"TelescopePromptNormal",
				"TelescopeResultsNormal",
				"TelescopePreviewNormal",
				"WhichKeyNormal",
				"WhichKeyFloat",
				"SnacksPicker",
				"SnacksPickerNormal",
				"SnacksPickerTitle",
				"SnacksPickerPrompt",
				"SnacksPickerInput",
				"SnacksPickerInputTitle",
				"SnacksPickerList",
				"SnacksPickerListTitle",
				"SnacksPickerPreview",
				"SnacksPickerPreviewTitle",
				"SnacksPickerBox",
				"SnacksNormal",
				"SnacksNormalNC",
				"SnacksWinBar",
				"SnacksInput",
				"SnacksInputNormal",
				"SnacksInputTitle",
			}

			-- Bordes invisibles (fg = bg = float_bg): red de seguridad para
			-- cualquier plugin que dibuje borde aunque le pidamos "none". Así no
			-- se ve ningún borde ni esquina redondeada en ningún menú.
			local border_groups = {
				"FloatBorder",
				"TelescopeBorder",
				"TelescopePromptBorder",
				"TelescopeResultsBorder",
				"TelescopePreviewBorder",
				"WhichKeyBorder",
				"SnacksPickerBorder",
				"SnacksPickerInputBorder",
				"SnacksPickerListBorder",
				"SnacksPickerPreviewBorder",
				"SnacksPickerBoxBorder",
				"SnacksInputBorder",
			}

			-- Reaplicar la transparencia en cada ColorScheme. Hacerlo dentro del
			-- evento (y no solo una vez) mantiene `Normal` sin bg sincronizado con
			-- el caché de transparencia de snacks.nvim, que se invalida justo en
			-- este evento. Si no, snacks cachea "no transparente", luego Normal
			-- pierde el bg y revienta al mezclar el backdrop (fg nil en blend()).
			local function apply_transparency()
				-- Editor: 100% transparente. Preservar fg y demás atributos;
				-- pasar { bg = "NONE" } a secas REEMPLAZA el grupo y borra el fg,
				-- lo que dejaba Normal sin foreground y hacía crashear snacks.gh.
				for _, group in ipairs(editor_transparent) do
					local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
					hl.bg = "NONE"
					hl.ctermbg = nil
					vim.api.nvim_set_hl(0, group, hl)
				end

				-- Menús/flotantes: panel opaco float_bg, conservando el fg.
				for _, group in ipairs(float_groups) do
					local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
					hl.bg = float_bg
					hl.ctermbg = nil
					vim.api.nvim_set_hl(0, group, hl)
				end

				-- Bordes invisibles.
				for _, group in ipairs(border_groups) do
					vim.api.nvim_set_hl(0, group, { fg = float_bg, bg = float_bg })
				end

				-- Números de línea legibles: el LineNr de Catppuccin (#45475a) casi
				-- no contrasta sobre el fondo transparente. overlay1 (#7f849c) se ve
				-- sin robar protagonismo. bg = NONE conserva la transparencia.
				vim.api.nvim_set_hl(0, "LineNr", { fg = "#7f849c", bg = "NONE" })
				vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#7f849c", bg = "NONE" })
				vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#7f849c", bg = "NONE" })
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
