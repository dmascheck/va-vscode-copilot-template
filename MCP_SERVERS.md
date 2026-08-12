# Recommended MCP Servers

[Model Context Protocol (MCP) servers](https://code.visualstudio.com/docs/copilot/chat/mcp-servers) extend GitHub Copilot's capabilities by connecting it to external tools and services. These are **optional** — your template works without them.

## How MCP Servers Work

MCP servers run as background processes that Copilot can call to perform actions — querying Azure resources, searching docs, creating diagrams, etc. They're configured in your VS Code settings.

## Quick Setup

To add an MCP server, open VS Code Settings (JSON) and add entries under `"mcp.servers"`. Each server has different installation requirements listed below.

---

## Azure

**What it does:** Manages Azure resources, deployments, monitoring, pricing, RBAC — over 50 tools covering the full Azure service catalog.

**Why you'd want it:** Deploy and manage Azure Government resources directly from Copilot chat. Ask "what resources are in my subscription?" or "deploy this Bicep template."

**Setup:** Provided by the [Azure GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-github-copilot) — install the extension and the MCP server is available automatically.

---

## Bicep

**What it does:** Validates Bicep IaC templates, provides resource type schemas, lists Azure Verified Modules, and catches errors before deployment.

**Why you'd want it:** Write correct Bicep templates the first time. Get real-time schema validation and AVM module suggestions.

**Setup:** Provided by the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) — install the extension and the MCP tools are available.

---

## GitHub

**What it does:** Manages repos, pull requests, issues, branches, code search, and can trigger Copilot reviews on PRs.

**Why you'd want it:** Create PRs, search code across repos, manage issues, and run code reviews without leaving VS Code.

**Setup:** Provided by the [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) — available automatically when signed in to GitHub.

---

## Context7

**What it does:** Fetches up-to-date documentation for libraries and frameworks (React, FastAPI, Django, Tailwind, etc.) directly from their official sources.

**Why you'd want it:** Copilot's training data can be months old. Context7 gives it current docs so suggestions use the latest API syntax, not deprecated patterns.

**Setup:**

```json
"mcp.servers": {
  "context7": {
    "command": "npx",
    "args": ["-y", "@context7/mcp"]
  }
}
```

**Requires:** Node.js 18+

---

## Sequential Thinking

**What it does:** Provides structured, step-by-step reasoning for complex problems. Breaks down multi-part tasks into logical phases.

**Why you'd want it:** When Copilot needs to think through a complex architecture decision, migration plan, or debugging session, this server forces structured analysis instead of jumping to conclusions.

**Setup:**

```json
"mcp.servers": {
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-sequential-thinking"]
  }
}
```

**Requires:** Node.js 18+

---

## Microsoft Learn

**What it does:** Searches and fetches official Microsoft Learn documentation and code samples. Returns authoritative, up-to-date content from Microsoft's docs.

**Why you'd want it:** When working with Azure services, .NET, or any Microsoft technology, this gives Copilot access to the official docs instead of relying on training data that may be outdated.

**Setup:** Provided by the [Azure GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-github-copilot) — available automatically.

---

## Draw.io

**What it does:** Creates architecture diagrams in Draw.io format from natural language descriptions.

**Why you'd want it:** Generate visual architecture diagrams by describing your system. Useful for documentation, ATO packages, and design reviews.

**Setup:**

```json
"mcp.servers": {
  "drawio": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-drawio"]
  }
}
```

**Requires:** Node.js 18+

---

## Playwright

**What it does:** Browser automation — navigate pages, fill forms, click elements, take screenshots, and run end-to-end tests.

**Why you'd want it:** Test your frontend with real browser interactions controlled from Copilot chat. "Take a screenshot of the login page" or "fill out and submit the patient form."

**Setup:**

```json
"mcp.servers": {
  "playwright": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-playwright"]
  }
}
```

**Requires:** Node.js 18+, Playwright browsers (`npx playwright install`)

---

## Filesystem

**What it does:** Read, write, search, and organize files and directories across your project.

**Why you'd want it:** Gives Copilot more reliable file access for large-scale refactoring, file organization, and cross-file operations.

**Setup:**

```json
"mcp.servers": {
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-filesystem", "/path/to/your/project"]
  }
}
```

**Requires:** Node.js 18+. Replace `/path/to/your/project` with your actual project directory.

---

## Verifying MCP Servers

After configuring, you can check which MCP servers are active:

1. Open Copilot Chat
2. Click the tools icon (wrench) in the chat input
3. You should see the configured servers and their available tools

If a server isn't showing up, check:

- The command is installed (e.g., `npx` requires Node.js)
- Your VS Code settings JSON is valid
- The server process can start (check the Output panel > MCP Servers)
