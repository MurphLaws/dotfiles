#!/bin/bash
# Restauración completa de dotfiles en un Mac nuevo. Idempotente: se puede
# re-ejecutar sin romper nada. Uso:
#   git clone https://github.com/MurphLaws/dotfiles ~/dotfiles && ~/dotfiles/install.sh
# Flags:
#   --no-forks   salta la compilación de los forks TUI (myx, spotify_player)
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BUILD_FORKS=1
[[ "${1:-}" == "--no-forks" ]] && BUILD_FORKS=0

STOW_PKGS=(nvim ghostty tmux zsh taskwarrior timewarrior claude zellij htop fish mpv git spotify-player myx graphview)

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# 1. Homebrew + paquetes del Brewfile
if ! command -v brew >/dev/null; then
  step "Instalando Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
step "Instalando paquetes del Brewfile"
# brew bundle no muestra progreso (baja todo en paralelo y queda mudo varios
# minutos), así que instalamos uno por uno con barra [n/total].
grep -E '^tap ' "$DOTFILES/Brewfile" | cut -d'"' -f2 | while read -r t; do brew tap "$t"; done
FORMULAE=($(grep -E '^brew ' "$DOTFILES/Brewfile" | cut -d'"' -f2))
CASKS=($(grep -E '^cask ' "$DOTFILES/Brewfile" | cut -d'"' -f2))
INSTALLED_F="$(brew list --formula -1 2>/dev/null)"
INSTALLED_C="$(brew list --cask -1 2>/dev/null)"
TOTAL=$(( ${#FORMULAE[@]} + ${#CASKS[@]} )); N=0; FAILED=""
progress() {  # progress <n> <total> <nombre>
  local pct=$(( $1 * 100 / $2 )) w=30
  local filled=$(( pct * w / 100 ))
  printf '\r\033[K[%-*s] %3d%% (%d/%d) %s' "$w" "$(printf '#%.0s' $(seq 1 $((filled==0?1:filled))))" "$pct" "$1" "$2" "$3"
}
for f in "${FORMULAE[@]}"; do
  N=$((N+1)); progress "$N" "$TOTAL" "$f"
  grep -qx "${f##*/}" <<<"$INSTALLED_F" && continue
  brew install --quiet "$f" >/dev/null 2>&1 || FAILED="$FAILED $f"
done
for c in "${CASKS[@]}"; do
  N=$((N+1)); progress "$N" "$TOTAL" "$c"
  grep -qx "$c" <<<"$INSTALLED_C" && continue
  brew install --cask --quiet "$c" >/dev/null 2>&1 || FAILED="$FAILED cask:$c"
done
printf '\r\033[K'
if [[ -n "$FAILED" ]]; then
  printf '\033[1;31mFallaron:\033[0m%s\n' "$FAILED"
  printf 'Reintenta con: brew bundle --file=%s/Brewfile\n' "$DOTFILES"
fi

# 2. Oh My Zsh + Powerlevel10k
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  step "Instalando Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
P10K_DIR="${ZSH:-$HOME/.oh-my-zsh}/custom/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  step "Instalando Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# 3. Stow: quitar los archivos que crean los instaladores y enlazar todo
step "Enlazando config con stow"
[[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && rm -f "$HOME/.zshrc"
cd "$DOTFILES"
stow --restow "${STOW_PKGS[@]}"

# 4. tmux plugin manager (dentro de tmux: prefix+I para instalar plugins)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  step "Instalando tpm"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 5. Plantillas de secretos (solo si no existen; hay que rellenarlas a mano)
step "Plantillas de secretos"
mkdir -p "$HOME/.config/zsh/conf.d"
[[ -f "$HOME/.config/zsh/conf.d/secrets.zsh" ]] || cp "$DOTFILES/zsh/.config/zsh/conf.d/secrets.zsh.example" "$HOME/.config/zsh/conf.d/secrets.zsh"
[[ -f "$HOME/.config/myx/client_id" ]] || cp "$HOME/.config/myx/client_id.example" "$HOME/.config/myx/client_id"
[[ -f "$HOME/.config/spotify-player/app.toml" ]] || cp "$HOME/.config/spotify-player/app.toml.example" "$HOME/.config/spotify-player/app.toml"

# 6. Neovim: lazy.nvim instala todos los plugins
step "Sincronizando plugins de Neovim"
nvim --headless "+Lazy! sync" +qa || true

# 7. Wallpaper
step "Aplicando wallpaper"
osascript -e "tell application \"System Events\" to set picture of every desktop to \"$DOTFILES/wallpapers/wallpaper.jpg\""

# 8. Forks TUI parcheados (necesitan cargo; brew ya instaló rust)
if [[ $BUILD_FORKS -eq 1 ]] && command -v cargo >/dev/null; then
  mkdir -p "$HOME/.local/src" "$HOME/.local/bin"
  if [[ ! -x "$HOME/.local/bin/myx" ]]; then
    step "Compilando fork de myx"
    git clone https://github.com/HaseebKhalid1507/Myx "$HOME/.local/src/myx"
    (cd "$HOME/.local/src/myx" && git checkout 25fdc5d && git am "$DOTFILES"/forks/myx/*.patch \
      && cargo build --release && cp target/release/myx "$HOME/.local/bin/")
  fi
  if [[ ! -x "$HOME/.local/bin/spotify_player" ]]; then
    step "Compilando fork de spotify_player"
    git clone https://github.com/aome510/spotify-player "$HOME/.local/src/spotify-player"
    (cd "$HOME/.local/src/spotify-player" && git checkout 9b81aaa && git apply "$DOTFILES"/forks/spotify-player/smart-shuffle.patch \
      && cargo build --release && cp target/release/spotify_player "$HOME/.local/bin/")
  fi
fi

step "Listo"
cat <<'EOF'
Pendientes manuales (secretos, no van al repo):
  - API keys:            $EDITOR ~/.config/zsh/conf.d/secrets.zsh
  - Spotify client_id:   $EDITOR ~/.config/myx/client_id ~/.config/spotify-player/app.toml
  - Plugins de tmux:     abrir tmux y presionar prefix+I
  - Estado de Claude:    rsync de ~/.claude/{projects,plugins,settings.local.json} desde el Mac viejo (ver README)
EOF
