-- =========================
-- jot: captura sin fricción
-- =========================
-- `nvim` sin argumentos abre un buffer norg vacío en insert mode: escribes
-- primero, ordenas después. Al terminar, <leader>ns (o :JotSave) pregunta
-- título / categorías / descripción, arma el @document.meta y guarda la nota
-- como ~/notes/<slug>.norg, dejándote en el archivo real.

local M = {}

local NOTES_DIR = vim.fn.expand("~/notes")

-- á→a, ñ→n, espacios→guiones, solo [a-z0-9-]
local function slugify(title)
	local map = {
		["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u",
		["ä"] = "a", ["ë"] = "e", ["ï"] = "i", ["ö"] = "o", ["ü"] = "u",
		["ñ"] = "n", ["Á"] = "a", ["É"] = "e", ["Í"] = "i", ["Ó"] = "o",
		["Ú"] = "u", ["Ñ"] = "n",
	}
	local s = title
	for k, v in pairs(map) do
		s = s:gsub(k, v)
	end
	s = s:lower():gsub("%s+", "-"):gsub("[^%w%-]", ""):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	if s == "" then
		s = "nota-" .. os.date("%Y%m%d-%H%M%S")
	end
	return s
end

-- <slug>.norg, y si ya existe: <slug>-2.norg, <slug>-3.norg, ...
local function unique_path(slug)
	local path = NOTES_DIR .. "/" .. slug .. ".norg"
	local n = 2
	while vim.fn.filereadable(path) == 1 do
		path = NOTES_DIR .. "/" .. slug .. "-" .. n .. ".norg"
		n = n + 1
	end
	return path
end

local function build_meta(title, description, categories)
	local meta = { "@document.meta", "title: " .. title }
	if description and description ~= "" then
		table.insert(meta, "description: " .. description)
	end
	table.insert(meta, "authors: [")
	table.insert(meta, "  illico")
	table.insert(meta, "]")
	if #categories > 0 then
		table.insert(meta, "categories: [")
		for _, c in ipairs(categories) do
			table.insert(meta, "  " .. c)
		end
		table.insert(meta, "]")
	end
	local today = os.date("%Y-%m-%d")
	table.insert(meta, "created: " .. today)
	table.insert(meta, "updated: " .. today)
	table.insert(meta, "version: 1.1.1")
	table.insert(meta, "@end")
	return meta
end

local function parse_categories(input)
	local out = {}
	for cat in (input or ""):gmatch("[^,]+") do
		cat = vim.trim(cat)
		if cat ~= "" then
			table.insert(out, cat)
		end
	end
	return out
end

-- Primera línea con contenido, sin marcadores norg, como título por defecto.
local function default_title(lines)
	for _, line in ipairs(lines) do
		local t = vim.trim(line:gsub("^[%*%-~%s]+", ""))
		if t ~= "" then
			return t:sub(1, 60)
		end
	end
	return ""
end

-- opts (opcional, para tests): { title=..., categories=..., description=... }
-- se salta los prompts que vengan dados.
function M.save(opts)
	opts = opts or {}
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local has_content = false
	for _, l in ipairs(lines) do
		if vim.trim(l) ~= "" then
			has_content = true
			break
		end
	end
	if not has_content then
		vim.notify("jot: buffer vacío, nada que guardar", vim.log.levels.WARN)
		return
	end

	local function finish(title, categories, description)
		local path = unique_path(slugify(title))
		local out = build_meta(title, description, categories)
		table.insert(out, "")
		vim.list_extend(out, lines)
		vim.fn.mkdir(NOTES_DIR, "p")
		vim.fn.writefile(out, path)

		-- reemplaza el scratch por el archivo real
		vim.cmd.edit(vim.fn.fnameescape(path))
		if vim.api.nvim_buf_is_valid(bufnr) and bufnr ~= vim.api.nvim_get_current_buf() then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		vim.notify("jot → " .. vim.fn.fnamemodify(path, ":~"))
		return path
	end

	if opts.title then
		return finish(opts.title, parse_categories(opts.categories), opts.description or "")
	end

	vim.ui.input({ prompt = "título: ", default = default_title(lines) }, function(title)
		if not title or vim.trim(title) == "" then
			return
		end
		vim.ui.input({ prompt = "categorías (a, b, c): " }, function(cats)
			if cats == nil then
				return
			end
			vim.ui.input({ prompt = "descripción: " }, function(desc)
				if desc == nil then
					return
				end
				finish(vim.trim(title), parse_categories(cats), vim.trim(desc))
			end)
		end)
	end)
end

-- Convierte el buffer actual (vacío, sin nombre) en buffer de captura.
function M.start()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.bo[bufnr].filetype = "norg"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "hide"
	vim.b[bufnr].jot = true

	vim.keymap.set("n", "<leader>ns", M.save, {
		buffer = bufnr,
		desc = "[jot] Guardar como nota neorg (pide metadatos)",
	})

	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Jot", M.start, { desc = "Abrir buffer de captura" })
vim.api.nvim_create_user_command("JotSave", function()
	M.save()
end, { desc = "Guardar captura como nota neorg" })

-- ===== arranque: `nvim` sin argumentos → captura =====
local group = vim.api.nvim_create_augroup("IllicoJot", { clear = true })

-- si nvim recibe un pipe (stdin), no somos captura
vim.api.nvim_create_autocmd("StdinReadPre", {
	group = group,
	callback = function()
		vim.g._illico_jot_stdin = true
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	callback = function()
		if vim.fn.argc() > 0 or vim.g._illico_jot_stdin then
			return
		end
		local bufnr = vim.api.nvim_get_current_buf()
		-- solo el buffer inicial: sin nombre, vacío, sin modificar
		if vim.api.nvim_buf_get_name(bufnr) ~= "" or vim.bo[bufnr].modified then
			return
		end
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		if #lines > 1 or (lines[1] or "") ~= "" then
			return
		end
		M.start()
	end,
})

return M
