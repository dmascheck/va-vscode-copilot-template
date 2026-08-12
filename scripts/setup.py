#!/usr/bin/env python3
"""
VA VS Code + Copilot Template — Project Setup Script

Automates initial project configuration:
1. Creates Python virtual environment and installs dependencies
2. Copies .env.example to .env.project (if not exists)
3. Installs git hooks (secret scanning, commit format)
4. Validates project structure
5. Shows recommended MCP servers

Usage:
    python scripts/setup.py
"""

import json
import platform
import shutil
import subprocess
import sys
from pathlib import Path

# ── Constants ──────────────────────────────────────────────────────────────────

PROJECT_ROOT = Path(__file__).resolve().parent.parent
VENV_DIR = PROJECT_ROOT / ".venv"
ENV_EXAMPLE = PROJECT_ROOT / ".env.example"
ENV_PROJECT = PROJECT_ROOT / ".env.project"
REQUIREMENTS = PROJECT_ROOT / "requirements.txt"
GIT_HOOKS_SCRIPT = PROJECT_ROOT / "scripts" / "setup-git-hooks.py"
VALIDATE_SCRIPT = PROJECT_ROOT / "scripts" / "validate-project.sh"

MCP_EXTENSION_SERVERS = [
    (
        "azure",
        "Azure resource management",
        "Deploy and manage Azure Government resources,"
        " check pricing, configure RBAC — all from Copilot"
        " chat. Comes with the Azure GitHub Copilot extension.",
    ),
    (
        "bicep",
        "Bicep IaC validation",
        "Validates your Bicep templates, shows resource"
        " schemas, and lists Azure Verified Modules."
        " Comes with the Bicep extension.",
    ),
    (
        "github",
        "GitHub repos, PRs, issues",
        "Create PRs, search code, manage issues, and run"
        " Copilot reviews without leaving VS Code."
        " Comes with GitHub Copilot.",
    ),
    (
        "microsoft-learn",
        "Microsoft Learn docs",
        "Searches official Microsoft docs and code samples"
        " so Copilot answers are grounded in current,"
        " authoritative content."
        " Comes with the Azure GitHub Copilot extension.",
    ),
]

MCP_NPX_SERVERS = [
    (
        "context7",
        "Library/framework docs",
        "Fetches up-to-date docs for React, FastAPI,"
        " Django, Tailwind, etc. — so Copilot uses"
        " current API syntax, not stale training data.",
        "npx",
        ["-y", "@context7/mcp"],
    ),
    (
        "sequential-thinking",
        "Structured reasoning",
        "Breaks down complex problems step by step"
        " before jumping to code. Great for architecture"
        " decisions and debugging hard issues.",
        "npx",
        ["-y", "@anthropic/mcp-sequential-thinking"],
    ),
    (
        "drawio",
        "Architecture diagrams",
        "Creates Draw.io diagrams from natural language."
        " Useful for documentation, ATO packages,"
        " and design reviews.",
        "npx",
        ["-y", "@anthropic/mcp-drawio"],
    ),
    (
        "playwright",
        "Browser testing",
        "Automates browser interactions — navigate pages,"
        " fill forms, take screenshots, run E2E tests."
        " Great for testing your frontend.",
        "npx",
        ["-y", "@anthropic/mcp-playwright"],
    ),
    (
        "filesystem",
        "File operations",
        "Gives Copilot reliable file access for large-scale"
        " refactoring, file organization, and cross-file"
        " operations.",
        "npx",
        ["-y", "@anthropic/mcp-filesystem", "."],
    ),
]


# ── Helpers ────────────────────────────────────────────────────────────────────


def print_banner():
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║       VA VS Code + Copilot Template — Setup                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()


def print_step(num, total, msg):
    print(f"\n  [{num}/{total}] {msg}")
    print(f"  {'─' * 50}")


def print_ok(msg):
    print(f"  ✅ {msg}")


def print_warn(msg):
    print(f"  ⚠️  {msg}")


def print_skip(msg):
    print(f"  ⏭️  {msg}")


def print_fail(msg):
    print(f"  ❌ {msg}")


def run_cmd(cmd, cwd=None, check=True):
    """Run a shell command and return the result."""
    result = subprocess.run(
        cmd,
        cwd=cwd or PROJECT_ROOT,
        capture_output=True,
        text=True,
    )
    if check and result.returncode != 0:
        print_fail(f"Command failed: {' '.join(cmd)}")
        if result.stderr:
            print(f"       {result.stderr.strip()}")
        return None
    return result


# ── Setup Steps ────────────────────────────────────────────────────────────────

TOTAL_STEPS = 6


def step_python_env():
    """Step 1: Create venv and install dependencies."""
    print_step(1, TOTAL_STEPS, "Python Environment")

    if VENV_DIR.exists():
        print_ok("Virtual environment already exists at .venv/")
    else:
        print("  Creating virtual environment...")
        result = run_cmd([sys.executable, "-m", "venv", str(VENV_DIR)])
        if result is None:
            print_fail("Could not create virtual environment")
            return False
        print_ok("Created .venv/")

    # Determine pip path
    if platform.system() == "Windows":
        pip_path = VENV_DIR / "Scripts" / "pip"
    else:
        pip_path = VENV_DIR / "bin" / "pip"

    if not pip_path.exists():
        print_fail(f"pip not found at {pip_path}")
        return False

    if REQUIREMENTS.exists():
        print("  Installing dependencies from requirements.txt...")
        result = run_cmd([str(pip_path), "install", "-r", str(REQUIREMENTS)])
        if result is None:
            print_warn("Some dependencies may have failed to install")
            return True  # Non-fatal
        print_ok("Dependencies installed")
    else:
        print_skip("No requirements.txt found")

    return True


def step_env_file():
    """Step 2: Create .env.project from .env.example."""
    print_step(2, TOTAL_STEPS, "Environment Configuration")

    if ENV_PROJECT.exists():
        print_ok(".env.project already exists")
        return True

    if not ENV_EXAMPLE.exists():
        print_warn(".env.example not found — skipping")
        return True

    shutil.copy2(ENV_EXAMPLE, ENV_PROJECT)
    print_ok("Created .env.project from .env.example")
    print_warn(
        "Edit .env.project with your project name,"
        " Azure Gov region, and compliance settings"
    )
    print(f"       File: {ENV_PROJECT}")

    return True


def step_log_dirs():
    """Step 3: Create Logs/ directory structure."""
    print_step(3, TOTAL_STEPS, "Log Directories")

    log_dirs = [
        "Logs/chat",
        "Logs/decisions",
        "Logs/issues",
        "Logs/lessons",
        "Logs/logging",
        "Logs/plans",
        "Logs/sessions",
    ]

    created = 0
    for d in log_dirs:
        dir_path = PROJECT_ROOT / d
        if not dir_path.exists():
            dir_path.mkdir(parents=True, exist_ok=True)
            created += 1

    if created > 0:
        print_ok(f"Created {created} log directories")
    else:
        print_ok("Log directories already exist")

    return True


def step_git_hooks():
    """Step 4: Install git hooks."""
    print_step(4, TOTAL_STEPS, "Git Hooks")

    # Check if we're in a git repo
    if not (PROJECT_ROOT / ".git").exists():
        print_skip("Not a git repository — skipping hooks")
        return True

    if not GIT_HOOKS_SCRIPT.exists():
        print_skip("setup-git-hooks.py not found — skipping")
        return True

    # Use the venv python if available, else system python
    if platform.system() == "Windows":
        python_path = VENV_DIR / "Scripts" / "python"
    else:
        python_path = VENV_DIR / "bin" / "python"

    if not python_path.exists():
        python_path = Path(sys.executable)

    result = run_cmd([str(python_path), str(GIT_HOOKS_SCRIPT)], check=False)
    if result and result.returncode == 0:
        print_ok("Git hooks installed (secret scanning, commit format)")
    else:
        print_warn(
            "Git hooks setup had issues — you can retry"
            " with: python scripts/setup-git-hooks.py"
        )

    return True


def step_validate():
    """Step 5: Validate project structure."""
    print_step(5, TOTAL_STEPS, "Project Validation")

    # Check key files exist
    checks = [
        (".github/copilot-instructions.md", "Copilot instructions"),
        (".github/agents/developer.agent.md", "Developer agent"),
        (".github/instructions/security.instructions.md", "Security instructions"),
        (".github/prompts/va-project.prompt.md", "VA project prompt"),
        (".vscode/settings.json", "VS Code settings"),
        (".vscode/extensions.json", "Extension recommendations"),
        ("pyproject.toml", "Python project config"),
        ("ruff.toml", "Ruff linting config"),
    ]

    all_ok = True
    for path, name in checks:
        if (PROJECT_ROOT / path).exists():
            print_ok(name)
        else:
            print_fail(f"{name} — missing: {path}")
            all_ok = False

    if all_ok:
        print_ok("All core files present")

    return True


def step_mcp_servers():
    """Step 6: Configure MCP servers interactively."""
    print_step(6, TOTAL_STEPS, "MCP Servers (Optional)")

    print("  MCP servers extend Copilot's capabilities by")
    print("  connecting it to external tools and services.")
    print()
    print("  We recommend all of them, but you can skip any")
    print("  and add them later. It's totally OK to say no.")
    print()

    # ── Extension-provided servers (always available) ────────
    print("  These 4 servers come FREE with the extensions")
    print("  you already installed — nothing to configure:\n")
    for name, short, desc in MCP_EXTENSION_SERVERS:
        print(f"    ✅ {name:<20} {short}")
        print(f"       {desc}")
        print()

    # ── NPX-based servers (need Node.js) ─────────────────────
    has_node = shutil.which("node") is not None
    has_npx = shutil.which("npx") is not None

    if not has_node or not has_npx:
        print("  The following 5 servers need Node.js to run.")
        print("  Node.js is not installed on this machine.")
        print("  Install Node.js (https://nodejs.org) and")
        print("  re-run this setup to configure them.\n")
        for name, short, desc, _, _ in MCP_NPX_SERVERS:
            print(f"    ⏭️  {name:<20} {short}")
        print()
        return True

    print("  The following 5 servers can be installed now.")
    print("  Each one is optional — we recommend all of them")
    print("  but it's fine to skip any.\n")

    selected = []
    for name, short, desc, cmd, args in MCP_NPX_SERVERS:
        print(f"    📦 {name}")
        print(f"       {desc}")
        answer = (
            input(f"       Install {name}? (Y/n — press Enter for yes): ")
            .strip()
            .lower()
        )
        if answer in ("", "y", "yes"):
            selected.append((name, cmd, args))
            print(f"       ✅ {name} selected\n")
        else:
            print("       ⏭️  Skipped\n")

    if not selected:
        print("  No MCP servers selected. You can add")
        print("  them later — see MCP_SERVERS.md.")
        return True

    # Write .vscode/mcp.json
    mcp_json_path = PROJECT_ROOT / ".vscode" / "mcp.json"
    servers = {}
    for name, cmd, args in selected:
        servers[name] = {
            "type": "stdio",
            "command": cmd,
            "args": args,
        }

    mcp_config = {"servers": servers}

    # Merge with existing mcp.json if it exists
    if mcp_json_path.exists():
        try:
            with open(mcp_json_path, encoding="utf-8") as f:
                existing = json.load(f)
            if "servers" in existing:
                existing["servers"].update(servers)
                mcp_config = existing
        except (json.JSONDecodeError, KeyError):
            pass  # Overwrite if malformed

    with open(mcp_json_path, "w", encoding="utf-8") as f:
        json.dump(mcp_config, f, indent=2)
        f.write("\n")

    print(f"  ✅ {len(selected)} MCP server(s) configured in .vscode/mcp.json")
    print("  Restart VS Code to activate them.")

    return True


# ── Main ───────────────────────────────────────────────────────────────────────


def main():
    print_banner()

    # Check Python version
    if sys.version_info < (3, 10):
        print_fail(f"Python 3.10+ required (you have {sys.version})")
        sys.exit(1)
    print_ok(
        f"Python {sys.version_info.major}"
        f".{sys.version_info.minor}"
        f".{sys.version_info.micro}"
    )

    # Run steps
    step_python_env()
    step_env_file()
    step_log_dirs()
    step_git_hooks()
    step_validate()
    step_mcp_servers()

    # Summary
    print("\n")
    print("  ══════════════════════════════════════════════════════════")
    print("  ✅ Setup complete!")
    print()
    print("  Next steps:")
    print("    1. Edit .env.project with your project settings")
    print("    2. Open Copilot Chat (Cmd+Shift+I) and type #va-project")
    print("    3. The wizard will configure your project")
    print("       and help you start building")
    print("  ══════════════════════════════════════════════════════════")
    print()


if __name__ == "__main__":
    main()
