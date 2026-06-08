# Plantilla de workbook (esqueleto NFM)

Esqueleto para adaptar. Respeta la indentación con TAB. Las imágenes (`![](URL)`) se insertan si hay
URL pública; si no, deja el espacio e indícale al usuario dónde pegarlas. La indentación con tabs aquí
se muestra con `»` solo para que se vea; al escribir, usa TABS reales.

```
<párrafo de bienvenida: qué van a lograr en esta sesión>
**Objetivo:** <en prosa, los objetivos integrados, no en lista>
<callout icon="🧭" color="blue_bg">
»**Módulo:** ... · **Duración:** ... · **Modalidad:** ... · **Temario:** ...
</callout>
---
## ⚙️ Pre-requisitos {toggle="true"}
»<checklist con - [ ]>
## 🗓️ Agenda {toggle="true"}
»<table fit-page-width="true" header-row="true"> ... (sin tiempos si el usuario no los quiere; columna "Tipo": 💬 Charla / 🛠️ Práctico) </table>
## 🎯 Objetivos {toggle="true"}
»<lista numerada>
---
![](URL_IMAGEN_BLOQUE_1)
# 🌐 Bloque 1 — <título> {toggle="true"}
»💬 *Charla con discusión abierta.*
»### <subtítulo>
»<prosa narrativa con hilo conductor>
»<details><summary>📊 Los números</summary> ... </details>
»<callout color="yellow_bg"> <mensaje central> </callout>
---
![](URL_IMAGEN_BLOQUE_2)
# 🛠️ Bloque 2 — <título> {toggle="true"}
»🛠️ **Práctico** · *...*
»### 🛠️ Ejercicio 2.1: <título> {toggle="true"}
»»**Objetivo.** ...
»»**Contexto y preparación.** ...
»»**Procedimiento.** ...
»»```text
<prompt a usar>
»»```
»»<details><summary>📋 Solución / Plantilla</summary> ... </details>
»»> **Pregunta de cierre:** ...
---
## 🏁 Cierre y tarea inter-sesión {toggle="true"}
»**Tarea inter-sesión.** <ver scope-tareas.md; lista de funcionalidades, sin conteos>
»**Lectura:** [Título](URL)
»**Videos para ver:**
»<video src="https://www.youtube.com/watch?v=ID"></video>
```

## Ejercicios "consume la API y construye"
Cuando uses la API de práctica (ver SKILL.md, Activos por defecto):
- Primer ejercicio del bloque práctico: pedir a Claude que **genere un `DOCS.md`** desde la URL de la API
  (todos los endpoints, valores y modelo de datos) para usarlo como contexto.
- Ejercicio de **contexto**: construir un dashboard con/ sin `CLAUDE.md` y comparar (el `CLAUDE.md` lo
  escribieron en el bloque de CLAUDE.md, en su stack).
- Ejercicio de **detalle del prompt**: el mismo dashboard con tres prompts de detalle creciente
  (mínimo / con la operación / completo con filtros y tests unitarios); tabla de comparación.
