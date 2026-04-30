---
name: 'Session Protocol'
description: 'Session lifecycle rules for start, sync, and end workflows'
applyTo: '**'
---

# Session Protocol

## Session Start
1. Read PROJECT_INTENT.md (why this project exists)
2. Read .github/context/PROJECT_CONTEXT.md (current state)
3. Read .github/context/NEXT_SESSION.md (resume point)
4. Read .github/context/TODO.md (task list)
5. Read .github/context/*.md (all other context files)
6. Check git status (up to date? conflicts?)
7. Check .env.project (Azure Government resource state, compliance flags)
8. Present dashboard summary

## Mid-Session Sync (every 3-4 hours for long sessions)
1. Update .github/context/PROJECT_CONTEXT.md with current state
2. Update .github/context/TODO.md (completed, in-progress, new items)
3. Write checkpoint to Logs/sessions/
4. Log any new decisions to Logs/decisions/
5. Git commit .github/context/ changes

## Session End
1. Generate session summary
2. Write summary to Logs/sessions/YYYY-MM-DD-{slug}.md
3. Update .github/context/NEXT_SESSION.md with resume instructions
4. Update .github/context/PROJECT_CONTEXT.md with final state
5. Update .github/context/TODO.md
6. Write decisions/issues/lessons to Logs/ subfolders
7. Git add + commit + push

## Git Workflow
- Branch naming: YYYYMMDD-feature-name
- Main branch always demo-ready
- Conventional commits: feat:, fix:, chore:, docs:
