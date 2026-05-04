# VA VS Code + GitHub Copilot Project Template

> **TL;DR:** Clone this repo, open it in VS Code, run one setup command, and get a fully configured AI-powered development environment built for the VA. Eight specialist AI agents, 20 workflow commands, VA security guidance, Azure Government patterns, and pre-configured tooling — all ready to go. No setup guesswork. Whether you're a seasoned developer or just starting to explore AI-assisted coding, this template gives you guardrails, best practices, and real productivity from day one.

---

## Why This Exists

Building software at the VA means navigating FedRAMP, HIPAA, NIST 800-53, Azure Government, PIV/CAC authentication, VHA Directive 6066, and a dozen other requirements — before you write a single line of code.

This template encodes all of that knowledge into your editor so you don't have to memorize it.

**Instead of:**

- Reading 200-page compliance docs to figure out which Azure endpoint to use
- Guessing whether your code handles PHI correctly
- Setting up linting, formatting, testing, and deployment from scratch for every project
- Asking "how do I structure a VA project?"

**You get:**

- AI agents that already know VA rules and guide you as you code
- Pre-configured security, compliance, and Azure Government patterns
- One-command setup that works on macOS, Windows, and Linux
- Workflow commands for everything from debugging to deployment

---

## Quick Start

### Option A: Use as a GitHub Template (recommended)

1. Click the green **"Use this template"** button at the top of this page
2. Name your new repo and click **Create repository**
3. Clone your new repo and open it in VS Code
4. Run the setup script:

```bash
python scripts/setup.py
```

### Option B: Guided Setup with Copilot

1. Clone the repo and open in VS Code
2. Open Copilot Chat (Ctrl+Shift+I / Cmd+Shift+I)
3. Type `#va-project` — the wizard walks you through everything conversationally

### Option C: Manual Setup (fallback)

If the script or Copilot aren't available, follow the [Manual Setup Guide](#manual-setup) below.

---

## What You Get When You Open This Repo

The moment you open this project in VS Code, the following activates **automatically** — no commands to run:

| What                           | How                                  | What it does for you                                                     |
| ------------------------------ | ------------------------------------ | ------------------------------------------------------------------------ |
| **13 recommended extensions**  | VS Code prompts you to install       | Python, Copilot, Azure tools, linting, testing — the full toolkit        |
| **14 instruction files**       | Copilot reads them automatically     | Every AI suggestion follows VA security, Azure Gov, and coding standards |
| **8 specialist agents**        | Available via `@agent` in chat       | Ask `@developer` to build, `@qa` to review, `@infrastructure` to deploy  |
| **20 workflow prompts**        | Available via `#command` in chat     | `#debug`, `#security-scan`, `#pre-deploy` — one command, full workflow   |
| **Formatting on save**         | Ruff auto-formats Python files       | Consistent code style without thinking about it                          |
| **Task runners**               | Terminal > Run Task                  | `test`, `lint`, `lint-fix` available immediately                         |
| **Dangerous command warnings** | Hooks detect risky terminal commands | Warns before `rm -rf`, `git push --force`, `az group delete`             |

---

## The AI Team: 8 Specialist Agents

Type `@agent-name` in Copilot Chat to activate. Each agent has a specific role and set of rules — they don't overlap, and they don't step on each other's work.

### `@developer` — Your Lead Engineer

Writes production-ready Python/FastAPI, React/TypeScript, and Azure SDK code. Follows test-driven development. Checks git history before modifying any file to avoid overwriting recent work. Never produces stubs or placeholders — every function is complete.

**When to use:** "Build the patient lookup API." / "Fix the authentication bug." / "Add input validation to this endpoint."

### `@infrastructure` — Your Cloud Engineer

Handles Bicep IaC, Azure Government resource creation, FedRAMP-compliant networking (private endpoints, VNet integration), and deployment pipelines. Verifies Azure CLI is set to Government cloud before any operation.

**When to use:** "Set up the Azure resources for this project." / "Create a Bicep template for Cosmos DB with private endpoints." / "Why is my App Service timing out?"

### `@qa` — Your Security and Quality Reviewer

Read-only by default. Reviews code for OWASP vulnerabilities, HIPAA compliance, FedRAMP controls, and VA 6500 Handbook adherence. Reports findings with severity levels (Critical / Warning / Suggestion) — does not auto-fix unless you ask.

**When to use:** "Review this PR for security issues." / "Is this code HIPAA compliant?" / "Run a quality audit on the backend."

### `@scrum-master` — Your Project Manager

Plans sprints, breaks down work into tasks, tracks progress in TODO.md, and coordinates the other agents. Never writes code — only orchestrates. Asks exhaustive discovery questions before planning.

**When to use:** "Plan the next sprint." / "Break down this feature into tasks." / "What's the project status?"

### `@debugger` — Your Diagnostician

Systematically investigates bugs: reproduce → isolate → diagnose → fix → document. Checks recent git changes and resolved issues before suggesting solutions. Handles both code bugs and Azure Government connectivity issues.

**When to use:** "I'm getting a 403 from Azure." / "This test is failing intermittently." / "Why is the API returning empty results?"

### `@documenter` — Your Technical Writer

Generates API documentation, README files, CHANGELOG entries, and architecture decision records. Follows Markdown standards and VA documentation conventions.

**When to use:** "Generate API docs for the backend." / "Write a CHANGELOG entry for this release." / "Document this architecture decision."

### `@scanner` — Your Code Cartographer

Scans the entire project and regenerates `CODE_MAP.md` — a structured map of every file, function, and module. Useful for onboarding or when you need a bird's-eye view of the codebase.

**When to use:** "Map this codebase." / "What does the project structure look like?" / "Regenerate the code map."

### `@auditor` — Your Health Inspector

Read-only audit of project health: checks context files for staleness, `.env` configuration, git status, dependency vulnerabilities, and Azure resource state. Reports what's wrong but never changes anything.

**When to use:** "Is this project healthy?" / "Check for stale dependencies." / "Audit the project state."

---

## 20 Workflow Commands

Type `#command` in Copilot Chat to run any of these. Each command is a complete workflow — not just a single action.

### Getting Started

| Command          | What it does                                                                                                                                                                              |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `#va-project`    | **New project wizard.** Configures your environment (name, compliance, tech stack), asks what you want to build, creates a plan, and starts building. Run this first.                     |
| `#start-session` | **Session initializer.** Syncs git, runs health check, loads project context, reads TODO.md, and presents a dashboard of where things stand. Run this at the start of every work session. |

### Day-to-Day Development

| Command           | What it does                                                                                                                       |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `#debug`          | **Full diagnostic workflow.** Reproduce → isolate → diagnose → fix → document. Handles both code bugs and Azure Government issues. |
| `#challenge`      | **Challenge your assumptions.** Ask Copilot to push back on your approach, find edge cases, and argue against your design.         |
| `#quality-report` | **Code quality audit.** Runs linting, type checking, test coverage, and reports on code health.                                    |
| `#deep-scan`      | **Full codebase scan.** Regenerates CODE_MAP.md with every file, function, and module mapped.                                      |
| `#health-check`   | **Quick project health audit.** Checks file staleness, git state, dependencies, and config.                                        |
| `#log-issue`      | **Document a resolved bug.** Records symptom, root cause, fix, and prevention in ISSUES_RESOLVED.md.                               |

### Infrastructure and Deployment

| Command       | What it does                                                                                                                                 |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `#infra-sync` | **Sync Azure state.** Queries your Azure Government resources and updates `.env.project` with current resource names, endpoints, and status. |
| `#pre-deploy` | **Deployment checklist.** Validates everything before you deploy — tests pass, secrets scanned, compliance verified, Azure resources ready.  |
| `#plan-check` | **Validate your plan.** Reviews your implementation plan for gaps, risks, and missing steps before you start building.                       |

### Session Management

| Command         | What it does                                                                                                                               |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `#end-session`  | **Save everything.** Generates a session summary, updates TODO.md, writes NEXT_SESSION.md with resume instructions, commits context files. |
| `#sync-context` | **Mid-session save.** Updates project state files without ending the session. Use every 3-4 hours in long sessions.                        |
| `#quick-save`   | **Fast save.** Quick commit of context files and current state.                                                                            |
| `#status`       | **Project status at a glance.** Shows TODO.md progress, git state, and recent activity.                                                    |
| `#save-chat`    | **Export chat history.** Saves the current Copilot conversation to Logs/ for reference.                                                    |
| `#save-plan`    | **Export a plan.** Saves a planning discussion to Logs/plans/ for future reference.                                                        |

### Security and Compliance

| Command          | What it does                                                                                                                                                                                                                  |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `#security-scan` | **Comprehensive security audit.** Scans for hardcoded secrets, checks dependencies for vulnerabilities, looks for OWASP patterns (SQL injection, XSS, CSRF), verifies Azure Government endpoints, and checks for PHI in logs. |

### Migration and Maintenance

| Command            | What it does                                                                                                                                 |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `#migrate-project` | **Migrate an existing project** into this template structure. Preserves your code while adding agents, instructions, and compliance tooling. |
| `#template-scan`   | **Check template freshness.** Compares your project against the latest template version and reports what's changed.                          |

---

## 14 Instruction Files (Automatic Copilot Guidance)

These files are loaded **automatically** by Copilot based on what you're working on. You never need to invoke them — they work in the background, shaping every AI suggestion to follow VA standards.

> **Important:** These are **best-practice guidance**, not hard blocks. Copilot will warn you when something deviates from VA standards and explain why, but it won't refuse to help. Teams can tighten enforcement if needed.

| Instruction File       | Activates When          | What it guides                                                                                                                     |
| ---------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **security**           | Always                  | FedRAMP High, HIPAA, NIST 800-53, OWASP Top 10, secret scanning, PHI handling                                                      |
| **verbose-logging**    | Always                  | Structured logging best practices — timestamps, severity, correlation IDs. Recommends `logging` over `print()` for production code |
| **git**                | Always                  | Branch naming (`YYYYMMDD-feature`), conventional commits, overwrite guard (checks recent changes before modifying files)           |
| **session-protocol**   | Always                  | Session lifecycle — start, sync, end workflows to maintain project context across sessions                                         |
| **session**            | Always                  | Session self-monitoring — reminds you to save state in long sessions                                                               |
| **azure-gov**          | When Azure is discussed | Azure Government endpoints (`.us` domains), FedRAMP networking, private endpoints                                                  |
| **azure-sdk**          | Python files            | `DefaultAzureCredential` with Government authority, retry policies, singleton clients                                              |
| **azure**              | Infrastructure files    | Bicep patterns, deployment scripts, resource naming                                                                                |
| **python**             | Python files            | FastAPI patterns, type hints, Pydantic models, async best practices                                                                |
| **frontend**           | Web files               | React/TypeScript, Vite, TailwindCSS, Section 508 accessibility                                                                     |
| **testing**            | Test files              | pytest patterns, Playwright E2E, synthetic test data (never real PHI), coverage targets                                            |
| **documentation**      | Markdown files          | ADR format, changelog standards, Markdown conventions                                                                              |
| **debugging-backend**  | Backend files           | Python debugging workflow, Azure connectivity diagnostics                                                                          |
| **debugging-frontend** | Web files               | Frontend debugging workflow, browser DevTools patterns                                                                             |

---

## Recommended MCP Servers (Optional)

[Model Context Protocol (MCP) servers](https://code.visualstudio.com/docs/copilot/chat/mcp-servers) extend Copilot's capabilities by connecting it to external tools and services. These are **optional** — your template works without them, but they add significant power.

| MCP Server              | What it does                                                            | Why it's useful                                                           |
| ----------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **azure**               | Manages Azure resources, deployments, monitoring, pricing, RBAC         | Deploy and manage Azure Government resources directly from chat           |
| **bicep**               | Validates Bicep IaC, provides schema help, lists Azure Verified Modules | Write correct Bicep templates the first time                              |
| **github**              | Manages repos, PRs, issues, branches, code search                       | Create PRs, search code, manage issues without leaving VS Code            |
| **context7**            | Fetches up-to-date documentation for libraries and frameworks           | Get current React, FastAPI, or any library docs — not stale training data |
| **sequential-thinking** | Structured reasoning for complex problems                               | Break down hard problems step by step before jumping to code              |
| **microsoft-learn**     | Searches and fetches official Microsoft Learn docs and code samples     | Get authoritative Azure/Microsoft answers grounded in official docs       |
| **drawio**              | Creates architecture diagrams                                           | Generate visual architecture diagrams from descriptions                   |
| **playwright**          | Browser automation, screenshots, form testing                           | Test your frontend with real browser interactions                         |
| **filesystem**          | File and directory operations                                           | Read, write, search, and organize files across your project               |

See [MCP_SERVERS.md](MCP_SERVERS.md) for installation instructions for each server.

---

## Pre-Configured Tooling

### Extensions (auto-recommended on open)

| Extension                     | What it does                                                |
| ----------------------------- | ----------------------------------------------------------- |
| GitHub Copilot + Copilot Chat | AI code generation and chat interface                       |
| Azure GitHub Copilot          | Azure-aware Copilot suggestions                             |
| Python + Pylance              | Language support, IntelliSense, debugging, test runner      |
| Ruff                          | Lightning-fast Python linting and formatting (runs on save) |
| Azure Account                 | Azure Government sign-in and subscription management        |
| Azure Cosmos DB               | Explore and query Cosmos DB databases                       |
| Azure Node Pack               | Azure Functions, App Service, Storage tools                 |
| Docker                        | Dockerfile support, container management                    |
| REST Client                   | Test APIs with `.http` files — no Postman needed            |
| Playwright                    | Browser testing framework integration                       |

### Task Runners (Terminal > Run Task)

| Task           | Command                                 | What it does                                 |
| -------------- | --------------------------------------- | -------------------------------------------- |
| `test`         | `python -m pytest tests/ -v`            | Run all tests with verbose output            |
| `lint`         | `ruff check . && ruff format --check .` | Check for lint errors and formatting issues  |
| `lint-fix`     | `ruff check --fix . && ruff format .`   | Auto-fix lint errors and reformat code       |
| `deploy-check` | `bash scripts/validate-project.sh`      | Validate project structure before deployment |
| `check-all`    | Runs `test` + `lint` in parallel        | Full quality check in one command            |

### Git Safety

- **Overwrite guard:** Before modifying any file, agents check `git log --since="24 hours ago"` and warn you if there are recent changes
- **Dangerous command detection:** Hooks warn before `rm -rf`, `git push --force`, `git reset --hard`, `az group delete`, `DROP TABLE`
- **Conventional commits:** Enforced commit style — `feat:`, `fix:`, `chore:`, `docs:`

---

## VA Security and Compliance Guidance

This template provides **guidance and warnings** for VA compliance standards. It does not block you from working — it educates and flags potential issues as you code.

| Standard                       | What the template does                                                                                                                                              |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **FedRAMP High**               | Warns when using commercial Azure endpoints instead of Government (`.us`). Guides private endpoint configuration. Flags public access on storage/databases.         |
| **HIPAA / VHA Directive 6066** | Warns when PHI might appear in logs, URLs, or error messages. Recommends field masking (`ssn=****1234`). Guides encryption at rest and in transit.                  |
| **NIST 800-53**                | Provides control-family guidance (Access Control, Audit, Encryption, Incident Response). Integrated into agent behavior and instruction files.                      |
| **OWASP Top 10**               | Security scan checks for SQL injection, XSS, CSRF, hardcoded secrets, and unsafe patterns.                                                                          |
| **VA 6500 Handbook**           | General VA security controls. Agents reference this during code review and architecture decisions.                                                                  |
| **Secret Scanning**            | Pre-commit hooks and `#security-scan` check for API keys, passwords, tokens, connection strings, and VA-specific identifiers (ICN, DFN, SSN) before they reach git. |

> **Note:** These are best practices, not hard enforcement. If your project requires strict enforcement (for example, blocking all code that doesn't use the logging framework), teams can tighten the instruction files. See [TEMPLATE_GUIDE.md](TEMPLATE_GUIDE.md) for how to customize enforcement levels.

---

## Project Structure

```
project/
├── .github/
│   ├── copilot-instructions.md      # Always-on Copilot rules
│   ├── agents/                      # 8 specialist AI agents
│   ├── instructions/                # 14 auto-applied guidance files
│   ├── prompts/                     # 20 workflow commands
│   └── context/                     # Project state + session tracking
├── .vscode/
│   ├── settings.json                # Editor, formatter, Copilot config
│   ├── extensions.json              # 13 recommended extensions
│   ├── tasks.json                   # test, lint, deploy-check tasks
│   ├── launch.json                  # F5 debug configurations
│   ├── hooks.json                   # Auto-format + safety hooks
│   └── template.code-snippets       # Code snippets
├── backend/                         # Python/FastAPI backend
├── web/                             # React/TypeScript frontend
├── infrastructure/                  # Bicep IaC templates
├── docs/                            # Architecture docs + decision records
├── scripts/                         # Setup, deploy, validation scripts
├── tests/                           # pytest + Playwright test suite
├── Logs/                            # Session logs (gitignored, local only)
├── .env.example                     # Environment variable template
├── PROJECT_INTENT.md                # Project purpose + compliance profile
├── pyproject.toml                   # Python project configuration
├── ruff.toml                        # Linting and formatting rules
└── requirements.txt                 # Python dependencies
```

---

## Manual Setup

If you can't run the setup script or prefer to configure manually:

1. **Install recommended extensions** — VS Code will prompt you, or run `Extensions: Show Recommended Extensions` from the command palette
2. **Create your environment file:**

   ```bash
   cp .env.example .env.project
   ```

   Edit `.env.project` with your project name, Azure Gov region, and compliance settings.

3. **Set up Python:**

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate   # macOS/Linux
   # .venv\Scripts\activate    # Windows
   pip install -r requirements.txt
   ```

4. **Install git hooks:**

   ```bash
   python scripts/setup-git-hooks.py
   ```

5. **Verify everything works:**
   ```bash
   python -m pytest tests/ -v
   ruff check .
   ```

---

## Prerequisites

| Requirement          | Minimum Version     | Check Command       |
| -------------------- | ------------------- | ------------------- |
| VS Code              | Latest stable       | `code --version`    |
| GitHub Copilot       | Active subscription | Extensions panel    |
| Python               | 3.12+               | `python3 --version` |
| Git                  | 2.30+               | `git --version`     |
| Azure CLI (optional) | Latest              | `az --version`      |

---

## Customization

This template is a starting point, not a straitjacket.

- **Add your own agents** — create `.github/agents/your-agent.agent.md`
- **Add your own prompts** — create `.github/prompts/your-command.prompt.md`
- **Modify instruction files** — edit any `.github/instructions/*.instructions.md` to match your team's standards
- **Tighten compliance** — change warnings to hard blocks in instruction files if your project requires strict enforcement
- **Add MCP servers** — see [MCP_SERVERS.md](MCP_SERVERS.md) for the full list and setup instructions

See [TEMPLATE_GUIDE.md](TEMPLATE_GUIDE.md) for detailed customization guidance.

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

This project is provided as-is for use by VA development teams and the broader community. See [LICENSE](LICENSE) for details.
