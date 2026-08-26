# clipvault: guardar valores que uso seguido (PIDs, ids, usuarios, codigos)
# en el Keychain de macOS y copiarlos al portapapeles por nombre.
#
#   cbset PID          -> pide el valor (oculto) y lo guarda
#   cb                 -> fzf sobre las llaves; la elegida va al portapapeles
#   cb PID             -> copia el valor de PID directo
#   cbls               -> lista las llaves guardadas
#   cbrm PID           -> borra la llave PID
#
# El valor vive cifrado en el Keychain. El portapapeles se limpia solo a los
# 30s (configurable con CLIPVAULT_CLEAR), pero solo si nadie copio otra cosa.
# Las llaves (no los valores) se guardan en un indice para poder listarlas y
# autocompletarlas. Los nombres de llave no son secretos.

CLIPVAULT_SERVICE="${CLIPVAULT_SERVICE:-clipvault}"
CLIPVAULT_INDEX="${CLIPVAULT_INDEX:-$HOME/.config/zsh/.clipvault-keys}"
CLIPVAULT_CLEAR="${CLIPVAULT_CLEAR:-30}"

_clipvault_index_add() {
  local key="$1"
  [[ -f "$CLIPVAULT_INDEX" ]] || : > "$CLIPVAULT_INDEX"
  grep -qxF -- "$key" "$CLIPVAULT_INDEX" || print -r -- "$key" >> "$CLIPVAULT_INDEX"
}

_clipvault_index_rm() {
  local key="$1"
  [[ -f "$CLIPVAULT_INDEX" ]] || return 0
  grep -vxF -- "$key" "$CLIPVAULT_INDEX" > "$CLIPVAULT_INDEX.tmp" 2>/dev/null
  mv "$CLIPVAULT_INDEX.tmp" "$CLIPVAULT_INDEX"
}

cbset() {
  local key="$1" val
  if [[ -z "$key" ]]; then
    print -u2 "uso: cbset <llave>"
    return 2
  fi
  printf 'valor para "%s" (oculto): ' "$key" >&2
  read -rs val
  printf '\n' >&2
  if [[ -z "$val" ]]; then
    print -u2 "cancelado: valor vacio"
    return 1
  fi
  # -U actualiza si ya existe
  if security add-generic-password -U -s "$CLIPVAULT_SERVICE" -a "$key" -w "$val" 2>/dev/null; then
    _clipvault_index_add "$key"
    print -u2 "guardado: $key"
  else
    print -u2 "error al guardar en el Keychain"
    return 1
  fi
}

cb() {
  local key="$1" val
  if [[ -z "$key" ]]; then
    if [[ ! -s "$CLIPVAULT_INDEX" ]]; then
      print -u2 "no hay llaves. usa: cbset <llave>"
      return 1
    fi
    key=$(sort "$CLIPVAULT_INDEX" | fzf --prompt='clipvault> ' --height=40% --reverse) || return 1
  fi
  [[ -z "$key" ]] && return 1
  val=$(security find-generic-password -s "$CLIPVAULT_SERVICE" -a "$key" -w 2>/dev/null)
  if [[ $? -ne 0 || -z "$val" ]]; then
    print -u2 "no encontrado: $key"
    return 1
  fi
  printf '%s' "$val" | pbcopy
  print -u2 "copiado: $key (se limpia en ${CLIPVAULT_CLEAR}s)"
  if [[ "$CLIPVAULT_CLEAR" == <-> && "$CLIPVAULT_CLEAR" -gt 0 ]]; then
    ( sleep "$CLIPVAULT_CLEAR"; [[ "$(pbpaste)" == "$val" ]] && printf '' | pbcopy ) &!
  fi
}

cbls() {
  if [[ -s "$CLIPVAULT_INDEX" ]]; then
    sort "$CLIPVAULT_INDEX"
  else
    print -u2 "no hay llaves. usa: cbset <llave>"
    return 1
  fi
}

cbrm() {
  local key="$1"
  if [[ -z "$key" ]]; then
    print -u2 "uso: cbrm <llave>"
    return 2
  fi
  security delete-generic-password -s "$CLIPVAULT_SERVICE" -a "$key" >/dev/null 2>&1
  _clipvault_index_rm "$key"
  print -u2 "borrado: $key"
}

# autocompletar llaves para cb y cbrm
_clipvault_keys() { reply=(${(f)"$(cat "$CLIPVAULT_INDEX" 2>/dev/null)"}) }
compctl -K _clipvault_keys cb cbrm
