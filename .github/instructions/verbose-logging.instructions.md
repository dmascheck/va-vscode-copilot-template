---
applyTo: "**"
description: "NON-NEGOTIABLE verbose logging mandate for ALL languages and ALL operations"
---

# Verbose Logging Standards (NON-NEGOTIABLE)

**Every piece of code, every script, every command, every endpoint, every call — gets verbose logging. No exceptions. No silent operations.**

## Language-Specific Frameworks

### Python
- **Use:** `from scripts.logging_config import setup_logging`
- **BLOCKED:** `print()`, `pprint()`, `subprocess.DEVNULL`, `logging.disable()`

### JavaScript / TypeScript
- **Use:** `import { logger } from '@/utils/logger'`
- **BLOCKED:** `console.log()`, `console.warn()`, `console.error()`

### Bash
- **Use:** `source scripts/lib/log.sh && log_init "category"`
- **BLOCKED:** bare `echo` (use `log_info`, `log_error`, `log_cmd`, etc.)

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

**NEVER** use `subprocess.DEVNULL`, `>/dev/null`, `2>/dev/null`, or `&>/dev/null`.

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
