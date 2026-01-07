return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- 1. Configuración de UI (Diagnósticos y Signos)
		local signs = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
			[vim.diagnostic.severity.INFO] = " ",
		}

		vim.diagnostic.config({
			signs = { text = signs },
			virtual_text = true,
			underline = true,
			update_in_insert = true,
			severity_sort = true,
		})

		-- 2. Autocompletado (Capabilities)
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- 3. Definición de Servidores
		-- Aquí definimos la configuración de cada servidor en una tabla limpia
		local servers = {
			-- Lua
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			},
			-- Web
			html = {},
			cssls = {},
			emmet_ls = {
				filetypes = {
					"css",
					"eruby",
					"html",
					"javascript",
					"javascriptreact",
					"less",
					"sass",
					"scss",
					"pug",
					"typescriptreact",
					"svelte",
				},
			},
			-- Go
			gopls = {
				settings = {
					gopls = {
						analyses = { unusedparams = true },
						staticcheck = true,
						gofumpt = true,
					},
				},
			},
			-- TypeScript (Usamos ts_ls que es el nombre moderno)
			ts_ls = {
				init_options = {
					preferences = {
						includeCompletionsForModuleExports = true,
						includeCompletionsForImportStatements = true,
					},
				},
			},
			-- Godot (Conexión directa TCP)
			gdscript = {
				name = "godot",
				cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
			},
		}

		-- 4. Keymaps (Autocmd al adjuntar LSP)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				-- Definiciones de teclas
				opts.desc = "Show LSP references"
				vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				opts.desc = "Go to declaration"
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				opts.desc = "Show LSP definitions"
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				opts.desc = "Show documentation"
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				opts.desc = "Smart rename"
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				opts.desc = "Code Action"
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				opts.desc = "Show buffer diagnostics"
				vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				opts.desc = "Show line diagnostics"
				vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				opts.desc = "Restart LSP"
				vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- 5. Inicialización de Servidores (Lógica de Migración)

		-- Verificamos si estamos en Neovim 0.11+ (donde existe vim.lsp.config)
		if vim.fn.has("nvim-0.11") == 1 then
			-- NUEVA FORMA (Según la documentación oficial)
			for name, config in pairs(servers) do
				config.capabilities = capabilities
				-- 1. Registrar configuración
				vim.lsp.config(name, config)
				-- 2. Habilitar servidor
				vim.lsp.enable(name)
			end
		else
			-- VIEJA FORMA (Fallback para Neovim 0.10)
			-- Si estás en 0.10, el warning es inevitable, pero esto evitará el CRASH.
			local lspconfig = require("lspconfig")
			for name, config in pairs(servers) do
				config.capabilities = capabilities
				-- Verificamos que el servidor exista en lspconfig antes de configurar
				if lspconfig[name] then
					lspconfig[name].setup(config)
				end
			end
		end
	end,
}
