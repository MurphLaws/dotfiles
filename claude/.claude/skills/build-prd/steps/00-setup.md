# Step 00 — Setup

## Objetivo

Capturar la información mínima para arrancar la entrevista: nombre del proyecto, ruta de salida y modo de operación.

## Preguntas

### P1 — Nombre del proyecto (libre)
> ¿Cuál es el nombre del proyecto o app que vamos a documentar?

Acepta nombres con espacios. Guarda como `meta.proyecto`. Genera también `meta.slug` en kebab-case lowercase (ej. "Mensualista" → `mensualista`, "Logistics Ops Hub" → `logistics-ops-hub`).

### P2 — Ruta de salida (libre, con default)
> ¿Dónde quieres que guarde el PRD final? Puedo guardarlo en el directorio actual (`<cwd>`) con el nombre `PRD_<slug>_v0.1.md`, o puedes darme una ruta específica.

Si el usuario dice "el directorio actual" o no responde con ruta, usa `<cwd>/PRD_<slug>_v0.1.md`. Guarda como `ruta_salida`.

### P3 — Tipo de proyecto (AskUserQuestion)
- MVP — primera versión funcional para validar
- POC — prueba de concepto, no busca usuarios reales aún
- Producto v1 — primera versión de producción
- Iteración mayor — agrega capacidades a un producto existente

Guarda como `meta.tipo`.

### P4 — Empresa / organización (libre, opcional)
> ¿En qué empresa u organización se enmarca este proyecto? (puedes responder "personal" o "n/a" si no aplica)

Guarda como `meta.empresa`.

### P5 — Programa o iniciativa (libre, opcional)
> ¿Es parte de algún programa, hackathon, iniciativa o cohorte específica? (ej. "DiscordobAI 2026", "Innovaitors 2026", o "ninguno")

Guarda como `meta.programa`. Si dice "ninguno" guarda `null`.

### P6 — Confidencialidad (AskUserQuestion)
- Uso interno
- Confidencial
- Público
- Restringido

Guarda como `meta.confidencialidad`.

## Acción tras P1-P6

1. Inicializa `.build-prd-state.json` en el directorio del cwd con la estructura del schema.
2. Setea `step_actual: 1`.
3. Avanza al step 01.
