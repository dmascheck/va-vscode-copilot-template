# Project Intent: ${PROJECT_NAME}

## Overview
- **Name**: ${PROJECT_NAME}
- **Purpose**: _Configured by #va-setup wizard_
- **Domain**: _healthcare / benefits / logistics / administration / general_
- **Type**: _demo / pilot / production_
- **VA Office**: _OIT / OCTO / VHA / VBA / NCA / other_
- **VISN/Facility**: _VISN number or facility name if applicable_
- **Stakeholders**: _Who is this for?_
- **Created**: ${DATE}

## Vision
_What is the north star for this project? What problem does it solve for Veterans or VA staff?_

## Discovery Notes
_Run `@scrum-master` to conduct exhaustive discovery and populate this section._

## Key Requirements
_Filled during `#va-setup` wizard or `@scrum-master` discovery_

## Compliance Profile
- **FedRAMP Level**: ${FEDRAMP_LEVEL} _(High / Moderate / Low)_
- **FISMA Impact**: ${FISMA_IMPACT} _(High / Moderate / Low)_
- **Handles PHI/PII**: ${HANDLES_PHI} _(Yes / No)_
- **ATO Required**: ${ATO_REQUIRED} _(Yes / No / Inherited)_
- **VHA Directive 6066 Applies**: ${VHA_6066} _(Yes / No)_
- **NIST 800-53 Baseline**: ${NIST_BASELINE} _(High / Moderate / Low)_
- **VA 6500 Handbook**: Applies to all VA systems

## Technical Profile
- **Azure Region**: ${AZURE_GOV_REGION} _(usgovvirginia / usgovarizona)_
- **Authentication**: ${AUTH_METHOD} _(PIV/CAC / Azure AD / Managed Identity)_
- **VistA Integration**: ${VISTA_INTEGRATION} _(Yes / No / N/A)_
- **Tech Stack**: ${TECH_STACK} _(Python+FastAPI / Node.js / Both)_
- **Git Hosting**: ${GIT_HOST} _(GitHub / Azure DevOps / VA GitHub Enterprise)_

## Constraints
- Azure Government cloud (not commercial Azure)
- VA network restrictions apply
- ${ADDITIONAL_CONSTRAINTS}

## Team
- **Team Size**: ${TEAM_SIZE} _(Solo / Small team / Large team)_
- **CI/CD**: ${CICD_PLATFORM} _(GitHub Actions / Azure Pipelines / other)_
