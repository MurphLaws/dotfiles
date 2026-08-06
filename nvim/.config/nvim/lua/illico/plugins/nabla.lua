return {
	"jbyuki/nabla.nvim",
	ft = { "markdown", "quarto", "norg" },
	keys = {
		{
			"<leader>me",
			function()
				require("nabla").enable_virt()
			end,
			mode = "n",
			ft = { "markdown", "quarto", "norg" },
			desc = "Math: Activar render inline",
		},
		{
			"<leader>mE",
			function()
				require("nabla").disable_virt()
			end,
			mode = "n",
			ft = { "markdown", "quarto", "norg" },
			desc = "Math: Desactivar render inline",
		},
		{
			"<leader>mm",
			function()
				require("nabla").popup()
			end,
			mode = "n",
			ft = { "markdown", "quarto", "norg" },
			desc = "Math: Vista previa de fórmula",
		},
	},
}
