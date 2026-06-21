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
