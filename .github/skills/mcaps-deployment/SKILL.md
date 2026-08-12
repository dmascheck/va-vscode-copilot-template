---
name: mcaps-deployment
description: "MCAPS compliance checklist and pilot prompt generation for Azure deployments in Microsoft-managed tenants. Use when deploying to Azure, planning Azure architecture, or encountering MCAPS-related access issues."
---

# MCAPS Deployment Skill

## Pre-Deployment MCAPS Checklist
For each Azure service in the deployment, verify:

- [ ] Service is in the MCAPS service matrix (check mcaps.instructions.md)
- [ ] Private Endpoint configured where required
- [ ] publicNetworkAccess = Disabled where required
- [ ] VNet integration enabled for compute services
- [ ] RBAC-only access (no access keys) for Key Vault
- [ ] Managed Identity configured for production auth
- [ ] No public blob storage access
- [ ] NAT Gateway for egress if needed
- [ ] Front Door Premium with Private Link for public endpoints

## MCAPS Pilot Prompt Generator
When uncertain about MCAPS compatibility, generate this structured prompt for MS Copilot:

```
I am a Microsoft CSA deploying in MCAPS tenant ME-MngEnvMCAP660184.

Project: [PROJECT_NAME]
Resource Group: [RG_NAME]
Region: [REGION]

Services I plan to deploy:
1. [Service 1] - [SKU] - [Network config: VNet/PE/Public]
2. [Service 2] - [SKU] - [Network config]
...

Questions:
1. Are all these services with the specified network configurations allowed in MCAPS?
2. Which services require Private Endpoints that I haven't configured?
3. Are there any MCAPS policies that could block this deployment?
4. What Shared Private Link configurations are needed for service-to-service communication?
5. Are there any known issues or workarounds for these services in MCAPS?
```

After user gets response from MS Copilot:
- Store the response in Obsidian `06 - Projects/{domain}/{project-name}/mcaps/YYYY-MM-DD-[service].md`
- Update .env.project MCAPS flags based on the response
- Update the deployment plan based on any constraints discovered

## 1ES MCP Registry Check
Before adding any new MCP server:
- Check if it's in the 1ES Registry
- If not in registry and org is in "registry only" mode, it will be blocked
- Approved Microsoft MCP servers: Azure MCP, GitHub MCP, Playwright, MarkItDown, WorkIQ
- Community servers (MCPVault, Taskmaster, Context7): verify not blocked on your environment

## What Works From Localhost (MCAPS)
- Azure OpenAI (direct endpoint)
- Azure Functions (local runtime)
- Application Insights (connection string)
- Key Vault (with Service Principal)

## What's Blocked From Localhost (MCAPS)
- Storage (Blob, Queue, Table, File) — needs Private Endpoint
- Cosmos DB — needs Private Endpoint
- SQL Server — needs Private Endpoint
- AI Search indexer — needs private execution environment
→ Use storage-proxy pattern for local development
