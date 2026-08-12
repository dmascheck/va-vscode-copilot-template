---
applyTo: "**"
---

# Git Workflow Standards

## Branch Naming

`<yyyymmdd>-<feature-name>` (e.g., `20260301-add-patient-sync`)

## Rules

- Main is ALWAYS demo-ready — never commit incomplete work
- One branch per feature, merge back with `--no-ff`
- Before switching branches: check uncommitted changes, suggest stash/commit
- Commit style: Conventional commits (`feat:`, `fix:`, `chore:`, `docs:`)
- After every commit: `git status` to confirm clean state
- Never auto-run `git reset --hard` or `git push --force` without explaining risks

## Overwrite Guard

Before modifying ANY source file:
```bash
git log --since="24 hours ago" --oneline -- <filename>
```
If commits exist in the last 24 hours → warn the user with the commit messages before proceeding.
