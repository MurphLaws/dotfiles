# Step 6 — Integration Tests & Quality

## Objective
Verify the entire system works end-to-end, clean up code quality issues, and confirm the production build works.

## Phase 6.1 — Integration Tests

Write tests that simulate what a real user would do:

1. **Registration and authentication flow** — register new user, login, access protected resource, logout
2. **Main journey happy path** — complete the primary user flow from start to finish
3. **Critical alternative flows** — important branches mentioned in the PRD
4. **Expired session handling** — what happens when the token expires mid-use

Use a test framework appropriate for the stack:
- **API integration:** supertest, pytest
- **E2E (optional for MVP):** Playwright, Cypress

```bash
npm test -- --testPathPattern="integration"
# All must pass
```

## Phase 6.2 — Quality Review

Systematic check for common issues:

### Code cleanliness
```bash
# Run linter — fix ALL warnings and errors
npm run lint -- --fix

# Search for debug artifacts
grep -r "console.log" src/ --include="*.ts" --include="*.tsx" --include="*.js"
grep -r "TODO" src/ --include="*.ts" --include="*.tsx" --include="*.js"
grep -r "FIXME" src/ --include="*.ts" --include="*.tsx" --include="*.js"
```

Remove all console.log statements, hardcoded data, and pending TODOs.

### Environment variables
- Verify ALL env vars are documented in `.env.example` with descriptions
- Verify NO secrets are hardcoded in the code

### Documentation
Verify `README.md` has clear instructions:
```markdown
# Project Name

## Prerequisites
- Node.js v18+
- PostgreSQL (or whatever DB)

## Setup
1. Clone the repo
2. cp .env.example .env
3. Edit .env with your values
4. npm install
5. npm run db:migrate (or equivalent)
6. npm run db:seed (or equivalent)
7. npm run dev

## Available Scripts
- npm run dev — start development server
- npm run build — production build
- npm run test — run all tests
- npm run lint — run linter
```

## Phase 6.3 — Production Build

```bash
# Build for production
npm run build

# Start from build (not dev mode)
npm start
# or
node dist/index.js
# or
npx next start
```

Verify from the production build:
- [ ] Server starts and `/health` responds 200
- [ ] Frontend loads correctly
- [ ] Main user journey works end-to-end
- [ ] No errors in browser console or server logs

## Checkpoint
```bash
git add .
git commit -m "feat: tests de integración, revisión de calidad y build"
git tag v5-qa
```
