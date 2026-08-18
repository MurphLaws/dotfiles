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
			-- Corta la barra en la línea del propio heading para que cada
			-- sección se vea como un bloque independiente (el break que se pidió).
			skip_heading = true,
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

		-- Barra de sección con el color de cada heading. render-markdown dibuja
		-- las guías por sección y de forma apilada: cada sección aporta solo su
		-- `level_change` (normalmente 1 barra) mediante marcas inline en la
		-- columna 0, no la profundidad absoluta. Por eso hay que derivar el
		-- nivel ABSOLUTO de cada barra desde el nodo de la sección
		-- (`self.node:level(false)`) y no del índice del bucle; de lo contrario
		-- todas las barras tomaban H1 (rojo). Con el nivel absoluto, la barra
		-- del título `#` = H1 (roja), `##` = H2 (morada), `###` = H3, etc.
		local ok_indent, Indent = pcall(require, "render-markdown.lib.indent")
		local ok_str, str = pcall(require, "render-markdown.lib.str")
		if ok_indent and ok_str and Indent.line then
			function Indent:line(virtual, level)
				local base
				if virtual then
					level = self:level(level)
					base = 0
				else
					assert(level, "level must be known for non-virtual lines")
					-- Nivel absoluto del heading de esta sección menos las
					-- barras que aporta = nivel del padre (base sobre la que
					-- apilamos). base + i da el nivel real de la columna i.
					local ok_lvl, cur = pcall(function()
						return self.node:level(false)
					end)
					base = (ok_lvl and cur or level) - level
				end
				local line = self.context.config:line()
				if level > 0 then
					local icon = self.config.icon
					local icon_width = str.width(icon)
					if icon_width == 0 then
						line:pad(self.config.per_level * level)
					else
						for i = 1, level do
							local hl_level = math.max(1, math.min(base + i, 6))
							line:text(icon, "RenderMarkdownH" .. hl_level)
							line:pad(self.config.per_level - icon_width)
						end
					end
				end
				return line
			end
		end

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
			end,
		})

		-- render-markdown pinta la barra de sección como virt_text inline en la
		-- fila real de cada línea. Con `wrap` + `breakindent` (nvim >= 0.10 tiene
		-- en cuenta el virt_text inline) las líneas envueltas se indentan y
		-- arrancan DESPUÉS de la barra, sin cruzarla ni pisar el contenido.
		-- `linebreak` corta en límites de palabra.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("RenderMarkdownWrap", { clear = true }),
			pattern = "markdown",
			callback = function()
				vim.opt_local.wrap = true
				vim.opt_local.breakindent = true
				vim.opt_local.linebreak = true
			end,
		})
	end,
}
