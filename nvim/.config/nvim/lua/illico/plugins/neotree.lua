return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		lazy = false, -- ADDED: Prevents the "flicker" when opening directories
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						source = "filesystem",
						position = "left",
						reveal = true,
					})
				end,
				desc = "Neo-tree: Filesystem",
			},
			{
				"<leader>b",
				function()
					require("neo-tree.command").execute({
						toggle = true,
						source = "buffers",
						position = "left",
					})
				end,
				desc = "Neo-tree: Open Buffers",
			},
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true, -- This handles closing safely internally
				popup_border_style = "rounded",
				filesystem = {
					follow_current_file = { enabled = true },
					hijack_netrw_behavior = "open_default",
					use_libuv_file_watcher = true,
					filtered_items = {
						visible = false,
						hide_dotfiles = false,
						hide_gitignored = false,
						hide_by_pattern = {
							"*.import",
							"*.uid",
						},
					},
				},
				buffers = {
					follow_current_file = { enabled = true },
					group_empty_dirs = true,
					show_unloaded = true,
					window = {
						mappings = {
							["bd"] = "buffer_delete",
							["<bs>"] = "navigate_up",
							["."] = "set_root",
							["w"] = "save_buffer",
						},
					},
					commands = {
						save_buffer = function(state)
							local node = state.tree:get_node()
							if node.type == "file" and node.extra and node.extra.bufnr then
								vim.api.nvim_buf_call(node.extra.bufnr, function()
									vim.cmd("write")
								end)
								print("Guardado: " .. node.name)
							else
								print("No se puede guardar este nodo.")
							end
						end,
					},
				},
				window = {
					width = 34,
					mappings = {
						["<esc>"] = "close_window",
					},
				},
			})

			-- COMMENTED OUT: This was causing the tree to close immediately
			-- when opening a directory (nvim .), because the tree is the "last window"
			-- right at the start.
			-- vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
			-- 	callback = function()
			-- 		if vim.fn.winnr("$") ~= 1 then
			-- 			return
			-- 		end
			-- 		local ft = vim.bo.filetype
			-- 		if ft == "neo-tree" then
			-- 			vim.cmd("quit")
			-- 		end
			-- 	end,
			-- })
		end,
	},
}
