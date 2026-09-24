#!/bin/sh
# Hook on-launch: antes de cada comando task, limpia los vínculos zknote
# cuyo archivo ya no existe en ~/zk, así el icono desaparece solo al borrar
# una nota. TASKNOTE_GC evita la recursión (las llamadas a task que hace
# tasknote heredan la variable y este hook sale de inmediato).
[ -n "$TASKNOTE_GC" ] && exit 0
TASKNOTE_GC=1 /Users/nicolaslasso/.local/bin/tasknote >/dev/null 2>&1
exit 0
