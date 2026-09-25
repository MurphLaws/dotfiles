# rustc/cargo vienen del formula "rust" de brew y ya están en /opt/homebrew/bin.
export PATH="$HOME/.cargo/bin:$PATH"

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# Shell base (reemplaza a oh-my-zsh; respaldo en ~/.zshrc.omz-backup)
# ------------------------------------------------------------------------------

# Historial
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_dups hist_ignore_space hist_verify
setopt inc_append_history extended_history
setopt auto_cd interactive_comments no_beep

# Keybindings estilo emacs + búsqueda en historial con flechas
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Completado: fpath de brew + compinit cacheado (regenera si el dump tiene >20 h)
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"
if [[ -n ${ZSH_COMPDUMP}(#qN.mh-20) ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''

# Alias de git (el plugin git de oh-my-zsh, copiado; helpers aparte)
source "$HOME/.zsh/git-helpers.zsh"
source "$HOME/.zsh/git-aliases.zsh"
source "$HOME/.zsh/task-next-green.zsh"

# Integracion de fzf: Ctrl-T inserta archivos en la linea de comandos,
# Ctrl-R busca en el historial, Alt-C hace cd, y ** + Tab autocompleta.
source <(fzf --zsh)

# Tema: Powerlevel10k directo (la estética vive en ~/.p10k.zsh, igual que antes)
source "$HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme"

# Sugerencias inline grises desde el historial (→ para aceptar)
source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ------------------------------------------------------------------------------
# User configuration
# ------------------------------------------------------------------------------
alias nvimconfig="cd ~/.config/nvim/lua/illico/ && nvim ."
alias gamedev="godot && cd ~/3dproto/ && nvim ."
alias neorg="nvim ~/notes/index.norg"

# Copilot CLI: autopilot with every tool/command auto-approved so it never
# stalls on "could not request permission" prompts. These flags only affect
# TOOL approvals — clarifying questions and user input still reach you.
# Swap --allow-all-tools for --yolo to also auto-allow all paths and URLs.
alias cop="copilot --allow-all-tools"
alias copauto="copilot --autopilot --allow-all-tools"

# Sync ~/notes: commit all .md and image files with a timestamp, block
# anything else from being staged, then push.
ns() {
  local notes_dir="$HOME/notes"
  local allowed_pattern='\.(md|png|jpg|jpeg|gif|svg|webp|bmp|tiff?|heic)$'

  cd "$notes_dir" || { echo "❌  ~/notes not found"; return 1 }

  # Use -z (NUL-terminated) so filenames with spaces/special chars are safe.
  # --untracked-files=all expands new folders into individual files instead
  # of collapsing them into one "?? folder/" line (which broke the
  # extension check for any new directory of notes/images).
  local dirty
  dirty=$(git status --porcelain -z --untracked-files=all | tr '\0' '\n' \
    | sed 's/^...//' \
    | grep -viE "$allowed_pattern" \
    | grep -v '^\s*$')

  if [[ -n "$dirty" ]]; then
    echo "⚠️  Blocked — only .md and image files are allowed:"
    echo "$dirty"
    cd - > /dev/null
    return 1
  fi

  # Stage allowed files only (excludes everything else via .gitignore allowlist).
  git add -A

  # Nothing to commit?
  if git diff --cached --quiet; then
    echo "✅  Notes already up to date — nothing to commit."
    cd - > /dev/null
    return 0
  fi

  local msg="notes: sync $(date '+%Y-%m-%d %H:%M')"
  git commit -m "$msg" && git push && echo "✅  $msg"
  cd - > /dev/null
}

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------------------------------------------------------------------------
# 🟢 P10K GIT FORCE OVERRIDES (Arreglo Visual)
# ------------------------------------------------------------------------------
# 1. Fuerza a p10k a esperar el estado de git (evita que lo oculte por lentitud)
typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=5

# 2. Define iconos explícitos para subida (push) y bajada (pull)
typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'

# 3. Asegura que se calculen estos estados
typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind)

# 4. Colores para el estado "Ahead" (Commits por subir) - Fondo Cian oscuro, texto blanco
typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_FOREGROUND=255
typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_BACKGROUND=23  # Dark Cyan/Teal
typeset -g POWERLEVEL9K_VCS_COMMITS_BEHIND_FOREGROUND=255
typeset -g POWERLEVEL9K_VCS_COMMITS_BEHIND_BACKGROUND=23
# ------------------------------------------------------------------------------

export PATH="/opt/homebrew/opt/node@20/bin:$PATH"

# >>> conda initialize (lazy) >>>
# El init real (conda shell.zsh hook) corre Python y cuesta ~300-470 ms en CADA
# shell. Lo diferimos: `conda` queda como función-trampolín que en su primer uso
# corre el init de verdad (que la redefine) y reenvía los argumentos.
# Trade-off: el entorno base NO se auto-activa al abrir la shell; corre `conda
# activate base` (o cualquier comando conda) y a partir de ahí todo es normal.
conda() {
    unset -f conda
    __conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}
# <<< conda initialize (lazy) <<<

export SUMO_HOME=/opt/homebrew/Cellar/sumo/1.20.0/share/sumo
# JAVA_HOME solo si hay algún JDK instalado. El glob evita invocar java_home
# (~25 ms) en cada shell cuando no hay ninguno.
_jdks=(/Library/Java/JavaVirtualMachines/*(N))
if (( $#_jdks )) && /usr/libexec/java_home -v 1.8 >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
fi
unset _jdks
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export EDITOR=nvim

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Auto-source shell config from stow packages
for conf in "$HOME/.config/zsh/conf.d/"*.zsh(N); do
  source "$conf"
done

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# TinyTeX (LaTeX local)
export PATH="$PATH:$HOME/Library/TinyTeX/bin/universal-darwin"
