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
		-- Configuración exclusiva para iCloud
		local icloud_path = os.getenv("HOME")
			.. "/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"

		-- Cambio realizado: de phone-refile.org a refile.org
		local refile_file = icloud_path .. "/refile.org"

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
			-- Agenda looks ONLY at your iCloud/Beorg folder
			org_agenda_files = {
				icloud_path .. "/**/*",
			},

			-- Default capture goes to iCloud refile
			org_default_notes_file = refile_file,

			org_hide_emphasis_markers = true,

			-- Note: <leader>oa (Agenda) and <leader>oc (Capture) are enabled by default
		})

		-- 4. CUSTOM KEYMAPS

		-- <leader>or -> Opens Refile (iCloud)
		vim.keymap.set("n", "<leader>or", function()
			vim.cmd.edit(refile_file)
		end, { desc = "Edit Refile (iCloud)" })
	end,
}
