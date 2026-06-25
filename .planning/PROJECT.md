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

### Active

<!-- Scope de este milestone. Hipótesis hasta validarse. -->

- [ ] Los menús/flotantes son **semitransparentes** (menos transparentes que el editor) en lugar de 100% opacos, resultando en un panel naturalmente más oscuro — conservando sin borde y sin esquinas redondeadas
- [ ] `tunnelvision.nvim` (leolaurindo) instalado y funcional, con toggle en `<leader>tv` que no interfiere con otros keymaps
- [ ] La cadena de `real-icons.nvim` (Mirsmog) está verificada de extremo a extremo a nivel de código/config: plugin presente, pack `material` instalable, `magick` disponible, `allow-passthrough` activo, fallback correcto
- [ ] Todos los cambios commiteados y árbol de git limpio al terminar

### Out of Scope

<!-- Límites explícitos. -->

- Evaluación visual por pantallazos — el usuario la descartó; la corrección se verifica a nivel de código y el usuario reporta si algo no se ve bien
- Cambiar la estética de bordes de los menús — el usuario explícitamente quiere mantener sin borde / sin esquinas redondeadas
- Tocar la transparencia del editor (`Normal`) — debe seguir 100% transparente
- Cambios en otras herramientas del repo (tmux, ghostty, taskwarrior, claude) salvo que la verificación de real-icons exija ajustar la cadena de passthrough

## Context

- Repo de dotfiles personal, stow-based, macOS (Apple Silicon), Catppuccin Mocha en nvim/tmux/ghostty.
- La config de flotantes vive en `nvim/.config/nvim/lua/illico/plugins/colorscheme.lua`: define `float_bg = "#181825"` aplicado como fondo sólido en `float_groups`, bordes invisibles en `border_groups`, y reaplica la transparencia en el evento `ColorScheme` (necesario para no romper el caché de transparencia de snacks.nvim).
- `real-icons.nvim` se configura en `nvim/.config/nvim/lua/illico/plugins/real-icons.lua` con `build = ":RealIconsInstallPack material"`, `mini_files = false` (se desactivó porque congelaba `<leader>e`).
- Ghostty corre con `background-opacity = 0.95`; la transparencia de los flotantes se compone con esa opacidad del terminal.
- Prefijos de keymaps `<leader>t*` ocupados: `tb`, `ths`, `tw`, `tz` → `<leader>tv` queda libre.
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
| Flotantes semitransparentes en vez de opacos | El usuario prefiere un panel naturalmente más oscuro, menos transparente que el editor | — Pending |
| Toggle de tunnelvision en `<leader>tv` | Libre y mnemónico; no colisiona con `tb/ths/tw/tz` | — Pending |
| Descartar evaluación visual por pantallazos | El usuario la retiró; verificación a nivel de código + reporte manual | — Pending |

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
*Last updated: 2026-06-25 after initialization*
