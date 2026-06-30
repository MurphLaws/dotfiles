# Global Instructions

## Idioma
- Cuando respondas en español, usa ÚNICAMENTE español neutro (latinoamericano estándar).
- PROHIBIDO el español rioplatense/argentino: no uses "vos", "tenés", "podés", "sos", "querés", "subí", "corré", "entrá", "creá", "dale", "acá", "laburo", voseo ni conjugaciones voseantes en imperativo ("mirá", "fijate", etc.).
- Usa "tú" (o "usted" si el contexto es formal): "tienes", "puedes", "eres", "quieres", "sube", "corre", "entra", "crea", "aquí".
- Esta regla aplica a todos los proyectos, sin excepción.

## Registro / tono
- PROHIBIDO anunciar tu propia honestidad, transparencia o franqueza. No uses: "seré honesto", "te seré honesto", "siendo honesto", "honestamente", "sin esconderme", "sin humo", "sin vueltas", "sin rodeos", "para ser claro/directo", "voy a ser directo", "el dato dice, no suposiciones", ni variantes. Anunciar que algo es honesto/directo implica que lo normal no lo es: es condescendiente.
- No hagas meta-comentario sobre cómo te estás comunicando. Da el hecho, el número o el hallazgo directamente.
- Asume que el lector es competente; no le aclares que "esta vez sí" eres sincero. (Relacionado: feedback de documentos "no tomes a tu lector por idiota".)

## Git Commits
- Never add Co-Authored-By lines to commit messages. Only the user is the author.
- Always commit changes after completing work, unless explicitly told not to.

## Comentarios CriticMarkup en archivos markdown
- En archivos `.md`/`.qmd` el usuario y su equipo dejan comentarios y sugerencias con sintaxis CriticMarkup:
  - `{>>comentario<<}` comentario al margen
  - `{==texto==}` resaltado
  - `{++añadir++}` sugerencia de inserción
  - `{--quitar--}` sugerencia de borrado
  - `{~~viejo~>nuevo~~}` sugerencia de reemplazo
- Los comentarios que empiezan con `@claude:` (p. ej. `{>>@claude: divide este bloque en dos<<}`) son TAREAS para ti: resuélvelas editando el documento y **borra la marca CriticMarkup** al terminar.
- Los comentarios que empiezan con `@<nombre>:` (cualquier otro nombre) son para esa persona: NO los toques ni los borres.
- Al aplicar una sugerencia `{++ ++}`/`{-- --}`/`{~~ ~>~~}` que apruebes, deja el texto final limpio (sin las marcas).

## GDScript — orden de declaración en una clase (evita warnings de gdlint)
El usuario usa `gdlint` (godot-gdscript-toolkit). El check `class-definitions-order` exige declarar los miembros de una clase en ESTE orden exacto. Respétalo SIEMPRE al escribir/editar `.gd`:

1. `@tool`, `@icon`, `@static_unload`
2. `class_name`
3. `extends`
4. Docstring de clase (`##`)
5. `signal`
6. `enum`
7. **`const`  ← las constantes van ANTES de los `@export`** (la causa típica del warning)
8. `static var`
9. `@export var`
10. Variables públicas normales (`var`)
11. Variables privadas (`var _x`)
12. `@onready var` públicas, luego `@onready var _x` privadas
13. `_static_init()` y métodos estáticos
14. Métodos virtuales del motor (`_init`, `_enter_tree`, `_ready`, `_process`, `_physics_process`, …)
15. Métodos sobrescritos, luego el resto de métodos
16. Subclases

Regla mnemotécnica: **propiedades y señales primero, métodos después; público antes que privado; `const` antes que `@export`.**

Otros checks de gdlint a tener en cuenta:
- `max-line-length`: límite por defecto **100 caracteres** por línea. Si una línea se pasa, o se parte (con `\`), o se sube el límite en un archivo de config (`gdlintrc`/`.gdlint.yml`) con `max-line-length: <n>`. Confirmar con el usuario qué prefiere antes de partir líneas (partir líneas = más líneas).
- Verificar el resultado ejecutando `gdlint Scripts/*.gd` cuando se editen scripts de Godot.

Fuentes: guía de estilo oficial de Godot (sección "Code order") y wiki del linter de godot-gdscript-toolkit (Scony).
