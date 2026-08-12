---
applyTo: "**/*.py"
description: "Azure SDK patterns for Python — DefaultAzureCredential, retry policies, client initialization"
---

# Azure SDK Patterns (Python)

## Client Initialization

```python
from azure.identity import DefaultAzureCredential

# ALWAYS use DefaultAzureCredential — handles MI, SP, CLI auth
credential = DefaultAzureCredential()

# Resource names from environment — NEVER hardcoded
import os
storage_name = os.environ["STORAGE_ACCOUNT_NAME"]
```

## Azure Government Endpoints

When creating SDK clients for Azure Government, specify the correct authority and endpoints:

```python
from azure.identity import DefaultAzureCredential, AzureAuthorityHosts

# For Azure Government
credential = DefaultAzureCredential(authority=AzureAuthorityHosts.AZURE_GOVERNMENT)
```

## Retry Policy

```python
from azure.core.pipeline.policies import RetryPolicy

# Configure retries for transient failures
retry_policy = RetryPolicy(
    retry_total=3,
    retry_backoff_factor=0.5,
    retry_mode="exponential"
)
```

## Anti-Patterns

- ❌ `StorageAccountKey` or connection strings → use `DefaultAzureCredential`
- ❌ Hardcoded endpoint URLs → use env vars
- ❌ Creating new client per request → use singleton pattern
- ❌ Commercial Azure endpoints → use Azure Government endpoints
- ❌ Ignoring 429 responses → implement retry-after logic
