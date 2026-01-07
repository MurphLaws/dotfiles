return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown", "norg" }, -- Activar también para Neorg
	build = function()
		-- Instala las dependencias del servidor automáticamente
		vim.fn["mkdp#util#install"]()
	end,
	init = function()
		-- Configuración global antes de cargar el plugin
		-- Truco: Engañar al plugin para que trate .norg como archivos soportados
		vim.g.mkdp_filetypes = { "markdown", "norg" }
		vim.g.mkdp_auto_close = 0 -- No cerrar el navegador al cambiar de buffer
	end,
	keys = {
		{
			"<leader>nb",
			"<cmd>MarkdownPreview<cr>",
			mode = "n",
			ft = "norg", -- Solo habilitar esta tecla en archivos norg
			desc = "Neorg: Vista previa en vivo (Browser)",
		},
		{
			"<leader>mp",
			"<cmd>MarkdownPreview<cr>",
			mode = "n",
			ft = "markdown",
			desc = "Markdown: Vista previa en vivo",
		},
	},
}
