return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>e",
				function()
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].filetype == "oil" and vim.api.nvim_win_get_config(win).relative == "" then
							vim.api.nvim_win_close(win, true)
							return
						end
					end
					vim.cmd("topleft vsplit | vertical resize 32 | Oil")
				end,
				desc = "Oil: Toggle side panel file explorer",
			},
			{
				"<leader>E",
				function()
					require("oil").toggle_float()
				end,
				desc = "Oil: Floating file explorer",
			},
		},
		config = function(_, opts)
			require("oil").setup(opts)

			-- Refresh open oil buffers when nvim regains focus, so file/folder
			-- moves done inside Godot (or any other external tool) show up
			-- without having to close and reopen the explorer.
			vim.api.nvim_create_autocmd("FocusGained", {
				group = vim.api.nvim_create_augroup("IllicoOilAutoRefresh", { clear = true }),
				callback = function()
					local ok, actions = pcall(require, "oil.actions")
					if not ok then
						return
					end
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].filetype == "oil" then
							vim.api.nvim_win_call(win, function()
								pcall(actions.refresh.callback)
							end)
						end
					end
				end,
			})
		end,
		opts = {
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name:match("%.uid$") ~= nil
				end,
			},
			float = {
				padding = 4,
				max_width = 0.6,
				max_height = 0.7,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},
			keymaps = {
				["q"] = "actions.close",
				["<esc>"] = "actions.close",
				["<CR>"] = {
					desc = "Open file in main window, keep sidebar",
					callback = function()
						local oil = require("oil")
						local entry = oil.get_cursor_entry()
						if not entry then
							return
						end
						if entry.type == "directory" then
							oil.select()
							return
						end
						local dir = oil.get_current_dir()
						if not dir then
							oil.select()
							return
						end
						local path = dir .. entry.name
						local sidebar_win = vim.api.nvim_get_current_win()
						local target_win
						for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
							if win ~= sidebar_win then
								local buf = vim.api.nvim_win_get_buf(win)
								local cfg = vim.api.nvim_win_get_config(win)
								if vim.bo[buf].filetype ~= "oil" and cfg.relative == "" then
									target_win = win
									break
								end
							end
						end
						if target_win then
							vim.api.nvim_set_current_win(target_win)
							vim.cmd("edit " .. vim.fn.fnameescape(path))
						else
							vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(path))
						end
					end,
				},
			},
		},
	},
}
