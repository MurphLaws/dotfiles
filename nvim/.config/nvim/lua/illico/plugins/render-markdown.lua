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
			icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
			position = "inline",
			backgrounds = {},
		},
		code = {
			sign = false,
		},
		bullet = {
			-- Marcador según el caracter fuente: `-` sigue siendo un guion,
			-- mientras que `*` se dibuja como `•` para distinguir a simple vista
			-- las dos clases de lista. Ambos se colorean de rojo vía
			-- RenderMarkdownBullet (ver enforce_bullet). `+` cae en el guion.
			icons = function(ctx)
				local marker = (ctx.value or ""):sub(1, 1)
				if marker == "*" then
					return "•"
				end
				return "-"
			end,
		},
		-- Guías verticales por sección. Se dibujan en el `statuscolumn` (ver
		-- illico.util.md_section_bars) en lugar del indent nativo de
		-- render-markdown: el statuscolumn se repite en las filas envueltas
		-- (wrap) y vive en el gutter, así la barra no se corta ni pisa el texto.
		-- Por eso el indent nativo va deshabilitado.
		indent = {
			enabled = false,
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

		-- Color atenuado para headings vacíos (sin contenido antes del
		-- siguiente heading de igual o mayor jerarquía). Se aplica al icono y
		-- al texto del heading mediante el parche de heading de más abajo.
		local function enforce_dim()
			vim.api.nvim_set_hl(0, "RenderMarkdownDim", { link = "Comment", default = false })
		end
		enforce_dim()

		-- Marcador de lista en rojo (mismo rojo del título/H1 del tema).
		local function enforce_bullet()
			vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#e55561", default = false })
		end
		enforce_bullet()

		-- Atenuar headings vacíos. render-markdown colorea el icono del heading
		-- con `self.data.fg` y el TÍTULO lo colorea treesitter
		-- (@markup.heading.N). Para atenuar ambos envolvemos el render de
		-- heading: si la sección no tiene contenido (solo líneas en blanco antes
		-- del siguiente heading de nivel <= al actual, o EOF) usamos el color
		-- atenuado en el icono y añadimos una marca de mayor prioridad sobre el
		-- texto. Un heading seguido por uno más profundo (nivel mayor) SÍ tiene
		-- estructura, así que no se atenúa.
		local ok_head, Heading = pcall(require, "render-markdown.render.markdown.heading")
		if ok_head and Heading.setup and Heading.run then
			local function heading_is_empty(node, level)
				local buf = node.buf
				local lines = vim.api.nvim_buf_get_lines(buf, node.start_row + 1, -1, false)
				for _, line in ipairs(lines) do
					local s = line:match("^%s*(.-)%s*$")
					if s == "" then
						-- línea en blanco: seguir buscando
					elseif s:match("^```") or s:match("^~~~") then
						return false -- bloque de código = contenido
					else
						local hashes = s:match("^(#+)%s")
						if hashes then
							-- otro heading: vacío solo si es de igual o mayor
							-- jerarquía (nivel <=); uno más profundo es contenido.
							return #hashes <= level
						end
						return false -- texto plano = contenido
					end
				end
				return true -- EOF sin contenido
			end

			local orig_setup = Heading.setup
			function Heading:setup(...)
				local ok = orig_setup(self, ...)
				self._dim = false
				if ok and self.data and self.data.atx then
					if heading_is_empty(self.node, self.data.level) then
						self._dim = true
						self.data.fg = "RenderMarkdownDim"
					end
				end
				return ok
			end

			local orig_run = Heading.run
			function Heading:run(...)
				orig_run(self, ...)
				if self._dim then
					local inline = self.node:child("inline")
					if inline then
						self.marks:add(self.config, "head_icon", inline.start_row, inline.start_col, {
							end_row = inline.end_row,
							end_col = inline.end_col,
							hl_group = "RenderMarkdownDim",
							priority = 5000,
						})
					end
				end
			end
		end

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("RenderMarkdownLinkUnderline", { clear = true }),
			callback = function()
				underline_links()
				enforce_strikethrough()
				enforce_dim()
				enforce_bullet()
			end,
		})

		-- Barras de sección en el statuscolumn (gutter): se repiten en las filas
		-- envueltas y desplazan todo el texto por igual, así el wrap no corta la
		-- guía ni pisa el contenido. `linebreak` corta en límites de palabra.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("RenderMarkdownWrap", { clear = true }),
			pattern = "markdown",
			callback = function()
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
				require("illico.util.md_section_bars").attach(vim.api.nvim_get_current_buf())
			end,
		})
	end,
}
