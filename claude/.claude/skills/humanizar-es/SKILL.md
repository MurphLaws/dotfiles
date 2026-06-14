---
name: humanizar-es
description: "Auditar y reescribir texto en español (especialmente académico/técnico) para eliminar patrones de redacción IA detectables por Pangram, GPTZero, Turnitin y similares. Activar cuando el usuario pida: 'auditar este texto', 'humanizar', 'quitar patrones de IA', 'esto suena a IA', 'bajar el score de detección', o quiera revisar prosa en español antes de entregarla. Combina el catálogo de Wikipedia 'Signs of AI writing', los patrones específicos del español identificados con Pangram, y las reglas de la skill human-writing. La salida NO tiene que ser 100% gramaticalmente perfecta: prioriza ritmo humano sobre pulcritud."
metadata:
  version: 1.0.0
---

# Humanizar-ES: auditoría y reescritura de patrones de IA en español

Esta skill hace dos cosas, en orden: **(1) audita** un texto y lista cada patrón de IA encontrado con cita textual, y **(2) reescribe** los tramos afectados con prosa que suene a persona, no a modelo.

## Principio rector

Lo que delata un texto generado no son palabras sueltas: es la **regularidad**. El mismo molde retórico aplicado párrafo tras párrafo, con cadencia idéntica y léxico reciclado. Por eso la regla central de esta skill es:

> **Ninguna estrategia de reescritura puede usarse dos veces seguidas.** Si rompiste una antítesis fusionando las dos cláusulas, la siguiente la rompes de otra forma: borrando la mitad, convirtiéndola en afirmación directa, o dejando la idea implícita. La variedad ES la humanización.

La salida no necesita gramática de manual. Una oración que arranca con «Y», una redundancia leve, un inciso que interrumpe donde un editor pondría punto: eso es ruido humano y se permite. Lo que NO se permite es cambiar cifras, citas, datos o el significado técnico.

**Registro profesional siempre.** La humanización viene de variar estructura, ritmo y convicción, NO de bajar el registro. Prohibidos los coloquialismos en texto académico: «echar gasolina», «meter» (por incorporar), «a punta de», «no da para», «meterle mano», «se desploma» (figurado), «ya es otra cosa» y similares. Un texto puede sonar humano y seguir sonando a tesis.

---

## CATÁLOGO DE PATRONES (español)

### 1. Antítesis por negación («no es A, sino B»)
El patrón más frecuente y delator. Variantes: «no X, sino Y», «no solo X, sino también Y», «X y no Y», «no es A: es B».
- *Detectar:* «no son competidores de M1, sino instrumentos diagnósticos», «la salida es una clasificación de regiones, no una lista de coordenadas».
- *Regla:* máximo una por sección. Las demás se convierten en afirmación directa, se parten en dos oraciones, o se borra la mitad negada (el lector la infiere).

### 2. Dos puntos-revelación («X: Y»)
Setup corto, dos puntos, revelación. Equivalente español del guión largo de la IA en inglés.
- *Detectar:* «La transferibilidad no es obvia: los catálogos son pequeños», «Es el placebo: cualquier modelo debe superarlo».
- *Regla:* máximo una por página. Sustituir por «porque», punto y oración nueva, o paréntesis.

### 3. Gerundio interpretativo colgante y «lo que» final
Oración factual que remata con interpretación gratuita pegada con gerundio o «lo que».
- *Detectar:* «...capturando el atractivo de los nodos dominantes», «...lo que conserva la interpretabilidad y traslada la diversificación a un parámetro único».
- *Regla:* o la interpretación merece su propia oración, o se borra. Nunca dos remates de gerundio en el mismo párrafo.

### 4. Tricolon y enumeración paralela perfecta
Grupos de tres con sintaxis idéntica; marcadores «Primero, ... Segundo, ... Tercero, ...»; «ni X, ni Y, ni Z».
- *Regla:* desbalancear. Dos elementos, o cuatro, o tres con sintaxis distinta y longitudes desparejas. Los «Primero/Segundo/Tercero» se reemplazan por flujo natural (el segundo punto puede empezar con «También pesa que...» y el tercero ni anunciarse).

### 5. Inflación de significancia
Anunciar la importancia en vez de mostrarla: «es metodológicamente central», «merece destacarse», «juega un papel crucial», «representa un cambio de paradigma».
- *Regla:* borrar el anuncio y dejar el hecho. Si el hecho no sostiene la importancia solo, el anuncio tampoco lo hacía.

### 6. Vocabulario mascota
Palabras correctas pero recicladas con frecuencia de máquina: **accionable, defendible, palanca, materializar, deliberado/deliberada, trazable, robusto/robustez, articular, capturar, delimitar, consolidar, exponer (como), heredar (figurado), honestidad metodológica, granular, holístico**.
- *Regla:* cada una puede aparecer UNA vez en todo el documento. Las demás instancias se cambian por sinónimos comunes o se reescribe la frase para no necesitarla.

### 7. Evitación de cópula
Verbos elaborados donde bastaba «es/tiene/hay»: «se inscribe en», «se materializa como», «constituye», «cumple la función de», «queda expuesto como», «sirve como».
- *Regla:* devolver el «es» o el «tiene» en la mayoría de los casos. El español académico humano usa cópulas sin vergüenza.

### 8. Cadencia uniforme (baja burstiness)
Oraciones de 25-40 palabras en serie, todas con la misma arquitectura interna (principal + inciso + remate). Es la métrica número uno de los detectores.
- *Regla:* meter oraciones de 4-10 palabras donde duela. Una por párrafo mínimo. También se vale una larga de verdad (50+) si fluye hablada. Leer en voz alta: si suena a metrónomo, no está listo.

### 9. Remates citables y aforismos
Cierres de póster: «El modelo recupera la señal genuina, no el ruido».
- *Regla:* si suena a cita de LinkedIn, reescribir plano o cortar. El dato ya cerraba el párrafo.

### 10. Señalización vacía
«Conviene precisar que», «cabe señalar», «merece subrayarse», «la lectura metodológica es que», «en palabras:».
- *Regla:* borrar el anuncio y decir la cosa. Excepción: una señalización por capítulo se tolera si de verdad reorienta al lector.

### 11. Hedging calibrado uniforme
Cautela en dosis perfecta y constante: «probablemente conservador», «no resulta sorprendente», «la explicación más plausible radica en».
- *Regla:* variar la convicción. A veces tajante («el peso de literatura se queda corto»), a veces inseguro de verdad («no tenemos forma de comprobarlo con n=32»).

### 12. Narrativa sin fricción
Todo justificado, nada salió mal, cada decisión llega con su razón empaquetada («decisión deliberada de interpretabilidad»). Las tesis humanas tienen cicatrices.
- *Regla:* donde sea honesto hacerlo, mostrar el costo o el descarte: «se probó X primero y no funcionó por Y», «la alternativa era Z, pero exigía datos que no había». No inventar fricción falsa; solo dejar de esconder la real.

### 13. Paralelismo sintáctico en listas y descripciones
Los cuatro componentes descritos con el molde idéntico («f1 codifica...; f2 aplica...; f3 resume...; f4 traduce...»).
- *Regla:* romper el molde en al menos un elemento: hacerlo más corto, meterle un comentario, cambiarle el orden sintáctico.

### 14. Personificaciones vacías de abstracciones
«La literatura recomienda», «el modelo interpreta», «la industria ha convergido» — tolerables en académico, pero en serie son molde. «La época nos invita a...» es directamente prohibido.

### 15. Fragmentos dramáticos y pseudo-poesía
Párrafos de una palabra, staccato para drama. (Raro en tesis, frecuente en posts.) Solo válido con ritmo real que lo sostenga, una vez.

### 16. Conclusiones-eco
Cierres que solo repiten lo dicho con otras palabras. Un cierre debe agregar una implicancia, una limitación honesta o una apertura, o no existir.

---

## EJEMPLOS MULTISHOT

Cada ejemplo usa una **estrategia distinta**. Nota cómo las soluciones no se parecen entre sí: eso es lo que hay que imitar.

### Ejemplo 1 — antítesis + dos puntos-revelación → afirmación directa con inciso
**Antes:**
> El espacio de decisión no se discretiza mediante una malla regular ni mediante clústeres de demanda, sino que se mantiene continuo y se muestrea con suficiente densidad como para que la salida final sea un ranking de coordenadas. Esta decisión se debe a la naturaleza del fenómeno que se busca capturar: la influencia de un centro comercial sobre los puntos cercanos es continua y monótonamente decreciente con la distancia.

**Después:**
> Aquí el espacio de decisión se deja continuo y se muestrea denso, de modo que lo que sale al final es una lista de coordenadas ordenadas. Tiene sentido por cómo se comporta el fenómeno. La influencia de un centro comercial sobre sus alrededores decae de forma continua con la distancia, sin saltos, y una malla regular o unos clústeres de demanda partirían ese continuo en pedazos arbitrarios.

### Ejemplo 2 — gerundio colgante + vocabulario mascota → oración corta y verbo común
**Antes:**
> La estructura lineal es una decisión deliberada de interpretabilidad: cada contribución al ranking final es trazable a una característica observable de la zona evaluada, capturando así la transparencia que exige el planificador municipal.

**Después:**
> Se eligió una estructura lineal porque se deja leer. Cualquiera puede tomar una posición del ranking y ver de dónde salió cada punto del puntaje, característica por característica. Para un planificador municipal eso vale más que un par de puntos extra de precisión.

### Ejemplo 3 — Primero/Segundo/Tercero → flujo natural desbalanceado
**Antes:**
> Tres rasgos del patrón son metodológicamente relevantes para este trabajo. Primero, la influencia del ancla disminuye de forma monótona con la distancia. Segundo, la magnitud del ancla, expresada como tráfico esperado de visitantes, escala el efecto. Tercero, el patrón no compite con el régimen de corredores, sino que lo complementa.

**Después:**
> Del patrón importan tres cosas para este trabajo. La influencia del ancla cae con la distancia, siempre. El tamaño del ancla escala el efecto (un centro comercial con cinco veces más visitantes pesa, a grandes rasgos, cinco veces más). Y conviene aclarar que el patrón convive bien con el despliegue sobre corredores viales; no son rivales.

### Ejemplo 4 — inflación de significancia + remate citable → dato plano y cierre honesto
**Antes:**
> Esta separación estricta entre los datos que el modelo principal nunca ve y los que las referencias supervisadas sí ven es central para que la métrica sea una medición honesta y no una validación circular. El modelo recupera la señal genuina, no el ruido.

**Después:**
> M1 nunca ve esas 32 estaciones. M2 y M3 sí las ven, porque para eso están. Si esa frontera se cruza en cualquier punto del proceso, la métrica de M1 deja de medir algo y se vuelve un círculo.

### Ejemplo 5 — cadencia uniforme → ritmo quebrado con fricción real
**Antes:**
> La captura disponible cubre la franja diurna en una ventana acotada; una captura sostenida durante un periodo más amplio permitiría estabilizar el componente y explorar variantes estacionales del puntaje, así como segmentar el ranking en franjas horarias representativas.

**Después:**
> La captura de tráfico cubre solo la franja diurna, y durante una ventana corta. Es poco. Con más semanas de datos el componente se estabilizaría y se podrían armar variantes del puntaje por franja horaria, pero eso costaba dinero de API que el proyecto no tenía.

### Ejemplo 6 — evitación de cópula + señalización → cópula directa
**Antes:**
> La interpretación correcta de M2 y M3 es, por tanto, la de un oracle restringido: ambos están deliberadamente sesgados a favor del catálogo de validación y, por ello, no son competidores de M1, sino instrumentos diagnósticos.

**Después:**
> M2 y M3 son instrumentos de diagnóstico. Están sesgados a favor del catálogo a propósito, así que compararlos contra M1 como si compitieran sería injusto con M1 y, peor, engañoso.

### Ejemplo 7 — paralelismo de lista → molde roto
**Antes:**
> El componente f_anchor codifica la proximidad ponderada por popularidad al centro comercial más relevante; f_gas aplica la misma lógica a las gasolineras; f_traf resume el tráfico vehicular promedio en el entorno inmediato; y f_socio traduce el estrato socioeconómico de la zona contenedora.

**Después:**
> f_anchor mide qué tan cerca y qué tan grande es el centro comercial dominante. f_gas hace lo mismo con gasolineras. El tráfico entra por f_traf, promediado en el entorno inmediato del punto, y el estrato del barrio entra por f_socio.

### Ejemplo 8 — hedging uniforme + conclusión-eco → convicción variable
**Antes:**
> La consecuencia metodológica es que el peso de la literatura w_socio = 0,20 es probablemente conservador: los techos supervisados sugieren un peso efectivo del orden de 0,30 a 0,45. Esta calibración es candidata a refinarse en una versión futura del trabajo.

**Después:**
> El peso de literatura w_socio = 0,20 se queda corto para Cali. Los dos techos supervisados, cada uno por su lado, apuntan a algo entre 0,30 y 0,45. Con 32 cargadores no da para recalibrar con confianza, así que el documento mantiene el valor de literatura y deja constancia de la diferencia.

---

## PROCESO

1. **Auditar.** Recorrer el texto y listar hallazgos: patrón → cita textual → ubicación. Buscar acumulaciones (un patrón aislado no condena; cinco en una página sí).
2. **Reescribir** los tramos afectados aplicando el catálogo, con estas restricciones duras:
   - La misma estrategia de corrección no se usa dos veces seguidas.
   - Cada párrafo reescrito incluye al menos una oración corta (4-12 palabras) si el original no la tenía.
   - Cifras, citas (`\cite`), referencias cruzadas (`\ref`, `\autoref`), etiquetas, fórmulas y términos en cursiva quedan idénticos.
   - El registro se conserva (una tesis sigue sonando a tesis; un post a post).
   - No introducir patrones nuevos: nada de guiones largos, ni «no es A, es B» fresco, ni tricolon nuevo.
3. **Re-auditar** el resultado contra el catálogo completo. Si la reescritura introdujo un patrón (suele pasar con las antítesis: se cuelan solas), corregir y repetir.
4. **Verificar integridad**: mismas cifras, mismas citas, mismo orden de secciones, mismo significado técnico.

## QUÉ NO TOCAR

- Texto ya marcado como humano por un detector externo (si el usuario dio ese mapa).
- Tablas de datos, fórmulas, bibliografía, bloques de código, literales de interfaz.
- Nombres propios y terminología técnica fijada (incluidas las cursivas de términos extranjeros).
- La voz del autor donde ya existe: si un tramo tiene una rareza personal, esa rareza se queda.

## FALSOS POSITIVOS (no «corregir» esto)

- Gramática perfecta por sí sola. Hay gente que escribe bien.
- Vocabulario académico normal (heterogéneo, estocástico, ponderado): solo el léxico mascota de la lista es señal.
- Un «sin embargo» o un «además» sueltos. La señal es la pila, no la pieza.
- Conectores necesarios en un argumento complejo: quitar todos rompe la lógica y eso también se nota.
