return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "darker",
			transparent = true,
		},
		config = function(_, opts)
			require("onedark").setup(opts)

			vim.opt.background = "dark"

			-- Side indicators (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })

			vim.cmd.colorscheme("onedark")

			-- nvim hereda siempre la transparencia de Ghostty.
			local ghostty_bg = "NONE"
			for _, group in ipairs({ "Normal", "NormalNC", "EndOfBuffer", "SignColumn", "LineNr" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group })
				hl.bg = ghostty_bg
				vim.api.nvim_set_hl(0, group, hl)
			end

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

			local heading_palette = { p.coral, p.amber, p.green, p.sky, p.mauve, p.peach }
			for i, color in ipairs(heading_palette) do
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".title", { fg = color, bold = true })
				vim.api.nvim_set_hl(0, "@neorg.headings." .. i .. ".prefix", { fg = color, bold = true })
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
