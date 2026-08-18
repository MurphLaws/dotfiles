return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- lazy=false para que el resaltado de TODO/FIXIT/... esté activo desde el
	-- arranque en cualquier buffer (incl. markdown), no solo al pulsar una key.
	lazy = false,
	keys = {
		-- Picker de todos en todo el vault de notas, sin importar el cwd.
		{
			"<leader>st",
			"<cmd>TodoTelescope cwd=~/notes<cr>",
			desc = "Todos: buscar en el vault (~/notes)",
		},
		-- Picker de todos en el proyecto/cwd actual (código, etc.).
		{
			"<leader>sT",
			"<cmd>TodoTelescope<cr>",
			desc = "Todos: buscar en el proyecto (cwd)",
		},
		-- Saltar al siguiente / anterior comentario TODO en el buffer.
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Todos: siguiente",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Todos: anterior",
		},
	},
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
