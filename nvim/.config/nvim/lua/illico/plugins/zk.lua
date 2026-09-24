return {
	"zk-org/zk-nvim",
	-- ft=markdown para que el LSP de zk se enganche al abrir cualquier nota
	-- del notebook (~/zk); los cmd permiten invocarlo desde fuera de un md.
	ft = "markdown",
	cmd = { "ZkNotes", "ZkNew", "ZkTags", "ZkBacklinks", "ZkLinks", "ZkMatch" },
	keys = {
		{ "<leader>zn", "<cmd>ZkNew { title = vim.fn.input('Título: ') }<cr>", desc = "Zk: nota nueva" },
		{ "<leader>zf", "<cmd>ZkNotes { sort = { 'modified' } }<cr>", desc = "Zk: buscar notas" },
		{ "<leader>zt", "<cmd>ZkTags<cr>", desc = "Zk: buscar por tag" },
		{ "<leader>zb", "<cmd>ZkBacklinks<cr>", desc = "Zk: backlinks de la nota" },
		{ "<leader>zl", "<cmd>ZkLinks<cr>", desc = "Zk: enlaces salientes" },
		{ "<leader>zf", ":'<,'>ZkMatch<cr>", mode = "v", desc = "Zk: buscar la selección" },
	},
	config = function()
		require("zk").setup({
			picker = "telescope",
		})
	end,
}
