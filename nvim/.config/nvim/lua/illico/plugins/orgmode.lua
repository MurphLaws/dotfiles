return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	ft = { "org" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", lazy = true },
		-- Plugin para "embellecer" los símbolos (bullets, headlines)
		{ "akinsho/org-bullets.nvim", config = true },
	},
	config = function()
		-- Configuración de Org-Bullets (El "Concealer Bonito")
		require("org-bullets").setup({
			symbols = {
				-- Puedes personalizar los iconos aquí si quieres
				list = "•",
				headlines = { "◉", "○", "✸", "✿" },
				checkboxes = {
					half = { "", "OrgTSCheckboxHalfChecked" },
					done = { "✓", "OrgDone" },
					todo = { " ", "OrgTODO" },
				},
			},
		})

		-- Configuración Principal de Orgmode
		require("orgmode").setup({
			org_agenda_files = { "~/orgfiles/**/*" },
			org_default_notes_file = "~/orgfiles/refile.org",

			-- Ocultar los marcadores de formato (*bold*, /italic/, _underline_)
			-- Esto hace que el texto se vea limpio como en un procesador de texto.
			org_hide_emphasis_markers = true,

			-- UI básica
			ui = {
				menu = {
					handler = function(data)
						local options = {}
						for _, item in ipairs(data.items) do
							table.insert(options, item.label .. " " .. item.desc)
						end
						vim.ui.select(options, {
							prompt = data.prompt,
						}, function(choice, idx)
							if choice then
								data.items[idx].action()
							end
						end)
					end,
				},
			},
		})

		-- Mapeos esenciales (Agenda y Captura)
		vim.keymap.set("n", "<leader>oa", function()
			require("orgmode").action("agenda.prompt")
		end, { desc = "Org Agenda" })

		vim.keymap.set("n", "<leader>oc", function()
			require("orgmode").action("capture.prompt")
		end, { desc = "Org Capture" })
	end,
}
