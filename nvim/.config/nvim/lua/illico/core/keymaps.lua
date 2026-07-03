local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear search highlights with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Keep cursor centered while jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "<Nop>", { desc = "Disable search-next" })
vim.keymap.set("n", "N", "<Nop>", { desc = "Disable search-prev" })

-- Fast vertical movement (10 lines at a time, centered)
vim.keymap.set("n", "J", "10jzz", { desc = "Jump 10 lines down" })
vim.keymap.set("n", "K", "10kzz", { desc = "Jump 10 lines up" })
vim.keymap.set("v", "<C-j>", "10jzz", { desc = "Jump 10 lines down (visual)" })
vim.keymap.set("v", "<C-k>", "10kzz", { desc = "Jump 10 lines up (visual)" })

-- Move selected lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- Indent and maintain selection
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Clipboard things
-- Paste without replacing clipboard content
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Delete without changing clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without changing clipboard" })

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
	local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
	vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
	print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- ===== Gists (via `gh` CLI) =====
-- Picker de tus gists; llama a on_choice({ id, label }) con el elegido.
local function pick_gist(prompt, on_choice)
	local list = vim.fn.systemlist({ "gh", "gist", "list", "--limit", "100" })
	if vim.v.shell_error ~= 0 then
		vim.notify("gh gist list falló:\n" .. table.concat(list, "\n"), vim.log.levels.ERROR)
		return
	end
	if #list == 0 then
		vim.notify("No tienes gists.", vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, line in ipairs(list) do
		local f = vim.split(line, "\t", { plain = true })
		if f[1] then
			table.insert(items, {
				id = f[1],
				label = string.format("%s  [%s]", (f[2] ~= "" and f[2] or "(sin descripción)"), f[4] or "?"),
			})
		end
	end

	vim.ui.select(items, {
		prompt = prompt,
		format_item = function(it)
			return it.label
		end,
	}, function(choice)
		if choice then
			on_choice(choice)
		end
	end)
end

-- Elige un archivo del gist y llama a on_file(filename); si solo hay uno, lo usa directo.
local function pick_gist_file(id, prompt, on_file)
	local files = {}
	for _, name in ipairs(vim.fn.systemlist({ "gh", "gist", "view", id, "--files" })) do
		if name ~= "" then
			table.insert(files, name)
		end
	end
	if #files == 0 then
		vim.notify("El gist no tiene archivos.", vim.log.levels.WARN)
		return
	end
	if #files == 1 then
		on_file(files[1])
	else
		vim.ui.select(files, { prompt = prompt }, function(name)
			if name then
				on_file(name)
			end
		end)
	end
end

-- <leader>gp — pega el contenido de un archivo de un gist en el cursor
vim.keymap.set("n", "<leader>gp", function()
	pick_gist("Pegar gist:", function(choice)
		pick_gist_file(choice.id, "Archivo a pegar:", function(filename)
			-- --filename devuelve solo el contenido del archivo (sin la descripción)
			local content = vim.fn.systemlist({ "gh", "gist", "view", choice.id, "--filename", filename, "--raw" })
			if vim.v.shell_error ~= 0 then
				vim.notify("gh gist view falló:\n" .. table.concat(content, "\n"), vim.log.levels.ERROR)
				return
			end
			local row = vim.api.nvim_win_get_cursor(0)[1]
			vim.api.nvim_buf_set_lines(0, row, row, false, content)
		end)
	end)
end, { desc = "Gist: pegar contenido en el cursor" })

-- <leader>gu — actualiza un archivo de un gist con el contenido del buffer actual
vim.keymap.set("n", "<leader>gu", function()
	pick_gist("Actualizar gist con el buffer actual:", function(choice)
		pick_gist_file(choice.id, "Archivo a sobrescribir:", function(filename)
			local ok = vim.fn.confirm(
				string.format("¿Sobrescribir '%s' del gist con el buffer actual?", filename),
				"&Sí\n&No",
				2
			)
			if ok ~= 1 then
				return
			end
			local tmp = vim.fn.tempname()
			vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), tmp)
			local out = vim.fn.systemlist({ "gh", "gist", "edit", choice.id, "--filename", filename, tmp })
			vim.fn.delete(tmp)
			if vim.v.shell_error ~= 0 then
				vim.notify("gh gist edit falló:\n" .. table.concat(out, "\n"), vim.log.levels.ERROR)
				return
			end
			vim.notify(string.format("Gist actualizado: %s", filename), vim.log.levels.INFO)
		end)
	end)
end, { desc = "Gist: actualizar con el buffer actual" })

--split management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
-- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
-- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
-- close current split window
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

vim.keymap.set("n", "<leader>ni", function()
	vim.cmd("edit ~/notes/index.norg")
end, { desc = "Go to Neorg index" })

-- ===== `q` quits empty buffers =====
-- Pressing `q` in normal mode on a fresh empty file buffer closes the window
-- (no more `:q!`). Otherwise `q` keeps its default behavior (start macro
-- recording). The mapping is toggled buffer-locally via autocmd so it only
-- exists while the buffer is actually empty and unmodified.
local quit_empty_group = vim.api.nvim_create_augroup("IllicoQuitEmptyBuffer", { clear = true })

local function update_q_for_empty_buffer()
	-- Only regular file buffers — leave terminal/quickfix/help/picker buffers
	-- with their own `q` semantics intact.
	if vim.bo.buftype ~= "" then
		return
	end
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local is_empty = (#lines == 0) or (#lines == 1 and lines[1] == "")
	if is_empty and not vim.bo.modified then
		vim.keymap.set("n", "q", "<cmd>q!<cr>", {
			buffer = 0,
			silent = true,
			desc = "Quit empty buffer",
		})
	else
		pcall(vim.keymap.del, "n", "q", { buffer = 0 })
	end
end

vim.api.nvim_create_autocmd(
	{ "BufEnter", "TextChanged", "TextChangedI", "BufModifiedSet" },
	{ group = quit_empty_group, callback = update_q_for_empty_buffer }
)
