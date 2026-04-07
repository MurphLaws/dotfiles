# Step 4 — Backend & API

## Objective
Build the complete backend: server structure (once), then endpoints + tests module by module. All tests must pass 100% before moving to frontend.

**CRITICAL: Work ONE MODULE at a time. Do not implement all endpoints in a single pass.**

## Phase 4.1 — Server Structure (once)

Create the base server according to `docs/ARQUITECTURA.md`:

1. **Server configuration** — port, CORS, body parsing, request logging
2. **Database connection** — with error handling and auto-reconnect
3. **Authentication middleware** — as defined in architecture (JWT validation, session check, etc.)
4. **Global error handler** — consistent JSON responses:
   ```json
   {
     "error": true,
     "code": "ERROR_CODE",
     "message": "Human readable message",
     "timestamp": "2024-01-01T00:00:00.000Z"
   }
   ```
5. **Router setup** — main router that will import module routes
6. **Health check** — `GET /health` that verifies database connection, returns 200

### Verify
Start the server and confirm:
```bash
curl http://localhost:3000/health
# Should return 200 with DB status
```

## Phase 4.2 — Implement Endpoints (per module)

Identify the modules from the architecture (e.g., users, products, orders, reports). For EACH module, implement:

### For each endpoint in the module:
1. **Validate all inputs** — reject invalid data with 400 and descriptive message
2. **Implement business logic** — if complex, separate into a services file
3. **Handle errors:**
   - 400: Invalid input
   - 401: Not authenticated
   - 403: Not authorized
   - 404: Resource not found
   - 409: Conflict (duplicate, etc.)
   - 500: Internal server error
4. **Return response** in the format defined in the architecture

### After implementing each endpoint:
Test it with a quick request to verify it works:
```bash
# Example
curl -X POST http://localhost:3000/api/users -H "Content-Type: application/json" -d '{"name":"Test","email":"test@test.com"}'
```

## Phase 4.3 — Unit Tests (per module)

After implementing each module's endpoints, write tests covering:

1. **Happy path** — valid request returns expected response
2. **Validation** — each required field missing returns 400 with descriptive error
3. **Authentication** — request without token returns 401
4. **Not found** — non-existent ID returns 404
5. **Edge cases** — specific scenarios from the PRD for this module

Use the seed data for tests.

### Run module tests:
```bash
npm test -- --testPathPattern="module-name"
```
All must pass before moving to the next module.

## Phase 4.4 — Full Backend Verification

After ALL modules are implemented and tested:

```bash
# Run ALL tests together
npm test

# Expected output: X tests, X passed, 0 failed
```

If any test fails, fix it and re-run until 100% pass.

## Module Execution Order

Follow dependency order:
1. **Auth/Users module first** — other modules often depend on user authentication
2. **Core entity modules** — the main business objects
3. **Relationship modules** — modules that connect core entities
4. **Utility modules** — analytics, reports, admin functions

## Checkpoint
```bash
git add .
git commit -m "feat: backend completo con API, lógica de negocio y tests"
git tag v3-backend
```
