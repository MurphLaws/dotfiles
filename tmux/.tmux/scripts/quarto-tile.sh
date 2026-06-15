#!/usr/bin/env bash
# quarto-tile.sh — coloca Ghostty en la mitad izquierda cuando el tmux window
# activo está marcado con @quarto_tile (sesión de QuartoSplit); si no, restaura
# Ghostty a pantalla completa y ESCONDE el visor WebKit (qpreview), para que al
# cambiar de tab no quede flotando encima.
#
# Trabaja SIEMPRE sobre un solo monitor: el que tiene el foco (NSScreen.main),
# que es donde está Ghostty. NO usa la unión de todos los monitores (eso es lo
# que devolvía `Finder bounds of window of desktop` en setups multi-monitor, y
# rompía el cálculo de la mitad: HALF salía gigante).
#
# Usa visibleFrame (el MISMO rect que usa qpreview.swift), que ya descuenta la
# barra de menú/notch Y el Dock. Así Ghostty y el visor calculan bordes idénticos
# y no queda gap vertical entre ambos.
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

# El hook `after-select-window` de tmux lanza este script con un PATH mínimo que
# NO incluye Homebrew, así que `tmux` (y otros binarios) no se encuentran y el
# script salía silenciosamente en la primera línea. Garantizamos el PATH aquí.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Sin sesión de split activa => no hacemos nada (cero overhead en uso normal).
[ "$(tmux show-options -gqv @quarto_active 2>/dev/null)" = "1" ] || exit 0

tile="$(tmux show-options -wqv @quarto_tile 2>/dev/null || true)"

# visibleFrame del MONITOR ENFOCADO, convertido a coordenadas top-left globales
# que entiende System Events: x_izq  y_arriba  ancho  alto. Es exactamente el
# mismo rect que qpreview.swift usa (NSScreen.main.visibleFrame), así los dos
# bordes coinciden y no queda gap vertical.
read -r X0 Y0 W H < <(
  osascript -l JavaScript -e 'ObjC.import("AppKit"); var ph=$.NSScreen.screens.objectAtIndex(0).frame.size.height; var f=$.NSScreen.mainScreen.visibleFrame; var tx=f.origin.x, ty=ph-(f.origin.y+f.size.height); `${Math.round(tx)} ${Math.round(ty)} ${Math.round(f.size.width)} ${Math.round(f.size.height)}`' 2>/dev/null
)
X0="${X0:-0}"; Y0="${Y0:-37}"; W="${W:-1920}"; H="${H:-1043}"
HALF=$(( W / 2 ))

ghostty_to() {  # $1=x  $2=y  $3=w  $4=h
  osascript <<EOF 2>/dev/null || true
tell application "System Events" to tell process "ghostty"
  set position of window 1 to {$1, $2}
  set size of window 1 to {$3, $4}
end tell
EOF
}

qpreview_visible() {  # $1=true|false  => muestra/esconde el visor (como Cmd+H)
  osascript -e "tell application \"System Events\" to set visible of process \"qpreview\" to $1" 2>/dev/null || true
}

if [ "$tile" = "1" ]; then
  qpreview_visible true                    # asegurar visible al volver al tab
  ghostty_to "$X0" "$Y0" "$HALF" "$H"      # mitad izquierda
else
  qpreview_visible false                   # esconder el visor en otros tabs
  ghostty_to "$X0" "$Y0" "$W" "$H"         # pantalla completa del monitor
fi
