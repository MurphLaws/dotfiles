return {
	"stevearc/aerial.nvim",
	-- master exige Neovim >= 0.12; este nvim es 0.11.5. La rama nvim-0.11 es la
	-- mantenida para esta versión. Quitar este branch al actualizar a nvim 0.12+.
	branch = "nvim-0.11",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		-- Para markdown/quarto usa treesitter (headings); LSP donde haya symbols.
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = {
			default_direction = "right",
			min_width = 30,
			-- bg sólido del colorscheme (no transparente) para que el panel y el
			-- float se vean integrados, no como un agujero negro.
			win_opts = {
				winhighlight = table.concat({
					"Normal:AerialNormal",
					"NormalFloat:AerialNormal",
					"FloatBorder:AerialBorder",
					"EndOfBuffer:AerialNormal",
				}, ","),
			},
		},
		float = {
			border = "rounded",
			relative = "editor", -- centrado en el editor
			max_height = 0.8,
			min_height = 0.4,
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = false, -- en markdown muestra todos los headings, sin filtrar por tipo
		close_on_select = true, -- al saltar a un heading, cierra (modo TOC)
		-- Cerrar con q (default), Q o Esc para no quedar atrapado.
		keymaps = {
			["Q"] = "actions.close",
			["<Esc>"] = "actions.close",
		},
	},
	config = function(_, opts)
		require("aerial").setup(opts)
		-- Colores de aerial = colorscheme (mocha base), borde redondeado visible.
		-- En un grupo propio para que la transparencia global (que vacía
		-- NormalFloat) no se lo lleve. Se reaplica en cada ColorScheme.
		local function set_hl()
			vim.api.nvim_set_hl(0, "AerialNormal", { bg = "#1e1e2e" })
			vim.api.nvim_set_hl(0, "AerialBorder", { bg = "#1e1e2e", fg = "#585b70" })
		end
		set_hl()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("illico_aerial_hl", { clear = true }),
			callback = set_hl,
		})
	end,
	cmd = { "AerialToggle", "AerialOpen" },
	keys = {
		{ "<leader>O", "<cmd>AerialToggle right<CR>", desc = "Outline lateral (aerial)" },
		{ "<leader>a", "<cmd>AerialToggle float<CR>", desc = "Outline flotante (aerial)" },
	},
}
