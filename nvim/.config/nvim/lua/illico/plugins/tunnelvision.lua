return {
	{
		"leolaurindo/tunnelvision.nvim",
		opts = {
			-- Por defecto el texto atenuado usa el color de `Comment` (#6c7086),
			-- que se sigue leyendo bastante. Forzamos un fg algo más oscuro
			-- (surface2) para que las líneas fuera de foco recedan sin desaparecer.
			dim = { fg = "#585b70" },
			-- Rastrea el símbolo en TODO el archivo, no solo en la función
			-- que contiene el cursor. Así funciona igual con variables que
			-- con funciones (sus llamadas viven en otras funciones del buffer).
			scope = "buffer",
			-- Combina LSP + emparejado por texto. Con el default "lsp_else_word",
			-- cuando hay LSP se usan SOLO sus líneas y el LSP de Godot/GDScript
			-- devuelve los usos pero NO la línea de declaración (`func nombre(...)`),
			-- que quedaba atenuada. "lsp_and_word" suma el match por palabra, que
			-- sí captura la declaración que el LSP omite.
			source = "lsp_and_word",
		},
		config = function(_, opts)
			require("tunnelvision").setup(opts)

			-- Extensión propia (no toca el código del plugin, que se sobrescribe
			-- al actualizar): cuando el símbolo bajo el cursor es el NOMBRE de una
			-- función, además de resaltar sus instancias/llamadas resaltamos el
			-- CUERPO ENTERO de su definición, no solo la línea `func nombre(...)`.
			-- Para variables u otros símbolos el comportamiento no cambia.
			local resolver = require("tunnelvision.resolver")
			local orig_compute = resolver.compute_path

			-- Devuelve las líneas (1-indexadas) del cuerpo completo de cada
			-- definición de función cuyo nombre coincide con `symbol`, vía
			-- treesitter. Si no hay parser disponible devuelve vacío y el
			-- comportamiento cae al del plugin (solo la línea de declaración).
			local function function_body_lines(bufnr, symbol)
				local out = {}
				if not symbol or symbol == "" then
					return out
				end
				local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
				if not ok_parser or not parser then
					return out
				end
				local ok_tree, trees = pcall(parser.parse, parser)
				if not ok_tree or not trees or not trees[1] then
					return out
				end

				-- Nodos de DEFINICIÓN de función (no llamadas): cubre
				-- function_definition (gdscript/python), function_declaration,
				-- method_definition, arrow_function, etc.
				local function is_func_def(node_type)
					if node_type:find("call", 1, true) then
						return false
					end
					return node_type:find("function", 1, true) or node_type:find("method", 1, true)
				end

				local function node_name(node)
					local ok_field, fields = pcall(node.field, node, "name")
					if ok_field and fields and fields[1] then
						return vim.treesitter.get_node_text(fields[1], bufnr)
					end
					-- Fallback: primer hijo de tipo name/identifier.
					for child in node:iter_children() do
						local ct = child:type()
						if ct == "name" or ct:find("identifier", 1, true) then
							return vim.treesitter.get_node_text(child, bufnr)
						end
					end
					return nil
				end

				local function walk(node)
					if is_func_def(node:type()) and node_name(node) == symbol then
						local sr, _, er, _ = node:range()
						for lnum = sr + 1, er + 1 do
							out[#out + 1] = lnum
						end
					end
					for child in node:iter_children() do
						walk(child)
					end
				end
				walk(trees[1]:root())
				return out
			end

			resolver.compute_path = function(bufnr, symbol, anchor, scope, o)
				local path_set, _, meta = orig_compute(bufnr, symbol, anchor, scope, o)
				for _, lnum in ipairs(function_body_lines(bufnr, symbol)) do
					path_set[lnum] = true
				end
				local order = {}
				for lnum in pairs(path_set) do
					order[#order + 1] = lnum
				end
				table.sort(order)
				return path_set, order, meta
			end
		end,
		keys = {
			-- Persistente: fija el símbolo donde estás parado y lo mantiene
			-- resaltado aunque muevas el cursor (modo static, el de siempre).
			{
				"<leader>tv",
				"<cmd>TunnelVision toggle<CR>",
				desc = "TunnelVision (fija el símbolo actual)",
			},
			-- Tiempo real: re-apunta automáticamente al símbolo bajo el cursor
			-- a medida que te mueves (modo dynamic del plugin). El modo se pasa
			-- por buffer, así que no pisa el toggle estático de arriba.
			{
				"<leader>tV",
				function()
					local tv = require("tunnelvision")
					local buf = vim.api.nvim_get_current_buf()
					local st = tv.status(buf)
					if st.active and st.mode == "dynamic" then
						tv.off()
					else
						tv.on({ mode = "dynamic" })
					end
				end,
				desc = "TunnelVision en tiempo real (sigue el símbolo bajo el cursor)",
			},
		},
	},
}
