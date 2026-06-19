# Engram Cloud — carga de secretos locales (fuera del repo) + atajos.
# Los secretos viven en ~/.config/engram/cloud.env (chmod 600, NO versionado).
[ -f "$HOME/.config/engram/cloud.env" ] && source "$HOME/.config/engram/cloud.env"

# `engram web` abre el dashboard de Engram Cloud en el navegador por defecto.
# Cualquier otro subcomando se delega al binario real de engram.
engram() {
  if [[ "$1" == "web" ]]; then
    local url="${ENGRAM_CLOUD_SERVER%/}"
    if [[ -z "$url" ]]; then
      print -u2 "engram web: ENGRAM_CLOUD_SERVER no está definido (revisa ~/.config/engram/cloud.env)"
      return 1
    fi
    command open "$url/dashboard"
    return
  fi
  command engram "$@"
}
