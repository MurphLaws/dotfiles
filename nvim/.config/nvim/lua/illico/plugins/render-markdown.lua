return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	-- LaTeX desactivado: no hay parser latex ni latex2text/utftex instalados.
	-- Evita los warnings de :checkhealth render-markdown.
	opts = { latex = { enabled = false } },
}
