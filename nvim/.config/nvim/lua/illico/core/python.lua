-- Neovim Python provider — independent of any project conda env.
-- Lives in `nvim-py` (pynvim), so reinstalling project envs (lacardio, etc.)
-- never breaks Neovim.
local nvim_py_bin = "/opt/miniconda3/envs/nvim-py/bin"

vim.g.python3_host_prog = nvim_py_bin .. "/python"

-- Add nvim-py/bin to PATH so Python-backed tooling resolves without depending
-- on the user's interactive shell PATH.
if not vim.env.PATH:find(nvim_py_bin, 1, true) then
  vim.env.PATH = nvim_py_bin .. ":" .. vim.env.PATH
end
