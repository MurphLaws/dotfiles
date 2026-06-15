#!/usr/bin/env bash
set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

[ "$(tmux show-options -gqv @quarto_active 2>/dev/null)" = "1" ] || exit 0
tile="$(tmux show-options -wqv @quarto_tile 2>/dev/null || true)"

read -r X0 Y0 W H < <(
  osascript -l JavaScript -e 'ObjC.import("AppKit"); var ph=$.NSScreen.screens.objectAtIndex(0).frame.size.height; var f=$.NSScreen.mainScreen.visibleFrame; var tx=f.origin.x, ty=ph-(f.origin.y+f.size.height); `${Math.round(tx)} ${Math.round(ty)} ${Math.round(f.size.width)} ${Math.round(f.size.height)}`' 2>/dev/null
)
X0="${X0:-0}"; Y0="${Y0:-37}"; W="${W:-1920}"; H="${H:-1043}"

ghostty_to() {
  osascript <<EOF 2>/dev/null || true
tell application "System Events" to tell process "ghostty"
  set position of window 1 to {$1, $2}
  set size of window 1 to {$3, $4}
end tell
EOF
}
qpreview_visible() {
  osascript -e "tell application \"System Events\" to set visible of process \"qpreview\" to $1" 2>/dev/null || true
}

if [ "$tile" = "1" ]; then
  qpreview_visible true
  ghostty_to "$X0" "$Y0" "$((W / 2))" "$H"
else
  qpreview_visible false
  ghostty_to "$X0" "$Y0" "$W" "$H"
fi
