#!/bin/bash

# Project Health Check / Validation Script
# Verifies all required files exist and project is properly configured

# Source centralized logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
log_init "deployment"

log_info "Running Project Validation..."

ERRORS=0
WARNINGS=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        log_info "✓ $1 exists"
    else
        log_error "✗ $1 missing"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check if directory exists
check_dir() {
    if [ -d "$1" ]; then
        log_info "✓ $1/ exists"
    else
        log_warning "⚠ $1/ missing"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Function to format bytes to KB
format_kb() {
    log_info "$(($1 / 1024))KB"
}

log_info "Checking File Structure..."

# Check Copilot customization files
check_file ".github/copilot-instructions.md"

# Check instruction files (minimum expected)

log_info "Instructions:"
INSTRUCTION_COUNT=$(find .github/instructions -name "*.instructions.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$INSTRUCTION_COUNT" -ge 1 ]; then
    log_info "✓ $INSTRUCTION_COUNT instruction file(s) found"
else
    log_error "✗ No instruction files in .github/instructions/"
    ERRORS=$((ERRORS + 1))
fi

# Check agents
log_info "Agents:"
AGENT_COUNT=$(find .github/agents -name "*.agent.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGENT_COUNT" -ge 1 ]; then
    log_info "✓ $AGENT_COUNT agent(s) found"
else
    log_warning "⚠ No agents in .github/agents/"
    WARNINGS=$((WARNINGS + 1))
fi

# Check prompts
log_info "Prompts:"
PROMPT_COUNT=$(find .github/prompts -name "*.prompt.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PROMPT_COUNT" -ge 1 ]; then
    log_info "✓ $PROMPT_COUNT prompt(s) found"
else
    log_warning "⚠ No prompts in .github/prompts/"
    WARNINGS=$((WARNINGS + 1))
fi

# Check context files
check_file ".github/context/PROJECT_CONTEXT.md"
check_file ".github/context/COMMAND_LOG.md"
check_file ".github/context/TEST_PLAN.md"
check_file ".github/context/TODO.md"

# Check reference docs
check_file ".github/AGENTS.md"

# Check root files
check_file "README.md"
check_file ".gitignore"
check_file ".env.example"
check_file "requirements.txt"

# Check directories
check_dir "backend"
check_dir "infrastructure"
check_dir "scripts"
check_dir "docs/decisions"


log_info "Checking Context File Sizes..."


# Check PROJECT_CONTEXT.md size
if [ -f ".github/context/PROJECT_CONTEXT.md" ]; then
    CONTEXT_SIZE=$(wc -c < .github/context/PROJECT_CONTEXT.md | tr -d ' ')
    CONTEXT_SIZE_KB=$(format_kb $CONTEXT_SIZE)
    
    if [ $CONTEXT_SIZE -gt 102400 ]; then
        # 100KB+ = ERROR
        log_error "✗ PROJECT_CONTEXT.md is ${CONTEXT_SIZE_KB} (>100KB)"
        log_info "MUST archive now: ./scripts/archive-context.sh"
        ERRORS=$((ERRORS + 1))
    elif [ $CONTEXT_SIZE -gt 51200 ]; then
        # 50KB+ = WARNING
        log_warning "⚠ PROJECT_CONTEXT.md is ${CONTEXT_SIZE_KB} (>50KB)"
        log_info "Consider archiving: ./scripts/archive-context.sh"
        WARNINGS=$((WARNINGS + 1))
    else
        log_info "✓ PROJECT_CONTEXT.md is ${CONTEXT_SIZE_KB}"
    fi
fi

# Check COMMAND_LOG.md size
if [ -f ".github/context/COMMAND_LOG.md" ]; then
    LOG_SIZE=$(wc -c < .github/context/COMMAND_LOG.md | tr -d ' ')
    LOG_SIZE_KB=$(format_kb $LOG_SIZE)
    
    if [ $LOG_SIZE -gt 204800 ]; then
        # 200KB+ = ERROR
        log_error "✗ COMMAND_LOG.md is ${LOG_SIZE_KB} (>200KB)"
        log_info "MUST archive now: ./scripts/archive-context.sh"
        ERRORS=$((ERRORS + 1))
    elif [ $LOG_SIZE -gt 102400 ]; then
        # 100KB+ = WARNING
        log_warning "⚠ COMMAND_LOG.md is ${LOG_SIZE_KB} (>100KB)"
        log_info "Consider archiving: ./scripts/archive-context.sh"
        WARNINGS=$((WARNINGS + 1))
    else
        log_info "✓ COMMAND_LOG.md is ${LOG_SIZE_KB}"
    fi
fi


log_info "Checking Configuration..."


# Check if .env exists
if [ -f ".env" ]; then
    log_info "✓ .env file exists"
else
    log_warning "⚠ .env file missing (copy from .env.example)"
    WARNINGS=$((WARNINGS + 1))
fi

# Check if git is initialized
if [ -d ".git" ]; then
    log_info "✓ Git repository initialized"
else
    log_error "✗ Git repository not initialized"
    ERRORS=$((ERRORS + 1))
fi

# Check if dependencies are installed (Python example)
if [ -f "requirements.txt" ]; then
    if command -v pip &> /dev/null; then
        # Check if venv exists
        if [ -d "venv" ] || [ -d ".venv" ]; then
            log_info "✓ Virtual environment exists"
        else
            log_warning "⚠ No virtual environment found"
            log_info "Run: python -m venv venv"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
fi


log_info "Checking Security..."


# Check for common secret patterns in code
if command -v grep &> /dev/null; then
    SECRET_PATTERNS=("password\s*=\s*['\"]" "api_key\s*=\s*['\"]" "secret\s*=\s*['\"]" "token\s*=\s*['\"]")
    
    for pattern in "${SECRET_PATTERNS[@]}"; do
        if grep -r -E "$pattern" backend/ web/ src/ 2>/dev/null | grep -v ".pyc" | grep -q .; then
            log_error "✗ Potential hardcoded secret found (pattern: $pattern)"
            ERRORS=$((ERRORS + 1))
        fi
    done
    
    if [ $ERRORS -eq 0 ]; then
        log_info "✓ No obvious hardcoded secrets detected"
    fi
fi

# Check .gitignore includes .env
if [ -f ".gitignore" ]; then
    if grep -q "^\.env$" .gitignore; then
        log_info "✓ .env is in .gitignore"
    else
        log_error "✗ .env not in .gitignore"
        ERRORS=$((ERRORS + 1))
    fi
fi



log_info "Validation Summary"



if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log_info "✅ All checks passed!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    log_warning "⚠️ ${WARNINGS} warning(s) found"
    log_info "Project is functional but has some recommendations"
    exit 0
else
    log_error "❌ ${ERRORS} error(s) and ${WARNINGS} warning(s) found"
    log_info "Please fix errors before proceeding"
    exit 1
fi
