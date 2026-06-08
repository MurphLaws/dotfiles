---
name: notion-workbook-builder
description: >
  Construye workbooks / entrenamientos en Notion con mínimos prompts, siguiendo el estilo de
  Nicolás (Innovaitors): secciones colapsables, ejercicios prácticos, banner e imágenes por
  sección, iconos personalizados y redacción profesional sin modismos. Actívala cuando el
  usuario diga: "crear un workbook", "armar/montar un workbook en Notion", "nuevo entrenamiento
  en Notion", "workbook de taller/clase", "/notion-workbook" o similar. La skill conecta y
  autentica el MCP de Notion, recoge tema/secciones/activos con pocas preguntas, pide icono,
  banner e imágenes por sección, y construye la página sección a sección. Sigue siempre la skill
  human-writing y el estilo de references/estilo-escritura.md.
metadata:
  version: 1.0.0
---

# Notion Workbook Builder

Monta un workbook de entrenamiento en Notion, en el estilo de Nicolás, con la menor cantidad de
prompts posible. Tú conduces; el usuario solo responde lo esencial y pega imágenes.

**Antes de empezar, lee los tres archivos de referencia y respétalos durante toda la sesión:**
- [references/estilo-escritura.md](references/estilo-escritura.md) — voz, tono y reglas anti-IA.
- [references/notion-nfm.md](references/notion-nfm.md) — sintaxis Notion-flavored-markdown y los
  **gotchas que rompen la página** (léelos: evitan borrar imágenes y romper toggles).
- [references/plantilla-workbook.md](references/plantilla-workbook.md) — el esqueleto de estructura.

Además, **activa la skill `human-writing`** y aplícala a todo el texto que redactes.

---

## Activos y supuestos por defecto (estilo Innovaitors)

- **Icono / marca de página:** el logo de **Innovaitors** ya está en `assets/innovaitors-icon.png`
  (462×187, sirve bien como cover/banner; para icono cuadrado, recórtalo o usa un emoji de marca).
  Ojo: la API de Notion **no sube archivos locales**; para usarlo como `icon`/`cover` necesitas una
  **URL pública** o que el usuario lo suba en la UI. Pregunta si prefiere otro icono para una página puntual.
- **API de práctica:** asume que **ya existe** una API de práctica como `taller-api-demo` y reúsala
  para los ejercicios del tipo "consume la API y construye un dashboard". No la reconstruyas cada vez.
  - Recursos: `contactos`, `tareas`, `ventas` (mismo patrón de slice; datos de ejemplo en memoria).
  - Desplegada en Railway · `GET /docs`, `GET /redoc`, `GET /health` · el root `/` redirige a ReDoc.
  - Repo: https://github.com/MurphLaws/taller-api-demo
  - URL típica: https://taller-api-demo-production.up.railway.app
  - Solo construye una API nueva (Fase 5) si el tema lo exige; si lo haces, sigue este mismo molde.
- **Scope de las tareas (tarea inter-sesión):** ver
  [references/scope-tareas.md](references/scope-tareas.md). Por defecto: construir, desde cero y de
  forma **autocontenida**, funcionalidades reales del proyecto del cliente, en un **repo nuevo con su
  `CLAUDE.md`** (front + back), que **funcione por sí solo** aparte de producción. **No menciones
  cantidades** (ni de usuarios ni de features): solo lista las funcionalidades.

---

## Fase 0 — Conectar Notion (MCP)

1. Comprueba si las herramientas de Notion están disponibles (busca `notion-search` / `notion-fetch`
   vía ToolSearch). Si no aparecen, el conector no está conectado.
2. Si no está conectado, pide al usuario que lo conecte:
   > Escribe `/mcp`, selecciona **"claude.ai Notion"** y completa la autorización en el navegador.
   No intentes autenticar tú: el flujo OAuth lo cierra el usuario.
3. Cuando confirme, valida con una llamada simple (`notion-search` de cualquier término) antes de seguir.
4. Lee el spec NFM una vez con `ReadMcpResourceTool` (server `claude_ai_Notion`, uri
   `notion://docs/enhanced-markdown-spec`) o revisa [references/notion-nfm.md](references/notion-nfm.md).

## Fase 1 — Recoger lo esencial (pocas preguntas, en lote)

Usa **una sola** llamada a AskUserQuestion (varias preguntas a la vez) para no fatigar. Pregunta:
- **Tema y título** del workbook, y la **audiencia** (técnica / mixta) y nivel.
- **Duración / formato** (p. ej. una sesión de N horas; charla + práctico).
- **Secciones** (los "Bloques"): pide el outline. Si el usuario no lo tiene, propónselo tú a partir
  del tema y confírmalo.
- **¿Hay parte práctica?** ¿Necesita una API/datos desplegados, un repo de práctica, o se trabaja
  sobre un repo real? (Si necesita una API de práctica, ver Fase 5.)
- Si el usuario tiene un **draft** (de un jefe, notas, PDF), pídelo y básate en él.

Si existe un workbook anterior de referencia en su Notion, ofrécete a leerlo (`notion-search` +
`notion-fetch`) para clonar su estética. Páginas grandes: lee en un subagente para no saturar contexto.

## Fase 2 — Activos visuales (icono, banner, imágenes por sección)

Avísale al usuario el patrón visual y pide los activos:
- **Icono de página:** un emoji, un custom emoji `:nombre:`, o una imagen. Pregúntale cuál quiere.
- **Banner / cover** y, sobre todo, el **patrón "imagen antes de cada fold"**: una imagen ancha al
  tope y **una imagen antes de cada sección colapsable** (Bloque).
- **Importante:** la API de Notion no sube archivos locales. Dos caminos:
  1. Si el usuario da **URLs públicas** de imagen, insértalas con `![](URL)` (y `cover`/`icon` en
     create/update-page).
  2. Si no, **construye la estructura dejando el espacio para cada imagen** y dile exactamente
     dónde pegarlas en la UI (antes de cada Bloque). En la práctica, el usuario suele subirlas él.
- Pide las imágenes **a medida que avanzas sección por sección**, no todas de golpe.

## Fase 3 — Crear la página base

Crea la página con `notion-create-pages` (sin parent = página de nivel superior, como el modelo):
- `properties.title`, `icon` (el que eligió).
- Contenido inicial: **párrafo de bienvenida + línea `**Objetivo:**`** (en prosa, no lista), y un
  **callout de metadatos** (Módulo · Duración · Modalidad · Stack/temario). Luego `---`.
- Guarda el `page_id` que devuelve. **A partir de aquí, NUNCA uses `replace_content`** si la página
  ya tiene imágenes del usuario (las borra). Ver gotchas.

## Fase 4 — Construir sección a sección

Para **cada** sección (Bloque), en orden:
1. Pide (o confirma) la **imagen** de esa sección y el contenido fuente.
2. Inserta, antes del encabezado de la sección, la imagen (`![](URL)`) si la tienes; si no, deja
   el marcador y anótalo para el usuario.
3. Crea la sección como **toggle de nivel superior**: `# <emoji> Bloque N — Título {toggle="true"}`.
   - Primera línea dentro: indicador de tipo en cursiva: `🛠️ **Práctico** · ...` para bloques con
     ejercicios, `💬 *Charla...*` para los teóricos. (Marca SIEMPRE qué bloques tienen ejercicios.)
   - Bloques teóricos (tipo "contexto/charla"): **prosa narrativa con hilo conductor**, no bullets
     sueltos. Datos clave dentro de un `<details>`.
   - Bloques prácticos: uno o más **ejercicios** con el patrón de la Fase 6.
4. **Verifica** con `notion-fetch` que la sección quedó bien (toggle cerrado, indentación, tablas)
   antes de pasar a la siguiente. Construir+verificar de a una sección reduce errores.

Cierra con una sección de **Cierre / tarea inter-sesión** y, si aplica, **lecturas con enlace** y
**videos embebidos** (`<video src="https://youtu...">`).

## Fase 5 — (Opcional) API/datos de práctica

Si el workbook necesita una API de práctica para ejercicios "consume datos y construye algo":
- Construye una API mínima (FastAPI suele ser la opción neutra y rápida) con 2–3 recursos en un
  patrón idéntico, datos de ejemplo en memoria, y `/docs` + `/redoc`.
- Despliégala (Railway: `railway init`, `railway up --detach`, `railway domain`). Verifica en vivo.
- Súbela a un repo público clonable si el ejercicio lo requiere.
- Pon la **URL en vivo y los endpoints dentro del ejercicio**.

## Fase 6 — Patrón de ejercicio (consistente)

Cada ejercicio es un `### <emoji> Ejercicio N.M: Título {toggle="true"}` con, en este orden:
- **Objetivo.** Qué se comprueba o se logra.
- **Contexto y preparación.** Qué necesita el participante y cómo montarlo (no asumir nada).
- **Procedimiento.** Pasos claros; los prompts a usar van en bloques de código.
- **Comparación / qué observar** (cuando aplique), en `<table>` o `<details>`.
- **> Pregunta de cierre** (quote) que abra reflexión, no que resuma.
- Conceptos teóricos en `<details><summary>📖 Conceptos clave</summary>`.
- Soluciones/plantillas en `<details><summary>📋 ...</summary>` con bloques de código.

Tono: profesional y técnico, **sin modismos**, con contexto suficiente para que se entienda y se
pueda evaluar rápido (prefiere tareas visibles y ejecutables sobre código que haya que leer).

## Fase 7 — Auto-auditoría antes de entregar

Releé el texto (sobre todo la prosa narrativa) y pásalo por el filtro de `human-writing`:
- ¿Hay antítesis por negación ("no es A, es B") repetida? Deja máximo una.
- ¿Guiones largos de tensión? Solo en atribuciones de cita.
- ¿Modismos / coloquialismos? Cámbialos por lenguaje técnico.
- ¿Cada párrafo conecta con el anterior? ¿La conclusión aporta algo nuevo?
- Español neutro latinoamericano, sin voseo.

Corrige antes de dar por terminado. Entrega la URL de la página al usuario.
