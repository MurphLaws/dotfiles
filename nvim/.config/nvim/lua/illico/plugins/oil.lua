return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	-- Oil sustituye a mini.files como explorador de <leader>e.
	keys = {
		{
			"<leader>e",
			function()
				require("oil").toggle_float()
			end,
			desc = "Oil: toggle floating explorer (cwd)",
		},
	},
	opts = {
		-- Se deja netrw como explorador de `nvim <carpeta>` para no cambiar el
		-- comportamiento de arranque (ver el autocmd de cd en core/options.lua).
		default_file_explorer = false,
		columns = { "icon" },
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,
		view_options = {
			show_hidden = true,
			-- Mismo ruido que se ocultaba en mini.files: metadatos del editor
			-- en proyectos Godot y dotfiles de repo.
			is_always_hidden = function(name, _)
				local hidden = {
					[".godot"] = true,
					[".editorconfig"] = true,
					[".gitattributes"] = true,
					[".gitignore"] = true,
					[".DS_Store"] = true,
				}
				if hidden[name] then
					return true
				end
				return name:match("%.uid$") ~= nil or name:match("%.import$") ~= nil
			end,
		},
		float = {
			padding = 2,
			max_width = 0.7,
			max_height = 0.8,
			border = "rounded",
			-- El flotante debe quedar sobre zen-mode y otros flotantes, igual
			-- que hacía mini.files.
			override = function(conf)
				conf.zindex = 100
				return conf
			end,
		},
		keymaps = {
			-- Paridad con lo que había en mini.files: flechas para navegar.
			-- `mode = "n"` es obligatorio: oil pasa `mode or ""` a vim.keymap.set,
			-- así que sin él el mapeo se aplicaría también en insert y no se
			-- podría escribir "q" al renombrar un archivo.
			["<Right>"] = { "actions.select", mode = "n" },
			["<Left>"] = { "actions.parent", mode = "n" },
			["q"] = { "actions.close", mode = "n" },
			["<Esc>"] = { "actions.close", mode = "n" },
		},
	},
}
