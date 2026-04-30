---
description: "Run security scan: secret detection, dependency audit, OWASP pattern check, VA compliance"
---

# Security Scan

**Purpose:** Comprehensive security audit.

## Steps

1. **Secret scan:** `grep -rn "password\|secret\|api_key\|token\|connection_string" --include="*.py" --include="*.ts" --include="*.env" . | grep -v ".env.example" | grep -v node_modules`
2. **Dependency audit:** `pip-audit` (Python) / `npm audit` (Node.js)
3. **OWASP check:** Look for SQL injection, XSS, CSRF patterns
4. **Azure Government check:** Verify no commercial endpoints (`.com` instead of `.us`)
5. **PHI check:** Verify no PHI in logs, URLs, or error messages
6. **VA compliance:** Verify FedRAMP controls in place

## Report

Present all findings with severity: 🔴 Critical | 🟡 Warning | 🟢 Info
