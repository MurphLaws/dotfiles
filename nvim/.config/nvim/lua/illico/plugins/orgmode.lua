return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		{ "akinsho/org-bullets.nvim", config = true },
	},
	config = function()
		-- 1. DEFINE PATHS
		local local_path = os.getenv("HOME") .. "/orgfiles"
		local icloud_path = os.getenv("HOME")
			.. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"

		local local_refile_file = local_path .. "/refile.org"
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

		-- 3. SETUP ORGMODE
		require("orgmode").setup({
			-- Agenda looks at BOTH your local folder and your iCloud/Beorg folder
			org_agenda_files = {
				local_path .. "/**/*",
				icloud_path .. "/**/*",
			},

			-- Default capture goes to local machine
			org_default_notes_file = local_refile_file,

			org_hide_emphasis_markers = true,

			-- Note: <leader>oa (Agenda) and <leader>oc (Capture) are enabled by default
		})

		-- 4. CUSTOM KEYMAPS (Only the ones you invented)

		-- <leader>or -> Opens Local Refile
		vim.keymap.set("n", "<leader>or", function()
			vim.cmd.edit(local_refile_file)
		end, { desc = "Edit Local Refile" })

		-- <leader>op -> Opens Phone (Beorg) Refile
		vim.keymap.set("n", "<leader>op", function()
			vim.cmd.edit(phone_refile_file)
		end, { desc = "Edit Phone Refile" })
	end,
}
