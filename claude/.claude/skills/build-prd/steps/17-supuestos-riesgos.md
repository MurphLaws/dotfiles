# Step 16 — Supuestos y Riesgos

## Objetivo

Capturar los supuestos sobre los que descansa el MVP (con cómo validarlos) y los riesgos potenciales (con probabilidad, impacto y mitigación).

## Preguntas

### P1 — Supuestos (libre, lista de 4-7)
> Vamos a listar los supuestos clave: cosas que damos por hechas para que el MVP funcione. Para cada uno necesito:
> - **Supuesto** (qué asumimos)
> - **Validación requerida** (cómo confirmar que es cierto antes de avanzar)
>
> Ejemplos:
> - "Los usuarios tienen smartphone con datos móviles" → validar con encuesta a los usuarios
> - "El ERP exporta pedidos en CSV" → validar con el equipo de TI
> - "Los clientes tienen WhatsApp activo" → pilotear con 5-10 clientes

Captura como `supuestos: [{ id: 'S1', supuesto, validacion }]`.

### P2 — Riesgos (libre, lista de 4-7)
> Ahora los riesgos: cosas que pueden salir mal. Para cada uno:
> - **Riesgo** (qué puede fallar)
> - **Probabilidad** (Baja / Media / Alta)
> - **Impacto** (Bajo / Medio / Alto / Crítico)
> - **Mitigación** (qué hacemos para reducir el riesgo o cómo respondemos si ocurre)
>
> Ejemplos:
> - "Baja adopción de la app por los conductores" — Media / Alto / Onboarding como beneficio + involucrar conductores en el diseño
> - "El ERP no permite exportación automática" — Media / Medio / Empezar con exportación manual

Para `probabilidad` e `impacto`, usa `AskUserQuestion` con las opciones (`Baja, Media, Alta` y `Bajo, Medio, Alto, Crítico`).

Captura como `riesgos: [{ id: 'R1', riesgo, probabilidad, impacto, mitigacion }]`.

### P3 — Riesgos típicos a explorar (auto-sugerir)
Si el usuario dice que terminó pero no mencionó algunos riesgos típicos, sugiérele:

- Adopción de usuarios finales (resistencia al cambio)
- Calidad de los datos existentes (limpieza, geocodificación, etc.)
- Disponibilidad del responsable técnico durante todo el sprint
- Integraciones con sistemas existentes
- Conectividad / infraestructura del usuario final
- Restricciones legales o de cumplimiento (datos personales, GDPR/LFPDPPP, etc.)

> Antes de cerrar la sección, ¿alguno de estos te parece relevante para tu caso?
> - Adopción del usuario
> - Calidad de los datos existentes
> - Disponibilidad del equipo técnico
> - Integraciones con sistemas existentes
> - Conectividad/infraestructura
> - Privacidad de datos / cumplimiento legal

Para los que el usuario marque, hacele las sub-preguntas.

## Output markdown

```markdown
## 16. Riesgos y Supuestos

### Supuestos

| # | Supuesto | Validación requerida |
|---|---|---|
{{filas de supuestos}}

### Riesgos

| # | Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|---|
{{filas de riesgos}}
```

Sigue el patrón del ejemplo en `references/ejemplo-logistics-ops-hub.md` (líneas 624-645).
