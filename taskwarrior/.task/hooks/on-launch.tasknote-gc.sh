#!/bin/sh
# Hook on-launch: antes de cada comando task, limpia el UDA note de las
# tareas cuya nota norg (~/notes/task-<slug>.norg) ya no existe, así el
# icono 󱗖 desaparece solo al borrar una nota a mano. TASKNOTE_GC evita la
# recursión (las llamadas a task de aquí heredan la variable y salen ya).
[ -n "$TASKNOTE_GC" ] && exit 0
export TASKNOTE_GC=1

task rc.verbose=nothing rc.hooks=off note.any: export 2>/dev/null | python3 -c '
import json, os, re, subprocess, sys, unicodedata

def slug(s):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")

try:
    tasks = json.load(sys.stdin)
except Exception:
    sys.exit(0)
notes = os.path.expanduser("~/notes")
for t in tasks:
    path = os.path.join(notes, "task-%s.norg" % (slug(t.get("description", "")) or "sin-titulo"))
    if not os.path.exists(path):
        subprocess.run(
            ["task", "rc.confirmation=off", "rc.verbose=nothing", "rc.hooks=off",
             t["uuid"], "modify", "note:"],
            capture_output=True,
        )
' >/dev/null 2>&1
exit 0
