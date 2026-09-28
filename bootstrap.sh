#!/usr/bin/env bash
# Deja esta Mac con la misma config que el repo. Se puede correr las veces que quieras.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
PACKAGES=(zsh tmux nvim ghostty karabiner taskwarrior claude copilot)

say() { printf '\n==> %s\n' "$*"; }
backup() { echo "    respaldo: $1 -> $1.bak-$STAMP"; mv "$1" "$1.bak-$STAMP"; }

say "Homebrew"
if ! command -v brew >/dev/null && [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
# No aborta si algo ya estaba instalado a mano (p. ej. Ghostty.app sin brew).
brew bundle --file="$DOTFILES/Brewfile" || echo "    aviso: brew bundle tuvo fallos; revisa arriba"

say "Tema y plugins de zsh (no se versionan)"
clone() { [ -d "$2" ] || git clone --depth=1 "$1" "$2"; }
clone https://github.com/romkatv/powerlevel10k.git "$DOTFILES/zsh/.zsh/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions.git "$DOTFILES/zsh/.zsh/plugins/zsh-autosuggestions"

say "Fuente SlalomSymbols"
mkdir -p "$HOME/Library/Fonts"
cp -f "$DOTFILES/fonts/slalom/SlalomSymbols.ttf" "$HOME/Library/Fonts/"

say "Ghostty: quitar config de Application Support (pisa a ~/.config/ghostty)"
GHOSTTY_MAC="$HOME/Library/Application Support/com.mitchellh.ghostty"
for f in "$GHOSTTY_MAC/config" "$GHOSTTY_MAC/config.ghostty"; do
  [ -f "$f" ] && backup "$f"
done

say "Respaldar archivos reales que chocan con los symlinks"
for app in nvim ghostty karabiner; do
  t="$HOME/.config/$app"
  [ -d "$t" ] && [ ! -L "$t" ] && backup "$t"
done
for pkg in "${PACKAGES[@]}"; do
  (cd "$DOTFILES/$pkg" && find . \( -type f -o -type l \) -not -path '*/.git/*' | sed 's|^\./||') |
    while read -r rel; do
      t="$HOME/$rel"
      [ -e "$t" ] && [ ! -L "$t" ] || continue
      # Ya enlazado vía un directorio padre symlinkeado: es el archivo del repo.
      [ "$(cd "$(dirname "$t")" && pwd -P)" = "$(cd "$DOTFILES/$pkg/$(dirname "$rel")" && pwd -P)" ] && continue
      backup "$t"
    done
done

say "Enlazar con stow"
mkdir -p "$HOME/.config"
cd "$DOTFILES"
stow --restow "${PACKAGES[@]}"

if [ "$HOME" != "/Users/illico" ]; then
  say "Aviso: tu usuario no es illico; revisa rutas absolutas en claude/.claude/settings.json"
fi

say "Listo. Cierra Ghostty por completo (Cmd+Q) y ábrelo de nuevo."
