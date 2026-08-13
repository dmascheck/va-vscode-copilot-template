#!/bin/bash
# SessionStart Hook — Injects project context + verified environment at session start
# Reads context files, verifies tool prerequisites, and returns as additionalContext

set -e

# Read input from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

if [ -z "$CWD" ]; then
  echo '{"continue": true}'
  exit 0
fi

CONTEXT=""

# ============================================================
# PHASE 1: Project Context Injection
# ============================================================

# Read PROJECT_INTENT.md
if [ -f "$CWD/.github/context/PROJECT_INTENT.md" ]; then
  INTENT=$(cat "$CWD/.github/context/PROJECT_INTENT.md")
  CONTEXT="${CONTEXT}\n\n--- PROJECT INTENT ---\n${INTENT}"
fi

# Read PROJECT_CONTEXT.md
if [ -f "$CWD/.github/context/PROJECT_CONTEXT.md" ]; then
  CTX=$(cat "$CWD/.github/context/PROJECT_CONTEXT.md")
  CONTEXT="${CONTEXT}\n\n--- PROJECT CONTEXT ---\n${CTX}"
fi

# Read NEXT_SESSION.md
if [ -f "$CWD/.github/context/NEXT_SESSION.md" ]; then
  NEXT=$(cat "$CWD/.github/context/NEXT_SESSION.md")
  CONTEXT="${CONTEXT}\n\n--- NEXT SESSION ---\n${NEXT}"
fi

# Read TODO.md
if [ -f "$CWD/.github/context/TODO.md" ]; then
  TODO=$(cat "$CWD/.github/context/TODO.md")
  CONTEXT="${CONTEXT}\n\n--- TODO ---\n${TODO}"
fi

# Read .env.project (non-secret resource names)
if [ -f "$CWD/.env.project" ]; then
  ENV=$(cat "$CWD/.env.project")
  CONTEXT="${CONTEXT}\n\n--- ENVIRONMENT ---\n${ENV}"
fi

# Check template version drift
TEMPLATE_VERSION="1.0.0"
if [ -f "$CWD/.template-version" ]; then
  PROJECT_VERSION=$(cat "$CWD/.template-version")
  if [ "$PROJECT_VERSION" != "$TEMPLATE_VERSION" ]; then
    CONTEXT="${CONTEXT}\n\n--- TEMPLATE UPDATE AVAILABLE ---\nThis project was created from template v${PROJECT_VERSION}. Current template is v${TEMPLATE_VERSION}. Run #template-check to review and apply updates."
  fi
fi

# ============================================================
# PHASE 2: Environment Verification (Verify, Don't Assume)
# Each check has a 3-second timeout to avoid blocking session start
# ============================================================

VERIFIED=""

# Helper: run a command with timeout, capture result
check_tool() {
  local label="$1"
  local cmd="$2"
  local result
  result=$(eval "timeout 3 $cmd" 2>&1) || result="NOT AVAILABLE"
  if echo "$result" | grep -qi "not found\|not available\|command not found\|error\|not recognized"; then
    VERIFIED="${VERIFIED}\n[FAIL] ${label}: not available"
  else
    # Trim to first line for cleanliness
    local first_line
    first_line=$(echo "$result" | head -1)
    VERIFIED="${VERIFIED}\n[OK] ${label}: ${first_line}"
  fi
}

# macOS doesn't have `timeout` — use perl fallback
if ! command -v timeout &>/dev/null; then
  timeout() {
    local duration="$1"
    shift
    perl -e 'alarm shift; exec @ARGV' "$duration" "$@"
  }
fi

# --- Tool checks ---
# Git
if command -v git &>/dev/null; then
  GIT_VER=$(git --version 2>&1 | head -1)
  VERIFIED="${VERIFIED}\n[OK] Git: ${GIT_VER}"
else
  VERIFIED="${VERIFIED}\n[FAIL] Git: not installed"
fi

# Python
if command -v python3 &>/dev/null; then
  PY_VER=$(python3 --version 2>&1 | head -1)
  VERIFIED="${VERIFIED}\n[OK] Python: ${PY_VER}"
else
  VERIFIED="${VERIFIED}\n[FAIL] Python3: not installed"
fi

# Node
if command -v node &>/dev/null; then
  NODE_VER=$(node --version 2>&1 | head -1)
  VERIFIED="${VERIFIED}\n[OK] Node.js: ${NODE_VER}"
else
  VERIFIED="${VERIFIED}\n[FAIL] Node.js: not installed"
fi

# Azure CLI
if command -v az &>/dev/null; then
  AZ_VER=$(timeout 5 az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "unknown")
  VERIFIED="${VERIFIED}\n[OK] Azure CLI: ${AZ_VER}"

  # Bicep (via az)
  BICEP_VER=$(timeout 5 az bicep version 2>&1 | head -1 || echo "")
  if [ -n "$BICEP_VER" ] && ! echo "$BICEP_VER" | grep -qi "error\|not found"; then
    VERIFIED="${VERIFIED}\n[OK] Bicep: ${BICEP_VER}"
  else
    VERIFIED="${VERIFIED}\n[FAIL] Bicep: not installed (run 'az bicep install')"
  fi

  # Azure login status. Every az call is wrapped in `timeout` (perl fallback above)
  # and guarded with `|| echo` so a slow ARM response or a not-logged-in state can
  # never hang or, under `set -e`, abort the hook and drop all context injection.
  AZ_ACCOUNT=$(timeout 5 az account show --query "{name:name, id:id, tenantId:tenantId}" -o tsv 2>&1 || echo "not logged in")
  if echo "$AZ_ACCOUNT" | grep -qi "please run\|error\|login\|not logged in"; then
    VERIFIED="${VERIFIED}\n[FAIL] Azure login: NOT logged in (run 'az login')"
  else
    AZ_NAME=$(timeout 5 az account show --query "name" -o tsv 2>/dev/null || echo "unknown")
    AZ_SUB=$(timeout 5 az account show --query "id" -o tsv 2>/dev/null || echo "unknown")
    VERIFIED="${VERIFIED}\n[OK] Azure subscription: ${AZ_NAME} (${AZ_SUB})"

    # Policy read access (quick check — count policies)
    POLICY_COUNT=$(timeout 5 az policy assignment list --query "length(@)" -o tsv 2>&1 || echo "denied")
    if echo "$POLICY_COUNT" | grep -qE "^[0-9]+$"; then
      VERIFIED="${VERIFIED}\n[OK] Policy read access: ${POLICY_COUNT} assignments readable"
    else
      VERIFIED="${VERIFIED}\n[WARN] Policy read access: denied or unavailable (Azure Policy checks will be limited)"
    fi
  fi
else
  VERIFIED="${VERIFIED}\n[FAIL] Azure CLI: not installed"
  VERIFIED="${VERIFIED}\n[FAIL] Bicep: requires Azure CLI"
  VERIFIED="${VERIFIED}\n[FAIL] Azure login: requires Azure CLI"
fi

# Docker
if command -v docker &>/dev/null; then
  DOCKER_VER=$(docker --version 2>&1 | head -1)
  VERIFIED="${VERIFIED}\n[OK] Docker: ${DOCKER_VER}"
else
  VERIFIED="${VERIFIED}\n[WARN] Docker: not installed (optional — needed for containerized apps)"
fi

# azd (Azure Developer CLI)
if command -v azd &>/dev/null; then
  AZD_VER=$(azd version 2>&1 | head -1)
  VERIFIED="${VERIFIED}\n[OK] Azure Developer CLI: ${AZD_VER}"
else
  VERIFIED="${VERIFIED}\n[WARN] azd: not installed (optional — install via 'curl -fsSL https://aka.ms/install-azd.sh | bash')"
fi

CONTEXT="${CONTEXT}\n\n--- VERIFIED ENVIRONMENT (checked at session start — do not assume, reference these) ---${VERIFIED}"

# Return context injection
if [ -n "$CONTEXT" ]; then
  python3 -c "
import json, sys
context = '''${CONTEXT}'''
result = {
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': context.strip()
    }
}
print(json.dumps(result))
"
else
  echo '{"continue": true}'
fi
