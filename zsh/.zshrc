export PATH="$(brew --prefix rustup)/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

# Auto-update desactivado: el chequeo hacía una petición de red a GitHub en cada
# arranque (~635 ms, 60% del tiempo de inicio y origen de los picos de varios
# segundos). Actualiza a mano cuando quieras con: omz update
zstyle ':omz:update' mode disabled

# compinit cacheado: salta la auditoría/recompilación del dump de completado si
# ya existe y tiene menos de ~20 h (oh-my-zsh lo regenera igual a diario).
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"

source $ZSH/oh-my-zsh.sh

# User configuration
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

  # Detect files that would be staged but aren't md/image.
  local dirty
  dirty=$(git status --porcelain | awk '{print $2}' \
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
    __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/opt/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/opt/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}
# <<< conda initialize (lazy) <<<

export SUMO_HOME=/opt/homebrew/Cellar/sumo/1.20.0/share/sumo
# Avoid startup error when no JDK is installed.
if /usr/libexec/java_home -v 1.8 >/dev/null 2>&1; then
  export JAVA_HOME="$('/usr/libexec/java_home' -v 1.8)"
fi
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export EDITOR=nvim

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export EDITOR=nvim

# Auto-source shell config from stow packages
for conf in "$HOME/.config/zsh/conf.d/"*.zsh(N); do
  source "$conf"
done

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# TinyTeX (LaTeX local)
export PATH="$PATH:$HOME/Library/TinyTeX/bin/universal-darwin"
