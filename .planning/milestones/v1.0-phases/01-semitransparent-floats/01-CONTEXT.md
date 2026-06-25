# Phase 1: Semitransparent Floats - Context

**Gathered:** 2026-06-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Los menús y ventanas flotantes de Neovim (Pmenu/autocompletado, Telescope, snacks picker, which-key, NormalFloat, etc.) deben renderizar **semitransparentes** — menos transparentes que el editor (que es 100% transparente) — para producir un panel naturalmente más oscuro sobre el wallpaper/Ghostty, conservando la estética sin borde y sin esquinas redondeadas. NO se toca la transparencia del editor (`Normal`/`NormalNC`/`SignColumn` siguen 100% transparentes). Todo se edita en `nvim/.config/nvim/lua/illico/plugins/colorscheme.lua`.
</domain>

<decisions>
## Implementation Decisions

### Apariencia de flotantes (decidido en questioning / PROJECT.md)
- Flotantes semitransparentes en lugar de 100% opacos; deben verse como un panel naturalmente más oscuro que el área transparente del editor.
- Mantener sin borde y sin esquinas redondeadas (la lógica de `border_groups` con fg=bg=float_bg se conserva).
- No alterar la transparencia del editor: `editor_transparent` (Normal/NormalNC/SignColumn) permanece en `bg = NONE`.
- Conservar la reaplicación en el autocmd `ColorScheme` (necesaria para no romper el caché de transparencia de snacks.nvim — fg no nil).

### Claude's Discretion
- Mecanismo y nivel exacto de semitransparencia (p. ej. `winblend`/`pumblend` con un valor moderado manteniendo el `float_bg` oscuro, o ajuste equivalente que componga el panel oscuro con la transparencia de Ghostty 0.95). Elegir un valor sensato y dejarlo fácil de afinar; el usuario reportará si el resultado no se ve bien (evaluación visual fuera de alcance).
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `nvim/.config/nvim/lua/illico/plugins/colorscheme.lua`: define `float_bg = "#181825"` (Catppuccin mantle), listas `editor_transparent`, `float_groups`, `border_groups`, y la función `apply_transparency()` reaplicada en el autocmd `ColorScheme`.

### Established Patterns
- Highlights aplicados preservando atributos: se lee `nvim_get_hl` y se muta solo `bg`/`ctermbg` (pasar `{bg="NONE"}` a secas borra el fg y crashea snacks.gh).
- Catppuccin con `transparent_background = true`; Ghostty `background-opacity = 0.95`.

### Integration Points
- `float_groups` cubre Pmenu, Telescope*, WhichKey*, Snacks*, NormalFloat. `pumblend`/`winblend` son opciones globales (`vim.opt`) que afectan a Pmenu y ventanas flotantes respectivamente.
</code_context>

<specifics>
## Specific Ideas

El usuario describe el objetivo como: en lugar de color 100% opaco, los menús deben tener "menos transparencia que el fondo, resultando en un color más oscuro naturalmente". Es decir: el editor totalmente transparente; los flotantes semitransparentes pero más sólidos que el editor.
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.
</deferred>
