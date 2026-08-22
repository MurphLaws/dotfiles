-- Scratch atado al archivo en vez de al directorio.
--
-- Snacks arma el nombre del archivo de scratch hasheando
-- `id or name` + count + cwd + branch (ver snacks/scratch.lua, _write_meta).
-- `filekey.id` está pensado exactamente para esto: pasándole la ruta absoluta
-- del buffer, cada archivo del proyecto tiene su propio scratch, y cwd/branch
-- dejan de importar (la ruta ya es única).
local M = {}

--- Abre el scratch del buffer actual. Si el buffer no tiene archivo real
--- (oil, terminal, floats, buffer sin nombre) cae al scratch del proyecto.
function M.file()
	local snacks = require("snacks")
	local path = vim.api.nvim_buf_get_name(0)

	if vim.bo.buftype ~= "" or path == "" then
		return snacks.scratch()
	end

	path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))

	return snacks.scratch({
		-- Título de la ventana: solo el nombre, la ruta completa sería ilegible.
		name = vim.fn.fnamemodify(path, ":t"),
		filekey = {
			id = path,
			cwd = false,
			branch = false,
			count = true,
		},
	})
end

return M
