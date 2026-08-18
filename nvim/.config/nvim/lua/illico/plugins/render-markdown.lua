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
		bullet = {
			icons = { "·", "◦", "▪", "‣" },
		},
		-- Guías verticales por sección, una barra por cada heading coloreada
		-- según su nivel (título `#` = color H1, `##` = H2, ...). skip_level=0
		-- para que el título también muestre su barra. El color por nivel se
		-- logra parcheando el módulo indent más abajo (render-markdown usa un
		-- único highlight de forma nativa).
		indent = {
			enabled = true,
			icon = "▎",
			skip_level = 0,
			skip_heading = false,
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

		-- Barra de sección con el color de cada heading: render-markdown dibuja
		-- todas las guías de indentación con un único highlight. Parcheamos
		-- `Indent:line` para que la columna i (nivel de anidamiento i) use el
		-- color del heading de nivel i (RenderMarkdownH1..H6). Con skip_level=0
		-- la columna 1 = H1 (título) → barra roja; columna 2 = H2 → morada; etc.
		local ok_indent, Indent = pcall(require, "render-markdown.lib.indent")
		local ok_str, str = pcall(require, "render-markdown.lib.str")
		if ok_indent and ok_str and Indent.line then
			function Indent:line(virtual, level)
				if virtual then
					level = self:level(level)
				else
					assert(level, "level must be known for non-virtual lines")
				end
				local line = self.context.config:line()
				if level > 0 then
					local icon = self.config.icon
					local icon_width = str.width(icon)
					if icon_width == 0 then
						line:pad(self.config.per_level * level)
					else
						for i = 1, level do
							local hl_level = math.min(i + self.config.skip_level, 6)
							line:text(icon, "RenderMarkdownH" .. hl_level)
							line:pad(self.config.per_level - icon_width)
						end
					end
				end
				return line
			end
		end

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("RenderMarkdownLinkUnderline", { clear = true }),
			callback = function()
				underline_links()
				enforce_strikethrough()
			end,
		})
	end,
}
