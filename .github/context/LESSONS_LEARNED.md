# Lessons Learned

## VA-Specific

### VA-001: Azure Government Endpoints
**Pattern:** Using commercial Azure endpoints instead of Government
**Fix:** Always use `.us` / `.usgovcloudapi.net` domains. Set `az cloud set --name AzureUSGovernment`.
**Impact:** Authentication failures, data residency violations

### VA-002: PHI in Logs
**Pattern:** Logging PHI/PII in application logs or error messages
**Fix:** Mask all sensitive fields. Log access events (who, what, when) but never the data itself.
**Impact:** HIPAA violation, VHA Directive 6066 non-compliance

### VA-003: DefaultAzureCredential Authority
**Pattern:** DefaultAzureCredential defaults to commercial Azure authority
**Fix:** Use `DefaultAzureCredential(authority=AzureAuthorityHosts.AZURE_GOVERNMENT)`
**Impact:** Auth failures in Azure Government

## General

_Add lessons learned from your project here. Format:_

```
### ID-NNN: Title
**Pattern:** What went wrong
**Fix:** How to avoid it
**Impact:** Why it matters
```
