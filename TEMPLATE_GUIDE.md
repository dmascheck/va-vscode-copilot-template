# VA VS Code + Copilot Project Template Guide

**Purpose:** Explains the template structure, how customizations work, and how to maintain it.
**Note:** This file exists only in the template repo. Remove it when creating a project from this template.
**Version:** 1.0.0 | Last Updated: 2026-04-30

---

## Quick Start

1. Clone this repo or download it
2. Open in VS Code
3. Type `#va-project` in Copilot Chat — the wizard configures everything
4. Type `#start-session` to begin working

---

## Architecture

```
project/
├── .github/
│   ├── copilot-instructions.md      # Always-on Copilot rules (VA-customized)
│   ├── agents/                      # 8 specialist agents
│   ├── instructions/                # 15 auto-applied rule files
│   ├── prompts/                     # 20 workflow commands
│   └── context/                     # 9 project state files
├── .vscode/
│   ├── settings.json                # Editor + Copilot config
│   ├── extensions.json              # 15 recommended extensions
│   ├── tasks.json                   # One-keystroke automation
│   ├── launch.json                  # F5 debug configs
│   ├── hooks.json                   # Agent lifecycle hooks
│   └── template.code-snippets       # Code snippets
├── backend/                         # Python/FastAPI backend
├── web/                             # React/TypeScript frontend
├── infrastructure/                  # Bicep IaC
├── docs/                            # Architecture + compliance docs
├── scripts/                         # 8 automation scripts
├── tests/                           # Test suite
├── Logs/                            # Session history (gitignored)
├── PROJECT_INTENT.md                # Project purpose + VA compliance profile
├── TEMPLATE_GUIDE.md                # This file (remove for real projects)
└── .env.example                     # Environment template
```

---

## Agents (`@agent-name` in chat)

| Agent             | Role           | Key Trait                                                  |
| ----------------- | -------------- | ---------------------------------------------------------- |
| `@developer`      | Implementation | Python/FastAPI, React, Azure SDK. TDD required.            |
| `@infrastructure` | Azure IaC      | Bicep, Azure Government, FedRAMP compliance.               |
| `@qa`             | Quality        | Testing, security, HIPAA/FedRAMP/VA validation. READ-ONLY. |
| `@scrum-master`   | Planning       | Sprint planning, task breakdown. NO CODE.                  |
| `@debugger`       | Diagnostics    | Systematic investigation. Read-only.                       |
| `@documenter`     | Docs           | API docs, README, CHANGELOG.                               |
| `@scanner`        | Code scan      | Regenerates CODE_MAP.md + API_REFERENCE.md.                |
| `@auditor`        | Health         | Checks context, env, git for staleness. READ-ONLY.         |

## Instructions (auto-applied)

| File                                 | Activates When       | Purpose                                     |
| ------------------------------------ | -------------------- | ------------------------------------------- |
| `azure-gov.instructions.md`          | Azure discussed      | Azure Government + FedRAMP compliance gate  |
| `security.instructions.md`           | Always               | FedRAMP, HIPAA, NIST 800-53, VA 6500, OWASP |
| `azure.instructions.md`              | Infrastructure files | Deployment, Bicep, resource standards       |
| `azure-sdk.instructions.md`          | Python files         | DefaultAzureCredential, retry policies      |
| `git.instructions.md`                | Always               | Branching, overwrite guard                  |
| `session.instructions.md`            | Always               | Context management                          |
| `session-protocol.instructions.md`   | Always               | Session lifecycle rules                     |
| `python.instructions.md`             | Python files         | FastAPI patterns, type hints                |
| `frontend.instructions.md`           | web/ files           | React/TypeScript, Section 508               |
| `testing.instructions.md`            | Test files           | pytest, Playwright, synthetic test data     |
| `documentation.instructions.md`      | Markdown files       | ADR format, changelog                       |
| `debugging-backend.instructions.md`  | backend/ files       | Backend debugging                           |
| `debugging-frontend.instructions.md` | web/ files           | Frontend debugging                          |
| `verbose-logging.instructions.md`    | Always               | Mandatory verbose logging                   |

## Prompts (`#command` in chat)

| Category           | Commands                                                                               |
| ------------------ | -------------------------------------------------------------------------------------- |
| **Setup**          | `#va-project` (interactive wizard)                                                     |
| **Session**        | `#start-session`, `#end-session`, `#sync-context`, `#quick-save`, `#status`            |
| **Development**    | `#debug`, `#challenge`, `#quality-report`, `#deep-scan`, `#health-check`, `#log-issue` |
| **Infrastructure** | `#infra-sync`, `#pre-deploy`, `#plan-check`                                            |
| **Saving**         | `#save-chat`, `#save-plan`                                                             |
| **Security**       | `#security-scan`                                                                       |
| **Migration**      | `#migrate-project`                                                                     |
| **Template**       | `#template-scan`                                                                       |

## VA-Specific Features

- **FedRAMP High** compliance gates in every agent
- **Azure Government** endpoints enforced (`.us` domains)
- **PIV/CAC** authentication patterns
- **VHA Directive 6066** PHI handling rules
- **NIST 800-53** High baseline controls
- **VA 6500 Handbook** security standards
- **Section 508** accessibility requirements in frontend
- **Synthetic test data** mandate (no real veteran data)

---

## Context Files

| File                 | Purpose                                             |
| -------------------- | --------------------------------------------------- |
| `PROJECT_CONTEXT.md` | Current state snapshot                              |
| `TODO.md`            | Task tracking                                       |
| `COMMAND_LOG.md`     | Session history (archive at 150KB)                  |
| `NEXT_SESSION.md`    | Resume point                                        |
| `CODE_MAP.md`        | Code structure (regenerated by `#deep-scan`)        |
| `ISSUES_RESOLVED.md` | Bug documentation                                   |
| `LESSONS_LEARNED.md` | Anti-patterns (pre-loaded with VA-specific lessons) |
| `TEST_PLAN.md`       | Test strategy                                       |
| `PROJECT_INTENT.md`  | Project purpose + VA compliance profile (in root)   |

---

## Version History

| Version | Date       | Changes                                                                                                                 |
| ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
| 1.0.0   | 2026-04-30 | Initial VA template: 8 agents, 15 instructions, 20 prompts, FedRAMP/HIPAA/VA compliance, Azure Government, setup wizard |
