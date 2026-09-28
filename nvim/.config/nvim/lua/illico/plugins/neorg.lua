-- Neorg vanilla: el vault vive en ~/notes (workspace «notes»).
return {
	"nvim-neorg/neorg",
	lazy = false, -- neorg recomienda cargarlo en el arranque
	version = "*",
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = { notes = "~/notes" },
						default_workspace = "notes",
					},
				},
			},
		})
	end,
}
