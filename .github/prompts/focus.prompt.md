---
description: "Write or update the repo's .github/context/ACTIVE_TASK.md contract — objective + machine-checkable done-condition + out-of-scope — so a long or multi-step run stays on the stated task and cannot declare hollow 'done'. Sets the contract; does not start the work."
---

# Focus — Set the Task Contract

Write `.github/context/ACTIVE_TASK.md` so a long run cannot quietly drift off-task or declare "done" on hollow work. This is the counterpart to `#converge` (which checks the contract) and it feeds `#start-session` (which surfaces an unfinished contract next session). See AGENTS.md Section 8 "Stay on Path / Converge".

This prompt writes ONE file. It does NOT begin the work.

## Steps

1. **Find or create the contract file.** Locate `.github/context/ACTIVE_TASK.md` (search up from cwd for the `.github/context` dir). If the repo has the standard context layout but the file is missing, create it from the template in `project-template-vscode/.github/context/ACTIVE_TASK.md`.

2. **Capture the objective in one sentence.** What is this task, concretely. If the request is vague, state the most likely interpretation and say so.

3. **Pin the done-condition — pick the tier** (from AGENTS.md Section 8):
   - **Tier A (strongest):** a command that exits 0 when done — `pytest -q`, `npm test`, `ruff check`, a gate script. Put it in `done_cmd`. Prefer this whenever the task has a real pass/fail.
   - **Tier B:** written, checkable acceptance criteria (for quality/fuzzy work with no natural command). List them under `# Acceptance criteria`. Leave `done_cmd` empty.
   - **Tier C:** human judgment (taste, aesthetics, requirements only the architect can confirm). Leave `done_cmd` empty, plan to set `status: blocked` when it needs their eyes. Do NOT fake a command that trivially passes.

4. **List out-of-scope items.** The things NOT to chase during this task. Drift gets logged in the tangent log, not switched to.

5. **Write the front-matter and sections** (`status: active`):
   ```
   ---
   status: active
   mode: advisory
   done_cmd: "<command, exit 0 == done>"   # empty for Tier B/C
   episode: ""
   ---
   # Objective
   <one sentence>
   # Acceptance criteria
   - <checkable conditions>
   # Out of scope
   - <...>
   # Tangent log (surfaced, not chased)
   - (none yet)
   ```

6. **Confirm and stop.** Echo the objective, done-condition, and tier back in one or two lines. Do NOT begin the work — `#focus` only sets the contract.

## Rules
- One active task at a time. If an active contract already exists, UPDATE it rather than stacking a second.
- `done_cmd` must be a real check the task actually exercises — never a self-graded box.
- When the task completes, set `status: done`; when blocked on an architect decision, set `status: blocked`.
- Enforcement note: in Claude Code the convergence-guard Stop hook reads this file and can block a premature stop. In Copilot there is no such hook yet — the contract is honored as discipline and surfaced by `#start-session`. Either way, YOU drive to the done-condition; the file keeps you honest about what "done" means.
- No emojis in the committed file.
