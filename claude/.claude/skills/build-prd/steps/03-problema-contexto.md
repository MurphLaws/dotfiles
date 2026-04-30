# Step 03 — Problema y Contexto

## Objetivo

Capturar el problema central, las limitaciones del proceso actual (AS-IS) y las alternativas existentes. **NO se pregunta por costos en COP/USD.**

## Preguntas

### P1 — Descripción del problema central (libre, párrafo largo)
> Cuéntame en uno o dos párrafos cómo funciona hoy la operación que esta app va a transformar. Quiero entender la situación actual: quién hace qué, cómo se comunican, qué herramientas usan, dónde se rompe la cosa.

Apunta a 4-8 líneas de respuesta. Si la respuesta es muy corta, repregunta: "¿Y cómo se enteran cuando algo sale mal?", "¿Quién hace de cuello de botella?", "¿Qué pasa si esa persona no está?".

### P2 — Limitaciones críticas del AS-IS (libre, lista)
> Dame entre 4 y 8 limitaciones concretas del proceso actual. Por ejemplo: "depende de una sola persona", "no hay visibilidad durante el día", "la comunicación es solo telefónica", "los datos están en hojas de cálculo separadas".

Guarda como `problema.limitaciones: string[]`.

### P3 — Alternativas existentes (libre, lista)
> ¿Hay otras herramientas o soluciones que han evaluado o que existen en el mercado para este problema? Pueden ser SaaS específicos, hojas de cálculo, soluciones open source, etc. Para cada una, dime qué hace bien y qué le falta.

Captura nombre + breve descripción de qué hace bien y qué le falta. Guarda como `problema.alternativas: [{ nombre, fortalezas, debilidades }]`.

### P4 — Oportunidad (libre, párrafo)
> En 2-3 líneas, ¿por qué este es el momento correcto para construir esta app? ¿Qué hace que ahora sea viable o necesario? (puede ser una nueva tecnología disponible, un cambio en el mercado, un problema que creció, una oportunidad institucional, etc.)

Guarda como `problema.oportunidad: string`.

## Output markdown

```markdown
## 2. Problema y Contexto

### Descripción del problema central

{{P1 — el párrafo del usuario, lo dejas casi tal cual, solo limpiando ortografía}}

### Proceso actual (AS-IS) — limitaciones críticas

{{lista bullet de P2, cada item con bold del concepto y descripción:
- **Concepto:** descripción.
}}

### Alternativas existentes y sus limitaciones

{{lista bullet de P3, formato:
- **Nombre:** qué hace bien. Limitación: qué le falta.
}}

### Oportunidad

{{P4}}
```

**Importante**: No incluyas tabla de costos. No menciones "costo anual", "COP", "USD", ni "ROI".
