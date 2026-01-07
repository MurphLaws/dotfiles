return {

	-- ─────────────────────────────
	-- Mini Starter (Dashboard)
	-- ─────────────────────────────
	-- Mini Surround
	-- ─────────────────────────────
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "sa",
					delete = "sd",
					find = "sf",
					find_left = "sF",
					highlight = "sh",
					replace = "sr",
					update_n_lines = "sn",
				},
			})
		end,
	},

	-- ─────────────────────────────
	-- Mini Trailspace
	-- ─────────────────────────────
	{
		"echasnovski/mini.trailspace",
		version = "*",
		config = function()
			local trailspace = require("mini.trailspace")

			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function()
					trailspace.trim()
				end,
			})

			vim.api.nvim_create_user_command("Trim", function()
				trailspace.trim()
			end, { desc = "Trim trailing whitespace" })
		end,
	},

	-- ─────────────────────────────
	-- Mini SplitJoin
	-- ─────────────────────────────
	{
		"echasnovski/mini.splitjoin",
		version = "*",
		config = function()
			local sj = require("mini.splitjoin")
			sj.setup({ mappings = { toggle = "" } })

			vim.keymap.set({ "n", "x" }, "sj", sj.join, { desc = "Join arguments" })
			vim.keymap.set({ "n", "x" }, "sk", sj.split, { desc = "Split arguments" })
		end,
	},
}
