-- Jupyter notebook editing inside Neovim:
-- image.nvim renders plots inline, quarto-nvim wires LSP over markdown
-- code-blocks, jupytext.nvim transparently converts .ipynb <-> markdown
-- on read/write.
return {
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = false },
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
    },
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    init = function()
      -- jupytext.nvim (sin mantenimiento, última versión abr-2024) todavía llama
      -- a la API pre-0.10 `vim.health.report_*`, que Neovim removió. Eso hace que
      -- `:checkhealth jupytext` falle. Restauramos los alias si faltan.
      local health = vim.health
      health.report_start = health.report_start or health.start
      health.report_ok = health.report_ok or health.ok
      health.report_warn = health.report_warn or health.warn
      health.report_error = health.report_error or health.error
      health.report_info = health.report_info or health.info
    end,
    opts = {
      style            = "markdown",
      output_extension = "md",
      force_ft         = "markdown",
    },
  },

  { "jmbuhr/otter.nvim", lazy = true },
}
