return {
	{
		"thePrimeagen/harpoon",
		enabled = true,
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup({
				global_settings = {
					save_on_toggle = true,
					save_on_change = true,
				},
			})

			harpoon:extend({
				UI_CREATE = function(cx)
					vim.keymap.set("n", "q", function()
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end, { buffer = cx.bufnr, desc = "Close harpoon menu" })
				end,
			})

			-- Harpoon Nav Interface
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon add file" })

			vim.keymap.set("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon quick menu" })

			-- Harpoon marked files
			vim.keymap.set("n", "<C-y>", function()
				harpoon:list():select(1)
			end)
			vim.keymap.set("n", "<C-i>", function()
				harpoon:list():select(2)
			end)
			vim.keymap.set("n", "<C-n>", function()
				harpoon:list():select(3)
			end)
			vim.keymap.set("n", "<C-s>", function()
				harpoon:list():select(4)
			end)

			-- Toggle previous & next buffers stored within Harpoon list
			vim.keymap.set("n", "<C-S-P>", function()
				harpoon:list():prev({ ui_nav_wrap = true })
			end)
			vim.keymap.set("n", "<C-S-N>", function()
				harpoon:list():next({ ui_nav_wrap = true })
			end)
			vim.keymap.set("n", "<C-a>n", function()
				harpoon:list():next({ ui_nav_wrap = true })
			end, { desc = "Harpoon cycle next" })

			for i = 1, 9 do
				vim.keymap.set("n", "<C-a>" .. i, function()
					harpoon:list():select(i)
				end, { desc = "Harpoon select " .. i })
			end

			vim.keymap.set("n", "<C-f>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon quick menu" })
		end,
	},
	{
		"kiennt63/harpoon-files.nvim",
		dependencies = {
			{ "ThePrimeagen/harpoon", branch = "harpoon2" },
		},
		opts = {},
	},
}
