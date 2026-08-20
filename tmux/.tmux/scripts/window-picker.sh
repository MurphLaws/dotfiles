#!/usr/bin/env bash
# ---------------------------------------------------
# Floating window (tab) picker for tmux  (prefix + b)
# ---------------------------------------------------
# Lista flotante de las ventanas de la sesion, pintada con los MISMOS iconos y
# colores que las tabs (plugin tmux-tabicon): se leen sus opciones en vivo, asi
# el picker queda siempre en sync con la barra. Sin campo de busqueda: se navega
# con j/k y se salta con Enter.
#
# NB: macOS solo trae bash 3.2, asi que NADA de arrays asociativos (declare -A).
#
# Uso: window-picker.sh <session_name>
set -uo pipefail

# Ghostty arranca tmux con un PATH minimo (ver tmux.conf); garantizamos tmux/fzf.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

session="${1:-}"
# display-popup no expande #{session_name} al lanzarse desde un bind, asi que el
# argumento puede llegar vacio o literal; en ese caso lo resolvemos aqui (dentro
# del popup, display-message apunta al cliente que lo abrio -> sesion correcta).
case "$session" in
  ''|'#{'*) session="$(tmux display-message -p '#{session_name}')" ;;
esac

# --- Iconos/colores desde la config de tmux-tabicon -------------------------
# Cada opcion es "?<cond>,<valor>|?<cond>,<valor>|...". La convertimos a lineas
# "clave<TAB>valor" detectando la regla por una palabra clave de su condicion.
build_map() {
  # $1 = string de opcion de tabicon; imprime "clave\tvalor" por linea.
  local raw="$1" entry cond val key oldIFS="$IFS"
  IFS='|'
  set -- $raw
  IFS="$oldIFS"
  for entry in "$@"; do
    [ -z "$entry" ] && continue
    cond="${entry%,*}"       # todo menos el ultimo campo (la condicion puede
    val="${entry##*,}"       # llevar comas internas; el valor nunca las tiene)
    case "$cond" in
      *"==:1,1"*)        key=default ;;
      *"*zsh"*)          key=zsh ;;
      *"*fish"*)         key=fish ;;
      *"window_panes"*)  key=multi ;;
      *"uvicorn"*)       key=uvicorn ;;
      *"python*"*)       key=python ;;
      *",node"*)         key=node ;;
      *"copilot"*)       key=copilot ;;
      *"nvim"*)          key=nvim ;;
      *"claude"*)        key=claude ;;
      *"_[0-9]"*)        key=jupyter ;;
      *) continue ;;
    esac
    printf '%s\t%s\n' "$key" "$val"
  done
}
ICON_MAP="$(build_map "$(tmux show-options -gv @tmux-tabicon-manual-icons 2>/dev/null)")"
COLOR_MAP="$(build_map "$(tmux show-options -gv @tmux-tabicon-manual-colors 2>/dev/null)")"

lookup() { # lookup <map> <key> ; imprime el valor o nada
  printf '%s\n' "$1" | awk -F'\t' -v k="$2" '$1==k{print $2; exit}'
}

# Resuelve la clave de una ventana segun comando + nº de panes (misma prioridad
# que tabicon: lo mas especifico gana).
resolve_key() {
  local cmd="$1" panes="$2"
  case "$cmd" in
    [0-9]*_[0-9]*_[0-9]*) echo jupyter; return ;;
    claude)  echo claude;  return ;;
    nvim)    echo nvim;    return ;;
    copilot) echo copilot; return ;;
    node)    echo node;    return ;;
    python*) echo python;  return ;;
    uvicorn) echo uvicorn; return ;;
  esac
  if [ "${panes:-1}" -gt 1 ] 2>/dev/null; then echo multi; return; fi
  case "$cmd" in
    *fish) echo fish; return ;;
    *zsh)  echo zsh;  return ;;
  esac
  echo default
}

# hex (#rrggbb) -> secuencia ANSI truecolor de foreground.
fg() {
  local h="${1#\#}"
  [ ${#h} -lt 6 ] && h="535965"
  printf '\033[38;2;%d;%d;%dm' "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"
}
DIM=$'\033[38;2;83;89;101m'
BOLD=$'\033[1m'; RST=$'\033[0m'

# --- Construccion de la lista ----------------------------------------------
lines=""
while IFS=$'\t' read -r idx active panes cmd name; do
  [ -z "$idx" ] && continue
  key="$(resolve_key "$cmd" "$panes")"
  icon="$(lookup "$ICON_MAP" "$key")";  [ -z "$icon" ] && icon="$(lookup "$ICON_MAP" default)"
  col="$(lookup "$COLOR_MAP" "$key")";  [ -z "$col" ]  && col="$(lookup "$COLOR_MAP" default)"
  [ -z "$icon" ] && icon="●"
  [ -z "$col" ]  && col="#535965"
  ansi="$(fg "$col")"
  if [ "$active" = "1" ]; then
    mark="${ansi}▎${RST}"; nm="${ansi}${BOLD}${name}${RST}"
  else
    mark=" "; nm="${ansi}${name}${RST}"
  fi
  display="${mark} ${ansi}${icon}${RST}  ${nm}  ${DIM}${cmd}${RST}"
  lines="${lines}${idx}	${display}
"
done < <(tmux list-windows -t "$session" \
           -F '#{window_index}	#{window_active}	#{window_panes}	#{pane_current_command}	#{window_name}')

if [ -z "$lines" ]; then
  printf 'no windows for session: %s\n' "$session" \
    | fzf --reverse --no-input --border=rounded --header='(press esc)'
  exit 0
fi

selection="$(
  printf '%s' "$lines" \
    | fzf \
        --ansi \
        --reverse \
        --no-multi \
        --no-input \
        --no-scrollbar \
        --highlight-line \
        --border=rounded \
        --padding=0,1 \
        --pointer='▶' \
        --delimiter=$'\t' \
        --with-nth=2 \
        --header='  j/k move   ·   enter switch   ·   esc cancel' \
        --color='fg:-1,bg:-1,fg+:-1,bg+:#2c313a,hl:#4fa6ed,hl+:#4fa6ed,pointer:#4fa6ed,marker:#4fa6ed,header:#535965,border:#4fa6ed,gutter:-1,info:#535965' \
        --bind='j:down,k:up,q:abort'
)" || exit 0

idx="${selection%%	*}"
[ -n "$idx" ] && tmux select-window -t "$session:$idx"
