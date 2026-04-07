# Step 0 — Prepare Workspace

## Objective
Create the project structure and place the consolidated requirement documents where they can be referenced throughout the entire build process.

## Actions

### 1. Create project folder
```bash
mkdir <project-name>
cd <project-name>
git init
mkdir docs
```

Use a kebab-case name derived from the project/challenge name.

### 2. Consolidate requirements into canonical documents

Read all the input requirement files. Create two consolidated documents:

#### docs/PRD.md
Synthesize from the technical spec, user journey, and any general requirements. Must include:

```markdown
# <Project Name> — PRD

## Problema a resolver
[What problem does this solve? For whom?]

## Usuarios objetivo
[List each persona with their role and what they need]

## Casos de uso principales
[Numbered list of core use cases]

## Reglas de negocio
[Business rules, validation rules, conditional logic, constraints]

## Criterios de éxito
[Measurable criteria — what does "working" mean?]

## Alcance del MVP
[What's IN scope and what's explicitly OUT of scope]

## Integraciones
[External systems, APIs, data sources if any]

## Restricciones técnicas
[Platform requirements, technology constraints if specified]
```

#### docs/PANTALLAS.md
Synthesize from the UI spec and user journey. Each screen gets its own section:

```markdown
# <Project Name> — Pantallas del User Journey

## Pantalla 1: <Name>
- **Qué ve el usuario:** [Description of the screen layout]
- **Campos/Datos mostrados:**
  - Campo 1: tipo, validación, obligatorio/opcional
  - Campo 2: tipo, validación, obligatorio/opcional
- **Acciones disponibles:** [Buttons, links, interactions]
- **Al interactuar:** [What happens when user takes each action]
- **Navegación:** [Where does the user go next]
- **Estados especiales:** [Loading, error, empty, success states]

## Pantalla 2: <Name>
[Same structure...]
```

Follow the user journey order — the sequence matters for implementation later.

### 3. First commit
```bash
git add .
git commit -m "docs: agregar PRD y documento de pantallas"
git tag v0-docs
```

## Why This Matters
Claude Code works with repository context. Having the documents inside the project means they can be referenced directly in every subsequent step. Git history provides rollback points if something goes wrong.

## Verification
- [ ] `docs/PRD.md` exists and is complete
- [ ] `docs/PANTALLAS.md` exists with all screens documented
- [ ] Git repo initialized with first commit
- [ ] Tag `v0-docs` created
