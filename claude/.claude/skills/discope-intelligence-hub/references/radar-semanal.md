# Reporte Radar Semanal — Instrucciones de Generacion

## Trigger
El usuario dice: "Reporte Radar semanal", "Alertas de competencia", "Monitoreo semanal", "Que ha pasado en el mercado esta semana", o variaciones.

## Proceso

1. Ejecutar busquedas web enfocadas en:
   - Noticias recientes del sector de empaques en Colombia y LatAm
   - Nuevos lanzamientos de productos de competidores
   - Cambios regulatorios relevantes (plasticos, economia circular, INVIMA)
   - Movimientos de grandes marcas en packaging cosmetico
   - Si hay SICEX actualizado: nuevas importaciones relevantes

2. Cubrir las 3 lineas de negocio:
   - Plasticos (envases, complementos)
   - Vidrio (envases cosmeticos, farma, alimentos)
   - Ingredientes y aditivos

3. Priorizar alertas por impacto.

## Formato de Salida

```markdown
### DISCORDOBA — DiScope Radar Semanal
**Semana [fecha inicio] al [fecha fin]**

**Resumen:** Esta semana se detectaron [X] alertas para las lineas de [lineas afectadas]. [Y] alertas de impacto alto requieren atencion.

---

| # | Linea | Evento | Impacto | Accion sugerida |
|---|-------|--------|---------|-----------------|
| 1 | [Linea] | [Descripcion del evento] | **ALTO** | [Accion concreta] |
| 2 | [Linea] | [Descripcion] | MEDIO | [Accion] |
| 3 | [Linea] | [Descripcion] | BAJO | [Accion] |

---

**Detalle de alertas de impacto ALTO:**

**Alerta [#]: [Titulo]**
- Evento: [Descripcion completa]
- Fuente: [URL]
- Implicacion para DisCórdoba: [2-3 oraciones]
- Accion recomendada: [1 oracion]

---

*Para profundizar en cualquier alerta, solicita una investigacion completa en DiScope.*
*Reporte generado por DiScope Intelligence Hub — [fecha]*
```

## Despues de Generar

Preguntar: "Quieres que lo copie en formato de email listo para enviar a la Gerente de Ingredientes y las gerencias?"

Si acepta, generar version email:
- Asunto: "DiScope Radar — Alertas semana [fechas]"
- Cuerpo: el reporte con formato limpio
- Cierre: "Equipo de Desarrollos Comercial — DisCórdoba S.A.S."

## Si No Hay Alertas

Si no se encuentran movimientos relevantes esta semana:

"### DiScope Radar Semanal — Semana [fechas]
**Sin alertas significativas esta semana.** El mercado de empaques en Colombia se mantiene estable en las 3 lineas de negocio. Continuo monitoreando para la proxima semana."
