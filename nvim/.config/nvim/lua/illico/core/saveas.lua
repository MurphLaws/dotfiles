-- illico/core/saveas.lua
--
-- `:w` sobre un buffer sin nombre pregunta la ruta en vez de dar E32.
-- No se puede hacer con autocomandos: E32 se lanza ANTES de que se disparen
-- BufWriteCmd/BufWritePre, así que interceptamos en la línea de comandos con
-- abreviaturas (`:w` → `:SaveAs`) que solo se expanden si el buffer actual no
-- tiene nombre y es un buffer normal.

-- Escribe el buffer actual en `path` (creando los directorios que falten) y
-- lo renombra a ese archivo, como haría `:saveas`.
local function save_as(path, bang, quit_after)
	path = vim.fn.fnamemodify(vim.fn.expand(vim.trim(path)), ":p")

	if vim.fn.isdirectory(path) == 1 then
		vim.notify(string.format("'%s' es un directorio", path), vim.log.levels.ERROR)
		return
	end

	if not bang and vim.fn.filereadable(path) == 1 then
		local choice = vim.fn.confirm(string.format("'%s' ya existe. ¿Sobrescribir?", path), "&Sí\n&No", 2)
		if choice ~= 1 then
			return
		end
		bang = true
	end

	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	local ok, err = pcall(vim.cmd, string.format("keepalt saveas%s %s", bang and "!" or "", vim.fn.fnameescape(path)))
	if not ok then
		vim.notify(tostring(err), vim.log.levels.ERROR)
		return
	end

	if quit_after then
		vim.cmd("quit")
	end
end

-- Sin argumento pide la ruta; con argumento (`:w foo.txt`) la usa tal cual.
local function prompt_save_as(opts, quit_after)
	if opts.args ~= "" then
		save_as(opts.args, opts.bang, quit_after)
		return
	end

	vim.ui.input({
		prompt = "Guardar como: ",
		default = vim.fn.getcwd() .. "/",
		completion = "file",
	}, function(input)
		if not input or vim.trim(input) == "" or vim.trim(input) == vim.fn.getcwd() .. "/" then
			vim.notify("Guardado cancelado", vim.log.levels.WARN)
			return
		end
		save_as(input, opts.bang, quit_after)
	end)
end

vim.api.nvim_create_user_command("SaveAs", function(opts)
	prompt_save_as(opts, false)
end, { nargs = "?", bang = true, complete = "file", desc = "Guardar buffer sin nombre pidiendo la ruta" })

vim.api.nvim_create_user_command("SaveAsQuit", function(opts)
	prompt_save_as(opts, true)
end, { nargs = "?", bang = true, complete = "file", desc = "Guardar buffer sin nombre pidiendo la ruta y cerrar" })

-- Abreviaturas de cmdline: solo se expanden si estamos escribiendo el comando
-- entero (no un argumento) y el buffer actual es normal y sin nombre.
local function unnamed_buffer()
	return vim.api.nvim_buf_get_name(0) == "" and vim.bo.buftype == ""
end

for cmd, replacement in pairs({ w = "SaveAs", wq = "SaveAsQuit", x = "SaveAsQuit" }) do
	vim.keymap.set("ca", cmd, function()
		if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == cmd and unnamed_buffer() then
			return replacement
		end
		return cmd
	end, { expr = true })
end
