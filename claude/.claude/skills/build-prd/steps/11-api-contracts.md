# Step 10 — Contratos de API (NUEVO, no estaba en el template original)

## Objetivo

Documentar los endpoints REST que la app necesita, derivados de las capacidades + acciones de las pantallas + estados de las entidades. Esta sección es **crítica para que Claude Code construya el backend sin preguntar**.

## Estrategia

**El usuario probablemente no va a redactar endpoints REST.** En lugar de hacerle escribir contratos, **propone tú una lista derivada** de:
- Las acciones del usuario en cada pantalla (step 07)
- Las transiciones de estado de las entidades (step 09)
- Las automatizaciones identificadas (step 05)

Luego pídele validación / correcciones.

## Preguntas

### P1 — Inferencia inicial (auto + validación)
A partir del estado capturado, **propón al usuario** una lista de endpoints organizados por capacidad. Formato propuesto:

```
Para C2 — Registro de cliente:
- POST /api/clientes — crear cliente
- GET /api/clientes/{id} — obtener cliente
- PATCH /api/clientes/{id} — editar cliente

Para C3 — Generación de cobro:
- POST /api/cobros — generar cobro nuevo
- GET /api/cobros?estado=pendiente — listar cobros pendientes
- POST /api/cobros/{id}/marcar-pagado — marcar pago recibido
```

Muéstrale al usuario y pregunta: "¿Falta algún endpoint? ¿Sobra alguno? ¿Cambiamos nombres?"

### Estrategia de validación cuando hay muchos endpoints

Si el conteo total supera 15 endpoints (típico en apps multi-rol con `actores.modo_multirol: true`), **valida por bloques de 5 a la vez** en lugar de uno por uno:

> Te muestro los 5 endpoints del rol Estudio. Dime si está bien todo el bloque o si hay correcciones específicas. Después pasamos a Promotor.

Esto reduce el costo cognitivo. Si el usuario aprueba un bloque sin correcciones, no profundices más en cada endpoint individual: marca todo el bloque como aprobado y avanza.

### P2 — Por cada endpoint, completar (libre, con sugerencias)
Para cada endpoint, **propón tú el contrato** y pídele validación:

```
POST /api/clientes
Request:
  { "nombre": string, "email": string, "telefono": string, "plan_id": uuid }
Response 201:
  { "id": uuid, "nombre": string, "email": string, "created_at": timestamp }
Response 400: validación de email
Response 409: email ya existe
```

Solo pedi validación si la inferencia tiene ambigüedad ("¿qué campos son obligatorios al crear cliente?").

### P3 — Webhooks y eventos asíncronos (libre, lista)
> ¿La app envía o recibe webhooks/eventos asíncronos? Por ejemplo: webhook de pasarela de pagos cuando se confirma un pago, evento de WhatsApp cuando el cliente responde, cron job que dispara cobros mensuales el día 1.

Captura como `api.webhooks: [{ direccion, endpoint, evento, payload }]` y `api.cron: [{ nombre, cuando, accion }]`.

### P4 — Errores estándar (auto-derivar)
Genera una tabla de códigos HTTP estándar que la API va a usar:

| Código | Cuándo se devuelve |
|---|---|
| 200 | OK — operación exitosa |
| 201 | Created — recurso creado |
| 204 | No Content — eliminación exitosa |
| 400 | Bad Request — validación falló (incluir detalle del campo) |
| 401 | Unauthorized — sin token o token inválido |
| 403 | Forbidden — token válido pero sin permiso |
| 404 | Not Found — recurso no existe |
| 409 | Conflict — violación de regla de unicidad |
| 422 | Unprocessable Entity — formato OK pero estado inválido (ej. cobro ya pagado) |
| 500 | Server Error — error interno |

## Output markdown

```markdown
## 10. Contratos de API

### Convenciones generales

- Base URL: `/api/v1`
- Autenticación: header `Authorization: Bearer <token>`
- Content-Type: `application/json`
- Formato de fechas: ISO 8601 (`2026-04-30T15:00:00Z`)
- IDs: UUID v4 en formato string

### Códigos de error estándar

{{tabla generada arriba}}

### Endpoints por capacidad

{{Por cada capacidad backend:}}
#### {{Cn — nombre}}

##### `{{METHOD}} {{path}}` — {{breve descripción}}

**Request:**
\`\`\`json
{{request body}}
\`\`\`

**Response (200/201):**
\`\`\`json
{{response body}}
\`\`\`

**Errores:**
- `400`: {{cuándo y por qué}}
- `404`: {{cuándo y por qué}}

**Validaciones:**
- {{lista de validaciones de input}}

---

### Webhooks

{{Por cada webhook entrante o saliente:}}
#### `{{nombre}}`
- **Dirección:** {{entrante / saliente}}
- **Endpoint:** {{path o URL}}
- **Trigger:** {{qué dispara el evento}}
- **Payload:** {{estructura}}

### Cron jobs / tareas programadas

{{Por cada cron:}}
- **{{nombre}}:** se ejecuta {{cuando}} y hace {{accion}}.
```
