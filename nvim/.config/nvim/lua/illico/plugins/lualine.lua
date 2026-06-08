return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local a = _G.superset_accents or {}
		local coral = a.coral or "#d1734a"
		local peach = a.peach or "#d18960"
		local green = a.green or "#67a367"
		local amber = a.amber or "#d1a72a"
		local sky = a.sky or "#74a5af"
		local mauve = a.mauve or "#9780b2"
		local fg_dim = a.fg_dim or "#6e6863"
		local fg_text = "#c0caf5"
		local bg_dark = "#1a1b26"

		local function set_buftab_hl()
			vim.api.nvim_set_hl(0, "BufTabCurrent", { fg = amber, bold = true })
			vim.api.nvim_set_hl(0, "BufTabModified", { fg = peach })
		end
		set_buftab_hl()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("BufTabColors", { clear = true }),
			callback = set_buftab_hl,
		})

		_G.IllicoSwitchBuf = function(bufnr)
			pcall(vim.api.nvim_set_current_buf, tonumber(bufnr))
		end

		local MAX_LEN = 20

		local function is_empty_noname(buf)
			if vim.api.nvim_buf_get_name(buf) ~= "" then
				return false
			end
			if vim.bo[buf].modified then
				return false
			end
			if vim.api.nvim_buf_line_count(buf) > 1 then
				return false
			end
			local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
			return first == ""
		end

		local function listed_bufs()
			local out = {}
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.fn.buflisted(buf) == 1 and not is_empty_noname(buf) then
					table.insert(out, buf)
				end
			end
			return out
		end

		_G.IllicoSwitchByIndex = function(idx)
			local bufs = listed_bufs()
			local target = bufs[idx + 1]
			if target then
				pcall(vim.api.nvim_set_current_buf, target)
			end
		end

		for i = 0, 9 do
			vim.keymap.set("n", "<leader>" .. i, function()
				_G.IllicoSwitchByIndex(i)
			end, { desc = "tabline: jump to buffer #" .. i, silent = true })
		end

		local function buffers_tabline()
			local current_buf = vim.api.nvim_get_current_buf()
			local parts = {}
			for _, buf in ipairs(listed_bufs()) do
				local name = vim.api.nvim_buf_get_name(buf)
				local fname = (name == "" and "[No Name]")
					or vim.fn.fnamemodify(name, ":t"):sub(1, MAX_LEN)
				local is_current = buf == current_buf
				local is_modified = vim.bo[buf].modified

				local mod = is_modified and " %#BufTabModified#●%*" or ""

				local segment
				if is_current then
					segment = " %#BufTabCurrent#["
						.. fname
						.. "%*"
						.. mod
						.. "%#BufTabCurrent#]%* "
				else
					segment = "  " .. fname .. mod .. " "
				end

				table.insert(parts, "%" .. buf .. "@v:lua.IllicoSwitchBuf@" .. segment .. "%T")
			end
			return table.concat(parts, "")
		end

		local superset_theme = {
			normal = {
				a = { fg = bg_dark, bg = amber, gui = "bold" },
				b = { fg = fg_text, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
			insert = {
				a = { fg = bg_dark, bg = green, gui = "bold" },
				b = { fg = fg_text, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
			visual = {
				a = { fg = bg_dark, bg = coral, gui = "bold" },
				b = { fg = fg_text, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
			replace = {
				a = { fg = bg_dark, bg = mauve, gui = "bold" },
				b = { fg = fg_text, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
			command = {
				a = { fg = bg_dark, bg = sky, gui = "bold" },
				b = { fg = fg_text, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
			terminal = {
				a = { fg = bg_dark, bg = peach, gui = "bold" },
				b = { fg = fg_text, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
			inactive = {
				a = { fg = fg_dim, bg = "NONE" },
				b = { fg = fg_dim, bg = "NONE" },
				c = { fg = fg_dim, bg = "NONE" },
			},
		}

		require("lualine").setup({
			options = {
				theme = superset_theme,
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
					tabline = 200,
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
					{ buffers_tabline },
				},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = { "nvim-tree", "lazy", "quickfix", "fugitive", "mason" },
		})
	end,
}
