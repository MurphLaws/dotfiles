# Step 17 — Ensamblar y Revisar

## Objetivo

Ensamblar el PRD final, validar coherencia, generar diagramas faltantes, listar pendientes y agregar la sección **"Notas para implementación con Claude Code"**.

## Acciones

### 1. Pasada de coherencia

Verifica que:

- [ ] **Cada capacidad Must-have tiene al menos una pantalla** (cruce step 06 ↔ step 07). Si una capacidad no tiene pantalla, alerta: "C5 'Dashboard operativo' no tiene pantalla en el inventario. ¿Olvidamos definirla?"
- [ ] **La sección de estética tiene paleta + tipografía + librería de componentes definidos** (step 08). Si falta cualquiera de estos tres, alerta — Claude Code no puede arrancar el frontend sin estos tokens. Si el usuario no dio referencias visuales, marca `[PENDIENTE — el resultado será un MVP genérico tipo Bootstrap]`.
- [ ] **Cada entidad del ERD aparece en alguna capacidad** (cruce step 06 ↔ step 10). Si una entidad existe pero ninguna capacidad la usa, alerta.
- [ ] **Cada KPI tiene baseline y meta** (step 16). Si falta alguno, márcalo como `[PENDIENTE]`.
- [ ] **Cada actor tiene al menos una fila en la matriz de interacciones** (step 04 ↔ step 12).
- [ ] **Cada acción de pantalla mapea a un endpoint o cambio de estado** (step 07 ↔ step 11). Sugiere endpoints faltantes.
- [ ] **Cada capacidad está asignada a una fase** (step 06 ↔ step 14). Si una Must-have no está, alerta.
- [ ] **No quedan placeholders** `{{...}}` ni `[PENDIENTE]` sin documentar en la lista final.

### 2. Listar pendientes

Recorre el estado y junta todos los `[PENDIENTE]`. Mostralos al usuario en una lista:

```
Pendientes detectados antes de ensamblar:
1. Sección 06-C3 / criterios_aceptacion_4 — usuario dijo "definir después"
2. Sección 09 / Pago / atributos — falta tipo de "monto"
3. ...

¿Quieres definirlos ahora o los dejo marcados como [PENDIENTE] en el PRD final?
```

Si el usuario quiere definirlos, hace las preguntas correspondientes. Si no, los deja marcados.

### 3. Notas para implementación con Claude Code

Esta es una sección **nueva** (no estaba en el template original) que cierra el PRD con todo lo que Claude Code necesita para construir la app de un solo intento.

#### 3.1 — Stack recomendado (auto-derivar de step 08)

```markdown
### Stack técnico recomendado

- **Frontend:** {{stack.frontend}} con TypeScript estricto
- **Backend:** {{stack.backend}} con TypeScript estricto
- **Base de datos:** {{stack.db}}
- **Auth:** {{auth.metodo}}
- **Hosting:** {{stack.hosting o "Vercel para frontend, Railway/Render para backend"}}
{{si hay componentes externos:}}
- **Servicios externos:**
  - {{cada componente con su rol}}
```

#### 3.2 — Orden recomendado de construcción

```markdown
### Orden recomendado de construcción

1. **Inicializar el proyecto** con el stack del punto anterior. Configurar TypeScript, linter, formateador, gitignore.
2. **Configurar el sistema de diseño** según el Capítulo 7 (Estética): instalar la librería de componentes elegida, importar tipografía(s), aplicar paleta de colores como CSS variables / Tailwind theme, configurar modo claro/oscuro si aplica. **Hacer esto antes de las pantallas** evita reescribirlas después.
3. **Schema y migraciones de la base de datos** según el ERD del Capítulo 9.
4. **Modelos / ORM** para cada entidad con sus validaciones del Capítulo 9.
5. **Auth** según el método elegido. Crear endpoint de login y middleware de autorización.
6. **Endpoints por capacidad** en el orden de la Fase 1, luego Fase 2, luego Fase 3 (Capítulo 13).
7. **Pantallas** en el orden del flujo principal (Capítulo 12), conectándolas a los endpoints conforme se construyen. Cada pantalla debe respetar los tokens del sistema de diseño y la densidad visual del Capítulo 7.
8. **Webhooks y cron jobs** del Capítulo 10.
9. **Seeds y fixtures** para tener datos de prueba para todas las pantallas.
10. **Testing manual end-to-end** validando cada criterio de aceptación del Capítulo 5.
11. **Revisión visual contra referencias del Capítulo 7**: comparar cada pantalla con las referencias del usuario y ajustar antes de cerrar.
```

#### 3.3 — Definition of Done por capacidad

Por cada capacidad, genera criterios de DoD a partir de los criterios de aceptación + endpoints + pantallas:

```markdown
### Definition of Done por capacidad

#### {{Cn — nombre}}
- [ ] Endpoints {{listar}} implementados y devuelven códigos HTTP correctos
- [ ] Validaciones de input rechazan datos inválidos con error claro
- [ ] Pantalla(s) {{listar}} muestran los estados loading/empty/error/success
- [ ] Cada criterio de aceptación pasa una prueba manual end-to-end
- [ ] Datos persisten correctamente en la base
{{si la capacidad usa servicios externos:}}
- [ ] Integración con {{servicio}} funciona en el entorno de pruebas
```

#### 3.4 — Comandos de instalación inicial

Genera los comandos exactos para arrancar:

```markdown
### Comandos de instalación inicial

\`\`\`bash
{{ej. para Next.js:}}
npx create-next-app@latest {{slug}} --typescript --tailwind --eslint --app
cd {{slug}}
{{instalar deps adicionales según componentes externos}}
\`\`\`

Variables de entorno necesarias (`.env.local`):
\`\`\`
{{lista de env vars derivadas de servicios externos: DATABASE_URL, STRIPE_SECRET_KEY, etc.}}
\`\`\`
```

### 4. Ensamblar PRD final

Lee `templates/prd-template.md`. Reemplaza cada `{{seccion_NN}}` con el markdown aprobado de cada step. Escribe el resultado en `ruta_salida` (definida en step 00).

### 5. Confirmar al usuario

> Listo. El PRD se generó en:
>
> `{{ruta_salida}}`
>
> Resumen:
> - {{N}} secciones completas
> - {{M}} capacidades documentadas ({{X}} Must-have, {{Y}} Should-have)
> - {{P}} pantallas, {{Q}} endpoints, {{R}} entidades en el ERD
> - {{S}} pendientes marcados como `[PENDIENTE]`
>
> Para arrancar la construcción con Claude Code:
> 1. Abre una nueva sesión de Claude Code en el directorio donde quieras crear la app
> 2. Pégale el PRD como primer mensaje
> 3. Dile: "Construye esta app siguiendo el orden recomendado en el último capítulo. Avísame antes de cada commit."
>
> ¿Quieres que actualice algo antes de cerrar?
```

Si el usuario pide cambios, vuelve al step correspondiente. Si no, marca la entrevista como completa en `.build-prd-state.json` (`completa: true`) y termina.
