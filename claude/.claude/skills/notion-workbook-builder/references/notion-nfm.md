# Notion-flavored-markdown (NFM) + gotchas

Lee el spec completo una vez con `ReadMcpResourceTool` (server `claude_ai_Notion`, uri
`notion://docs/enhanced-markdown-spec`). Resumen operativo y los errores que rompen la página.

## Sintaxis que usamos
- **Encabezado colapsable (toggle):** `# Texto {toggle="true"}` / `## ...` / `### ...`. Los **hijos van
  indentados con TAB**, un tab más por nivel de anidación. Sin la indentación, el contenido NO queda dentro del toggle.
- **Toggle secundario:** `<details>` / `<summary>EMOJI Título</summary>` ... `</details>`. El cuerpo va
  un tab más adentro que `<details>`.
- **Callout:** `<callout icon="💡" color="yellow_bg">` ... `</callout>` (texto indentado dentro).
- **Tabla:** `<table fit-page-width="true" header-row="true">` con `<tr><td>`. Las celdas solo aceptan
  rich text (usa `**bold**`, no `<strong>`). Las etiquetas `<table>`/`</table>` van a la indentación del
  bloque; las filas `<tr>/<td>` van a flush-left (sin tabs).
- **Columnas:** `<columns><column>...</column><column>...</column></columns>`.
- **Bloque de código:** ```lang ... ```. El **fence** va a la indentación del bloque, pero el **contenido
  del código va flush-left** (sin tabs), para que no aparezcan tabs literales dentro del código.
- **Imagen:** `![](URL)` (URL pública). **Cover** e **icon** se pasan en create/update-page.
- **Video (YouTube):** `<video src="https://www.youtube.com/watch?v=ID"></video>` (URL completa, NO entre llaves).
- **Divider:** `---`. **Emojis:** Unicode estándar (🛠️ 💬 📖 📋 🔗 🧪). Custom: `:nombre:`.

## Patrón estructural del workbook
1. Título + icono (Innovaitors por defecto).
2. Párrafo de bienvenida + `**Objetivo:**` (prosa).
3. `<callout>` de metadatos (Módulo · Duración · Modalidad · temario).
4. `---`
5. Toggles de nivel superior para Pre-requisitos / Agenda / Objetivos (o lo que aplique).
6. **Imagen ancha antes de CADA Bloque** (patrón "imagen antes de fold"), y `# Bloque N — ... {toggle="true"}`.
   - Primera línea del bloque: indicador `🛠️ **Práctico** · ...` o `💬 *Charla...*`.
7. Ejercicios como `### 🛠️ Ejercicio N.M: ... {toggle="true"}` (ver patrón en estilo-escritura.md).
8. Cierre + tarea + lecturas + videos.

## GOTCHAS (críticos — léelos)
- **`replace_content` BORRA las imágenes** (y todo lo que no esté en el nuevo texto). En cuanto la página
  tenga banner o imágenes del usuario, **NUNCA uses `replace_content`**: usa solo `update_content`
  (search/replace puntual) o `insert_content`.
- **Editar la línea de un encabezado-toggle con `update_content`:** funciona y **preserva el toggle solo si
  incluyes la línea COMPLETA con `{toggle="true"}`** en `old_str` y `new_str`. Si editas solo el texto
  interno del encabezado (sin el `{toggle}` en el span), Notion **pierde el toggle y desanida los hijos**.
- **Insertar** un encabezado-toggle nuevo (dentro de un `new_str` o vía `insert_content`) **sí** lo crea
  como toggle. Para renumerar/insertar ejercicios, edita la línea completa o inserta tras una línea estable
  (no-encabezado), como la línea de modalidad del bloque.
- **Auto-enlace:** cualquier cosa que parezca dominio (`CLAUDE.md`, `DOCS.md`, `archivo.md`) se convierte en
  enlace `http://...`. **Envuélvelo en backticks** (código inline) para evitarlo, también en encabezados.
- **Bold + código adyacente** (`**texto `code`**`) puede serializarse con `****` extra; no rompe el render,
  pero si molesta, no pongas el código dentro del bold.
- **Verifica con `notion-fetch` después de cada cambio estructural** (toggles, inserciones, renumeraciones):
  `update_content` no avisa si un `old_str` no coincidió (queda no-op silencioso).
- **Concurrencia:** el usuario suele editar en la UI (título, iconos, etiquetas). Antes de un cambio grande,
  vuelve a hacer `notion-fetch` para anclar sobre el texto actual real.
- **Páginas grandes** (>200k chars): el `fetch` se guarda a archivo; léelo por tramos o en un subagente.
