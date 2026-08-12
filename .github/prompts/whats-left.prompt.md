---
description: "Answer 'what is left / are we done / is it 100% complete' with an execution-proven ledger, never a claim. Runs the project's real checks (ACTIVE_TASK done_cmd, gates, tests) and reports DONE-with-proof vs IN-PROGRESS vs NOT-BUILT vs NEEDS-DAN. Differs from #standup (what I did) and #quality-report (is code healthy) — this answers what is actually built and proven vs not."
---

# What's Left — the Honest Status Ledger

Answer "what is left / are we done / is it complete" with a ledger backed by checks that actually RAN during this answer — never prose confidence, never trusting a checkbox in TODO.md.

**How this differs from the neighbors:**
- `#standup` = "what did I do yesterday, what's planned" (reads sessions + TODO, trusts them)
- `#quality-report` = "is the code healthy" (test pass rate, coverage, lint, CVEs)
- `#whats-left` (this) = "what is actually BUILT and PROVEN vs not" — runs proofs, forces the NOT-BUILT vs IN-PROGRESS distinction that the others blur.

## Procedure

1. **Find the ground truth.** Read `.github/context/ACTIVE_TASK.md` (objective + done_cmd), `TODO.md`, `NEXT_SESSION.md`, and any module gate/tracker the current work uses.

2. **RUN the checks — do not recall them.** Execute the ACTIVE_TASK `done_cmd` and/or the relevant gates (test suite, build, lint, a completeness gate) and read the REAL exit codes/output. A result remembered from earlier in the session is a claim, not a fact.

3. **Report the four buckets, in this order, plain terms:**
   - **DONE** — each item WITH the proof that just ran (command + exit 0 / count). No proof, no DONE — it moves down a bucket.
   - **IN-PROGRESS** — started; what specifically remains; roughly how much.
   - **NOT-BUILT** — promised or planned but not started. Say so plainly; never blur this into "in progress."
   - **NEEDS-DAN** — parked decisions/authorizations, numbered and ready to rule (use the #decide / decision-partner format).

4. **One-line bottom line first:** "X of Y done and proven; blocked on N decisions" — then the ledger. If the honest answer is "not done", lead with that; never soften it.

## Hard rules
- Never say "complete / done / 100%" for anything that lacks an executed proof from step 2.
- If a check cannot run right now (off-site server, missing env), list the item as UNVERIFIED with the reason — not as done.
- Distinguish the task Dan actually asked for from adjacent work you noticed; the ledger covers the asked task, extras go in one trailing line.
- Read-only status report — this prompt does not build or fix anything. No emojis.
