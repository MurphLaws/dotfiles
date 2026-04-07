# Step 5 — Frontend & Screens

## Objective
Build the complete frontend: client setup first, then screens one by one following the user journey order, then connect navigation.

## Phase 5.1 — Client Setup

Configure the frontend according to `docs/ARQUITECTURA.md`:

1. **Framework setup** with routing configured
2. **HTTP client** — configured with API base URL and automatic auth token handling:
   ```typescript
   // Example: axios instance with interceptor
   const api = axios.create({ baseURL: '/api' });
   api.interceptors.request.use((config) => {
     const token = localStorage.getItem('token');
     if (token) config.headers.Authorization = `Bearer ${token}`;
     return config;
   });
   ```
3. **Main layout** — navigation structure, content container, footer if applicable
4. **Global styles** — typography, colors, spacing. Clean and functional (MVP aesthetic)
5. **Reusable components** that appear across multiple screens:
   - Buttons (primary, secondary, danger, loading state)
   - Form inputs (text, select, textarea, date, number — with error display)
   - Cards / list items
   - Tables (with empty state)
   - Modals / dialogs
   - Loading spinner / skeleton
   - Error display (with retry button)
   - Empty state (with descriptive message)
   - Toast / notification for success/error feedback

### Verify
```bash
npm run dev
# Frontend compiles, shows empty layout, no console errors
```

## Phase 5.2 — Implement Screens One by One

Open `docs/PANTALLAS.md`. Implement each screen **in user journey order**.

For EACH screen:

1. **Connect with the corresponding API endpoints** — fetch data on mount, submit on actions
2. **Loading state** — show spinner/skeleton while data loads
3. **Error state** — show error message with retry option if API fails
4. **Empty state** — show descriptive message when there's no data
5. **Form validation** — inline error messages, disable submit while invalid
6. **Action feedback:**
   - Buttons disable on click to prevent double-submit
   - Success confirmation (toast, redirect, or message)
   - Error messages inline or as toast
7. **Responsive** — works on mobile and desktop

### Implementation order (follow user journey):
Example: Registration → Login → Dashboard → Detail → Action → Confirmation

After implementing each screen, verify it works with the seed data before moving to the next.

## Phase 5.3 — Connect Navigation

After all screens are implemented, verify the complete navigation:

1. **Correct routes** — each screen at the right URL
2. **Links and buttons** — navigate to the correct destination
3. **Post-action navigation** — after create/edit → redirect to list, after delete → redirect appropriately
4. **Back button** — works consistently
5. **Protected routes** — redirect to login if no session
6. **404 page** — exists for undefined routes
7. **Auth flow** — login stores token, logout clears it, expired token redirects to login

## Verification

Open the app in the browser and walk through the ENTIRE user journey:

- [ ] All screens load without console errors
- [ ] Seed data displays correctly
- [ ] Create, edit, and delete actions work
- [ ] Navigation follows the journey flow
- [ ] Auth flow works (register, login, protected routes, logout)
- [ ] Responsive — check at mobile width

## Checkpoint
```bash
git add .
git commit -m "feat: frontend completo con todas las pantallas del journey"
git tag v4-frontend
```
