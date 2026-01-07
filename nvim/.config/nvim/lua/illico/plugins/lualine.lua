return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto", -- 'auto' detectará que usas catppuccin y usará los colores correctos por modo
				icons_enabled = true,
				component_separators = { left = "│", right = "│" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "dashboard", "alpha", "starter" },
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = {
					{ "mode", icon = "", separator = { right = "" }, padding = { left = 1, right = 1 } },
				},
				lualine_b = {
					{ "branch", icon = "" },
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " ●",
							readonly = " ",
							unnamed = "[No Name]",
							newfile = " ",
						},
					},
				},
				lualine_x = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
					},
					{
						"encoding",
						fmt = function(str)
							return str:upper()
						end,
					},
					{
						"fileformat",
						symbols = {
							unix = "", -- macOS icon
							dos = "",
							mac = "",
						},
					},
					{ "filetype", icon_only = false },
				},
				lualine_y = {
					{ "progress", separator = { left = "" }, padding = { left = 1, right = 1 } },
				},
				lualine_z = {
					{ "location", icon = "", separator = { left = "" }, padding = { left = 1, right = 1 } },
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = { "nvim-tree", "lazy", "quickfix", "fugitive", "mason" },
		})
	end,
}
