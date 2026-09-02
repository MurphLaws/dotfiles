-- ============================================================================
-- claudecode.nvim — integra Neovim con el CLI de Claude Code vía WebSocket
-- (mismo protocolo que la extensión oficial de VS Code). Requiere el CLI
-- `claude` instalado por separado; este plugin no habla con la API directo.
-- ============================================================================

return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	cmd = {
		"ClaudeCode",
		"ClaudeCodeFocus",
		"ClaudeCodeSelectModel",
		"ClaudeCodeAdd",
		"ClaudeCodeSend",
		"ClaudeCodeTreeAdd",
		"ClaudeCodeStatus",
		"ClaudeCodeStart",
		"ClaudeCodeStop",
		"ClaudeCodeOpen",
		"ClaudeCodeClose",
		"ClaudeCodeDiffAccept",
		"ClaudeCodeDiffDeny",
		"ClaudeCodeCloseAllDiffs",
	},
	config = true,
	keys = {
		{ "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Claude Code: abrir/cerrar terminal" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<CR>", desc = "Claude Code: enfocar" },
		{ "<leader>ar", "<cmd>ClaudeCodeStart resume<CR>", desc = "Claude Code: reanudar sesión" },
		{ "<leader>aC", "<cmd>ClaudeCodeStart continue<CR>", desc = "Claude Code: continuar sesión" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", desc = "Claude Code: elegir modelo" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "Claude Code: agregar buffer actual" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Claude Code: enviar selección" },
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Claude Code: aceptar diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Claude Code: rechazar diff" },
	},
}
