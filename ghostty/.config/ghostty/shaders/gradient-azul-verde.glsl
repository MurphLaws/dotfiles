// Gradiente diagonal azul -> verde sobre el fondo por defecto de Ghostty,
// preservando texto, celdas con color de fondo explícito y la transparencia.
//
// Cómo funciona: con background-opacity < 1 NO podemos detectar el fondo por
// su alpha (Ghostty entrega el fondo con alpha = background-opacity, no ~0).
// Por eso detectamos el fondo por su COLOR: donde el pixel coincide con el
// color de fondo por defecto (#1e1e2e) pintamos el gradiente; donde Ghostty
// dibujó texto o celdas con otro color, lo dejamos intacto.
//
// El pipeline de shaders de Ghostty opera en espacio LINEAL, así que la textura
// iChannel0 ya viene en lineal y comparamos contra el color de fondo en lineal.

// sRGB -> lineal: el color de fondo se configura en sRGB (el hex), pero la
// comparación contra la textura debe hacerse en espacio lineal.
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// --- CONFIGURACIÓN ---
// Colores del gradiente en sRGB (como se ven). Azul arriba-izquierda,
// verde abajo-derecha. Ajusta a tu gusto.
const vec3  COLOR_AZUL  = vec3(0.090, 0.165, 0.420); // azul profundo
const vec3  COLOR_VERDE = vec3(0.075, 0.345, 0.220); // verde profundo

// Color de fondo por defecto de Ghostty (= `background` del config, #1e1e2e).
const vec3  COLOR_FONDO = vec3(0.1176, 0.1176, 0.1804);

// Opacidad del gradiente (igual que background-opacity de ghostty).
const float BG_OPACITY  = 0.95;

// Tolerancia de detección del fondo (distancia en lineal). El fondo en lineal
// es muy oscuro (~0.01-0.03); cualquier texto o celda coloreada queda lejos.
const float TOL_LO = 0.010;
const float TOL_HI = 0.045;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // Diagonal: 0 en la esquina superior izquierda, 1 en la inferior derecha.
    // (uv.y crece hacia arriba: arriba-izq = (0,1), abajo-der = (1,0))
    float t = clamp((uv.x + (1.0 - uv.y)) * 0.5, 0.0, 1.0);
    vec3 grad = sRGBToLinear(mix(COLOR_AZUL, COLOR_VERDE, t));

    // Detección del fondo por proximidad de color (en lineal).
    // Con premultiplicado el color del fondo queda escalado por su alpha; lo
    // tenemos en cuenta usando el color de fondo también premultiplicado.
    vec3  fondoLin = sRGBToLinear(COLOR_FONDO) * BG_OPACITY;
    float dist     = distance(term.rgb, fondoLin);

    // isFondo = 1 donde el pixel es fondo por defecto, 0 donde hay contenido.
    float isFondo = 1.0 - smoothstep(TOL_LO, TOL_HI, dist);

    vec3  rgb   = mix(term.rgb, grad, isFondo);
    float alpha = mix(term.a, BG_OPACITY, isFondo);

    fragColor = vec4(rgb, alpha);
}
