-- ============================================================================
-- telescope-orgmode.nvim — extensión oficial que reemplaza los prompts nativos
-- de orgmode (refile, insert link) por pickers de Telescope con fuzzy real, y
-- añade búsqueda de headlines y tags sobre todos los org_agenda_files.
-- Dentro del picker: <C-Space> alterna entre headlines y archivos.
-- ============================================================================

return {
	"nvim-orgmode/telescope-orgmode.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-orgmode/orgmode",
		"nvim-telescope/telescope.nvim",
	},
	-- El toggle headline/archivo viene hardcodeado como <C-Space> (sin opción
	-- de config). Este build lo parchea a <Tab> y se re-aplica en cada update.
	build = [[sh -c "sed -i '' 's/<c-space>/<Tab>/g' lua/telescope-orgmode/adapters/telescope.lua"]],
	config = function()
		require("telescope").load_extension("orgmode")
		local ext = require("telescope").extensions.orgmode

		vim.keymap.set("n", "<leader>oh", ext.search_headings, { desc = "Org: buscar headlines" })
		vim.keymap.set("n", "<leader>oT", ext.search_tags, { desc = "Org: buscar por tag" })

		-- En buffers org, pisa los atajos nativos de refile e insertar link con
		-- las versiones Telescope. Este autocmd se registra después del de
		-- orgmode (es dependencia), así que su mapeo buffer-local gana.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			group = vim.api.nvim_create_augroup("illico_telescope_orgmode", { clear = true }),
			callback = function(ev)
				vim.keymap.set("n", "<leader>or", ext.refile_heading, {
					buffer = ev.buf,
					desc = "Org: refile (Telescope)",
				})
				vim.keymap.set("n", "<leader>oli", ext.insert_link, {
					buffer = ev.buf,
					desc = "Org: insertar link (Telescope)",
				})
			end,
		})
	end,
}
