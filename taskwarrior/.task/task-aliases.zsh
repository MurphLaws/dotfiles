# Taskwarrior aliases — source from .zshrc
# Add: source ~/.task/task-aliases.zsh

alias tt=taskwarrior-tui

task() {
    local colorize="$HOME/.task/hooks/colorize-top"
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
