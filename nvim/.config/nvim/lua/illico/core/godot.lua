-- Godot / GDScript integration (no plugin — vim-godot was outdated and its
-- ftdetect/gsl.vim mapped *.gdshader → gsl, fighting our own detection).
--
-- LSP + diagnostics: configured in plugins/lsp/lspconfig.lua
--   - gdscript LSP requires Godot editor running on 127.0.0.1:6005
--     (Editor Settings > Text Editor > External > Use External Editor).
--   - gdshader_lsp uses `gdshader-language-server` on $PATH.
--
-- Offline docs: class pages are fetched on demand from docs.godotengine.org
-- and cached under ~/.cache/godot-docs/. Requires `curl` and `pandoc`.

vim.filetype.add({
	extension = {
		gd = "gdscript",
		gdshader = "gdshader",
		gdshaderinc = "gdshader",
		tscn = "gdresource",
		tres = "gdresource",
	},
})

local group = vim.api.nvim_create_augroup("IllicoGodot", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gdscript", "gdshader", "gdresource" },
	group = group,
	callback = function(args)
		vim.bo[args.buf].expandtab = false
		vim.bo[args.buf].tabstop = 4
		vim.bo[args.buf].shiftwidth = 4
		vim.bo[args.buf].softtabstop = 0
	end,
})

-- Godot's gdscript LSP returns resource path completions wrapped in literal
-- quotes (`"res://..."`). Inserted as-is inside an existing `""` they leave a
-- trailing extra `"`. Strip the wrapping quotes from completion items so
-- accepting one inside a quoted string yields a clean insertion.
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "gdscript" then
			return
		end
		if client._gdscript_quote_patch then
			return
		end
		client._gdscript_quote_patch = true

		local function unquote(s)
			if type(s) ~= "string" then
				return s
			end
			if s:sub(1, 1) == '"' then
				s = s:sub(2)
			end
			if s:sub(-1) == '"' then
				s = s:sub(1, -2)
			end
			return s
		end

		local function fix_items(items)
			if type(items) ~= "table" then
				return
			end
			for _, item in ipairs(items) do
				if type(item) == "table" then
					if item.insertText then
						item.insertText = unquote(item.insertText)
					end
					if item.textEdit and item.textEdit.newText then
						item.textEdit.newText = unquote(item.textEdit.newText)
					end
					if item.filterText then
						item.filterText = unquote(item.filterText)
					end
					if type(item.label) == "string" and item.label:sub(1, 1) == '"' then
						item.label = unquote(item.label)
					end
				end
			end
		end

		local orig_request = client.request
		client.request = function(self, method, params, handler, bufnr)
			if method == "textDocument/completion" and handler then
				local orig_handler = handler
				handler = function(err, result, ctx, config)
					if type(result) == "table" then
						if result.items then
							fix_items(result.items)
						else
							fix_items(result)
						end
					end
					return orig_handler(err, result, ctx, config)
				end
			end
			return orig_request(self, method, params, handler, bufnr)
		end
	end,
})

-- Avoids Godot's "Used spaces for indentation instead of tabs as configured"
-- warning by collapsing every 4 leading spaces into a tab on save.
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.gd", "*.gdshader", "*.gdshaderinc" },
	group = group,
	callback = function(args)
		local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
		local changed = false
		for i, line in ipairs(lines) do
			local indent, rest = line:match("^([\t ]*)(.*)$")
			if indent and indent:find(" ", 1, true) then
				local cols = 0
				for c = 1, #indent do
					if indent:sub(c, c) == "\t" then
						cols = cols + 4 - (cols % 4)
					else
						cols = cols + 1
					end
				end
				local new_indent = string.rep("\t", math.floor(cols / 4)) .. string.rep(" ", cols % 4)
				if new_indent ~= indent then
					lines[i] = new_indent .. rest
					changed = true
				end
			end
		end
		if changed then
			vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
		end
	end,
})

local cache_dir = vim.fn.stdpath("cache") .. "/godot-docs"
local base_url = "https://docs.godotengine.org/en/stable/classes/"

local function ensure_tools()
	for _, bin in ipairs({ "curl", "pandoc" }) do
		if vim.fn.executable(bin) == 0 then
			vim.notify(bin .. " not found on $PATH", vim.log.levels.ERROR)
			return false
		end
	end
	return true
end

local function render_markdown(md, title)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(md, "\n", { plain = true }))
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
		title = " Godot: " .. title .. " ",
		title_pos = "center",
	})
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end

local function html_to_markdown(html_path, title)
	local out = vim.fn.system({ "pandoc", "-f", "html", "-t", "gfm-raw_html", "--wrap=none", html_path })
	if vim.v.shell_error ~= 0 then
		vim.notify("pandoc failed: " .. out, vim.log.levels.ERROR)
		return
	end
	render_markdown(out, title)
end

local function fetch_and_render(class_name)
	local slug = class_name:lower()
	local filename = "class_" .. slug .. ".html"
	local cached = cache_dir .. "/" .. filename
	if vim.fn.filereadable(cached) == 1 then
		html_to_markdown(cached, class_name)
		return
	end
	vim.fn.mkdir(cache_dir, "p")
	local url = base_url .. filename
	vim.notify("Godot docs: fetching " .. class_name .. "...")
	vim.system({ "curl", "-fsSL", "-A", "Mozilla/5.0", "-o", cached, url }, {}, function(res)
		vim.schedule(function()
			if res.code ~= 0 then
				os.remove(cached)
				vim.notify("No Godot class '" .. class_name .. "' (HTTP fetch failed)", vim.log.levels.WARN)
				return
			end
			html_to_markdown(cached, class_name)
		end)
	end)
end

local function open_docs(term)
	if not term or term == "" then
		vim.notify("No term to look up", vim.log.levels.WARN)
		return
	end
	if not ensure_tools() then
		return
	end
	fetch_and_render(term)
end

vim.api.nvim_create_user_command("GodotDocs", function(opts)
	open_docs(opts.args)
end, { nargs = 1, desc = "Open Godot docs for a class" })

vim.api.nvim_create_user_command("GodotDocsClearCache", function()
	vim.fn.delete(cache_dir, "rf")
	vim.notify("Godot docs cache cleared")
end, { desc = "Clear cached Godot doc pages" })

local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

map("<leader>Gd", function()
	open_docs(vim.fn.expand("<cword>"))
end, "Godot: docs for word under cursor")
map("<leader>GD", function()
	vim.ui.input({ prompt = "Godot class: " }, function(input)
		if input and input ~= "" then
			open_docs(input)
		end
	end)
end, "Godot: search docs")
