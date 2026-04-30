-- Jupyter notebook editing inside Neovim:
-- molten-nvim runs cells (kernel via pynvim), image.nvim renders plots inline,
-- quarto-nvim wires LSP/runner over markdown code-blocks, jupytext.nvim
-- transparently converts .ipynb <-> markdown on read/write.
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "ipynb", "quarto", "markdown" },
    init = function()
      -- Output goes to a floating window automatically; cell buffer stays clean.
      -- Images (matplotlib, etc.) render INSIDE that floating window — no overlap.
      vim.g.molten_image_provider        = "image.nvim"
      vim.g.molten_auto_open_output      = true   -- popup window appears on cell run
      vim.g.molten_wrap_output           = true
      vim.g.molten_virt_text_output      = false  -- no virt-text overlay (avoids conflicts)
      vim.g.molten_virt_lines_off_by_1   = false
      vim.g.molten_output_win_max_height = 30
      vim.g.molten_output_show_more      = true
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_use_border_highlights = true
      vim.g.molten_tick_rate             = 200
      vim.g.molten_split_direction       = "right"
      vim.g.molten_split_size            = 40
    end,
  },

  {
    "3rd/image.nvim",
    -- Note: NO `processor` set explicitly — let image.nvim pick a stable default
    -- (avoids the magick_cli race conditions that were producing stack traces).
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = false },  -- disable embedded markdown image rendering
                                         -- (conflicts with molten's image flow)
      },
      max_width                       = 200,
      max_height                      = 30,
      max_height_window_percentage    = 80,
      max_width_window_percentage     = 90,
      window_overlap_clear_enabled    = true,
      window_overlap_clear_ft_ignore  = { "cmp_menu", "cmp_docs", "" },
    },
  },

  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages   = { "python" },
        chunks      = "all",
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion  = { enabled = true },
      },
      codeRunner = {
        enabled        = true,
        default_method = "molten",
      },
    },
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style            = "markdown",
      output_extension = "md",
      force_ft         = "markdown",
    },
  },

  { "jmbuhr/otter.nvim", lazy = true },
}
