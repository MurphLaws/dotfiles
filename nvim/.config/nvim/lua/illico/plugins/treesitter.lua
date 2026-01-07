return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master", -- CRITICAL: Forces the stable legacy version
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			treesitter.setup({
				-- Enable syntax highlighting
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				-- Enable indentation
				indent = { enable = true },

				-- Ensure these languages parsers are installed
				ensure_installed = {
					"json",
					"javascript",
					"typescript",
					"tsx",
					"go",
					"yaml",
					"html",
					"css",
					"python",
					"http",
					"prisma",
					"markdown",
					"markdown_inline",
					"svelte",
					"graphql",
					"bash",
					"lua",
					"vim",
					"dockerfile",
					"gitignore",
					"query",
					"vimdoc",
					"c",
					"java",
					"rust",
					"ron",
					"norg", -- Required for Neorg
					"gdscript", -- Godot GDScript
					"gdshader", -- Godot Shaders
					"godot_resource", -- Godot Resources
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
					},
				},
			})
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
