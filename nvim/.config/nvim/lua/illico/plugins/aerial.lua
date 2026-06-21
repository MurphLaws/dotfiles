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
			-- Borde redondeado para delimitar el menú; interior transparente
			-- (NormalFloat/FloatBorder con bg=NONE por la config global).
			border = "rounded",
			relative = "editor",
			max_height = 0.8,
			min_height = 0.4,
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = false, -- en markdown muestra todos los headings, sin filtrar
		-- Al seleccionar (<CR>): salta a la sección en el buffer COMPLETO, cierra
		-- el panel y deja el foco en el buffer. No parte la ventana en dos.
		close_on_select = true,
		-- Cerrar el panel con q (default), Q o Esc.
		keymaps = {
			["Q"] = "actions.close",
			["<Esc>"] = "actions.close",
		},
	},
	config = function(_, opts)
		require("aerial").setup(opts)
		-- Tecla 'e' en el panel: salta a la sección bajo el cursor y la abre en una
		-- pestaña nueva (pantalla completa, narrow). Al guardar (:w) se sincroniza
		-- con el .md original. '<CR>' sigue siendo el salto normal al buffer.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "aerial",
			group = vim.api.nvim_create_augroup("illico_aerial_narrow", { clear = true }),
			callback = function(ev)
				vim.keymap.set("n", "e", function()
					require("aerial").select()
					vim.schedule(function()
						require("illico.narrow").narrow_section()
					end)
				end, { buffer = ev.buf, desc = "Aerial: editar sección a pantalla completa (narrow)" })
			end,
		})
	end,
	cmd = { "AerialToggle", "AerialOpen" },
	keys = {
		{ "<leader>O", outline("right"), desc = "Outline lateral plegado (aerial)" },
		{ "<leader>a", outline("float"), desc = "Outline flotante plegado (aerial)" },
	},
}
