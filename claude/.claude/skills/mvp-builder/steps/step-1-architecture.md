# Step 1 — Design Architecture

## Objective
Produce a complete architecture document that serves as the blueprint for all subsequent steps. This is the most important step — a good architecture makes everything else flow naturally.

## What to Design

Read `docs/PRD.md` and `docs/PANTALLAS.md` completely. Then design:

### 1. Stack tecnológico
Recommend technologies with justification for each choice. Prioritize:
- Mature technologies with good documentation
- MVP-appropriate (not enterprise-grade)
- Frameworks the requirements suggest (e.g., if the challenge mentions specific platforms)

**Default stack if nothing is specified:**
- Frontend: Next.js + Tailwind CSS (or React + Vite for simpler apps)
- Backend: Node.js + Express (or Next.js API routes if full-stack JS)
- Database: PostgreSQL with Prisma ORM (or SQLite for very simple MVPs)
- Auth: JWT with bcrypt

### 2. Estructura de carpetas
Complete folder structure for the entire project.

### 3. Modelo de datos
All entities with:
- Attributes and data types
- Primary keys, foreign keys, constraints
- Relationships with cardinality (1:1, 1:N, N:M)
- Include mermaid ER diagram

### 4. Endpoints del API
Organized by resource. For each endpoint:
- HTTP method + route
- Description
- Request body (if applicable)
- Response shape
- Auth requirements

### 5. Componentes de UI
Organized by screen (matching docs/PANTALLAS.md). For each:
- Component name
- Data it consumes (which API endpoint)
- Actions it triggers

### 6. Autenticación y autorización
- Auth strategy (JWT, sessions, etc.)
- Role-based access if needed
- Protected vs public routes

### 7. Variables de entorno
All env vars needed with descriptions.

## Output

Save everything to `docs/ARQUITECTURA.md`. Include mermaid diagrams where useful (ER diagram, API flow, component tree).

## Self-Review Before Committing

Check the architecture against these criteria:
- [ ] Every screen in PANTALLAS.md has corresponding API endpoints
- [ ] Every API endpoint has a corresponding data model
- [ ] Auth covers all protected routes mentioned in the PRD
- [ ] No over-engineering — this is an MVP
- [ ] Stack choices are justified and appropriate
- [ ] Folder structure matches the stack conventions

## Checkpoint
```bash
git add .
git commit -m "docs: arquitectura del proyecto aprobada"
git tag v0-arquitectura
```
