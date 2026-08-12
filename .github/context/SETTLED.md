<!-- BEGIN GENERATED: audit-open-findings (emit_open_findings.py) -->
## DO NOT START HERE - this is a BACKLOG, not a queue

The queue is `.github/context/NEXT_SESSION.md` in this repo. The one declared next action for the platform is in `friction-audit/.github/context/STATUS.md`.

Reading the findings below FIRST is what drifted the 2026-08-12 session: it opened to this list, picked an estate-wide sweep nobody asked for, reverted 434 files across 8 repos, and never touched the declared priority all day. A finding is work OWED - it is not work NEXT, and it is not permission to start.

## AUDIT FINDINGS - open, measured 2026-08-11

3 finding(s) from the 2026-08-11 platform deep dive apply to va-vscode-copilot-template. Full detail with every evidence receipt: `~/VSCodeProjects/friction-audit/findings/deepdive-20260811/board.json`.

These were TRUE WHEN MEASURED on 2026-08-11. They are not a claim about right now - run the check shown before acting on one, and do not report one as fixed without doing so. Do NOT re-derive these from scratch; the investigation is already done.

- **[C7/HIGH] Finished work sits on side branches and unpushed commits while GitHub's main branch is months old**
  - fix: Rule once per repo and execute: either merge the working branch into main and push, or change the GitHub default branch to the working branch - for 3rdplanetpos the branch is not an experiment, it IS the project, so merge it (after the 70-commit divergence in 
  - check: `git log --oneline origin/main..HEAD | wc -l -> 1010 ; git log -1 origin/main -> 135e68f3 2026-04-29 ; git branch -avv -> remotes/origin/HEAD -> origin/main`

- **[C9/HIGH] Personal, clinical and Microsoft-internal content is committed to repos meant for other people**
  - fix: Three separate actions. (1) Before any push to va-vscode-copilot-template, rewrite commit 9224a29 to drop obsidian-vault, obsidian-folder-note, decision-partner, shopify and the MCAPS-specific files, and strip Obsidian and MCAPS blocks from the 33 affected age
  - check: `{"isTemplate":true,"visibility":"PUBLIC"} ; .github/instructions/obsidian-vault.instructions.md:4,9-10 -> applyTo: '**' ... /Users/danmascheck/ObsidanVault/Dan's Vault/ ... '03 - V`

- **[C8/MEDIUM] Every number in your docs is typed by hand, so nearly every number is wrong**
  - fix: Delete hand-typed counts from prose. Where a number is genuinely useful, generate it: a `refresh-inventory` script regenerating the tables from `ls` and `git ls-files`, run from the pre-commit hook and from master.sh sync after it writes files (sync already kn
  - check: `CLAUDE.md, HANDOFF.md, PROJECT_MANUAL.md, CODE_MAP.md all say 28 prompts / 28 skills / 28 agents | ls .github/prompts|wc -l -> 35 ; skills -> 29 ; agents -> 30 ; instructions -> 18`
<!-- END GENERATED: audit-open-findings -->
