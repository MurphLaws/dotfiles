# Step 12 — Flujo Principal (Narrativa)

## Objetivo

Capturar narrativamente el flujo del actor principal de inicio a fin, en prosa que cuente cómo usa la app un día típico. Más uno o dos flujos secundarios.

## Preguntas

### P1 — Día típico del actor principal (libre, párrafo largo)
> Cuéntame en 2-3 párrafos un día típico del {{actor.principal.rol}} usando la app. Empieza desde que abre la app (¿desde dónde? ¿qué dispositivo?), pasa por las acciones principales que hace, las decisiones que toma, las notificaciones que recibe, y cierra cuando termina su jornada. Quiero la historia completa.

Captura como `flujo_principal.narrativa: string`.

### P2 — Flujo secundario importante (libre, párrafo)
> Ahora cuéntame el flujo de un actor secundario clave. Por ejemplo: el conductor en campo, el cliente externo recibiendo una notificación, el equipo comercial atendiendo una novedad. Mismo formato: párrafo narrativo de 1-2 párrafos.

Captura como `flujo_principal.flujos_secundarios: [{ actor, narrativa }]`. Acepta múltiples; pregunta "¿hay otro flujo importante de capturar?" hasta que el usuario diga no.

### P3 — Automatizaciones involucradas (libre o auto-derivar)
A partir de las automatizaciones del step 05 + webhooks/cron del step 10, **propón una lista** y pídele al usuario que confirme/agregue:

```
Automatizaciones involucradas en el flujo principal:
- {{automatización}} (trigger: {{cuándo se dispara}})
- ...
```

## Output markdown

```markdown
## 12. Flujo Principal

### Flujo del {{actor.principal.rol}} (actor principal)

{{narrativa}}

**Automatizaciones involucradas en el flujo principal:**
{{lista bullet}}

### Flujo secundario: {{actor secundario}}

{{narrativa}}

{{repetir por cada flujo secundario}}
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 516-535).
