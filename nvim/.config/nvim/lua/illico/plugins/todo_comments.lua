return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- lazy=false para que el resaltado de TODO/FIXIT/... esté activo desde el
	-- arranque en cualquier buffer (incl. markdown), no solo al pulsar una key.
	lazy = false,
	keys = {
		-- Picker de todos en todo el vault de notas, sin importar el cwd.
		-- Usa el picker propio (texto del todo a la izquierda, archivo al final).
		{
			"<leader>st",
			function()
				require("illico.util.todo_picker").find({ cwd = vim.fn.expand("~/notes") })
			end,
			desc = "Todos: buscar en el vault (~/notes)",
		},
		-- Picker de todos en el proyecto/cwd actual (código, etc.).
		{
			"<leader>sT",
			function()
				require("illico.util.todo_picker").find({})
			end,
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
				color = "todo",
				alt = { "todo" },
			},
			DONE = {
				icon = " ", -- checkmark
				color = "done",
				alt = { "done", "completed" },
			},
			FIXIT = {
				icon = " ", -- wrench
				color = "fix",
				alt = { "fix", "fixme" },
			},
			BUGGED = {
				icon = " ", -- bug
				color = "bug",
				alt = { "bug", "issue" },
			},
			OPTIM = {
				icon = " ", -- lightning / speed
				color = "optim",
				alt = { "optimize", "optimizable", "perf", "performance" },
			},
			POINTER = {
				icon = "➜ ", -- flecha punchy
				color = "pointer",
				alt = { "pointer", "ptr" },
			},
			QUESTION = {
				icon = " ", -- question mark
				color = "question",
				alt = { "question", "ask", "q" },
			},
		},
		-- Paleta propia, distinta a la del markdown (rojo H1, morado H2,
		-- cian enlaces, verde frontmatter) para que los keywords resalten.
		colors = {
			todo = { "#3B82F6" }, -- blue
			done = { "#9CA3AF" }, -- gray
			fix = { "#F59E0B" }, -- amber
			bug = { "#E11D8F" }, -- magenta
			optim = { "#FB923C" }, -- orange
			pointer = { "#FACC15" }, -- gold / yellow
			question = { "#F472B6" }, -- pink
		},
		highlight = {
			before = "", -- "fg" or "bg" or empty
			keyword = "wide", -- "fg", "bg", "wide", or empty
			after = "fg", -- "fg" or "bg" or empty
			pattern = [[.*<(KEYWORDS)\s*:]], -- pattern used for highlighting
			comments_only = false,
			multiline = false,
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
