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
#   timer.sh done-menu              menu del popup al llegar a cero
#   timer.sh note                   escribe la nota de sesion y devuelve su ruta
#
# El estado vive en un fichero, asi que la cuenta sobrevive a cerrar nvim, a
# cambiar de ventana y a reiniciar el shell: solo depende del servidor de tmux.
#
# Mientras corre, cada SAMPLE_INTERVAL segundos se apunta en que directorio
# estabas (el panel activo del cliente enganchado). Al terminar, eso se
# convierte en un reparto de tiempo por carpeta y, cruzando con git, en la
# lista de archivos que tocaste.

set -uo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE="$CACHE/tmux-timer"
TRACK="$CACHE/tmux-timer-track"
STAMP="$CACHE/tmux-timer-stamp"
SELF="$HOME/.tmux/scripts/timer.sh"

NOTES_DIR="${TMUX_TIMER_NOTES_DIR:-$HOME/notes/sessions}"
SAMPLE_INTERVAL=10
SNOOZE=600

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

# segundos -> "1h 05m" / "25m" / "40s", para leerlo en la nota
format_human() {
	local secs="$1" hours mins
	hours=$((secs / 3600))
	mins=$(((secs % 3600) / 60))
	if ((hours > 0)); then
		printf '%dh %02dm' "$hours" "$mins"
	elif ((mins > 0)); then
		printf '%dm' "$mins"
	else
		printf '%ds' "$secs"
	fi
}

# Fichero de estado: "MODO VALOR DURACION INICIO NOMBRE".
#   MODO     running | paused | done
#   VALOR    epoch limite (running/done)  o  segundos restantes (paused)
#   DURACION segundos originales, para poder reiniciar
#   INICIO   epoch en el que se arranco, para la nota y para git
read_state() {
	MODE="" VALUE="" DURATION="" START="" LABEL=""
	[[ -f "$STATE" ]] || return 1
	read -r MODE VALUE DURATION START LABEL <"$STATE" || return 1
	[[ -n "$MODE" ]]
}

write_state() {
	mkdir -p "$(dirname "$STATE")"
	printf '%s %s %s %s %s\n' "$1" "$2" "$3" "$4" "${5:-}" >"$STATE"
}

refresh_bar() {
	tmux refresh-client -S 2>/dev/null
}

# Apunta cuanto tiempo llevas en cada directorio. Se llama desde la barra, que
# refresca cada segundo, asi que el sello de tiempo hace de throttle y de
# candado entre varios clientes enganchados.
sample_activity() {
	local now last delta dir
	now="$(date +%s)"
	last=0
	[[ -f "$STAMP" ]] && read -r last <"$STAMP" 2>/dev/null
	[[ "$last" =~ ^[0-9]+$ ]] || last=0

	((now - last < SAMPLE_INTERVAL)) && return 0
	printf '%s\n' "$now" >"$STAMP"

	# La primera muestra solo pone el reloj en hora: no hay intervalo que repartir.
	((last == 0)) && return 0

	# Si tmux estuvo sin refrescar (desenganchado, portatil dormido) no imputamos
	# el hueco entero.
	delta=$((now - last))
	((delta > SAMPLE_INTERVAL * 2)) && delta=$((SAMPLE_INTERVAL * 2))

	dir="$(tmux list-panes -a -F \
		'#{?session_attached,#{?window_active,#{?pane_active,#{pane_current_path},},},}' \
		2>/dev/null | grep -m1 .)" || return 0
	[[ -n "$dir" ]] || return 0

	printf '%s\t%s\n' "$delta" "$dir" >>"$TRACK"
}

clear_tracking() {
	rm -f "$TRACK" "$STAMP"
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

	# En segundo plano y con los descriptores cerrados: esto sale de la barra de
	# estado y no puede quedarse bloqueando su captura.
	tmux display-popup -E -w 90% -h 90% "$SELF done-menu" >/dev/null 2>&1 &
}

# El prompt vive aqui y no en el bind para no anidar tres niveles de comillas
# dentro de display-menu.
cmd_prompt() {
	tmux command-prompt -p "duracion:,nombre:" "run-shell '$SELF start %1 %2'"
}

cmd_start() {
	local spec="${1:-25m}" seconds now
	shift || true

	if ! seconds="$(parse_duration "$spec")"; then
		tmux display-message "timer: no entiendo '$spec' (usa 25m, 90s, 1h30m)" 2>/dev/null
		return 1
	fi

	now="$(date +%s)"
	clear_tracking
	write_state running "$((now + seconds))" "$seconds" "$now" "$*"
	refresh_bar
}

cmd_pause() {
	if ! read_state; then
		tmux display-message "timer: no hay ninguno en marcha" 2>/dev/null
		return 0
	fi
	case "$MODE" in
	running)
		write_state paused "$((VALUE - $(date +%s)))" "$DURATION" "$START" "$LABEL"
		rm -f "$STAMP"
		;;
	paused) write_state running "$(($(date +%s) + VALUE))" "$DURATION" "$START" "$LABEL" ;;
	done) return 0 ;;
	esac
	refresh_bar
}

cmd_restart() {
	local now
	if ! read_state; then
		tmux display-message "timer: no hay ninguno que reiniciar" 2>/dev/null
		return 0
	fi
	now="$(date +%s)"
	clear_tracking
	write_state running "$((now + DURATION))" "$DURATION" "$now" "$LABEL"
	refresh_bar
}

# Alarga la cuenta sin perder ni el inicio ni lo que ya se ha registrado.
cmd_extend() {
	local extra="${1:-$SNOOZE}"
	read_state || return 0
	rm -f "$STAMP"
	write_state running "$(($(date +%s) + extra))" "$DURATION" "$START" "$LABEL"
	refresh_bar
}

cmd_stop() {
	rm -f "$STATE"
	clear_tracking
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
			write_state done "$VALUE" "$DURATION" "$START" "$LABEL"
			notify_done "$LABEL"
			printf '#[fg=%s]│#[fg=%s,bold] 󰄉 ¡Tiempo!%s ' "$C_DIM" "$C_DONE" "$suffix"
		else
			sample_activity
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

# --- nota de sesion -------------------------------------------------------

# "SEGUNDOS<TAB>DIRECTORIO", de mas a menos tiempo.
tracked_dirs() {
	[[ -s "$TRACK" ]] || return 0
	awk -F'\t' '{ t[$2] += $1 } END { for (d in t) printf "%d\t%s\n", t[d], d }' "$TRACK" |
		sort -rn
}

# Raices de repo, sin repetir, de todos los directorios registrados.
tracked_repos() {
	local secs dir root
	while IFS=$'\t' read -r secs dir; do
		root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || continue
		printf '%s\n' "$root"
	done < <(tracked_dirs) | awk '!seen[$0]++'
}

# Archivos del repo tocados desde el inicio: los que siguen sucios y los que
# entraron en commits durante el intervalo.
repo_files() {
	local root="$1" since="$2"
	{
		git -C "$root" status --porcelain=v1 2>/dev/null |
			sed -e 's/^.\{3\}//' -e 's/.* -> //'
		git -C "$root" log --since="@$since" --name-only --pretty=format: 2>/dev/null
	} | sed '/^$/d' | sort -u
}

# Escribe la nota y devuelve por stdout "RUTA<TAB>LINEA_DEL_CURSOR".
# El cuerpo se deja en blanco a proposito: solo el frontmatter con las horas.
cmd_note() {
	read_state || return 1

	local now ended_at started_at elapsed slug file
	now="$(date +%s)"
	[[ "$MODE" == "done" ]] && now="$VALUE"
	elapsed=$((now - START))
	((elapsed < 0)) && elapsed=0

	started_at="$(date -r "$START" '+%Y-%m-%dT%H:%M')"
	ended_at="$(date -r "$now" '+%Y-%m-%dT%H:%M')"

	slug="${LABEL:-sesion}"
	slug="$(printf '%s' "$slug" | tr '/:' '--' | tr -s ' ')"
	mkdir -p "$NOTES_DIR"
	file="$NOTES_DIR/$(date -r "$START" '+%Y-%m-%d %H%M') $slug.md"

	{
		printf -- '---\n'
		printf 'type: session\n'
		printf 'timer: "%s"\n' "${LABEL:-sin nombre}"
		printf 'started: %s\n' "$started_at"
		printf 'ended: %s\n' "$ended_at"
		printf 'duration: %s\n' "$(format_human "$elapsed")"
		printf 'tags: [session]\n'
		printf -- '---\n\n'
	} >"$file"

	# El cursor va a la linea en blanco que hay tras el frontmatter.
	printf '%s\t%s\n' "$file" "$(wc -l <"$file" | tr -d ' ')"
}

# Reparto de tiempo por directorio y archivos de git tocados, a stdout. No entra
# en la nota: esta se queda vacia para escribir.
cmd_report() {
	read_state || return 1

	local secs dir root rel files

	if [[ -s "$TRACK" ]]; then
		while IFS=$'\t' read -r secs dir; do
			printf '%8s  %s\n' "$(format_human "$secs")" "${dir/#$HOME/~}"
		done < <(tracked_dirs)
	else
		printf 'Sin registro de actividad.\n'
	fi

	while read -r root; do
		files="$(repo_files "$root" "$START")"
		[[ -n "$files" ]] || continue
		printf '\n%s\n' "${root/#$HOME/~}"
		while read -r rel; do
			printf '  %s\n' "$rel"
		done <<<"$files"
	done < <(tracked_repos)
}

# --- popup ----------------------------------------------------------------

# Menu del popup: se navega con j/k (o flechas) y se elige con Enter. Ninguna
# otra tecla hace nada, asi que un dedazo no se lleva por delante la sesion que
# acabas de terminar.
cmd_done_menu() {
	read_state || return 0

	local elapsed sel=0 key rest i choice="" out file line spec seconds
	local -a labels=(
		"Write a reflection note in Obsidian"
		"Snooze"
		"Dismiss"
	)

	elapsed=$(($(date +%s) - START))
	[[ "$MODE" == "done" ]] && elapsed=$((VALUE - START))

	draw_menu() {
		printf '\033[H\033[2J'
		printf '\n  \033[1;31m󰄉  Time'"'"'s up\033[0m%s\n' "${LABEL:+ — $LABEL}"
		printf '  \033[2m%s · %s → %s\033[0m\n\n' \
			"$(format_human "$elapsed")" \
			"$(date -r "$START" '+%H:%M')" \
			"$(date '+%H:%M')"
		for i in "${!labels[@]}"; do
			if ((i == sel)); then
				printf '  \033[1;33m❯ %s\033[0m\n' "${labels[i]}"
			else
				printf '    \033[2m%s\033[0m\n' "${labels[i]}"
			fi
		done
		printf '\n  \033[2mj/k move · Enter select\033[0m'
	}

	printf '\033[?25l'
	while true; do
		draw_menu
		if ! read -rsn1 key; then
			# Sin terminal donde leer, mejor no tocar nada.
			choice="none"
			break
		fi

		case "$key" in
		j | J) ((sel = (sel + 1) % ${#labels[@]})) ;;
		k | K) ((sel = (sel - 1 + ${#labels[@]}) % ${#labels[@]})) ;;
		'')
			if ((sel == 1)); then
				# Vacio o ilegible: vuelve al menu, sin alargar nada.
				printf '\n  Snooze: \033[?25h'
				read -r spec || { choice="none"; break; }
				printf '\033[?25l'
				seconds="$(parse_duration "${spec// /}")" || continue
			fi
			choice="$sel"
			break
			;;
		$'\033')
			# Flechas: llega "\033[A" o "\033[B" en tres golpes.
			read -rsn2 -t 1 rest
			case "$rest" in
			'[B') ((sel = (sel + 1) % ${#labels[@]})) ;;
			'[A') ((sel = (sel - 1 + ${#labels[@]}) % ${#labels[@]})) ;;
			esac
			;;
		esac
	done
	printf '\033[?25h\033[H\033[2J'

	case "$choice" in
	0)
		out="$(cmd_note)" || return 0
		file="${out%%$'\t'*}"
		line="${out##*$'\t'}"
		cmd_stop
		"${EDITOR:-nvim}" "+$line" "$file"
		;;
	1) cmd_extend "$seconds" ;;
	2) cmd_stop ;;
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
extend)
	shift
	cmd_extend "$@"
	;;
stop) cmd_stop ;;
status) cmd_status ;;
note) cmd_note ;;
report) cmd_report ;;
done-menu) cmd_done_menu ;;
*)
	echo "uso: timer.sh {prompt|start <duracion> [nombre]|pause|restart|extend [segundos]|stop|status|note|report|done-menu}" >&2
	exit 1
	;;
esac
