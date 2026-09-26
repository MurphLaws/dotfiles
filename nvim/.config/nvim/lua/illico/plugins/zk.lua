return {
	"zk-org/zk-nvim",
	-- ft=markdown para que el LSP de zk se enganche al abrir cualquier nota
	-- del notebook (~/zk); los cmd permiten invocarlo desde fuera de un md.
	ft = "markdown",
	cmd = { "ZkNotes", "ZkNew", "ZkTags", "ZkBacklinks", "ZkLinks", "ZkMatch", "ZkInsertLink", "ZkInsertLinkAtSelection" },
	keys = {
		{ "<leader>zn", "<cmd>ZkNew { title = vim.fn.input('Título: ') }<cr>", desc = "Zk: nota nueva" },
		{ "<leader>zf", "<cmd>ZkNotes { sort = { 'modified' } }<cr>", desc = "Zk: buscar notas" },
		{ "<leader>zt", "<cmd>ZkTags<cr>", desc = "Zk: buscar por tag" },
		{ "<leader>zb", "<cmd>ZkBacklinks<cr>", desc = "Zk: backlinks de la nota" },
		{ "<leader>zl", "<cmd>ZkLinks<cr>", desc = "Zk: enlaces salientes" },
		{ "<leader>zf", ":'<,'>ZkMatch<cr>", mode = "v", desc = "Zk: buscar la selección" },
		{ "<leader>zi", "<cmd>ZkInsertLink<cr>", desc = "Zk: insertar link a nota" },
		{ "<leader>zi", ":'<,'>ZkInsertLinkAtSelection<cr>", mode = "v", desc = "Zk: link con la selección como título" },
	},
	config = function()
		require("zk").setup({
			picker = "telescope",
		})

		-- Seguir links con <CR>: en zk "seguir link" = go-to-definition del LSP.
		-- Solo en buffers donde se adjunta el LSP de zk (notas del notebook).
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("ZkFollowLink", {}),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.name == "zk" then
					vim.keymap.set("n", "<CR>", function()
						-- zk y marksman devuelven cada uno el mismo destino; sin esto,
						-- los 2 resultados abren el quickfix en vez de saltar.
						vim.lsp.buf.definition({
							on_list = function(list)
								vim.fn.setqflist({}, " ", list)
								vim.cmd.cfirst()
							end,
						})
					end, { buffer = ev.buf, desc = "Zk: seguir link" })
				end
			end,
		})
	end,
}
