---
phase: 03-real-icons-verification
plan: 01
requirements:
  - ICONS-01
status: complete
code_change: none
---

# Phase 3 Summary — Real-icons Verification

**Outcome:** La cadena de `real-icons.nvim` está completa y funcional de extremo a extremo. No se requirió ningún cambio de código (auditoría limpia).

## Self-Check: PASSED

## Evidence (chain links verified)

| Link | Check | Result |
|------|-------|--------|
| ImageMagick | `/opt/homebrew/bin/magick -version` | ✓ ImageMagick 7.1.2-21 Q16-HDRI aarch64 |
| tmux passthrough | `grep allow-passthrough tmux/.tmux.conf` | ✓ `set -g allow-passthrough on` (línea 18) |
| Plugin instalado | `~/.local/share/nvim/lazy/real-icons.nvim/` | ✓ assets, lua, media, doc, LICENSE |
| Pack `material` instalado | `~/.cache/nvim/real-icons/packs/material/` | ✓ 13 PNGs raw (p. ej. `material__lua.png`, `material__git.png`) |
| Pack renderizado (dist) | `~/.local/share/nvim/real-icons/packs/material/dist` | ✓ presente (build `:RealIconsInstallPack material` corrió OK) |
| Spec correcto | `real-icons.lua` | ✓ `pack=material`, `backend=ghostty`, `fallback={enabled=true,provider=auto}`, `snacks_picker=true`, `mini_files=false` |
| Render real | screenshot del usuario (snacks picker) | ✓ iconos `material__*.png` visibles en los `.lua` |

## Notes

- `backend=ghostty` usa el protocolo gráfico de Ghostty que atraviesa tmux gracias a `allow-passthrough on` (TERM=screen-256color dentro de tmux es esperado; la imagen llega vía passthrough).
- `mini_files=false` es intencional (con preview=true en mini.files real-icons congelaba `<leader>e`); el explorador usa glyphs de mini.icons. Documentado en el spec.
- Fallback a glyphs habilitado (`provider=auto`) para entornos sin protocolo gráfico.

No code changed in this phase — verification only.
