return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		keywords = {
			TODO = {
				icon = " ", -- clipboard/plan
				color = "info",
				alt = { "todo" },
			},
			DONE = {
				icon = " ", -- checkmark
				color = "hint",
				alt = { "done", "completed" },
			},
			FIXIT = {
				icon = " ", -- wrench
				color = "warning",
				alt = { "fix", "fixme" },
			},
			BUGGED = {
				icon = " ", -- bug
				color = "error",
				alt = { "bug", "issue" },
			},
			OPTIM = {
				icon = " ", -- lightning / speed
				color = "optim",
				alt = { "optimize", "optimizable", "perf", "performance" },
			},
		},
		colors = {
			error = { "DiagnosticError", "ErrorMsg", "#DC2626" }, -- red
			warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" }, -- yellow
			info = { "DiagnosticInfo", "#2563EB" }, -- blue
			hint = { "DiagnosticHint", "#10B981" }, -- green
			default = { "Identifier", "#7C3AED" }, -- purple
			optim = { "#F97316" }, -- orange
		},
		highlight = {
			before = "", -- "fg" or "bg" or empty
			keyword = "wide", -- "fg", "bg", "wide", or empty
			after = "fg", -- "fg" or "bg" or empty
			pattern = [[.*<(KEYWORDS)\s*:]], -- pattern used for highlighting
			comments_only = false,
			max_line_len = 400,
			exclude = {},
		},
		search = {
			command = "rg",
			args = {
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
			},
			pattern = [[\b(KEYWORDS):]], -- ripgrep regex
		},
	},
}
