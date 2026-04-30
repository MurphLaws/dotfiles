# Step 11 — Interacciones y Puntos de Contacto

## Objetivo

Generar la matriz de actores × canales × momentos × inputs × outputs. Esto se **deriva en gran parte automáticamente** de las secciones anteriores; pídele al usuario que valide y complete.

## Generación auto + validación

A partir de:
- Actores (step 04)
- Pantallas (step 07)
- Procesos (step 05)
- Capacidades (step 06)

**Genera una primera versión de la tabla** y mostrala al usuario:

```markdown
| Actor | Canal | Momento de interacción | Inputs | Outputs |
|---|---|---|---|---|
| {{actor.principal.rol}} | {{pantalla.S1.nombre}} | {{cuándo, derivado del flujo principal}} | {{qué le da el usuario al sistema}} | {{qué le devuelve el sistema}} |
| ... | ... | ... | ... | ... |
```

## Pregunta única

> Aquí está la matriz de interacciones derivada de lo que ya me contaste. Revisala y dime: ¿hay alguna fila que falte, sobre o esté mal? ¿Hay algún punto de contacto con un sistema externo (ERP, pasarela, API) que no haya capturado?

Acepta correcciones y aplicalas.

## Output markdown

```markdown
## 11. Interacciones y Puntos de Contacto

| Actor | Canal | Momento de interacción | Inputs | Outputs |
|---|---|---|---|---|
{{filas validadas}}
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 502-513).
