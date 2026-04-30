-- Autocmds for .ipynb editing with molten + jupytext.
--   * On open: try to MoltenInit using the kernel from the notebook's metadata
--     (or current $CONDA_PREFIX), then import any saved outputs.
--   * On save: re-export molten outputs back into the .ipynb.

local imb = function(e)
  vim.schedule(function()
    local ok_kern, kernels = pcall(vim.fn.MoltenAvailableKernels)
    if not ok_kern or not kernels then return end

    local try_kernel_name = function()
      local f = io.open(e.file, "r")
      if not f then return nil end
      local content = f:read("a")
      f:close()
      local meta = vim.json.decode(content).metadata
      return meta and meta.kernelspec and meta.kernelspec.name or nil
    end

    local ok, kernel_name = pcall(try_kernel_name)
    if not ok or not kernel_name or not vim.tbl_contains(kernels, kernel_name) then
      kernel_name = nil
      local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
      if venv then kernel_name = string.match(venv, "/.+/(.+)") end
    end

    if kernel_name and vim.tbl_contains(kernels, kernel_name) then
      vim.cmd(("MoltenInit %s"):format(kernel_name))
    end
    pcall(vim.cmd, "MoltenImportOutput")
  end)
end

vim.api.nvim_create_autocmd("BufAdd", {
  pattern = { "*.ipynb" },
  callback = imb,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ipynb" },
  callback = function(e)
    if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then imb(e) end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.ipynb" },
  callback = function()
    local ok, status = pcall(require, "molten.status")
    if ok and status.initialized() == "Molten" then
      vim.cmd("MoltenExportOutput!")
    end
  end,
})
