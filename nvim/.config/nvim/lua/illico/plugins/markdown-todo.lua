return {
  "thenbe/markdown-todo.nvim",
  ft = { "markdown", "md" },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "md" },
      callback = function(args)
        vim.keymap.set("n", "<leader>tt", function()
          require("illico.markdown_todo_hierarchy").cycle()
        end, { buffer = args.buf, desc = "Toggle markdown todo (with hierarchy)" })
      end,
    })
  end,
  config = function()
    require("markdown-todo").setup()
  end,
}
