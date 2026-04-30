#!/bin/bash

# Local Development Setup Script

# Source centralized logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
log_init "deployment"
log_startup_diagnostics

log_info "Setting Up Local Development Environment..."

# Check prerequisites
log_info "Checking Prerequisites..."

# Check Python
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version)
    log_info "Python found: $PYTHON_VERSION"
else
    log_error "Python 3 not found. Please install Python 3.8+"
    exit 1
fi

# Check pip
if command -v pip3 &>/dev/null; then
    log_info "pip found"
else
    log_error "pip not found"
    exit 1
fi

# Check Azure CLI (optional)
if command -v az &>/dev/null; then
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
    log_info "Azure CLI found: $AZ_VERSION"
else
    log_warning "Azure CLI not found (optional)"
    log_info "Install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
fi

# Create virtual environment
log_info "Creating Virtual Environment..."

if [ ! -d "venv" ]; then
    log_cmd python3 -m venv venv
    log_info "Virtual environment created"
else
    log_info "Virtual environment already exists"
fi

# Activate virtual environment
log_info "Installing Dependencies..."

source venv/bin/activate

# Upgrade pip
log_cmd pip install --upgrade pip

# Install dependencies
if [ -f "requirements.txt" ]; then
    log_cmd pip install -r requirements.txt
    log_info "Dependencies installed"
else
    log_warning "requirements.txt not found"
fi

# Setup environment variables
log_info "Setting Up Environment Variables..."

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        log_info "Created .env from .env.example"
        log_warning "Please edit .env with your actual values"
    else
        log_warning ".env.example not found"
    fi
else
    log_info ".env already exists"
fi

# Initialize git hooks (if .githooks exists)
log_info "Setting Up Git Hooks..."

if [ -d ".githooks" ]; then
    git config core.hooksPath .githooks
    chmod +x .githooks/*
    log_info "Git hooks configured"
else
    log_warning ".githooks directory not found"
fi

# Create necessary directories
log_info "Creating Project Directories..."

mkdir -p src tests docs/diagrams docs/decisions infrastructure/bicep scripts Logs/logging/archive Logs/logging/summaries

log_info "Directories created"

# Run validation
log_info "Running Project Validation..."

if [ -f "scripts/validate-project.sh" ]; then
    chmod +x scripts/validate-project.sh
    log_cmd bash scripts/validate-project.sh
else
    log_warning "Validation script not found"
fi

log_info "=========================================="
log_info "Local Setup Complete!"
log_info "=========================================="
log_info "Next steps:"
log_info "1. Edit .env with your configuration"
log_info "2. Activate virtual environment: source venv/bin/activate"
log_info "3. Start coding!"
log_info ""
log_info "Useful commands:"
log_info "- Run tests: pytest tests/"
echo "- Run linter: flake8 src/"
echo "- Deploy: ./scripts/deploy.sh"
echo ""
