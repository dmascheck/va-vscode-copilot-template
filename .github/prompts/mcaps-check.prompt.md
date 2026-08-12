---
description: "Generate MCAPS pilot prompt for MS Copilot consultation"
---

Generate a MCAPS compliance check prompt for this project's planned Azure architecture:

1. Read .env.project for MCAPS tenant, resource group, region
2. Identify all Azure services currently in use or planned
3. For each service, note the network configuration (Private Endpoint, VNet, public)
4. Generate a structured prompt I can paste into MS Copilot (internal) that asks:
   - Are all services allowed in MCAPS?
   - What Private Endpoints are needed?
   - What policies could block deployment?
   - Any workarounds for restricted services?
5. After I paste back the MS Copilot response, store it in Obsidian 06 - Projects/{domain}/{project-name}/mcaps/
