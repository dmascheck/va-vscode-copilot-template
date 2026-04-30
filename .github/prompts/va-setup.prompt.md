---
agent: agent
description: "Interactive VA project setup wizard. Asks targeted questions about compliance, tech stack, Azure Government, and team structure, then configures all template files."
---

# VA Project Setup Wizard

**Purpose:** Configure this template for your specific VA project. Asks questions in tiers, then generates all customized files.

🚨 **Run this FIRST after cloning the template. Type `#va-setup` in Copilot Chat.**

---

## Step 1: Welcome + Pre-Flight

Display:
```
╔══════════════════════════════════════════════════════════════╗
║           VA PROJECT SETUP WIZARD v1.0                       ║
║   Configure your VS Code + Copilot environment for VA        ║
╚══════════════════════════════════════════════════════════════╝

This wizard will ask you about:
  1. Your project (name, purpose, team)
  2. Compliance requirements (FedRAMP, FISMA, HIPAA)
  3. Technical stack (Azure Gov, VistA, auth)
  4. Team structure (solo/team, CI/CD, git hosting)

Then it will configure ALL template files for your project.
Estimated time: 5–10 minutes.
```

---

## Step 2: Project Identity (Tier 1)

Ask these questions. Wait for answers before proceeding.

**Questions:**
1. **Project name** — What is your project called? (used for file naming, resource naming)
2. **One-sentence description** — What does this project do?
3. **Domain** — Which area? (healthcare / benefits / logistics / administration / general)
4. **Project type** — Is this a demo, pilot, or production system?
5. **VA Office** — Which VA office owns this? (OIT / OCTO / VHA / VBA / NCA / other)
6. **VISN/Facility** — If applicable, which VISN or VA facility? (or "N/A")
7. **Stakeholders** — Who are the primary users? (Veterans, VA staff, clinicians, administrators)

After answers, summarize:
```
📋 PROJECT IDENTITY:
  Name:         {answer}
  Description:  {answer}
  Domain:       {answer}
  Type:         {answer}
  Office:       {answer}
  VISN:         {answer}
  Stakeholders: {answer}

Correct? (yes / adjust)
```

---

## Step 3: Compliance Profile (Tier 2)

**Questions:**
1. **FedRAMP level** — What FedRAMP authorization level? (High / Moderate / Low)
   - _Most VA systems require FedRAMP High. If unsure, choose High._
2. **FISMA impact level** — What is the FISMA categorization? (High / Moderate / Low)
   - _Typically matches FedRAMP level._
3. **PHI/PII handling** — Does this system handle Protected Health Information or Personally Identifiable Information? (Yes / No)
   - _If Yes: VHA Directive 6066, HIPAA, and 38 CFR Part 1 rules will be enforced._
4. **ATO status** — Does this project need an Authority to Operate? (Yes / No / Inherited from parent system)
5. **Existing compliance framework** — Are there existing policies, security controls, or SA&A documentation you need to align with? (describe or "standard VA")

After answers, summarize:
```
🛡️ COMPLIANCE PROFILE:
  FedRAMP:        {level}
  FISMA:          {level}
  PHI/PII:        {yes/no} → {VHA 6066 + HIPAA enforced / standard security}
  ATO:            {status}
  Framework:      {description}

This means the following rules will be ACTIVE:
  ✅ FedRAMP {level} controls
  ✅ NIST 800-53 {baseline} baseline
  ✅ VA 6500 Handbook (always)
  {✅ VHA Directive 6066 (PHI) — if applicable}
  {✅ HIPAA Safe Harbor — if applicable}
  ✅ Encryption at rest + in transit
  ✅ Audit logging for all data access

Correct? (yes / adjust)
```

---

## Step 4: Technical Profile (Tier 3)

**Questions:**
1. **Azure Government region** — Which region? (usgovvirginia / usgovarizona / both)
   - _Default: usgovvirginia_
2. **Authentication method** — How do users authenticate? (PIV/CAC / Azure AD / Managed Identity / combination)
   - _PIV/CAC is standard for VA staff. Managed Identity for service-to-service._
3. **VistA/CPRS integration** — Does this project need to connect to VistA or CPRS? (Yes / No / Future phase)
   - _If Yes: VistA gateway patterns and DFN/ICN handling will be included._
4. **Backend tech stack** — What language/framework? (Python + FastAPI / Node.js + Express / both)
   - _Default: Python + FastAPI_
5. **Frontend needed?** — Does this project have a web frontend? (Yes — React + TypeScript / Yes — other / No — API only)
6. **Database** — What data storage? (Cosmos DB / Azure SQL / Azure Table Storage / none yet)
7. **AI services** — Will this use Azure OpenAI or other AI services? (Yes / No / Future phase)

After answers, present:
```
🔧 TECHNICAL PROFILE:
  Azure Region:   {region}
  Auth:           {method}
  VistA:          {status}
  Backend:        {stack}
  Frontend:       {stack or "API only"}
  Database:       {choice}
  AI Services:    {status}

Correct? (yes / adjust)
```

---

## Step 5: Team & Workflow (Tier 4)

**Questions:**
1. **Team size** — Solo developer or team? (solo / 2-5 / 6+)
2. **Git hosting** — Where is code hosted? (GitHub / Azure DevOps / VA GitHub Enterprise)
3. **CI/CD** — What pipeline? (GitHub Actions / Azure Pipelines / none yet)
4. **Code review process** — How are changes reviewed? (PR reviews / pair programming / solo + self-review)
5. **Deployment target** — Where does this deploy? (Azure App Service / Azure Functions / AKS / VM / not decided)

```
👥 TEAM PROFILE:
  Size:         {answer}
  Git:          {answer}
  CI/CD:        {answer}
  Reviews:      {answer}
  Deploy to:    {answer}

Correct? (yes / adjust)
```

---

## Step 6: Generate Configuration

After all tiers confirmed, generate:

### 6a: Write .env.project

Create `.env.project` from `.env.example` with all answers filled in:

```bash
cp .env.example .env.project
```

Then replace all placeholder values with the collected answers.

### 6b: Update PROJECT_INTENT.md

Replace all `${PLACEHOLDER}` values in `PROJECT_INTENT.md` with the collected answers. Fill in the Vision and Key Requirements sections based on the description and stakeholder information.

### 6c: Update copilot-instructions.md

If team size > 1, adjust the working model description. If VistA integration = Yes, add VistA-specific verification steps.

### 6d: Configure Security Instructions

Based on compliance profile:
- FedRAMP High → enable all NIST 800-53 High controls
- PHI/PII = Yes → enable VHA Directive 6066 + HIPAA enforcement
- PIV/CAC → add CAC authentication patterns to security instructions

### 6e: Configure Infrastructure Agent

Based on technical profile:
- Set Azure Government region
- Configure database patterns (Cosmos / SQL / Table Storage)
- Set deployment target in infrastructure agent
- Add VistA gateway patterns if applicable

### 6f: Update Context Files

Initialize these context files with project-specific information:
- `.github/context/PROJECT_CONTEXT.md` — populated with project name, type, tech stack
- `.github/context/TODO.md` — initialized with first tasks
- `.github/context/NEXT_SESSION.md` — set to "Project initialized — ready for development"

---

## Step 7: Present Setup Report

```
╔══════════════════════════════════════════════════════════════╗
║                 VA PROJECT CONFIGURED                        ║
╚══════════════════════════════════════════════════════════════╝

📋 Project:     {name} — {description}
🏛️ VA Office:   {office} / {VISN}
🛡️ Compliance:  FedRAMP {level} · FISMA {level} · {PHI status}
🔧 Stack:       {backend} + {frontend} + {database}
☁️ Azure:       {region} · {auth method}
👥 Team:        {size} · {git host} · {CI/CD}

Files configured:
  ✅ .env.project
  ✅ PROJECT_INTENT.md
  ✅ .github/copilot-instructions.md
  ✅ .github/context/PROJECT_CONTEXT.md
  ✅ .github/context/TODO.md
  ✅ .github/context/NEXT_SESSION.md

Next steps:
  1. Review the generated files
  2. Run: git add -A && git commit -m "feat: initialize VA project from template"
  3. Type #start-session to begin your first work session
  4. Type @scrum-master to start project planning
```

Ask: "Ready to start building? Type `#start-session` to begin."
