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

		-- pylint: preferir el del env activo (conda/venv), que sí ve los
		-- paquetes del proyecto. Si el env no tiene pylint, cae al de Mason.
		local pylint = lint.linters.pylint
		pylint.cmd = function()
			local env = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
			local env_pylint = env and (env .. "/bin/pylint")
			if env_pylint and vim.fn.executable(env_pylint) == 1 then
				return env_pylint
			end
			return "pylint"
		end

		-- El pylint de Mason corre en su propio env y no ve los paquetes del
		-- proyecto, así que en ese fallback los "Unable to import" (E0401) son
		-- falsos positivos. Pyright (con pythonPath del env activo) ya valida
		-- imports de verdad; se filtra ese diagnóstico solo cuando corre el de
		-- Mason.
		local pylint_parse = pylint.parser
		pylint.parser = function(output, bufnr, ...)
			local diagnostics = pylint_parse(output, bufnr, ...)
			if pylint.cmd() ~= "pylint" then
				return diagnostics -- pylint del env: sus import-error son reales
			end
			return vim.tbl_filter(function(d)
				return not (d.code == "E0401" or (d.message and d.message:match("^Unable to import")))
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
