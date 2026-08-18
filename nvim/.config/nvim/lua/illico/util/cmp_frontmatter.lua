-- Source de nvim-cmp que completa los valores de los campos del frontmatter
-- YAML (status, tags, type, owner) mientras se edita la sección de metadata de
-- una nota markdown. Solo se activa dentro del bloque `---` inicial.
local fm = require("illico.util.frontmatter")

local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

function source:get_debug_name()
	return "frontmatter"
end

-- Dispara el menú al escribir `:`, espacio, o dentro de una lista inline `[ ,`.
function source:get_trigger_characters()
	return { ":", " ", "[", ",", '"', "'" }
end

-- Solo válido en markdown y dentro del bloque de frontmatter inicial.
function source:is_available()
	if vim.bo.filetype ~= "markdown" then
		return false
	end
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	if lines[1] ~= "---" then
		return false
	end
	local close
	for i = 2, #lines do
		if lines[i] == "---" then
			close = i
			break
		end
	end
	if not close then
		return false
	end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	return row > 1 and row < close
end

function source:complete(params, callback)
	local before = params.context.cursor_before_line
	-- Nombre del campo al inicio de la línea: `status:`, `jira:`, `tags:`, ...
	local key = before:match("^(%w[%w_%-]*):")
	if not key then
		callback({ items = {}, isIncomplete = false })
		return
	end
	local values = fm.values(key)
	if #values == 0 then
		callback({ items = {}, isIncomplete = false })
		return
	end

	local cmp = require("cmp")
	local items = {}
	for _, entry in ipairs(values) do
		items[#items + 1] = {
			label = entry.value,
			insertText = entry.value,
			kind = cmp.lsp.CompletionItemKind.EnumMember,
			-- Marca de dónde viene el valor en el menú del autocompletado.
			labelDetails = { description = entry.dynamic and "vault" or "preset" },
		}
	end
	callback({ items = items, isIncomplete = false })
end

return source
