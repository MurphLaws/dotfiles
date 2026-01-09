return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		{ "akinsho/org-bullets.nvim", config = true },
		{ "nvim-telescope/telescope.nvim" },
	},
	config = function()
		-- 1. DEFINE PATHS
		local local_path = os.getenv("HOME") .. "/orgfiles"
		-- Ruta larga de iCloud
		local icloud_path = os.getenv("HOME")
			.. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"

		-- Definición de archivos específicos (Basado en tus nombres preferidos)
		local macbook_refile_file = icloud_path .. "/macbook-refile.org"
		local phone_refile_file = icloud_path .. "/phone-refile.org"

		-- 2. SETUP ORG-BULLETS
		require("org-bullets").setup({
			symbols = {
				list = "•",
				headlines = { "◉", "○", "✸", "✿" },
				checkboxes = {
					half = { "", "OrgTSCheckboxHalfChecked" },
					done = { "✓", "OrgDone" },
					todo = { " ", "OrgTODO" },
				},
			},
		})

		-- 3. DEFINE TEMPLATES LOCALLY
		local custom_templates = {
			-- Aquí puedes añadir tus plantillas personalizadas en el futuro
			-- j = { description = "Journal", template = "* %?\n  %u" }
		}

		-- 3.1 SETUP ORGMODE
		local orgmode = require("orgmode")
		orgmode.setup({
			org_agenda_files = {
				local_path .. "/**/*",
				icloud_path .. "/**/*",
			},
			-- Usamos macbook-refile como el archivo de notas por defecto
			org_default_notes_file = macbook_refile_file,
			org_hide_emphasis_markers = true,
			org_capture_templates = custom_templates,

			-- Desactivar mapeos por defecto para usar los nuestros con Telescope
			mappings = {
				global = {
					org_agenda = false,
					org_capture = false,
				},
			},
		})

		-- 4. CUSTOM TELESCOPE PICKERS

		-- Agenda Picker
		local function telescope_org_agenda()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local themes = require("telescope.themes")

			local agenda_options = {
				{ label = "Agenda for current week or day", action = "agenda" },
				{ label = "List of all TODO entries", action = "todos" },
				{ label = "Match a TAGS/PROP/TODO query", action = "match" },
				{ label = "Search for keywords", action = "search" },
			}

			pickers
				.new(themes.get_dropdown({}), {
					prompt_title = "Org Agenda",
					finder = finders.new_table({
						results = agenda_options,
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.label,
								ordinal = entry.label,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							if selection then
								local cmd = selection.value.action
								if cmd == "agenda" then
									orgmode.action("agenda.agenda")
								elseif cmd == "todos" then
									orgmode.action("agenda.todos")
								elseif cmd == "match" then
									orgmode.action("agenda.tags")
								elseif cmd == "search" then
									orgmode.action("agenda.search")
								end
							end
						end)

						-- Mapear 'q' en modo Normal para cerrar la ventana
						map("n", "q", actions.close)

						return true
					end,
				})
				:find()
		end

		-- Capture Picker
		local function telescope_org_capture()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local themes = require("telescope.themes")

			local template_list = {}

			-- 1. Añadir Plantillas Personalizadas
			for key, tpl in pairs(custom_templates) do
				table.insert(template_list, { key = key, description = tpl.description or "No description" })
			end

			-- 2. Añadir Tarea por Defecto (siempre útil)
			if #template_list == 0 then
				table.insert(template_list, { key = "t", description = "Task" })
			end

			pickers
				.new(themes.get_dropdown({}), {
					prompt_title = "Org Capture",
					finder = finders.new_table({
						results = template_list,
						entry_maker = function(entry)
							-- FIX: Usamos entry directamente para evitar error de nil value
							return {
								value = entry,
								display = string.format("[%s] %s", entry.key, entry.description),
								ordinal = entry.key .. " " .. entry.description,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							if selection then
								require("orgmode.capture"):open_template(selection.value.key)
							end
						end)

						-- Mapear 'q' en modo Normal para cerrar la ventana
						map("n", "q", actions.close)

						return true
					end,
				})
				:find()
		end

		-- 5. KEYMAPS

		-- Integración con Telescope
		vim.keymap.set("n", "<leader>oa", telescope_org_agenda, { desc = "Org Agenda (Telescope)" })
		vim.keymap.set("n", "<leader>oc", telescope_org_capture, { desc = "Org Capture (Telescope)" })

		-- Atajos de archivos (Corregidos nombres y mapeos)
		-- <leader>om -> Abre Macbook Refile
		vim.keymap.set("n", "<leader>om", function()
			vim.cmd.edit(macbook_refile_file)
		end, { desc = "Edit Macbook Refile" })

		-- <leader>op -> Abre Phone Refile
		vim.keymap.set("n", "<leader>op", function()
			vim.cmd.edit(phone_refile_file)
		end, { desc = "Edit Phone Refile" })
	end,
}
