---
name: session-management
description: "Session lifecycle management for VS Code Copilot. Redirects to authoritative prompt files for start/end session workflows. Provides supplementary context for mid-session sync and marathon checkpoints."
---

# Session Management Skill

## CRITICAL: Prompt Files Are Authoritative

🚨 **This skill is supplementary context only. The prompt files contain the full runbooks with detailed boxed reports and verification passes.**

### #start-session
**Read and follow `prompts/start-session.prompt.md`** (or `.github/prompts/start-session.prompt.md`) step by step. It contains:
- 11 mandatory steps (git sync → health check → CODE_MAP → infra state → context files → staleness → git status → SP expiration → VA compliance → mode/agents → report)
- A full boxed `SESSION START REPORT` with evidence per line
- A terminal-based verification pass comparing reported values to actual

Do NOT substitute this skill's summary for the prompt file's detailed report.

### #end-session
**Read and follow `prompts/end-session.prompt.md`** (or `.github/prompts/end-session.prompt.md`) step by step. It contains:
- 7 mandatory steps (summary → session log → context updates → decisions/issues/lessons → chat save → git push → report)
- A full boxed `SESSION END REPORT` with session confidence indicator
- A terminal-based verification pass

Do NOT substitute this skill's summary for the prompt file's detailed report.

## Mid-Session Sync (#sync-context)
Recommended every 3-4 hours for marathon sessions:
1. Update PROJECT_CONTEXT.md with current state
2. Update TODO.md (completed items, new items)
3. Write a checkpoint to `Logs/sessions/YYYY-MM-DD-checkpoint.md`
4. Log any new decisions to `Logs/decisions/YYYY-MM-DD-{slug}.md`
5. Git commit context changes with message `chore: mid-session sync`

## Marathon Checkpoints
When PreCompact hook fires (compaction imminent):
1. Write a checkpoint with current progress to `Logs/sessions/`
2. Update PROJECT_CONTEXT.md
3. Update TODO.md
4. Summarize key decisions/issues from this segment into `Logs/decisions/` and `Logs/issues/`

## Project Record Sinks (Quick Reference)
Session history and project memory live in the repo, under the gitignored `Logs/` tree:
- `Logs/sessions/` — session summaries and mid-session checkpoints
- `Logs/decisions/` — architecture and approach decisions, one file each
- `Logs/issues/` — issues encountered, with root cause and fix
- `Logs/lessons/` — durable lessons and known anti-patterns
- `Logs/plans/` — saved implementation, architecture, and migration plans
- `Logs/chat/` — exported chat transcripts
