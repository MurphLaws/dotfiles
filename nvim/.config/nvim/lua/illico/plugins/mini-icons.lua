-- mini.icons — modern flat icon set with custom Superset palette.
-- Mocks nvim-web-devicons so every plugin (telescope, lualine, snacks, oil, etc)
-- picks up the new icons + colors without touching their config.
return {
	{
		"echasnovski/mini.icons",
		version = "*",
		lazy = false,
		priority = 900, -- after colorscheme (1000), before everything else
		config = function()
			local a = _G.superset_accents or {}
			local coral = a.coral or "#d1734a"
			local green = a.green or "#67a367"
			local amber = a.amber or "#d1a72a"
			local sky = a.sky or "#74a5af"
			local mauve = a.mauve or "#9780b2"
			local red = a.red or "#b85c5c"
			local fg_dim = a.fg_dim or "#6e6863"

			require("mini.icons").setup({
				style = "glyph",

				default = {
					default = { glyph = "󰈤", hl = "MiniIconsGrey" },
					directory = { glyph = "", hl = "MiniIconsOrange" },
					extension = { glyph = "󰈔", hl = "MiniIconsGrey" },
					file = { glyph = "󰈔", hl = "MiniIconsGrey" },
					filetype = { glyph = "󰈔", hl = "MiniIconsGrey" },
					lsp = { glyph = "󰰣", hl = "MiniIconsPurple" },
					os = { glyph = "󰟀", hl = "MiniIconsGrey" },
				},

				-- Directories: all coral by default, special folders get accent variants
				directory = {
					[".git"] = { glyph = "", hl = "MiniIconsOrange" },
					[".github"] = { glyph = "", hl = "MiniIconsGrey" },
					[".venv"] = { glyph = "", hl = "MiniIconsGreen" },
					venv = { glyph = "", hl = "MiniIconsGreen" },
					["node_modules"] = { glyph = "", hl = "MiniIconsRed" },
					src = { glyph = "󰘦", hl = "MiniIconsOrange" },
					app = { glyph = "󰀻", hl = "MiniIconsOrange" },
					lib = { glyph = "󰂺", hl = "MiniIconsOrange" },
					api = { glyph = "󰘦", hl = "MiniIconsOrange" },
					test = { glyph = "󰙨", hl = "MiniIconsGreen" },
					tests = { glyph = "󰙨", hl = "MiniIconsGreen" },
					docs = { glyph = "󰈙", hl = "MiniIconsAzure" },
					doc = { glyph = "󰈙", hl = "MiniIconsAzure" },
					public = { glyph = "󰉋", hl = "MiniIconsAzure" },
					assets = { glyph = "󰦨", hl = "MiniIconsPurple" },
					images = { glyph = "󰋩", hl = "MiniIconsPurple" },
					img = { glyph = "󰋩", hl = "MiniIconsPurple" },
					screenshots = { glyph = "󰹑", hl = "MiniIconsPurple" },
					dataset = { glyph = "󰆼", hl = "MiniIconsGreen" },
					data = { glyph = "󰆼", hl = "MiniIconsGreen" },
					notebooks = { glyph = "", hl = "MiniIconsYellow" },
					pipeline = { glyph = "󰧪", hl = "MiniIconsOrange" },
					draft = { glyph = "󰦨", hl = "MiniIconsYellow" },
					config = { glyph = "", hl = "MiniIconsGrey" },
					configs = { glyph = "", hl = "MiniIconsGrey" },
					[".config"] = { glyph = "", hl = "MiniIconsGrey" },
					scripts = { glyph = "󰒓", hl = "MiniIconsOrange" },
					utils = { glyph = "󰒓", hl = "MiniIconsAzure" },
					components = { glyph = "󱓼", hl = "MiniIconsAzure" },
					hooks = { glyph = "󰓹", hl = "MiniIconsPurple" },
					pages = { glyph = "󰈚", hl = "MiniIconsAzure" },
					styles = { glyph = "󰌜", hl = "MiniIconsPurple" },
					build = { glyph = "󰒓", hl = "MiniIconsGrey" },
					dist = { glyph = "󰒓", hl = "MiniIconsGrey" },
				},

				-- File extensions — colored to match Superset's Files panel vibe
				extension = {
					-- Web / JS family
					js = { glyph = "󰌞", hl = "MiniIconsYellow" },
					jsx = { glyph = "", hl = "MiniIconsAzure" },
					ts = { glyph = "󰛦", hl = "MiniIconsAzure" },
					tsx = { glyph = "", hl = "MiniIconsAzure" },
					mjs = { glyph = "󰌞", hl = "MiniIconsYellow" },
					cjs = { glyph = "󰌞", hl = "MiniIconsYellow" },
					vue = { glyph = "󰡄", hl = "MiniIconsGreen" },
					svelte = { glyph = "", hl = "MiniIconsOrange" },
					astro = { glyph = "", hl = "MiniIconsOrange" },

					-- Styling
					css = { glyph = "󰌜", hl = "MiniIconsAzure" },
					scss = { glyph = "󰌜", hl = "MiniIconsPurple" },
					sass = { glyph = "󰌜", hl = "MiniIconsPurple" },
					less = { glyph = "󰌜", hl = "MiniIconsAzure" },
					html = { glyph = "󰌝", hl = "MiniIconsOrange" },

					-- Python
					py = { glyph = "󰌠", hl = "MiniIconsGreen" },
					ipynb = { glyph = "", hl = "MiniIconsOrange" },
					pyi = { glyph = "󰌠", hl = "MiniIconsGreen" },

					-- Lua / Vim
					lua = { glyph = "󰢱", hl = "MiniIconsPurple" },
					vim = { glyph = "", hl = "MiniIconsGreen" },

					-- Systems
					go = { glyph = "󰟓", hl = "MiniIconsAzure" },
					rs = { glyph = "󱘗", hl = "MiniIconsOrange" },
					c = { glyph = "󰙱", hl = "MiniIconsAzure" },
					h = { glyph = "󰙲", hl = "MiniIconsPurple" },
					cpp = { glyph = "󰙲", hl = "MiniIconsAzure" },
					hpp = { glyph = "󰙲", hl = "MiniIconsPurple" },

					-- Data / config
					json = { glyph = "󰘦", hl = "MiniIconsYellow" },
					jsonc = { glyph = "󰘦", hl = "MiniIconsYellow" },
					yaml = { glyph = "󰈙", hl = "MiniIconsOrange" },
					yml = { glyph = "󰈙", hl = "MiniIconsOrange" },
					toml = { glyph = "󰈙", hl = "MiniIconsOrange" },
					xml = { glyph = "󰗀", hl = "MiniIconsOrange" },
					csv = { glyph = "󰈚", hl = "MiniIconsGreen" },
					sql = { glyph = "󰆼", hl = "MiniIconsAzure" },
					env = { glyph = "󰒓", hl = "MiniIconsYellow" },

					-- Docs
					md = { glyph = "󰍔", hl = "MiniIconsAzure" },
					mdx = { glyph = "󰍔", hl = "MiniIconsAzure" },
					rst = { glyph = "󰈙", hl = "MiniIconsAzure" },
					txt = { glyph = "󰈙", hl = "MiniIconsGrey" },
					pdf = { glyph = "󰈦", hl = "MiniIconsRed" },
					tex = { glyph = "󰙩", hl = "MiniIconsAzure" },

					-- Shell
					sh = { glyph = "󱆃", hl = "MiniIconsGreen" },
					bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
					zsh = { glyph = "󱆃", hl = "MiniIconsGreen" },
					fish = { glyph = "󰈺", hl = "MiniIconsGreen" },

					-- Images
					png = { glyph = "󰋩", hl = "MiniIconsPurple" },
					jpg = { glyph = "󰋩", hl = "MiniIconsPurple" },
					jpeg = { glyph = "󰋩", hl = "MiniIconsPurple" },
					gif = { glyph = "󰵸", hl = "MiniIconsPurple" },
					svg = { glyph = "󰜡", hl = "MiniIconsYellow" },
					webp = { glyph = "󰋩", hl = "MiniIconsPurple" },

					-- Containers / infra
					Dockerfile = { glyph = "󰡨", hl = "MiniIconsAzure" },
					dockerfile = { glyph = "󰡨", hl = "MiniIconsAzure" },

					-- Lock / DS
					lock = { glyph = "󰌾", hl = "MiniIconsGrey" },
				},

				-- Specific filenames
				file = {
					[".gitignore"] = { glyph = "", hl = "MiniIconsOrange" },
					[".gitattributes"] = { glyph = "", hl = "MiniIconsOrange" },
					[".gitmodules"] = { glyph = "", hl = "MiniIconsOrange" },
					[".env"] = { glyph = "󰒓", hl = "MiniIconsYellow" },
					[".env.local"] = { glyph = "󰒓", hl = "MiniIconsYellow" },
					[".DS_Store"] = { glyph = "󰀵", hl = "MiniIconsGrey" },
					["README.md"] = { glyph = "󰂺", hl = "MiniIconsAzure" },
					["readme.md"] = { glyph = "󰂺", hl = "MiniIconsAzure" },
					["LICENSE"] = { glyph = "󰿃", hl = "MiniIconsYellow" },
					["package.json"] = { glyph = "󰎙", hl = "MiniIconsRed" },
					["package-lock.json"] = { glyph = "󰌾", hl = "MiniIconsRed" },
					["yarn.lock"] = { glyph = "󰌾", hl = "MiniIconsAzure" },
					["pnpm-lock.yaml"] = { glyph = "󰌾", hl = "MiniIconsYellow" },
					["tsconfig.json"] = { glyph = "󰛦", hl = "MiniIconsAzure" },
					["Cargo.toml"] = { glyph = "󱘗", hl = "MiniIconsOrange" },
					["Cargo.lock"] = { glyph = "󰌾", hl = "MiniIconsOrange" },
					["pyproject.toml"] = { glyph = "󰌠", hl = "MiniIconsGreen" },
					["requirements.txt"] = { glyph = "󰌠", hl = "MiniIconsGreen" },
					["Makefile"] = { glyph = "󰒓", hl = "MiniIconsOrange" },
					["Dockerfile"] = { glyph = "󰡨", hl = "MiniIconsAzure" },
					["docker-compose.yml"] = { glyph = "󰡨", hl = "MiniIconsAzure" },
					["docker-compose.yaml"] = { glyph = "󰡨", hl = "MiniIconsAzure" },
				},
			})

			-- Make every plugin that requires nvim-web-devicons get mini.icons
			MiniIcons.mock_nvim_web_devicons()

			-- Reapply our palette to the highlight groups in case earlier setup overrode them
			vim.api.nvim_set_hl(0, "MiniIconsAzure",  { fg = sky })
			vim.api.nvim_set_hl(0, "MiniIconsBlue",   { fg = sky })
			vim.api.nvim_set_hl(0, "MiniIconsCyan",   { fg = sky })
			vim.api.nvim_set_hl(0, "MiniIconsGreen",  { fg = green })
			vim.api.nvim_set_hl(0, "MiniIconsGrey",   { fg = fg_dim })
			vim.api.nvim_set_hl(0, "MiniIconsOrange", { fg = coral })
			vim.api.nvim_set_hl(0, "MiniIconsPurple", { fg = mauve })
			vim.api.nvim_set_hl(0, "MiniIconsRed",    { fg = red })
			vim.api.nvim_set_hl(0, "MiniIconsYellow", { fg = amber })
		end,
	},
}
