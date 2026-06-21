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
		-- del cursor y re-renderiza en CADA movimiento. Con saltos de 10 líneas
		-- (J/K) y C-d/C-u eso provoca redibujados constantes y el tirón visible.
		-- Desactivarlo deja la línea siempre renderizada -> scroll fluido.
		anti_conceal = { enabled = false },
	},
}
