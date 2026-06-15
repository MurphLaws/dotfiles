// Gradiente diagonal azul -> verde sobre el fondo por defecto de Ghostty,
// preservando texto y celdas con color de fondo explícito.
//
// Detección del fondo por LUMINANCIA (no por color exacto): el fondo por
// defecto (#1e1e2e) es casi negro, mientras que el texto y las celdas
// coloreadas son mucho más brillantes. Esto es robusto frente a las
// suposiciones de premultiplicado/espacio de color (a diferencia de comparar
// contra un color exacto, que rompía la detección y dejaba la pantalla sin
// gradiente). El pipeline de shaders de Ghostty opera en espacio LINEAL.

// sRGB -> lineal: los colores del gradiente se escriben en sRGB (como se ven),
// pero deben convertirse a lineal para el pipeline de Ghostty.
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// --- CONFIGURACIÓN ---
// Colores del gradiente en sRGB. Azul arriba-izquierda, verde abajo-derecha.
// Suficientemente saturados/brillantes para que el gradiente se vea claramente
// por encima del fondo casi negro.
const vec3  COLOR_AZUL  = vec3(0.165, 0.298, 0.678); // azul (#2a4cad)
const vec3  COLOR_VERDE = vec3(0.122, 0.541, 0.353); // verde (#1f8a5a)

// Opacidad del gradiente (igual que background-opacity de ghostty).
const float BG_OPACITY  = 0.95;

// Umbrales de luminancia (en lineal) para separar fondo de contenido.
// Fondo #1e1e2e -> lum lineal ~0.017. Texto/celdas coloreadas -> >>0.10.
const float LUM_LO = 0.025;
const float LUM_HI = 0.100;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // Diagonal: 0 en la esquina superior izquierda, 1 en la inferior derecha.
    // (uv.y crece hacia arriba: arriba-izq = (0,1), abajo-der = (1,0))
    float t = clamp((uv.x + (1.0 - uv.y)) * 0.5, 0.0, 1.0);
    vec3 grad = sRGBToLinear(mix(COLOR_AZUL, COLOR_VERDE, t));

    // Luminancia del pixel del terminal (lineal). El fondo es muy oscuro.
    float lum = dot(term.rgb, vec3(0.2126, 0.7152, 0.0722));

    // isFondo = 1 donde el pixel es fondo (oscuro), 0 donde hay contenido.
    float isFondo = 1.0 - smoothstep(LUM_LO, LUM_HI, lum);

    vec3  rgb   = mix(term.rgb, grad, isFondo);
    float alpha = mix(term.a, BG_OPACITY, isFondo);

    fragColor = vec4(rgb, alpha);
}
