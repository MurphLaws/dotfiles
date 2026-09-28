# Configurar estos dotfiles en otra máquina

Instrucciones manuales, sin scripts. Pensado para macOS con Homebrew.
Funciona igual si en esa máquina usas GitHub Copilot CLI en vez de Claude
Code: el paquete `copilot` reutiliza las mismas skills, instrucciones y
sonidos (ver la sección de Copilot).

> **Importante:** varias rutas del repo asumen que el usuario se llama
> `illico` y que el repo vive en `~/dotfiles` (por ejemplo los hooks de
> `claude/.claude/settings.json` usan rutas absolutas `/Users/illico/...`).
> Si el usuario de la otra máquina es distinto, busca y reemplaza
> `/Users/illico` por tu `$HOME` real después de clonar:
> `grep -rl "/Users/illico" ~/dotfiles` te dice qué archivos tocar.

## 1. Requisitos

```
brew install stow git neovim tmux jq eza
brew install --cask ghostty karabiner-elements font-jetbrains-mono-nerd-font
```

Opcionales según lo que uses en esa máquina: `taskwarrior`, `zk`.

## 2. Clonar y enlazar

```
git clone https://github.com/MurphLaws/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh tmux nvim ghostty fonts karabiner taskwarrior claude copilot
```

Stow crea symlinks desde `$HOME` hacia el repo. Si un paquete falla por
conflicto ("existing target"), es que ya hay un archivo real en esa ruta:
muévelo (`mv ~/.config/nvim ~/.config/nvim.bak`) y repite el `stow` de ese
paquete. Enlaza solo los paquetes que apliquen: si la máquina no tiene
Claude Code, omite `claude`… salvo que quieras peon-ping (ver abajo, el
adaptador vive dentro del paquete `claude`).

## 3. Notas por paquete

- **zsh**: el `.zshrc` asume `eza` instalado (alias de `ls`).
- **ghostty**: arranca tmux automáticamente (`command =` al final del
  config) y fija la ventana en 191×47 celdas; ajusta si esa pantalla es
  más chica.
- **nvim**: al primer arranque, lazy.nvim instala los plugins solo.
- **fonts**: contiene `SlalomSymbols` (glyph propio); la fuente principal
  es JetBrains Mono Nerd Font del cask de arriba.
- **claude**: settings, hooks, skills y `CLAUDE.md` de Claude Code.
  Recuerda el reemplazo de `/Users/illico` si aplica.

## 4. Réplica en GitHub Copilot CLI

El paquete `copilot` ya deja todo enlazado; no hay que copiar nada a mano.
Cómo funciona cada pieza:

- **Comportamiento (instrucciones globales)**:
  `~/.copilot/copilot-instructions.md` es un symlink al `CLAUDE.md` global
  del paquete `claude`. Copilot lo lee como instrucciones de usuario, así
  que el comportamiento (español neutro, modo consulta de Godot, etc.) es
  el mismo. Referencia: [Add custom instructions — GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions).

- **Skills**: Copilot CLI usa el mismo formato `SKILL.md` que Claude Code
  y busca skills personales en `~/.copilot/skills`. Ese directorio es un
  symlink a las skills del paquete `claude`, así que las ~136 skills
  quedan disponibles en ambos agentes sin duplicar nada. Ojo: las skills
  que dependen de herramientas exclusivas de Claude Code (subagentes GSD,
  artifacts, MCP concretos) funcionarán parcialmente o no funcionarán en
  Copilot; las de puro texto/instrucciones (clean, build-prd,
  human-writing, humanizar-es, job-finder, pdf-to-epub…) funcionan igual.
  Referencia: [Add agent skills — GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills).

- **Sonidos peon-ping**: se instalan aparte porque los packs de audio no
  van en git:

  ```
  brew tap peonping/tap
  brew install peon-ping
  peon-ping-setup
  ```

  El setup descarga los packs a `~/.openpeon` e instala el runtime en
  `~/.claude/hooks/peon-ping` (por eso conviene stowear también `claude`
  aunque la máquina use Copilot: aporta el `config.json` versionado con
  tu configuración de packs y volumen). El enganche con Copilot ya está
  en el repo: `~/.copilot/hooks/peon-ping.json` traduce los eventos de
  Copilot (sessionStart, userPromptSubmitted, postToolUse, errorOccurred,
  sessionEnd) al adaptador oficial `adapters/copilot.sh` que trae
  peon-ping. Si las versiones nuevas de `peon-ping-setup` detectan
  Copilot solas, este archivo simplemente queda redundante, no estorba.
  Referencia: [Use hooks — GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks).

## 5. Verificar

- `nvim` abre con tema onedark darker y sin errores de plugins.
- `tmux` muestra la barra con iconos (si ves cuadrados, falta la Nerd Font).
- En Copilot CLI: pregunta algo en español y debe responder en español
  neutro; `/skills` (o pedir una skill por nombre, p. ej. "clean") debe
  encontrarlas; al enviar un prompt debe sonar el peon.

## 6. Si las configs no cambian

Clonar no basta: sin `stow` no hay symlinks y todo se ve igual.

- Confirma que son symlinks y no archivos reales:
  `ls -la ~/.zshrc ~/.config/nvim ~/.config/ghostty` debe mostrar
  `-> .../dotfiles/...`. Si ves un archivo o directorio normal, había un
  conflicto: muévelo a `.bak` y repite el `stow` de ese paquete.
- `stow -nv <paquete>` simula el enlace y muestra qué haría o qué choca.
- Powerlevel10k lento o con cuadrados: falta la Nerd Font, o hay un
  `.zshrc`/`.p10k.zsh` viejo que no es el symlink del repo.
- Si el usuario no es `illico`: `grep -rl "/Users/illico" ~/dotfiles` y
  reemplaza por tu `$HOME`.
- Abre una terminal nueva (o reinicia Ghostty) después de enlazar.
