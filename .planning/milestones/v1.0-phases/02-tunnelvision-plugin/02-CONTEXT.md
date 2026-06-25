# Phase 2: Tunnelvision Plugin - Context

**Gathered:** 2026-06-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Instalar el plugin `tunnelvision.nvim` (leolaurindo) en la config de Neovim vía lazy.nvim, con un toggle en `<leader>tv` que no interfiera con otros keymaps ni plugins. El plugin NO debe auto-activarse (es opt-in): solo se enciende/apaga con el toggle. Nuevo archivo de spec: `nvim/.config/nvim/lua/illico/plugins/tunnelvision.lua` (convención: un archivo por plugin bajo `illico/plugins/`).
</domain>

<decisions>
## Implementation Decisions

### Instalación y toggle (locked)
- Plugin: `"leolaurindo/tunnelvision.nvim"` vía lazy.nvim, archivo nuevo `illico/plugins/tunnelvision.lua`.
- Toggle keybind: `<leader>tv` (verificado libre; los `<leader>t*` ocupados son `tb`, `ths`, `tw`, `tz`; `<leader>v` también libre pero el usuario eligió `<leader>tv`).
- El plugin no auto-activa (opt-in por defecto) → carga perezosa por el keymap (`keys = {...}`) para no interferir con la edición normal ni el arranque.
- El desc del keymap debe ser claro (p. ej. "TunnelVision toggle") para which-key.

### API de tunnelvision.nvim (verificada del repo)
- `setup(opts)` con opciones tipo `{ mode = "static", scope = "function", source = "lsp_else_word" }`. Si no se quieren overrides, `opts = {}` basta.
- Comandos: `:TunnelVision on|off|toggle|next|prev|retarget|refresh|status`, `:TunnelVision mode [...]`, `:TunnelVision scope [...]`.
- Lua API documentada: `require("tunnelvision").on(opts)`, `.off()`, `.is_active()`. La existencia de un `.toggle()` en Lua es AMBIGUA en el README.
- Requisitos: Neovim >= 0.9 (cumplido, 0.11), opcionalmente treesitter/LSP documentHighlight (ya presentes en la config).

### Claude's Discretion
- Forma exacta del toggle: PREFERIR el comando documentado `:TunnelVision toggle` (`<cmd>TunnelVision toggle<CR>`) que es robusto y no depende de si `.toggle()` Lua existe; alternativamente un wrapper Lua con `is_active()` → `off()`/`on()`. El executor debe confirmar la API real contra el source instalado del plugin antes de decidir.
- Valores de `opts` (mode/scope/source): usar los defaults razonables o `{}`.
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Convención de specs: cada plugin en su propio archivo bajo `nvim/.config/nvim/lua/illico/plugins/` (p. ej. `leap.lua`, `aerial.lua`), cargado automáticamente por lazy.nvim (`illico.plugins`).
- Lazy-loading por `keys = {...}` ya se usa en otros specs (p. ej. snacks keys).

### Established Patterns
- which-key muestra el `desc` de los keymaps; usar desc descriptivo.
- Catppuccin/transparencia ya resueltos en fase 1; tunnelvision no debe tocar highlights globales del editor.

### Integration Points
- Nuevo archivo `illico/plugins/tunnelvision.lua` returneando la spec table; lazy lo recoge sin más cambios.
</code_context>

<specifics>
## Specific Ideas

El usuario pidió explícitamente: instalar el plugin y "un comando de toggle que no interfiera con lo demás". `<leader>tv` confirmado por el usuario.
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.
</deferred>
