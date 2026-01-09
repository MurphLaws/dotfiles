return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		{ "akinsho/org-bullets.nvim", config = true },
		-- Extensión vital para usar Telescope en Orgmode
		{ "nvim-orgmode/telescope-orgmode.nvim" },
	},
	config = function()
		-- 1. DEFINE PATHS (Todo centralizado en iCloud para Beorg)
		-- Ruta real de iCloud Drive para Beorg
		local icloud_path = os.getenv("HOME")
			.. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"

		-- Definimos los dos archivos principales de refile
		-- IMPORTANTE: Renombra tu archivo 'refile.org' a 'macbook-refile.org' en Finder/iCloud
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

		-- 3. SETUP TELESCOPE EXTENSION
		-- Cargamos la extensión antes de configurar Orgmode
		require("telescope").load_extension("orgmode")

		-- 4. SETUP ORGMODE
		require("orgmode").setup({
			-- La agenda busca recursivamente (**) en tu carpeta de iCloud
			org_agenda_files = {
				icloud_path .. "/**/*",
			},
			-- Las capturas por defecto (capture) van al archivo del Macbook
			org_default_notes_file = macbook_refile_file,
			org_hide_emphasis_markers = true,

			-- UI Configuration (Mejora visual de las ventanas "blandas")
			win_border = "rounded",
			org_agenda_min_height = 16,

			-- MAPPINGS CONFIGURATION
			mappings = {
				global = {
					org_agenda = "<leader>oa",
					org_capture = "<leader>oc",
				},
				org = {
					-- 🔴 DESACTIVAMOS el refile nativo para forzar el uso de Telescope
					refile = false,
				},
			},
		})

		-- 5. KEYMAPS AVANZADOS (Sobrescriben comportamientos por defecto)

		-- Usamos un autocmd para asegurar que estos atajos tengan prioridad en buffers .org
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				-- REFILE CON TELESCOPE (<leader>or)
				-- Al pulsar esto, se abrirá Telescope. Escribe el nombre del archivo (ej: "phone")
				-- o el headline directamente para mover la tarea.
				vim.keymap.set("n", "<leader>or", require("telescope").extensions.orgmode.refile_heading, {
					buffer = true,
					desc = "Refile Headline (Telescope)",
				})

				-- SEARCH HEADLINGS (<leader>os)
				-- Alternativa a la agenda: busca cualquier tarea en todos tus archivos con Telescope
				vim.keymap.set("n", "<leader>os", require("telescope").extensions.orgmode.search_headings, {
					buffer = true,
					desc = "Search Org Headings",
				})
			end,
		})

		-- Atajos globales para editar rápidamente tus archivos de inbox/refile
		vim.keymap.set("n", "<leader>om", function()
			vim.cmd.edit(macbook_refile_file)
		end, { desc = "Edit Macbook Refile" })

		vim.keymap.set("n", "<leader>op", function()
			vim.cmd.edit(phone_refile_file)
		end, { desc = "Edit Phone Refile" })

		-- 6. FIX UI: Limpieza visual de los menús de Agenda y Capture
		-- Elimina los números de línea y columnas extra que hacían que el menú se viera "feo" y desalineado
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "orgagenda", "orgcapture" },
			callback = function()
				vim.opt_local.signcolumn = "no"
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				-- Opcional: Centrar cursor o resaltar línea actual si prefieres
				vim.opt_local.cursorline = true
			end,
		})
	end,
}
