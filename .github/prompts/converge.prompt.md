---
description: "Prove the current task is actually done by RUNNING its done-condition, not by asserting it. Reads .github/context/ACTIVE_TASK.md, runs its done_cmd, and reports the real exit code and what remains. The counterpart to #focus. Use before claiming a task finished, or when asked 'are we actually done / prove it / run the gate'."
---

# Converge — Prove Done by Running the Check

Prove the current task is done by running its check, not by asserting it. This is the manual counterpart to `#focus`: it runs the `done_cmd` from `.github/context/ACTIVE_TASK.md` and reports the truth. Encodes the doctrine from AGENTS.md Section 8: "done = an external check passed, never a feeling."

Scope note: `#converge` checks THIS task's contract (its `done_cmd`). For a broader "what is left across the whole project" status, use `#whats-left`.

## Steps

1. **Locate the contract.** Find `.github/context/ACTIVE_TASK.md` (search up from cwd). If there is none, say so and suggest `#focus` to set one — do NOT guess a done-condition.

2. **Read the done-condition.** Parse `done_cmd`, `status`, `mode`, and the Objective.
   - If `status` is already `done` or `blocked` → report that and stop.
   - If `done_cmd` is empty (Tier B/C) → there is no machine check. Re-state the Objective and the acceptance criteria, and ask Dan to confirm rather than declaring done yourself.

3. **Run `done_cmd`** from the repo root (the dir containing `.github`). Show the exact command, and capture its REAL exit code and the tail of its output. Do NOT summarize a failing run as success.

4. **Report honestly:**
   - Exit 0 → the check passes. State it plainly. Offer to set `status: done` in the contract.
   - Non-zero → NOT done. Show the failing output, name what is still open, and (if asked) keep working toward it. Never paper over the failure.

5. **On a clean pass, optionally close the contract.** If Dan agrees, set `status: done` so the next `#start-session` does not resurface it as unfinished.

## Rules
- Report the ACTUAL exit code and real output — running it is the whole point; a claimed pass is not a pass.
- Do NOT edit `done_cmd` to make it pass. If the check itself is wrong, raise that with Dan; do not weaken the gate.
- Re-run after any fix with fresh output; a stale prior pass does not count.
- This prompt runs a command and may flip `status` to `done` on confirmation; it makes no other code changes.
- No emojis in the committed file.
