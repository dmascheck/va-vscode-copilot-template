---
description: "Lightweight mid-work context save — updates only TODO.md and NEXT_SESSION.md"
---

# Quick Save

Save current progress without a full sync:

1. Update `.github/context/TODO.md` with current task status
2. Update `.github/context/NEXT_SESSION.md` with where you are right now
3. `git add .github/context/ && git commit -m "chore: quick save"`
