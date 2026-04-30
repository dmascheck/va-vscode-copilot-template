---
agent: agent
description: Pre-deployment checklist and verification. Run before any deployment to production or staging.
---

# Pre-Deploy

**Purpose:** Comprehensive pre-deployment verification.

## Checklist

### Code Quality
- [ ] All tests pass (`pytest tests/ -v`)
- [ ] No lint errors (`ruff check .`)
- [ ] No TODO/FIXME in production code
- [ ] No hardcoded secrets

### VA Compliance
- [ ] Azure CLI set to Government cloud
- [ ] FedRAMP compliance verified (private endpoints, encryption, auth)
- [ ] No commercial Azure endpoints in code
- [ ] No PHI/PII in logs or error messages
- [ ] HIPAA controls in place (if PHI project)

### Infrastructure
- [ ] Bicep templates validate (`az bicep build`)
- [ ] Resource tags include: environment, project, owner, vaOffice, fedRampLevel
- [ ] Private endpoints configured for all data services
- [ ] Environment variables set in App Service config

### Deployment
- [ ] Tested in dev environment first
- [ ] Rollback plan documented
- [ ] `LESSONS_LEARNED.md` reviewed
- [ ] Team notified of deployment

## Output

```
🚀 PRE-DEPLOY REPORT:
✅ Passed: {count}
❌ Failed: {count} — {list}
🛡️ VA Compliance: {passed/failed}
📋 VERDICT: {READY TO DEPLOY / BLOCKED — fix {issues} first}
```
