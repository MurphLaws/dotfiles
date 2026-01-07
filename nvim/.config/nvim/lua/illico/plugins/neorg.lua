return {
	{
		"nvim-neorg/neorg",
		lazy = false,
		version = "*",

		dependencies = {
			{ "L3MON4D3/LuaSnip" },
			{ "pysan3/neorg-templates", dependencies = { "L3MON4D3/LuaSnip" } },
			{ "pritchett/neorg-capture" },
			{ "andreadev-it/neorg-better-captures" },
		},

		keys = {
			{ "<localleader>t", false, ft = "norg" },

			{
				"<localleader>tt",
				"<Plug>(neorg.qol.todo-items.todo.task-cycle)",
				ft = "norg",
				desc = "[neorg] Cycle Task",
			},

			{
				"<localleader>nc",
				"<cmd>Neorg capture<cr>",
				ft = "norg",
				desc = "[neorg] Capture",
			},

			{
				"<localleader>nr",
				function()
					_G.Neorg_refile_subtree()
				end,
				ft = "norg",
				desc = "[neorg] Refile subtree",
			},

			-- date insert (no brackets)
			{
				"<localleader>id",
				function()
					-- Example (es locale): Diciembre 27, 2025
					local s = vim.fn.strftime("%B %d, %Y")
					local first = vim.fn.strcharpart(s, 0, 1)
					local rest = vim.fn.strcharpart(s, 1)
					s = vim.fn.toupper(first) .. rest
					vim.api.nvim_put({ s }, "c", true, true)
				end,
				ft = "norg",
				desc = "[neorg] insert day date",
			},

			{
				"<localleader>iw",
				function()
					-- Example (es locale): Diciembre, 2025 - w52
					local s = vim.fn.strftime("%B, %Y") .. " - w" .. vim.fn.strftime("%V")
					local first = vim.fn.strcharpart(s, 0, 1)
					local rest = vim.fn.strcharpart(s, 1)
					s = vim.fn.toupper(first) .. rest
					vim.api.nvim_put({ s }, "c", true, true)
				end,
				ft = "norg",
				desc = "[neorg] insert week date",
			},
		},

		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {},
					["core.qol.todo_items"] = {},
					["core.concealer"] = {},
					["core.dirman"] = {
						config = {
							workspaces = { notes = "~/notes" },
							default_workspace = "notes",
						},
					},

					-- ✅ MÓDULOS DE EXPORTACIÓN AGREGADOS (Para convertir a Markdown)
					["core.export"] = {},
					["core.export.markdown"] = {
						config = {
							extensions = "all",
						},
					},

					-- captures
					["external.better-captures"] = {
						config = {
							captures = {
								-- IMPORTANT:
								-- neorg-better-captures uses LuaSnip fmt{} under the hood.
								-- A lone "{" or "{date}" WILL crash.
								-- Only "{}" placeholders allowed.
								project = {
									path = "gtd/projects.norg",
									type = "text",
									content = [[
* {}
  - ( ) {}
]],
									workspace = "notes",
								},
								quick_note = {
									path = "inbox.norg",
									type = "text",
									content = [[
* {}
  - ( ) {}
]],
									workspace = "notes",
								},
								-- === NUEVO CAPTURE GTD (IN-NOTE) ===
								in_note = {
									path = "in.norg",
									workspace = "notes",
									-- Esto busca el headline existente "* IN"
									headline = "IN",
									type = "text",
									-- Crea un nivel 2 (**) debajo del nivel 1 (*)
									content = [[
** {}
   {}
]],
								},
							},
						},
					},
				},
			})

			-- =========================
			-- view persistence
			-- =========================
			vim.opt.viewdir = vim.fn.stdpath("state") .. "/view"
			vim.fn.mkdir(vim.opt.viewdir:get(), "p")
			vim.opt.viewoptions = { "cursor", "folds" }

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "norg",
				callback = function()
					vim.wo.conceallevel = 2
					vim.wo.foldenable = true
				end,
			})

			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "*.norg",
				callback = function()
					pcall(vim.cmd, "silent! loadview")
				end,
			})

			vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
				pattern = "*.norg",
				callback = function()
					pcall(vim.cmd, "silent! mkview")
				end,
			})

			-- =========================
			-- refile implementation
			-- =========================

			local function read_file_lines(path)
				local ok, lines = pcall(vim.fn.readfile, path)
				return ok and lines or {}
			end

			local function write_file_lines(path, lines)
				vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
				vim.fn.writefile(lines, path)
			end

			local function find_headlines(lines)
				local out = {}
				for i, line in ipairs(lines) do
					local stars = line:match("^(%*+)%s+")
					if stars then
						table.insert(out, {
							lnum = i,
							level = #stars,
							raw = line,
						})
					end
				end
				return out
			end

			local function get_subtree_range(bufnr, cursor_lnum)
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local start = cursor_lnum
				while start >= 1 and not lines[start]:match("^%*+%s+") do
					start = start - 1
				end
				if start < 1 then
					return nil
				end

				local level = #(lines[start]:match("^(%*+)"))
				local finish = #lines
				for i = start + 1, #lines do
					local s = lines[i]:match("^(%*+)%s+")
					if s and #s <= level then
						finish = i - 1
						break
					end
				end
				return start, finish, level
			end

			local function normalize_subtree_levels(subtree, target_level)
				local root_stars = subtree[1]:match("^(%*+)%s+")
				if not root_stars then
					return subtree
				end

				local delta = (target_level + 1) - #root_stars
				local out = {}

				for _, line in ipairs(subtree) do
					local stars, rest = line:match("^(%*+)%s+(.*)$")
					if stars then
						table.insert(out, string.rep("*", math.max(1, #stars + delta)) .. " " .. rest)
					else
						table.insert(out, line)
					end
				end
				return out
			end

			local function insert_under_heading(lines, lnum, level, subtree)
				local insert_at = #lines + 1
				for i = lnum + 1, #lines do
					local s = lines[i]:match("^(%*+)%s+")
					if s and #s <= level then
						insert_at = i
						break
					end
				end

				if insert_at > 1 and lines[insert_at - 1] ~= "" then
					table.insert(lines, insert_at, "")
					insert_at = insert_at + 1
				end

				for i = #subtree, 1, -1 do
					table.insert(lines, insert_at, subtree[i])
				end

				table.insert(lines, insert_at + #subtree, "")
				return lines
			end

			_G.Neorg_refile_subtree = function()
				local bufnr = vim.api.nvim_get_current_buf()
				if vim.bo[bufnr].filetype ~= "norg" then
					return
				end

				local cursor = vim.api.nvim_win_get_cursor(0)
				local start_lnum, end_lnum = get_subtree_range(bufnr, cursor[1])
				if not start_lnum then
					return
				end

				local subtree = vim.api.nvim_buf_get_lines(bufnr, start_lnum - 1, end_lnum, false)
				local vault = vim.fn.expand("~/notes")
				local files = vim.fn.globpath(vault, "**/*.norg", false, true)

				local items = {}
				for _, f in ipairs(files) do
					table.insert(items, {
						path = f,
						label = vim.fn.fnamemodify(f, ":~:."),
					})
				end

				table.sort(items, function(a, b)
					return a.label < b.label
				end)

				vim.ui.select(items, {
					prompt = "refile to file:",
					format_item = function(item)
						return item.label
					end,
				}, function(file)
					if not file then
						return
					end

					local lines = read_file_lines(file.path)
					local heads = find_headlines(lines)

					local targets = { { kind = "eof", label = "(end of file)" } }
					for _, h in ipairs(heads) do
						table.insert(targets, {
							kind = "head",
							label = string.rep("  ", h.level - 1) .. h.raw,
							lnum = h.lnum,
							level = h.level,
						})
					end

					vim.ui.select(targets, {
						prompt = "under headline:",
						format_item = function(item)
							return item.label
						end,
					}, function(t)
						if not t then
							return
						end

						if t.kind == "head" then
							subtree = normalize_subtree_levels(subtree, t.level)
							lines = insert_under_heading(lines, t.lnum, t.level, subtree)
						else
							if #lines > 0 and lines[#lines] ~= "" then
								table.insert(lines, "")
							end
							for _, l in ipairs(subtree) do
								table.insert(lines, l)
							end
							table.insert(lines, "")
						end

						write_file_lines(file.path, lines)
						vim.api.nvim_buf_set_lines(bufnr, start_lnum - 1, end_lnum, false, {})
						pcall(vim.cmd, "write")
					end)
				end)
			end
		end,
	},
}
