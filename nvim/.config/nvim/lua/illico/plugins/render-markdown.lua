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
		-- Antilag al scrollear: anti_conceal revela el markdown crudo en la línea
		-- del cursor y re-renderiza en CADA movimiento. Desactivarlo deja la línea
		-- siempre renderizada -> scroll fluido. (La distinción visual de jornadas/
		-- bloques/ejercicios se hace al PLEGAR vía foldtext.nvim.)
		anti_conceal = { enabled = false },
	},
}
