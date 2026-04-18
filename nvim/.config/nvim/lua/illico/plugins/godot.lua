-- Godot / GDScript integration.
--
-- LSP + live diagnostics require Godot editor to be running (it hosts the
-- gdscript LSP on 127.0.0.1:6005 — see lsp/lspconfig.lua).
-- In Godot: Editor Settings > Text Editor > External > Use External Editor.
--
-- Offline docs: class pages are fetched on demand from docs.godotengine.org
-- and cached under ~/.cache/godot-docs/. Requires `curl` and `pandoc` on
-- $PATH. Run :GodotDocsClearCache to force re-fetch.
return {
	"habamax/vim-godot",
	ft = { "gdscript", "gdshader", "gdresource" },
	cmd = { "GodotRun", "GodotRunLast", "GodotRunCurrent", "GodotRunFZF", "GodotDocs", "GodotDocsClearCache" },
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "gdscript", "gdshader", "gdresource" },
			group = vim.api.nvim_create_augroup("IllicoGodot", { clear = true }),
			callback = function(args)
				vim.bo[args.buf].expandtab = false
				vim.bo[args.buf].tabstop = 4
				vim.bo[args.buf].shiftwidth = 4
				vim.bo[args.buf].softtabstop = 0
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
			vim.system(
				{ "curl", "-fsSL", "-A", "Mozilla/5.0", "-o", cached, url },
				{},
				function(res)
					vim.schedule(function()
						if res.code ~= 0 then
							os.remove(cached)
							vim.notify(
								"No Godot class '" .. class_name .. "' (HTTP fetch failed)",
								vim.log.levels.WARN
							)
							return
						end
						html_to_markdown(cached, class_name)
					end)
				end
			)
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

		map("<leader>Gr", "<cmd>GodotRun<CR>", "Godot: run project")
		map("<leader>Gc", "<cmd>GodotRunCurrent<CR>", "Godot: run current scene")
		map("<leader>Gl", "<cmd>GodotRunLast<CR>", "Godot: run last scene")
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
	end,
}
