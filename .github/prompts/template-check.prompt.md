---
description: "Compare this project's config files against the latest template. Identifies drift and recommends updates without overwriting customizations."
---

Check this project against the latest template for updates:

1. Read this project's `.template-version` file (if it exists) to see what template version it was created from
2. Read the current template version from the plugin, or from your local checkout of the template repository
3. Compare these project-level files against the template:
   - `.vscode/mcp.json` — any new MCP servers added? Any config improvements?
   - `.vscode/settings.json` — any new settings?
   - `.vscode/extensions.json` — any new recommended extensions?
   - `.vscode/launch.json` — any new debug configurations?
   - `.vscode/tasks.json` — any new tasks?
   - `.github/workflows/test.yml` — any CI/CD improvements?
   - `.githooks/pre-commit` — any new security checks?
   - `.githooks/commit-msg` — any changes?
   - `.env.example` — any new environment variables?
   - `.gitignore` — any new patterns?
4. For each difference found:
   - Classify: is this an INTENTIONAL project customization or UNINTENTIONAL drift?
   - If the project has customized something (e.g., enabled an extra MCP server), preserve the customization
   - If the template has something new the project is missing, recommend adding it
5. Present a report:
   - New items available from template (recommend adding)
   - Project customizations (keep as-is)
   - Outdated items (recommend updating)
6. After user approval, apply the selected updates
7. Update `.template-version` to the current version
