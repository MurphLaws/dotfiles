return {
	"nvim-mini/mini.files",
	version = false,
	keys = {
		{
			"<leader>e",
			function()
				local mf = require("mini.files")
				if not mf.close() then
					mf.open(vim.fn.getcwd(), false)
				end
			end,
			desc = "Mini.files: Toggle floating explorer (cwd)",
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
			filter = function(entry)
				return not entry.name:match("%.uid$")
			end,
		},
	},
	config = function(_, opts)
		require("mini.files").setup(opts)

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
