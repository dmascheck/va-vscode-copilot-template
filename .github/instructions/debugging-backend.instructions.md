---
applyTo: "**/backend/**,**/*.py,**/src/**"
---

# Backend Debugging Protocol

## Root Cause Analysis

1. **Reproduce** — Get exact error, stack trace, and steps
2. **Isolate** — Identify failing component (API layer, data layer, Azure service)
3. **Check recent changes** — `git log --since="48 hours ago" -- <file>`
4. **Check known issues** — Read `ISSUES_RESOLVED.md` and `LESSONS_LEARNED.md`
5. **Diagnose** — Form hypothesis, gather evidence, verify

## Azure Government Debugging

- Verify endpoints use `.us` / `.usgovcloudapi.net` (not commercial)
- Check `az cloud show --query name` = `AzureUSGovernment`
- Verify private endpoint connectivity
- Check Managed Identity token acquisition

## Common Patterns

| Symptom | Likely Cause | Quick Check |
|---------|-------------|-------------|
| 403 Forbidden | Missing RBAC role | `az role assignment list --assignee <id>` |
| Connection timeout | Private endpoint not configured | `az network private-endpoint list` |
| Auth failure | Wrong cloud/authority | Check `AzureAuthorityHosts.AZURE_GOVERNMENT` |
| Import error | Missing dependency | `pip list \| grep <package>` |
