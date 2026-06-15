// Gradiente diagonal azul -> verde sobre el fondo por defecto de Ghostty,
// preservando la transparencia de la ventana.
//
// Cómo funciona: con transparencia, Ghostty entrega el fondo por defecto al
// shader con alpha ~0 (la capa de la ventana pinta la transparencia, no el
// shader). Por eso detectamos "fondo" por su alpha: donde no hay contenido
// pintamos el gradiente con la opacidad deseada; donde Ghostty sí dibujó texto
// o celdas con color de fondo explícito, las dejamos intactas.

// sRGB -> lineal: Ghostty pasa valores sRGB pero el pipeline de shaders opera
// en espacio lineal. Convertimos para que el color se vea como el hex elegido.
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// --- CONFIGURACIÓN ---
// Colores en sRGB (como se ven). Azul en la esquina superior izquierda,
// verde en la inferior derecha. Ajusta a tu gusto.
const vec3  COLOR_AZUL  = vec3(0.090, 0.165, 0.420); // azul profundo
const vec3  COLOR_VERDE = vec3(0.075, 0.345, 0.220); // verde profundo
const float BG_OPACITY  = 0.95; // igual que background-opacity de ghostty

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // Diagonal: 0 en la esquina superior izquierda, 1 en la inferior derecha.
    // (uv.y crece hacia arriba: arriba-izq = (0,1), abajo-der = (1,0))
    float t = clamp((uv.x + (1.0 - uv.y)) * 0.5, 0.0, 1.0);

    vec3 grad = sRGBToLinear(mix(COLOR_AZUL, COLOR_VERDE, t));

    // term.a > 0  => Ghostty pintó contenido aquí -> respetarlo.
    // term.a ~ 0  => fondo por defecto -> pintar gradiente.
    // smoothstep en vez de step para suavizar el borde antialias del texto.
    float isContent = smoothstep(0.0, 0.04, term.a);

    vec3  rgb   = mix(grad, term.rgb, isContent);
    float alpha = mix(BG_OPACITY, term.a, isContent);

    fragColor = vec4(rgb, alpha);
}
