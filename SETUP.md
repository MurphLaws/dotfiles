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

## 1. Instalar (un solo comando)

```
git clone https://github.com/MurphLaws/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

Luego cierra Ghostty con Cmd+Q y ábrelo de nuevo. `bootstrap.sh` se puede
repetir sin riesgo. Hace lo que clonar solo no hace:

- Instala todo el `Brewfile`, incluida la JetBrains Mono Nerd Font (sin
  ella Ghostty no tiene negrita ni itálica) y Ghostty.
- Clona powerlevel10k y zsh-autosuggestions (no se versionan).
- Copia `SlalomSymbols.ttf` a `~/Library/Fonts`.
- Respalda `~/Library/Application Support/com.mitchellh.ghostty/config`:
  Ghostty lo lee *después* de `~/.config/ghostty/config` y pisa tamaño,
  fuente y tema.
- Respalda (`*.bak-FECHA`) cualquier archivo real que choque y corre
  `stow` de todos los paquetes.

## 2. Manual (si no quieres el script)

`brew bundle --file ~/dotfiles/Brewfile`, luego
`stow zsh tmux nvim ghostty karabiner taskwarrior claude copilot`. Si un
paquete falla con "existing target", mueve ese archivo a `.bak` y repite.

## 3. Notas por paquete

- **zsh**: el `.zshrc` asume `eza` instalado (alias de `ls`).
- **ghostty**: arranca tmux automáticamente (`command =` al final del
  config) y fija la ventana en 191×47 celdas; ajusta si esa pantalla es
  más chica.
- **nvim**: al primer arranque, lazy.nvim instala los plugins solo.
- **fonts**: no se stowea; `bootstrap.sh` copia `SlalomSymbols` a
  `~/Library/Fonts`. La fuente principal viene del `Brewfile`.
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
  symlink a las skills del paquete `claude`, así que quedan disponibles en
  ambos agentes sin duplicar nada. Ojo: las skills
  que dependen de herramientas exclusivas de Claude Code (subagentes,
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

## 6. Cambios recientes (2026-09-25 a 2026-09-28)

Para el agente que configure otra máquina: esto es lo que cambió en estos
días y lo que implica. Después de `git pull`, vuelve a correr
`./bootstrap.sh` (es idempotente) y revisa cada punto.

- **bootstrap.sh + Brewfile** (`270f8d1`): antes clonar no bastaba. Ahora
  el script instala fuentes, Ghostty, zk y el resto, clona p10k y
  zsh-autosuggestions, respalda la config de Ghostty en Application Support
  y hace `stow`. `.zprofile` ya usa `$HOME` en vez de `/Users/illico`.
- **Ghostty**: ventana por defecto 191×47 (`6c745a8`); si la pantalla es
  más chica, bájalo en `ghostty/.config/ghostty/config`. La base de
  texto es `font-style = Bold`, así que sin JetBrains Mono Nerd Font
  instalada todo se ve distinto.
- **tmux** (`a843c5e`): `default-terminal` pasó de `screen-256color` a
  `tmux-256color` para tener itálicas reales dentro de tmux. Verifica con
  `infocmp tmux-256color`; si falla, falta el terminfo (`brew install
  ncurses` y reinicia tmux con `tmux kill-server`). El dashboard de ngrok
  se lanza con `TERM=screen-256color ngrok ...`.
- **nvim**: se ocultan las `~` de fin de buffer (`00f2f28`); notas
  markdown pulidas (`94fdb96`): blink solo usa lsp y path en markdown, el
  completado de `[[` lo da marksman, render-markdown muestra
  `[[nota#head]]` como "nota › head". zk-nvim (`4696845`): `<leader>zi`
  inserta link y `<CR>` sigue links. Requiere `zk` (Brewfile) y marksman
  (lo instala Mason al abrir nvim). El notebook vive en `~/zk`
  (`ZK_NOTEBOOK_DIR`, exportado en `.zshrc`) y **no está en este repo**:
  clónalo o créalo aparte.
- **zsh**: `ls`/`ll` son funciones con `eza`. `ls` es una cuadrícula limpia de
  nombres y, fuera de un repo, colorea las carpetas que son repos (verde =
  limpio, amarillo = con cambios); `ll` añade la vista detallada con rama y
  estado en columnas. `\ls` usa el ls original. Requiere `eza`.
- **Claude Code**: `settings.json` usa modelo `opus` (`0a3d638`); los
  hooks de peon-ping están activos y `peon-gate.sh`
  (`964619a`) respeta `headphones_only` usando el tipo de dispositivo de
  CoreAudio (funciona con macOS en español; necesita `jq`). claude-hud sin
  la línea personalizada (`c2e6574`). La skill `pdf-to-epub` se versiona
  (`67d8a3c`); sus dependencias de Python están en su
  `requirements.txt`. `skills/synced/` se ignora.
- **Copilot CLI** (`a4a1943`): paquete `copilot` que reutiliza
  instrucciones, skills y peon-ping de Claude (sección 4).

## 7. Si las configs no cambian

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
