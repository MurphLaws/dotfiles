# Step 02 — Resumen Ejecutivo

## Objetivo

Capturar la información para escribir UN solo párrafo denso que explique qué es la app, qué reemplaza/transforma, a quién va dirigida y qué problemas operativos elimina. **Sin números monetarios.**

## Preguntas

### P1 — Pitch en una frase (libre)
> Si tuvieras que describir la app en una sola frase, ¿qué dirías? Empieza con "Es una plataforma/app/herramienta que…"

### P2 — Qué reemplaza o transforma (libre)
> ¿Qué proceso, herramienta o forma de trabajar actual viene a reemplazar? Sé concreto: "reemplaza el Excel manual de planificación", "elimina las llamadas telefónicas para cobrar", "sustituye los recibos en papel".

### P3 — A quién va dirigida (libre)
> ¿Quién es el usuario principal de la app? Dame un cargo o rol específico (ej. "Director de Logística", "Gerente de Cobros", "Dueño de un negocio pequeño").

### P4 — 3-5 problemas operativos que elimina (libre, lista)
> Dame los 3 a 5 dolores operativos más fuertes que la app va a eliminar. **No me des números en pesos**, sino las consecuencias concretas: "no se sabe quién pagó este mes", "el cobrador olvida visitar clientes", "los recibos en papel se pierden".

Acepta como lista. Guarda como `resumen.dolores: string[]`.

### P5 — Estructura del MVP (libre, opcional)
> ¿La app tiene capas o módulos principales que ya tienes en mente? Por ejemplo: "captación de clientes, generación de cobro, registro de pago, reporte mensual". Si no lo tienes claro aún, lo definimos más adelante.

Si responde, guarda como `resumen.capas: string[]`. Si no, deja `[]`.

## Output markdown

```markdown
## 1. Resumen Ejecutivo

**{{meta.proyecto}}** {{P1 — convertido a 3a persona, ej. "es una plataforma operativa…"}}, {{P2 — qué reemplaza}}{{ mediante un flujo de N capas: <capas si existen>}}. Este {{meta.tipo}} está dirigido a {{P3}} y busca eliminar {{listar P4 en prosa: "las X devoluciones diarias, la dependencia de Y, las Z horas extra de…"}}.
```

Un solo párrafo de 3-5 líneas. Estilo del ejemplo (línea 19 del PRD de referencia).
