# Step 3 — Database & Models

## Objective
Create the complete database schema, application models, and realistic seed data. The database must be fully verified before writing any backend code.

## Phase 3.1 — Schema & Migrations

Read `docs/ARQUITECTURA.md`, data model section. Create:

- All tables/collections with columns and data types
- Primary keys, foreign keys, constraints (unique, not null, defaults)
- Indexes for the most frequent queries (based on PRD use cases)
- `created_at` and `updated_at` timestamps on ALL tables

Generate migration files and execute them:
```bash
# Prisma example
npx prisma migrate dev --name init

# Knex example  
npx knex migrate:latest

# Django example
python manage.py makemigrations && python manage.py migrate
```

Verify migrations ran without errors.

## Phase 3.2 — Application Models

Create models/entities that correspond to the database schema:

- **Validations** on the model level (required fields, formats, ranges)
- **Relationships** between models (hasMany, belongsTo, etc.)
- **Serialization methods** — what fields are exposed in the API vs hidden (e.g., password hashes never exposed)
- **Type definitions** if using TypeScript

## Phase 3.3 — Seed Data

Generate realistic test data:

- **At least 10 records per main entity**
- **Reflect the scenarios from docs/PANTALLAS.md** — so when building screens later, there's data to display
- **Include edge cases:**
  - Optional fields left empty
  - Records with complex relationships
  - Data in different states (active, completed, pending, cancelled)
  - Boundary values (max length strings, zero amounts, etc.)

Execute the seed:
```bash
# Prisma
npx prisma db seed

# Knex
npx knex seed:run

# Custom
node scripts/seed.js
```

## Verification

Run a verification query that proves the database works:

```sql
-- Example: show all tables, row counts, and test a JOIN
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM [main_entity];
SELECT u.name, e.* FROM [main_entity] e JOIN users u ON e.user_id = u.id LIMIT 5;
```

Confirm:
- [ ] All tables exist with correct columns
- [ ] Row counts match expected seed quantities
- [ ] JOIN queries return coherent data (relationships work)
- [ ] No orphaned foreign keys

## Checkpoint
```bash
git add .
git commit -m "feat: schema de base de datos, modelos y seed data"
git tag v2-database
```
