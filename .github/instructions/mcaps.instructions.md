---
name: 'MCAPS Compliance'
description: 'MCAPS managed tenant policies and service requirements for Microsoft-managed Azure environments'
applyTo: '**/infrastructure/**'
---

# MCAPS Compliance

## Tenant Context
- Managed by MCAPS (Microsoft Managed Cloud Access Protection Service)
- Tenant: ME-MngEnvMCAP660184
- Strict network policies — no public endpoints allowed

## Service Matrix
| Service | Access Pattern | Notes |
|---------|---------------|-------|
| Storage (Blob/Queue/Table/File) | Private Endpoint | publicNetworkAccess=Disabled |
| Cosmos DB | Private Endpoint | publicNetworkAccess=Disabled |
| SQL Server | Private Endpoint | publicNetworkAccess=Disabled |
| Key Vault | Private Endpoint + RBAC | No access keys |
| AI Services (OpenAI) | Direct endpoint | Works from localhost |
| AI Search | Shared Private Link | For indexers in private execution env |
| App Service | VNet Integration | vnetRouteAllEnabled |
| Functions | VNet Integration | EP1+ for VNet support |
| Container Apps | VNet Integration | Internal environment |
| Application Insights | Connection String | Works from localhost |
| Front Door | Premium + Private Link | For public-facing endpoints |

## Before Every Azure Architecture Decision
1. Check this matrix for the service you're planning to use
2. If uncertain about MCAPS compatibility, generate a pilot prompt via #mcaps-check
3. Copy the pilot prompt to MS Copilot (internal) for verification
4. Store the MS Copilot response in Obsidian 06 - Projects/{domain}/{project-name}/mcaps/ for future reference

## Storage Proxy Pattern (Local Dev)
When developing locally against MCAPS-protected storage:
- Use infrastructure/storage-proxy/server.js as a Node.js bridge
- Proxy authenticates via Managed Identity and forwards requests
- Frontend/backend connect to localhost proxy instead of Azure directly

## 1ES MCP Registry
- Microsoft employees should use MCP servers from the 1ES Registry
- Check chat.mcp.gallery.serviceUrl for registry endpoint
- Non-registry MCP servers may be blocked in registry-only mode
- WorkIQ is the approved path for Teams + M365 data access
