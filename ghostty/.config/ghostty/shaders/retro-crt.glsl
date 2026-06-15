// Retro CRT sutil para Ghostty — conserva los colores Catppuccin.
//
// Autocontenido: NO intenta detectar "qué pixel es fondo" (ese era el bug del
// gradiente anterior: dependía de umbrales de luminancia sRGB/lineal que nunca
// acertaban). En vez de eso aplica el efecto a TODA la pantalla, que es como
// funciona un CRT de verdad. El gradiente azul->verde se añade como GLOW
// ADITIVO ponderado por la oscuridad del pixel: brilla sobre el fondo oscuro y
// es casi imperceptible sobre el texto claro, sin necesidad de detección.
//
// Intensidad: MUY SUTIL. Sin curvatura (no hay bisel/bordes) ni aberración
// cromática (no hay línea de colores en el borde).

// --- CONFIGURACIÓN (subir/bajar para más o menos efecto) ---
const float CURVATURE       = 0.0;    // 0 = pantalla plana, sin bordes/bisel
const float SCANLINE        = 0.035;  // profundidad de scanlines (apenas)
const float VIGNETTE        = 0.10;   // oscurecimiento en los bordes (leve)
const float GLOW_STRENGTH   = 0.38;   // intensidad del glow azul->verde
const float ABERRATION      = 0.0;    // 0 = sin línea de colores en el borde

// Colores del glow (sRGB). Azul arriba-izquierda, verde abajo-derecha.
const vec3 GLOW_AZUL  = vec3(0.12, 0.22, 0.55);
const vec3 GLOW_VERDE = vec3(0.07, 0.34, 0.20);

const float PI = 3.14159265359;

// Curvatura tipo CRT: deforma las uv hacia un barril sutil.
vec2 curveUV(vec2 uv) {
    uv = uv * 2.0 - 1.0;                 // -1..1
    vec2 off = uv.yx * uv.yx * CURVATURE; // ^2 -> barril
    uv += uv * off;
    return uv * 0.5 + 0.5;               // de vuelta a 0..1
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv0 = fragCoord.xy / iResolution.xy;
    vec2 uv  = curveUV(uv0);

    // Fuera de la pantalla curvada -> bisel transparente (deja ver el escritorio).
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

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
    float t = clamp((uv.x + (1.0 - uv.y)) * 0.5, 0.0, 1.0);
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
