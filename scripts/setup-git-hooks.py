#!/usr/bin/env python3
"""
Git Hooks Setup Script - Part of Template v2.4.0

Installs comprehensive git hooks for testing enforcement:
- pre-commit: Security checks + linting + unit tests + debugging code detection
- pre-push: Full test suite + coverage threshold
- commit-msg: Conventional commit format validation
- prepare-commit-msg: Block direct commits to main branch

Run once per project to install hooks.
"""

import os
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
os.chdir(ROOT)

# ANSI colors
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"


def print_header(text):
    print(f"\n{BLUE}{'=' * 70}{NC}")
    print(f"{BLUE}{text}{NC}")
    print(f"{BLUE}{'=' * 70}{NC}\n")


def print_success(text):
    print(f"{GREEN}✅ {text}{NC}")


def print_warning(text):
    print(f"{YELLOW}⚠️  {text}{NC}")


def print_error(text):
    print(f"{RED}❌ {text}{NC}")


def merge_hooks(security_hook, testing_hook, output_hook):
    """Merge security and testing hooks into one pre-commit hook"""
    with open(security_hook, "r", encoding="utf-8") as f:
        security_content = f.read()

    with open(testing_hook, "r", encoding="utf-8") as f:
        testing_content = f.read()

    # Remove shebang from testing hook (keep only one)
    testing_content = "\n".join(
        [
            line
            for line in testing_content.split("\n")
            if not line.startswith("#!/bin/bash")
        ]
    )

    # Combine: security checks first, then testing
    merged = security_content.rstrip() + "\n\n" + testing_content.lstrip()

    with open(output_hook, "w", encoding="utf-8") as f:
        f.write(merged)

    return True


def install_hooks():
    """Install all git hooks"""
    print_header("Installing Git Hooks")

    git_dir = Path(".git")
    if not git_dir.exists():
        print_error("Not a git repository!")
        return False

    hooks_dir = git_dir / "hooks"
    hooks_dir.mkdir(exist_ok=True)

    source_hooks_dir = Path(".githooks")
    if not source_hooks_dir.exists():
        print_error(".githooks directory not found!")
        return False

    hooks_installed = []

    # 1. Install pre-commit hook (security + lint)
    print(f"{YELLOW}📝 Installing pre-commit hook (security + lint)...{NC}")
    security_hook = source_hooks_dir / "pre-commit"
    testing_hook = source_hooks_dir / "pre-commit-testing"
    output_hook = hooks_dir / "pre-commit"

    if security_hook.exists() and testing_hook.exists():
        if merge_hooks(security_hook, testing_hook, output_hook):
            output_hook.chmod(0o755)
            print_success("pre-commit hook installed (security + testing)")
            hooks_installed.append("pre-commit")
        else:
            print_error("Failed to merge pre-commit hooks")
    elif security_hook.exists():
        shutil.copy(security_hook, output_hook)
        output_hook.chmod(0o755)
        print_success("pre-commit hook installed (security + lint)")
        hooks_installed.append("pre-commit")
    else:
        print_warning("pre-commit hooks not found, skipping")

    # 2. Install pre-push hook
    print(f"{YELLOW}📝 Installing pre-push hook...{NC}")
    pre_push_source = source_hooks_dir / "pre-push"
    pre_push_dest = hooks_dir / "pre-push"

    if pre_push_source.exists():
        shutil.copy(pre_push_source, pre_push_dest)
        pre_push_dest.chmod(0o755)
        print_success("pre-push hook installed (full test suite + coverage)")
        hooks_installed.append("pre-push")
    else:
        print_warning("pre-push hook not found, skipping")

    # 3. Install commit-msg hook
    print(f"{YELLOW}📝 Installing commit-msg hook...{NC}")
    commit_msg_source = source_hooks_dir / "commit-msg"
    commit_msg_dest = hooks_dir / "commit-msg"

    if commit_msg_source.exists():
        shutil.copy(commit_msg_source, commit_msg_dest)
        commit_msg_dest.chmod(0o755)
        print_success("commit-msg hook installed (conventional commits)")
        hooks_installed.append("commit-msg")
    else:
        print_warning("commit-msg hook not found, skipping")

    # 4. Install prepare-commit-msg hook
    print(f"{YELLOW}📝 Installing prepare-commit-msg hook...{NC}")
    prepare_commit_source = source_hooks_dir / "prepare-commit-msg"
    prepare_commit_dest = hooks_dir / "prepare-commit-msg"

    if prepare_commit_source.exists():
        shutil.copy(prepare_commit_source, prepare_commit_dest)
        prepare_commit_dest.chmod(0o755)
        print_success("prepare-commit-msg hook installed (block main commits)")
        hooks_installed.append("prepare-commit-msg")
    else:
        print_warning("prepare-commit-msg hook not found, skipping")

    print()
    return hooks_installed


def test_hooks():
    """Test that hooks are working"""
    print_header("Testing Git Hooks")

    hooks_dir = Path(".git/hooks")

    # Check if hooks are executable
    hooks_to_test = ["pre-commit", "pre-push", "commit-msg", "prepare-commit-msg"]

    all_working = True
    for hook in hooks_to_test:
        hook_path = hooks_dir / hook
        if hook_path.exists():
            if os.access(hook_path, os.X_OK):
                print_success(f"{hook} is installed and executable")
            else:
                print_error(f"{hook} is not executable!")
                all_working = False
        else:
            print_warning(f"{hook} not found")

    print()
    return all_working


def print_usage_guide():
    """Print usage guide for the hooks"""
    print_header("Git Hooks Usage Guide")

    print(f"{BLUE}Installed Hooks:{NC}\n")

    print(f"{GREEN}1. pre-commit{NC} - Runs before every commit")
    print("   • Checks for connection strings and secrets")
    print("   • Detects debugging code (console.log, debugger, print)")
    print("   • Runs linting")
    print("   • Runs unit tests")
    print("   • Blocks commit if any check fails\n")

    print(f"{GREEN}2. pre-push{NC} - Runs before every push")
    print("   • Runs full test suite")
    print("   • Checks test coverage (minimum 70%)")
    print("   • Blocks push if tests fail or coverage too low\n")

    print(f"{GREEN}3. commit-msg{NC} - Validates commit message format")
    print("   • Enforces conventional commits (feat:, fix:, etc.)")
    print("   • Requires minimum 10 character description")
    print("   • Suggests imperative mood\n")

    print(f"{GREEN}4. prepare-commit-msg{NC} - Protects main branch")
    print("   • Blocks direct commits to main/master")
    print("   • Forces feature branch workflow")
    print("   • Keeps main branch stable\n")

    print(f"{YELLOW}Bypassing Hooks (NOT RECOMMENDED):{NC}")
    print("  git commit --no-verify")
    print("  git push --no-verify\n")

    print(f"{YELLOW}When to bypass:{NC}")
    print("  • Emergency hotfixes (document why in commit message)")
    print("  • Work in progress commits on feature branches")
    print("  • When tests are temporarily broken (fix ASAP)\n")

    print(f"{BLUE}Examples:{NC}\n")

    print(f"{GREEN}Good commit message:{NC}")
    print("  feat: add user authentication with JWT")
    print("  fix: resolve memory leak in data processing")
    print("  test: add unit tests for auth module\n")

    print(f"{RED}Bad commit message (will be blocked):{NC}")
    print("  updated stuff")
    print("  WIP")
    print("  Fixed bug\n")


def main():
    print_header("Git Hooks Setup - Template v2.4.0")

    print("This script will install comprehensive git hooks for:")
    print("  • Security enforcement (no secrets in code)")
    print("  • Testing enforcement (tests must pass)")
    print("  • Code quality (linting must pass)")
    print("  • Commit standards (conventional commits)")
    print("  • Branch protection (no direct commits to main)")
    print()

    # Install hooks
    hooks_installed = install_hooks()

    if not hooks_installed:
        print_error("No hooks were installed!")
        return 1

    # Test hooks
    if not test_hooks():
        print_warning("Some hooks may not be working correctly")

    # Print usage guide
    print_usage_guide()

    print_header("✅ Git Hooks Setup Complete!")

    print(f"{GREEN}Installed {len(hooks_installed)} hooks:{NC}")
    for hook in hooks_installed:
        print(f"  • {hook}")
    print()

    print(f"{YELLOW}Next steps:{NC}")
    print("  1. Try making a commit to test the hooks")
    print("  2. Read the usage guide above")
    print("  3. See .github/AGENTS.md for full workflow")
    print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
