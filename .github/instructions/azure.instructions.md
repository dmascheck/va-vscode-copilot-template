---
applyTo: "**/infrastructure/**, **/bicep/**, **/scripts/deploy**, **/scripts/deploy*"
---

# Azure Infrastructure Standards

## Azure Government Only

All VA resources deploy to Azure Government:
- Region: `usgovvirginia` or `usgovarizona`
- Cloud: `AzureUSGovernment`
- Verify: `az cloud show --query name` must return `AzureUSGovernment`

## Bicep Standards

- Use modular Bicep (`main.bicep` + `modules/`)
- Always include resource tags (environment, project, owner, vaOffice, fedRampLevel)
- Use `@secure()` decorator for secrets
- Reference Key Vault for secrets — never inline

## Naming Convention

`va-{project}-{environment}-{resource-type}-{region}`

## Network

- Private Endpoints for all data services
- VNet Integration for App Service / Functions
- No public access to Storage, Cosmos, SQL, Key Vault

## Deployment

- Always use `az deployment group create` with `--mode Incremental`
- Never use `--mode Complete` without explicit user confirmation
- Tag all resources at deployment time
