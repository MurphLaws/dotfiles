#!/bin/sh
# Toggle del split inferior (prefix + \): alterna su altura entre un minimo
# siempre visible (MIN lineas: se ve el prompt y la ultima linea de output)
# y un tamano mediano (30%). Si no existe todavia, lo crea en el cwd actual.
# Al expandir, el foco pasa al split; al minimizar, vuelve al pane superior.

MIN=3

if [ "$(tmux display -p '#{window_panes}')" -eq 1 ]; then
  tmux split-window -v -l 30% -c "$(tmux display -p '#{pane_current_path}')"
  exit 0
fi

h=$(tmux display -p -t '{bottom}' '#{pane_height}')
if [ "$h" -le "$MIN" ]; then
  tmux resize-pane -t '{bottom}' -y 30%
  tmux select-pane -t '{bottom}'
else
  tmux resize-pane -t '{bottom}' -y "$MIN"
  tmux select-pane -t '{top}'
fi
