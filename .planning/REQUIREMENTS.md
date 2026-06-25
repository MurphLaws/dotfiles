# Requirements: Dotfiles — Ajustes gráficos de Neovim

**Defined:** 2026-06-25
**Core Value:** La config de Neovim se ve y se comporta como el usuario quiere: menús con un panel naturalmente más oscuro (no 100% opaco), sin romper la transparencia del editor ni la estética sin bordes ya establecida.

## v1 Requirements

Requisitos para este milestone. Cada uno mapea a fases del roadmap.

### Flotantes

- [ ] **FLOAT-01**: Los menús y ventanas flotantes se muestran semitransparentes (menos transparentes que el editor, que es 100% transparente), produciendo un panel naturalmente más oscuro, conservando sin borde y sin esquinas redondeadas

### Tunnelvision

- [ ] **TUNNEL-01**: `tunnelvision.nvim` (leolaurindo) queda instalado y operativo, con un toggle en `<leader>tv` que no interfiere con otros keymaps ni plugins

### Iconos

- [ ] **ICONS-01**: La cadena de `real-icons.nvim` (Mirsmog) está verificada de extremo a extremo a nivel de código/config — plugin presente, pack `material` instalable, `magick` disponible, `allow-passthrough` activo en tmux, fallback correcto — y los iconos renderizan como el plugin pretende

### Cierre

- [ ] **REPO-01**: Todos los cambios quedan commiteados y el árbol de git queda limpio al finalizar

## v2 Requirements

(Ninguno — milestone acotado a los tres ajustes gráficos.)

## Out of Scope

Explícitamente excluido. Documentado para evitar scope creep.

| Feature | Reason |
|---------|--------|
| Evaluación visual por pantallazos | El usuario la descartó; la corrección se verifica a nivel de código y el usuario reporta si algo no se ve bien |
| Cambiar la estética de bordes de los menús | El usuario quiere mantener sin borde / sin esquinas redondeadas |
| Tocar la transparencia del editor (`Normal`) | Debe seguir 100% transparente |
| Cambios en otras herramientas del repo (taskwarrior, claude, etc.) | Fuera del milestone, salvo lo mínimo de la cadena de passthrough si la verificación de real-icons lo exige |

## Traceability

Qué fases cubren qué requisitos. Se actualiza durante la creación del roadmap.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FLOAT-01 | TBD | Pending |
| TUNNEL-01 | TBD | Pending |
| ICONS-01 | TBD | Pending |
| REPO-01 | TBD | Pending |

**Coverage:**
- v1 requirements: 4 total
- Mapped to phases: 0 (pending roadmap)
- Unmapped: 4 ⚠️

---
*Requirements defined: 2026-06-25*
*Last updated: 2026-06-25 after initial definition*
