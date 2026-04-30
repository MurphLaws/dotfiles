# Step 13 — Plan de Implementación por Fases

## Objetivo

Dividir las capacidades en fases de implementación con duración, alcance, capacidades incluidas, acciones clave y entregables.

## Preguntas

### P1 — Cantidad de fases (AskUserQuestion)
- 1 fase (un solo sprint, todo de una)
- 2 fases (fundamentos + completar)
- 3 fases (recomendado para MVP — base, ejecución, automatización)
- 4+ fases

Default sugerido: 3 fases.

### P2 — Duración total y por fase (libre)
> ¿Cuántos días o semanas tienes en total para construir el MVP? ¿Y cómo quieres distribuirlos entre las fases? Ejemplo: "30 días total, 12 días Fase 1, 9 días Fase 2, 9 días Fase 3".

Si el usuario no sabe, sugiere: para 1 desarrollador con Claude Code, una capacidad típica toma 1-3 días. Total = N capacidades × 2 días promedio.

### P3 — Por cada fase: alcance + capacidades + acciones (libre)
Para cada fase:

> Fase {{N}}: ¿cuál es el alcance principal en una frase? ¿Qué capacidades de las que listamos van en esta fase? ¿Qué 4-6 acciones concretas hay que ejecutar? ¿Cuál es el entregable verificable al final?

Captura como `fases: [{ numero, nombre, dias_inicio, dias_fin, alcance, capacidades_ids: ['C1','C2'], acciones_clave: string[], entregable }]`.

### P4 — Validación de cobertura (auto)
Después de capturar todas las fases, verifica que:
- Todas las capacidades Must-have están asignadas a alguna fase
- No hay capacidades duplicadas en distintas fases
- Las dependencias entre capacidades respetan el orden (ej. login antes de pantallas privadas)

Si encuentras una falla, alerta al usuario y sugiere corrección.

## Output markdown

```markdown
## 13. Plan de Implementación por Fases

{{Por cada fase:}}
### Fase {{N}} — {{nombre}} (Días {{inicio}}–{{fin}})
**Alcance:** {{alcance}}.

**Capacidades incluidas:** {{lista de IDs y nombres}}.

**Acciones clave:**
{{lista bullet}}

**Entregable:** {{entregable}}.

---
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 540-583).
