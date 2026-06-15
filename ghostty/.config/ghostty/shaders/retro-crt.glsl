// Retro CRT para Ghostty — conserva los colores Catppuccin.
//
// Autocontenido: NO intenta detectar "qué pixel es fondo" (ese era el bug del
// gradiente anterior: dependía de umbrales de luminancia sRGB/lineal que nunca
// acertaban). En vez de eso aplica el efecto a TODA la pantalla, que es como
// funciona un CRT de verdad. El gradiente azul->verde se añade como GLOW
// ADITIVO ponderado por la oscuridad del pixel: brilla sobre el fondo oscuro y
// es casi imperceptible sobre el texto claro, sin necesidad de detección.
//
// Intensidad: NOTORIA pero limpia. Sin curvatura (no hay bisel/bordes) ni
// aberración cromática (no hay línea de colores en el borde) — eso era lo que
// ensuciaba los bordes antes y se mantiene desactivado.

// --- CONFIGURACIÓN (subir/bajar para más o menos efecto) ---
const float CURVATURE       = 0.08;   // curva la pantalla SIN bordes (ver curveUV)
const float SCANLINE        = 0.15;   // profundidad de scanlines (bien marcadas)
const float VIGNETTE        = 0.12;   // oscurecimiento en los bordes (leve)
const float GLOW_STRENGTH   = 0.32;   // intensidad del glow azul->verde (transparente)
const float ABERRATION      = 0.0;    // 0 = sin línea de colores en el borde

// Colores del glow (sRGB). Azul arriba-izquierda, verde abajo-derecha.
const vec3 GLOW_AZUL  = vec3(0.12, 0.22, 0.55);
const vec3 GLOW_VERDE = vec3(0.07, 0.34, 0.20);

const float PI = 3.14159265359;

// Curvatura tipo CRT SIN bordes. El intento anterior abombaba las uv hacia
// AFUERA, lo que mandaba las esquinas fuera de [0,1] y dejaba franjas/bisel
// transparentes. Aquí hacemos lo contrario: comprimimos las uv hacia ADENTRO
// según la distancia² al centro. Ningún pixel muestrea fuera de [0,1] => nunca
// hay borde, pero el centro se magnifica y los bordes se "doblan", dando la
// sensación de pantalla curva de un monitor viejo.
vec2 curveUV(vec2 uv) {
    uv = uv * 2.0 - 1.0;             // -1..1
    float r2 = dot(uv, uv);          // dist² al centro (0 centro .. 2 esquinas)
    uv *= 1.0 - CURVATURE * r2;      // comprime más cuanto más lejos del centro
    return uv * 0.5 + 0.5;           // de vuelta a 0..1
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv0 = fragCoord.xy / iResolution.xy;
    vec2 uv  = curveUV(uv0);

    // Aberración cromática sutil: más fuerte hacia los bordes.
    vec2 dir = uv - 0.5;
    float ab = ABERRATION * dot(dir, dir) * 4.0;
    vec4 term;
    term.r = texture(iChannel0, uv + dir * ab).r;
    term.g = texture(iChannel0, uv).g;
    term.b = texture(iChannel0, uv - dir * ab).b;
    term.a = texture(iChannel0, uv).a;

    vec3 col = term.rgb;

    // --- GLOW azul->verde (aditivo, sólo sobre zonas oscuras) ---
    // Azul en la esquina superior-izquierda, verde en la inferior-derecha.
    // Aquí uv.y=0 cae arriba en pantalla, así que "abajo" es uv.y grande:
    // t=1 (verde) cuando uv.x=1 (derecha) y uv.y=1 (abajo).
    float t = clamp((uv.x + uv.y) * 0.5, 0.0, 1.0);
    vec3 glow = mix(GLOW_AZUL, GLOW_VERDE, t);
    float lum = dot(term.rgb, vec3(0.2126, 0.7152, 0.0722));
    float darkness = clamp(1.0 - lum * 1.3, 0.0, 1.0); // ~1 en fondo, ~0 en texto
    col += glow * GLOW_STRENGTH * darkness;

    // --- Scanlines (líneas horizontales tenues) ---
    float scan = 1.0 - SCANLINE * (0.5 + 0.5 * sin(uv.y * iResolution.y * PI));
    col *= scan;

    // --- Viñeta (bordes más oscuros) ---
    float vig = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * 16.0;
    vig = clamp(pow(vig, VIGNETTE), 0.0, 1.0);
    col *= mix(1.0, vig, 0.6);

    fragColor = vec4(col, term.a);
}
