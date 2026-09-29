-- ftplugin para norg: numeración jerárquica (1., 1.1., …) resaltada.
-- norg no la reconoce como lista (las nativas usan ~).
-- Conceal: con conceallevel=2 el concealer de neorg oculta el {:destino:} de
-- los enlaces y deja solo la etiqueta. concealcursor vacío = la línea bajo el
-- cursor se muestra completa para editarla (mismo criterio que ftplugin/org.lua).
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""

-- Wrap por palabras completas, con las líneas envueltas indentadas.
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- Enlaces: azul + itálica (el tema los deja blancos) y un icono 󰌷 delante
-- de cada {destino}[etiqueta] como texto virtual (el destino va concealed).
vim.api.nvim_set_hl(0, "@neorg.links.description.norg", { fg = "#61afef", italic = true, underline = true })
vim.api.nvim_set_hl(0, "NorgLinkIcon", { fg = "#61afef" })

local ns = vim.api.nvim_create_namespace("norg_link_icons")
local function link_icons(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local from = 1
		while true do
			local a, b = line:find("{[^{}]*}", from)
			if not a then
				break
			end
			-- El icono va a la DERECHA del link completo, incluida la
			-- etiqueta [..] si existe.
			local _, d = line:find("^%[[^%]]*%]", b + 1)
			local endcol = d or b
			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, endcol, {
				virt_text = { { " 󰌷", "NorgLinkIcon" } },
				virt_text_pos = "inline",
			})
			from = endcol + 1
		end
	end
end
local norg_buf = vim.api.nvim_get_current_buf()
link_icons(norg_buf)
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	buffer = norg_buf,
	callback = function()
		link_icons(norg_buf)
	end,
})

-- Ciclar tareas - ( ) → (x) → (?): el default de neorg es <C-Space>, que en
-- macOS cambia la distribución del teclado.
vim.keymap.set("n", "<leader>nc", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", { buffer = true, desc = "Ciclar tarea" })

-- Meta return estilo orgmode: nueva línea abajo con el mismo formato que la
-- actual (encabezado, ítem de lista, tarea con ( )). Lo hace core.itero, que
-- solo trae <M-CR> en modo insert; el <Plug> está definido en modo "!", así
-- que desde normal se entra con A (remap para que el <Plug> se expanda).
vim.keymap.set("n", "<leader><CR>", "A<Plug>(neorg.itero.next-iteration)", { buffer = true, remap = true, desc = "Continuar objeto (meta return)" })

local numlist = require("illico.numlist")
numlist.attach(1) -- aquí ni el nivel 1 lo pinta tree-sitter
