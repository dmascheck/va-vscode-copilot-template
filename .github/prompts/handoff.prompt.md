---
description: "Generate complete project handoff document — the 'project bible' that lets someone else pick up and run with this project"
---

Generate a comprehensive handoff document for this project. This is the "project bible" — everything someone needs to understand, run, deploy, and maintain this project:

1. **Project Overview** — Purpose, users, stakeholders, business value
2. **Architecture** — System diagram + description of every component and how they connect
3. **Technology Stack** — Languages, frameworks, Azure services, and why each was chosen
4. **Azure Resources** — Resource names, SKUs, resource group, costs
5. **Policy Considerations** — What's restricted, workarounds, private endpoints
6. **Architecture Decision Records** — Every significant decision and why (pull from `Logs/decisions/`)
7. **Deployment Guide** — How to deploy from scratch, step by step
8. **Development Guide** — How to set up a local dev environment
9. **API Reference** — All endpoints with request/response examples
10. **Testing Strategy** — What's tested, how to run tests, coverage
11. **Monitoring & Observability** — App Insights config, log locations, alerts
12. **Known Issues** — Current bugs, workarounds (pull from `Logs/issues/`)
13. **Cost Breakdown** — Monthly Azure costs by service
14. **Future Roadmap** — Planned but not yet built features

Save to docs/HANDOFF.md
