# Step 08 — Estética y Referencias Visuales

## Objetivo

Capturar la dirección visual de la app: **referencias concretas** (sitios web, screenshots, plantillas que el usuario admira), mood/sensación deseada, paleta de colores, tipografía, densidad visual y librería de componentes. Sin esto, Claude Code construye un MVP genérico tipo Bootstrap que el cliente va a odiar.

## Reglas estrictas

- **Pide referencias concretas, no descripciones abstractas.** "Quiero algo moderno" no sirve. "Quiero que se vea como Linear.app" sí sirve.
- **Acepta cualquier formato:** URLs de sitios, paths a imágenes locales, screenshots pegados al chat, capturas en clipboard, hasta dibujos hechos a mano fotografiados. Lo que importa es tener material visual.
- **Si el usuario pega imágenes**, descríbelas en el output del PRD (Claude Code de la sesión nueva no las va a tener cargadas — necesita la descripción textual). Captura: paleta de colores observada, estilo de tipografía, densidad, componentes característicos.
- **Si el usuario no tiene referencias**, propón 3 opciones default por categoría (ver P2 abajo) y deja que elija.

## Preguntas

### P1 — Referencias visuales que admira (libre, lista)
> Ahora la parte estética. Para que la app no termine viéndose como un MVP genérico, necesito que me muestres referencias visuales de sitios o apps que admires y quieras imitar en estilo. Tres formas de hacerlo:
>
> 1. **URLs**: pégame links de sitios web cuyo estilo te guste (ej. "linear.app", "stripe.com", "notion.so").
> 2. **Imágenes**: si tienes screenshots o capturas de plantillas que te gusten, pégame el path local o súbelas al chat. También puedes copiar una imagen al portapapeles y decírmelo.
> 3. **Apps que ya uses**: dime nombres de apps que te gusten visualmente aunque sean de otro rubro.
>
> Dame entre 3 y 6 referencias. Para cada una, en una frase decime qué te gusta de ella ("la limpieza de Linear", "los colores cálidos de Notion", "la densidad informativa de Bloomberg").

Captura como `estetica.referencias: [{ tipo: 'url'|'imagen'|'app', valor, que_le_gusta }]`.

**Si el usuario menciona haber copiado al portapapeles**, sugiérele invocar el skill auxiliar `/read-clipboard` para que Claude lea la imagen, después continúa.

**Si pega URLs**, considera invocar WebFetch para abrir el sitio, capturar paleta visible y describir el estilo en 2-3 líneas. Esto enriquece el PRD final.

**Si pega paths a imágenes locales**, leelas con la herramienta Read (admite PNG/JPG) y describilas: paleta dominante, tipo de tipografía (serif/sans/mono), densidad visual, mood general.

### P2 — Mood / sensación deseada (AskUserQuestion, multiSelect)
> ¿Qué sensaciones queres que transmita la interfaz? (puedes elegir varias)

- Minimalista y limpia (espacios amplios, pocos elementos por pantalla)
- Densa e informativa (Bloomberg/Notion — mucho dato visible a la vez)
- Cálida y amigable (curvas suaves, ilustraciones, tonos cálidos)
- Profesional y corporativa (rectas, neutros, autoridad)
- Lúdica y juguetona (animaciones, microinteracciones, colores vivos)
- Lujosa y premium (mucho espacio negativo, tipografía serif, oro/negro)
- Técnica y geek (mono fonts, terminal vibes, oscuro por defecto)
- Editorial (tipo revista, tipografía protagonista, fotografías grandes)

Captura como `estetica.mood: string[]`.

### P3 — Paleta de colores (libre o derivado)
> ¿Tienes colores corporativos o de marca que quieras usar? Si es así, decime los hex (ej. "#1B4D3E para primario, #F5F1E8 para fondo"). Si no tienes paleta definida, podemos:
> 1. Derivarla de las referencias del paso 1 (yo te propongo y tú validás)
> 2. Empezar con una paleta neutra (grises + un acento) y refinarla después

Si el usuario tiene paleta: captura `estetica.paleta: { primario, secundario?, acento, fondo, texto, error, exito }` con hex codes.

Si no tiene: a partir de las referencias de P1, **propón** una paleta de 5 colores con hex y muéstraselos. Pídele validación.

### P4 — Tipografía (AskUserQuestion)
> ¿Qué estilo de tipografía prefieres?

- Sans-serif moderna (Inter, Geist, SF Pro — default seguro)
- Sans-serif geométrica (Outfit, Space Grotesk — más distintiva)
- Serif clásica (Charter, Source Serif — editorial/premium)
- Mono para todo (JetBrains Mono, Geist Mono — técnica)
- Mix: serif para títulos + sans para cuerpo (editorial moderno)

Captura como `estetica.tipografia: { titulos, cuerpo, mono? }`. Default si elige sans-serif moderna: `Inter` para todo, `Geist Mono` para código.

### P5 — Densidad visual (AskUserQuestion)
> ¿Qué densidad visual prefieres?

- Compacta (Notion, Linear — mucha info por pantalla, padding chico)
- Equilibrada (Stripe, Vercel — espacios moderados)
- Generosa (Apple, Things — mucho espacio negativo, cards grandes)

Captura como `estetica.densidad: 'compacta'|'equilibrada'|'generosa'`.

### P6 — Modo claro/oscuro (AskUserQuestion)
- Solo claro (default)
- Solo oscuro
- Ambos con toggle de usuario
- Automático (sigue OS) con toggle override

Captura como `estetica.modos: string[]`.

### P7 — Librería de componentes (AskUserQuestion, con recomendación contextual)
Recomendación según stack del step 09 (que aún no llegó, pero podés inferir):
- Si React: shadcn/ui (recomendado, modern), Mantine, Chakra UI
- Si Vue: PrimeVue, Vuetify
- Si vanilla: Tailwind UI puro

> ¿Qué librería de componentes preferís?
- shadcn/ui (Recomendado para React — copy-paste, customizable, ya estilizado tipo Linear/Vercel)
- MUI (Material-UI — más opinionado, bueno si querés look "Google")
- Custom desde cero con Tailwind (máximo control, más trabajo)
- No tengo preferencia, elegí lo que sea estándar moderno

Captura como `estetica.componentes: string`.

### P8 — Iconografía (AskUserQuestion)
- Lucide (Recomendado — open source, consistente, 1000+ icons)
- Heroicons (de Tailwind, más cuadrados)
- Phosphor (más juguetón, varias densidades)
- Sin preferencia

Captura como `estetica.iconos: string`.

### P9 — Animaciones (AskUserQuestion)
- Mínimas (solo transiciones de hover/focus básicas)
- Sutiles (fades, slides cortos en cambios de página y modales — recomendado)
- Generosas (microinteracciones en botones, animaciones de entrada por elemento)
- Ninguna (la app debe sentirse "instantánea", sin animaciones)

Captura como `estetica.animaciones: string`.

### P10 — Inspiración inversa (libre, opcional)
> ¿Hay algún sitio o app cuyo estilo NO quieras que se parezca al tuyo? A veces es más fácil definirlo por contraste. Por ejemplo: "no quiero que se vea como un banco tradicional", "no quiero algo tipo Bootstrap genérico".

Captura como `estetica.anti_referencias: string[]`. Si no responde, deja `[]`.

## Output markdown

```markdown
## 7. Estética y Referencias Visuales

### Mood y sensación

{{estetica.mood unidos por " · ", ej. "Minimalista · Profesional"}}

### Referencias visuales

{{Por cada referencia:}}
- **{{tipo}}**: `{{valor}}` — {{que_le_gusta}}
  {{si es URL o imagen, agregar descripción del estilo capturada por la IA, ej.: "Estilo capturado: paleta neutra con acento esmeralda, tipografía Inter geométrica, espaciado generoso, cards con border sutil y radius medio."}}

### Tokens de diseño

| Token | Valor |
|---|---|
| Color primario | `{{paleta.primario}}` |
| Color secundario | `{{paleta.secundario o "n/a"}}` |
| Color de acento | `{{paleta.acento}}` |
| Fondo | `{{paleta.fondo}}` |
| Texto principal | `{{paleta.texto}}` |
| Color de error | `{{paleta.error}}` |
| Color de éxito | `{{paleta.exito}}` |
| Tipografía títulos | `{{tipografia.titulos}}` |
| Tipografía cuerpo | `{{tipografia.cuerpo}}` |
| Tipografía mono | `{{tipografia.mono o "n/a"}}` |
| Densidad | {{densidad}} |
| Modo de color | {{modos unidos por ", "}} |

### Decisiones de UI

- **Librería de componentes:** {{componentes}}
- **Iconografía:** {{iconos}}
- **Animaciones:** {{animaciones}}

### Anti-referencias (lo que NO queremos)

{{si hay anti_referencias:}}
{{lista bullet}}
{{si no:}}
*Sin anti-referencias específicas.*

### Notas para el implementador

A partir de esta sección, Claude Code debe:
1. Configurar Tailwind con los tokens de color exactos como variables CSS (`--color-primary`, etc.).
2. Instalar la librería de componentes elegida y usarla como base — no rediseñar desde cero.
3. Importar la(s) tipografía(s) elegida(s) desde Google Fonts o Fontsource.
4. Mantener la densidad visual en cada pantalla (padding, gaps, font-sizes consistentes con el preset elegido).
5. Aplicar el preset de animaciones seleccionado de forma consistente (no mezclar "ninguna" con "generosas").
6. Si hay referencias visuales, usarlas como criterio de revisión: cada pantalla debe sentirse "como X" (donde X es la referencia principal).
```

## Casos especiales a manejar

- **Si el usuario sube una imagen y describes contenido sensible** (logos de marcas registradas, etc.), notalo pero no copies pixel-perfect; trata la referencia como "inspiración" no "imitación".
- **Si las referencias son contradictorias** (ej. "minimalista como Apple" + "denso como Bloomberg"), señálalo: "Estas dos referencias apuntan a estilos opuestos. ¿Cuál prima si hay que elegir?"
- **Si el usuario no tiene paleta y no quiere derivarla**, default neutro: `#0F172A` (slate-900) primario, `#FFFFFF` fondo claro / `#0A0A0A` fondo oscuro, `#3B82F6` acento (azul), grises Tailwind para texto.
