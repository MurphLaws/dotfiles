return {
	"obsidian-nvim/obsidian.nvim",
	-- Se sigue la rama `main` en vez del último tag: la release v3.16.6 llama
	-- `vim.pos.cursor(0)` con la firma antigua y rompe `:Obsidian toc` en
	-- Neovim 0.12 (nightly). `main` ya adoptó la nueva API de `vim.pos`.
	branch = "main",
	ft = "markdown",
	-- Menú <leader>o (o = Obsidian). Los keys también actúan como triggers de
	-- carga perezosa del plugin.
	keys = {
		{ "<leader>on", "<cmd>Obsidian new<cr>", desc = "Obsidian: New note" },
		{ "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Obsidian: Open in app" },
		{ "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian: Search notes" },
		{ "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: Quick switch" },
		{ "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Obsidian: Today's daily note" },
		{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian: Backlinks" },
		{ "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Obsidian: Follow link" },
		{ "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Obsidian: List links" },
		{ "<leader>oL", "<cmd>Obsidian link<cr>", mode = "x", desc = "Obsidian: Link selection" },
		{ "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Obsidian: Rename note" },
		{ "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Obsidian: Toggle checkbox" },
		{ "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Obsidian: Insert template" },
		{ "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "Obsidian: Switch workspace" },
		{ "<leader>oW", "<cmd>ObsidianWeekly<cr>", desc = "Obsidian: Weekly note (semana actual)" },
		{ "<leader>ox", "<cmd>ObsidianExtractHeading<cr>", desc = "Obsidian: Heading actual → nota (con link)" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "notes",
				path = vim.fn.expand("~/notes"),
			},
		},
		-- Completion se provee vía el LSP integrado (obsidian-ls); ya no se
		-- configura nvim_cmp aquí (removido en obsidian.nvim 4.0).
		completion = {
			min_chars = 2,
		},
		-- id = título tal cual lo tipeás (slug con guiones), nada de
		-- "1786851095-GPXK": el archivo y el id quedan legibles y [[título]]
		-- resuelve directo sin depender de aliases.
		note_id_func = function(title)
			if title and title ~= "" then
				return title:gsub(" ", "-"):gsub("[^A-Za-z0-9á-úÁ-Úñ%-_]", ""):lower()
			end
			return tostring(os.time())
		end,
		picker = {
			name = "snacks.pick",
		},
		ui = {
			enable = false,
		},
	},
	config = function(_, opts)
		require("obsidian").setup(opts)

		-- ===== Nota semanal (:ObsidianWeekly / <leader>oW) =====
		-- ===== Nota semanal (:ObsidianWeekly / <leader>oW) =====
		-- Crea (o abre) la nota de la semana ISO actual bajo ~/notes/weekly/.
		-- Nombre de archivo = rango de semana. Título `#` = nombre de la semana.
		-- Estructura: Weekly Plan → días (Tasks/Notes) → Weekly Review.
		local function create_weekly_note()
			local vault = vim.fn.expand("~/notes")
			local now = os.time()
			-- %u = día ISO (1=lunes ... 7=domingo); retrocedemos al lunes.
			local iso_wday = tonumber(os.date("%u", now))
			local monday = now - (iso_wday - 1) * 86400
			local iso_year = os.date("%G", now)
			local iso_week = os.date("%V", now)
			local mon_str = os.date("%Y-%m-%d", monday)
			local sun_str = os.date("%Y-%m-%d", monday + 6 * 86400)

			local week_name = string.format("%s-W%s (%s — %s)", iso_year, iso_week, mon_str, sun_str)
			local dir = vault .. "/weekly"
			vim.fn.mkdir(dir, "p")
			local path = dir .. "/" .. week_name .. ".md"

			if vim.fn.filereadable(path) == 0 then
				local days = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
				local lines = {
					"---",
					"type: weekly",
					string.format("week: %s-W%s", iso_year, iso_week),
					string.format("range: %s/%s", mon_str, sun_str),
					"tags: [weekly]",
					"---",
					"# " .. week_name,
					"",
					"## Weekly Plan",
					"- ",
					"",
				}
				for i, day in ipairs(days) do
					local d = os.date("%Y-%m-%d", monday + (i - 1) * 86400)
					table.insert(lines, string.format("## %s · %s", day, d))
					table.insert(lines, "### Tasks")
					table.insert(lines, "- [ ] ")
					table.insert(lines, "### Notes")
					table.insert(lines, "")
				end
				table.insert(lines, "## Weekly Review")
				table.insert(lines, "### Wins")
				table.insert(lines, "- ")
				table.insert(lines, "### Blockers")
				table.insert(lines, "- ")
				table.insert(lines, "### Next week")
				table.insert(lines, "- ")
				table.insert(lines, "")
				vim.fn.writefile(lines, path)
			end

			vim.cmd.edit(vim.fn.fnameescape(path))
		end

		vim.api.nvim_create_user_command("ObsidianWeekly", create_weekly_note, {
			desc = "Obsidian: crear/abrir la nota de la semana actual",
		})

		-- ===== Extraer heading a nota (:ObsidianExtractHeading / <leader>ox) =====
		-- Toma el heading bajo el cursor y todo su cuerpo (hasta el próximo
		-- heading de nivel igual o superior), lo mueve a una nota nueva nombrada
		-- según el título del heading y reemplaza la sección por un [[link]].
		local function extract_heading_to_note()
			local buf = vim.api.nvim_get_current_buf()
			local vault = vim.fn.expand("~/notes")
			if not vim.startswith(vim.api.nvim_buf_get_name(buf), vault) then
				vim.notify("ExtractHeading: el buffer no está en el vault", vim.log.levels.WARN)
				return
			end
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local cur = vim.api.nvim_win_get_cursor(0)[1] -- 1-based

			-- Buscar hacia arriba el heading que contiene el cursor.
			local start_idx, level, title
			for i = cur, 1, -1 do
				local h = lines[i]:match("^(#+)%s+")
				if h then
					start_idx = i
					level = #h
					title = lines[i]:gsub("^#+%s+", ""):gsub("%s+$", "")
					break
				end
			end
			if not start_idx then
				vim.notify("ExtractHeading: no hay heading bajo el cursor", vim.log.levels.WARN)
				return
			end

			-- Fin de la sección: próximo heading de nivel <= level.
			local end_idx = #lines
			for i = start_idx + 1, #lines do
				local h = lines[i]:match("^(#+)%s+")
				if h and #h <= level then
					end_idx = i - 1
					break
				end
			end

			-- Cuerpo = líneas tras el heading hasta el fin de sección.
			local body = {}
			for i = start_idx + 1, end_idx do
				table.insert(body, lines[i])
			end

			-- Nombre de nota a partir del título (mismo estilo que note_id_func).
			local id = title:gsub(" ", "-"):gsub("[^A-Za-z0-9á-úÁ-Úñ%-_]", ""):lower()
			if id == "" then
				vim.notify("ExtractHeading: título vacío", vim.log.levels.WARN)
				return
			end
			local path = vault .. "/" .. id .. ".md"
			if vim.fn.filereadable(path) == 1 then
				vim.notify("ExtractHeading: ya existe " .. id .. ".md", vim.log.levels.ERROR)
				return
			end

			local note = { "# " .. title, "" }
			for _, l in ipairs(body) do
				table.insert(note, l)
			end
			vim.fn.writefile(note, path)

			-- Reemplazar la sección original por el link (respeta el nivel).
			local repl = { string.rep("#", level) .. " [[" .. id .. "]]" }
			vim.api.nvim_buf_set_lines(buf, start_idx - 1, end_idx, false, repl)
			vim.notify("ExtractHeading: creada " .. id .. ".md", vim.log.levels.INFO)
		end

		vim.api.nvim_create_user_command("ObsidianExtractHeading", extract_heading_to_note, {
			desc = "Obsidian: mover el heading actual a una nota nueva y dejar un link",
		})


		-- Historial de saltos por wiki-link: al seguir un [[link]] se apila la
		-- posición de origen y <BS> vuelve ahí. <BS> NO hace nada si no venís
		-- de un salto de link (evita cambiar de buffer por un backspace
		-- accidental). Solo activo en markdown dentro del vault.
		local link_stack = {}

		local function cursor_on_wikilink()
			local line = vim.api.nvim_get_current_line()
			local col = vim.api.nvim_win_get_cursor(0)[2] + 1
			local from = 1
			while true do
				local s, e = line:find("%[%[.-%]%]", from)
				if not s then
					return false
				end
				if col >= s and col <= e then
					return true
				end
				from = e + 1
			end
		end

		local function follow_link()
			if cursor_on_wikilink() then
				table.insert(link_stack, {
					buf = vim.api.nvim_get_current_buf(),
					pos = vim.api.nvim_win_get_cursor(0),
				})
			end
			vim.cmd("Obsidian follow_link")
		end

		local function jump_back()
			local from = table.remove(link_stack)
			while from and not vim.api.nvim_buf_is_valid(from.buf) do
				from = table.remove(link_stack)
			end
			if not from then
				return
			end
			vim.api.nvim_set_current_buf(from.buf)
			pcall(vim.api.nvim_win_set_cursor, 0, from.pos)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			group = vim.api.nvim_create_augroup("ObsidianLinkHistory", { clear = true }),
			callback = function(ev)
				local vault = vim.fn.expand("~/notes")
				if not vim.startswith(vim.api.nvim_buf_get_name(ev.buf), vault) then
					return
				end
				local o = { buffer = ev.buf }
				o.desc = "Obsidian: follow link (con historial)"
				vim.keymap.set("n", "gf", follow_link, o)
				vim.keymap.set("n", "<CR>", follow_link, o)
				vim.keymap.set("n", "<leader>of", follow_link, o)
				o.desc = "Obsidian: volver del último link seguido"
				vim.keymap.set("n", "<BS>", jump_back, o)
			end,
		})
	end,
}
