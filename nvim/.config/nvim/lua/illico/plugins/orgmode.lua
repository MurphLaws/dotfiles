return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		{ "danilshvalov/org-modern.nvim" },
		{ "akinsho/org-bullets.nvim" },
		{ "lukas-reineke/headlines.nvim", dependencies = "nvim-treesitter/nvim-treesitter" },
	},
	config = function()
		-- ==========================================
		-- 1. FIX COLORS (RAINBOW TEXT)
		-- ==========================================
		local function set_org_headline_colors()
			local colors = {
				level1 = "#f38ba8", -- Red
				level2 = "#fab387", -- Peach
				level3 = "#f9e2af", -- Yellow
				level4 = "#a6e3a1", -- Green
				level5 = "#89b4fa", -- Blue
				level6 = "#cba6f7", -- Mauve
				level7 = "#94e2d5", -- Teal
				level8 = "#f5c2e7", -- Pink
			}

			local set_hl = vim.api.nvim_set_hl
			set_hl(0, "OrgHeadlineLevel1", { fg = colors.level1, bold = true })
			set_hl(0, "OrgHeadlineLevel2", { fg = colors.level2, bold = true })
			set_hl(0, "OrgHeadlineLevel3", { fg = colors.level3, bold = true })
			set_hl(0, "OrgHeadlineLevel4", { fg = colors.level4, bold = true })
			set_hl(0, "OrgHeadlineLevel5", { fg = colors.level5, bold = true })
			set_hl(0, "OrgHeadlineLevel6", { fg = colors.level6, bold = true })
			set_hl(0, "OrgHeadlineLevel7", { fg = colors.level7, bold = true })
			set_hl(0, "OrgHeadlineLevel8", { fg = colors.level8, bold = true })
		end

		set_org_headline_colors()
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = set_org_headline_colors,
		})

		-- ==========================================
		-- 2. HEADLINES (LINES & BLOCKS)
		-- ==========================================
		require("headlines").setup({
			org = {
				headline_highlights = { "Headline1", "Headline2", "Headline3" },
				-- Makes the 5 dashes (-----) look like a solid line
				dash_highlight = "Dash",
				dash_string = "—",

				fat_headlines = true,
				fat_headline_upper_string = " ",
				fat_headline_lower_string = " ",
			},
		})

		-- ==========================================
		-- 3. ICONS (CLEAN GEOMETRIC)
		-- ==========================================
		require("org-bullets").setup({
			symbols = {
				list = "•",
				-- Clean progression: Solid Circle > Open Circle > Diamond > Square
				headlines = { "◉", "○", "◆", "◇", "◼", "◻" },
				checkboxes = {
					half = { "", "@org.agenda.scheduled" },
					done = { "✓", "@org.keyword.done" },
					todo = { " ", "@org.keyword.todo" },
				},
			},
		})

		-- Visual Cleanup
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				vim.opt_local.conceallevel = 2
				vim.opt_local.concealcursor = "nc"
			end,
		})

		-- ==========================================
		-- 4. CORE ORGMODE CONFIG
		-- ==========================================
		local icloud_path = os.getenv("ICLOUD_ORG_PATH")
			or (os.getenv("HOME") .. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org")
		local refile_file = icloud_path .. "/refile.org"
		local Menu = require("org-modern.menu")

		require("orgmode").setup({
			org_agenda_files = { icloud_path .. "/**/*" },
			org_default_notes_file = refile_file,
			org_hide_emphasis_markers = true,

			org_capture_templates = {
				t = {
					description = "Task",
					template = "* TODO %?\n  %u",
					target = refile_file,
					headline = "IN",
				},
			},

			mappings = {
				global = {
					org_agenda = "<leader>oa",
					org_capture = "<leader>oc",
				},
			},

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
	end,
}
