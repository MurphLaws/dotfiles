# Scope de las tareas (tarea inter-sesión)

El cierre de cada workbook lleva una **tarea inter-sesión** con esta forma por defecto.

## Forma de la tarea
Construir, **desde cero y de forma autocontenida**, funcionalidades reales del proyecto del cliente,
con Claude, para **aprender a construir** y llegar a la próxima sesión con algo **funcional por sí solo**,
aparte de producción.

Pasos que se le piden al participante:
1. Iniciar un **repositorio nuevo** con su propio `CLAUDE.md`, que defina el stack de **frontend y backend**
   y las convenciones del proyecto (en el stack con el que se sienta cómodo).
2. Con Claude, analizar qué se necesita para implementar cada funcionalidad (modelo de datos, endpoints,
   pantallas) y construirlas.
3. Dejar la entrega **autocontenida y funcional**: que se levante y se pueda probar sola, sin depender de producción.
4. Anotar qué faltaría para llevarlo a producción más adelante.

## Reglas
- **Solo lista las funcionalidades.** **No menciones cantidades** (ni cuántos participantes ni cuántas
  funcionalidades): eso es contexto interno, no va en el workbook.
- Toma las funcionalidades del **sprint correspondiente** del proyecto del cliente.

## Ejemplo: OMEDICALL (plataforma médica) — Sprint 1
Funcionalidades a construir:
- **CU-01 · Registro de paciente**
- **CU-02 · Registro de médico / prestador**
- **CU-03 · Completar perfil de salud del paciente**
- **CU-04 · Búsqueda de médico por filtros**
- **CU-07 · Ver perfil completo del médico**

(El proyecto OMEDICALL tiene 17 casos de uso en 3 sprints; backend FastAPI + PostgreSQL/pgvector, frontend a
definir por el equipo. Para otro cliente, sustituye por sus funcionalidades de sprint, sin mencionar conteos.)
