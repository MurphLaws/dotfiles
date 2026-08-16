return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		-- Paleta 0x96f (la misma de ghostty/tmux)
		local bg_dark = "#262427" -- fondo del terminal
		local gray1 = "#3a373b" -- franja base de la statusline
		local gray2 = "#545452" -- chips (branch, filename, filetype, lsp)
		local fg_text = "#fcfcfa"
		local fg_dim = "#8a8887"
		local red = "#ff666d"
		local green = "#bee55e"
		local yellow = "#ffc739"
		local cyan = "#9deaf6" -- chip de modo / location (celeste pálido)
		local cyan2 = "#1bd5eb"
		local purple = "#b0a3eb"
		local cream = "#fcfcfa"
		local orange = "#ff9e64" -- tokyonight orange (filename con cambios sin guardar)

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

		-- La tabline de buffers se quitó; los buffers se ven con <leader>pb
		-- (snacks) y se saltan con <leader>0-9.
		vim.o.showtabline = 1

		-- Tema estilo powerline slant: chip de modo de color, franja gris continua
		local function mode_theme(color)
			return {
				a = { fg = bg_dark, bg = color, gui = "bold" },
				b = { fg = fg_text, bg = gray1 },
				c = { fg = fg_dim, bg = gray1 },
				x = { fg = fg_dim, bg = gray1 },
				y = { fg = bg_dark, bg = cyan },
				z = { fg = bg_dark, bg = cyan2, gui = "bold" },
			}
		end
		local superset_theme = {
			normal = mode_theme(cyan),
			insert = mode_theme(green),
			visual = mode_theme(yellow),
			replace = mode_theme(red),
			command = mode_theme(purple),
			terminal = mode_theme(purple),
			inactive = {
				a = { fg = fg_dim, bg = gray1 },
				b = { fg = fg_dim, bg = gray1 },
				c = { fg = fg_dim, bg = gray1 },
			},
		}

		-- Nombre del LSP activo del buffer, como "( rust_analyzer)"
		local function lsp_name()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if #clients == 0 then
				return ""
			end
			return "( " .. clients[1].name .. ")"
		end

		-- Chevrones decorativos ❮❮❮ rojo/amarillo/crema (como en la referencia)
		local chevrons = {
			{ function() return "" end, color = { fg = red, bg = gray1 }, padding = { left = 1, right = 0 } },
			{ function() return "" end, color = { fg = yellow, bg = gray1 }, padding = 0 },
			{ function() return "" end, color = { fg = cream, bg = gray1 }, padding = { left = 0, right = 1 } },
		}

		require("lualine").setup({
			options = {
				theme = superset_theme,
				icons_enabled = true,
				component_separators = { left = "", right = "" },
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
					{ "mode", separator = { right = "" }, padding = { left = 1, right = 1 } },
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
						path = 0,
						-- Naranja cuando el buffer tiene cambios sin guardar
						color = function()
							if vim.bo.modified then
								return { fg = bg_dark, bg = orange, gui = "bold" }
							end
							return { fg = fg_text, bg = gray2 }
						end,
						separator = { left = "", right = "" },
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
						lsp_name,
						color = { fg = fg_text, bg = gray2 },
						separator = { left = "", right = "" },
					},
					chevrons[1],
					chevrons[2],
					chevrons[3],
					{
						"filetype",
						icon_only = false,
						fmt = string.upper,
						color = { fg = fg_text, bg = gray2 },
						separator = { left = "", right = "" },
					},
					{
						"encoding",
						icon = "Δ",
						color = { fg = fg_text, bg = gray1 },
					},
				},
				lualine_y = {
					{ "location", separator = { left = "" }, padding = { left = 1, right = 1 } },
				},
				lualine_z = {
					{ "progress", separator = { left = "" }, padding = { left = 1, right = 1 } },
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
			winbar = {},
			inactive_winbar = {},
			extensions = { "nvim-tree", "lazy", "quickfix", "fugitive", "mason" },
		})
	end,
}
