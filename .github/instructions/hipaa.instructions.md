---
name: 'HIPAA Compliance'
description: 'HIPAA compliance rules for VA healthcare projects. Auto-applies when working on VA-related code.'
---

# HIPAA Compliance

## Apply when working on VA healthcare projects (va-*, VHA, VBA)

### Data Protection
- Encrypt all PHI at rest (Azure Storage encryption, Cosmos DB encryption)
- Encrypt all PHI in transit (HTTPS only, TLS 1.2+)
- Minimize PHI exposure — only access what's needed for the current operation
- Never log PHI in application logs, console output, or error messages
- Audit all PHI access with structured logging (who, what, when, why)

### Authentication & Authorization
- DefaultAzureCredential for all Azure service access
- Role-based access control (RBAC) on all resources
- Managed Identity in production — no secrets in code
- Session tokens with appropriate expiration
- Multi-factor authentication where applicable

### API & Data Handling
- Input validation on all endpoints handling health data
- Pydantic models or Zod schemas for all PHI data structures
- No PHI in URL parameters — use request body
- Response filtering — don't return more PHI than requested
- Data retention policies — auto-delete per VA requirements

### Infrastructure
- All resources in a policy-compliant Azure Government subscription
- Private Endpoints for all data stores
- VNet integration for all compute
- Azure Front Door with WAF for public endpoints
- Application Insights with PHI scrubbing

### Testing
- Test data must be synthetic — never use real patient data
- De-identified test datasets for integration testing
- Security testing includes PHI exposure checks
