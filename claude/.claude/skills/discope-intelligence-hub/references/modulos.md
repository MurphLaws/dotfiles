# Modulos de DiScope Intelligence Hub — Instrucciones Detalladas

## Modulo 1: Scout (Tendencias y Estado del Arte)

### Objetivo
Investigar tendencias globales, materiales emergentes, tecnologias aplicables y regulaciones relevantes para el producto solicitado.

### Proceso
1. Generar 3-5 queries de busqueda web optimizados. Ejemplos:
   - "[tipo producto] [material] packaging trends 2025 2026"
   - "[producto] cosmetic packaging innovation"
   - "envase [material] [segmento] regulacion INVIMA Colombia"
   - "[material] packaging sustainability rPET PCR trends"
2. Ejecutar busquedas multiples.
3. Analizar y sintetizar resultados.
4. Estructurar en formato Markdown.

### Formato de Salida

```
### TENDENCIAS Y ESTADO DEL ARTE
**[Nombre del producto investigado]**

**Tendencias globales**
1. **[Nombre de tendencia]** — [Descripcion 1-2 oraciones]. [Fuente: nombre, fecha, URL]
2. **[Nombre de tendencia]** — [Descripcion]. [Fuente]
3. (minimo 3, maximo 5)

**Materiales recomendados**
- [Material 1]: [justificacion tecnica breve]
- [Material 2]: [justificacion]

**Tecnologias aplicables**
- [Tecnologia]: [relevancia para DisCórdoba]

**Regulaciones relevantes**
- INVIMA: [detalle si aplica para Colombia]
- [Otra regulacion]: [detalle]
```

### Criterios de Calidad
- Minimo 3 tendencias con fuentes verificables (URLs funcionales).
- Informacion de los ultimos 12 meses.
- Incluir relevancia para Colombia/LatAm cuando exista.
- Fuentes reconocidas del sector: PETnology, Cosmetics Design, Inside Packaging, Fortune Business Insights, Grand View Research, Towards Packaging.

---

## Modulo 2: Suppliers (Proveedores)

### Objetivo
Identificar proveedores nacionales e internacionales para el producto, generando fichas comparativas con precios.

### Proceso CON datos de SICEX
1. Analizar el archivo SICEX cargado por el usuario.
2. Filtrar registros por partida arancelaria y/o descripcion relevante.
3. Agrupar por pais de origen y exportador.
4. Calcular volumenes historicos y precios promedio.
5. Clasificar como "Conocido" (si esta en la lista de proveedores actuales de DisCórdoba, cuando esta disponible) o "Nuevo".
6. Complementar con busqueda web para proveedores adicionales.

### Proceso SIN datos de SICEX
1. Generar queries de busqueda web:
   - "[producto] manufacturer [pais]"
   - "proveedor [producto] [material] latinoamerica"
   - "[producto] wholesale supplier international"
   - "[tipo envase] fabricante Colombia"
2. Buscar en directorios industriales, sitios de fabricantes, resultados de ferias.
3. Extraer datos disponibles de cada proveedor.

### Formato de Salida

```
### PROVEEDORES IDENTIFICADOS
**[X] proveedores encontrados ([Y] nacionales, [Z] internacionales)**

| Proveedor | Pais | Productos | Vol. historico | Precio ref. | Tipo | Fuente |
|-----------|------|-----------|---------------|-------------|------|--------|
| [Nombre]  | [Pais] | [Productos relevantes] | [Volumen o N/D] | [Precio FOB/CIF o Consultar] | [Conocido/Nuevo] | [SICEX/Web + URL] |

**Resumen:** De los [X] proveedores, [N] son nuevos para DisCórdoba. Los proveedores de [paises] ofrecen los precios mas competitivos. [Nombre proveedor nacional] tiene la ventaja de tiempos de entrega mas cortos.

*Los precios son referenciales basados en datos publicos. Solicitar cotizacion formal antes de comparar.*
```

### Criterios de Calidad
- Minimo 3 proveedores identificados (idealmente 5-8).
- Distinguir nacionales vs internacionales.
- Marcar "Conocido" vs "Nuevo".
- Precios con contexto (FOB/CIF/estimado). Si no hay, escribir "Consultar".
- Si se uso SICEX: incluir volumenes historicos.
- Fuente verificable por cada proveedor.

---

## Modulo 3: Clients (Clientes Potenciales)

### Objetivo
Identificar clientes potenciales que podrian necesitar el producto investigado, con consumo mensual estimado.

### Proceso CON datos de CRM
1. Analizar el export del CRM.
2. Filtrar clientes por sector relevante (ej: cosmeticos, farma).
3. Identificar clientes que compran productos similares o complementarios.
4. Estimar consumo mensual basado en volumenes historicos + tamano de empresa.
5. Asignar nivel de confianza:
   - "Alta": mismo sector + historial de compra similar.
   - "Media": mismo sector sin historial directo.
   - "Baja": sector relacionado pero sin datos.
6. Complementar con busqueda web de clientes nuevos.

### Proceso SIN datos de CRM
1. Generar queries de busqueda web:
   - "empresas [segmento] Colombia"
   - "fabricantes [producto final] [ciudad]"
   - "marcas cosmeticas colombianas" (adaptar al segmento)
2. Identificar empresas del sector y tamano relevante.
3. Estimar consumo basado en benchmarks del sector.
4. Todos marcados como tipo "Nuevo".

### Formato de Salida

```
### CLIENTES POTENCIALES
**[X] clientes identificados — Consumo total estimado: [TOTAL] unidades/mes**

| Cliente | Sector | Justificacion | Consumo est. (u/mes) | Confianza | Tipo |
|---------|--------|---------------|---------------------|-----------|------|
| [Nombre] | [Sector] | [1 oracion por que necesitaria el producto] | [Numero] | [Alta/Media/Baja] | [Actual/Nuevo] |

**Resumen:** [X] clientes actuales con consumo estimado de [Y] u/mes (confianza media-alta) + [Z] clientes nuevos con consumo estimado de [W] u/mes (confianza media-baja). **Consumo total estimado: [TOTAL] unidades/mes.**

*Estimaciones basadas en: tamano de empresa, productos similares que consume, y benchmark del sector [segmento] en Colombia.*
```

### Feature Interactivo
Si el usuario dice "El cliente X confirmo 8.000 u/mes", recalcular el total y actualizar el resumen.

---

## Modulo 4: Radar (Competencia)

### Objetivo
Detectar movimientos de competencia: nuevos importadores, cambios de precios, lanzamientos de productos similares.

### Proceso CON datos de SICEX
1. Identificar importadores colombianos que traen el mismo tipo de producto.
2. Calcular volumenes y precios.
3. Detectar tendencias (creciendo, estable, decreciendo).
4. Complementar con busqueda web de noticias.

### Proceso SIN datos de SICEX
1. Buscar noticias recientes sobre competidores en el mercado colombiano de empaques.
2. Buscar lanzamientos de productos similares.
3. Identificar nuevos actores en el mercado.

### Formato de Salida

```
### ANALISIS COMPETITIVO
**[X] alertas detectadas para [producto]**

**ALERTA 1 — Impacto: [ALTO/MEDIO/BAJO]**
- Evento: [Descripcion del evento detectado]
- Fuente: [Referencia con URL]
- Implicacion: [Que significa para DisCórdoba, 1-2 oraciones]
- Accion sugerida: [1 oracion concreta]

(Repetir para cada alerta, ordenadas de ALTO a BAJO)

[Si no hay alertas relevantes]: "No se detectaron movimientos criticos para este producto. El mercado se mantiene estable."
```

### Criterios de Impacto
- **ALTO**: Competidor directo con producto identico a precios menores, o nuevo actor con volumen significativo.
- **MEDIO**: Movimiento de mercado que podria afectar en 3-6 meses.
- **BAJO**: Informacion de contexto sin accion inmediata.

---

## Modulo 5: Trends (Contexto del Sector)

### Objetivo
Contextualizar la investigacion con tendencias macro del sector que enriquecen la perspectiva estrategica.

### Proceso
1. Buscar tendencias recientes del sector de packaging global con foco en:
   - Materiales (rPET, PCR, PETG, bio-based, vidrio reciclado)
   - Disenos (refillable, minimalist, thick-wall, smart packaging)
   - Regulaciones (economia circular, prohibicion plasticos, PCR obligatorio)
   - Tecnologias (ISBM, IML, automatizacion, IoT en produccion)
   - Movimientos de grandes marcas (L'Oreal, Grupo Boticario, K-Beauty)
2. Filtrar por relevancia para DisCórdoba y el producto investigado.
3. Conectar tendencias con oportunidades concretas.

### Formato de Salida

```
### CONTEXTO DEL SECTOR
**Tendencias macro relevantes para [producto]**

[Parrafo con datos clave en negritas: tamano de mercado, CAGR, proyecciones]

[Parrafo con implicacion para DisCórdoba]

**Oportunidad identificada:** [Oportunidad concreta con recomendacion]

Fuentes: [Lista de URLs]
```

### Fuentes Priorizadas
PETnology, Cosmetics Design, Inside Packaging, Fortune Business Insights, Grand View Research, Towards Packaging, blogs de fabricantes (SIPA, Nissei ASB), conferencias (K Show, Cosmoprof, Andina Pack, Sustainability in Packaging Latin America).
