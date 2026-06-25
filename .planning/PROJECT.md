# Dotfiles — Ajustes gráficos de Neovim

## What This Is

Milestone de pulido visual sobre la configuración de Neovim dentro de este repo de dotfiles (stow, macOS, Catppuccin Mocha sobre Ghostty + tmux transparentes). Cubre tres cambios concretos: hacer los menús/flotantes semitransparentes, integrar el plugin `tunnelvision.nvim` con un toggle propio, y verificar que la cadena de `real-icons.nvim` renderiza iconos reales como el plugin pretende.

## Core Value

La config de Neovim se ve y se comporta como el usuario quiere: menús con un panel naturalmente más oscuro (no 100% opaco), sin romper la transparencia del editor ni la estética sin bordes ya establecida.

## Requirements

### Validated

<!-- Inferidas del codebase existente (.planning/codebase/). Funcionan hoy. -->

- ✓ Neovim con Catppuccin Mocha y `transparent_background = true` (editor 100% transparente) — existing
- ✓ Menús/flotantes sin borde y sin esquinas redondeadas, con fondo de panel `#181825` (mantle) — existing
- ✓ `real-icons.nvim` instalado (pack `material`, backend `ghostty`, fallback a glyphs) — existing
- ✓ Cadena gráfica Ghostty → tmux (`allow-passthrough on`) → nvim para protocolo de imágenes — existing
- ✓ Despliegue stow por paquete; toda edición se hace en el repo, no en `~/.config` — existing
- ✓ Menús/flotantes **semitransparentes** (`winblend`/`pumblend = 10` global + `picker.win.*.wo.winblend` en snacks), panel naturalmente más oscuro, sin borde — v1.0 (FLOAT-01)
- ✓ `tunnelvision.nvim` instalado con toggle `<leader>tv` (lazy, opt-in, no interfiere) — v1.0 (TUNNEL-01)
- ✓ Cadena de `real-icons.nvim` verificada de punta a punta (magick, passthrough, pack `material` renderizado, fallback) — v1.0 (ICONS-01)
- ✓ Indicador de tmux "Claude done" con glifo campana  (U+F0F3) rojo, disparando en `Stop` + `Notification`; hook y `settings.json` versionados en el repo (symlinks) — v1.0 (NOTIFY-01/02)

### Active

<!-- Scope del próximo milestone. Vacío por ahora. -->

(Ninguno — milestone v1.0 enviado. Usa `/gsd:new-milestone` para el siguiente.)

### Out of Scope

<!-- Límites explícitos. -->

- Evaluación visual por pantallazos — el usuario la descartó; la corrección se verifica a nivel de código y el usuario reporta si algo no se ve bien
- Cambiar la estética de bordes de los menús — el usuario explícitamente quiere mantener sin borde / sin esquinas redondeadas
- Tocar la transparencia del editor (`Normal`) — debe seguir 100% transparente
- Cambios en ghostty/taskwarrior y demás herramientas del repo — fuera del milestone (el milestone sí toca nvim, tmux y el hook de claude para el indicador "Claude terminó")

## Context

- Repo de dotfiles personal, stow-based, macOS (Apple Silicon), Catppuccin Mocha en nvim/tmux/ghostty.
- La config de flotantes vive en `nvim/.config/nvim/lua/illico/plugins/colorscheme.lua`: define `float_bg = "#181825"` aplicado como fondo sólido en `float_groups`, bordes invisibles en `border_groups`, y reaplica la transparencia en el evento `ColorScheme` (necesario para no romper el caché de transparencia de snacks.nvim).
- `real-icons.nvim` se configura en `nvim/.config/nvim/lua/illico/plugins/real-icons.lua` con `build = ":RealIconsInstallPack material"`, `mini_files = false` (se desactivó porque congelaba `<leader>e`).
- Ghostty corre con `background-opacity = 0.95`; la transparencia de los flotantes se compone con esa opacidad del terminal.
- Prefijos de keymaps `<leader>t*` ocupados: `tb`, `ths`, `tw`, `tz` → `<leader>tv` queda libre.
- Indicador "Claude terminó" en tmux: el hook `Stop` `~/.claude/hooks/tmux-claude-done.sh` pone `@claude_done 1` en la ventana (solo si no es la activa); `window-status-format`/`window-status-current-format` en `tmux/.tmux.conf` (líneas ~134/137) pintan el glifo rojo ``; `after-select-window` lo borra. El hook NO está trackeado en el repo (vive en `~/.claude/hooks/`). Sospecha de fallo con GSD: dependencia del `Stop` del agente principal frente a eventos `SubagentStop`.
- Política de cierre: commit de todo y clean tree. Sin líneas Co-Authored-By (el usuario es único autor).

## Constraints

- **Estética**: Menús sin borde y sin esquinas redondeadas — invariante, no se toca.
- **Transparencia**: El editor (`Normal`/`NormalNC`/`SignColumn`) sigue 100% transparente; solo cambian los flotantes.
- **No-interferencia**: El toggle de tunnelvision (`<leader>tv`) no debe pisar keymaps existentes ni alterar otros plugins.
- **Tech stack**: Lua + lazy.nvim; editar en el repo (stow), nunca en `~/.config` directo.
- **Cierre**: commit de todos los cambios + clean tree al finalizar.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flotantes semitransparentes vía `winblend`/`pumblend` (=10) + `wo.winblend` en snacks picker | Global no llega al picker de snacks (lo detectó el plan-checker); se setea por ventana | ✓ Good — v1.0 |
| Toggle de tunnelvision en `<leader>tv` (comando `:TunnelVision toggle`, lazy) | Libre y mnemónico; comando documentado robusto; opt-in no interfiere | ✓ Good — v1.0 |
| Descartar evaluación visual por pantallazos | El usuario la retiró; verificación a nivel de código + reporte manual | ✓ Good — v1.0 |
| Indicador con glifo campana  (U+F0F3) + evento `Notification` además de `Stop` | Campana preferida; `Notification` cubre "necesita acknowledgement" durante GSD (antes solo `Stop`) | ✓ Good — v1.0 |
| Versionar hook `tmux-claude-done.sh` + `settings.json` en el repo (symlinks desde ~/.claude) | El usuario pidió versionar el fix; settings.json sin secretos | ✓ Good — v1.0 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-25 after v1.0 milestone (Ajustes gráficos de Neovim)*
