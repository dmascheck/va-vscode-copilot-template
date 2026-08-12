#!/bin/bash
# UserPromptSubmit Hook — Decision gate for high-stakes requests

set -e

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null || echo "")

# Check for architecture/deployment/high-stakes keywords
DECISION_GATE=$(echo "$PROMPT" | python3 -c "
import sys, re

prompt = sys.stdin.read().lower()
high_stakes_patterns = [
    r'deploy',
    r'delete.*resource',
    r'remove.*resource',
    r'change.*architecture',
    r'migrate.*database',
    r'switch.*to',
    r'replace.*with',
    r'production',
    r'go.?live',
    r'ship.*it',
]
for pattern in high_stakes_patterns:
    if re.search(pattern, prompt):
        print('HIGH_STAKES')
        sys.exit(0)
print('NORMAL')
" 2>/dev/null || echo "NORMAL")

if [ "$DECISION_GATE" = "HIGH_STAKES" ]; then
  echo '{
    "systemMessage": "ARCHITECT-FIRST: This appears to be a high-stakes request. Before proceeding: 1) State assumptions. 2) Name 2-3 alternatives with tradeoffs. 3) Identify risks. 4) Get explicit user approval before executing any irreversible actions.",
    "continue": true
  }'
else
  echo '{"continue": true}'
fi
