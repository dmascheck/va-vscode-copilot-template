---
agent: agent
description: "Save the current implementation plan to Logs/plans/."
---

# Save Plan

**Purpose:** Save the current implementation plan for future reference.

## Steps

1. Collect the plan from chat context
2. Write to `Logs/plans/YYYY-MM-DD-{slug}.md` with:
   - Plan title and date
   - Architecture decisions
   - Task breakdown with status markers
   - VA compliance validation results
   - Azure cost estimates (if available)
3. Update `TODO.md` to reference the plan
4. Git commit
