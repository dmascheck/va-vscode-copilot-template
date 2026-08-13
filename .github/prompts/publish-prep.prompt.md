---
description: "Prepare a repo for PUBLIC git publication. Scans git HISTORY (not just staged files) for committed secrets, internal/customer references, and /Logs material; verifies .gitignore coverage, LICENSE, and a clean public README; produces a go/no-go report. Complements scan-secrets.sh (which only scans staged/changed files). Never auto-pushes or makes the repo public — the architect makes that call after a clean report."
---

# Publish-Prep — Pre-Public-Repo Safety Gate

Get a repo ready to go public. Goal: nothing internal, no secrets, no customer/Copilot-only material leaks into the public history. This ASSESSES and PREPARES and produces a report — it NEVER pushes or sets the repo public. The architect makes that call after a clean report.

**Why this exists (not covered by the pre-commit hook):** `scan-secrets.sh` scans only staged/changed files for THIS commit. It cannot catch a secret that was committed months ago, later removed and gitignored, but is STILL in the git history — which anyone can read with `git log -p` after cloning. This gate scans HISTORY.

## Steps

1. **Inventory the sensitive surface.** Identify everything that must not go public: secrets; the gitignored `/Logs` history; internal context files (`.github/context/`, internal `CLAUDE.md`/`AGENTS.md`, Copilot-only instructions); customer/opportunity names; internal URLs/tenant/subscription ids; decision/issue notes meant for the awareness hub only.

2. **Verify `.gitignore` coverage.** Confirm it excludes: `.env*` (except `.env.example`/`.env.project`), `/Logs`, internal context dirs, Copilot-internal files. Add missing entries. Distinguish "gitignored but still in history" from "never committed" — gitignore alone does not scrub history.

3. **Scan for committed secrets in HISTORY (BLOCKING).** Scan tracked files AND git history:
   ```bash
   git log -p --all | grep -iE 'AccountKey=|SharedAccessKey|password\s*=|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|Bearer [A-Za-z0-9._-]{20,}|sk-[A-Za-z0-9]{20,}|SharedAccessSignature|Endpoint=sb://' | head
   ```
   Also check `git rev-list --all` blobs where feasible. Any hit is a publish blocker: it must be ROTATED (it is a leak) and scrubbed from history (removing the current file is not enough). Report location + type, never the value.

4. **Scan for internal references (BLOCKING).** Grep tracked files AND history for customer names, internal managed-tenant or subscription identifiers, opportunity or deal record ids, internal hostnames, employee names, absolute paths into a personal machine, and Copilot-only/internal markers. Each hit is a blocker until removed or confirmed-safe by the architect.

5. **Confirm `/Logs` + internal material are absent from what will ship.** Verify `/Logs` and internal context are gitignored AND not present in the history that would publish. If they are in history, flag that a history rewrite (or a fresh public mirror) is required.

6. **LICENSE + public README (BLOCKING).** Ensure a LICENSE exists (ask the architect which if absent — their call). Ensure a clean, public-appropriate README: describes the project for an outside reader, no internal context, no Copilot/internal instructions, no customer references.

7. **Final pre-publish report — go / no-go, BLOCKING items first:**
   - Secrets in history (locations only) — blocker.
   - Internal references / customer names — blocker.
   - `/Logs` or internal material in history — blocker.
   - Missing LICENSE or non-clean README — blocker.
   - `.gitignore` gaps fixed / remaining.
   - Bottom line: safe to publish, or the exact list to resolve first.

8. **Do not push.** Report only. Publishing and any history rewrite are explicit architect-confirmed actions, not done here.

## Rules
- NEVER auto-push and never set the repo public. This prepares and reports; the architect publishes.
- No internal or Copilot-only material in a public repo — hard exclusion (standing rule).
- gitignore is not history scrubbing: if sensitive content is in past commits, flag history rewrite / fresh mirror as required.
- A committed secret is a leak: rotate it AND scrub history — removing the file is not enough.
- Report secret/internal LOCATIONS, never their values.
- Blocking items (secrets, internal refs, /Logs in history, missing LICENSE/clean README) make it NO-GO until resolved. No emojis.
