return {
	{
		"filipjanevski/0x96f.nvim",
		priority = 1000,
		config = function()
			require("0x96f").setup()
			vim.cmd.colorscheme("0x96f")

			-- 🟢 FORCE TRANSPARENCY & FIX BORDERS
			-- Global elements
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
			vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
			vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })

			-- Fix Telescope Borders
			vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })

			-- Fix WhichKey Borders
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none" })

			-- 🟢 Fix Snacks Picker Transparency (New addition)
			-- Esto asegura que los menús de Snacks se vean iguales a Telescope
			vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none" })
			vim.api.nvim_set_hl(0, "SnacksPickerNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "none" })
			vim.api.nvim_set_hl(0, "SnacksPickerTitle", { bg = "none" })
			vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { bg = "none" })
			vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "none" })
			vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "none" })
		end,
	},
}
