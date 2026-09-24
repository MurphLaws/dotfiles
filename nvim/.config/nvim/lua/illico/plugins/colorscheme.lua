-- Tokyonight night con fondo transparente: Normal/floats/sidebars sin bg,
-- así se ve la translucidez de ghostty (background-opacity) a través de nvim.
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
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	-- Onedark es el tema que current-theme.lua deja activo vía el theme
	-- switcher; antes llegaba de contrabando como dependencia de modicator.
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
	},
}
