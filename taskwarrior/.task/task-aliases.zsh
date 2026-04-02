# Taskwarrior aliases — source from .zshrc
# Add: source ~/.task/task-aliases.zsh

task() {
    local colorize="$HOME/.task/hooks/colorize-top"
    # Intercept _projects anywhere in args (zsh completion passes rc.hooks=0 _projects)
    if [[ "$*" == *_projects* ]]; then
        { command task _projects; command task status:completed _unique project } 2>/dev/null | sort -u
        return
    fi
    case "$1" in
        ""|-*)
            command task "$@" | "$colorize"
            ;;
        list)
            shift
            command task list "$@" | "$colorize"
            ;;
        *)
            command task "$@"
            ;;
    esac
}
