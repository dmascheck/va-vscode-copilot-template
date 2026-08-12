---
name: azure-auth
description: "Azure authentication patterns using DefaultAzureCredential. Service Principal setup, Managed Identity migration, RBAC configuration. Use when setting up Azure authentication or troubleshooting auth issues."
---

# Azure Authentication Skill

## DefaultAzureCredential (Always Use This)
The credential chain tries these in order:
1. Environment variables (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET)
2. Managed Identity (in Azure)
3. Azure CLI (`az login`)
4. VS Code credential
5. Interactive browser login

## Local Development Setup (Service Principal)
```bash
# Create Service Principal
az ad sp create-for-rbac --name "sp-${PROJECT_NAME}-dev" \
  --role "Contributor" \
  --scopes "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP}"

# Add to .env.dev (gitignored!)
AZURE_CLIENT_ID=<appId>
AZURE_TENANT_ID=<tenant>
AZURE_CLIENT_SECRET=<password>
```

## Python Usage
```python
from azure.identity import DefaultAzureCredential
from azure.cosmos import CosmosClient

credential = DefaultAzureCredential()
client = CosmosClient(url=os.environ["COSMOS_ENDPOINT"], credential=credential)
```

## TypeScript Usage
```typescript
import { DefaultAzureCredential } from "@azure/identity";
import { CosmosClient } from "@azure/cosmos";

const credential = new DefaultAzureCredential();
const client = new CosmosClient({ endpoint: process.env.COSMOS_ENDPOINT!, aadCredentials: credential });
```

## RBAC Role Assignments
Common roles needed:
- **Storage Blob Data Contributor** — read/write blobs
- **Cosmos DB Account Reader** — read Cosmos data
- **Key Vault Secrets User** — read secrets
- **Cognitive Services OpenAI User** — call OpenAI endpoints

```bash
az role assignment create \
  --assignee "${AZURE_CLIENT_ID}" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/${STORAGE}"
```

## Production (Managed Identity)
- Enable system-assigned Managed Identity on App Service / Container App / Function App
- Assign RBAC roles to the Managed Identity
- Remove all Service Principal references from production config
- No secrets needed in production

## Auth Troubleshooting
1. "DefaultAzureCredential failed" → Check AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET in .env
2. "403 Forbidden" → Check RBAC role assignments, may need to wait 5-10 min for propagation
3. "MCAPS blocks" → Service may require Private Endpoint, check MCAPS instructions
