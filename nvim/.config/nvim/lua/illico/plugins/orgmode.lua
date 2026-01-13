return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		{ "danilshvalov/org-modern.nvim" },
		{ "akinsho/org-bullets.nvim" },
	},
	config = function()
		-- ==========================================
		-- 1. ICONOS ESTILO NEORG (GEOMÉTRICOS)
		-- ==========================================
		require("org-bullets").setup({
			symbols = {
				list = "•",
				headlines = { "◉", "○", "●", "◈", "◆", "▪" },
				checkboxes = {
					half = { "", "@org.agenda.scheduled" },
					done = { "✓", "@org.keyword.done" },
					todo = { " ", "@org.keyword.todo" },
				},
			},
		})

		-- ==========================================
		-- 2. LIMPIEZA VISUAL (Ocultar sintaxis)
		-- ==========================================
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				vim.opt_local.conceallevel = 2
				vim.opt_local.concealcursor = "nc"
			end,
		})

		-- ==========================================
		-- 3. LÓGICA CORE DE ORGMODE
		-- ==========================================
		local icloud_path = os.getenv("ICLOUD_ORG_PATH")
			or (os.getenv("HOME") .. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org")
		local refile_file = icloud_path .. "/refile.org"
		local Menu = require("org-modern.menu")

		require("orgmode").setup({
			org_agenda_files = { icloud_path .. "/**/*" },
			org_default_notes_file = refile_file,
			org_hide_emphasis_markers = true,
			org_startup_indented = true,

			org_capture_templates = {
				t = {
					description = "Task",
					template = "* TODO %?\n  %u",
					target = refile_file,
					headline = "IN",
				},
			},

			-- --- UPDATE HERE ---
			mappings = {
				global = {
					org_agenda = "<leader>oa",
					org_capture = "<leader>oc",
				},
				org = {
					-- Remap the checkbox toggle to <leader>cc
					org_toggle_checkbox = "<leader>cc",
				},
			},
			-- -------------------

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
							icons = { separator = "➜" },
						}):open(data)
					end,
				},
			},
		})

		vim.keymap.set("n", "<leader>or", function()
			vim.cmd.edit(refile_file)
		end, { desc = "Edit Refile" })

		-- ==========================================
		-- 4. COLORES PERSONALIZADOS (PASTEL + LINKS)
		-- ==========================================
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				-- Headlines (Pastel Macaron Palette)
				vim.api.nvim_set_hl(0, "@org.headline.level1", { fg = "#F28FAD", bold = true }) -- Pastel Flamingo
				vim.api.nvim_set_hl(0, "@org.headline.level2", { fg = "#F8BD96", bold = true }) -- Pastel Peach
				vim.api.nvim_set_hl(0, "@org.headline.level3", { fg = "#FAE3B0", bold = true }) -- Pastel Wheat
				vim.api.nvim_set_hl(0, "@org.headline.level4", { fg = "#ABE9B3", bold = true }) -- Pastel Matcha
				vim.api.nvim_set_hl(0, "@org.headline.level5", { fg = "#96CDFB", bold = true }) -- Pastel Sky
				vim.api.nvim_set_hl(0, "@org.headline.level6", { fg = "#DDB6F2", bold = true }) -- Pastel Lavender

				-- Links (Italic + Underlined + Pastel Teal)
				local link_opts = { fg = "#94E2D5", underline = true, italic = true }
				vim.api.nvim_set_hl(0, "@org.hyperlink", link_opts)
				vim.api.nvim_set_hl(0, "@org.hyperlink.desc", link_opts)
			end,
		})

		vim.cmd("doautocmd ColorScheme")
	end,
}
