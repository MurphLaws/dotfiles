-- Copilot con ghost text nativo (sin copilot-cmp: eso era para nvim-cmp).
-- <M-l> acepta la sugerencia; <M-]>/<M-[> ciclan.
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		suggestion = { enabled = true, auto_trigger = true },
		panel = { enabled = false },
	},
}
