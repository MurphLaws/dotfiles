return {
	"ribelo/taskwarrior.nvim",
	opts = {
		filter = { "noice", "nofile" },
		task_file_name = ".taskwarrior.json",
		granulation = 60 * 1000 * 10,
		notify_start = true,
		notify_stop = true,
		notify_error = true,
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("taskwarrior_nvim").browser({ "ready" })
			end,
			desc = "Task browser (ready)",
		},
		{
			"<leader>ta",
			function()
				require("taskwarrior_nvim").browser({ "status:pending" })
			end,
			desc = "Task browser (all pending)",
		},
		{
			"<leader>td",
			function()
				require("taskwarrior_nvim").browser({ "status:completed" })
			end,
			desc = "Task browser (done)",
		},
	},
}
