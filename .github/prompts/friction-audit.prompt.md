---
description: "On-demand friction audit of THIS project's session history. Digests the project's Logs/chat/ digests + session/lesson/issue notes, extracts FRICTION (corrections, repeats, hollow-done claims, drift) and OPPORTUNITY (repeated manual sequences, always-added instructions, skill gaps), and presents a prioritized report. Read-only, single-project, no cross-machine or scheduled infrastructure — the lightweight counterpart to the two friction probes in #start-session."
---

# Friction Audit (on-demand, single project)

Analyze this project's own session history for FRICTION and OPPORTUNITY, and present a prioritized report. This is the manual, evidence-gathering version — no scheduled runs, no cross-machine sync, no auto-fix. It exists to prove whether an automated auditor would be worth building; until it surfaces real, repeated friction, do not build heavier machinery.

Read-only. This prompt reports; it does not change code or apply fixes.

## Steps

1. **Gather the history.** Read the project's `Logs/chat/*-digest.md` (the session digests), `Logs/sessions/`, `Logs/lessons/`, `Logs/issues/`, and `NEXT_SESSION.md`/`TODO.md`. If chat digests are missing, note it — the audit is weaker without them (the digest is where corrections/repeats live).

2. **Extract findings under two lenses:**
   - **FRICTION** — where something went wrong for Dan: he corrects the agent, repeats an instruction, interrupts, redoes work, or hits a repeated block. Seeded clusters (keep ids stable): hollow-complete claims (declared done on unproven work), task drift (wandered off the stated task), session-end/handoff fragility, hand-pasted ritual prompts (the same scaffold typed every time), repeated guard/permission blocks, machine-swap context loss, flailing loops (3+ near-identical retries).
   - **OPPORTUNITY** — nothing broke, but efficiency is on the table: a repeated multi-step manual sequence that could be one step (SIMPLIFY), work a script/prompt could own (AUTOMATE), a skill that always needs the same manual follow-up or an existing skill that's never invoked when it should be (SKILL-GAP), or under-used subagents/parallelism (TOOL-USE).

3. **Apply the evidence gate.** Report a finding only if it has real support: >= 2 occurrences across the history, OR one occurrence with a large measurable cost. Quote the verbatim evidence (session + short quote) for each — never editorialize a pattern into existence. Cap OPPORTUNITY at the top 5 by estimated payback; FRICTION is uncapped.

4. **Cross-check the probes.** Fold in the two `#start-session` probes over the whole history, not just recent: promise-rot (TODO/NEXT_SESSION items >3 weeks stale, never started) and lessons-not-sticking (a `Logs/lessons/` entry whose mistake recurred later). These are the highest-severity findings — a recorded lesson that repeated is the purest signal the system is not learning.

5. **Report — prioritized:**
   - **Top friction** (by occurrence x cost), each with verbatim evidence and a one-line proposed fix (a text change to a prompt/instruction/lesson, or a note).
   - **Top opportunities** (<= 5), each with the repeated sequence and what would collapse it.
   - **Promise-rot** and **lessons-not-sticking** call-outs.
   - Bottom line: is there enough repeated friction here to justify building an automated, scheduled auditor — or is the manual pass sufficient?

## Rules
- Read-only. Report findings and propose fixes; do not apply them or change code.
- Evidence gate is mandatory — no finding without >= 2 real occurrences (or one high-cost). Quote verbatim; do not invent patterns.
- Single project, this run only. No cross-machine reads, no scheduled job, no findings ledger — those are the heavy infrastructure this prompt deliberately avoids until the value is proven.
- No emojis in any written artifact. Report locations, never secret values.
