# Phase 4: tmux "Claude Done" Indicator - Context

**Gathered:** 2026-06-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Mejorar el indicador de tmux que marca la ventana donde una sesión de Claude terminó o necesita acknowledgement: (1) cambiar el glifo  (U+F06A) por la campana  (U+F0F3) en rojo en `tmux/.tmux.conf`; (2) hacer que se muestre de forma fiable durante GSD añadiendo el evento `Notification` al hook (hoy solo `Stop`); (3) versionar el hook y el registro en el repo. Toca config en vivo de Claude Code (~/.claude) — ejecutado inline con cuidado.
</domain>

<decisions>
## Implementation Decisions

### Glifo (NOTIFY-01, locked)
- Reemplazar `` (U+F06A, bytes ef 80 aa... en realidad el actual) por `` (U+F0F3, bytes ef 83 b3) en rojo (`@thm_red`) en `window-status-format` y `window-status-current-format` (líneas ~134 y ~137 de `tmux/.tmux.conf`).

### Eventos / fiabilidad (NOTIFY-02, locked — decisión del usuario)
- Añadir el hook `tmux-claude-done.sh` al evento **`Notification`** además de `Stop`. Razón: durante GSD, cuando Claude se pausa esperando input (AskUserQuestion/checkpoints/permisos) eso es un `Notification`, que hoy NO está cableado → por eso "con GSD a veces no se muestra". NO añadir `SubagentStop` (marcaría en cada subagente, ruidoso).
- El script NO necesita cambio de lógica: usa `$TMUX_PANE`/`window_active`, funciona igual en ambos eventos. Solo se actualiza el comentario de cabecera para reflejar "terminó o necesita acknowledgement".

### Versionado (NOTIFY-02, locked — decisión del usuario)
- Mover el hook a `claude/.claude/hooks/tmux-claude-done.sh` (repo) y symlinkear `~/.claude/hooks/tmux-claude-done.sh` → repo.
- Trackear también `~/.claude/settings.json` en el repo (`claude/.claude/settings.json`) + symlink, para que el registro `Notification` quede versionado. settings.json no contiene secretos (solo rutas de hooks).
- Backup de los archivos reales antes de reemplazarlos por symlinks. Claude Code corriendo: cambios de settings.json aplican en la próxima sesión.

### Claude's Discretion
- Symlinks absolutos vs relativos: usar absolutos al repo (`/Users/illico/dotfiles/claude/.claude/...`), robustos e idempotentes ante un futuro `stow claude`.
</decisions>

<code_context>
## Existing Code Insights

- `tmux/.tmux.conf` líneas 127-144: `@claude_done` flag + glifo rojo en window-status-format/current-format; `after-select-window` lo limpia (línea 178).
- `~/.claude/settings.json`: hook `tmux-claude-done.sh` registrado solo bajo `Stop` (junto a peon-ping). Ya existe bloque `Notification` (con peon-ping) al que se añade el hook.
- Paquete `claude/` del repo: solo `CLAUDE.md` y `skills/` trackeados; `hooks/` y `settings.json` NO existían en el repo hasta esta fase. Skills se despliegan por symlink (mezcla repo + `.agents/skills`).
- Hook script actual: marca ventana no-activa con `@claude_done 1` usando `$TMUX_PANE`.
</code_context>

<specifics>
## Specific Ideas

Usuario: "tmux tenía una config que mostraba un icono rojo al lado del número de la tab cuando una sesión de Claude terminaba o necesitaba acknowledgement; este icono puede ser mejor [→ campana], y a veces con GSD no se muestra, debe ser por los subagentes."
</specifics>

<deferred>
## Deferred Ideas

- `SubagentStop` como evento del indicador — descartado por ruidoso.
</deferred>
