-- Narrowing para markdown: abre una sección (heading + su contenido) en un
-- buffer temporal. Al guardar (:w) en ese buffer, los cambios se escriben de
-- vuelta en el buffer .md original (que queda modificado, listo para guardarlo).
local M = {}

local counter = 0

-- Rango (1-indexed, inclusivo) de la sección markdown que envuelve `lnum`,
-- usando el nodo `section` de tree-sitter.
local function section_range(buf, lnum)
	local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
	if not ok or not parser then
		return nil
	end
	parser:parse()
	local node = vim.treesitter.get_node({ bufnr = buf, pos = { lnum - 1, 0 } })
	while node and node:type() ~= "section" do
		node = node:parent()
	end
	if not node then
		return nil
	end
	local sr, _, er, ec = node:range()
	local e = (ec == 0) and er or (er + 1)
	return sr + 1, e
end

-- Abre las líneas [s,e] de `srcbuf` en un buffer temporal en un split vertical.
function M.narrow(srcbuf, s, e)
	local lines = vim.api.nvim_buf_get_lines(srcbuf, s - 1, e, false)
	counter = counter + 1
	vim.cmd("botright vsplit")
	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].buftype = "acwrite" -- :w dispara BufWriteCmd (no escribe archivo)
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].bufhidden = "wipe"
	local base = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(srcbuf), ":t")
	pcall(vim.api.nvim_buf_set_name, buf, ("narrow://%d/%s:%d-%d"):format(counter, base, s, e))
	vim.bo[buf].modified = false

	local st = { src = srcbuf, s = s, e = e }
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			if not vim.api.nvim_buf_is_valid(st.src) then
				vim.notify("El buffer original ya no existe", vim.log.levels.WARN)
				return
			end
			local new = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			vim.api.nvim_buf_set_lines(st.src, st.s - 1, st.e, false, new)
			st.e = st.s + #new - 1 -- ajustar el rango si cambió el número de líneas
			vim.bo[buf].modified = false
			vim.notify(("Sección sincronizada → %s (L%d-%d)"):format(base, st.s, st.e))
		end,
	})
end

-- Narrow de la sección bajo el cursor del buffer actual.
function M.narrow_section()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].filetype ~= "markdown" then
		vim.notify("narrow_section: el buffer actual no es markdown", vim.log.levels.WARN)
		return
	end
	local s, e = section_range(buf, vim.fn.line("."))
	if not s then
		vim.notify("No se encontró una sección en el cursor", vim.log.levels.WARN)
		return
	end
	M.narrow(buf, s, e)
end

return M
