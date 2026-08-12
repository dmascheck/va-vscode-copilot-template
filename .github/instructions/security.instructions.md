---
applyTo: "**"
description: "VA security standards — FedRAMP High, HIPAA, NIST 800-53, VHA Directive 6066, OWASP, secret scanning"
---

# VA Security Standards

## FedRAMP High Baseline

All VA systems on Azure Government must meet FedRAMP High:
- **AC** — Access Control: Role-based access, least privilege, PIV/CAC enforcement
- **AU** — Audit: All data access logged, tamper-evident, retained per VA policy
- **SC** — System Communications: TLS 1.2+ everywhere, encryption at rest (AES-256)
- **IA** — Identification/Authentication: Multi-factor (PIV/CAC), no shared accounts

## Secret Scanning

NEVER commit secrets. Before every commit, verify:
- No API keys, passwords, connection strings, or tokens in source files
- No `.env` files (only `.env.example` is committed)
- No Azure client secrets or SAS tokens
- No private keys or certificates
- No VA-specific identifiers (ICN, DFN, SSN) in test data

## Authentication

- **ALWAYS** use `DefaultAzureCredential` — never connection strings or access keys
- **PIV/CAC** required for VA staff access to all systems
- Store third-party secrets in Azure Key Vault, retrieved at runtime
- Use Managed Identity in production — Service Principal for local dev only
- Azure Government endpoints only (`.us` domains)

## Input Validation (OWASP)

- Validate and sanitize ALL user input at API boundaries
- Use Pydantic models for request validation in FastAPI
- Never construct SQL or shell commands from unvalidated input
- Escape output for XSS prevention in frontend rendering

## HIPAA / VHA Directive 6066

When handling Protected Health Information (PHI):
- Encrypt data at rest (AES-256) and in transit (TLS 1.2+)
- Log access to PHI — who accessed what, when (audit trail)
- Minimize PHI exposure — only retrieve fields needed (minimum necessary)
- **NEVER** log PHI in application logs or error messages
- **NEVER** include PHI in URLs, query strings, or error responses
- Ensure Azure resources use private endpoints (no public access to PHI stores)
- Apply 38 CFR Part 1 privacy protections
- Document PHI data flows for ATO package

## VA 6500 Handbook

- All systems must comply with VA Handbook 6500 security controls
- Systems handling VA data must have valid ATO or inherited authorization
- Incident response procedures must be documented
- Security awareness training required for all team members

## NIST 800-53 Controls (High Baseline)

Key control families enforced:
- **AC** — Access Control (PIV/CAC, RBAC, least privilege)
- **AT** — Awareness and Training
- **AU** — Audit and Accountability (all actions logged)
- **CA** — Assessment, Authorization, Monitoring
- **CM** — Configuration Management
- **IA** — Identification and Authentication (MFA mandatory)
- **IR** — Incident Response
- **SC** — System and Communications Protection (encryption, network segmentation)
- **SI** — System and Information Integrity (vulnerability scanning)

## Dependency Security

- Run `pip-audit` (Python) or `npm audit` (Node.js) before deployment
- Pin dependency versions in `requirements.txt` and `package-lock.json`
- Review changelog before upgrading major versions
- No dependencies with known CVSS 9+ vulnerabilities in production

## Anti-Patterns

| Pattern | Risk | Fix |
|---------|------|-----|
| Hardcoded secrets | Credential leak | Use env vars + Key Vault |
| `eval()` or `exec()` on user input | Code injection | Never — use safe alternatives |
| SQL string concatenation | SQL injection | Use parameterized queries |
| PHI in logs | HIPAA violation | Mask with `****`, log access event only |
| Commercial Azure endpoints | Wrong cloud | Use `.us` Azure Government endpoints |
| Shared accounts | Non-compliant auth | Individual PIV/CAC accounts |
| `dangerouslySetInnerHTML` | XSS | Sanitize HTML or use safe rendering |
| Broad CORS (`*`) | CSRF | Specify allowed origins explicitly |
