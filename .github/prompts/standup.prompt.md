---
description: "Generate standup report from recent session history"
---

Generate a standup report:

1. Read `Logs/sessions/` for yesterday's session summaries for this project
2. Read current TODO.md
3. Present standup format:
   - **Yesterday**: What was accomplished (from session summaries)
   - **Today**: What's planned (from TODO.md and NEXT_SESSION.md)
   - **Blockers**: Any unresolved issues (from `Logs/issues/`)
