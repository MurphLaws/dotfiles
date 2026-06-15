#!/usr/bin/env bash
# quarto-tile.sh — coloca Ghostty en la mitad izquierda cuando el tmux window
# activo está marcado con @quarto_tile (sesión de QuartoSplit); si no, restaura
# Ghostty a pantalla completa. El visor WebKit del preview (qpreview) se coloca
# a sí mismo en la mitad derecha, así que aquí no hay que tocarlo.
#
# Lo invoca:
#   - el hook `after-select-window` de tmux (en cada cambio de tab)
#   - el comando :QuartoSplit de nvim (al abrir el preview)
#
# Requiere permisos de macOS (una sola vez):
#   - Accesibilidad para Ghostty (mover su propia ventana vía System Events)
#
# Opciones tmux que consume:
#   @quarto_active   (global)  1 => hay una sesión de split activa
#   @quarto_tile     (window)  1 => este window es el que va a media pantalla

set -uo pipefail

# Sin sesión de split activa => no hacemos nada (cero overhead en uso normal).
[ "$(tmux show-options -gqv @quarto_active 2>/dev/null)" = "1" ] || exit 0

tile="$(tmux show-options -wqv @quarto_tile 2>/dev/null || true)"

# Geometría de la pantalla principal (Finder devuelve: izq, arr, der, abj).
read -r SCREEN_W SCREEN_H < <(
  osascript -e 'tell application "Finder" to get bounds of window of desktop' 2>/dev/null \
    | awk -F', ' '{print $3" "$4}'
)
SCREEN_W="${SCREEN_W:-1440}"
SCREEN_H="${SCREEN_H:-900}"

TOP=37                              # offset por barra de menú / notch
HALF=$(( SCREEN_W / 2 ))
USABLE_H=$(( SCREEN_H - TOP ))

ghostty_to() {  # $1=x  $2=w  $3=h
  osascript <<EOF 2>/dev/null || true
tell application "System Events" to tell process "ghostty"
  set position of window 1 to {$1, $TOP}
  set size of window 1 to {$2, $3}
end tell
EOF
}

if [ "$tile" = "1" ]; then
  ghostty_to 0 "$HALF" "$USABLE_H"
else
  # No estamos en el tab marcado => Ghostty a pantalla completa.
  ghostty_to 0 "$SCREEN_W" "$USABLE_H"
fi
