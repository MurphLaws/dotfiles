-- illico/core/options.lua

-- Disable netrw (we use mini.files for file exploration)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Desactivar providers que no se usan (solo usamos python3).
-- Silencia los warnings de :checkhealth por neovim npm / perl / ruby gem.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- ===== Basics =====
-- Configuración del cursor:
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.cursorline = true -- Resalta la línea donde está el cursor

-- :q sobre un buffer con cambios pregunta "¿Guardar?" (Y/N/C) en vez de
-- escupir E37/E162. Los buffers sin cambios (incl. vacíos sin nombre)
-- cierran sin preguntar nada.
vim.opt.confirm = true

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Auto-reload files changed outside nvim (e.g. Godot editor writing to .gd files).
-- Without this, saving triggers "WARNING: The file has been changed since reading it!!!"
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})

-- When checktime detects an external change, reload silently instead of prompting.
-- This is what actually suppresses the W11/W12 "do you want to save?" dialog.
vim.api.nvim_create_autocmd("FileChangedShell", {
	pattern = "*",
	callback = function()
		vim.v.fcs_choice = "reload"
	end,
})

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

-- Wrapping global desactivado (ideal para código)
-- Se activa localmente en orgmode/markdown según sea necesario
vim.opt.wrap = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- ===== System clipboard =====
vim.opt.clipboard = "unnamedplus"

-- ===== Movimiento Visual (Better Wrapping Navigation) =====
-- Esto permite que j y k se muevan por líneas visuales cuando hay wrapping (wrap=true),
-- pero se comporta normalmente cuando no hay wrapping.
vim.keymap.set("n", "j", "gj", { silent = true })
vim.keymap.set("n", "k", "gk", { silent = true })

-- ===== Views & Session =====
-- Where Neovim stores views
vim.opt.viewdir = vim.fn.stdpath("state") .. "/view"
vim.fn.mkdir(vim.opt.viewdir:get(), "p")

-- Save/load folds (and cursor, etc.) in views
vim.opt.viewoptions = { "cursor", "folds" }

-- ===== UI Noise Reduction =====
vim.o.wildmenu = false
vim.o.wildoptions = "" -- IMPORTANT: removes the built-in popupmenu behavior

-- ===== Transparency =====
-- Clear background for main window and floating windows
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- ===== Default filetype for new buffers =====
-- Empty unnamed buffers you create during a session (:enew) default to markdown.
-- The autocmd is registered only *after* VimEnter, so the initial startup buffer
-- is never touched — it stays a plain scratch buffer. This keeps launch fast and
-- guarantees render-markdown is NOT loaded on start (it would be pulled in by a
-- markdown filetype). This keeps launch fast.
-- ===== `nvim <carpeta>`: entrar a la carpeta =====
-- Al abrir Neovim con una carpeta como único argumento (p.ej. `nvim notes`),
-- se hace `cd` dentro de ella. Así <leader>e (mini.files abre en cwd),
-- Telescope y todo lo demás trabajan *dentro* de esa carpeta.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local argv = vim.fn.argv()
		if #argv == 1 and vim.fn.isdirectory(argv[1]) == 1 then
			vim.cmd.cd(vim.fn.fnamemodify(argv[1], ":p"))
		end
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*",
			callback = function(args)
				local buf = args.buf
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(buf) then
						return
					end
					if vim.api.nvim_get_current_buf() ~= buf then
						return
					end
					if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) == "" and vim.bo[buf].filetype == "" then
						vim.bo[buf].filetype = "markdown"
					end
				end)
			end,
		})
	end,
})
