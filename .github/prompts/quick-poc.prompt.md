---
description: "Fast POC/prototype without full discovery. For when you need a working demo by Thursday. Skips exhaustive questioning, builds fast with sensible defaults."
---

Build a quick POC/prototype. This is SPEED MODE — skip the exhaustive discovery.

1. Ask me ONLY these 3 questions:
   - What should this POC demonstrate? (one sentence)
   - Who is the audience? (customer meeting, internal demo, personal experiment)
   - Any specific Azure services required? (or let you pick)

2. Pick the fastest tech stack for the job:
   - If web app: FastAPI + React + Vite (or Next.js if frontend-heavy)
   - If API only: FastAPI or Express
   - If serverless: Azure Functions
   - If static: Azure Static Web Apps
   - Default to what builds fastest, not what's "best practice"

3. Skip:
   - HIPAA compliance (unless explicitly told it's healthcare)
   - Full architecture documentation
   - ADRs
   - Sprint planning
   - Exhaustive testing (basic smoke tests only)

4. Do:
   - Get something working and visible ASAP
   - Use sample/mock data
   - Deploy to Azure (basic SKUs, cheapest options)
   - Make it look presentable (not ugly)
   - README with "how to demo this" instructions

5. When done, offer: "Want me to promote this to a full project with #new-project discovery?"
