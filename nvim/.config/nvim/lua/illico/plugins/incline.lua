return {
	"b0o/incline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"lewis6991/gitsigns.nvim",
		"SmiteshP/nvim-navic",
	},
	event = "BufReadPre",
	config = function()
		local devicons = require("nvim-web-devicons")
		local navic = require("nvim-navic")

                require("incline").setup({
                        window = {
                                padding = { left = 1, right = 1 },
                                margin = { horizontal = 1, vertical = 1 },
                                placement = { horizontal = "right", vertical = "top" },
				zindex = 45,
				winhighlight = {
					active = {
						Normal = "InclineNormal",
						EndOfBuffer = "None",
					},
					inactive = {
						Normal = "InclineNormalNC",
						EndOfBuffer = "None",
					},
				},
                        },
                        render = function(props)
                                vim.api.nvim_set_hl(0, "InclineNavicSeparator", { fg = "#6c7086" })

                                local full_path = vim.api.nvim_buf_get_name(props.buf)
                                local display_path = vim.fn.fnamemodify(full_path, ":~:.:h")
                                local filename = vim.fn.fnamemodify(full_path, ":t")
                                if filename == "" then
                                        filename = "[No Name]"
                                end
				local ft_icon, ft_color = devicons.get_icon_color(filename)
				local modified = vim.bo[props.buf].modified

				-- Git diff info
                                local function get_git_diff()
                                        local icons = {
                                                added = { icon = " ", hl = "DiffAdd" },
                                                changed = { icon = " ", hl = "DiffChange" },
                                                removed = { icon = " ", hl = "DiffDelete" },
                                        }
                                        local signs = vim.b[props.buf].gitsigns_status_dict
                                        if not signs then
                                                return {}
                                        end
                                        local labels = {}
                                        for _, name in ipairs({ "added", "changed", "removed" }) do
                                                local data = icons[name]
                                                local count = tonumber(signs[name])
                                                if count and count > 0 then
                                                        table.insert(labels, { data.icon .. count .. " ", group = data.hl })
                                                end
                                        end
                                        if #labels > 0 then
                                                table.insert(labels, { "│ " })
                                        end
                                        return labels
                                end

                                -- Diagnostic info
                                local function get_diagnostic_label()
                                        local icons = {
                                                error = " ",
                                                warn = " ",
                                                info = " ",
                                                hint = " ",
                                        }
                                        local hl_map = {
                                                error = "DiagnosticSignError",
                                                warn = "DiagnosticSignWarn",
                                                info = "DiagnosticSignInfo",
                                                hint = "DiagnosticSignHint",
                                        }
                                        local label = {}
                                        for _, severity in ipairs({ "error", "warn", "info", "hint" }) do
                                                local icon = icons[severity]
                                                local n = #vim.diagnostic.get(props.buf, {
                                                        severity = vim.diagnostic.severity[string.upper(severity)],
                                                })
                                                if n > 0 then
                                                        table.insert(label, { icon .. n .. " ", group = hl_map[severity] })
                                                end
                                        end
                                        if #label > 0 then
                                                table.insert(label, { "│ " })
                                        end
                                        return label
                                end

                                -- Navic breadcrumbs
                                local function get_navic_breadcrumbs()
                                        if navic.is_available(props.buf) then
                                                local location = navic.get_location({ highlight = true })
                                                if location ~= "" then
                                                        return {
                                                                { "󰋖  ", group = "InclineNavicSeparator" },
                                                                { location .. " ", group = "NavicText" },
                                                                { "│ ", group = "InclineNavicSeparator" },
                                                        }
                                                end
                                        end
                                        return {}
                                end

                                local result = {}

                                table.insert(result, { "▊ ", guifg = "#89b4fa" })

                                -- Add diagnostic labels
                                vim.list_extend(result, get_diagnostic_label())

                                -- Add git diff
                                vim.list_extend(result, get_git_diff())

                                -- Add directory path when available
                                if display_path ~= "" and display_path ~= "." then
                                        table.insert(result, { display_path .. "/", guifg = "#89dceb" })
                                        table.insert(result, { " " })
                                end

                                -- Add breadcrumbs with separator
                                local breadcrumbs = get_navic_breadcrumbs()
                                if #breadcrumbs > 0 then
                                        vim.list_extend(result, breadcrumbs)
                                end

				-- Add file icon and name
                                table.insert(result, { (ft_icon or "") .. " ", guifg = ft_color or "#89b4fa", guibg = "none" })
                                table.insert(result, {
                                        filename,
                                        gui = modified and "bold,italic" or "bold",
                                        guifg = modified and "#f9e2af" or "#cdd6f4",
                                })

				-- Modified indicator
				if modified then
					table.insert(result, { " ● ", guifg = "#f38ba8" })
				else
					table.insert(result, { " " })
				end

				-- Add window number
				table.insert(result, { "│ ", guifg = "#6c7086" })
				table.insert(result, { " " .. vim.api.nvim_win_get_number(props.win) .. " ", guifg = "#89b4fa" })

				return result
			end,
		})
	end,
}
