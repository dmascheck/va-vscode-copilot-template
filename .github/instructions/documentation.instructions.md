---
applyTo: "**/*.md"
description: "Markdown standards, ADR format, and documentation conventions"
---

# Documentation Standards

## Architecture Decision Records (ADRs)

Store in `docs/decisions/ADR-NNN-title.md`:

```markdown
# ADR-NNN: Title

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** YYYY-MM-DD
**Deciders:** [names]

## Context
[What is the issue? What forces are at play?]

## Decision
[What is the decision? Why this approach?]

## Consequences
[What are the positive and negative outcomes?]

## VA Compliance Impact
[Does this affect FedRAMP, HIPAA, or ATO posture?]
```

## CHANGELOG Format

Follow Keep a Changelog:
- Group under: Added, Fixed, Changed, Removed
- Include version number and date
- Link to relevant ADRs when applicable

## General Markdown

- One sentence per line (better diffs)
- Use ATX headers (`#`, `##`, `###`)
- Code blocks with language identifiers
- Tables for structured data
