-- real-icons.nvim — iconos-imagen reales (protocolo gráfico de Ghostty) en
-- lugar de glyphs de Nerd Font. Cae a glyphs automáticamente si la imagen no
-- se puede dibujar.
--
-- Requisitos (ya cubiertos en este equipo):
--   • Ghostty + termguicolors
--   • magick (ImageMagick) para packs SVG  → /opt/homebrew/bin/magick
--   • En tmux: `set -g allow-passthrough on` → ya activo en ~/.tmux.conf
--
-- Carga en VeryLazy para que snacks y mini.files ya estén inicializados cuando
-- real-icons parchee sus integraciones.
return {
	{
		"Mirsmog/real-icons.nvim",
		build = ":RealIconsInstallPack material",
		event = "VeryLazy",
		opts = {
			pack = "material",
			backend = "ghostty",
			fallback = { enabled = true, provider = "auto" },
			integrations = {
				snacks_picker = true, -- el menú de búsqueda (Find Files / Grep)
				mini_files = true, -- explorador mini.files
				-- lualine = true,  -- descomenta si quieres iconos-imagen en la statusline
			},
		},
	},
}
