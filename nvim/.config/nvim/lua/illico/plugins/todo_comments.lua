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
			POINTER = {
				icon = "➜ ", -- flecha punchy
				color = "pointer",
				alt = { "pointer", "ptr" },
			},
		},
		colors = {
			error = { "DiagnosticError", "ErrorMsg", "#DC2626" }, -- red
			warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" }, -- yellow
			info = { "DiagnosticInfo", "#2563EB" }, -- blue
			hint = { "DiagnosticHint", "#10B981" }, -- green
			default = { "Identifier", "#7C3AED" }, -- purple
			optim = { "#F97316" }, -- orange
			pointer = { "#FF7A00" }, -- bright orange
		},
		highlight = {
			before = "", -- "fg" or "bg" or empty
			keyword = "wide", -- "fg", "bg", "wide", or empty
			after = "fg", -- "fg" or "bg" or empty
			pattern = [[.*<(KEYWORDS)\s*:]], -- pattern used for highlighting
			comments_only = false,
			-- Notas multilínea: el color del keyword abarca las líneas siguientes
			-- hasta la primera línea en blanco (útil para POINTER/TODO largos en
			-- markdown, no solo la primera línea).
			multiline = true,
			multiline_pattern = "^.", -- continúa mientras la línea no esté vacía
			multiline_context = 20,
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
	config = function(_, opts)
		require("todo-comments").setup(opts)

		-- En markdown la continuación multilínea del plugin exige que la línea
		-- sea un "comment" (captura de treesitter), lo que nunca ocurre en prosa
		-- markdown, así que el color no pasaba de la primera línea. Como usamos
		-- comments_only=false, reemplazamos ese check por una regla propia: la
		-- nota (POINTER:, TODO:, ...) continúa sobre las líneas siguientes SOLO
		-- mientras sean continuación en prosa; corta al llegar a un nuevo ítem de
		-- lista (`- `, `* `, `+ `, `1.`), un heading (`#`) o una línea en blanco.
		-- Así un POINTER que es un bullet no se derrama sobre los bullets
		-- hermanos.
		local hl = require("todo-comments.highlight")
		local is_comment = hl.is_comment
		hl.is_comment = function(buf, row, col)
			if vim.bo[buf].filetype == "markdown" then
				local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
				local body = line:match("^%s*(.-)%s*$")
				-- Corta en nuevos bullets / listas ordenadas / headings.
				if body:match("^[%-%*%+]%s") or body:match("^%d+[%.%)]%s") or body:match("^#") then
					return false
				end
				return true
			end
			return is_comment(buf, row, col)
		end
	end,
}
