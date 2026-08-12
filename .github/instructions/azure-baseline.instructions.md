---
name: 'Azure Baseline'
description: 'Azure infrastructure standards and MCAPS compliance for all Azure deployments'
applyTo: '**/infrastructure/**'
---

# Azure Baseline

## MCAPS Pre-Flight (MANDATORY)
Before ANY Azure architecture decision or deployment:
1. Check .env.project for MCAPS_TENANT flag
2. Check MCAPS_*_PUBLIC_ACCESS flags for each service
3. Consult docs/MCAPS_SERVICE_REQUIREMENTS.md if it exists
4. Run #mcaps-check if deploying a new service type

## MCAPS Patterns
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
4. MCAPS compliance verified
5. Cost estimate reviewed

## What Works From Localhost
- Azure OpenAI (direct endpoint)
- Azure Functions (local runtime)
- Application Insights (connection string)
- Key Vault (with Service Principal)

## What MCAPS Blocks From Localhost
- Storage (Blob, Queue, Table, File) — needs Private Endpoint
- Cosmos DB — needs Private Endpoint
- SQL Server — needs Private Endpoint
- Use storage-proxy pattern for local dev if needed
