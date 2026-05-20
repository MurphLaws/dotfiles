return {
	"nvim-mini/mini.files",
	version = false,
	keys = {
		{
			"<leader>e",
			function()
				local mf = require("mini.files")
				if not mf.close() then
					mf.open(vim.fn.getcwd())
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
				vim.keymap.set("n", "<CR>", function()
					require("mini.files").go_in({ close_on_file = true })
				end, { buffer = args.data.buf_id, desc = "Mini.files: open & close on file" })
			end,
		})
	end,
}
