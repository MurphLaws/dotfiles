-- Runner de Python en ventana flotante: <leader>rr guarda y ejecuta el archivo
-- actual con el python del env activo (VIRTUAL_ENV > CONDA_PREFIX > python3),
-- así los imports resuelven igual que en tu shell y los plots de matplotlib
-- abren su ventana nativa (el proceso sigue vivo mientras plt.show() bloquea).
-- Cada <leader>rr re-ejecuta desde cero; q o <esc> cierran el float.
local function python_bin()
	if vim.env.VIRTUAL_ENV then
		return vim.env.VIRTUAL_ENV .. "/bin/python"
	end
	if vim.env.CONDA_PREFIX then
		return vim.env.CONDA_PREFIX .. "/bin/python"
	end
	return "python3"
end

local state = { buf = nil, win = nil }

local function close_previous()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_delete(state.buf, { force = true })
	end
end

local function run_in_float(file)
	close_previous()
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.8)
	state.buf = vim.api.nvim_create_buf(false, true)
	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2) - 1,
		style = "minimal",
		border = "rounded",
		title = "  " .. vim.fn.fnamemodify(file, ":t") .. " ",
		title_pos = "center",
	})
	vim.fn.jobstart({ python_bin(), file }, {
		term = true,
		on_exit = function(_, code)
			-- retitula al terminar para saber cómo salió sin cerrar el float
			vim.schedule(function()
				if state.win and vim.api.nvim_win_is_valid(state.win) then
					local mark = code == 0 and "✓" or ("✗ exit " .. code)
					vim.api.nvim_win_set_config(state.win, {
						title = "  " .. vim.fn.fnamemodify(file, ":t") .. " [" .. mark .. "] ",
						title_pos = "center",
					})
				end
			end)
		end,
	})
	for _, key in ipairs({ "q", "<esc>" }) do
		vim.keymap.set("n", key, close_previous, { buffer = state.buf, nowait = true })
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	group = vim.api.nvim_create_augroup("PyRun", { clear = true }),
	callback = function(ev)
		vim.keymap.set("n", "<leader>rr", function()
			vim.cmd.write()
			run_in_float(vim.api.nvim_buf_get_name(ev.buf))
		end, { buffer = ev.buf, desc = "Run Python file (float)" })
	end,
})
