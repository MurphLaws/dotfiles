-- Neorg vanilla: el vault vive en ~/notes (workspace «notes»).
return {
	"nvim-neorg/neorg",
	lazy = false, -- neorg recomienda cargarlo en el arranque
	version = "*",
	-- Con rocks deshabilitado en lazy.nvim, las dependencias que neorg
	-- declara como rockspecs se traen como plugins git normales.
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		"nvim-neorg/lua-utils.nvim",
		"nvim-neotest/nvim-nio",
		"pysan3/pathlib.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-neorg/neorg-telescope", -- picker para buscar notas e insertar links
		{ "pysan3/neorg-templates", dependencies = { "L3MON4D3/LuaSnip" } },
		"pritchett/neorg-capture",
	},
	config = function()
		-- neorg trae los parsers norg/norg_meta por luarocks, que está
		-- deshabilitado. norg_meta se registra en nvim-treesitter (rama main);
		-- install() recarga el registro y dispara `User TSUpdate`, así que hay
		-- que registrarlo ahí para que sobreviva a la recarga.
		--
		-- El parser norg NO puede instalarlo nvim-treesitter: su scanner es C++
		-- (scanner.cc) y main solo compila C. Está compilado a mano en
		-- ~/.local/share/nvim/site/parser/norg.so. Para recompilarlo (otra
		-- máquina, o si nvim cambia de ABI y neorg vuelve a avisar
		-- "norg treesitter parser was not found"):
		--   git clone --depth 1 https://github.com/nvim-neorg/tree-sitter-norg
		--   cd tree-sitter-norg
		--   /usr/bin/cc  -c -I src src/parser.c  -o parser.o  -Os -fPIC
		--   /usr/bin/c++ -c -I src src/scanner.cc -o scanner.o -Os -fPIC -std=c++14
		--   /usr/bin/c++ -shared parser.o scanner.o -o ~/.local/share/nvim/site/parser/norg.so
		vim.api.nvim_create_autocmd("User", {
			pattern = "TSUpdate",
			callback = function()
				require("nvim-treesitter.parsers").norg_meta = {
					install_info = { url = "https://github.com/nvim-neorg/tree-sitter-norg-meta", branch = "main" },
					tier = 2,
				}
			end,
		})
		if not vim.tbl_contains(require("nvim-treesitter.config").get_installed("parsers"), "norg_meta") then
			require("nvim-treesitter").install({ "norg_meta" })
		end

		-- Captura por categorías: el nombre del archivo es <categoria>-<slug>.norg
		-- (idea-*, task-*, nota-*), plano en la raíz del vault. El título se
		-- pregunta una vez y el template lo recibe vía el keyword {CTITLE}.
		local capture_title = ""
		local function slugify(s)
			s = s:lower()
			for from, to in pairs({ ["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u", ["ñ"] = "n", ["ü"] = "u" }) do
				s = s:gsub(from, to)
			end
			return (s:gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
		end
		local function capture_file(prefix)
			return function()
				capture_title = vim.fn.input("Título: ")
				if capture_title == "" then
					capture_title = "sin-titulo"
				end
				-- $/ = raíz del workspace actual. Sin él, neorg resuelve la ruta
				-- relativa al archivo del buffer llamador y revienta ("Parent
				-- for / not found") si capturas desde un buffer sin nombre.
				return "$/" .. prefix .. "-" .. slugify(capture_title)
			end
		end

		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				-- El contador [x/y] (z%) de tareas, en el mismo azul de los links.
				["core.todo-introspector"] = { config = { highlight_group = "NorgProgress" } },
				["core.integrations.telescope"] = {},
				["external.templates"] = {
					config = {
						templates_dir = vim.fn.expand("~/notes/templates"),
						keywords = {
							CTITLE = function()
								return require("luasnip").text_node(capture_title)
							end,
						},
					},
				},
				["external.capture"] = {
					config = {
						templates = {
							{ description = "idea", name = "idea", file = capture_file("idea") },
							{ description = "work", name = "work", file = capture_file("work") },
							{ description = "task", name = "task", file = capture_file("task") },
						},
					},
				},
				["core.dirman"] = {
					config = {
						workspaces = { notes = "~/notes" },
						default_workspace = "notes",
					},
				},
			},
		})

		-- Bold/cursiva/tachado con color propio, mismos colores onedark que
		-- se usan en render-markdown.lua (naranja/violeta; gris para tachado).
		vim.api.nvim_set_hl(0, "@neorg.markup.bold", { fg = "#d19a66", bold = true })
		vim.api.nvim_set_hl(0, "@neorg.markup.italic", { fg = "#c678dd", italic = true })
		vim.api.nvim_set_hl(0, "@neorg.markup.strikethrough", { fg = "#5c6370", strikethrough = true })
		vim.api.nvim_set_hl(0, "NorgProgress", { fg = "#61afef" })

		-- Captura a pantalla completa: neorg-capture abre un :split hardcodeado
		-- (sin opción de config), así que se mueve esa ventana a su propio tab
		-- y al terminar la captura (el buffer se wipea) se cierra el tab.
		-- Ojo: el plugin usa `noautocmd split`, así que BufWinEnter no se dispara;
		-- el FileType sí, porque lo setea después vía su BufReadCmd manual.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function(ev)
				if not vim.api.nvim_buf_get_name(ev.buf):match("^neorg%-capture://") then
					return
				end
				pcall(vim.cmd.wincmd, "T")
				local tab = vim.api.nvim_get_current_tabpage()
				vim.api.nvim_create_autocmd("BufWipeout", {
					buffer = ev.buf,
					once = true,
					callback = vim.schedule_wrap(function()
						if vim.api.nvim_tabpage_is_valid(tab) and #vim.api.nvim_list_tabpages() > 1 then
							pcall(vim.api.nvim_win_close, vim.api.nvim_tabpage_get_win(tab), false)
						end
					end),
				})
			end,
		})

		-- Todo neorg bajo <leader>n (grupo «Neorg» en which-key).
		local tele = require("telescope").extensions.neorg
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc })
		end
		map("<leader>nn", "<cmd>Neorg index<cr>", "Abrir index")
		map("<leader>nf", tele.find_norg_files, "Buscar notas")
		map("<leader>ni", tele.insert_link, "Insertar link")
		-- TOC dentro del documento: inserta (o actualiza) un bloque «* TOC» al
		-- inicio con links a los encabezados del archivo. neorg solo trae el
		-- TOC en split (:Neorg toc), no en el propio documento.
		local function update_doc_toc()
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			-- Borrar el TOC previo: su encabezado + las líneas de lista/blanco que le siguen.
			for i, l in ipairs(lines) do
				if l:match("^%* TOC%s*$") then
					local last = i
					for j = i + 1, #lines do
						if lines[j]:match("^%s*$") or lines[j]:match("^%s*%-%s+{") then
							last = j
						else
							break
						end
					end
					vim.api.nvim_buf_set_lines(0, i - 1, last, false, {})
					lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
					break
				end
			end
			-- ponytail: lee líneas planas, un `* dentro de un bloque de código contaría
			local toc = { "* TOC" }
			for _, l in ipairs(lines) do
				local stars, title = l:match("^(%*+)%s+(.+)$")
				if stars then
					toc[#toc + 1] = ("%s- {%s %s}[%s]"):format(string.rep(" ", #stars + 1), stars, title, title)
				end
			end
			toc[#toc + 1] = ""
			-- Al inicio del archivo, tras @document.meta si existe.
			local at = 0
			if lines[1] and lines[1]:match("^@document%.meta") then
				for i, l in ipairs(lines) do
					if l:match("^@end%s*$") then
						at = i
						break
					end
				end
			end
			vim.api.nvim_buf_set_lines(0, at, at, false, toc)
		end
		vim.api.nvim_create_user_command("NeorgTocUpdate", update_doc_toc, { desc = "Insertar/actualizar TOC del documento" })
		map("<leader>ns", update_doc_toc, "Insertar/actualizar TOC del documento")
		-- Toggle del TOC: neorg no lo trae; su buffer se llama "toc-<tabpage>".
		map("<leader>nt", function()
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match("toc%-%d+$") then
					vim.api.nvim_win_close(win, true)
					return
				end
			end
			vim.cmd("Neorg toc")
		end, "Tabla de contenidos (toggle)")
		map("<leader>na", "<cmd>Neorg capture<cr>", "Captura (idea/tarea/nota)")
		-- Nota nueva vacía, sin template: pregunta el título y abre <slug>.norg
		-- plano en la raíz del vault (mismo esquema que las capturas).
		map("<leader>no", function()
			local title = vim.fn.input("Título: ")
			if title == "" then
				return
			end
			vim.cmd.edit(vim.fn.expand("~/notes/") .. slugify(title) .. ".norg")
		end, "Nota nueva vacía")
	end,
}
