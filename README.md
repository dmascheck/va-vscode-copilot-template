# VA VS Code + GitHub Copilot Project Template

**Purpose:** A ready-to-use project template for Veterans Affairs development teams using VS Code with GitHub Copilot. Clone, open, run the setup wizard, and start building.

**Version:** 1.0.0 | Last Updated: 2026-04-30

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/dmascheck/va-vscode-copilot-template.git my-va-project
cd my-va-project

# 2. Open in VS Code
code .

# 3. Run the setup wizard in Copilot Chat
#va-setup
```

The setup wizard asks targeted questions about your project (compliance level, tech stack, Azure Gov region, VistA integration, PIV/CAC requirements) and configures all files automatically.

---

## What's Included

### Agents (8 specialist personas — `@agent-name` in chat)

| Agent | Role | Key Trait |
|-------|------|-----------|
| `@developer` | Implementation | Python/FastAPI, React, Azure SDK. TDD required. |
| `@infrastructure` | Azure IaC | Bicep, Azure Government, FedRAMP compliance, deployment. |
| `@qa` | Quality | Testing, security, HIPAA/FedRAMP validation. READ-ONLY. |
| `@scrum-master` | Planning | Sprint planning, task breakdown. NO CODE. |
| `@debugger` | Diagnostics | Systematic investigation. Read-only, delegates to @developer. |
| `@documenter` | Docs | API docs, README, CHANGELOG. |
| `@scanner` | Code scan | Regenerates CODE_MAP.md + API_REFERENCE.md. |
| `@auditor` | Health | Checks context, env, git, deps for staleness. READ-ONLY. |

### Instructions (15 auto-applied rule files)

Automatically loaded based on file patterns — no manual invocation needed. Includes VA-specific compliance (FedRAMP High, NIST 800-53, VHA Directive 6066), HIPAA, Azure Government patterns, and security standards.

### Prompts (20 workflow commands — `#command` in chat)

| Category | Commands |
|----------|----------|
| **Setup** | `#va-setup` (interactive project configuration wizard) |
| **Session** | `#start-session`, `#end-session`, `#sync-context`, `#quick-save`, `#status` |
| **Development** | `#debug`, `#challenge`, `#quality-report`, `#deep-scan`, `#health-check`, `#log-issue` |
| **Infrastructure** | `#infra-sync`, `#pre-deploy`, `#plan-check` |
| **Saving** | `#save-chat`, `#save-plan` |
| **Security** | `#security-scan` |
| **Migration** | `#migrate-project` |
| **Template** | `#template-scan` |

### Scripts (8 automation tools)

| Script | Purpose |
|--------|---------|
| `scripts/deploy.sh` | Deployment script |
| `scripts/deploy-with-private-endpoints.sh` | FedRAMP-compliant deployment with private endpoints |
| `scripts/setup_local.sh` | Local environment setup |
| `scripts/setup-git-hooks.py` | Install git hooks (secret scanning, commit format) |
| `scripts/validate-project.sh` | Project structure validation |
| `scripts/chat_digest.py` | Extract readable digest from Copilot session logs |
| `scripts/logging_config.py` | Centralized Python logging configuration |
| `scripts/lib/log.sh` | Centralized Bash logging library |

---

## Project Structure

```
project/
├── .github/
│   ├── copilot-instructions.md      # Always-on Copilot rules
│   ├── agents/                      # 8 specialist agents
│   ├── instructions/                # 15 auto-applied rule files
│   ├── prompts/                     # 20 workflow commands
│   ├── skills/                      # 3 reusable capabilities
│   └── context/                     # Project state files
├── .vscode/
│   ├── settings.json                # Editor + Copilot config
│   ├── extensions.json              # Recommended extensions
│   ├── tasks.json                   # One-keystroke automation
│   ├── launch.json                  # F5 debug configs
│   ├── hooks.json                   # Agent lifecycle hooks
│   └── template.code-snippets       # Code snippets
├── backend/                         # Python/FastAPI backend
├── web/                             # React/TypeScript frontend
├── infrastructure/                  # Bicep IaC
├── docs/                            # Architecture + compliance docs
├── scripts/                         # Automation scripts
├── tests/                           # Test suite
├── Logs/                            # Session history (gitignored)
├── .env.example                     # Environment template
├── PROJECT_INTENT.md                # Project purpose + VA context
└── TEMPLATE_GUIDE.md                # Full template reference
```

---

## VA-Specific Features

- **FedRAMP High / FISMA** compliance gates built into every agent and instruction
- **Azure Government** region support (usgovvirginia, usgovarizona)
- **PIV/CAC** authentication patterns
- **VistA/CPRS** integration guidance in developer and infrastructure agents
- **VHA Directive 6066** PHI handling rules in security instructions
- **NIST 800-53** control mapping in compliance documentation
- **VA 6500 Handbook** security standards enforcement
- **ATO (Authority to Operate)** awareness in deployment workflows

---

## Prerequisites

- **VS Code** 1.100+ with GitHub Copilot extension
- **GitHub Copilot** license (Business or Enterprise)
- **Python** 3.12+ and **Node.js** 20+
- **Azure CLI** with Azure Government cloud configured
- **Git** 2.40+

### Azure Government Setup

```bash
# Configure Azure CLI for Government cloud
az cloud set --name AzureUSGovernment
az login
```

---

## Customization

After running `#va-setup`, all `${PLACEHOLDER}` values are replaced with your project-specific configuration. To re-customize later, edit `.env.project` and run `#va-setup` again.

---

## Contributing

This template is maintained for VA development teams. To suggest improvements:
1. Fork the repo
2. Create a feature branch
3. Submit a pull request with description of changes

---

## License

Internal use — Veterans Affairs development teams.
