---
description: "Azure Government and FedRAMP compliance rules — load when discussing Azure architecture, service selection, networking, deployment, or any Azure resource."
---

# Azure Government + FedRAMP Compliance Gate

**All VA Azure workloads run on Azure Government.** This file enforces tenant-level security policies and FedRAMP High requirements.

**When this matters:** Any time you're designing, coding, or deploying anything that touches Azure services.

## The Rule

Before recommending or implementing ANY Azure service pattern, check this file first. If the pattern is blocked, present the alternative. Do NOT suggest the blocked pattern as an option.

## Service Access Matrix

| Service | Public Access | Auth | Network Pattern | Alternative if Blocked |
|---------|-------------|------|-----------------|----------------------|
| **Storage** (Blob/Table/Queue) | ❌ Disabled | Managed Identity | Private Endpoint | Use storage proxy for local dev |
| **Cosmos DB** | ❌ Disabled | Managed Identity | Private Endpoint | Use Cosmos Emulator for local dev |
| **Key Vault** | ❌ Disabled | Managed Identity | Private Endpoint | — |
| **Azure SQL** | ❌ Disabled | Managed Identity | Private Endpoint | — |
| **AI Search** | ⚠️ Varies | Managed Identity | **Shared Private Link** (NOT regular PE) | — |
| **Azure OpenAI** | ⚠️ Varies | Managed Identity | Check per-resource | — |
| **App Service** (inbound) | ✅ Allowed | N/A | VNet Integration (outbound) | — |
| **Functions** (inbound) | ✅ Allowed | N/A | VNet Integration (outbound) | — |

## Blocked Patterns (NEVER suggest these)

| Pattern | Why Blocked | Correct Alternative |
|---------|-------------|-------------------|
| Connection strings for Storage/Cosmos/SQL | FedRAMP disables local auth | `DefaultAzureCredential` + resource name from env var |
| SAS tokens | Disabled at tenant level | Managed Identity + RBAC |
| Public blob access | FedRAMP requires private | Private Endpoint + backend proxy |
| Commercial Azure endpoints (`.com`) | VA uses Azure Government | Use `.us` / `.usgovcloudapi.net` endpoints |
| "Allow trusted Microsoft services" bypass for indexers | Unreliable in Gov tenants | Use Shared Private Link |

## Azure Government Endpoint Reference

```
Commercial                          → Government
management.azure.com                → management.usgovcloudapi.net
blob.core.windows.net               → blob.core.usgovcloudapi.net
table.core.windows.net              → table.core.usgovcloudapi.net
queue.core.windows.net              → queue.core.usgovcloudapi.net
vault.azure.net                     → vault.usgovcloudapi.net
database.windows.net                → database.usgovcloudapi.net
search.windows.net                  → search.windows.us
cognitiveservices.azure.com         → cognitiveservices.azure.us
login.microsoftonline.com           → login.microsoftonline.us
graph.microsoft.com                 → graph.microsoft.us
```

## Architecture Pattern (FedRAMP-Compliant)

```
Developer Machine:
├── Frontend (localhost:3000) ──→ Backend (Azure App Service, Gov Cloud)
└── Never direct to Storage/Cosmos/SQL

Azure Government:
├── App Service (VNet Integration outbound)
│   ├──PE──→ Storage Account
│   ├──PE──→ Cosmos DB
│   ├──PE──→ Key Vault
│   └──PE──→ Azure SQL
├── AI Search ──SPL──→ Storage (Shared Private Link)
└── All resources in usgovvirginia or usgovarizona
```

## Live Validation Commands

```bash
# Verify you're on Government cloud
az cloud show --query name -o tsv  # Must return "AzureUSGovernment"

# Check if a service allows public access
az storage account show --name <name> --query "publicNetworkAccess" -o tsv
az cosmosdb show --name <name> --resource-group <rg> --query "publicNetworkAccess" -o tsv
az keyvault show --name <name> --query "properties.publicNetworkAccess" -o tsv

# Check Private Endpoints
az network private-endpoint list --resource-group <rg> -o table
```

## When Discussing Architecture

For EVERY Azure service in the design:
1. Check this table → is the pattern allowed?
2. If ❌ → present the alternative, not the blocked pattern
3. If ⚠️ Varies → run the live validation command to confirm
4. Verify Government endpoints are used (`.us`, not `.com`)
5. Always present the FedRAMP-compliant architecture diagram above

**Never say "you could use a connection string" or "enable public access" — these are not options.**
