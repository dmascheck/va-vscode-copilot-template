---
agent: agent
description: Full diagnostic workflow for code AND Azure issues. Systematic root cause analysis → resolution → document.
---

# Debug

**Purpose:** Systematic debugging for any bug, error, or unexpected behavior.

## Workflow

1. **Reproduce** — Get exact error, stack trace, steps to reproduce
2. **Context** — Check recent git changes, ISSUES_RESOLVED.md, LESSONS_LEARNED.md
3. **Isolate** — Is this code, config, environment, or Azure Government network?
4. **Diagnose** — Form hypothesis, gather evidence
5. **Fix** — Delegate to `@developer` or fix directly if simple
6. **Document** — Offer `#log-issue` to record the fix
7. **Verify** — Run tests to confirm fix doesn't break anything

## Azure Government Debugging

- Verify endpoints use `.us` domains
- Check `az cloud show --query name` = `AzureUSGovernment`
- Verify private endpoint connectivity
- Check Managed Identity token acquisition with Government authority
