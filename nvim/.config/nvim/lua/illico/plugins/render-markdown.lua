return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	-- Vanilla. Solo: LaTeX off (no hay parser, evita warnings de checkhealth),
	-- y anti_conceal off (evita el re-render por movimiento del cursor que daba
	-- lag al scrollear). Sin customización de headings ni tablas.
	opts = {
		latex = { enabled = false },
		file_types = { "markdown" },
		anti_conceal = { enabled = false },
	},
}
