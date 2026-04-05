# Taskwarrior shell integration
source "$HOME/.task/task-aliases.zsh"

# Add taskwarrior completion from homebrew
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

# Custom task completion: autocomplete project names after "task note -p"
_task() {
  if [[ ${words[2]} == "note" && ( ${words[3]} == "-p" || ${words[3]} == "--project" ) && CURRENT -eq 4 ]]; then
    local projects=(${(f)"$({ command task _projects; command task status:completed _unique project } 2>/dev/null | sort -u)"})
    compadd -a projects
    return
  fi
  # Load and call the original _task from homebrew
  unfunction _task
  autoload -Uz _task
  _task "$@"
}
compdef _task task

# Edit a task's description in neovim
task-edit() {
  local tmpfile=$(mktemp /tmp/task-edit.XXXXXX)
  task "$1" export 2>/dev/null | jq -r '.[0].description' > "$tmpfile"
  nvim "$tmpfile"
  local new_desc=$(cat "$tmpfile")
  rm "$tmpfile"
  task "$1" modify description:"$new_desc"
}
