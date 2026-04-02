# Taskwarrior shell integration
source "$HOME/.task/task-aliases.zsh"

# Add taskwarrior completion from homebrew
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
  autoload -Uz _task
  compdef _task task
fi

# Edit a task's description in neovim
task-edit() {
  local tmpfile=$(mktemp /tmp/task-edit.XXXXXX)
  task "$1" export 2>/dev/null | jq -r '.[0].description' > "$tmpfile"
  nvim "$tmpfile"
  local new_desc=$(cat "$tmpfile")
  rm "$tmpfile"
  task "$1" modify description:"$new_desc"
}
