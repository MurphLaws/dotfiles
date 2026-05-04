return {
  dir = vim.fn.stdpath("config") .. "/local-plugins/taskwarrior-notes",
  name = "taskwarrior-notes",
  cmd = { "TaskNotes" },
  keys = {
    { "<leader>tw", "<cmd>TaskNotes<cr>", desc = "Taskwarrior task notes" },
  },
  config = function()
    require("taskwarrior-notes").setup()
  end,
}
