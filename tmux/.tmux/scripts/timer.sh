#!/usr/bin/env bash
#
# Cuenta atras para la barra de estado de tmux.
#
#   timer.sh prompt                 pide duracion y nombre (lo usa el menu)
#   timer.sh start 25m [nombre]     arranca (o reinicia) la cuenta
#   timer.sh pause                  pausa / reanuda
#   timer.sh restart                vuelve a empezar con la misma duracion y nombre
#   timer.sh stop                   la quita de la barra
#   timer.sh status                 lo que pinta la barra (vacio si no hay nada)
#
# El estado vive en un fichero, asi que la cuenta sobrevive a cerrar nvim, a
# cambiar de ventana y a reiniciar el shell: solo depende del servidor de tmux.

set -uo pipefail

STATE="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-timer"
SELF="$HOME/.tmux/scripts/timer.sh"

# Mismos valores que la paleta @thm_* de tmux.conf (onedark darker).
C_DIM="#535965"
C_RUN="#e2b86b"
C_DONE="#e55561"

# "25m" | "90s" | "1h30m" | "25" (minutos) -> segundos
parse_duration() {
	local spec="$1" total=0 num unit rest

	if [[ "$spec" =~ ^[0-9]+$ ]]; then
		echo $((spec * 60))
		return 0
	fi

	rest="$spec"
	while [[ -n "$rest" ]]; do
		if [[ "$rest" =~ ^([0-9]+)([hms])(.*)$ ]]; then
			num="${BASH_REMATCH[1]}"
			unit="${BASH_REMATCH[2]}"
			rest="${BASH_REMATCH[3]}"
			case "$unit" in
			h) total=$((total + num * 3600)) ;;
			m) total=$((total + num * 60)) ;;
			s) total=$((total + num)) ;;
			esac
		else
			return 1
		fi
	done

	[[ "$total" -gt 0 ]] || return 1
	echo "$total"
}

# segundos -> mm:ss, o h:mm:ss cuando pasa de la hora
format_time() {
	local secs="$1" hours mins
	((secs < 0)) && secs=0
	hours=$((secs / 3600))
	mins=$(((secs % 3600) / 60))
	secs=$((secs % 60))
	if ((hours > 0)); then
		printf '%d:%02d:%02d' "$hours" "$mins" "$secs"
	else
		printf '%02d:%02d' "$mins" "$secs"
	fi
}

# Fichero de estado: "MODO VALOR DURACION NOMBRE".
#   MODO     running | paused | done
#   VALOR    epoch limite (running/done)  o  segundos restantes (paused)
#   DURACION segundos originales, para poder reiniciar
read_state() {
	MODE="" VALUE="" DURATION="" LABEL=""
	[[ -f "$STATE" ]] || return 1
	read -r MODE VALUE DURATION LABEL <"$STATE" || return 1
	[[ -n "$MODE" ]]
}

write_state() {
	mkdir -p "$(dirname "$STATE")"
	printf '%s %s %s %s\n' "$1" "$2" "$3" "${4:-}" >"$STATE"
}

refresh_bar() {
	tmux refresh-client -S 2>/dev/null
}

notify_done() {
	local label="$1" text="Se acabó el tiempo"
	[[ -n "$label" ]] && text="Se acabó el tiempo: $label"

	tmux display-message "󰄉  $text" 2>/dev/null
	if command -v osascript >/dev/null 2>&1; then
		osascript -e "display notification \"$text\" with title \"Timer\"" >/dev/null 2>&1
	fi
	[[ -f /System/Library/Sounds/Glass.aiff ]] &&
		afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
}

# El prompt vive aqui y no en el bind para no anidar tres niveles de comillas
# dentro de display-menu.
cmd_prompt() {
	tmux command-prompt -p "duracion:,nombre:" "run-shell '$SELF start %1 %2'"
}

cmd_start() {
	local spec="${1:-25m}" seconds
	shift || true

	if ! seconds="$(parse_duration "$spec")"; then
		tmux display-message "timer: no entiendo '$spec' (usa 25m, 90s, 1h30m)" 2>/dev/null
		return 1
	fi

	write_state running "$(($(date +%s) + seconds))" "$seconds" "$*"
	refresh_bar
}

cmd_pause() {
	if ! read_state; then
		tmux display-message "timer: no hay ninguno en marcha" 2>/dev/null
		return 0
	fi
	case "$MODE" in
	running) write_state paused "$((VALUE - $(date +%s)))" "$DURATION" "$LABEL" ;;
	paused) write_state running "$(($(date +%s) + VALUE))" "$DURATION" "$LABEL" ;;
	done) return 0 ;;
	esac
	refresh_bar
}

cmd_restart() {
	if ! read_state; then
		tmux display-message "timer: no hay ninguno que reiniciar" 2>/dev/null
		return 0
	fi
	write_state running "$(($(date +%s) + DURATION))" "$DURATION" "$LABEL"
	refresh_bar
}

cmd_stop() {
	rm -f "$STATE"
	refresh_bar
}

cmd_status() {
	read_state || return 0

	local left suffix=""
	[[ -n "$LABEL" ]] && suffix=" $LABEL"

	case "$MODE" in
	running)
		left=$((VALUE - $(date +%s)))
		if ((left <= 0)); then
			# El primero en darse cuenta avisa; el cambio de modo lo hace una sola vez.
			write_state done "$VALUE" "$DURATION" "$LABEL"
			notify_done "$LABEL"
			printf '#[fg=%s]│#[fg=%s,bold] 󰄉 ¡Tiempo!%s ' "$C_DIM" "$C_DONE" "$suffix"
		else
			printf '#[fg=%s]│#[fg=%s] 󰄉 %s%s ' "$C_DIM" "$C_RUN" "$(format_time "$left")" "$suffix"
		fi
		;;
	paused)
		printf '#[fg=%s]│#[fg=%s] 󰏤 %s%s ' "$C_DIM" "$C_DIM" "$(format_time "$VALUE")" "$suffix"
		;;
	done)
		printf '#[fg=%s]│#[fg=%s,bold] 󰄉 ¡Tiempo!%s ' "$C_DIM" "$C_DONE" "$suffix"
		;;
	esac
}

case "${1:-status}" in
prompt) cmd_prompt ;;
start)
	shift
	cmd_start "$@"
	;;
pause) cmd_pause ;;
restart) cmd_restart ;;
stop) cmd_stop ;;
status) cmd_status ;;
*)
	echo "uso: timer.sh {prompt|start <duracion> [nombre]|pause|restart|stop|status}" >&2
	exit 1
	;;
esac
