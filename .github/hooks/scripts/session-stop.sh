#!/bin/bash
# Stop Hook — Auto-saves chat session when session ends
# Copies JSONL chat data from VS Code's internal storage to project Logs/

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

# Determine Logs directory — support both project layout and Templates repo
LOGS_DIR=""
if [ -n "$CWD" ]; then
  if [ -d "$CWD/Logs/chat" ] || [ -d "$CWD/.github/context" ]; then
    # Standard project layout
    LOGS_DIR="$CWD/Logs"
  elif [ -d "$CWD/logs/template-sessions" ]; then
    # Templates repo layout
    LOGS_DIR="$CWD/logs/template-sessions"
  fi
fi

# Silently exit if no recognized workspace
if [ -z "$LOGS_DIR" ]; then
  echo '{"continue": true}'
  exit 0
fi

# Create Logs directories
mkdir -p "$LOGS_DIR/chat" "$LOGS_DIR/sessions" "$LOGS_DIR/decisions" "$LOGS_DIR/issues" "$LOGS_DIR/lessons"
[ -d "$CWD/.github/context" ] && mkdir -p "$LOGS_DIR/mcaps"

# Find and copy chat session JSONL from VS Code's internal storage
# VS Code stores chat at: ~/Library/Application Support/Code/User/workspaceStorage/{id}/chatSessions/*.jsonl
VSCODE_STORAGE="$HOME/Library/Application Support/Code/User/workspaceStorage"
DATE=$(date +%Y-%m-%d)
DATE_TIME=$(date +%Y-%m-%d-%H%M%S)

if [ -d "$VSCODE_STORAGE" ]; then
  # Find the most recently modified chat session JSONL across all workspace storages
  # Use -mtime -1 (last 24 hours) instead of -mmin -60 to handle long sessions
  # NUL-delimit so the spaces in "Application Support" do not split the path.
  LATEST_CHAT=$(find "$VSCODE_STORAGE" -path "*/chatSessions/*.jsonl" -mtime -1 -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)

  if [ -n "$LATEST_CHAT" ] && [ -f "$LATEST_CHAT" ]; then
    DEST="$LOGS_DIR/chat/${DATE_TIME}-session.jsonl"
    # Only copy if an identical copy is not already saved (compare one file at a
    # time; a bare glob could hand diff zero or many args and always report a diff).
    ALREADY_SAVED=false
    for existing in "$LOGS_DIR/chat/"*session*.jsonl; do
      [ -f "$existing" ] || continue
      if cmp -s "$LATEST_CHAT" "$existing"; then ALREADY_SAVED=true; break; fi
    done
    if [ "$ALREADY_SAVED" = false ]; then
      cp "$LATEST_CHAT" "$DEST" 2>/dev/null
    fi
  fi
fi

# Update NEXT_SESSION.md with timestamp (project layout only)
if [ -d "$CWD/.github/context" ]; then
  DATE_HUMAN=$(date "+%Y-%m-%d %H:%M")
  echo -e "\n<!-- Session ended: ${DATE_HUMAN} -->" >> "$CWD/.github/context/NEXT_SESSION.md" 2>/dev/null || true
fi

echo '{"continue": true}'
