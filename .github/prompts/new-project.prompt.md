---
description: "Start a new project with exhaustive discovery, architecture planning, and phased build plan"
---

I want to start a new project. Use the @scrum-master orchestration to:

1. Run exhaustive project discovery (Approach A) — ask me questions in tiers until you have 100% confidence you understand what I want. If my answers spawn more questions, keep going. Do not stop asking until you are fully confident.

2. After discovery, present a complete summary of your understanding and ask "what am I missing?"

3. Once I confirm, update PROJECT_INTENT.md with everything learned.

4. Update `.github/context/PROJECT_CONTEXT.md`:
   - Fill **What This Is** section with the full project description
   - Fill **Business Value** section with quantified value statements
   - Fill **Key Features** section with the core features identified
   - Update frontmatter: tech_stack, linked_opp, stakeholders (if answered)
   - Append a discovery summary to the **Notes** section

5. Use @Planner to produce a phased build plan with dependencies and parallel opportunities.

5. Use @Architect to validate the architecture, check Azure Policy compliance, produce an architecture diagram (Draw.io or Excalidraw), and generate an Azure cost estimate.

6. Present the complete plan with architecture diagram and cost estimate for my approval.

7. Only after I approve, begin Phase 1 implementation with checkpoints between each phase.
