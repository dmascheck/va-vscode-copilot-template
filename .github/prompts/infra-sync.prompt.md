---
agent: agent
description: Query Azure Government to discover deployed resources and sync to .env.project.
---

# Infra Sync

**Purpose:** Query Azure Government to discover deployed resources and sync to `.env.project`.

## Pre-Flight

```bash
# Verify Government cloud
az cloud show --query name -o tsv  # Must return AzureUSGovernment
az account show --query "{sub:name,id:id}" -o table
```

## Discovery

```bash
source .env.project
RG="${AZURE_RESOURCE_GROUP}"

echo "=== Resources in $RG ==="
az resource list --resource-group "$RG" -o table 2>/dev/null

echo "=== Storage Accounts ==="
az storage account list --resource-group "$RG" --query "[].name" -o tsv

echo "=== App Services ==="
az webapp list --resource-group "$RG" --query "[].{name:name,state:state}" -o table

echo "=== Cosmos DB ==="
az cosmosdb list --resource-group "$RG" --query "[].name" -o tsv

echo "=== Key Vault ==="
az keyvault list --resource-group "$RG" --query "[].name" -o tsv
```

## Update .env.project

Fill in discovered resource names. Set `INFRA_LAST_SYNC` to today's date.
