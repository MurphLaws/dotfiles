# Taskwarrior aliases — source from .zshrc
# Add: source ~/.task/task-aliases.zsh

task() {
    local colorize="$HOME/.task/hooks/colorize-top"
    local taskgit="$HOME/.task/hooks/task-git.sh"
    case "$1" in
        ""|-*)
            "$taskgit" "$@" | "$colorize"
            ;;
        list)
            shift
            "$taskgit" list "$@" | "$colorize"
            ;;
        *)
            "$taskgit" "$@"
            ;;
    esac
}
