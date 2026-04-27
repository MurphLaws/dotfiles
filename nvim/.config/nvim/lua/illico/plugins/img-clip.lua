return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		default = {
			dir_path = vim.fn.expand("~/.cache/claude-prompt-images"),
			file_name = "%Y%m%d-%H%M%S",
			use_absolute_path = true,
			relative_to_current_file = false,
			prompt_for_file_name = false,
			extension = "png",
			template = "$FILE_PATH",
			drag_and_drop = {
				insert_mode = true,
			},
		},
		filetypes = {
			markdown = {
				url_encode_path = true,
				template = "![Image]($FILE_PATH)",
			},
		},
	},
	keys = {
		{
			"<C-v>",
			function()
				if not require("img-clip").paste_image() then
					local keys = vim.api.nvim_replace_termcodes("<C-r>+", true, true, true)
					vim.api.nvim_feedkeys(keys, "n", false)
				end
			end,
			mode = "i",
			desc = "Paste image from clipboard (fallback to text paste)",
		},
		{
			"<C-v>",
			function()
				if not require("img-clip").paste_image() then
					local keys = vim.api.nvim_replace_termcodes("<C-v>", true, true, true)
					vim.api.nvim_feedkeys(keys, "n", false)
				end
			end,
			mode = "n",
			desc = "Paste image from clipboard (fallback to visual block)",
		},
	},
}
