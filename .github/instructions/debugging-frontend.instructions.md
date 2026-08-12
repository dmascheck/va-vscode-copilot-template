---
applyTo: "**/*.tsx,**/*.ts,**/*.jsx,**/*.js,**/web/**"
---

# Frontend Debugging Protocol

## Root Cause Analysis

1. **Reproduce** — Get exact error, browser console output, network tab
2. **Isolate** — Component, API call, state management, or rendering issue
3. **Check recent changes** — `git log --since="48 hours ago" -- <file>`
4. **Check known issues** — Read `ISSUES_RESOLVED.md` and `LESSONS_LEARNED.md`

## Common Patterns

| Symptom | Likely Cause | Quick Check |
|---------|-------------|-------------|
| White screen | Unhandled error in render | Check browser console |
| CORS error | Backend CORS config | Check API allowed origins |
| API 401/403 | Auth token missing/expired | Check network tab headers |
| Stale data | Missing cache invalidation | Check React Query / SWR config |
| Accessibility failure | Missing aria attributes | Run axe-core audit |

## Section 508 Debugging

VA requires Section 508 compliance. Check:
- Color contrast (WCAG 2.1 AA minimum)
- Keyboard navigation (all interactive elements reachable)
- Screen reader compatibility (meaningful aria-labels)
- Focus management after route changes
