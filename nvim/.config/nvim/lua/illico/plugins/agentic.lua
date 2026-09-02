-- ============================================================================
-- agentic.nvim — chat de IA dentro de Neovim vía ACP (Agent Client Protocol),
-- usando tu suscripción Claude (Max) a través de `claude-agent-acp`, no una
-- API key. A diferencia de avante/claudecode, el chat y el diff viven en
-- buffers reales de nvim (nada de terminal emulado).
--
-- Dependencia externa: el binario `claude-agent-acp` debe estar en el PATH.
--   npm install -g @agentclientprotocol/claude-agent-acp
-- (ya está instalado vía Homebrew/npm global en esta máquina: /opt/homebrew/bin)
--
-- Bugs conocidos de una instalación anterior (ver memoria de esta sesión):
-- - El diff preview con auth_type/permissions.defaultMode = "auto" en
--   ~/.claude/settings.json nunca dispara `session/request_permission`, así
--   que el preview de diff no aparece nunca (ni inline ni split). Si el diff
--   deja de mostrarse, revisa ese setting o cambia el modo con <S-Tab>.
-- - Cambiar diff_preview.layout requiere reiniciar Neovim, no solo recargar.
-- ============================================================================

return {
	"carlos-algms/agentic.nvim",
	opts = {
		provider = "claude-agent-acp",
		diff_preview = {
			enabled = true,
			layout = "inline",
			center_on_navigate_hunks = true,
		},
	},
	keys = {
		{
			"<leader>at",
			function()
				require("agentic").toggle()
			end,
			mode = { "n", "v" },
			desc = "Agentic: abrir/cerrar chat",
		},
		{
			"<leader>an",
			function()
				require("agentic").new_session()
			end,
			desc = "Agentic: nueva sesión",
		},
		{
			"<leader>aA",
			function()
				require("agentic").add_selection_or_file_to_context()
			end,
			mode = { "n", "v" },
			desc = "Agentic: agregar archivo/selección al contexto",
		},
	},
}
