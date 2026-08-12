#!/bin/bash
# PreToolUse Hook — Anti-loop protection + dangerous operation blocking

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
TOOL_INPUT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin).get('tool_input',{})))" 2>/dev/null || echo "{}")

# Block dangerous operations
case "$TOOL_NAME" in
  run_in_terminal)
    # Check for dangerous commands in the tool input
    DANGEROUS=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
cmd = data.get('command', '')
dangerous_patterns = [
    r'rm\s+-rf\s+/',
    r'rm\s+-rf\s+~',
    r'DROP\s+TABLE',
    r'DROP\s+DATABASE',
    r'DROP\s+SCHEMA',
    r'TRUNCATE\s+TABLE',
    r'DELETE\s+FROM\s+\w+\s*;',          # DELETE without WHERE
    r'DELETE\s+FROM\s+\w+\s*$',          # DELETE without WHERE (end of string)
    r'git\s+push\s+.*--force',
    r'git\s+reset\s+--hard',
    r'chmod\s+777',
    r'mkfs\.',
    r'dd\s+if=',
    r'az\s+group\s+delete',              # Azure resource group delete
    r'az\s+resource\s+delete',           # Azure resource delete
    r'az\s+\w+\s+delete.*--yes',         # Any az delete with --yes (no confirmation)
]
for pattern in dangerous_patterns:
    if re.search(pattern, cmd, re.IGNORECASE):
        print('DANGEROUS')
        sys.exit(0)
print('SAFE')
" 2>/dev/null || echo "SAFE")

    if [ "$DANGEROUS" = "DANGEROUS" ]; then
      echo '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "deny",
          "permissionDecisionReason": "[BLOCKED] BLOCKED: Dangerous command detected. This operation could cause irreversible damage. Review the command and confirm manually if you really want to proceed."
        }
      }'
      exit 0
    fi
    ;;
esac

# Default: allow
echo '{"continue": true}'
