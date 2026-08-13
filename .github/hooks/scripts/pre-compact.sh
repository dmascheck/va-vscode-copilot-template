#!/bin/bash
# PreCompact Hook — Checkpoint to preserve context before compaction
# CRITICAL for marathon sessions (15-18 hours)

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

if [ -z "$CWD" ]; then
  echo '{"continue": true}'
  exit 0
fi

# Signal the AI to generate a checkpoint before compaction
echo '{
  "systemMessage": "[WARN] COMPACTION IMMINENT — Marathon session checkpoint needed. Before compaction summarizes earlier context: 1) Save a checkpoint summary to Logs/sessions/ (key decisions, work completed, current state, next steps). 2) Update PROJECT_CONTEXT.md with current state. 3) Update TODO.md with current task status. This ensures nothing is lost when earlier conversation history is compacted.",
  "continue": true
}'
