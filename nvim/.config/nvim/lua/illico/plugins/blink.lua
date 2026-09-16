-- blink.cmp: completado con defaults de fábrica (menú, docs, cmdline, snippets
-- vía friendly-snippets). Único extra: la fuente de orgmode, que el propio
-- plugin de orgmode provee.
return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = { "rafamadriz/friendly-snippets" },
	opts = {
		keymap = { preset = "super-tab" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = { org = { "orgmode", "buffer", "path" } },
			providers = {
				orgmode = {
					name = "Orgmode",
					module = "orgmode.org.autocompletion.blink",
					fallbacks = { "buffer" },
				},
			},
		},
	},
}
