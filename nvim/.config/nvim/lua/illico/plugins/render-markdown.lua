return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown", "quarto" },
	-- LaTeX desactivado: no hay parser latex ni latex2text/utftex instalados.
	-- Evita los warnings de :checkhealth render-markdown.
	-- file_types incluye quarto para embellecer/concealar también los .qmd.
	opts = {
		latex = { enabled = false },
		file_types = { "markdown", "quarto" },
	},
}
