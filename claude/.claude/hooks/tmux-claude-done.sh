#!/bin/sh
# Marca la ventana de tmux donde Claude acaba de terminar O necesita
# acknowledgement (espera input: AskUserQuestion, checkpoint, permiso) con un
# flag (@claude_done) para mostrar un icono de campana en la barra de estado.
# Registrado en los eventos Stop y Notification (ver ~/.claude/settings.json).
# Solo marca ventanas que NO sean la activa: si ya la estas viendo, no hay nada
# que notificar. El flag se borra solo al seleccionar la ventana (hook
# after-select-window en ~/.tmux.conf).
[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0

# Si la ventana del pane ya es la activa de su sesion, no notificar.
active=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)
[ "$active" = "1" ] && exit 0

tmux set-option -w -t "$TMUX_PANE" @claude_done 1 2>/dev/null
exit 0
