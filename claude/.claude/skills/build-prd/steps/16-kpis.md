# Step 15 — KPIs y Métricas de Éxito

## Objetivo

Capturar las métricas operativas que validan que el MVP cumple su propósito. **Solo KPIs operativos, no monetarios.**

## Reglas estrictas

- **NO preguntar** por COP, USD, "ahorro estimado", "ROI", "valor económico".
- **SÍ preguntar** por: tiempo, porcentaje, conteo, tasa, cobertura, latencia, satisfacción.

## Preguntas

### P1 — KPIs principales (libre, lista, 4-7 items)
> Vamos a definir 4 a 7 KPIs operativos para medir el éxito del MVP. Para cada uno necesito:
> - **Nombre del KPI**
> - **Qué mide en una frase**
> - **Línea base actual** (cómo está hoy, en unidades concretas: minutos, %, cantidad)
> - **Meta esperada post-MVP** (a qué valor querés llegar, en las mismas unidades)
>
> Ejemplos de KPIs válidos:
> - Tiempo de planificación (min/día) — baseline 150 min, meta <30 min
> - Tasa de devoluciones (%) — baseline 10%, meta <3%
> - Cobertura digital de entregas (%) — baseline 0%, meta >80%
> - Latencia entre evento y dashboard (segundos) — baseline N/A, meta <60s
>
> Ejemplos de KPIs **inválidos** (no aceptes):
> - "Ahorro mensual en COP"
> - "Reducción de costo de operación"
> - "ROI"

Si el usuario propone un KPI monetario, repregunta traduciéndolo a operativo: "En lugar de 'ahorro en pesos', ¿puedes medirlo como 'horas extras eliminadas por semana' o 'número de devoluciones evitadas'?".

Captura como `kpis: [{ nombre, que_mide, baseline, meta }]`.

### P2 — Cómo se mide cada KPI (auto-derivar + validar)
Para cada KPI, **propón** dónde y cómo se mide:

```
KPI: Tasa de devoluciones
Cómo se mide: query a la base de datos, columna "estado" de Pedido, filtrar estado='devuelto' / total del día.
Frecuencia: diaria, automática, dashboard del Director.
```

Pide validación. Captura como `kpis[i].como_se_mide: string`.

## Output markdown

```markdown
## 15. KPIs y Métricas de Éxito

| KPI | Qué mide | Línea base actual | Meta esperada post-MVP | Cómo se mide |
|---|---|---|---|---|
{{filas de kpis}}
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 612-620), pero **SIN** la columna de "Costo anual estimado" si la hubiera. Agrega la columna "Cómo se mide" para que Claude Code sepa qué query/lógica implementar.
