-- ============================================================================
-- Gemini CLI helpers (OAuth Pro path — no API key, no Pro free-tier limit:0)
-- Shells out to `gemini -p ...` and shows the response in a right-side split.
-- ============================================================================

local PANEL_FILETYPE = "gemini-output"

-- Persistent panel state across calls (module-level)
local panel = { buf = nil, win = nil }

-- Active gemini model (toggle with <leader>iM)
local current_model = "gemini-2.5-flash"
local function toggle_model()
	current_model = current_model == "gemini-2.5-flash" and "gemini-2.5-pro" or "gemini-2.5-flash"
	vim.notify("Gemini model → " .. current_model, vim.log.levels.INFO)
	if panel.win and vim.api.nvim_win_is_valid(panel.win) then
		vim.wo[panel.win].winbar = "  Gemini ["
			.. current_model
			.. "]    [q close · Y yank · R replace · J/K scroll]"
	end
end

local function strip_ansi(s)
	if not s then
		return ""
	end
	-- ESC[…m and ESC]…BEL/ST sequences
	return (s:gsub("\27%[[%d;]*[A-Za-z]", ""):gsub("\27%][^\7\27]*[\7\27]?", ""))
end

local function get_visual_selection()
	local s = vim.fn.getpos("'<")
	local e = vim.fn.getpos("'>")
	local mode = vim.fn.visualmode()
	if mode == "" then
		mode = "v"
	end
	local ok, lines = pcall(vim.fn.getregion, s, e, { type = mode })
	if not ok or not lines or #lines == 0 then
		return "", s, e
	end
	return table.concat(lines, "\n"), s, e
end

local function panel_alive()
	return panel.buf
		and vim.api.nvim_buf_is_valid(panel.buf)
		and panel.win
		and vim.api.nvim_win_is_valid(panel.win)
end

local function ensure_panel(title)
	if panel.buf and not vim.api.nvim_buf_is_valid(panel.buf) then
		panel.buf = nil
	end
	if panel.win and not vim.api.nvim_win_is_valid(panel.win) then
		panel.win = nil
	end

	if not panel.buf then
		panel.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[panel.buf].filetype = PANEL_FILETYPE
		vim.bo[panel.buf].bufhidden = "hide"
		vim.bo[panel.buf].buftype = "nofile"
		vim.bo[panel.buf].swapfile = false
		pcall(vim.api.nvim_buf_set_name, panel.buf, "[Gemini]")
	end

	if not panel.win then
		local prev_win = vim.api.nvim_get_current_win()
		vim.cmd("botright vsplit")
		panel.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(panel.win, panel.buf)
		vim.api.nvim_win_set_width(panel.win, math.min(80, math.max(60, math.floor(vim.o.columns * 0.4))))
		vim.wo[panel.win].wrap = true
		vim.wo[panel.win].linebreak = true
		vim.wo[panel.win].number = false
		vim.wo[panel.win].relativenumber = false
		vim.wo[panel.win].signcolumn = "no"
		vim.wo[panel.win].foldcolumn = "0"
		vim.wo[panel.win].cursorline = false
		vim.wo[panel.win].winbar = "  "
			.. (title or "Gemini")
			.. " ["
			.. current_model
			.. "]    [q close · Y yank · R replace · J/K scroll]"
		-- focus stays on previous window — user keeps typing
		pcall(vim.api.nvim_set_current_win, prev_win)
	else
		-- panel already open — just refresh the winbar title
		vim.wo[panel.win].winbar = "  "
			.. (title or "Gemini")
			.. " ["
			.. current_model
			.. "]    [q close · Y yank · R replace · J/K scroll]"
	end

	-- (re)apply panel keymaps (idempotent)
	local kopts = { buffer = panel.buf, nowait = true }
	vim.keymap.set("n", "q", function()
		if panel.win and vim.api.nvim_win_is_valid(panel.win) then
			vim.api.nvim_win_close(panel.win, true)
		end
		panel.win = nil
	end, vim.tbl_extend("force", kopts, { desc = "Close Gemini panel" }))
end

local function set_panel_content(text)
	ensure_panel()
	local lines = vim.split(text or "", "\n", { plain = true })
	vim.bo[panel.buf].modifiable = true
	vim.api.nvim_buf_set_lines(panel.buf, 0, -1, false, lines)
	vim.bo[panel.buf].modifiable = false
	-- scroll panel to top
	if panel_alive() then
		pcall(vim.api.nvim_win_set_cursor, panel.win, { 1, 0 })
	end
end

local function gemini_call(prompt, title, opts)
	opts = opts or {}
	ensure_panel(title)
	set_panel_content("⏳ Thinking…\n\nPrompt:\n" .. prompt)

	-- panel-scoped keymaps that depend on the latest call's context
	local kopts = { buffer = panel.buf, nowait = true }
	vim.keymap.set("n", "Y", function()
		local text = table.concat(vim.api.nvim_buf_get_lines(panel.buf, 0, -1, false), "\n")
		vim.fn.setreg("+", text)
		vim.fn.setreg('"', text)
		vim.notify("Copied to clipboard", vim.log.levels.INFO)
	end, vim.tbl_extend("force", kopts, { desc = "Yank Gemini response" }))

	if opts.replace_target then
		local target = opts.replace_target
		vim.keymap.set("n", "R", function()
			if not vim.api.nvim_buf_is_valid(target.buf) then
				vim.notify("Origin buffer no longer valid", vim.log.levels.WARN)
				return
			end
			local text = table.concat(vim.api.nvim_buf_get_lines(panel.buf, 0, -1, false), "\n")
			vim.api.nvim_buf_set_text(
				target.buf,
				target.s[2] - 1,
				target.s[3] - 1,
				target.e[2] - 1,
				target.e[3],
				vim.split(text, "\n", { plain = true })
			)
			vim.notify("Replaced selection", vim.log.levels.INFO)
		end, vim.tbl_extend("force", kopts, { desc = "Replace original selection" }))
	else
		pcall(vim.keymap.del, "n", "R", { buffer = panel.buf })
	end

	vim.system(
		{ "gemini", "--skip-trust", "-m", current_model, "-p", prompt, "-o", "text" },
		{
			text = true,
			env = vim.tbl_extend("force", vim.fn.environ(), {
				NO_COLOR = "1",
				TERM = "dumb",
				GEMINI_CLI_TRUST_WORKSPACE = "true",
			}),
		},
		function(res)
			vim.schedule(function()
				if res.code ~= 0 then
					local err = strip_ansi((res.stderr and res.stderr ~= "") and res.stderr or "(no stderr)")
					set_panel_content("Gemini error (exit " .. tostring(res.code) .. "):\n\n" .. err)
					return
				end
				local out = vim.trim(strip_ansi(res.stdout or ""))
				if out == "" then
					out = "(empty response)"
				end
				set_panel_content(out)
			end)
		end
	)
end

local function ask_with_selection(template, title)
	local sel, s, e = get_visual_selection()
	if sel == "" then
		vim.notify("No visual selection", vim.log.levels.WARN)
		return
	end
	local ft = vim.bo.filetype
	local prompt = template .. "\n\n```" .. ft .. "\n" .. sel .. "\n```"
	gemini_call(prompt, title, {
		replace_target = { buf = vim.api.nvim_get_current_buf(), s = s, e = e },
	})
end

local function ask_quick()
	local p = vim.fn.input("Ask Gemini: ")
	if p == "" then
		return
	end
	gemini_call(p, "Gemini")
end

local function ask_inline()
	local p = vim.fn.input("Gemini inline: ")
	if p == "" then
		return
	end
	gemini_call(p, "Gemini")
end

local function ask_commit_msg()
	local diff = vim.fn.system("git diff --cached")
	if vim.v.shell_error ~= 0 or diff == "" then
		vim.notify("No staged changes (run `git add` first)", vim.log.levels.WARN)
		return
	end
	local prompt = "Generate a concise conventional-commit message for the following diff. "
		.. "Output ONLY the commit message (subject + body if needed), no explanation, no markdown fences.\n\n"
		.. diff
	gemini_call(prompt, "Commit Message")
end

local function panel_scroll(direction)
	if not panel_alive() then
		vim.notify("Gemini panel not open", vim.log.levels.WARN)
		return
	end
	local key = direction == "down" and "<C-d>" or "<C-u>"
	vim.fn.win_execute(panel.win, "normal! " .. vim.api.nvim_replace_termcodes(key, true, true, true))
end

local function panel_jump(where)
	if not panel_alive() then
		return
	end
	vim.fn.win_execute(panel.win, "normal! " .. (where == "top" and "gg" or "G"))
end

local function toggle_panel()
	if panel_alive() then
		vim.api.nvim_win_close(panel.win, true)
		panel.win = nil
	else
		ensure_panel("Gemini")
	end
end

-- ============================================================================
-- CodeCompanion plugin spec
-- ============================================================================

return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionCmd",
	},
	-- runs at startup, before lazy-load triggers — so J/K override is live immediately
	init = function()
		-- Global J/K override: panel-aware scroll with fallback to user's 10jzz/10kzz
		vim.keymap.set("n", "K", function()
			if panel_alive() then
				panel_scroll("up")
			else
				vim.cmd("normal! 10kzz")
			end
		end, { desc = "Gemini scroll up / 10kzz fallback" })
		vim.keymap.set("n", "J", function()
			if panel_alive() then
				panel_scroll("down")
			else
				vim.cmd("normal! 10jzz")
			end
		end, { desc = "Gemini scroll down / 10jzz fallback" })

		-- LSP buffers: lspconfig sets buffer-local K=hover. Re-bind via vim.schedule so we run AFTER lspconfig's LspAttach handler.
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("GeminiPanelJKOverride", { clear = true }),
			callback = function(args)
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					vim.keymap.set("n", "K", function()
						if panel_alive() then
							panel_scroll("up")
						else
							vim.lsp.buf.hover()
						end
					end, { buffer = args.buf, desc = "Gemini scroll up / LSP hover fallback" })
					vim.keymap.set("n", "J", function()
						if panel_alive() then
							panel_scroll("down")
						else
							vim.cmd("normal! 10jzz")
						end
					end, { buffer = args.buf, desc = "Gemini scroll down / 10jzz fallback" })
				end)
			end,
		})
	end,
	keys = {
		-- Chat (multi-turn) — uses CodeCompanion's gemini_cli ACP adapter
		{ "<leader>ic", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat (toggle)" },
		{ "<leader>ia", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions palette" },
		{ "<leader>iA", "<cmd>CodeCompanionChat Add<cr>", mode = { "v" }, desc = "AI Add selection to chat" },

		-- Inline (one-shot) — uses gemini CLI directly, side panel
		{ "<leader>ip", toggle_panel, mode = "n", desc = "AI Toggle side panel" },
		{ "<leader>iM", toggle_model, mode = "n", desc = "AI Toggle model (flash ↔ pro)" },

		{
			"<leader>iG",
			function()
				panel_jump("bottom")
			end,
			mode = "n",
			desc = "AI Panel jump to bottom",
		},
		{
			"<leader>iH",
			function()
				panel_jump("top")
			end,
			mode = "n",
			desc = "AI Panel jump to top",
		},
		{ "<leader>iq", ask_quick, mode = "n", desc = "AI Quick question" },
		{ "<leader>ii", ask_inline, mode = "n", desc = "AI Inline prompt" },
		{
			"<leader>ie",
			function()
				ask_with_selection("Explain this code clearly and concisely:", "Explain")
			end,
			mode = "v",
			desc = "AI Explain selection",
		},
		{
			"<leader>if",
			function()
				ask_with_selection(
					"Fix bugs or issues in this code. Output only the corrected code, no explanations:",
					"Fix"
				)
			end,
			mode = "v",
			desc = "AI Fix selection (R in panel to replace)",
		},
		{
			"<leader>ir",
			function()
				ask_with_selection("Review this code for bugs, performance, and style issues:", "Review")
			end,
			mode = "v",
			desc = "AI Review selection",
		},
		{
			"<leader>it",
			function()
				ask_with_selection("Write thorough unit tests for this code:", "Tests")
			end,
			mode = "v",
			desc = "AI Generate tests",
		},
		{ "<leader>ig", ask_commit_msg, mode = "n", desc = "AI Generate commit message (from staged diff)" },
	},
	config = function()
		require("codecompanion").setup({
			adapters = {
				gemini = function()
					return require("codecompanion.adapters").extend("gemini", {
						env = {
							api_key = "cmd:echo $GEMINI_API_KEY",
						},
						schema = {
							model = {
								default = "gemini-2.5-flash",
							},
						},
					})
				end,
			},
			strategies = {
				chat = {
					adapter = "gemini_cli",
					keymaps = {
						send = { modes = { n = "<C-s>", i = "<C-s>" } },
						close = { modes = { n = "<C-c>", i = "<C-c>" } },
					},
				},
				inline = { adapter = "gemini" },
				cmd = { adapter = "gemini" },
			},
			display = {
				chat = {
					window = {
						layout = "vertical",
						width = 0.4,
					},
					show_settings = false,
					show_token_count = true,
				},
				diff = {
					enabled = true,
					provider = "default",
				},
			},
			opts = {
				log_level = "ERROR",
				language = "Spanish",
			},
		})

		local ok, wk = pcall(require, "which-key")
		if ok then
			wk.add({
				{ "<leader>i", group = "AI (Gemini)" },
			})
		end
	end,
}
