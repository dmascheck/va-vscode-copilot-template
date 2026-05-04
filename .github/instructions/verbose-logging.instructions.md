---
applyTo: "**"
description: "VA best practice — structured verbose logging for all languages and operations"
---

# Verbose Logging Standards (VA Best Practice)

> **⚠️ VA Best Practice:** Structured logging with timestamps, severity levels, and correlation IDs is strongly recommended for all production VA code. It enables Azure Monitor integration, HIPAA audit trails, and incident diagnosis. Teams may enforce this strictly if needed.

For production code, prefer the project logging framework over `print()`/`console.log()`. For quick debugging or learning, `print()` is acceptable — just add a comment noting it should be replaced before production.

## Language-Specific Frameworks

### Python
- **Recommended:** `from scripts.logging_config import setup_logging`
- **Avoid in production:** `print()`, `pprint()`, `subprocess.DEVNULL`, `logging.disable()`

### JavaScript / TypeScript
- **Recommended:** `import { logger } from '@/utils/logger'`
- **Avoid in production:** `console.log()`, `console.warn()`, `console.error()`

### Bash
- **Recommended:** `source scripts/lib/log.sh && log_init "category"`
- **Avoid in production:** bare `echo` (use `log_info`, `log_error`, `log_cmd`, etc.)

## Mandatory Logging Points

### Every Function
```
ENTER function_name(param1=value, param2=value)
EXIT  function_name → result_summary (elapsed_ms)
FAIL  function_name raised ExceptionType: message (elapsed_ms)
```

### Every File Operation
```
FILE READ: /path/to/file (1234 bytes)
FILE WRITE: /path/to/file (5678 bytes)
```

### Every Subprocess / External Command
```
SUBPROCESS: git status → exit_code=0
STDOUT: (full output)
STDERR: (full output if any)
```

**Avoid** `subprocess.DEVNULL`, `>/dev/null`, `2>/dev/null`, or `&>/dev/null` in production — capture output for diagnostics.

### Every External API Call
```
HTTP GET https://api.example.us/v1/resource → 200 (45ms)
```

### Every Error
```
ERROR in function_name: ExceptionType — message
CONTEXT: {all relevant variables}
STACK: {full traceback}
```

## PHI/PII Logging Rule

- **NEVER** log PHI, PII, secrets, tokens, or passwords
- Mask sensitive fields: `patient_id=****1234`, `ssn=****`
- Log access events (who accessed what) but NOT the data itself
