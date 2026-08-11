return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "storm",
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)

			vim.opt.background = "dark"

			-- Side indicators (End of Buffer)
			vim.opt.fillchars:append({ eob = "·" })

			vim.cmd.colorscheme("tokyonight-storm")

			-- nvim hereda siempre la transparencia de Ghostty.
			local ghostty_bg = "NONE"
			for _, group in ipairs({ "Normal", "NormalNC", "EndOfBuffer", "SignColumn", "LineNr" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group })
				hl.bg = ghostty_bg
				vim.api.nvim_set_hl(0, group, hl)
			end

			-- Paleta tokyonight storm, mapeada a las claves de acento que el resto
			-- de la config ya consume (lualine, mini.icons, org/neorg overrides).
			-- Los nombres de las claves son históricos — los valores son tokyonight.
			local p = {
				coral = "#f7768e", -- red/pink
				peach = "#ff9e64", -- orange
				green = "#9ece6a", -- green
				amber = "#e0af68", -- yellow
				gold = "#e0af68", -- yellow
				sky = "#7dcfff", -- cyan
				blue = "#7aa2f7", -- blue
				mauve = "#bb9af7", -- purple/magenta
				purple = "#bb9af7", -- purple/magenta
				red = "#f7768e", -- red
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
			-- Global names kept for back-compat; values are tokyonight storm.
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
