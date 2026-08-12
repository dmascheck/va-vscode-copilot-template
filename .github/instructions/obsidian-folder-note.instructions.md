---
applyTo: "**"
description: "Standard Obsidian Folder Note template for all projects. Used by end-session to update project notes."
---

# Obsidian Folder Note Template

## Standard Format

All project Folder Notes in Obsidian follow this hybrid format:
- **Zone 1 (top)** — Auto-updated every end-session
- **Zone 2 (bottom)** — Manually maintained, with `(verified: YYYY-MM-DD)` dates

### Zone 1 Sections (auto-updated)

```markdown
# {Project Name}
**Status:** {Active/Maintenance/Archived} | **Type:** {Production/Demo/Tool} | **Version:** {X.Y.Z}

---

## What This Is
{One paragraph description of the project's purpose and value.}

**Business Value:**
- {Bullet 1}
- {Bullet 2}

---

## Current Status

### Working ✅
- [x] {Completed items from TODO.md}

### Pending 📝
- [ ] {In-progress and pending items from TODO.md}

---

## Open Tasks
- [ ] #task {Task 1 from TODO.md}
- [ ] #task {Task 2 from TODO.md}

---

## Recent Session Notes
- **YYYY-MM-DD:** {One-line summary}. Next: {focus}.
- **YYYY-MM-DD:** {One-line summary}. Next: {focus}.

(End-session appends new entries here. Keep last 10; archive older to sessions/ subfolder.)

---
```

### Zone 2 Sections (manually maintained, with verified dates)

```markdown
## Architecture (verified: YYYY-MM-DD)
{Brief architecture description or link to architecture decision notes.}

- **Plugin/Backend/Frontend:** {paths or descriptions}
- **Context:** {how context is managed}
- **Infrastructure:** {Azure resources, MCP servers, etc.}

---

## Component Inventory (verified: YYYY-MM-DD)

| Component | Count | Key Items |
|-----------|-------|-----------|
| {Type 1} | {N} | {Brief list} |
| {Type 2} | {N} | {Brief list} |

(Counts auto-updated by end-session when directories are scannable.)

---

## Tech Stack (verified: YYYY-MM-DD)
- {Language/Framework list}

---

## Azure Resources (verified: YYYY-MM-DD)

| Resource | Status | Notes |
|----------|--------|-------|
| {Resource} | ✅/❌ | {Notes} |

_N/A if project has no Azure resources._

---

## Decisions Log

| Decision | Date | Link |
|----------|------|------|
| {Decision Name} | YYYY-MM-DD | [[decisions/YYYY-MM-DD-slug]] |

See decisions/ subfolder for detailed ADRs.

---

## Known Issues (verified: YYYY-MM-DD)
- {Issue 1 — status/workaround}
- {Issue 2 — status/workaround}

---

## Related
- [[sessions/]] — Session summaries
- [[decisions/]] — Architecture decisions
- [[issues/]] — Known issues & root causes
- [[lessons/]] — Patterns learned
```

## Update Rules

### End-Session Updates (Zone 1)
1. Rewrite **Current Status** from TODO.md (Working ✅ = done items, Pending 📝 = in-progress + pending)
2. Rewrite **Open Tasks** from TODO.md with `#task` tags
3. Append 1-liner to **Recent Session Notes**: `**YYYY-MM-DD:** {summary}. Next: {focus}.`
4. Update component counts from directory scans (if applicable)
5. Update `last_updated` frontmatter

### End-Session Updates (Zone 2 — conditional)
6. If infrastructure/bicep/.env.project files changed → prompt user to update Architecture section
7. If user updates a Zone 2 section → update its `(verified: YYYY-MM-DD)` date

### Start-Session Checks
8. Read Folder Note and check `(verified: YYYY-MM-DD)` dates
9. Flag any Zone 2 section older than 30 days as stale in the report
