return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "darker",
			transparent = true,
			-- fg más blanco que el #a0a8b7 de "darker" (mismo valor que ghostty)
			colors = { fg = "#dde1e7" },
		},
		config = function(_, opts)
			require("onedark").setup(opts)

			vim.opt.background = "dark"

			-- Side indicators (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })

			-- Separadores entre buffers: glifo grueso (más "grande") pero
			-- totalmente transparente (bg = NONE, sin color propio).
			vim.opt.fillchars:append({ vert = "┃", horiz = "━", horizup = "┻", horizdown = "┳", vertleft = "┫", vertright = "┣", verthoriz = "╋" })

			vim.cmd.colorscheme("onedark")

			-- nvim hereda siempre la transparencia de Ghostty.
			local ghostty_bg = "NONE"
			for _, group in ipairs({ "Normal", "NormalNC", "EndOfBuffer", "SignColumn", "LineNr" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group })
				hl.bg = ghostty_bg
				vim.api.nvim_set_hl(0, group, hl)
			end

			-- Separador entre buffers: sin bg propio (transparente, hereda de
			-- Ghostty) para que el glifo grueso de arriba no se vea como un
			-- bloque de color sólido.
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#535965", bg = "NONE" })
			vim.api.nvim_set_hl(0, "VertSplit", { fg = "#535965", bg = "NONE" })

			-- Paleta onedark darker, mapeada a las claves de acento que el resto
			-- de la config ya consume (lualine, mini.icons, org/neorg overrides).
			-- Los nombres de las claves son históricos — los valores son onedark.
			local p = {
				coral = "#e55561", -- red
				peach = "#cc9057", -- orange
				green = "#8ebd6b", -- green
				amber = "#e2b86b", -- yellow
				gold = "#e2b86b", -- yellow
				sky = "#48b0bd", -- cyan
				blue = "#4fa6ed", -- blue
				mauve = "#bf68d9", -- purple/magenta
				purple = "#bf68d9", -- purple/magenta
				red = "#e55561", -- red
				fg_dim = "#535965", -- comment/grey
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

			-- Markdown énfasis: conserva el efecto característico (negrita, itálica,
			-- tachado) pero con un tinte sutil de color, no tan marcado.
			local em = {
				bold = "#d7c39a", -- oro apagado, cálido y suave
				italic = "#c3aed6", -- lavanda tenue
				strike = "#8a9199", -- gris dim (tachado atenuado)
			}
			for _, suffix in ipairs({ "", ".markdown", ".markdown_inline" }) do
				vim.api.nvim_set_hl(0, "@markup.strong" .. suffix, { fg = em.bold, bold = true })
				vim.api.nvim_set_hl(0, "@markup.italic" .. suffix, { fg = em.italic, italic = true })
				vim.api.nvim_set_hl(
					0,
					"@markup.strikethrough" .. suffix,
					{ fg = em.strike, strikethrough = true }
				)
			end

			local heading_palette = { p.coral, p.amber, p.green, p.sky, p.mauve, p.peach }
			for i, color in ipairs(heading_palette) do
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title", { fg = color, bold = true })
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix", { fg = color, bold = true })
			end

			-- Markdown headings: paleta propia (frío -> cálido) distinta al ciclo
			-- rojo/morado por defecto de onedark. Cubre las variantes de
			-- treesitter y, por herencia, RenderMarkdownH1..H6.
			local md_heading_palette = { p.mauve, p.blue, p.sky, p.green, p.amber, p.peach }
			for i, color in ipairs(md_heading_palette) do
				for _, suffix in ipairs({ "", ".markdown" }) do
					vim.api.nvim_set_hl(0, "@markup.heading." .. i .. suffix, { fg = color, bold = true })
				end
			end

			-- Expose accents to other plugins (lualine, mini.icons, incline, etc).
			-- Global names kept for back-compat; values are onedark darker.
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
