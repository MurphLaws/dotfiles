export PATH="$(brew --prefix rustup)/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
alias nvimconfig="cd ~/.config/nvim/lua/illico/ && nvim ."
alias gamedev="godot && cd ~/3dproto/ && nvim ."
alias neorg="nvim ~/notes/index.norg"
alias genindex='cd "$HOME/Downloads/Alarmas Operativas (Por corregir)" && bash "$HOME/generate_index.sh"'

export ICLOUD_ORG_PATH="$HOME/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"
alias icloudpath="cd \"$ICLOUD_ORG_PATH\""

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

# >>> conda initialize >>>
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
# <<< conda initialize <<<

export SUMO_HOME=/opt/homebrew/Cellar/sumo/1.20.0/share/sumo
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export EDITOR=nvim

# API keys y demás secretos NO van en este repo (es público).
# Viven en ~/.config/zsh/conf.d/secrets.zsh (gitignored), que el loop de
# conf.d de más abajo carga automáticamente. Plantilla: secrets.zsh.example
[ -s "/Users/illico/.bun/_bun" ] && source "/Users/illico/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Deploy alarmas operativas al server/S3
alias deploy-alarmas="bash ~/Innovaitors/PEGSA/deploy_alarmas.sh"
alias index-alarmas="bash ~/Innovaitors/PEGSA/index-alarmas.sh"
pegsa-index() {
  ssh pegsa-chatbot-server 'python3 -c "
import yaml, subprocess, json

index = yaml.safe_load(open(\"/home/ubuntu/chatbot-soporte-tecnico-pegsa/data/index.yaml\"))
s3_base = index[\"Config\"][\"s3_path\"]
alarms = index.get(\"Alarms\", {})

for code in sorted(alarms.keys(), key=lambda x: int(x)):
    alarm = alarms[code]
    name = alarm.get(\"name\", \"\")
    alarm_type = alarm.get(\"alarm_type\", \"\")
    index_files = set(alarm.get(\"extra_metadata\", []))

    # List files in S3 extra_metadata for this alarm
    result = subprocess.run(
        [\"aws\", \"s3\", \"ls\", f\"{s3_base}{code}/extra_metadata/\"],
        capture_output=True, text=True
    )
    s3_files = set()
    for line in result.stdout.strip().split(\"\n\"):
        parts = line.strip().split()
        if parts and not parts[-1].startswith(\"PRE\") and parts[-1] != \"0\":
            s3_files.add(parts[-1])

    match = \"\u2705\" if index_files == s3_files else \"\u274c\"
    print(f\"{match} [{alarm_type}] {code}: {name}\")

    all_files = sorted(index_files | s3_files)
    for f in all_files:
        in_idx = f in index_files
        in_s3 = f in s3_files
        if in_idx and in_s3:
            print(f\"     \u2022 {f}\")
        elif in_idx and not in_s3:
            print(f\"     \u2022 {f}  (solo en index, NO en S3)\")
        else:
            print(f\"     \u2022 {f}  (solo en S3, NO en index)\")
    print()
"'
}
# Auto-source shell config from stow packages
for conf in "$HOME/.config/zsh/conf.d/"*.zsh(N); do
  source "$conf"
done

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

alias claude-mem='bun "/Users/illico/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
alias booky="python3 /Users/illico/annas/booky"


# TinyTeX (LaTeX local)
export PATH="$PATH:$HOME/Library/TinyTeX/bin/universal-darwin"

# peon-ping quick controls
alias peon="bash /Users/illico/.claude/hooks/peon-ping/peon.sh"
[ -f /Users/illico/.claude/hooks/peon-ping/completions.bash ] && source /Users/illico/.claude/hooks/peon-ping/completions.bash
