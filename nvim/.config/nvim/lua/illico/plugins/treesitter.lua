-- nvim-treesitter, rama `main`.
--
-- La rama `master` está congelada y su README dice literalmente "Neovim 0.10 or
-- 0.11 (Neovim 0.12 is not supported)". Sobre nvim 0.12 sus directivas de query
-- se registran con `{ all = false }`, opción que 0.12 eliminó, así que los
-- handlers recibían TSNode[] donde esperaban un TSNode y reventaban: cualquier
-- bloque ```lang en markdown rompía el highlighting.
--
-- Diferencias de `main` respecto a `master`, para que no sorprendan:
--   * no existe `nvim-treesitter.configs`; setup() solo acepta `install_dir`
--   * no soporta lazy-loading  ->  lazy = false
--   * el highlighting y el indent se activan a mano por FileType
--   * los módulos (incremental_selection, textobjects…) desaparecieron

-- `norg` no está en el registro de `main`: ese parser lo aporta neorg.
local ensure_installed = {
	"bash",
	"c",
	"css",
	"dockerfile",
	"gdscript", -- Godot GDScript
	"gdshader", -- Godot Shaders
	"gitignore",
	"go",
	"godot_resource", -- Godot Resources
	"graphql",
	"html",
	"http",
	"java",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"prisma",
	"python",
	"query",
	"regex", -- requerido por snacks.picker
	"ron",
	"rust",
	"scss", -- estilos
	"svelte",
	"tsx",
	"typescript",
	"typst", -- documentos typst
	"vim",
	"vimdoc",
	"vue", -- SFC de Vue
	"yaml",
}

-- ---------------------------------------------------------------------------
-- Selección incremental por nodos: reemplazo del módulo `incremental_selection`
-- de master. <C-space> arranca en el nodo bajo el cursor y, repetido, sube al
-- ancestro que abarque más texto.
-- ---------------------------------------------------------------------------

local function line_len(lnum)
	return #(vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1] or "")
end

-- El final de un nodo es exclusivo; lo devolvemos inclusivo y acotado a la
-- línea, que es lo que espera nvim_win_set_cursor.
local function node_range(node)
	local sr, sc, er, ec = node:range()
	if ec == 0 and er > sr then
		er = er - 1
		ec = line_len(er)
	end
	ec = math.max(ec - 1, 0)
	return sr, math.min(sc, math.max(line_len(sr) - 1, 0)), er, math.min(ec, math.max(line_len(er) - 1, 0))
end

local function selection_range()
	local a, b = vim.fn.getpos("v"), vim.fn.getpos(".")
	local sr, sc, er, ec = a[2] - 1, a[3] - 1, b[2] - 1, b[3] - 1
	if sr > er or (sr == er and sc > ec) then
		sr, sc, er, ec = er, ec, sr, sc
	end
	return sr, sc, er, ec
end

local function grow_selection()
	local buf = vim.api.nvim_get_current_buf()
	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok or not parser then
		return
	end

	local in_visual = vim.fn.mode():match("^[vV\22]") ~= nil
	local sr, sc, er, ec
	if in_visual then
		sr, sc, er, ec = selection_range()
	else
		local cursor = vim.api.nvim_win_get_cursor(0)
		sr, sc, er, ec = cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2]
	end

	parser:parse(true)
	local range = { sr, sc, er, ec + 1 }
	-- Con inyecciones (```lua dentro de markdown) el árbol correcto es el más
	-- pequeño que cubra el rango, no el de la raíz.
	local ltree = parser:language_for_range(range)
	local tree = ltree and ltree:tree_for_range(range)
	if not tree then
		return
	end

	local node = tree:root():named_descendant_for_range(sr, sc, er, ec + 1)
	-- Sube mientras el nodo no aporte más texto que la selección actual.
	while node do
		local nsr, nsc, ner, nec = node_range(node)
		local bigger = nsr < sr or ner > er or (nsr == sr and nsc < sc) or (ner == er and nec > ec)
		if not in_visual or bigger then
			break
		end
		node = node:parent()
	end
	if not node then
		return
	end

	local nsr, nsc, ner, nec = node_range(node)
	if in_visual then
		vim.cmd("normal! \27")
	end
	vim.api.nvim_win_set_cursor(0, { nsr + 1, nsc })
	vim.cmd("normal! v")
	vim.api.nvim_win_set_cursor(0, { ner + 1, nec })
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- `main` no soporta lazy-loading
		build = ":TSUpdate",
		config = function()
			-- Sin argumentos: install_dir por defecto es stdpath("data").."/site",
			-- que ya está en el runtimepath.
			require("nvim-treesitter").setup()

			-- Equivalente a `ensure_installed`: instala en segundo plano solo lo
			-- que falte (main no trae esa opción).
			local installed = require("nvim-treesitter.config").get_installed("parsers")
			local missing = vim.tbl_filter(function(lang)
				return not vim.tbl_contains(installed, lang)
			end, ensure_installed)
			if #missing > 0 then
				require("nvim-treesitter").install(missing)
			end

			-- Lo que antes hacían los módulos `highlight` e `indent`.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("illico_treesitter", { clear = true }),
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match)
					if not lang then
						return
					end
					-- Falla si el parser no está instalado; no es un error.
					if not pcall(vim.treesitter.start, ev.buf, lang) then
						return
					end
					-- master solo ponía indentexpr donde había query de indents.
					if vim.treesitter.query.get(lang, "indents") then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			for _, mode in ipairs({ "n", "x" }) do
				vim.keymap.set(mode, "<C-space>", grow_selection, {
					desc = "Treesitter: ampliar selección al nodo padre",
					silent = true,
				})
			end
		end,
	},
	-- NOTE: js,ts,jsx,tsx Auto Close Tags
	{
		"windwp/nvim-ts-autotag",
		enabled = true,
		ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
				per_filetype = {
					["html"] = { enable_close = true },
					["typescriptreact"] = { enable_close = true },
				},
			})
		end,
	},
}
