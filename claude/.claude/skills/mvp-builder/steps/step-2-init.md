# Step 2 — Initialize Project

## Objective
Create the real project structure based on the approved architecture. After this step, the project should compile and run (empty) without errors.

## Actions

Based on `docs/ARQUITECTURA.md`:

### 1. Create folder structure
Create the exact folder structure defined in the architecture document.

### 2. Initialize and install dependencies
```bash
# For Node.js projects
npm init -y
npm install <all-dependencies-from-architecture>
npm install -D <dev-dependencies>
```

Install ALL dependencies that will be needed — don't leave any for later.

### 3. Configure tooling
- ESLint + Prettier (or equivalent for the stack)
- TypeScript config if using TS
- Tailwind config if using Tailwind

### 4. Environment setup
Create `.env.example` with ALL variables documented:
```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Auth
JWT_SECRET=your-secret-key-here
JWT_EXPIRATION=24h

# Server
PORT=3000
NODE_ENV=development
```

Copy to `.env` for local development.

### 5. Git ignore
Create `.gitignore` appropriate for the stack:
```
node_modules/
.env
.next/
dist/
*.log
```

### 6. Configure scripts
In `package.json` (or equivalent):
```json
{
  "scripts": {
    "dev": "...",
    "build": "...",
    "start": "...",
    "test": "...",
    "lint": "..."
  }
}
```

## Verification

Run these commands and confirm no errors:
```bash
# Check structure
ls -la

# Try to run (should start empty without errors)
npm run dev

# Try to build
npm run build

# Try to lint
npm run lint
```

If there are errors, fix them before proceeding.

## Checkpoint
```bash
git add .
git commit -m "setup: inicializar proyecto con estructura y dependencias"
git tag v1-setup
```
