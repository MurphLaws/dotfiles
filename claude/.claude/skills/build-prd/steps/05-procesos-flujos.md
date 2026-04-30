# Step 05 — Procesos y Flujos (AS-IS y TO-BE)

## Objetivo

Capturar el proceso actual paso a paso, las fricciones que la app elimina, y el proceso propuesto. Generar mermaid flowchart del TO-BE automáticamente.

## Preguntas

### P1 — Proceso AS-IS paso a paso (libre, lista numerada)
> Cuéntame el proceso actual de principio a fin, paso por paso. Empieza con el evento que dispara todo (ej. "el cliente solicita el servicio") y termina con el cierre (ej. "se archiva el comprobante"). Quiero entre 6 y 10 pasos numerados.

Captura como `procesos.as_is: string[]` (lista ordenada).

### P2 — Fricciones eliminadas por el TO-BE (auto-derivar + validar)
A partir de las limitaciones del step 03 (`problema.limitaciones`) y los pasos del AS-IS, **propón una tabla** de pares "fricción actual → cómo se elimina". Muestra al usuario y pide validación / agregar items que falten.

Formato:
```
| Fricción actual | Cómo se elimina |
|---|---|
| Planificación manual de 2,5 h | Reemplazada por planificación asistida en <30 min con datos geocodificados |
```

Guarda como `procesos.fricciones: [{ actual, eliminacion }]`.

### P3 — Proceso TO-BE paso a paso (libre, lista numerada)
> Ahora cuéntame cómo quieres que sea el proceso con la app. Mismo formato: 8-15 pasos numerados, desde el evento que dispara hasta el cierre. Si hay decisiones (ej. "¿el cliente puede recibir?"), márcamelas como "Decisión:".

Captura como `procesos.to_be: [{ tipo: 'paso'|'decision', descripcion, ramas?: { si, no } }]`.

### P4 — Oportunidades de automatización (libre, lista)
> ¿Qué partes del proceso TO-BE deberían ser automáticas (sin intervención humana) y qué dispara cada una? Por ejemplo: "geocodificación de direcciones nuevas se dispara cuando aparece un cliente sin coordenadas".

Captura como `procesos.automatizaciones: [{ proceso, tipo, trigger }]`.

## Generación del mermaid TO-BE

A partir de `procesos.to_be`, genera un flowchart mermaid:
- Nodos circulares `([Inicio: ...])` y `([Fin: ...])` para inicio/fin
- Nodos rectangulares `[Texto]` para pasos
- Nodos diamante `{¿Pregunta?}` para decisiones, con flechas `-- Sí -->` y `-- No -->`
- Si hay loop (ej. "¿quedan más clientes?"), conectar de vuelta al paso correspondiente

## Output markdown

```markdown
## 4. Procesos y Flujos

### Proceso actual (AS-IS)

{{lista numerada de procesos.as_is}}

**Puntos de fricción eliminados por el TO-BE:**

| Fricción actual | Cómo se elimina |
|---|---|
{{filas de procesos.fricciones}}

### Proceso propuesto (TO-BE)

```mermaid
flowchart TD
{{nodos y aristas generados desde procesos.to_be}}
```

### Oportunidades de automatización identificadas

| Proceso | Tipo de automatización | Trigger |
|---|---|---|
{{filas de procesos.automatizaciones}}
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 105-170).
