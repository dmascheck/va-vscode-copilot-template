---
description: "Verify work produced by the OTHER AI tool — usually Copilot reviewing Claude Code's changes, or vice versa. Diff-based CODE review: identify what changed, dispatch @reviewer + the security auditor in parallel, produce ONE prioritized report (BLOCKERS / SHOULD-FIX / NITS). Differs from #doublecheck (which verifies factual CLAIMS in prose via web sources) — this verifies CODE. Read-only; does not auto-fix unless asked."
---

# Cross-Review — Verify the Other Tool's Code

The "verify the other tool's work" runbook — the second half of the two-tools model (Copilot = day-to-day; Claude Code = the hardest work + verifying what the other produced). It is diff-based and read-only: review the code changes, route them through the specialist subagents, hand back one prioritized report.

**How this differs from #doublecheck:** `#doublecheck` verifies factual CLAIMS in prose (legal citations, statutory refs, research summaries) by finding web sources. `#cross-review` verifies CODE another tool wrote (correctness bugs, security holes, vibe-coded tells). Different artifact, different method — use doublecheck for claims, cross-review for code.

## Steps

1. **Scope the diff.** Determine exactly what changed and by whom. Default to working tree + staged vs the base (`git diff` and `git diff --cached`); for a branch/PR, diff against its merge base (`git merge-base`). If the architect named a tool ("review Claude's last commits"), scope to those commits. State the scope and the file/line count up front.

2. **Read the change in context.** For each changed file, read enough surrounding code to judge the change, not just the hunk. Note intent: what was this change trying to do, and does the diff actually achieve it.

3. **Dispatch the specialist subagents in parallel** (one message, independent tasks):
   - `@reviewer` — correctness bugs, logic errors, broken edge cases, reuse/simplification, and quality/vibe-coded tells (dead code, copy-paste, invented APIs, swallowed errors, bare print/console.log, placeholder/TODO left in, money in float instead of Decimal).
   - `security-auditor` — secrets in code/config, injection, authz gaps, Azure Policy and data-classification concerns, Key Vault for secrets, synthetic-data-only, no real PHI/PII.
   Give each the diff scope and the relevant files. Wait for both.

4. **Check tests.** Did the change add/update tests for what it changed? Do existing tests still cover it? If tests exist and are cheap to run, run them and report pass/fail; if not run, say so — do not claim verification you did not perform.

5. **Synthesize ONE prioritized report.** Merge both subagents' findings, de-duplicate, order by severity: BLOCKERS (correctness/security must-fix) -> SHOULD-FIX (quality, missing tests) -> NITS. Each finding: `file:line`, what is wrong, why it matters, suggested fix. Lead with the bottom line: ship / fix-then-ship / rework.

6. **Report.** Print the prioritized findings + the bottom line. If the architect asked for fixes, apply ONLY the agreed ones path-scoped and re-verify; otherwise leave the tree untouched.

## Rules
- Read-only by default. Do not auto-fix; surface findings and let the architect decide. Apply fixes only when explicitly asked.
- Lead with the bottom line, then the prioritized list — a recommendation, not a survey.
- Verify before claiming done: if you ran tests, report results; if not, say so. Never assert behavior you did not observe.
- Apply the hard rules as review criteria: no secrets in repo, Key Vault for secrets, synthetic-data-only, no emojis in artifacts, no placeholders/TODOs/stubs, structured logging not bare prints, no swallowed errors, policy-compliant Azure.
- If fixes are applied, commit path-scoped (never `git add -A`); do not push unless asked.
