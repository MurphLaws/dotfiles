# Taskwarrior aliases — source from .zshrc
# Add: source ~/.task/task-aliases.zsh

task() {
    local colorize="$HOME/.task/hooks/colorize-top"
    case "$1" in
        _projects)
            { command task _projects; command task status:completed _unique project } 2>/dev/null | sort -u
            ;;
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
