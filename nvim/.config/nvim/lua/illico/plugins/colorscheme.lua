return {
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.background = "dark"

			-- Side indicators (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })

			vim.cmd.colorscheme("oxocarbon")

			-- Fondo igual al de ghostty (tema 0x96f) en vez del #161616 de oxocarbon
			local ghostty_bg = "#262427"
			for _, group in ipairs({ "Normal", "NormalNC", "EndOfBuffer", "SignColumn", "LineNr" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group })
				hl.bg = ghostty_bg
				vim.api.nvim_set_hl(0, group, hl)
			end

			-- Paleta oxocarbon (IBM Carbon), mapeada a las claves de acento que el
			-- resto de la config ya consume (lualine, mini.icons, org/neorg overrides).
			-- Los nombres de las claves son históricos — los valores son oxocarbon.
			local p = {
				coral = "#ff7eb6", -- pink (base12)
				peach = "#ff7eb6", -- pink (base12)
				green = "#42be65", -- base13
				amber = "#3ddbd9", -- teal claro (base08) — oxocarbon no tiene amarillo
				gold = "#3ddbd9", -- teal claro (base08)
				sky = "#82cffa", -- base15
				blue = "#78a9ff", -- base09
				mauve = "#be95ff", -- base14
				purple = "#be95ff", -- base14
				red = "#ee5396", -- base10
				fg_dim = "#525252", -- base03 (comment)
			}

			-- Menús "block" sin bordes: cada menú se diferencia por un fondo plano
			-- distinto. Tonos base de oxocarbon.
			-- Más oscuros que el fondo (#262427) para que los menús se despeguen
			local crust = "#0b0b0b"
			local mantle = "#141414" -- floats / telescope
			local surface0 = "#1e1e1e" -- pmenu / cmp / prompt
			local surface1 = "#333333" -- selección / scrollbar
			local text = "#f2f4f8" -- base05

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
			-- Global names kept for back-compat; values are oxocarbon.
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
