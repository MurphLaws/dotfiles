// Retro CRT para Ghostty — conserva los colores Catppuccin.
//
// Autocontenido: NO intenta detectar "qué pixel es fondo" (ese era el bug del
// gradiente anterior: dependía de umbrales de luminancia sRGB/lineal que nunca
// acertaban). En vez de eso aplica el efecto a TODA la pantalla, que es como
// funciona un CRT de verdad.
//
// Intensidad: NOTORIA pero limpia. Sin curvatura (no hay bisel/bordes) ni
// aberración cromática (no hay línea de colores en el borde) — eso era lo que
// ensuciaba los bordes antes y se mantiene desactivado.

// --- CONFIGURACIÓN (subir/bajar para más o menos efecto) ---
const float CURVATURE       = 0.0;    // 0 = pantalla plana, sin abombado
const float SCANLINE        = 0.20;   // profundidad de scanlines (bien marcadas)
const float VIGNETTE        = 0.18;   // oscurecimiento en los bordes (más retro)
const float ABERRATION      = 0.0022; // separación RGB mínima hacia los bordes

// Bloom: resplandor de fósforo que hace RESALTAR el texto (píxeles claros
// irradian un halo). Subir BLOOM_STRENGTH = texto más brillante/marcado.
const float BLOOM_STRENGTH  = 0.55;   // intensidad del halo del texto
const float BLOOM_THRESHOLD = 0.30;   // a partir de qué brillo un pixel "irradia"
const float BLOOM_RADIUS    = 1.6;    // qué tan lejos se esparce el halo (px)

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

    // --- Bloom: el texto (píxeles claros) irradia un halo y RESALTA ---
    // Promedia un vecindario 5x5 quedándose sólo con la parte brillante; ese
    // resplandor se suma encima, así el texto destaca sobre el fondo oscuro.
    vec2 texel = BLOOM_RADIUS / iResolution.xy;
    vec3 bloom = vec3(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec3 s = texture(iChannel0, clamp(uv + vec2(float(x), float(y)) * texel, 0.0, 1.0)).rgb;
            float bl = dot(s, vec3(0.2126, 0.7152, 0.0722));
            bloom += s * smoothstep(BLOOM_THRESHOLD, 1.0, bl);
        }
    }
    bloom /= 25.0;
    col += bloom * BLOOM_STRENGTH;

    float lum = dot(term.rgb, vec3(0.2126, 0.7152, 0.0722));

    // --- Scanlines (líneas horizontales tenues) ---
    // Las líneas oscurecen sobre todo el FONDO; sobre el texto (píxeles claros)
    // se atenúan casi por completo para no ensombrecerlo. Reutilizamos `lum`.
    float scanDepth = SCANLINE * (1.0 - smoothstep(0.25, 0.6, lum));
    float scan = 1.0 - scanDepth * (0.5 + 0.5 * sin(uv.y * iResolution.y * PI));
    col *= scan;

    // --- Viñeta (bordes más oscuros) ---
    float vig = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * 16.0;
    vig = clamp(pow(vig, VIGNETTE), 0.0, 1.0);
    col *= mix(1.0, vig, 0.6);

    fragColor = vec4(col, term.a);
}
