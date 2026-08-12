---
name: 'MCP-First Tool Priority'
description: 'Always prefer MCP tools over shell commands. Check .env.project before Azure operations.'
applyTo: '**'
---

# MCP-First Tool Priority

## Rule: Is there an MCP tool? Use it. Failed? Auto-fallover to shell.

## Tool Priority Matrix

| Task | MCP Tool First | Shell Fallover |
|------|---------------|----------------|
| Git operations | GitKraken MCP / Git MCP | git CLI |
| Azure resource info | Azure MCP | az CLI |
| Azure deployment | Azure MCP deploy | az deployment / azd |
| File operations | Filesystem MCP | cp, mv, cat |
| Web browsing | Playwright MCP | curl, wget |
| Microsoft docs | Microsoft Learn MCP | #fetch URL |
| Framework docs | Context7 MCP | #fetch URL |
| GitHub operations | GitHub MCP | gh CLI |
| Database queries | ADX/Kusto MCP | az kusto |
| Obsidian vault | MCPVault MCP | direct file read/write |
| Docker operations | Docker MCP | docker CLI |
| Task management | Taskmaster AI MCP | manual TODO.md |
| PDF reading | PDF Reader MCP | manual |
| Diagrams | Draw.io / Excalidraw MCP | manual |

## ENV-FIRST Rule
Before ANY Azure operation:
1. Read .env.project for resource names, subscription ID, resource group
2. Only query Azure MCP or az CLI if the value isn't in .env.project
3. After discovering a new value, write it back to .env.project

## Fallover Statement
When using shell instead of MCP, include: "MCP fallover: using [shell command] because [MCP tool] [was unavailable/failed/doesn't support this operation]."
