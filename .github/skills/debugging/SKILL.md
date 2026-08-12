---
name: debugging
description: "Systematic anti-loop debugging methodology. Searches Obsidian for prior issues before suggesting fixes. Diagnoses comprehensively before fixing. MCAPS-aware for Azure issues. Use when encountering errors, bugs, or unexpected behavior."
---

# Debugging Skill

## Anti-Loop Protocol
BEFORE suggesting any fix, ALWAYS:
1. Search Obsidian `06 - Projects/{domain}/{project-name}/issues/` for this error/symptom
2. Check if the same command/approach was tried earlier in this session
3. If a prior fix exists and WORKED → use it
4. If a prior fix FAILED → try a DIFFERENT approach
5. Never retry the same failed approach

## Diagnostic Methodology

### Step 0: MCAPS Quick Check (Azure errors only)
If error is 403, timeout, connection refused, or network-related:
- Check .env.project for MCAPS_*_PUBLIC_ACCESS flags
- Check if the service requires Private Endpoint
- Check if the request is coming from localhost (MCAPS blocks some services from localhost)
- If MCAPS is likely the cause → generate #mcaps-check prompt

### Step 1: Capture & Classify
- Exact error message, stack trace, HTTP status
- Classify: code bug, configuration error, Azure issue, dependency issue, environment issue
- When did it start? What changed?

### Step 2: Comprehensive Diagnosis (READ-ONLY)
Do ALL of these before attempting any fix:
- Run linter (ruff check / eslint)
- Check recent git diff for potentially breaking changes
- Read relevant logs
- Check imports and dependency versions
- If Azure-related: check resource health, auth, networking

### Step 3: Root Cause Analysis
- Search Obsidian ISSUES for similar symptoms across all projects
- Search Obsidian LESSONS for known anti-patterns
- Check Microsoft Learn for known issues with the SDK/service version
- Isolate: code vs config vs Azure vs environment

### Step 4: Fix ALL Issues at Once
- Don't fix one error, run, find next error, fix that (whack-a-mole)
- Identify ALL issues from the diagnostic, fix them in one pass
- Run tests to verify the complete fix

### Step 5: Document
Write to Obsidian `06 - Projects/{domain}/{project-name}/issues/`:
```
# Issue: [Title]
**Date**: YYYY-MM-DD
**Symptom**: [what was observed]
**Root Cause**: [what was actually wrong]
**Fix**: [what was done]
**Prevention**: [how to avoid this in the future]
```

## Stale Syntax Prevention
Before running ANY CLI command:
- Query Microsoft Learn MCP or Context7 for current syntax
- Verify the SDK version matches the documentation
- Don't rely on memory for az CLI, Bicep, or npm commands
