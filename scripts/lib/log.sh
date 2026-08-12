#!/bin/bash
# =============================================================================
# Centralized Bash Logging Library
#
# Usage:
#   source scripts/lib/log.sh
#   log_init "deployment"    # Sets category → writes to Logs/logging/deployment.log
#   log_info "Starting deploy"
#   log_error "Something failed"
#   log_cmd "az group list"  # Runs command, captures + logs all output
# =============================================================================

# --- Configuration ---
LOG_DIR="Logs/logging"
LOG_CATEGORY="${LOG_CATEGORY:-script}"
LOG_FILE=""
LOG_LEVEL="${LOG_LEVEL:-DEBUG}"

# Colors
_RED='\033[0;31m'
_YELLOW='\033[1;33m'
_GREEN='\033[0;32m'
_BLUE='\033[0;34m'
_GRAY='\033[0;90m'
_NC='\033[0m'

# --- Initialize logging ---
log_init() {
    LOG_CATEGORY="${1:-script}"
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/${LOG_CATEGORY}.log"
    log_info "Logging initialized: category=$LOG_CATEGORY file=$LOG_FILE"
}

# --- Core log function ---
_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')
    local caller="${FUNCNAME[2]:-main}:${BASH_LINENO[1]:-0}"
    local formatted="$timestamp | $LOG_CATEGORY | $level | $caller | $message"

    # Always write to file
    if [ -n "$LOG_FILE" ]; then
        echo "$formatted" >> "$LOG_FILE"
    fi

    # Console output based on level
    case "$level" in
        DEBUG)    [ "$LOG_LEVEL" = "DEBUG" ] && echo -e "${_GRAY}$formatted${_NC}" >&2 ;;
        INFO)     echo -e "${_BLUE}$formatted${_NC}" >&2 ;;
        WARNING)  echo -e "${_YELLOW}$formatted${_NC}" >&2 ;;
        ERROR)    echo -e "${_RED}$formatted${_NC}" >&2 ;;
        CRITICAL) echo -e "${_RED}$formatted${_NC}" >&2 ;;
    esac
}

# --- Level-specific functions ---
log_debug()    { _log "DEBUG" "$@"; }
log_info()     { _log "INFO" "$@"; }
log_warning()  { _log "WARNING" "$@"; }
log_error()    { _log "ERROR" "$@"; }
log_critical() { _log "CRITICAL" "$@"; }

# --- Run a command and log everything ---
log_cmd() {
    local cmd_desc="$*"
    log_info "SUBPROCESS: $cmd_desc"

    local output
    local exit_code
    output=$("$@" 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log_info "SUBPROCESS EXIT: $exit_code"
        if [ -n "$output" ]; then
            log_debug "STDOUT:\n$output"
        fi
    else
        log_error "SUBPROCESS EXIT: $exit_code"
        if [ -n "$output" ]; then
            log_error "OUTPUT:\n$output"
        fi
    fi

    # Also write raw output to log file for full capture
    if [ -n "$LOG_FILE" ] && [ -n "$output" ]; then
        echo "$output" >> "$LOG_FILE"
    fi

    return $exit_code
}

# --- Check if a command succeeds (replaces &>/dev/null) ---
# Usage: if log_check az resource show --name foo; then ...
log_check() {
    local cmd_desc="$*"
    local output
    local exit_code
    output=$("$@" 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log_debug "CHECK OK: $cmd_desc"
    else
        log_debug "CHECK FAIL (exit $exit_code): $cmd_desc"
    fi

    if [ -n "$LOG_FILE" ] && [ -n "$output" ]; then
        echo "$output" >> "$LOG_FILE"
    fi

    return $exit_code
}

# --- Capture a command's output (replaces 2>/dev/null || echo "") ---
# Usage: RESULT=$(log_capture az resource show --query "foo" -o tsv)
log_capture() {
    local cmd_desc="$*"
    local output
    local exit_code
    output=$("$@" 2>&1)
    exit_code=$?

    if [ $exit_code -ne 0 ]; then
        log_debug "CAPTURE FAIL (exit $exit_code): $cmd_desc"
        if [ -n "$LOG_FILE" ]; then
            echo "CAPTURE FAIL: $cmd_desc → $output" >> "$LOG_FILE"
        fi
    fi

    echo "$output"
    return $exit_code
}

# --- Log a file operation ---
log_file_op() {
    local operation="$1"
    local filepath="$2"
    local size=0
    if [ -f "$filepath" ]; then
        size=$(wc -c < "$filepath" | tr -d ' ')
    fi
    log_info "FILE $operation: $filepath ($size bytes)"
}

# --- Startup diagnostics ---
log_startup_diagnostics() {
    log_info "=== STARTUP DIAGNOSTICS ==="
    log_info "Bash: $BASH_VERSION"
    log_info "OS: $(uname -s) $(uname -r)"
    log_info "Machine: $(uname -m)"
    log_info "CWD: $(pwd)"
    log_info "PID: $$"
    log_info "User: $(whoami)"

    # Key tools
    for tool in python3 node az azd git docker; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_info "TOOL $tool: $(command -v "$tool")"
        else
            log_warning "TOOL $tool: NOT FOUND"
        fi
    done

    log_info "=== END STARTUP DIAGNOSTICS ==="
}
