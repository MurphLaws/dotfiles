-- Godot / GDScript integration.
--
-- LSP + live diagnostics require Godot editor to be running (it hosts the
-- gdscript LSP on 127.0.0.1:6005 — see lsp/lspconfig.lua).
-- In Godot: Editor Settings > Text Editor > External > Use External Editor.
return {
	"habamax/vim-godot",
	ft = { "gdscript", "gdshader", "gdresource" },
	cmd = { "GodotRun", "GodotRunLast", "GodotRunCurrent", "GodotRunFZF" },
	init = function()
		-- GDScript requires hard tabs — Godot parser rejects spaces.
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

		local function open_docs_cword()
			local word = vim.fn.expand("<cword>")
			if word == "" then
				vim.notify("No word under cursor", vim.log.levels.WARN)
				return
			end
			vim.ui.open("https://docs.godotengine.org/en/stable/search.html?q=" .. word)
		end

		local function search_docs()
			vim.ui.input({ prompt = "Godot docs search: " }, function(input)
				if not input or input == "" then
					return
				end
				vim.ui.open("https://docs.godotengine.org/en/stable/search.html?q=" .. input)
			end)
		end

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
		end

		map("<leader>Gr", "<cmd>GodotRun<CR>", "Godot: run project")
		map("<leader>Gc", "<cmd>GodotRunCurrent<CR>", "Godot: run current scene")
		map("<leader>Gl", "<cmd>GodotRunLast<CR>", "Godot: run last scene")
		map("<leader>Gd", open_docs_cword, "Godot: docs for word under cursor")
		map("<leader>GD", search_docs, "Godot: search docs")
	end,
}
