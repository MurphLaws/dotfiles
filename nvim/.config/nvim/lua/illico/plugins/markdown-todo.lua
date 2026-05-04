return {
  "thenbe/markdown-todo.nvim",
  ft = { "markdown", "md" },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "md" },
      callback = function(args)
        vim.keymap.set("n", "<leader>tt", function()
          local line = vim.api.nvim_get_current_line()
          if line:match("%(%s*[xX]%s*%)") then
            require("markdown-todo").make_todo("undone")
          else
            require("markdown-todo").make_todo("done")
          end
        end, { buffer = args.buf, desc = "Toggle markdown todo done/undone" })
      end,
    })
  end,
  config = function()
    require("markdown-todo").setup()
  end,
}
