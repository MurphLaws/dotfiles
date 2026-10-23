-- Oxide como tema activo, con fondo transparente:
-- Normal/floats sin bg, así se ve la translucidez de ghostty a través de nvim.
return {
	{
		"oxidescheme/nvim",
		name = "oxide",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			-- Itálicas desactivadas para mantener la fuente estándar del código.
			styles = {
				comments = { italic = false },
			},
			-- La paleta base de oxide es plana (L=0.70 en OKLCH); con la
			-- transparencia pierde contraste. Se promueven los acentos a su
			-- variante bright (L=0.80) y el texto principal a bright_text.
			on_colors = function(c)
				for _, k in ipairs({ "red", "orange", "yellow", "lime", "green", "teal", "sky", "blue", "purple", "pink" }) do
					c[k] = c["bright_" .. k]
				end
				c.text = c.bright_text
			end,
		},
		config = function(_, opts)
			require("oxide").setup(opts)
			vim.cmd.colorscheme("oxide")
		end,
	},
	-- Tokyonight queda instalado para volver con :colorscheme tokyonight.
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
				comments = { italic = false },
				keywords = { italic = false },
			},
		},
	},
	-- Onedark es el tema que current-theme.lua deja activo vía el theme
	-- switcher; antes llegaba de contrabando como dependencia de modicator.
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			-- El fg de fábrica (#abb2bf) es gris y los acentos saturan mucho
			-- con la transparencia de ghostty: blanco casi puro y paleta pastel.
			colors = {
				fg = "#f0f0f0",
				red = "#ed8796",
				green = "#a6da95",
				yellow = "#eed49f",
				blue = "#8aadf4",
				purple = "#c6a0f6",
				cyan = "#8bd5ca",
				orange = "#f5a97f",
			},
		},
	},
}
