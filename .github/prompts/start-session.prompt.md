---
agent: agent
description: Initialize a Copilot session with full project context, git sync, health check, and task status.
---

# Start Session

**Purpose:** Initialize GitHub Copilot with complete project understanding. Run at the beginning of every work session.

🚨 **EVERY step below is MANDATORY. Do not skip any step.**

---

## Step 1: Git Sync

```bash
git fetch origin && git status && git log --oneline -3
```

**Decision tree:**
1. Up-to-date, no local changes → Note "✅ Code in sync"
2. Behind origin, no local changes → `git pull --rebase`
3. Behind origin, WITH local changes → `git stash && git pull --rebase && git stash pop`
4. Diverged → `git stash && git pull --rebase && git stash pop` (warn user if conflicts)

After sync:
```bash
git log --oneline -3
git status
```

---

## Step 2: Run Health Check

Run `#health-check` to audit all files and report issues upfront.

---

## Step 3: Check CODE_MAP.md

```bash
ls -la .github/context/CODE_MAP.md 2>/dev/null || echo "CODE_MAP.md not found"
```

- < 7 days old: Read it
- Missing or > 7 days: Run `#deep-scan` first

---

## Step 4: Check Infrastructure State

```bash
cat .env.project 2>/dev/null | grep -v "^#" | grep -v "^$" || echo "No .env.project"
```

Note all Azure Government resource names. Verify `AZURE_GOV_REGION` is set.

---

## Step 5: Read Context Files

Read ALL files in `.github/context/`:
1. `PROJECT_CONTEXT.md` — Current state
2. `NEXT_SESSION.md` — Where to resume
3. `TODO.md` — Active tasks
4. `LESSONS_LEARNED.md` — Awareness scan
5. `COMMAND_LOG.md` — Last 50 lines only

Also read `PROJECT_INTENT.md` in project root for compliance profile.

Read ALL files in `Logs/`:
1. `Logs/sessions/` — Last 3 session files in full
2. `Logs/decisions/` — ALL decision files
3. `Logs/issues/` — ALL issue files, flag any with status "Open"
4. `Logs/lessons/` — ALL lesson files

---

## Step 6: Check Context File Sizes + Staleness

```bash
for name in PROJECT_CONTEXT.md NEXT_SESSION.md TODO.md LESSONS_LEARNED.md COMMAND_LOG.md; do
  if [ -f ".github/context/$name" ]; then
    echo "$name: $(wc -c < ".github/context/$name") bytes · $(stat -f '%Sm' -t '%Y-%m-%d' ".github/context/$name")"
  else
    echo "$name: MISSING from .github/context/"
  fi
done
```

**Staleness thresholds:**
- `PROJECT_CONTEXT.md` > 7 days → ⚠️ Stale
- `TODO.md` > 7 days → ⚠️ Stale
- `CODE_MAP.md` > 7 days → ⚠️ Stale

---

## Step 7: Git Status

```bash
git status
git branch --show-current
```

Warn if on main with uncommitted changes.

---

## Step 8: Check Service Principal Expiration

```bash
source .env.project 2>/dev/null
if [ -n "$AZURE_SP_SECRET_EXPIRES" ]; then
    echo "SP expires: $AZURE_SP_SECRET_EXPIRES"
fi
```

- < 30 days: ⚠️ Warn
- < 7 days: 🚨 Critical

---

## Step 9: VA Compliance Quick Check

```bash
source .env.project 2>/dev/null
echo "FedRAMP Level: ${FEDRAMP_LEVEL:-NOT SET}"
echo "Azure Region: ${AZURE_GOV_REGION:-NOT SET}"
echo "Handles PHI: ${HANDLES_PHI:-NOT SET}"
```

Verify Azure CLI is set to Government:
```bash
az cloud show --query name -o tsv 2>/dev/null || echo "Azure CLI not configured"
```

---

## Step 10: Suggest Mode and Agents

Based on project state:
- `PROJECT_CONTEXT.md` shows "Project Initialized: No" → Suggest `@scrum-master` for planning
- `NEXT_SESSION.md` mentions debugging → Suggest `@debugger`
- On feature branch with changes → Suggest `@developer` for implementation
- Infrastructure work → Suggest `@infrastructure`

---

## Step 11: Present Session Start Report

```
╔══════════════════════════════════════════════════════════════╗
║                   SESSION START REPORT                       ║
║  {DATE} · {BRANCH}                                           ║
╚══════════════════════════════════════════════════════════════╝

┌─ GIT SYNC ──────────────────────────────────────────────────┐
│ {✅/⚠️} {branch} · {ahead/behind} · {clean/dirty}           │
│ Last 3: {commits}                                            │
└─────────────────────────────────────────────────────────────┘

┌─ HEALTH CHECK ──────────────────────────────────────────────┐
│ {findings summary}                                           │
└─────────────────────────────────────────────────────────────┘

┌─ CONTEXT FILES ─────────────────────────────────────────────┐
│ PROJECT_CONTEXT.md  {✅/⚠️} {bytes} · {age}                 │
│ NEXT_SESSION.md     {✅/⚠️} {bytes} · {age}                 │
│ TODO.md             {✅/⚠️} {bytes} · {age}                 │
│ Sessions:           {N files read}                           │
│ Decisions:          {N files read}                           │
│ Issues:             {N open}                                 │
└─────────────────────────────────────────────────────────────┘

┌─ VA COMPLIANCE ─────────────────────────────────────────────┐
│ FedRAMP:    {level}                                          │
│ Azure Gov:  {region} · {az cloud status}                     │
│ PHI:        {yes/no}                                         │
│ SP Expires: {date or N/A}                                    │
└─────────────────────────────────────────────────────────────┘

┌─ SUGGESTED MODE ────────────────────────────────────────────┐
│ {suggestion + reason}                                        │
└─────────────────────────────────────────────────────────────┘

🎯 RESUME POINT: "{from NEXT_SESSION.md}"
```

Ask: "What would you like to work on?"
