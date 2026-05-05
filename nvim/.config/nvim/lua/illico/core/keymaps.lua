local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keep cursor centered while jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

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
