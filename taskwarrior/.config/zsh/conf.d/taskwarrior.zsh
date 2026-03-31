# Taskwarrior shell integration
source "$HOME/.task/task-aliases.zsh"

# Edit a task's description in neovim
task-edit() {
  local tmpfile=$(mktemp /tmp/task-edit.XXXXXX)
  task "$1" export 2>/dev/null | jq -r '.[0].description' > "$tmpfile"
  nvim "$tmpfile"
  local new_desc=$(cat "$tmpfile")
  rm "$tmpfile"
  task "$1" modify description:"$new_desc"
}
