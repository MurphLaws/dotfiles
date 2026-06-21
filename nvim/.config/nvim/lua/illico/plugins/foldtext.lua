return {
	"OXY2DEV/foldtext.nvim",
	lazy = false,
	config = function()
		-- Salida del foldtext para markdown: icono nerd-font SOLO para Jornada,
		-- Bloque y Ejercicio; el resto de headings solo muestran su texto.
		local function md_section(buffer)
			local fs = vim.v.foldstart
			local line = (vim.api.nvim_buf_get_lines(buffer, fs - 1, fs, false)[1]) or ""
			local text = vim.trim((line:gsub("^#+%s*", "")))
			if text:find("^Jornada") then
				return { { "  ", "FtJornada" }, { text, "FtJornada" } } -- calendario
			elseif text:find("^Bloque") then
				return { { "  ", "FtBloque" }, { text, "FtBloque" } } -- bloque de texto
			elseif text:find("^Ejercicio") then
				return { { "  ", "FtEjercicio" }, { text, "FtEjercicio" } } -- maletín
			end
			return { { text, "FtHeading" } } -- otros headings: solo texto
		end

		require("foldtext").setup({
			styles = {
				-- Excluir markdown del estilo treesitter por defecto para que use
				-- el nuestro (ambos harían match; así no compiten).
				ts_expr = {
					condition = function(_, window)
						local buf = vim.api.nvim_win_get_buf(window)
						if vim.bo[buf].filetype == "markdown" then
							return false
						end
						return vim.wo[window].foldmethod == "expr"
							and vim.wo[window].foldexpr == "v:lua.vim.treesitter.foldexpr()"
					end,
				},
				markdown = {
					filetypes = { "markdown" },
					parts = {
						{ kind = "section", output = md_section },
						{
							kind = "fold_size",
							padding_left = "   ",
							icon = "󰘖 ",
							hl = "@comment",
						},
					},
				},
			},
		})

		-- Colores de los iconos/títulos en el foldtext. Llevan FONDO para que el
		-- heading plegado muestre un "highlight" (render-markdown no pinta su barra
		-- sobre el foldtext, así que el resaltado lo damos aquí).
		local function hls()
			vim.api.nvim_set_hl(0, "FtJornada", { fg = "#cba6f7", bg = "#302b40", bold = true }) -- malva
			vim.api.nvim_set_hl(0, "FtBloque", { fg = "#89b4fa", bg = "#1f2b40", bold = true }) -- azul
			vim.api.nvim_set_hl(0, "FtEjercicio", { fg = "#fab387", bg = "#3a2c1e", bold = true }) -- durazno
			vim.api.nvim_set_hl(0, "FtHeading", { fg = "#cdd6f4", bg = "#2a2b3c" }) -- otros headings
		end
		hls()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("illico_foldtext_hl", { clear = true }),
			callback = hls,
		})
	end,
}
