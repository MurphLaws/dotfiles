return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local function set_harpoon_hl()
			vim.api.nvim_set_hl(0, "HarpoonCurrent", { fg = "#ff6188", bold = true })
			vim.api.nvim_set_hl(0, "HarpoonPin", { fg = "#5fafff" })
		end
		set_harpoon_hl()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("HarpoonFilesColors", { clear = true }),
			callback = set_harpoon_hl,
		})

		local PIN = "\u{f435}"
		local MAX_LEN = 15
		local function harpoon_colored()
			local ok, harpoon = pcall(require, "harpoon")
			if not ok then
				return ""
			end
			local items = harpoon:list().items or {}
			if #items == 0 then
				return ""
			end
			local current_file = vim.fn.expand("%:p")
			local parts = {}
			for id, item in ipairs(items) do
				local file_path = vim.fn.fnamemodify(item.value, ":p")
				local fname = vim.fn.fnamemodify(file_path, ":t"):sub(1, MAX_LEN)
				local is_current = file_path == current_file
				local pin = "%#HarpoonPin#" .. PIN .. "%*"
				if is_current then
					table.insert(
						parts,
						" %#HarpoonCurrent#[" .. pin .. "%#HarpoonCurrent# " .. id .. " " .. fname .. "]%* "
					)
				else
					table.insert(parts, "  " .. pin .. " " .. id .. " " .. fname .. " ")
				end
			end
			return table.concat(parts, "")
		end

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
			tabline = {
				lualine_a = {
					{ harpoon_colored },
				},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = { "nvim-tree", "lazy", "quickfix", "fugitive", "mason" },
		})
	end,
}
