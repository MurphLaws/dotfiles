-- Abre el outline en la dirección dada y lo deja PLEGADO al nivel superior
-- (solo jornadas/apéndice visibles). Si ya está abierto, lo cierra (toggle).
-- El plegado se difiere porque los symbols se cargan async tras abrir.
local function outline(direction)
	return function()
		local aerial = require("aerial")
		if aerial.is_open() then
			aerial.close()
		else
			aerial.open({ direction = direction })
			vim.defer_fn(function()
				pcall(aerial.tree_set_collapse_level, 0, 1) -- 1 = nivel; sube para mostrar más
			end, 60)
		end
	end
end

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
			-- El max_width por defecto (0.2 del ancho) dejaba el float angosto y
			-- truncaba los títulos. Lo ampliamos para que quepan los headings.
			min_width = 40,
			max_width = { 80, 0.5 },
		},
		float = {
			-- Borde redondeado para delimitar el menú (sin él se confunde con el
			-- texto de atrás). El interior sigue transparente: NormalFloat y
			-- FloatBorder tienen bg=NONE (forzado por la config global) y
			-- winblend=0 hace que el float ocluya el buffer => se ve el
			-- ESCRITORIO dentro del menú, solo el borde lo enmarca.
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
	cmd = { "AerialToggle", "AerialOpen" },
	keys = {
		{ "<leader>O", outline("right"), desc = "Outline lateral plegado (aerial)" },
		{ "<leader>a", outline("float"), desc = "Outline flotante plegado (aerial)" },
	},
}
