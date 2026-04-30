---
agent: agent
description: Document a resolved issue in ISSUES_RESOLVED.md and optionally promote universal patterns to LESSONS_LEARNED.md.
---

# Log Issue

**Purpose:** Document a resolved issue for future reference.

## Steps

1. Ask: What was the issue? What was the root cause? How was it fixed?
2. Write to `.github/context/ISSUES_RESOLVED.md`:

```markdown
## YYYY-MM-DD: {title}
**Symptom:** {what went wrong}
**Root Cause:** {why}
**Fix:** {what was done}
**Prevention:** {how to avoid in future}
**Files:** {affected files}
```

3. If this is a universal pattern → also add to `LESSONS_LEARNED.md`
4. Write to `Logs/issues/YYYY-MM-DD-{slug}.md` for session history
