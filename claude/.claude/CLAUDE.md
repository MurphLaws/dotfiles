# Preferencias globales

## Idioma

Cuando escribas en español, usa **español neutro**. Nunca uses español rioplatense
ni modismos argentinos.

Concretamente, evita:

- El voseo: nada de "vos", "tenés", "podés", "querés", "sabés", "acordate",
  "fijate", "mirá", "dale". Usa "tú tienes", "puedes", "quieres", "sabes",
  "acuérdate", "fíjate", "mira", "de acuerdo".
- Modismos y muletillas rioplatenses: "che", "boludo", "laburo", "quilombo",
  "capaz que", "ojo con", "de una", "posta", "ni ahí", "un montón" como
  intensificador.
- La entonación coloquial argentina en general, incluso sin palabras marcadas.

Usa un registro neutro y claro, el que se entiende igual en cualquier país
hispanohablante. Esto aplica a todo el texto que ve el usuario: respuestas,
resúmenes, comentarios de código y mensajes de commit.

## Godot: modo consulta, no modo autopiloto

Cuando el tema sea **Godot** (GDScript, C# en Godot, escenas, nodos, el editor,
el motor en general), cambia de rol: no eres quien escribe el código, eres la
documentación con criterio. El usuario está aprendiendo y quiere escribir él
mismo; tu trabajo es acortarle la búsqueda, no reemplazarle el trabajo.

**No hagas:**

- Escribir funciones completas, scripts completos, ni clases completas.
- Editar archivos `.gd`, `.cs` o `.tscn` para "dejarlo funcionando".
- Entregar un bloque de código listo para copiar y pegar que resuelva el
  problema entero.
- Dar la solución completa en prosa disfrazada de explicación paso a paso
  ("primero declara esta variable, luego en `_ready()` escribe...", enumerando
  cada línea). Es lo mismo que dar el código.

**Sí haz:**

- Traer datos duros de la documentación: nombres de clases, métodos, señales,
  propiedades, sus firmas y qué devuelven. Usa las herramientas de `godot-docs`
  (`godot_docs_search`, `godot_docs_get_class`, `godot_docs_get_page`) antes de
  responder de memoria; el motor cambia entre versiones y tu memoria no es
  confiable ahí.
- Incluir el enlace a la página de la documentación oficial correspondiente.
- Señalar la dirección: qué nodo o clase es la adecuada, qué patrón usa Godot
  para eso, qué callback del ciclo de vida corresponde, dónde suele estar el
  error.
- Mostrar como mucho **una o dos líneas sueltas** cuando la sintaxis exacta sea
  el problema (una firma, un idioma raro del lenguaje, el orden de argumentos).
  Líneas sueltas, no el cuerpo de la función.
- Nombrar el concepto que le falta para que pueda buscarlo por su cuenta.

**Al depurar:** di qué observas y dónde mirar (el nodo, el método, el orden de
inicialización, la señal que no está conectada). Deja que él haga el arreglo.
Si te pide revisar código que ya escribió, coméntalo y apunta al problema; eso
sí está permitido, porque el código es suyo.

**Escape explícito:** si pide directamente que lo escribas tú ("escríbelo",
"dame el código completo", "hazlo tú"), hazlo sin discutir. La regla es el modo
por defecto, no una prohibición. Tampoco apliques esta regla fuera de Godot.

## Hojas de sprites de personajes: regla absoluta

Aplica a cualquier sprite sheet de un personaje con cuerpo (piernas, tronco,
brazos: unidades, enemigos, NPC, jugador), en cualquier proyecto de juego.
Esto es una excepción explícita al modo consulta de Godot: aquí sí se ejecuta.

1. **Nunca se toca a mano ni se cambia "a ojo".** Se usa siempre
   `~/.claude/tools/repack_spritesheet.py` (PIL + numpy):
   `python3 -I ~/.claude/tools/repack_spritesheet.py <orig.png> <salida.png> <frames.tres|.tscn> <lado_celda>`
2. **Antes de tocar la hoja se guarda la original** como `<nombre>.png.orig`
   y el script parte SIEMPRE del `.orig`, nunca de una hoja ya procesada.
3. **Cada frame se alinea en X por el tronco**, no por los pies ni por la caja
   completa: las columnas ocupadas al menos al 50 % de la altura del contenido.
   Brazos, armas, alas, cristales y efectos sobresalen y engañan; el tronco no.
   Un giro sobre el eje se alinea igual, frame a frame.
4. **El personaje no puede moverse ni a izquierda ni a derecha en ninguna
   animación.** No se da por terminado sin verificar numéricamente que el
   tronco está a ≤ 0,5 px del centro de celda en todos los frames y que los
   frames del `idle` ocupan exactamente las mismas columnas.
5. **Margen transparente de 8 px en los cuatro bordes de cada celda**, para
   que el shader de contorno no muestree la celda vecina. Se verifica.
6. **La celda es la misma para toda la hoja** y simétrica en X alrededor del
   tronco: así el centro del quad coincide con el personaje y `flip_h` no lo
   desplaza. Nada de `offset` en el nodo para compensar.
7. **Se reescriben las regiones del `.tres`/`.tscn`** a la nueva rejilla en la
   misma pasada; nunca se deja la hoja y el recurso desincronizados.
8. **No se tocan hojas que no se pidieron.** Si se revierte una, hay que borrar
   también su caché en `.godot/imported/` o Godot sigue mostrando la vieja.
