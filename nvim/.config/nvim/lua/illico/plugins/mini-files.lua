return {
	"nvim-mini/mini.files",
	version = false,
	keys = {
		{
			"<leader>m",
			function()
				local mf = require("mini.files")
				if not mf.close() then
					local path = vim.api.nvim_buf_get_name(0)
					if path == "" or vim.fn.filereadable(path) == 0 then
						mf.open()
					else
						mf.open(path)
					end
				end
			end,
			desc = "Mini.files: Toggle floating explorer",
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
	end,
}
