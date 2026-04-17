# Informe Integrado DiScope — Instrucciones de Generacion

## Trigger
El usuario dice: "Genera el informe", "Arma el informe para gerencia", "Consolida todo", "Prepara el documento", o variaciones.

## Pre-generacion
Antes de generar, preguntar:
"Quieres incluir alguna observacion personal o recomendacion propia en el informe?"

Si el usuario agrega algo, incorporarlo en la seccion de recomendacion.

## Estructura del Informe

```markdown
# INFORME DE INVESTIGACION — DiScope Intelligence Hub

**Producto:** [Nombre completo del producto]
**Linea:** [Plastico/Vidrio/Ingredientes] | **Segmentos:** [Alimentos/Cosmeticos/Farma/Aseo]
**Fecha:** [DD de mes de AAAA]
**Elaborado por:** DiScope para [Nombre del usuario], [Cargo]
**Origen de solicitud:** [Quien solicito y por que]

---

## 1. Resumen Ejecutivo

[3-5 oraciones con: que se investigo, principales hallazgos, consumo total estimado, numero de proveedores identificados, y recomendacion en una linea.]

---

## 2. Analisis de Tendencias

[Resumen de los datos mas relevantes del modulo Scout. Incluir las 2-3 tendencias mas importantes con datos cuantitativos y fuentes.]

---

## 3. Proveedores Identificados

[Tabla comparativa de las mejores opciones de proveedor]

| Proveedor | Pais | Productos | Precio ref. | Tipo | Ventaja principal |
|-----------|------|-----------|-------------|------|-------------------|

[Parrafo de recomendacion: cuales son los mas competitivos y por que]

---

## 4. Clientes Potenciales

[Tabla con clientes potenciales]

| Cliente | Sector | Consumo est. (u/mes) | Confianza | Tipo |
|---------|--------|---------------------|-----------|------|

**Consumo total estimado: [TOTAL] unidades/mes**
[Desglose: X clientes actuales + Y nuevos]

---

## 5. Analisis Competitivo

[Alertas de Radar mas relevantes, priorizadas por impacto]

[Si hay alerta ALTA: destacarla con explicacion de implicaciones]

---

## 6. Contexto del Sector

[Datos de Trends relevantes para este producto especifico]
[Oportunidades estrategicas identificadas]

---

## 7. Recomendacion

**RECOMENDACION: [PROCEDER / NO PROCEDER / PROCEDER CON CONDICIONES]**

[Justificacion basada en datos:
- Volumen estimado: [X] u/mes (suficiente/insuficiente para el umbral de [Y])
- Proveedores: [X] opciones identificadas con precios competitivos
- Competencia: [nivel de actividad]
- Tendencia del mercado: [creciendo/estable/decreciendo]
]

[Si el usuario agrego observacion personal, incluirla aqui]

---

## Fuentes Consultadas

1. [Nombre de fuente] — [URL]
2. [Nombre de fuente] — [URL]
(listar todas las fuentes usadas en el informe)
```

## Despues de Generar

Mostrar: "Informe listo. Quieres que lo genere como archivo Word descargable? O si necesitas ajustes, indicame que cambio."

## Versiones del Informe

Si el usuario pide "hazlo mas corto" o "version ejecutiva", generar version de 1 pagina:
- Solo: Producto, consumo total estimado, top 3 proveedores, recomendacion, 1 parrafo de contexto.

Si el usuario pide ajustes puntuales ("agrega mas detalle en proveedores", "cambia la recomendacion"):
- Regenerar solo la seccion afectada, no todo el informe.

## Generacion como Archivo Word

Si el usuario pide el archivo Word, usar la capacidad de creacion de archivos de Claude para generar un .docx con:
- Nombre: "DiScope_Informe_[ProductoAbreviado]_[MesAnio].docx"
- Formato profesional: titulos jerarquicos, tablas con bordes, fuente Arial
- Presentar con enlace de descarga
