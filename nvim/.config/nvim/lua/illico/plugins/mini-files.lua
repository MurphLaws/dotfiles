return {
	"nvim-mini/mini.files",
	-- Reemplazado por oil.nvim (ver oil.lua). Se deja el spec desactivado en
	-- vez de borrarlo, por si hay que volver.
	enabled = false,
	version = false,
	keys = {
		{
			"<leader>e",
			function()
				local mf = require("mini.files")
				if not mf.close() then
					local buf = vim.api.nvim_buf_get_name(0)
					local path = (buf ~= "" and vim.loop.fs_stat(buf)) and buf
						or vim.fn.getcwd()
					mf.open(path, false)
				end
			end,
			desc = "Mini.files: Toggle floating explorer (current file's folder)",
		},
	},
	opts = {
		windows = {
			preview = true,
			width_focus = 40,
			width_preview = 60,
		},
		options = {
			use_as_default_explorer = false,
		},
		content = {
			-- Ruido que nunca se toca a mano (proyectos Godot y dotfiles de
			-- repo). Solo quedan escenas/scripts, assets e imágenes.
			filter = function(entry)
				local hidden = {
					[".godot"] = true,
					[".editorconfig"] = true,
					[".gitattributes"] = true,
					[".gitignore"] = true,
					[".DS_Store"] = true,
				}
				if hidden[entry.name] then
					return false
				end
				return not entry.name:match("%.uid$") and not entry.name:match("%.import$")
			end,
		},
	},
	config = function(_, opts)
		local mf = require("mini.files")
		mf.setup(opts)

		-- Los bookmarks (`ma` para marcar, `'a` para saltar) viven dentro del
		-- objeto explorador, y <leader>e crea uno nuevo en cada apertura para
		-- abrir siempre en el cwd. Se cachean aquí al marcarlos y se reponen al
		-- abrir, para que sobrevivan al toggle.
		local saved_bookmarks = {}
		local set_bookmark = mf.set_bookmark
		mf.set_bookmark = function(id, path, bm_opts)
			-- El id `'` es el "antes del último salto" que mini.files gestiona
			-- solo; no tiene sentido persistirlo.
			if id ~= "'" then
				saved_bookmarks[id] = { path = path, opts = bm_opts }
			end
			return set_bookmark(id, path, bm_opts)
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesExplorerOpen",
			callback = function()
				for id, bm in pairs(saved_bookmarks) do
					-- El directorio puede haber desaparecido desde que se marcó;
					-- set_bookmark lanza error en ese caso.
					local ok = pcall(set_bookmark, id, bm.path, bm.opts)
					if not ok then
						saved_bookmarks[id] = nil
					end
				end
			end,
		})

		-- Make sure mini.files floats render above zen-mode and other floats.
		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesWindowOpen",
			callback = function(args)
				local win_id = args.data.win_id
				vim.api.nvim_win_set_config(win_id, {
					zindex = 100,
					border = "rounded",
				})
			end,
		})

		-- <CR> on a file: open it AND close the picker. On a directory:
		-- navigate in (mini.files default behavior).
		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local mf = require("mini.files")
				local buf = args.data.buf_id
				vim.keymap.set("n", "<CR>", function()
					mf.go_in({ close_on_file = true })
				end, { buffer = buf, desc = "Mini.files: open & close on file" })

				-- Navegación con flechas (como antes): Right entra a la carpeta
				-- o abre el archivo y cierra; Left sube al directorio padre.
				-- Up/Down ya mueven el cursor por ser un buffer normal.
				vim.keymap.set("n", "<Right>", function()
					mf.go_in({ close_on_file = true })
				end, { buffer = buf, desc = "Mini.files: go in / open" })
				vim.keymap.set("n", "<Left>", function()
					mf.go_out()
				end, { buffer = buf, desc = "Mini.files: go out (parent)" })
			end,
		})
	end,
}
