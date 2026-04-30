# Step 04 — Usuarios y Actores Clave

## Objetivo

Identificar al actor principal, los actores secundarios y los sistemas externos que interactúan con la app. Cada actor humano debe tener 6 atributos.

## Preguntas

### P1 — Actor principal (libre)
> ¿Quién es el usuario principal? Dame nombre o cargo, y luego cuéntame sobre él/ella siguiendo este patrón:
> - **Quién es**: rol, contexto, nivel digital
> - **Objetivo principal con la app**: qué quiere lograr
> - **Frustraciones actuales**: qué le duele hoy
> - **Motivación para adoptar la app**: por qué la usaría
> - **Contexto de uso**: dónde, cuándo, desde qué dispositivo

Si el usuario no estructura la respuesta, hazle las 5 sub-preguntas una a la vez.

Guarda como `actores.principal: { nombre, rol, quien_es, objetivo, frustraciones, motivacion, contexto_uso }`.

### P2 — Cantidad de actores secundarios (AskUserQuestion)
- Solo 1 actor secundario
- 2-3 actores secundarios
- 4-5 actores secundarios (típico para apps con múltiples roles)
- 6 o más actores secundarios

Guarda como `actores.cantidad_secundarios: number`.

### P3-Pn — Por cada actor secundario (libre, repetir)
Para cada uno, hazle las mismas 5 sub-preguntas que al principal:
> Hablemos del actor secundario #N. ¿Cuál es su rol? Y luego: ¿quién es?, ¿qué quiere lograr?, ¿qué le frustra hoy?, ¿desde dónde y cómo usaría la app?

Guarda como `actores.secundarios: [{ nombre, rol, quien_es, objetivo, frustraciones, contexto_uso }]`.

### P_final — Sistemas externos (libre, lista)
> ¿Qué sistemas externos interactúan con esta app? Por ejemplo: un ERP existente, una pasarela de pagos, WhatsApp Business, una API de mapas, un sistema de facturación. Para cada uno dime su rol.

Guarda como `actores.sistemas: [{ nombre, rol }]`.

## Nota crítica para apps multi-rol

Si el usuario menciona **3 o más actores humanos con dashboards distintos** (ej. Estudio + Promotor + Cliente + Admin), avísale explícitamente al final de la sección:

> Veo que tu app tiene varios roles con experiencias muy distintas. En el step 7 (Pantallas) y step 10 (API contracts) voy a tratar cada rol como un grupo separado para no mezclar pantallas, endpoints ni permisos. ¿Te parece?

Esto evita que el step 07 produzca un inventario de pantallas mezclado donde no se distingue qué rol ve qué. Marca en el estado: `actores.modo_multirol: true`.

## Output markdown

```markdown
## 3. Usuarios y Actores Clave

### Actor principal

#### {{nombre}} — {{rol}}
- **Quién es:** {{quien_es}}
- **Objetivo principal:** {{objetivo}}
- **Frustraciones actuales:** {{frustraciones}}
- **Motivación para adoptar:** {{motivacion}}
- **Contexto de uso:** {{contexto_uso}}

### Actores secundarios

{{Por cada actor secundario:}}
#### {{rol}}
- **Quién es:** {{quien_es}}
- **Objetivo principal:** {{objetivo}}
- **Frustraciones actuales:** {{frustraciones}}
- **Contexto de uso:** {{contexto_uso}}

### Sistemas externos (actores sistema)

{{Por cada sistema:}}
#### {{nombre}}
- **Rol:** {{rol}}
```

Sigue exactamente la estructura del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 67-102).
