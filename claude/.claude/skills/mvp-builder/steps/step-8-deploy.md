# Step 8 — Deploy Preparation

## Objective
Prepare the project for deployment so it can be accessed by test users via a public URL.

## Phase 8.1 — Prepare for Deploy

### Environment configuration
- Document ALL production env vars needed
- Ensure the app reads config from environment (not hardcoded)

### Dockerfile (if applicable)
```dockerfile
# Example for Node.js
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["npm", "start"]
```

### Ensure the app handles:
- Running migrations on startup (or provide a migrate command)
- Serving frontend as static files from the backend
- Health check endpoint works for platform monitoring
- Graceful shutdown on SIGTERM

## Phase 8.2 — Platform Recommendation

Based on the stack, recommend the simplest deploy option:

| Stack | Platform | Cost |
|-------|----------|------|
| Node.js + PostgreSQL | Railway, Render | Free or < $10/mo |
| Python + PostgreSQL | Railway, Fly.io | Free or < $10/mo |
| Full-stack JS (Next.js) | Vercel + Supabase | Free tier |
| Static + API | Netlify + Railway | Free tier |

### Provide deploy instructions
Add to README.md a "Deploy" section with step-by-step instructions for the recommended platform:

```markdown
## Deploy

### Option 1: Railway (recommended)
1. Create account at railway.app
2. Connect your GitHub repository
3. Add PostgreSQL plugin
4. Set environment variables: [list them]
5. Deploy

### Option 2: Docker
1. Build: `docker build -t project-name .`
2. Run: `docker run -p 3000:3000 --env-file .env project-name`
```

## Phase 8.3 — Final Verification

Before declaring the MVP ready:

- [ ] Production build works (`npm run build && npm start`)
- [ ] All tests pass (`npm test`)
- [ ] Health check responds 200
- [ ] Full user journey works in production mode
- [ ] No seed/test data in production config
- [ ] README has complete setup + deploy instructions
- [ ] All git tags exist: v0-docs, v0-arquitectura, v1-setup, v2-database, v3-backend, v4-frontend, v5-qa, v6-experiment, v7-deploy

## Checkpoint
```bash
git add .
git commit -m "feat: preparación para despliegue"
git tag v7-deploy
```

## Summary to Present

After this step, tell the user:

1. **What was built:** Stack, number of endpoints, number of screens, key features
2. **How to run locally:** Copy-paste commands
3. **How to deploy:** Recommended platform + steps
4. **Git tags:** List all checkpoints created
5. **Next steps:**
   - Write the experiment hypothesis in docs/EXPERIMENTO.md (if not already done)
   - Deploy to a test environment
   - Recruit 20-50 test users
   - Run the experiment for 2 weeks
   - Analyze metrics and decide: iterate, pivot, or scale
