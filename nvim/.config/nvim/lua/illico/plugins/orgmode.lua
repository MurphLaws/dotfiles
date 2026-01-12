return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		-- 1. MENÚ MODERNO (Solo para la ventana flotante de acciones)
		{ "danilshvalov/org-modern.nvim" },
		-- 2. ICONOS (Solo cambiamos los asteriscos por puntos/círculos)
		{ "akinsho/org-bullets.nvim" },
		-- (Eliminado headlines.nvim para quitar fondos y espaciado extra)
	},
	config = function()
		-- ==========================================
		-- 1. CONFIGURACIÓN VISUAL (MINIMALISTA)
		-- ==========================================

		-- Configuración de iconos simples
		require("org-bullets").setup({
			symbols = {
				list = "•",
				headlines = { "◉", "○", "✸", "✿" },
				checkboxes = {
					half = { "", "@org.agenda.scheduled" },
					done = { "✓", "@org.keyword.done" },
					todo = { " ", "@org.keyword.todo" },
				},
			},
		})

		-- Ocultar asteriscos (*bold*) y marcadores de sintaxis para limpieza visual
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				vim.opt_local.conceallevel = 2
				vim.opt_local.concealcursor = "nc"
			end,
		})

		-- ==========================================
		-- 2. CONFIGURACIÓN PRINCIPAL ORGMODE
		-- ==========================================

		local icloud_path = os.getenv("HOME")
			.. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"
		local refile_file = icloud_path .. "/refile.org"

		-- Importamos el módulo del menú moderno
		local Menu = require("org-modern.menu")

		require("orgmode").setup({
			org_agenda_files = { icloud_path .. "/**/*" },
			org_default_notes_file = refile_file,
			org_hide_emphasis_markers = true,

			-- MAPPINGS
			mappings = {
				global = {
					org_agenda = "<leader>oa",
					org_capture = "<leader>oc",
				},
			},

			-- UI MENU HANDLER: Estilo Moderno Flotante
			ui = {
				menu = {
					handler = function(data)
						Menu:new({
							window = {
								margin = { 1, 0, 1, 0 },
								padding = { 0, 1, 0, 1 },
								title_pos = "center",
								border = "single",
								zindex = 1000,
							},
							icons = {
								separator = "➜",
							},
						}):open(data)
					end,
				},
			},
		})

		-- KEYMAPS EXTRA
		vim.keymap.set("n", "<leader>or", function()
			vim.cmd.edit(refile_file)
		end, { desc = "Edit Refile" })
	end,
}
