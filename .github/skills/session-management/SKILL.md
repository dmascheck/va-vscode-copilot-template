---
name: session-management
description: "Session lifecycle management for VS Code Copilot. Redirects to authoritative prompt files for start/end session workflows. Provides supplementary context for mid-session sync and marathon checkpoints."
---

# Session Management Skill

## CRITICAL: Prompt Files Are Authoritative

🚨 **This skill is supplementary context only. The prompt files contain the full runbooks with detailed boxed reports and verification passes.**

### #start-session
**Read and follow `prompts/start-session.prompt.md`** (or `.github/prompts/start-session.prompt.md`) step by step. It contains:
- 12 mandatory steps (MCP servers → git sync → health check → context files → Obsidian → report)
- A full boxed `SESSION START REPORT` with evidence per line
- A terminal-based verification pass comparing reported values to actual

Do NOT substitute this skill's summary for the prompt file's detailed report.

### #end-session
**Read and follow `prompts/end-session.prompt.md`** (or `.github/prompts/end-session.prompt.md`) step by step. It contains:
- 7 mandatory steps (summary → Logs/ writes → chat save → context updates → Obsidian mirror → git push → report)
- A full boxed `SESSION END REPORT` with session confidence indicator
- A terminal-based verification pass
- An Obsidian-formatted markdown report mirror

Do NOT substitute this skill's summary for the prompt file's detailed report.

## Mid-Session Sync (#sync-context)
Recommended every 3-4 hours for marathon sessions:
1. Update PROJECT_CONTEXT.md with current state
2. Update TODO.md (completed items, new items)
3. Write checkpoint to Obsidian `06 - Projects/{domain}/{project-name}/sessions/`
4. Log any new decisions to Obsidian `06 - Projects/{domain}/{project-name}/decisions/`
5. Git commit context changes with message `chore: mid-session sync`

## Marathon Checkpoints
When PreCompact hook fires (compaction imminent):
1. Write checkpoint to Obsidian with current progress
2. Update PROJECT_CONTEXT.md
3. Update TODO.md
4. Summarize key decisions/issues from this segment

## Obsidian MCP Tools (Quick Reference)
Call these directly by name — do NOT use tool_search:
- `mcp_obsidian-mcpv_list_directory` — list folders/files
- `mcp_obsidian-mcpv_read_note` — read a note (param: path)
- `mcp_obsidian-mcpv_write_note` — create/overwrite (params: path, content)
- `mcp_obsidian-mcpv_patch_note` — partial update
- `mcp_obsidian-mcpv_update_frontmatter` — update YAML frontmatter
- `mcp_obsidian-mcpv_search_notes` — search vault content
