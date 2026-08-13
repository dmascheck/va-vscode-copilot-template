---
name: project-discovery
description: "Exhaustive project discovery framework (Approach A). Asks tiered questions until 100% confidence, produces PROJECT_INTENT.md and phased build plan. Use when starting a new project or feature from scratch."
---

# Project Discovery Skill

## Approach A: Exhaustive Questioning
Do NOT proceed to planning until you have high confidence in ALL categories below.
After each tier of questions, summarize understanding and ask "what am I missing?"
If an answer spawns more questions, follow that rabbit hole before moving on.

## Discovery Tiers

### Tier 1: Core Intent
- What is this project? (one sentence)
- Who is it for? (end users, stakeholders)
- What problem does it solve?
- What domain? (healthcare/VA, comic retail, personal, infra, tools)
- Is this a demo/POC, pilot, or production system?
- What's the timeline?

### Tier 2: Features & Functionality
- What are the 3-5 core features?
- What does the user interface look like? (web app, API only, CLI, mobile)
- What data does it manage? (types, volume, sensitivity)
- What integrations are needed? (Azure services, APIs, third-party)
- Are there existing systems this connects to?

### Tier 3: Technical Architecture
- What Azure services are needed? (check availability in your Azure Government region)
- What's the authentication model? (Azure AD, API keys, public)
- What's the data storage strategy? (Cosmos DB, SQL, Table Storage, Blob)
- What's the deployment target? (App Service, Container Apps, Functions, Static Web Apps)
- What language/framework is best for this? (let AI recommend based on requirements)
- What's the expected scale? (users, requests, data volume)

### Tier 4: Compliance & Constraints
- HIPAA required? (VA healthcare projects)
- Azure Policy constraints? (check the tenant's deny assignments)
- FedRAMP requirements?
- Cost target? (monthly Azure spend budget)
- Security requirements? (data encryption, audit logging, PHI)

### Tier 5: Deliverables & Handoff
- Who needs to receive this? (internal team, customer, leadership)
- What deliverables beyond code? (architecture diagram, cost estimate, deployment guide, ADRs)
- Demo requirements? (sample data, specific scenarios to show)
- Is a handoff document needed?

## Post-Discovery
1. Present comprehensive summary: "Here's what I understand you want..."
2. User confirms or corrects
3. Update PROJECT_INTENT.md with everything learned
4. Hand off to @Planner for phased build plan
5. Hand off to @Architect for architecture validation + cost estimate
