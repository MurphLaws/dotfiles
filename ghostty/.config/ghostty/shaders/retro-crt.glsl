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
const float CURVATURE       = 0.0;    // 0 = pantalla plana, sin abombado
const float SCANLINE        = 0.20;   // profundidad de scanlines (bien marcadas)
const float VIGNETTE        = 0.18;   // oscurecimiento en los bordes (más retro)
const float GLOW_STRENGTH   = 0.36;   // intensidad del glow teal->orange
const float ABERRATION      = 0.0022; // separación RGB mínima hacia los bordes

// Colores del glow (sRGB). Teal arriba-izquierda, orange abajo-derecha.
// Ambos OSCUROS para contrastar con el texto blanco sin lavarlo.
const vec3 GLOW_TEAL   = vec3(0.02, 0.20, 0.21);
const vec3 GLOW_ORANGE = vec3(0.28, 0.12, 0.02);

const float PI = 3.14159265359;

// Curvatura tipo CRT abombada hacia AFUERA (como el vidrio de un monitor viejo)
// pero SIN bordes transparentes. El abombado por sí solo manda las esquinas
// fuera de [0,1] y deja franjas/bisel; para evitarlo aplicamos un OVERSCAN (un
// leve zoom) calibrado para que la esquina caiga justo en 1.0. Resultado: las
// líneas se curvan hacia afuera y la imagen sigue cubriendo toda la pantalla.
vec2 curveUV(vec2 uv) {
    uv = uv * 2.0 - 1.0;                 // -1..1
    float r2 = dot(uv, uv);              // dist² al centro (0 centro .. 2 esquinas)
    uv *= 1.0 + CURVATURE * r2;          // barril hacia afuera (esquinas se alejan)
    uv *= 1.0 / (1.0 + 2.0 * CURVATURE); // overscan: la esquina (r2=2) vuelve a 1.0
    return uv * 0.5 + 0.5;               // de vuelta a 0..1
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv0 = fragCoord.xy / iResolution.xy;
    vec2 uv  = clamp(curveUV(uv0), 0.0, 1.0); // clamp: jamás muestrear fuera => sin bordes

    // Aberración cromática sutil: más fuerte hacia los bordes. Las coords
    // desplazadas se fijan al rango válido para no asomar bordes transparentes.
    vec2 dir = uv - 0.5;
    float ab = ABERRATION * dot(dir, dir) * 2.0;
    vec4 term;
    term.r = texture(iChannel0, clamp(uv + dir * ab, 0.0, 1.0)).r;
    term.g = texture(iChannel0, uv).g;
    term.b = texture(iChannel0, clamp(uv - dir * ab, 0.0, 1.0)).b;
    term.a = texture(iChannel0, uv).a;

    vec3 col = term.rgb;

    // --- GLOW teal->orange (aditivo, sólo sobre zonas oscuras) ---
    // Teal en la esquina superior-izquierda, orange en la inferior-derecha.
    // Aquí uv.y=0 cae arriba en pantalla, así que "abajo" es uv.y grande:
    // t=1 (orange) cuando uv.x=1 (derecha) y uv.y=1 (abajo).
    float t = clamp((uv.x + uv.y) * 0.5, 0.0, 1.0);
    vec3 glow = mix(GLOW_TEAL, GLOW_ORANGE, t);
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
