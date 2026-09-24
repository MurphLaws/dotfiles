# `task` a secas pinta de verde la primera tarea (la más urgente).
# Taskwarrior no colorea por posición, así que se postprocesa la salida,
# pero SOLO para `task` sin argumentos; con argumentos el binario corre
# intacto (prompts interactivos incluidos).
task() {
    if [[ $# -eq 0 && -t 1 ]]; then
        command task rc._forcecolor=on 2>/dev/null | awk '
            !done {
                line = $0
                gsub(/\033\[[0-9;]*m/, "", line)
                if (line ~ /^ *[0-9]+ /) {
                    # Reinyectar verde tras cada secuencia de color: el fondo
                    # (resaltado) se conserva y solo la letra cambia a verde.
                    out = $0
                    gsub(/\033\[[0-9;]*m/, "&\033[32m", out)
                    printf "\033[32m%s\033[0m\n", out
                    done = 1
                    next
                }
            }
            { print }'
        return ${pipestatus[1]}
    fi
    command task "$@"
}
