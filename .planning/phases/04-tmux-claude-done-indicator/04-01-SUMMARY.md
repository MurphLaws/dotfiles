---
phase: 04-tmux-claude-done-indicator
plan: 01
requirements:
  - NOTIFY-01
  - NOTIFY-02
status: complete
---

# Phase 4 Summary — tmux "Claude Done" Indicator

## Self-Check: PASSED

## What was built

| Task | Change | Commit |
|------|--------|--------|
| 1 | Glifo del indicador  (U+F06A) →  (U+F0F3, campana) en rojo, en `window-status-format` y `window-status-current-format` de `tmux/.tmux.conf` (2/2 ocurrencias) | e42be47 |
| 2 | Hook `tmux-claude-done.sh` versionado en `claude/.claude/hooks/` (comentario actualizado a "terminó o necesita acknowledgement"); `~/.claude/hooks/tmux-claude-done.sh` ahora es symlink al repo (backup `.pre-repo.bak`) | d308f11 |
| 3 | `tmux-claude-done.sh` añadido al evento **`Notification`** de `~/.claude/settings.json` (junto a peon-ping), conservando `Stop`; `settings.json` versionado en `claude/.claude/settings.json` + symlink (backup `.pre-repo.bak`) | 2a1cd5a |

## Why (reliability fix)

El indicador antes solo disparaba en `Stop`. Durante GSD, cuando Claude se pausa esperando input (AskUserQuestion / checkpoints / permisos) eso es un evento `Notification`, que no estaba cableado → de ahí que "con GSD a veces no se mostrara". Ahora el hook cubre `Stop` (terminó) + `Notification` (necesita acknowledgement). Se descartó `SubagentStop` por ruidoso (marcaría en cada subagente).

## Verification (code-level)

- `grep -c $'' tmux/.tmux.conf` → 2; sin restos de U+F06A.
- `settings.json` válido (JSON); `Notification` = [peon.sh, tmux-claude-done.sh]; `Stop` = [peon.sh, tmux-claude-done.sh].
- `~/.claude/hooks/tmux-claude-done.sh` y `~/.claude/settings.json` son symlinks al repo; resuelven OK.
- `tmux -f tmux/.tmux.conf ... start-server` → config OK.

## Notes / live config

- El registro `Notification` aplica en la próxima sesión de Claude Code (settings.json se lee al inicio).
- Backups de los archivos reales originales: `~/.claude/hooks/tmux-claude-done.sh.pre-repo.bak` y `~/.claude/settings.json.pre-repo.bak`.
- El script no necesitó cambios de lógica (usa `$TMUX_PANE`/`window_active`; funciona igual en Stop y Notification).
- No se añadió `SubagentStop`. El indicador sigue marcando solo ventanas NO activas y se limpia al seleccionarlas (lógica existente intacta).
