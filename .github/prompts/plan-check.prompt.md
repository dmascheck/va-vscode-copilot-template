---
agent: agent
description: "Validate an Azure architecture plan against FedRAMP and Azure Government rules."
---

# Plan Check

**Purpose:** Validate any architecture plan against VA compliance rules.

## Steps

1. Read the plan (from chat context or `Logs/plans/`)
2. For each Azure service in the plan:
   - Check against `.github/instructions/azure-gov.instructions.md` service matrix
   - Verify Government endpoints used
   - Verify private endpoint patterns
   - Verify authentication method
3. Check FedRAMP High compliance
4. Check HIPAA compliance (if PHI project)

## Output

```
🏗️ PLAN CHECK: {plan name}

| Service | Pattern | Compliant | Issue |
|---------|---------|-----------|-------|
| Storage | Private EP | ✅ | — |
| Cosmos  | Public | ❌ | Must use PE |

🛡️ FedRAMP: {passed/failed}
🏥 HIPAA: {passed/N/A}
📋 VERDICT: {APPROVED / NEEDS CHANGES — list}
```
