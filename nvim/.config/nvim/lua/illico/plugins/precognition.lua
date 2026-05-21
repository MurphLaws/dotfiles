return {
	{
		"tris203/precognition.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("precognition").setup(opts)

			local dim = "#3b4261"
			vim.api.nvim_set_hl(0, "PrecognitionHint", { fg = dim, bg = "NONE" })
			vim.api.nvim_set_hl(0, "PrecognitionHintBracket", { fg = dim, bg = "NONE" })
		end,
	},
}
