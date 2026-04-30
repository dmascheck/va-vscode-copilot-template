---
agent: agent
description: "Save chat transcript — exports to Logs/chat/ and writes session summary to Logs/sessions/"
---

# Save Chat

**Purpose:** Save the current chat session for future reference.

## Steps

1. Generate a session summary from the conversation
2. Write to `Logs/sessions/YYYY-MM-DD-session-N.md`
3. If raw log available, run `python3 scripts/chat_digest.py` to create digest
4. Git commit the new files
