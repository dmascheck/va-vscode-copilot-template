---
name: 'Obsidian Vault Structure'
description: 'How to read from and write to the Obsidian vault. Maps project domains to vault folder paths.'
applyTo: '**'
---

# Obsidian Vault Structure

## Vault Location
`/Users/danmascheck/ObsidanVault/Dan's Vault/`

## Folder Structure (DO NOT modify top-level structure)
```
00 - Inbox/          ← Quick capture
01 - Daily Notes/    ← Morning briefings
02 - People/         ← Contacts (VA + Microsoft)
03 - VA Account/     ← VA org structure, intel
04 - Meetings/       ← Meeting notes with transcripts
05 - Opportunities/  ← Pipeline deals (OP-XXXXXX format)
06 - Projects/       ← Project notes + AI session data ← THIS IS WHERE WE WRITE
07 - Tasks/          ← Task tracking
08 - Ideas & Research/
09 - Resources/      ← Templates, skills
10 - Archive/
VAEC Intake/         ← VA engagement intake docs
```

## Project Domain Mapping
When writing to Obsidian, map project domain to the correct subfolder:

| Domain in .env.project | Obsidian Path |
|------------------------|---------------|
| `healthcare` or `va` | `06 - Projects/VA/` |
| `retail` or `munkeybutt` | `06 - Projects/Munkeybutt Comix/` |
| `personal` | `06 - Projects/Personal/` |
| `tools` or `infra` | `06 - Projects/Tools/` |

## Where AI Session Data Goes
Each project is a FOLDER containing its overview note (same name as folder) plus subfolders for session data.
This uses the Obsidian Folder Notes pattern (plugin: "Folder notes" by LostPaul).
Clicking the folder in the sidebar opens the overview note.

```
06 - Projects/VA/
└── va-video-connect/                ← click folder → opens overview note
    ├── va-video-connect.md          ← project overview (frontmatter, architecture, status)
    ├── sessions/                    ← session summaries (written by #end-session)
    ├── decisions/                   ← architecture decisions + plan references
    ├── issues/                      ← bugs, root causes, fixes (anti-loop database)
    ├── lessons/                     ← patterns learned
    ├── mcaps/                       ← MS Copilot consultation answers
    └── plans/                       ← build plan references
```

## Reading from Obsidian (MCPVault)
- Use `search_notes` for broad searches across the vault
- Use `read_note` for specific notes when you know the path
- Project notes have frontmatter with: name, type, domain, status, tech_stack, linked_opp

## Writing to Obsidian (MCPVault)
- NEVER modify existing project notes (the .md file) without user permission
- Session data goes in the project's subfolder (sessions/, decisions/, etc.)
- Use consistent date prefixes: `YYYY-MM-DD-short-title.md`
- Include frontmatter with at minimum: `date`, `type`, `project`

## Linking Conventions
- Use `[[wikilinks]]` to link between notes
- Link session notes back to the main project note: `[[va-video-connect]]`
- Link decisions to relevant opportunity notes: `[[OP-000070438 FHB-VA-OCC-Tele-Medicine-Platform]]`

## Frontmatter Update on Migration
When migrating projects from Windsurf to VS Code, update:
- `windsurf_path` → `vscode_path`
- Add: `vscode_path: /Users/danmascheck/VSCodeProjects/{project-name}`
