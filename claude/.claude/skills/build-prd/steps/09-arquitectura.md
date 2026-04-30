# Step 08 — Arquitectura de Solución (Alto Nivel)

## Objetivo

Capturar el stack técnico, los componentes del sistema, y generar diagramas mermaid de componentes y flujo de datos.

## Preguntas

### P1 — Stack preferido (AskUserQuestion)
- Web full-stack moderno (Next.js + Postgres + Tailwind)
- React SPA + API REST (Vite + Express + Postgres)
- PWA mobile-first (React PWA + Firebase + Firestore)
- No tengo preferencia — recomiéndame uno

Si elige "no tengo preferencia", recomienda según el contexto: si la app necesita offline + móvil → PWA + Firebase; si es admin tool → Next.js; si es API + web → Vite + Express.

Guarda como `arquitectura.stack: { frontend, backend, db, hosting }`.

### P2 — Componentes adicionales (libre, lista)
> Además del stack base, ¿hay componentes externos que necesites? Por ejemplo: pasarela de pagos (Stripe, MercadoPago), mensajería (WhatsApp Twilio, Email SendGrid), almacenamiento de archivos (S3, Cloudinary), maps (Google Maps), analytics, autenticación de terceros (Auth0, Clerk).

Captura como `arquitectura.componentes_externos: [{ nombre, proposito }]`.

### P3 — Integración con sistemas existentes (libre)
> ¿Necesita integrarse con algún sistema interno existente (ERP, CRM, base de datos legacy)? Si sí, ¿cómo: API, exportación CSV manual, webhook, base de datos compartida?

Guarda como `arquitectura.integraciones: [{ sistema, modo }]`.

### P4 — Autenticación y autorización (AskUserQuestion)
- Email + password (autenticación local)
- Google / GitHub OAuth (sin password)
- Magic link (email con código)
- Sin auth (la app no requiere login)

Si la app tiene roles distintos (visto en step 04 actores), agrega: "Vamos a tener roles `<roles>`".

Guarda como `arquitectura.auth: { metodo, roles: [] }`.

## Generación auto

### Tabla de componentes

A partir de capacidades + stack + componentes externos + integraciones:

```markdown
| Componente | Plataforma | Propósito |
|---|---|---|
| Frontend | {{stack.frontend}} | UI de usuario |
| Backend / API | {{stack.backend}} | Lógica de negocio + endpoints |
| Base de datos | {{stack.db}} | Persistencia de datos |
| Auth | {{auth.metodo}} | Autenticación de usuarios |
{{filas por cada componente externo}}
{{filas por cada integración}}
```

### Diagrama de componentes (mermaid)

A partir de los componentes y los actores (step 04), genera un `graph TB` con `subgraph` agrupando por capa (Frontend / Backend / Datos / Externos) y aristas mostrando flujo de datos.

### Diagrama de flujo de datos (mermaid)

Genera un `flowchart LR` mostrando cómo viajan los datos entre componentes durante la operación principal (ejemplo: usuario → API → DB → respuesta + notificación externa).

## Output markdown

```markdown
## 8. Arquitectura de Solución (Alto Nivel)

### Stack y plataformas

| Componente | Plataforma | Propósito |
|---|---|---|
{{tabla}}

### Diagrama de componentes

\`\`\`mermaid
graph TB
{{generado}}
\`\`\`

### Flujo de datos entre componentes

\`\`\`mermaid
flowchart LR
{{generado}}
\`\`\`
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 283-377).
