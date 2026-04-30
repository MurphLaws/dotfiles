# Step 06 — Funcionalidades y Capacidades

## Objetivo

Capturar todas las capacidades (C1, C2, …, Cn) del MVP. Cada capacidad necesita: descripción funcional, caso de uso, criterios de aceptación, información que gestiona (input/output), tipo (manual/automatizado/híbrido) y prioridad (Must/Should/Could). **Esta es la sección más importante para que Claude Code pueda construir la app.**

## Preguntas

### P1 — Listado de capacidades (libre, lista)
Antes de profundizar en cada una, primero levanta el inventario:
> Voy a hacer una lista numerada de todas las capacidades de la app. Dame los nombres cortos (3-6 palabras cada uno) de las funcionalidades principales del MVP. Por ejemplo: "Registro de cliente", "Generación de cobro mensual", "Notificación al cliente por WhatsApp", "Dashboard de pagos pendientes".

Apunta a 5-10 capacidades. Guarda como `capacidades: [{ id, nombre, ...campos por completar }]` con IDs `C1, C2, ...`.

### P2-Pn — Por cada capacidad, profundizar (libre)
Para cada capacidad de la lista, haz estas 6 sub-preguntas en orden, una a la vez:

#### P2.1 — Descripción funcional
> {{Cn — nombre}}: Descríbeme en 2-3 líneas qué hace exactamente esta capacidad. No el "para qué", sino el "qué". Ejemplo: "Permite al cliente registrarse con email y teléfono, validar email por código de 6 dígitos, y completar perfil con datos de pago."

#### P2.2 — Caso de uso típico
> Llévame por un caso de uso típico, paso a paso. Quién la dispara, qué hace, qué pasa después. 4-7 pasos.

#### P2.3 — Criterios de aceptación (lista, 4-7 items)
> Dame 4-7 criterios de aceptación medibles. Cada uno debe ser verificable como "sí/no". Ejemplos:
> - "Al menos el 80% de los emails se validan en menos de 2 minutos."
> - "El formulario rechaza emails con formato inválido y muestra mensaje claro."
> - "Los datos se guardan en la base de datos al confirmar el formulario."

Si el usuario da criterios vagos ("debe funcionar bien"), repregunta con: "¿Cómo sabemos que está funcionando bien? ¿Qué medirías?".

#### P2.4 — Información que gestiona (input → output)
> ¿Qué información entra y qué información sale? Ejemplo: "Entrada: nombre, email, teléfono, tipo de plan. Salida: ID de cliente, token de sesión, fecha de creación."

#### P2.5 — Tipo (AskUserQuestion)
- Manual (humano hace todos los pasos)
- Automatizado (sistema hace todo, sin intervención)
- Híbrido (mezcla — humano dispara, sistema procesa, humano confirma)

#### P2.6 — Prioridad (AskUserQuestion)
- Must-have (sin esto no hay MVP)
- Should-have (importante pero puede ir en Fase 2)
- Could-have (nice to have, fuera de MVP)

#### P2.7 — Edge cases y validaciones (libre, opcional)
> ¿Hay casos borde o validaciones específicas que la app deba manejar? Por ejemplo: "qué pasa si el cliente intenta registrarse dos veces", "qué pasa si la API externa no responde", "qué pasa si el archivo subido es muy grande".

Guarda como `capacidades[i].edge_cases: string[]`. Si no hay, deja `[]`.

## Output markdown

Por cada capacidad:

```markdown
### {{id}} — {{nombre}}

- **Descripción funcional:** {{descripcion}}
- **Caso de uso:** {{caso_uso en prosa, no lista}}
- **Criterios de aceptación:**
{{lista bullet de criterios_aceptacion, cada uno con "  - "}}
- **Información que gestiona:** entrada: {{input}}. Salida: {{output}}.
- **Tipo:** {{tipo}}.
- **Prioridad:** {{prioridad}}.
{{Si hay edge_cases:}}
- **Casos borde y validaciones:**
{{lista bullet de edge_cases}}

---
```

Encabezado de la sección:

```markdown
## 5. Funcionalidades y Capacidades
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 173-279).
