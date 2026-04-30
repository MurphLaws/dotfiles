# Step 07 — Pantallas / UI (NUEVO, no estaba en el template original)

## Objetivo

Documentar cada pantalla de la app con suficiente detalle para que Claude Code pueda construirla sin preguntar. Esta sección es **crítica para one-shot build**.

## Preguntas

### P1 — Inventario de pantallas (libre, lista)
> Vamos a listar todas las pantallas (vistas) de la app. Incluye pantallas públicas y privadas (con sesión). Por ejemplo: "Login", "Registro", "Dashboard principal", "Detalle de cliente", "Listado de cobros", "Configuración de perfil". Apunta a 5-15 pantallas. Si la app tiene roles distintos, marca qué roles ven cada pantalla.

Captura como `pantallas: [{ id: "S1", nombre, roles_visibles: string[], ... }]`. IDs S1, S2, etc.

### P2 — Mapeo capacidad ↔ pantallas (libre, derivado)
A partir de las capacidades del step 06 y las pantallas listadas, **propón un mapeo** "capacidad → pantallas que la usan". Muestra al usuario y pide validar.

Ejemplo:
```
- C1 Geocodificación → pantalla S2 "Importar clientes" (botón Geocodificar)
- C3 Planificación asistida → pantalla S4 "Planificador del día"
```

Guarda en `pantallas[i].capacidades_usadas: [string]`.

### P3-Pn — Por cada pantalla (libre)
Para cada pantalla, haz estas sub-preguntas en orden:

#### P3.1 — Propósito
> {{Sn — nombre}}: ¿Qué propósito tiene esta pantalla? Una frase.

#### P3.2 — Componentes principales (lista)
> ¿Qué componentes principales tiene? Por ejemplo: "Header con logo y menú", "Tabla con 5 columnas (nombre, plan, estado, próximo cobro, acciones)", "Botón flotante 'Nuevo cobro'", "Sidebar con filtros".

Captura como lista. Para cada componente, captura tipo (header/tabla/formulario/card/etc.) y datos que muestra.

#### P3.3 — Estados visuales (AskUserQuestion multiSelect)
> ¿Qué estados visuales debe manejar?
- Loading (cargando datos)
- Empty (sin datos)
- Error (algo falló)
- Success (acción completada)
- Disabled (sin permisos / sin acceso)

#### P3.4 — Navegación (libre)
> ¿De qué pantallas se llega a esta? ¿A qué pantallas se va desde esta? Dame las rutas/enlaces.

Captura como `navegacion: { entrante: string[], saliente: string[] }`.

#### P3.5 — Acciones del usuario (lista)
> ¿Qué acciones puede hacer el usuario en esta pantalla? Por ejemplo: "ver detalle del cliente", "marcar pago como recibido", "editar plan", "exportar a CSV".

Cada acción debería mapear a un endpoint o cambio de estado (lo conectamos en step 10).

#### P3.6 — Responsive / breakpoints (AskUserQuestion)
- Solo desktop (escritorio, ≥1024px)
- Solo móvil (smartphone, ≤640px)
- Ambos (responsive completo desktop + móvil)
- Tablet también (3 breakpoints)

#### P3.7 — Notas de diseño (libre, opcional)
> ¿Tienes alguna preferencia de diseño visual o referencia? Por ejemplo: "estilo minimalista tipo Linear", "colores corporativos azul y blanco", "tablas densas tipo Notion". Si no tienes preferencia, salto esta y uso defaults sensatos.

## Output markdown

Encabezado de la sección:

```markdown
## 6. Pantallas y UI
```

Subsección con tabla de inventario:

```markdown
### Inventario de pantallas

| ID | Nombre | Roles que la ven | Capacidades que usa |
|---|---|---|---|
{{filas de pantallas}}
```

Por cada pantalla:

```markdown
### {{id}} — {{nombre}}

- **Propósito:** {{proposito}}
- **Componentes principales:**
{{lista bullet de componentes con su tipo y datos que muestra}}
- **Estados visuales:** {{lista de estados separados por coma}}
- **Navegación:**
  - Entrante: {{lista}}
  - Saliente: {{lista}}
- **Acciones del usuario:**
{{lista bullet de acciones}}
- **Responsive:** {{breakpoints}}
{{si hay notas de diseño:}}
- **Notas de diseño:** {{notas}}

---
```
