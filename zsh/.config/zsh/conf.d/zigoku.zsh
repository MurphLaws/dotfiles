# zigoku dentro de tmux no puede usar el protocolo de gráficos kitty
# (el binario no envuelve las secuencias en passthrough), así que las
# portadas caen al mosaico de half-blocks pixelado. Este wrapper lo
# lanza en una ventana nueva de Ghostty cuando estamos dentro de tmux.
zigoku() {
  if [[ -n "$TMUX" ]]; then
    open -na Ghostty --args -e "$HOME/.local/bin/zigoku" "$@"
  else
    "$HOME/.local/bin/zigoku" "$@"
  fi
}
