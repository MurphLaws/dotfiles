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
			per_filetype = {
				org = { "orgmode", "buffer", "path" },
				-- En notas solo interesan links (LSP) y rutas; snippets/buffer
				-- meten fechas y palabras sueltas en el menú de [[.
				markdown = { "lsp", "path" },
			},
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
