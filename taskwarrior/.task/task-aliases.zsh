# Taskwarrior aliases — source from .zshrc
# Add: source ~/.task/task-aliases.zsh

task() {
    local colorize="$HOME/.task/hooks/colorize-top"
    local tree="$HOME/.task/hooks/tree-render"
    local linkicon="$HOME/.task/hooks/link-icon"

    # Intercept _projects anywhere in args (zsh completion passes rc.hooks=0 _projects)
    if [[ "$*" == *_projects* ]]; then
        { command task _projects; command task status:completed _unique project } 2>/dev/null | sort -u
        return
    fi

    # Pre-process -url / -file flags into link:VALUE
    local link_val="" had_link_flag=0
    local -a args=()
    local i=1 a p
    while (( i <= $# )); do
        a="${@[$i]}"
        case "$a" in
            -url)
                ((i++))
                link_val="${@[$i]}"
                had_link_flag=1
                ;;
            -file)
                ((i++))
                p="${@[$i]}"
                # Resolve to absolute path
                if [[ "$p" != /* ]]; then
                    if [[ -e "$p" ]]; then
                        p="$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"
                    else
                        p="$PWD/$p"
                    fi
                fi
                link_val="$p"
                had_link_flag=1
                ;;
            *)
                args+=("$a")
                ;;
        esac
        ((i++))
    done
    if (( had_link_flag )); then
        args+=("link:$link_val")
        # If the user wrote `task <id> -url ...` with no command, inject `modify`
        # so taskwarrior treats it as a modification (otherwise it errors).
        if [[ "${args[1]}" =~ ^[0-9]+$ ]]; then
            case "${args[2]}" in
                modify|mod|add|annotate|done|delete|start|stop|edit) ;;
                *) args=("${args[1]}" modify "${args[@]:1}") ;;
            esac
        fi
    fi
    set -- "${args[@]}"

    # Handle: task <id> open  → open the task's link
    if [[ "$1" =~ ^[0-9]+$ && "$2" == "open" && $# -eq 2 ]]; then
        local link
        link=$(command task _get "$1.link" 2>/dev/null)
        if [[ -z "$link" ]]; then
            echo "Task $1 has no link" >&2
            return 1
        fi
        echo "Opening: $link"
        open "$link"
        return
    fi

    case "$1" in
        ""|-*)
            command task "$@" | "$tree" | "$linkicon" | "$colorize"
            ;;
        list)
            shift
            command task list "$@" | "$tree" | "$linkicon" | "$colorize"
            ;;
        next)
            shift
            command task next "$@" | "$tree" | "$linkicon" | "$colorize"
            ;;
        split)
            # Bypass Taskwarrior's alias.split so shell-quoted args survive
            shift
            "$HOME/.task/hooks/split" "$@"
            ;;
        *)
            command task "$@"
            ;;
    esac
}
