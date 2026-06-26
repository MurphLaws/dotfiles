return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		local eslint = lint.linters.eslint_d

		-- gdlint: silencia el warning de max-line-length (filtra ese diagnostico)
		local gdlint = lint.linters.gdlint
		local gdlint_parse = gdlint.parser
		gdlint.parser = function(output, bufnr, ...)
			local diagnostics = gdlint_parse(output, bufnr, ...)
			return vim.tbl_filter(function(d)
				return not (d.message and d.message:match("max%-line%-length"))
			end, diagnostics)
		end

		-- Filetype → Linter mapping
		lint.linters_by_ft = {
			javascript = { "biomejs" },
			typescript = { "biomejs" },
			javascriptreact = { "biomejs" },
			typescriptreact = { "biomejs" },
			svelte = { "biomejs" },
			python = { "pylint" },
			lua = { "luacheck" },
			yaml = { "yamllint" },
			gdscript = { "gdlint" },
		}

		-- ESLint config
		eslint.args = {
			"--no-warn-ignored",
			"--format",
			"json",
			"--stdin",
			"--stdin-filename",
			function()
				return vim.fn.expand("%:p")
			end,
		}

		-- Run linter on file events
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		-- Manual trigger
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
