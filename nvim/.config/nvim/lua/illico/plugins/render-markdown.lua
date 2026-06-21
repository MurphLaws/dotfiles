return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown", "quarto" },
	opts = {
		-- LaTeX off: no hay parser latex instalado (evita warnings de checkhealth).
		latex = { enabled = false },
		file_types = { "markdown", "quarto" },
		-- anti_conceal off: evita el re-render por movimiento del cursor (lag).
		anti_conceal = { enabled = false },
		heading = {
			-- Sin "flags": ni sign en el gutter ni icono circular inline. El '#'
			-- se sigue ocultando (icono = string vacío) y el texto queda al margen.
			-- Se conservan los fondos (highlight) y los colores por nivel.
			sign = false,
			icons = { "", "", "", "", "", "" },
			position = "inline",
		},
		pipe_table = {
			-- render-markdown NO es fold-aware: el borde de la tabla (líneas
			-- virtuales) se "filtra" cuando la sección está plegada. Sin borde no
			-- hay nada que filtrar; las celdas se siguen alineando.
			border_enabled = false,
		},
	},
}
