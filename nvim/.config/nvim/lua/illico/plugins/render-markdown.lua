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
		heading = {
			-- Badge por patrón de texto del heading (solo del lado de nvim, no
			-- toca el archivo). "Bloque ..." y "Ejercicio ..." se distinguen del
			-- resto de H3/H4 con su propio icono y color de fondo.
			custom = {
				bloque = {
					pattern = "^Bloque",
					icon = "▊ ",
					background = "RmBloqueBg",
					foreground = "RmBloqueFg",
				},
				ejercicio = {
					pattern = "^Ejercicio",
					icon = "▍ ",
					background = "RmEjercicioBg",
					foreground = "RmEjercicioFg",
				},
			},
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		-- Colores de los badges. En grupos propios para que sobrevivan a la
		-- transparencia global y a recargas de colorscheme.
		local function hls()
			vim.api.nvim_set_hl(0, "RmBloqueFg", { fg = "#89b4fa", bold = true }) -- azul
			vim.api.nvim_set_hl(0, "RmBloqueBg", { fg = "#89b4fa", bg = "#1e3050", bold = true })
			vim.api.nvim_set_hl(0, "RmEjercicioFg", { fg = "#a6e3a1", bold = true }) -- verde
			vim.api.nvim_set_hl(0, "RmEjercicioBg", { fg = "#a6e3a1", bg = "#1e3a2a", bold = true })
		end
		hls()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("illico_rendermd_hl", { clear = true }),
			callback = hls,
		})
	end,
}
