# Step 14 — Alcance del MVP

## Objetivo

Listar lo que el MVP **incluye** y lo que **NO incluye** (con justificación). Esto es crítico para evitar scope creep y para que Claude Code sepa qué NO construir.

## Preguntas

### P1 — Lo que incluye (auto-derivar + validar)
A partir de las capacidades Must-have del step 06, genera la lista. Muéstrale al usuario:

```
El MVP va a incluir:
- C1 — Geocodificación de clientes
- C2 — Wiki de rutas
- C3 — Planificación asistida
- ...
```

Pide validación: "¿Te parece completa esta lista? ¿Falta algo?"

### P2 — Lo que NO incluye (libre, lista con justificación)
> Ahora la parte importante: ¿qué cosas, aunque sean tentadoras, **NO** vas a incluir en este MVP? Para cada una dame una justificación clara (por qué se queda afuera, cuándo se incluiría). Por ejemplo: "tracking GPS continuo del vehículo — requiere hardware adicional, queda para Fase 2 post-piloto".

Sugerencias de descartes típicos a explorar (pregunta uno a uno si aplican):
- Integración con sistemas internos existentes (ERP, CRM)
- App nativa móvil (vs PWA)
- Notificaciones push
- Reportes avanzados / analytics
- Multi-idioma
- Dark mode
- Roles y permisos granulares (más allá de los básicos)
- Auditoría / log de acciones
- Exportación a Excel / PDF
- Integraciones de terceros más allá de las esenciales

Captura como `alcance.no_incluye: [{ funcionalidad, justificacion }]`.

### P3 — Capacidades Should-have / Could-have (auto-derivar)
Las capacidades del step 06 marcadas como Should/Could van a aparecer aquí como "no incluido en MVP, queda para Fase 2/3".

## Output markdown

```markdown
## 14. Alcance del MVP

### Incluye

{{lista bullet de capacidades Must-have:}}
- {{capacidad y descripción de 1 línea}}
- ...
- Piloto en {{contexto del piloto}} antes de despliegue completo.

### No incluye (con justificación)

| Funcionalidad excluida | Justificación |
|---|---|
{{filas de alcance.no_incluye}}
{{filas auto-generadas para capacidades Should/Could}}
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 588-608).
