---
name: 'Azure Baseline'
description: 'Azure infrastructure standards and policy compliance for all Azure deployments'
applyTo: '**/infrastructure/**'
---

# Azure Baseline

## Policy Pre-Flight (MANDATORY)
Before ANY Azure architecture decision or deployment:
1. Check .env.project for `AZURE_TENANT_ID`, `AZURE_GOV_REGION`, and `FEDRAMP_LEVEL`
2. Query the deny assignments that apply: `az policy assignment list --scope /subscriptions/<sub>`
3. Consult docs/POLICY_SERVICE_REQUIREMENTS.md if it exists
4. For a new service type, confirm it is approved in your Azure Government region before designing around it

## Policy Patterns
- No public blob access (publicNetworkAccess=Disabled)
- Private Endpoints required for: Storage, Cosmos DB, SQL, Key Vault, AI Services
- Shared Private Link for: AI Search indexers, App Service VNet integration
- NAT Gateway for egress
- All compute in VNet with vnetRouteAllEnabled

## Authentication
- DefaultAzureCredential ALWAYS
- Service Principal for local dev (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET)
- Managed Identity for production
- RBAC-only Key Vault (no access keys)

## Infrastructure as Code
- Bicep with modular structure (main.bicep + modules/)
- Check Microsoft Learn MCP for current Bicep syntax before writing templates
- Use Azure Verified Modules (AVM) where available
- Cost estimates must be produced alongside any architecture plan

## Deployment Gates
1. Code verified locally
2. CLI syntax verified from current docs
3. Pre-deploy checklist completed
4. Policy compliance verified
5. Cost estimate reviewed

## What Works From Localhost
- Azure OpenAI (direct endpoint)
- Azure Functions (local runtime)
- Application Insights (connection string)
- Key Vault (with Service Principal)

## What Policy Typically Blocks From Localhost
- Storage (Blob, Queue, Table, File) — needs Private Endpoint
- Cosmos DB — needs Private Endpoint
- SQL Server — needs Private Endpoint
- Use storage-proxy pattern for local dev if needed
