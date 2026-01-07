return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- You can keep this, but...
		lazy = false, -- 🟢 ADD THIS: Force it to load on startup
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
