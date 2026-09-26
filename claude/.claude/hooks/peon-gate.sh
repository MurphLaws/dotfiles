#!/bin/bash
# Filtro previo a peon-ping para respetar headphones_only en cualquier Mac.
# peon-ping detecta los altavoces buscando "speaker" en el nombre del
# dispositivo, lo que falla con macOS en otros idiomas ("Altavoces del
# MacBook Air"). Aquí se usa el tipo de transporte de CoreAudio, que no
# depende del idioma ni del modelo.

PEON_DIR="$HOME/.claude/hooks/peon-ping"

on_builtin_speakers() {
  system_profiler SPAudioDataType -json 2>/dev/null | jq -e '
    [.SPAudioDataType[]._items[]? | select(.coreaudio_default_audio_output_device == "spaudio_yes")][0]
    | .coreaudio_device_transport == "coreaudio_device_type_builtin"
      and ((._name // "") | test("headphone|auriculares|casque|kopfh"; "i") | not)
  ' >/dev/null
}

headphones_only=$(jq -r '.headphones_only // false' "$PEON_DIR/config.json" 2>/dev/null)

if [ "$headphones_only" = "true" ] && on_builtin_speakers; then
  cat >/dev/null  # consumir el JSON del hook y salir sin sonido
  exit 0
fi

exec "$PEON_DIR/peon.sh"
