return {
	"vieitesss/miniharp.nvim",
	version = "*",
	opts = {
		autoload = true,
		autosave = true,
		show_on_autoload = false,
		notifications = true,
		ui = {
			position = "bottom-right",
			show_hints = true,
			enter = false,
		},
	},
	keys = {
		{
			"<leader>M",
			function()
				require("miniharp").toggle_file()
			end,
			desc = "miniharp: toggle file mark",
		},
		{
			"<leader>ml",
			function()
				require("miniharp").show_list()
			end,
			desc = "miniharp: toggle marks list",
		},
		{
			"<leader>mL",
			function()
				require("miniharp").enter_list()
			end,
			desc = "miniharp: enter marks list",
		},
		{
			"<leader>1",
			function()
				require("miniharp").go_to(1)
			end,
			desc = "miniharp: go to mark 1",
		},
		{
			"<leader>2",
			function()
				require("miniharp").go_to(2)
			end,
			desc = "miniharp: go to mark 2",
		},
		{
			"<leader>3",
			function()
				require("miniharp").go_to(3)
			end,
			desc = "miniharp: go to mark 3",
		},
		{
			"<leader>4",
			function()
				require("miniharp").go_to(4)
			end,
			desc = "miniharp: go to mark 4",
		},
	},
}
