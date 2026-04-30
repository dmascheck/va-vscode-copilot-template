---
agent: agent
description: "Clean session close — writes session summary, updates context files, saves chat, commits and pushes"
---

# End Session

**Purpose:** Save all session state, update context files, and prepare for next session.

🚨 **EVERY step is MANDATORY. Do not skip.**

---

## Step 1: Generate Session Summary

Create a session summary with:
- **Date and duration** (approximate)
- **What was accomplished** (list of completed tasks)
- **Decisions made** (with rationale)
- **Issues encountered** (with status: resolved/open)
- **Files changed** (from `git diff --stat`)

---

## Step 2: Write Session Log

Save to `Logs/sessions/YYYY-MM-DD-session-N.md`:

```markdown
# Session: YYYY-MM-DD — {title}

## Accomplished
- {task 1}
- {task 2}

## Decisions
- {decision}: {rationale}

## Issues
- {issue}: {status}

## Files Changed
{git diff --stat output}

## Next Steps
- {what to do next session}
```

---

## Step 3: Update Context Files

### 3a: NEXT_SESSION.md
Write specific resume instructions — what to work on next, what state things are in.

### 3b: PROJECT_CONTEXT.md
Update with any state changes from this session.

### 3c: TODO.md
- Mark completed tasks as done
- Add any new tasks discovered
- Update in-progress items

### 3d: COMMAND_LOG.md
Append session summary (date, key actions, outcomes).

---

## Step 4: Write Decisions/Issues/Lessons

If any decisions were made → write to `Logs/decisions/YYYY-MM-DD-{slug}.md`
If any issues were resolved → write to `Logs/issues/YYYY-MM-DD-{slug}.md`
If any lessons were learned → write to `Logs/lessons/YYYY-MM-DD-{slug}.md`

---

## Step 5: Save Chat Transcript

```bash
# Save chat digest if session log available
LATEST_LOG=$(ls -t Logs/chat/*.jsonl 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
  python3 scripts/chat_digest.py "$LATEST_LOG"
fi
```

---

## Step 6: Git Commit and Push

```bash
git add .github/context/
git add Logs/sessions/ Logs/decisions/ Logs/issues/ Logs/lessons/
git status
```

Commit with: `docs: end session YYYY-MM-DD — {summary}`

```bash
git commit -m "docs: end session YYYY-MM-DD — {summary}"
git push origin $(git branch --show-current)
```

---

## Step 7: Present End Session Report

```
╔══════════════════════════════════════════════════════════════╗
║                   SESSION END REPORT                         ║
║  {DATE}                                                      ║
╚══════════════════════════════════════════════════════════════╝

✅ ACCOMPLISHED:
  - {task 1}
  - {task 2}

📝 FILES UPDATED:
  - .github/context/PROJECT_CONTEXT.md
  - .github/context/NEXT_SESSION.md
  - .github/context/TODO.md
  - Logs/sessions/{filename}

🔄 GIT:
  - Committed: {hash}
  - Pushed: {branch}

🎯 NEXT SESSION:
  {resume instructions}
```
