-- Picker de TODO comments con el texto de la nota a la IZQUIERDA (empezando por
-- el keyword, p. ej. `POINTER: ...`) y la ubicación del archivo al final,
-- atenuada. Es una variante del picker de la extensión de telescope de
-- todo-comments, que muestra el archivo primero y el texto después.
local M = {}

function M.find(opts)
	local Config = require("todo-comments.config")
	local Highlight = require("todo-comments.highlight")
	local make_entry = require("telescope.make_entry")
	local pickers = require("telescope.builtin")

	opts = opts or {}

	-- Todos los keywords conocidos, salvo que se filtre con opts.keywords.
	local keywords = vim.tbl_keys(Config.keywords)
	if opts.keywords then
		local filters = vim.split(opts.keywords, ",")
		keywords = vim.tbl_filter(function(kw)
			return vim.tbl_contains(filters, kw)
		end, keywords)
	end

	opts.vimgrep_arguments = { Config.options.search.command }
	vim.list_extend(opts.vimgrep_arguments, Config.options.search.args)
	opts.search = Config.search_regex(keywords)
	opts.prompt_title = "Find Todo"
	opts.use_regex = true

	local entry_maker = make_entry.gen_from_vimgrep(opts)
	opts.entry_maker = function(line)
		local ret = entry_maker(line)
		ret.display = function(entry)
			local text = entry.text
			local start, finish, kw = Highlight.match(text)
			if not start then
				return string.format("%s:%s:%s %s", entry.filename, entry.lnum, entry.col, text)
			end

			kw = Config.keywords[kw] or kw
			local icon = Config.options.keywords[kw].icon or " "
			text = vim.trim(text:sub(start))

			-- Texto primero (icono + nota), ubicación al final atenuada.
			local prefix = icon .. " "
			local location = string.format("  %s:%s", entry.filename, entry.lnum)
			local display = prefix .. text .. location

			local hl = {}
			-- icono con el color del keyword
			table.insert(hl, { { 0, #icon + 1 }, "TodoFg" .. kw })
			-- keyword resaltado (fondo)
			table.insert(hl, { { #prefix, #prefix + (finish - start) + 2 }, "TodoBg" .. kw })
			-- resto del texto de la nota (color del keyword)
			table.insert(hl, { { #prefix + (finish - start) + 1, #prefix + #text }, "TodoFg" .. kw })
			-- ubicación atenuada
			table.insert(hl, { { #prefix + #text, #display }, "Comment" })

			return display, hl
		end
		return ret
	end

	pickers.grep_string(opts)
end

return M
