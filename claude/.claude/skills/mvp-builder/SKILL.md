---
name: mvp-builder
description: "Build a complete MVP from product requirements (PRD, user journey, UI spec, tech spec). Executes 8 development phases end-to-end using Claude Code as copilot. Designed for Innovaitors challenge-style projects."
argument-hint: <requirements-folder-path>
user_invocable: true
---

# MVP Builder — De documentos de producto a aplicación funcional

You are an autonomous MVP builder. You will take a folder of product requirements and build a complete, functional MVP from scratch following an 8-step process. Each step has detailed instructions in the `steps/` subfolder of this skill.

## Arguments

- **Requirements path**: `$ARGUMENTS` — Path to a folder containing the project requirements in markdown. This folder should contain some combination of:
  - User journey document (user_journey*.md, user-journey*.md)
  - UI/Visual specification (ui*.md, especificacion_UI*.md, ui-spec*.md)
  - Technical features specification (tech*.md, especificacion_tecnica*.md, tech-features*.md)
  - PRD or general requirements (PRD*.md, requirements*.md, README.md)

If a single .md file is passed instead of a folder, treat it as a combined PRD.

## Before You Start

1. **Read ALL requirement files** in the provided path. Glob for `*.md` files and read every single one.
2. **Identify the project name** from the folder name or document titles.
3. **Create the project workspace** — ask the user where they want the project created, or default to the current working directory.
4. **Consolidate inputs** — Map whatever documents exist to the two canonical inputs the process needs:
   - `docs/PRD.md` — Synthesized from: tech spec + any general requirements + user journey context
   - `docs/PANTALLAS.md` — Synthesized from: UI spec + user journey (translate each touchpoint into a concrete screen description)
   
   If some documents are missing, extract what you can and note gaps. The user journey alone can provide both if the UI spec is absent.

## Execution Process

Execute each step sequentially. **Never skip a step.** After each step, create a git checkpoint (commit + tag). Read the detailed instructions for each step from the referenced file before executing.

**CRITICAL RULES:**
- After each step, verify the result works before moving to the next step.
- If something fails, fix it before advancing. Do not accumulate errors.
- Work ONE MODULE AT A TIME during backend and frontend phases.
- Always commit working code — never commit broken state.
- Prefer mature, well-documented technologies for the stack. This is an MVP, not enterprise architecture.

### Step 0 — Prepare Workspace
Read `steps/step-0-workspace.md` and execute.
- Create project folder, initialize git
- Place consolidated docs/PRD.md and docs/PANTALLAS.md
- First commit + verify docs are complete
- **Checkpoint:** `git tag v0-docs`

### Step 1 — Design Architecture
Read `steps/step-1-architecture.md` and execute.
- Analyze PRD + PANTALLAS and design full architecture
- Output: docs/ARQUITECTURA.md with stack, data model, API, components, auth, env vars
- Review for MVP-appropriateness (no over-engineering)
- **Checkpoint:** `git tag v0-arquitectura`

### Step 2 — Initialize Project
Read `steps/step-2-init.md` and execute.
- Create folder structure, install dependencies, configure tooling
- Verify project compiles and runs empty
- **Checkpoint:** `git tag v1-setup`

### Step 3 — Database & Models
Read `steps/step-3-database.md` and execute.
- Create schema, migrations, models, seed data
- Verify with JOIN queries across tables
- **Checkpoint:** `git tag v2-database`

### Step 4 — Backend & API
Read `steps/step-4-backend.md` and execute.
- Server structure (once), then endpoints + tests per module
- All tests must pass 100% before moving on
- **Checkpoint:** `git tag v3-backend`

### Step 5 — Frontend & Screens
Read `steps/step-5-frontend.md` and execute.
- Client setup, then screens one by one following user journey order
- Connect navigation, verify full flow
- **Checkpoint:** `git tag v4-frontend`

### Step 6 — Integration Tests & Quality
Read `steps/step-6-testing.md` and execute.
- Integration tests, quality review, production build
- **Checkpoint:** `git tag v5-qa`

### Step 7 — Experiment Preparation
Read `steps/step-7-experiment.md` and execute.
- Define metrics, implement tracking, optional analytics panel
- **Checkpoint:** `git tag v6-experiment`

### Step 8 — Deploy Preparation
Read `steps/step-8-deploy.md` and execute.
- Dockerfile/deploy config, README with deploy instructions
- **Checkpoint:** `git tag v7-deploy`

## Completion

When all 8 steps are done, present a summary to the user:
1. What was built (stack, features, screens)
2. How to run locally (commands)
3. How to deploy (platform + instructions)
4. Git tags created for each phase
5. What to do next (define experiment hypothesis, recruit test users)

## Handling Input Variations

The requirements from Innovaitors/discordoba follow this pattern:
- Folder name: `retoN:project_name-authors/`
- Contains 3 files: user journey, UI spec, tech features spec
- Written in Spanish
- Include: personas, stages with actions/emotions/friction/opportunities, field definitions, validation rules, acceptance criteria

When processing these, extract:
- **For PRD.md:** Problem statement, user personas, business rules, acceptance criteria, technical constraints, integrations
- **For PANTALLAS.md:** Each stage/etapa becomes a screen. For each: what the user sees, fields and their types/validation, actions available, navigation flow, error states
