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
					-- Solo recortar en buffers normales y modificables.
					-- Evita E21 en buffers especiales (checkhealth, terminal, etc.).
					if vim.bo.modifiable and vim.bo.buftype == "" then
						trailspace.trim()
					end
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

	-- ─────────────────────────────
	-- Mini Animate (smooth scroll + cursor / resize / float animations)
	-- ─────────────────────────────
	{
		"echasnovski/mini.animate",
		version = "*",
		event = "VeryLazy",
		config = function()
			local animate = require("mini.animate")

			-- Quick, linear timings keep things smooth without feeling sluggish.
			local function timing(ms)
				return animate.gen_timing.linear({ duration = ms, unit = "total" })
			end

			animate.setup({
				cursor = { timing = timing(80) }, -- cursor glide between positions
				scroll = { timing = timing(120) }, -- smooth scrolling (<C-d>/<C-u>/zz/n/N…)
				resize = { timing = timing(80) }, -- animated window resize
				open = { timing = timing(120) }, -- float window open
				close = { timing = timing(120) }, -- float window close
			})
		end,
	},
}
