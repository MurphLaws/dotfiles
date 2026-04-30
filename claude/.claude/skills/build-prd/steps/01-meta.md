# Step 01 — Frontmatter / Meta del proyecto

## Objetivo

Capturar el resto del frontmatter YAML que va al inicio del PRD.

## Preguntas

### P1 — Versión del PRD (libre, default `0.1`)
> ¿Qué versión es este PRD? Si es la primera, lo dejamos en `0.1`.

### P2 — Fecha (libre, default hoy)
> ¿Qué fecha quieres que aparezca en el PRD? Si quieres usar la de hoy, dime "hoy".

Si dice "hoy" o no responde, usa la fecha del entorno (`Today's date is YYYY-MM-DD`).

### P3 — Enfoque del PRD (libre)
> En una frase, ¿cuál es el enfoque principal del proyecto? Por ejemplo: "procesos, plataformas y automatización", "experiencia móvil del cliente final", "automatización de back-office contable".

### P4 — Subtítulo descriptivo (libre)
> Dame un subtítulo de una línea que describa qué es la app. Por ejemplo: "Centro de Control Operativo de Entregas", "Asistente Virtual de Cobros Recurrentes".

## Output markdown

Genera el frontmatter y el título principal:

```yaml
---
proyecto: {{meta.proyecto}}
version: {{meta.version}}
fecha: {{meta.fecha}}
tipo: {{meta.tipo}}
enfoque: {{meta.enfoque}}
empresa: {{meta.empresa}}
programa: {{meta.programa}}
confidencialidad: {{meta.confidencialidad}}
---

# PRD — {{meta.proyecto}}
## {{meta.subtitulo}}{{ · meta.empresa si existe}}
```

Después del frontmatter incluye `\n---\n` como separador.
