---
agent: agent
description: "New VA project wizard. Configures the template, discovers what you want to build, and starts building. Run this after setup.py."
---

# VA Project Wizard

**Purpose:** Configure your project environment, discover what you want to build, and start building — all in one conversation.

🚨 **Run this after cloning the template and running `python scripts/setup.py`. Type `#va-project` in Copilot Chat.**

---

## Phase 1: Welcome

Display:

```
╔══════════════════════════════════════════════════════════════╗
║              VA PROJECT WIZARD v2.0                          ║
║   Let's set up your project and start building               ║
╚══════════════════════════════════════════════════════════════╝

This wizard will:
  1. Configure your project environment
  2. Ask what you want to build
  3. Help you start building it

It's OK if you don't know the answers to every question.
Just press Enter to skip anything you're unsure about
— we'll use smart defaults.

Let's go!
```

---

## Phase 2: Project Identity

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

## Phase 3: Compliance Profile (Skippable)

**Say this first:** "These are compliance questions. It's completely OK if you don't know the answers — most people don't when starting a new project. Press Enter on any question to use the VA default."

**Questions (with defaults):**

1. **FedRAMP level** — What FedRAMP authorization level? (Default: **High** — most VA systems require this)
2. **FISMA impact level** — What is the FISMA categorization? (Default: **High** — typically matches FedRAMP)
3. **PHI/PII handling** — Does this system handle Protected Health Information or Personally Identifiable Information? (Default: **No**)
   - _If Yes: VHA Directive 6066, HIPAA, and 38 CFR Part 1 rules will be activated._
4. **ATO status** — Does this project need an Authority to Operate? (Default: **Not sure** — we'll include guidance either way)

After answers, summarize:

```
🛡️ COMPLIANCE PROFILE:
  FedRAMP:  {level}
  FISMA:    {level}
  PHI/PII:  {yes/no}
  ATO:      {status}

Active rules:
  ✅ FedRAMP {level} controls
  ✅ NIST 800-53 {baseline} baseline
  ✅ VA 6500 Handbook (always)
  {✅ VHA Directive 6066 + HIPAA — if PHI}

Correct? (yes / adjust / skip — use defaults)
```

---

## Phase 4: Technical Profile (Skippable)

**Say this first:** "Technical questions — again, defaults are fine if you're not sure."

**Questions (with defaults):**

1. **Azure Government region** — Which region? (Default: **usgovvirginia**)
2. **Authentication** — How do users authenticate? (Default: **Managed Identity** for services, **PIV/CAC** for staff)
3. **VistA integration** — Does this connect to VistA or CPRS? (Default: **No**)
4. **Backend** — What language/framework? (Default: **Python + FastAPI**)
5. **Frontend** — Does this have a web UI? (Default: **No — API only**)
6. **Database** — What data storage? (Default: **None yet — we'll decide later**)
7. **AI services** — Will this use Azure OpenAI? (Default: **No**)

After answers:

```
🔧 TECHNICAL PROFILE:
  Azure Region:   {region}
  Auth:           {method}
  VistA:          {status}
  Backend:        {stack}
  Frontend:       {stack or "API only"}
  Database:       {choice}
  AI Services:    {status}

Correct? (yes / adjust / skip — use defaults)
```

---

## Phase 5: Team & Workflow (Skippable)

**Questions (with defaults):**

1. **Team size** — Solo or team? (Default: **solo**)
2. **Git hosting** — Where is code hosted? (Default: **GitHub**)
3. **CI/CD** — What pipeline? (Default: **None yet**)

```
👥 TEAM:
  Size:    {answer}
  Git:     {answer}
  CI/CD:   {answer}

Correct? (yes / adjust / skip — use defaults)
```

---

## Phase 6: Configure Files

After all phases confirmed, generate:

1. **Write `.env.project`** — fill in all values from answers (or defaults)
2. **Update `PROJECT_INTENT.md`** — replace all `${PLACEHOLDER}` values
3. **Update `.github/context/PROJECT_CONTEXT.md`** — populate with project name, type, tech stack
4. **Update `.github/context/TODO.md`** — initialize with first tasks
5. **Update `.github/context/NEXT_SESSION.md`** — set to "Project initialized — ready for development"

Present:

```
✅ Project configured! Files updated:
  • .env.project
  • PROJECT_INTENT.md
  • .github/context/PROJECT_CONTEXT.md
  • .github/context/TODO.md
  • .github/context/NEXT_SESSION.md
```

---

## Phase 7: Discovery — "What Do You Want to Build?"

**This is the core of the wizard.** Transition with:

```
╔══════════════════════════════════════════════════════════════╗
║         Now let's talk about what you want to build          ║
╚══════════════════════════════════════════════════════════════╝

Tell me what you want to build. Be as specific or as vague
as you want — I'll ask follow-up questions until I have a
clear picture. There are no wrong answers.
```

Wait for the user's response. Then ask exhaustive follow-up questions based on what they said. Keep asking until you have 100% confidence and zero assumptions.

**Discovery question categories** (adapt based on what they're building):

### What problem does it solve?

- Who has this problem today?
- How do they solve it currently (without your app)?
- What's painful about the current approach?

### Who uses it?

- Primary users (role, technical level)
- Secondary users (admins, managers, auditors)
- How many users approximately?

### What are the main features?

- What must the MVP include?
- What's nice to have but can wait?
- What should it definitely NOT do?

### What data does it work with?

- What data does it read?
- What data does it write/create?
- Where does the data come from?
- Does any of it involve PHI/PII?

### What does the user see/interact with?

- Is there a UI? What does it look like?
- Is it an API other systems call?
- Is it a CLI tool? A background service?
- Is it a chatbot/agent?

### What does it connect to?

- External APIs or services?
- Databases?
- Azure services?
- VistA/CPRS?
- Other VA systems?

### How does it handle errors and edge cases?

- What happens when the external service is down?
- What happens with bad/missing data?
- How should it handle unauthorized access?

**After each round of answers:**

```
📋 Here's what I understand so far:
  [summarize everything]

What am I missing? Anything wrong?
```

**Keep going until the user confirms: "That's everything" or "Looks good."**

---

## Phase 8: Plan

Present a phased build plan:

```
📋 BUILD PLAN:

Phase 1: Foundation
  • [list specific tasks]
  • Estimated: [simple/medium/complex]

Phase 2: Core Features
  • [list specific tasks]

Phase 3: Polish & Deploy
  • [list specific tasks]

Ready to start building? I can:
  A) Create the project skeleton (folders, files, basic structure)
  B) Jump straight into Phase 1 and start coding
  C) Save this plan and come back later

What would you prefer?
```

---

## Phase 9: Build

Based on their choice:

**A) Skeleton:** Create the folder structure, initial files, package configs, and basic scaffolding. Then ask "Ready to start building features?"

**B) Start coding:** Begin implementing Phase 1 tasks. Write real, production-ready code. Follow the instruction files and agent rules.

**C) Save and stop:** Write the plan to `.github/context/TODO.md` and `Logs/plans/`. Set `NEXT_SESSION.md` to resume from the plan. Say:

```
✅ Plan saved! When you're ready:
  1. Type #start-session to resume
  2. I'll pick up right where we left off
```

---

## Rules

- **Never assume.** If you're not sure, ask.
- **Summarize after every phase.** Confirm understanding before moving on.
- **Use defaults when skipped.** Don't leave blanks — fill with sensible VA defaults.
- **Be encouraging.** This wizard serves beginners AND experts. Never make the user feel dumb for not knowing something.
- **Follow instruction files.** All code generated must follow the 14 instruction files in this template.
- **Commit after configuration.** After Phase 6, suggest: `git add -A && git commit -m "feat: initialize VA project from template"`
