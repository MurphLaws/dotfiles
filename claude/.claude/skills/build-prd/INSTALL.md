# Instalación del skill `build-prd` para Claude Code

Este skill convierte a Claude Code en un entrevistador estructurado que te genera un PRD completo (Product Requirements Document) en ~90 minutos, listo para arrastrar a una sesión nueva de Claude Code y construir la app en un solo intento.

## Requisitos previos

- Tener instalado **Claude Code** (CLI). Si no lo tienes:
  - Mac/Linux: `curl -fsSL https://claude.ai/install.sh | bash`
  - Windows (PowerShell): `irm https://claude.ai/install.ps1 | iex`
  - Verificar con `claude --version`
- Una sesión iniciada (`/login` con tu cuenta de Anthropic).

## Instalación (1 minuto)

### Opción A — Mac / Linux

```bash
# 1. Crea el directorio de skills si no existe
mkdir -p ~/.claude/skills

# 2. Descomprime este paquete dentro de ~/.claude/skills/
# Si tienes el .tar.gz:
tar xzf build-prd-skill.tar.gz -C ~/.claude/skills/
# Si tienes el .zip:
unzip build-prd-skill.zip -d ~/.claude/skills/

# 3. Verifica
ls ~/.claude/skills/build-prd/
# Debes ver: SKILL.md  steps/  templates/  references/  INSTALL.md
```

### Opción B — Windows

1. Crea (si no existe) la carpeta `C:\Users\<tu-usuario>\.claude\skills\`
2. Descomprime el paquete dentro de esa carpeta. Te debe quedar `C:\Users\<tu-usuario>\.claude\skills\build-prd\`
3. Verifica que existe `SKILL.md` dentro de `build-prd\`

## Uso

1. Abre una terminal en cualquier directorio donde quieras que se genere el PRD (recomendado: una carpeta vacía nueva, ej. `mkdir mi-app && cd mi-app`).
2. Ejecuta `claude` para iniciar Claude Code.
3. Dentro de Claude Code, escribe:
   ```
   /build-prd
   ```
4. Responde las preguntas que el skill te haga. Son 18 secciones; toma entre 60 y 90 minutos completar todas.
5. Puedes pausar cuando quieras escribiendo "pausemos" o cerrando la sesión. Tu progreso queda guardado en `.build-prd-state.json` en el directorio. Para reanudar, vuelve a correr `claude` en el mismo directorio y escribe `/build-prd` — el skill detecta el estado y pregunta si continuar.
6. Al terminar, tendrás un archivo `PRD_<nombre-proyecto>_v0.1.md` en el directorio. Ese es el output.

## Cómo construir la app con el PRD

1. Abre una sesión NUEVA de Claude Code en otro directorio (donde quieras crear la app):
   ```bash
   mkdir mi-app && cd mi-app
   claude
   ```
2. Pega el contenido completo del PRD como primer mensaje.
3. Dile a Claude algo como:
   > "Construye esta app siguiendo el orden recomendado en el último capítulo (Notas para Claude Code). Avísame antes de cada commit."
4. Claude empezará a ejecutar los comandos de instalación, configurar la base de datos, levantar el backend, las pantallas, etc.

## ¿Qué incluye el skill?

El skill te entrevista en 18 secciones cubriendo:

1. Meta del proyecto (nombre, versión, fecha)
2. Resumen ejecutivo
3. Problema y contexto
4. Usuarios y actores clave
5. Procesos AS-IS y TO-BE (genera diagrama mermaid automático)
6. Funcionalidades y capacidades con criterios de aceptación
7. Pantallas y UI
8. **Estética y referencias visuales** (URLs, imágenes que admires, paleta, tipografía)
9. Arquitectura técnica
10. Modelo de datos con ERD (genera diagrama mermaid automático)
11. Contratos de API
12. Matriz de interacciones
13. Flujo principal narrativo
14. Plan de implementación por fases
15. Alcance del MVP (incluye / no incluye)
16. KPIs operativos
17. Supuestos y riesgos
18. Notas para implementación con Claude Code (stack, comandos de instalación, DoD)

## Soporte

Si hay un problema con el skill, puedes:
- Escribir `claude doctor` en la terminal para verificar la instalación de Claude Code.
- Borrar la carpeta `~/.claude/skills/build-prd/` y reinstalar desde el paquete.
- Borrar `.build-prd-state.json` en el directorio donde estabas trabajando para empezar de cero.

---

*Skill generado para uso interno. Versión 1.0.*
