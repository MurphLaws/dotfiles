return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	-- LaTeX off (no hay parser, evita warnings de checkhealth) y anti_conceal
	-- off (evita el re-render por movimiento del cursor que daba lag).
	-- Look limpio: headings con números en círculo y sin banda de fondo,
	-- links sin icono de cadena.
	opts = {
		latex = { enabled = false },
		file_types = { "markdown" },
		anti_conceal = { enabled = false },
		heading = {
			sign = false,
			icons = { "❯ ", "❯❯ ", "❯❯❯ ", "❯❯❯❯ ", "❯❯❯❯❯ ", "❯❯❯❯❯❯ " },
			position = "inline",
			backgrounds = {},
		},
		code = {
			sign = false,
		},
		link = {
			wiki = { icon = "" },
			hyperlink = "",
			custom = {
				web = { pattern = "^http", icon = "" },
			},
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)

		-- Links subrayados (conserva el color del colorscheme y agrega underline)
		local function underline_links()
			for _, group in ipairs({ "RenderMarkdownLink", "RenderMarkdownWikiLink" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
				hl.underline = true
				vim.api.nvim_set_hl(0, group, hl)
			end
		end
		underline_links()

		-- Tachado real en ~~texto~~: fuerza el atributo strikethrough en el
		-- grupo de treesitter (y el legacy) por si el colorscheme lo pisa.
		-- Requiere una terminal que soporte el SGR de tachado (kitty, wezterm,
		-- ghostty; NO alacritty).
		local function enforce_strikethrough()
			for _, group in ipairs({ "@markup.strikethrough", "@text.strike" }) do
				local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
				hl.strikethrough = true
				vim.api.nvim_set_hl(0, group, hl)
			end
		end
		enforce_strikethrough()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("RenderMarkdownLinkUnderline", { clear = true }),
			callback = function()
				underline_links()
				enforce_strikethrough()
			end,
		})
	end,
}
