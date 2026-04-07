# Step 7 — Experiment Preparation

## Objective
Prepare the MVP to measure whether the solution actually solves the problem. Implement tracking, define metrics, and optionally create an analytics dashboard.

## Phase 7.1 — Define Experiment (create docs/EXPERIMENTO.md)

Create `docs/EXPERIMENTO.md` with this structure:

```markdown
# Plan de experimento

## Hipótesis
[Falsifiable statement about what will happen when users try the MVP]
Example: "El 60% de los usuarios que inician el flujo principal lo completarán en menos de 5 minutos."

## Métricas

### Primaria
[The one number that tells you if the hypothesis is true or false]
- Metric: [name]
- Success threshold: [number]
- How measured: [description]

### Secundarias
- Time per screen (average)
- Drop-off rate per step
- Error frequency by type
- Feature usage distribution

## Diseño del experimento
- Duración estimada: 2 semanas
- Tamaño de muestra objetivo: 20-50 usuarios
- Criterio de éxito: [clear definition]
- Criterio de fracaso: [clear definition]
```

Derive the hypothesis and metrics from the PRD's acceptance criteria and success metrics.

## Phase 7.2 — Implement Tracking

Create a simple analytics service that records events in a database table:

### Analytics table schema
```sql
CREATE TABLE analytics_events (
  id SERIAL PRIMARY KEY,
  event VARCHAR(100) NOT NULL,
  user_id INTEGER REFERENCES users(id),
  metadata JSONB DEFAULT '{}',
  screen VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_analytics_event ON analytics_events(event);
CREATE INDEX idx_analytics_screen ON analytics_events(screen);
CREATE INDEX idx_analytics_created ON analytics_events(created_at);
```

### Events to track automatically
1. **page_view** — every navigation, with screen name
2. **action_completed** — every successful user action, with action name
3. **error_seen** — every user-visible error, with error type and message
4. **flow_started** — when user begins the main journey
5. **flow_completed** — when user finishes the main journey

### Summary endpoint
`GET /api/analytics/summary` returns:
```json
{
  "unique_users": 0,
  "conversion_rate": 0.0,
  "avg_flow_duration_seconds": 0,
  "screens_by_dropoff": [],
  "top_errors": [],
  "events_by_day": []
}
```

**IMPORTANT:** No external analytics services. Everything stays in the local database.

## Phase 7.3 — Analytics Panel (recommended)

Create a protected route at `/admin/metricas` (protected by simple password or admin role):

1. **User count** — total unique users who have used the app
2. **Conversion rate** — with simple daily chart
3. **Journey funnel** — how many users reached each screen, how many continued
4. **Error list** — most frequent errors

Keep it functional, not pretty. A table and basic numbers are enough.

## Checkpoint
```bash
git add .
git commit -m "feat: tracking de métricas y preparación para experimento"
git tag v6-experiment
```
