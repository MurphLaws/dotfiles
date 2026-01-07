
return {
  "nvim-telescope/telescope.nvim",
  branch = "master", -- using master to fix issues with deprecated to definition warnings
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "andrew-george/telescope-themes",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local themes = require("telescope.themes")

    telescope.load_extension("fzf")
    telescope.load_extension("themes")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
          },
        },
      },
      extensions = {
        themes = {
          enable_previewer = true,
          enable_live_preview = true,
          persist = {
            enabled = true,
            path = vim.fn.stdpath("config") .. "/lua/colorscheme.lua",
          },
        },
      },
    })

    -- 🔭 Telescope keymaps
    vim.keymap.set("n", "<leader>pr", "<cmd>Telescope oldfiles<CR>", { desc = "Fuzzy find recent files" })
    vim.keymap.set("n", "<leader>pWs", function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end, { desc = "Find connected words under cursor" })

    vim.keymap.set("n", "<leader>ths", "<cmd>Telescope themes<CR>", { desc = "Theme Switcher" })

    -- 🔍 Search only within the current buffer (Ivy layout, exact match)
    vim.keymap.set("n", "<leader>pb", function()
      builtin.current_buffer_fuzzy_find(themes.get_ivy({
        winblend = 10,
        previewer = false,
        fuzzy = false,                -- exact substring match only
        case_mode = "smart_case",     -- respects case if typed uppercase
        sorting_strategy = "ascending",
        layout_config = { height = 15 },
      }))
    end, { desc = "Search in current buffer (exact, ivy layout)" })
  end,
}
