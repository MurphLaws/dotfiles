-- Tokyonight como tema activo, con fondo transparente:
-- Normal/floats sin bg, así se ve la translucidez de ghostty a través de nvim.
return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
				-- Itálicas desactivadas para mantener la fuente estándar del código.
				comments = { italic = false },
				keywords = { italic = false },
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	-- Oxide queda instalado para volver con :colorscheme oxide.
	{
		"oxidescheme/nvim",
		name = "oxide",
		lazy = false,
		priority = 1000,
		opts = { transparent = true },
	},
	-- Onedark es el tema que current-theme.lua deja activo vía el theme
	-- switcher; antes llegaba de contrabando como dependencia de modicator.
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
	},
}
