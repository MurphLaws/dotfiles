# Phase 3: Real-icons Verification - Context

**Gathered:** 2026-06-25
**Status:** Ready for planning
**Mode:** Verification/audit phase (no code change expected unless a broken link is found)

<domain>
## Phase Boundary

Verificar de extremo a extremo, a nivel de código/config, que la cadena de `real-icons.nvim` (Mirsmog) está en orden y que los iconos-imagen del pack `material` se renderizan como el plugin pretende. NO es una evaluación visual por pantallazos (fuera de alcance); es una auditoría de los eslabones de la cadena. Solo se modifica código si se encuentra un eslabón roto.
</domain>

<decisions>
## Implementation Decisions

### Alcance (locked)
- Verificar: plugin instalado, pack `material` instalado/renderizado, `magick` disponible, `allow-passthrough` activo en tmux, integración snacks_picker, fallback configurado, `mini_files=false` (desactivado a propósito).
- NO añadir cambios no pedidos. Si todo está en orden → documentar evidencia, sin tocar código.

### Claude's Discretion
- Si algún eslabón estuviera roto (p. ej. pack no instalado o magick ausente), aplicar el fix mínimo. (Resultado real: todo en orden, sin fix necesario — ver SUMMARY.)
</decisions>

<code_context>
## Existing Code Insights

- Spec en `nvim/.config/nvim/lua/illico/plugins/real-icons.lua`: `pack="material"`, `backend="ghostty"`, `build=":RealIconsInstallPack material"`, `fallback={enabled=true, provider="auto"}`, `integrations.snacks_picker=true`, `integrations.mini_files=false`.
- Cadena gráfica: Ghostty (graphics protocol) → tmux (`allow-passthrough on`, línea 18) → nvim (real-icons backend ghostty).
- Assets del pack en `~/.cache/nvim/real-icons/packs/material/` (PNGs raw) y `~/.local/share/nvim/real-icons/packs/material/dist`.
</code_context>

<specifics>
## Specific Ideas

El usuario pidió "que verifiques que esto realmente funciona ... los iconos sí se renderizan como el plugin busca, por lo que necesitarías revisar que todo esté instalado en orden". El screenshot del usuario ya muestra los iconos `material__*.png` (p. ej. el icono azul de `.lua`) renderizados en el snacks picker.
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.
</deferred>
