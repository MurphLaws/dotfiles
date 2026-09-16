-- ============================================================================
-- nvim-orgmode — Org mode para Neovim: agenda, capture, TODOs, refile y notas
-- sobre archivos .org planos en ~/org. El plugin instala y registra su propio
-- parser de tree-sitter para `org`, no depende del registro de nvim-treesitter.
--
-- Estructura de ~/org (dos vaults planos, cada uno con su inbox):
--   work/refile.org       inbox de trabajo (capture `w`; luego refile)
--   personal/refile.org   inbox personal (capture `p`; luego refile)
--   <vault>/*.org         las notas, archivos sueltos en la raíz del vault
--                         (<leader>on pregunta el vault)
--   personal/diario.org, personal/enlaces.org (captures `j` y `e`)
--
-- Atajos globales: <leader>oa agenda, <leader>oc capture, <leader>on nota
-- nueva con prompts (título, descripción, tags). El resto son buffer-local y
-- solo existen en archivos .org; se descubren con `g?` dentro de un buffer org.
-- ============================================================================

local ORG_DIR = vim.fn.expand("~/org")

-- Crea una nota nueva con prompts tipo Obsidian: pide vault (work/personal),
-- título, descripción y tags; genera slug para el nombre de archivo y escribe
-- el encabezado (#+title/author/date/description/filetags) en
-- ~/org/<vault>/notas/<slug>.org.
local function org_new_note()
	vim.ui.select({ "personal", "work" }, { prompt = "Vault:" }, function(vault)
		if not vault then
			return
		end
	vim.ui.input({ prompt = "Título de la nota: " }, function(title)
		if not title or title == "" then
			return
		end
		vim.ui.input({ prompt = "Descripción (opcional): " }, function(desc)
			vim.ui.input({ prompt = "Tags separados por espacio (opcional): " }, function(tags)
				local slug = title
					:lower()
					:gsub("[áàä]", "a")
					:gsub("[éèë]", "e")
					:gsub("[íìï]", "i")
					:gsub("[óòö]", "o")
					:gsub("[úùü]", "u")
					:gsub("ñ", "n")
					:gsub("[^%w%s-]", "")
					:gsub("%s+", "-")
				local dir = ORG_DIR .. "/" .. vault
				vim.fn.mkdir(dir, "p")
				local path = dir .. "/" .. slug .. ".org"
				if vim.fn.filereadable(path) == 1 then
					vim.notify("La nota ya existe, abriéndola: " .. slug .. ".org")
					vim.cmd.edit(path)
					return
				end
				-- El tag del vault va siempre; los demás son opcionales
				local filetags = ":" .. vault
				if tags and tags ~= "" then
					filetags = filetags .. ":" .. tags:gsub("%s+", ":")
				end
				filetags = filetags .. ":"
				local lines = {
					"#+title: " .. title,
					"#+author: Nicolás Lasso",
					"#+date: " .. os.date("[%Y-%m-%d %a %H:%M]"),
					"#+description: " .. (desc or ""),
					"#+filetags: " .. filetags,
					"",
					"",
				}
				vim.fn.writefile(lines, path)
				vim.cmd.edit(path)
				vim.cmd.normal("G")
			end)
		end)
	end)
	end)
end

return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	config = function()
		require("orgmode").setup({
			org_agenda_files = ORG_DIR .. "/**/*",
			org_default_notes_file = ORG_DIR .. "/personal/refile.org",
			org_todo_keywords = { "TODO(t)", "NEXT(n)", "WAIT(w)", "|", "DONE(d)", "CANCELED(c)" },
			org_startup_indented = true,
			org_hide_emphasis_markers = true, -- oculta los * / _ = de énfasis (requiere conceallevel=2, ver ftplugin/org.lua)
			-- Sin ellipsis nativo: orgmode lo pinta al FINAL de la línea (después
			-- de los tags) y no es configurable. El indicador propio de abajo
			-- (decoration provider) lo pone junto al texto del título.
			org_ellipsis = "",
			-- Con el default ('overview') foldlevel queda en 0 y cualquier
			-- promote/demote (<<, >>) re-evalúa los folds y los cierra todos
			-- (issues #899/#524 de orgmode). Con 'showeverything' foldlevel es
			-- 99: los archivos abren desplegados y los folds solo se cierran
			-- cuando tú los cierras (<Tab>/<S-Tab>/zc).
			org_startup_folded = "showeverything",
			-- Los enlaces a headlines usan :ID: (id:...) en vez de ruta+título:
			-- sobreviven a refiles, renombres de archivo y a mover el subtree.
			org_id_link_to_org_use_id = true,
			mappings = {
				org = {
					-- El default es <C-Space>, que en macOS cambia el idioma del
					-- teclado. <CR> en modo normal no hace nada útil, así que:
					-- Enter sobre la línea del checkbox lo marca/desmarca.
					org_toggle_checkbox = "<CR>",
					-- Default <prefix>na: convertía <leader>on en prefijo dentro
					-- de buffers org y tapaba el atajo global de "nueva nota".
					org_add_note = "<leader>oN",
				},
				agenda = {
					org_agenda_add_note = "<leader>oN",
				},
			},
			org_log_done = "time", -- al marcar DONE, sella CLOSED: [fecha]
			org_capture_templates = {
				w = {
					description = "Tarea → inbox work",
					template = "* TODO %?\n  %u",
					target = ORG_DIR .. "/work/refile.org",
				},
				p = {
					description = "Tarea → inbox personal",
					template = "* TODO %?\n  %u",
					target = ORG_DIR .. "/personal/refile.org",
				},
				T = {
					description = "Tarea con enlace a donde estoy",
					template = "* TODO %?\n  %u\n  %a",
				},
				n = {
					description = "Nota rápida",
					template = "* %^{Título}\n  :PROPERTIES:\n  :AUTHOR: Nicolás Lasso\n  :CREATED: %U\n  :DESCRIPTION: %^{Descripción}\n  :END:\n  %?",
				},
				e = {
					description = "Enlace (URL del portapapeles)",
					template = "* %^{Título}\n  %U\n  %x\n  %?",
					target = ORG_DIR .. "/personal/enlaces.org",
				},
				j = {
					description = "Diario",
					template = "* %<%H:%M> %?",
					target = ORG_DIR .. "/personal/diario.org",
					datetree = true,
				},
			},
		})

		vim.keymap.set("n", "<leader>on", org_new_note, { desc = "Org: nueva nota (con prompts)" })

		-- <leader>op: promueve el headline bajo el cursor a su propio archivo.
		-- Solo pregunta el vault: crea ~/org/<vault>/<slug-del-título>.org con
		-- encabezado y mueve ahí el subtree completo (refile vía API, así que
		-- el :ID: viaja con él y los enlaces id: siguen funcionando).
		local function org_promote_to_file()
			local api = require("orgmode.api")
			local headline = api.current():get_closest_headline()
			if not headline then
				vim.notify("No hay headline bajo el cursor", vim.log.levels.WARN)
				return
			end
			local title = headline.title
			vim.ui.select({ "personal", "work" }, { prompt = "Vault:" }, function(vault)
				if not vault then
					return
				end
				local slug = title
					:lower()
					:gsub("[áàä]", "a")
					:gsub("[éèë]", "e")
					:gsub("[íìï]", "i")
					:gsub("[óòö]", "o")
					:gsub("[úùü]", "u")
					:gsub("ñ", "n")
					:gsub("[^%w%s-]", "")
					:gsub("%s+", "-")
				local path = ORG_DIR .. "/" .. vault .. "/" .. slug .. ".org"
				if vim.fn.filereadable(path) == 0 then
					-- Los tags del headline pasan a ser filetags del archivo
					-- nuevo (además del tag del vault), sin duplicados.
					local tags = { vault }
					for _, t in ipairs(headline.tags or {}) do
						if t ~= vault then
							table.insert(tags, t)
						end
					end
					vim.fn.writefile({
						"#+title: " .. title,
						"#+author: Nicolás Lasso",
						"#+date: " .. os.date("[%Y-%m-%d %a %H:%M]"),
						"#+filetags: :" .. table.concat(tags, ":") .. ":",
						"",
					}, path)
				end
				-- Los tags ya viven en el #+filetags del archivo nuevo: se quitan
				-- del headline antes de moverlo para no duplicarlos.
				if #(headline.tags or {}) > 0 then
					headline:set_tags({}):wait()
					headline = api.current():get_closest_headline()
				end
				api.refile({ source = headline, destination = api.load(path) })
				vim.notify("Promovido a " .. vault .. "/" .. slug .. ".org")
			end)
		end

		-- <leader>of: "enfoca" el headline actual en una pestaña nueva — mismo
		-- buffer (no hay nada que sincronizar), pero los folds son por ventana:
		-- se pliega todo y se abre solo el subtree bajo el cursor. Cerrar la
		-- pestaña (:q o ZZ) devuelve al archivo y posición originales.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			group = vim.api.nvim_create_augroup("illico_org_focus", { clear = true }),
			callback = function(ev)
				vim.keymap.set("n", "<leader>of", function()
					vim.cmd("tab split")
					vim.cmd("normal! zMzv")
				end, { buffer = ev.buf, desc = "Org: enfocar headline en su propia pestaña (:q para volver)" })
				vim.keymap.set("n", "<leader>op", org_promote_to_file, {
					buffer = ev.buf,
					desc = "Org: promover headline a su propio archivo",
				})
			end,
		})

		-- Indicador de fold "..." pegado al título del headline (no al final de
		-- la línea, donde chocaba visualmente con los tags). Se dibuja como
		-- virt_text efímero sobre el espacio de relleno que precede a los tags;
		-- si el headline no tiene tags, va tras el fin de línea.
		local fold_ns = vim.api.nvim_create_namespace("illico_org_fold_hint")
		local fold_closed = {} -- winid -> { [fila 0-based] = true }
		vim.api.nvim_set_decoration_provider(fold_ns, {
			on_win = function(_, winid, bufnr, topline, botline)
				if vim.bo[bufnr].filetype ~= "org" then
					fold_closed[winid] = nil
					return false
				end
				local closed = {}
				vim.api.nvim_win_call(winid, function()
					local lnum = topline + 1
					while lnum <= botline + 1 do
						local fc = vim.fn.foldclosed(lnum)
						if fc == -1 then
							lnum = lnum + 1
						else
							closed[fc - 1] = true
							lnum = vim.fn.foldclosedend(lnum) + 1
						end
					end
				end)
				fold_closed[winid] = closed
			end,
			on_line = function(_, winid, bufnr, row)
				local closed = fold_closed[winid]
				if not closed or not closed[row] then
					return
				end
				local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
				local stars = line and line:match("^(%*+)")
				if not stars then
					return
				end
				-- Mismo color que el headline, igual que el ellipsis nativo
				local hl = "@org.headline.level" .. ((#stars - 1) % 8 + 1)
				-- Fin del título: antes del relleno de espacios que alinea los tags
				local tag_start = line:find("%s%s+:[%w_@#%%:]+:%s*$")
				local opts = { hl_mode = "combine", ephemeral = true }
				if tag_start then
					opts.virt_text = { { " ...", hl } }
					opts.virt_text_pos = "overlay"
					vim.api.nvim_buf_set_extmark(bufnr, fold_ns, row, tag_start, opts)
				else
					opts.virt_text = { { " ...", hl } }
					opts.virt_text_pos = "eol"
					vim.api.nvim_buf_set_extmark(bufnr, fold_ns, row, 0, opts)
				end
			end,
		})

		-- Estilo Obsidian: seguir un enlace [[file:...]] hacia una nota que no
		-- existe abre un buffer nuevo (orgmode usa :edit); este autocmd hace que
		-- ese buffer nazca con el encabezado ya puesto (título derivado del
		-- nombre del archivo). La nota se crea en disco recién al guardar.
		vim.api.nvim_create_autocmd("BufNewFile", {
			group = vim.api.nvim_create_augroup("illico_org_new_from_link", { clear = true }),
			pattern = ORG_DIR .. "/**/*.org",
			callback = function(ev)
				local title = vim.fn.fnamemodify(ev.file, ":t:r"):gsub("-", " "):gsub("^%l", string.upper)
				vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, {
					"#+title: " .. title,
					"#+author: Nicolás Lasso",
					"#+date: " .. os.date("[%Y-%m-%d %a %H:%M]"),
					"#+filetags: ",
					"",
					"",
				})
			end,
		})
	end,
}
