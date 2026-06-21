return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown", "quarto" },
	-- Vanilla. Solo: LaTeX off (no hay parser, evita warnings de checkhealth),
	-- soporte de .qmd, y anti_conceal off (evita el re-render por movimiento del
	-- cursor que daba lag al scrollear). Sin customización de headings ni tablas.
	opts = {
		latex = { enabled = false },
		file_types = { "markdown", "quarto" },
		anti_conceal = { enabled = false },
	},
}
