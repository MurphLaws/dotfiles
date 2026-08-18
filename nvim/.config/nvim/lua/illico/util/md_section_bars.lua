-- Guías de sección verticales para markdown dibujadas en el `statuscolumn`.
--
-- render-markdown dibuja sus guías de indentación como virt_text inline dentro
-- del área de texto. Eso tiene dos problemas irresolubles:
--   1. Al envolver una línea (`wrap`) el virt_text inline NO se repite en las
--      filas de continuación, así que la barra se "corta" (Neovim no soporta
--      `virt_text_repeat_linebreak` para inline, ni `breakindent` cuenta el
--      virt_text inline).
--   2. El apilado de varias marcas inline en la misma columna puede invertir el
--      orden visual de los colores.
--
-- Dibujarlas en el `statuscolumn` (el canalón/gutter) resuelve ambas cosas: el
-- statuscolumn se evalúa en CADA fila de pantalla —incluidas las envueltas
-- (`v:virtnum > 0`)— y vive en el gutter, que desplaza todo el texto (también
-- el envuelto) por igual. Resultado: barras continuas y texto alineado, sin
-- interferencias.

local M = {}

-- Cache por buffer: { [buf] = { bars = { [lnum] = {hl,...} }, max = n } }.
-- Se guarda a nivel de módulo (no en `vim.b`) para no copiar la tabla en cada
-- redibujado del statuscolumn.
M.cache = {}

local BAR = "▎"

-- Recalcula, para cada línea del buffer, la lista de barras (una por heading
-- ancestro) coloreadas según el nivel del heading. Un heading muestra solo las
-- barras de sus ancestros (su propia barra empieza en el contenido de abajo),
-- de modo que la guía se "rompe" en la línea del propio heading.
function M.compute(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local bars = {}
	local max = 0
	local stack = {} -- niveles de heading abiertos
	local in_fence = false
	local in_frontmatter = false

	for i, line in ipairs(lines) do
		local s = line:gsub("^%s+", "")

		-- Frontmatter YAML delimitado por `---` en la primera línea.
		if i == 1 and s == "---" then
			in_frontmatter = true
		elseif in_frontmatter and s == "---" then
			in_frontmatter = false
			bars[i] = {}
			goto continue
		end

		local is_fence = s:match("^```") ~= nil or s:match("^~~~") ~= nil
		if is_fence then
			in_fence = not in_fence
		end

		local level
		if not in_frontmatter and not in_fence and not is_fence then
			local hashes = s:match("^(#+)%s")
			if hashes then
				level = #hashes
			end
		end

		if level then
			-- cerrar secciones de nivel igual o más profundo
			while #stack > 0 and stack[#stack] >= level do
				table.remove(stack)
			end
			-- la línea del heading muestra las barras de los ancestros
			local list = {}
			for _, l in ipairs(stack) do
				list[#list + 1] = "RenderMarkdownH" .. math.min(l, 6)
			end
			bars[i] = list
			table.insert(stack, level)
		else
			local list = {}
			for _, l in ipairs(stack) do
				list[#list + 1] = "RenderMarkdownH" .. math.min(l, 6)
			end
			bars[i] = list
		end

		if #bars[i] > max then
			max = #bars[i]
		end

		::continue::
	end

	M.cache[buf] = { bars = bars, max = max }
end

-- Construye el string del statuscolumn para la fila actual (usa v:lnum,
-- v:relnum, v:virtnum). Formato: [signos][número][barras] .
function M.statuscolumn()
	local ok, res = pcall(function()
		local buf = vim.api.nvim_get_current_buf()
		local data = M.cache[buf]
		if not data then
			M.compute(buf)
			data = M.cache[buf]
		end
		local lnum = vim.v.lnum

		-- Número (híbrido: absoluto en la línea actual, relativo en el resto).
		local nw = math.max(vim.o.numberwidth, 3)
		local numhl, numstr
		if vim.v.virtnum ~= 0 then
			-- fila envuelta/virtual: sin número, solo el hueco
			numhl = "LineNr"
			numstr = string.rep(" ", nw)
		else
			numhl = (vim.v.relnum == 0) and "CursorLineNr" or "LineNr"
			local n = (vim.v.relnum == 0) and lnum or vim.v.relnum
			local t = tostring(n)
			numstr = string.rep(" ", math.max(0, nw - #t)) .. t
		end

		-- Barras (mismas en la fila real y en las envueltas → continuidad).
		local list = (data and data.bars[lnum]) or {}
		local maxd = (data and data.max) or 0
		local seg = {}
		for i = 1, maxd do
			local hl = list[i]
			if hl then
				seg[#seg + 1] = "%#" .. hl .. "#" .. BAR
			else
				seg[#seg + 1] = " "
			end
		end

		return "%s" .. "%#" .. numhl .. "#" .. numstr .. " " .. table.concat(seg) .. " "
	end)
	return ok and res or ""
end

-- Activa el statuscolumn y los autocomandos de recálculo en el buffer actual.
function M.attach(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	M.compute(buf)
	local function set_statuscolumn()
		vim.wo.statuscolumn = "%!v:lua.require'illico.util.md_section_bars'.statuscolumn()"
	end
	set_statuscolumn()

	local group = vim.api.nvim_create_augroup("MdSectionBars_" .. buf, { clear = true })
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
		group = group,
		buffer = buf,
		callback = function()
			M.compute(buf)
		end,
	})
	-- Al mostrar el buffer en (otra) ventana: recomputar y reasegurar el
	-- statuscolumn (es una opción de ventana, no de buffer).
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = group,
		buffer = buf,
		callback = function()
			M.compute(buf)
			set_statuscolumn()
		end,
	})
	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		buffer = buf,
		callback = function()
			M.cache[buf] = nil
		end,
	})
end

return M
