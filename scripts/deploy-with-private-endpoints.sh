#!/bin/bash

################################################################################
# MCAPS-Compliant Deployment Script with Private Endpoints
#
# Purpose: Deploy Azure resources with VNet Integration and Private Endpoints
# Based on: Real VA Video Connect deployment experience
# Version: 2.3.1
# Date: 2025-11-19
#
# Usage:
#   ./deploy-with-private-endpoints.sh <resource-type> <resource-name>
#
# Examples:
#   ./deploy-with-private-endpoints.sh storage mystorageaccount
#   ./deploy-with-private-endpoints.sh cosmos mycosmosdb
#   ./deploy-with-private-endpoints.sh keyvault mykeyvault
################################################################################

set -e  # Exit on error

# Source centralized logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
log_init "deployment"
log_startup_diagnostics

################################################################################
# CONFIGURATION
################################################################################

# Read from environment or use defaults
PROJECT_NAME="${PROJECT_NAME:-my-project}"
RG="${RG:-rg-${PROJECT_NAME}-demo}"
LOCATION="${LOCATION:-eastus}"
VNET_NAME="${VNET_NAME:-vnet-${PROJECT_NAME}}"
WEBAPP_NAME="${WEBAPP_NAME:-${PROJECT_NAME}-backend}"

# VNet Configuration
VNET_ADDRESS_PREFIX="10.0.0.0/16"
WEBAPP_SUBNET_NAME="subnet-webapp"
WEBAPP_SUBNET_PREFIX="10.0.1.0/24"
PE_SUBNET_NAME="subnet-private-endpoints"
PE_SUBNET_PREFIX="10.0.2.0/24"

log_info "Configuration:"
echo "  Project: $PROJECT_NAME"
echo "  Resource Group: $RG"
echo "  Location: $LOCATION"
echo "  VNet: $VNET_NAME"
echo "  Web App: $WEBAPP_NAME"
echo ""

################################################################################
# STEP 1: CREATE VNET (IF NOT EXISTS)
################################################################################

create_vnet() {
    log_info "Step 1: Creating VNet..."
    
    # Check if VNet exists
    if log_check az network vnet show --name $VNET_NAME --resource-group $RG; then
        log_success "VNet already exists: $VNET_NAME"
    else
        log_info "Creating VNet: $VNET_NAME"
        az network vnet create \
            --name $VNET_NAME \
            --resource-group $RG \
            --location $LOCATION \
            --address-prefix $VNET_ADDRESS_PREFIX \
            --subnet-name $WEBAPP_SUBNET_NAME \
            --subnet-prefix $WEBAPP_SUBNET_PREFIX \
            --output none
        
        log_success "VNet created: $VNET_NAME"
    fi
}

################################################################################
# STEP 2: CREATE PRIVATE ENDPOINT SUBNET
################################################################################

create_pe_subnet() {
    log_info "Step 2: Creating Private Endpoint subnet..."
    
    # Check if subnet exists
    if az network vnet subnet show \
        --vnet-name $VNET_NAME \
        --name $PE_SUBNET_NAME \
        --resource-group $RG; then
        log_success "Private Endpoint subnet already exists"
    else
        log_info "Creating Private Endpoint subnet"
        az network vnet subnet create \
            --name $PE_SUBNET_NAME \
            --resource-group $RG \
            --vnet-name $VNET_NAME \
            --address-prefix $PE_SUBNET_PREFIX \
            --private-endpoint-network-policies Disabled \
            --output none
        
        log_success "Private Endpoint subnet created"
    fi
}

################################################################################
# STEP 3: ENABLE VNET INTEGRATION ON WEB APP
################################################################################

enable_vnet_integration() {
    log_info "Step 3: Enabling VNet Integration on Web App..."
    
    # Check if Web App exists
    if ! log_check az webapp show --name $WEBAPP_NAME --resource-group $RG; then
        log_warning "Web App not found: $WEBAPP_NAME"
        log_warning "Skipping VNet Integration (run this after deploying Web App)"
        return
    fi
    
    # Check if already integrated
    VNET_ROUTE_ALL=$(az webapp config appsettings list \
        --name $WEBAPP_NAME \
        --resource-group $RG \
        --query "[?name=='WEBSITE_VNET_ROUTE_ALL'].value" -o tsv 2>&1 || echo "")
    
    if [ "$VNET_ROUTE_ALL" == "1" ]; then
        log_success "VNet Integration already enabled"
    else
        log_info "Enabling VNet Integration"
        az webapp vnet-integration add \
            --name $WEBAPP_NAME \
            --resource-group $RG \
            --vnet $VNET_NAME \
            --subnet $WEBAPP_SUBNET_NAME \
            --output none
        
        # Enable route all traffic through VNet
        az webapp config appsettings set \
            --name $WEBAPP_NAME \
            --resource-group $RG \
            --settings WEBSITE_VNET_ROUTE_ALL=1 \
            --output none
        
        log_success "VNet Integration enabled"
    fi
}

################################################################################
# STEP 4: ENABLE MANAGED IDENTITY
################################################################################

enable_managed_identity() {
    log_info "Step 4: Enabling Managed Identity..."
    
    # Check if Web App exists
    if ! log_check az webapp show --name $WEBAPP_NAME --resource-group $RG; then
        log_warning "Web App not found: $WEBAPP_NAME"
        log_warning "Skipping Managed Identity (run this after deploying Web App)"
        return
    fi
    
    # Enable Managed Identity
    IDENTITY_ID=$(az webapp identity assign \
        --name $WEBAPP_NAME \
        --resource-group $RG \
        --query principalId -o tsv 2>&1 || echo "")
    
    if [ -z "$IDENTITY_ID" ]; then
        log_error "Failed to enable Managed Identity"
        exit 1
    fi
    
    log_success "Managed Identity enabled: $IDENTITY_ID"
    echo "$IDENTITY_ID" > /tmp/identity_id.txt
}

################################################################################
# STEP 5: CREATE PRIVATE ENDPOINT + DNS
################################################################################

create_private_endpoint() {
    local RESOURCE_NAME=$1
    local RESOURCE_ID=$2
    local GROUP_ID=$3
    local DNS_ZONE=$4
    
    log_info "Creating Private Endpoint for $RESOURCE_NAME ($GROUP_ID)..."
    
    PE_NAME="pe-${RESOURCE_NAME}-${GROUP_ID}"
    
    # Check if Private Endpoint exists
    if az network private-endpoint show \
        --name $PE_NAME \
        --resource-group $RG; then
        log_success "Private Endpoint already exists: $PE_NAME"
    else
        log_info "Creating Private Endpoint: $PE_NAME"
        az network private-endpoint create \
            --name $PE_NAME \
            --resource-group $RG \
            --vnet-name $VNET_NAME \
            --subnet $PE_SUBNET_NAME \
            --private-connection-resource-id $RESOURCE_ID \
            --group-id $GROUP_ID \
            --connection-name "${PE_NAME}-connection" \
            --output none
        
        log_success "Private Endpoint created: $PE_NAME"
    fi
    
    # Get Private IP
    log_info "Getting Private IP for $PE_NAME..."
    PRIVATE_IP=$(az network private-endpoint show \
        --name $PE_NAME \
        --resource-group $RG \
        --query 'customDnsConfigs[0].ipAddresses[0]' -o tsv)
    
    if [ -z "$PRIVATE_IP" ]; then
        log_error "Failed to get Private IP for $PE_NAME"
        exit 1
    fi
    
    log_success "Private IP: $PRIVATE_IP"
    
    # Create DNS Zone (if not exists)
    log_info "Creating Private DNS Zone: $DNS_ZONE..."
    if az network private-dns zone show \
        --name $DNS_ZONE \
        --resource-group $RG; then
        log_success "DNS Zone already exists: $DNS_ZONE"
    else
        az network private-dns zone create \
            --resource-group $RG \
            --name $DNS_ZONE \
            --output none
        
        log_success "DNS Zone created: $DNS_ZONE"
    fi
    
    # Link DNS Zone to VNet (if not linked)
    log_info "Linking DNS Zone to VNet..."
    LINK_NAME="dns-link-${GROUP_ID}"
    if az network private-dns link vnet show \
        --resource-group $RG \
        --zone-name $DNS_ZONE \
        --name $LINK_NAME; then
        log_success "DNS Zone already linked to VNet"
    else
        az network private-dns link vnet create \
            --resource-group $RG \
            --zone-name $DNS_ZONE \
            --name $LINK_NAME \
            --virtual-network $VNET_NAME \
            --registration-enabled false \
            --output none
        
        log_success "DNS Zone linked to VNet"
    fi
    
    # Create DNS A Record
    log_info "Creating DNS A Record..."
    
    # Delete existing record if exists
    az network private-dns record-set a delete \
        --resource-group $RG \
        --zone-name $DNS_ZONE \
        --name $RESOURCE_NAME \
        --yes || true
    
    # Create new record
    az network private-dns record-set a create \
        --resource-group $RG \
        --zone-name $DNS_ZONE \
        --name $RESOURCE_NAME \
        --output none
    
    az network private-dns record-set a add-record \
        --resource-group $RG \
        --zone-name $DNS_ZONE \
        --record-set-name $RESOURCE_NAME \
        --ipv4-address $PRIVATE_IP \
        --output none
    
    log_success "DNS A Record created: $RESOURCE_NAME → $PRIVATE_IP"
}

################################################################################
# STEP 6: GRANT RBAC PERMISSIONS
################################################################################

grant_rbac() {
    local RESOURCE_ID=$1
    local ROLE=$2
    
    log_info "Granting RBAC role: $ROLE..."
    
    # Get Managed Identity ID
    if [ -f /tmp/identity_id.txt ]; then
        IDENTITY_ID=$(cat /tmp/identity_id.txt)
    else
        IDENTITY_ID=$(az webapp identity show \
            --name $WEBAPP_NAME \
            --resource-group $RG \
            --query principalId -o tsv 2>&1 || echo "")
    fi
    
    if [ -z "$IDENTITY_ID" ]; then
        log_warning "Managed Identity not found, skipping RBAC"
        return
    fi
    
    # Check if role assignment exists
    EXISTING=$(az role assignment list \
        --assignee $IDENTITY_ID \
        --scope $RESOURCE_ID \
        --role "$ROLE" \
        --query "[].id" -o tsv 2>&1 || echo "")
    
    if [ -n "$EXISTING" ]; then
        log_success "RBAC role already assigned: $ROLE"
    else
        az role assignment create \
            --assignee $IDENTITY_ID \
            --role "$ROLE" \
            --scope $RESOURCE_ID \
            --output none
        
        log_success "RBAC role assigned: $ROLE"
    fi
}

################################################################################
# RESOURCE-SPECIFIC DEPLOYMENT FUNCTIONS
################################################################################

deploy_storage() {
    local STORAGE_NAME=$1
    
    log_info "Deploying Storage Account: $STORAGE_NAME"
    
    # Create Storage Account with public access DISABLED
    if log_check az storage account show --name $STORAGE_NAME --resource-group $RG; then
        log_success "Storage Account already exists: $STORAGE_NAME"
    else
        log_info "Creating Storage Account with public access DISABLED"
        az storage account create \
            --name $STORAGE_NAME \
            --resource-group $RG \
            --location $LOCATION \
            --sku Standard_LRS \
            --public-network-access Disabled \
            --allow-blob-public-access false \
            --default-action Deny \
            --output none
        
        log_success "Storage Account created: $STORAGE_NAME"
    fi
    
    # Get Storage Account ID
    STORAGE_ID=$(az storage account show \
        --name $STORAGE_NAME \
        --resource-group $RG \
        --query id -o tsv)
    
    # Create Private Endpoints
    create_private_endpoint "$STORAGE_NAME" "$STORAGE_ID" "blob" "privatelink.blob.core.windows.net"
    create_private_endpoint "$STORAGE_NAME" "$STORAGE_ID" "table" "privatelink.table.core.windows.net"
    
    # Grant RBAC permissions
    grant_rbac "$STORAGE_ID" "Storage Blob Data Contributor"
    grant_rbac "$STORAGE_ID" "Storage Table Data Contributor"
    
    log_success "Storage Account deployment complete!"
}

deploy_cosmos() {
    local COSMOS_NAME=$1
    
    log_info "Deploying Cosmos DB: $COSMOS_NAME"
    
    # Create Cosmos DB with public access DISABLED
    if log_check az cosmosdb show --name $COSMOS_NAME --resource-group $RG; then
        log_success "Cosmos DB already exists: $COSMOS_NAME"
    else
        log_info "Creating Cosmos DB with public access DISABLED"
        az cosmosdb create \
            --name $COSMOS_NAME \
            --resource-group $RG \
            --locations regionName=$LOCATION failoverPriority=0 isZoneRedundant=False \
            --public-network-access Disabled \
            --enable-automatic-failover false \
            --output none
        
        log_success "Cosmos DB created: $COSMOS_NAME"
    fi
    
    # Get Cosmos DB ID
    COSMOS_ID=$(az cosmosdb show \
        --name $COSMOS_NAME \
        --resource-group $RG \
        --query id -o tsv)
    
    # Create Private Endpoint
    create_private_endpoint "$COSMOS_NAME" "$COSMOS_ID" "Sql" "privatelink.documents.azure.com"
    
    # Grant RBAC permissions
    grant_rbac "$COSMOS_ID" "Cosmos DB Built-in Data Contributor"
    
    log_success "Cosmos DB deployment complete!"
}

deploy_keyvault() {
    local KV_NAME=$1
    
    log_info "Deploying Key Vault: $KV_NAME"
    
    # Create Key Vault with public access DISABLED
    if log_check az keyvault show --name $KV_NAME --resource-group $RG; then
        log_success "Key Vault already exists: $KV_NAME"
    else
        log_info "Creating Key Vault with public access DISABLED"
        az keyvault create \
            --name $KV_NAME \
            --resource-group $RG \
            --location $LOCATION \
            --public-network-access Disabled \
            --output none
        
        log_success "Key Vault created: $KV_NAME"
    fi
    
    # Get Key Vault ID
    KV_ID=$(az keyvault show \
        --name $KV_NAME \
        --resource-group $RG \
        --query id -o tsv)
    
    # Create Private Endpoint
    create_private_endpoint "$KV_NAME" "$KV_ID" "vault" "privatelink.vaultcore.azure.net"
    
    # Grant RBAC permissions
    grant_rbac "$KV_ID" "Key Vault Secrets User"
    
    log_success "Key Vault deployment complete!"
}

################################################################################
# AZURE AI SEARCH WITH SHARED PRIVATE LINK
################################################################################
# 
# IMPORTANT: Azure AI Search is a Microsoft-managed service that runs OUTSIDE
# your VNet. Regular Private Endpoints DO NOT work for Search indexers accessing
# storage because Search cannot route to your VNet.
#
# Solution: Use "Shared Private Link Resources" which create a private endpoint
# from the Microsoft-managed Search service to your storage account.
#
################################################################################

deploy_search_with_shared_link() {
    local SEARCH_NAME=$1
    local TARGET_RESOURCE_NAME=$2
    local TARGET_RESOURCE_TYPE=$3  # storage, cosmos, sql
    
    log_info "Deploying Azure AI Search with Shared Private Link: $SEARCH_NAME"
    
    # Create Search Service if not exists
    if log_check az search service show --name $SEARCH_NAME --resource-group $RG; then
        log_success "Search Service already exists: $SEARCH_NAME"
    else
        log_info "Creating Search Service"
        az search service create \
            --name $SEARCH_NAME \
            --resource-group $RG \
            --location $LOCATION \
            --sku basic \
            --partition-count 1 \
            --replica-count 1 \
            --output none
        
        log_success "Search Service created: $SEARCH_NAME"
    fi
    
    # Enable Managed Identity on Search
    log_info "Enabling Managed Identity on Search Service..."
    SEARCH_IDENTITY=$(az search service update \
        --name $SEARCH_NAME \
        --resource-group $RG \
        --identity-type SystemAssigned \
        --query "identity.principalId" -o tsv 2>&1 || echo "")
    
    if [ -z "$SEARCH_IDENTITY" ]; then
        # Try to get existing identity
        SEARCH_IDENTITY=$(az search service show \
            --name $SEARCH_NAME \
            --resource-group $RG \
            --query "identity.principalId" -o tsv)
    fi
    
    log_success "Search Managed Identity: $SEARCH_IDENTITY"
    
    # Determine target resource details based on type
    case $TARGET_RESOURCE_TYPE in
        storage)
            TARGET_ID=$(az storage account show \
                --name $TARGET_RESOURCE_NAME \
                --resource-group $RG \
                --query id -o tsv)
            GROUP_ID="blob"
            RBAC_ROLE="Storage Blob Data Reader"
            ;;
        cosmos)
            TARGET_ID=$(az cosmosdb show \
                --name $TARGET_RESOURCE_NAME \
                --resource-group $RG \
                --query id -o tsv)
            GROUP_ID="Sql"
            RBAC_ROLE="Cosmos DB Built-in Data Reader"
            ;;
        sql)
            TARGET_ID=$(az sql server show \
                --name $TARGET_RESOURCE_NAME \
                --resource-group $RG \
                --query id -o tsv)
            GROUP_ID="sqlServer"
            RBAC_ROLE="SQL DB Contributor"
            ;;
        *)
            log_error "Unknown target resource type: $TARGET_RESOURCE_TYPE"
            log_info "Supported types: storage, cosmos, sql"
            exit 1
            ;;
    esac
    
    log_info "Target Resource ID: $TARGET_ID"
    
    # Create Shared Private Link Resource
    LINK_NAME="link-${TARGET_RESOURCE_NAME}-${GROUP_ID}"
    log_info "Creating Shared Private Link: $LINK_NAME"
    
    if az search shared-private-link-resource show \
        --service-name $SEARCH_NAME \
        --resource-group $RG \
        --name $LINK_NAME; then
        log_success "Shared Private Link already exists: $LINK_NAME"
    else
        az search shared-private-link-resource create \
            --service-name $SEARCH_NAME \
            --resource-group $RG \
            --name $LINK_NAME \
            --group-id $GROUP_ID \
            --resource-id $TARGET_ID \
            --request-message "Azure AI Search indexer access" \
            --output none
        
        log_success "Shared Private Link created: $LINK_NAME"
    fi
    
    # Check link status
    log_info "Checking Shared Private Link status..."
    LINK_STATUS=$(az search shared-private-link-resource show \
        --service-name $SEARCH_NAME \
        --resource-group $RG \
        --name $LINK_NAME \
        --query "properties.status" -o tsv)
    
    if [ "$LINK_STATUS" == "Approved" ]; then
        log_success "Shared Private Link status: Approved ✓"
    elif [ "$LINK_STATUS" == "Pending" ]; then
        log_warning "Shared Private Link status: Pending"
        log_warning "You must approve the private endpoint connection on the target resource!"
        echo ""
        log_info "To approve via CLI:"
        echo "  az network private-endpoint-connection approve \\"
        echo "    --resource-group $RG \\"
        echo "    --resource-name $TARGET_RESOURCE_NAME \\"
        echo "    --type Microsoft.Storage/storageAccounts \\"  # Adjust type as needed
        echo "    --name <connection-name> \\"
        echo "    --description 'Approved for AI Search'"
        echo ""
        log_info "Or approve via Azure Portal:"
        echo "  1. Go to $TARGET_RESOURCE_NAME → Networking → Private endpoint connections"
        echo "  2. Find the pending connection from $SEARCH_NAME"
        echo "  3. Select and click 'Approve'"
    else
        log_error "Shared Private Link status: $LINK_STATUS"
    fi
    
    # Grant RBAC to Search Managed Identity
    log_info "Granting RBAC role to Search identity..."
    EXISTING_ROLE=$(az role assignment list \
        --assignee $SEARCH_IDENTITY \
        --scope $TARGET_ID \
        --role "$RBAC_ROLE" \
        --query "[].id" -o tsv 2>&1 || echo "")
    
    if [ -n "$EXISTING_ROLE" ]; then
        log_success "RBAC role already assigned: $RBAC_ROLE"
    else
        az role assignment create \
            --assignee $SEARCH_IDENTITY \
            --role "$RBAC_ROLE" \
            --scope $TARGET_ID \
            --output none
        
        log_success "RBAC role assigned: $RBAC_ROLE"
    fi
    
    echo ""
    log_success "Azure AI Search deployment complete!"
    echo ""
    log_info "Next steps for indexer configuration:"
    echo "  1. Ensure Shared Private Link is Approved"
    echo "  2. Create data source with:"
    echo "     - credentials: { connectionString: ResourceId=$TARGET_ID }"
    echo "     - OR connection string with Managed Identity"
    echo "  3. Set indexer to use Managed Identity authentication"
    echo ""
    log_info "Example indexer data source (REST API):"
    echo '  {'
    echo '    "name": "my-datasource",'
    echo '    "type": "azureblob",'
    echo '    "credentials": {'
    echo "      \"connectionString\": \"ResourceId=$TARGET_ID\""
    echo '    },'
    echo '    "container": { "name": "my-container" }'
    echo '  }'
}

################################################################################
# STEP 7: RESTART APP
################################################################################

restart_app() {
    log_info "Step 7: Restarting Web App..."
    
    if ! log_check az webapp show --name $WEBAPP_NAME --resource-group $RG; then
        log_warning "Web App not found, skipping restart"
        return
    fi
    
    az webapp restart \
        --name $WEBAPP_NAME \
        --resource-group $RG \
        --output none
    
    log_success "Web App restarted"
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    local RESOURCE_TYPE=$1
    local RESOURCE_NAME=$2
    local TARGET_RESOURCE=$3  # For search: target resource name
    local TARGET_TYPE=$4      # For search: target resource type (storage, cosmos, sql)
    
    if [ -z "$RESOURCE_TYPE" ] || [ -z "$RESOURCE_NAME" ]; then
        log_error "Usage: $0 <resource-type> <resource-name> [target-resource] [target-type]"
        echo ""
        echo "Resource types: storage, cosmos, keyvault, search"
        echo ""
        echo "Examples:"
        echo "  $0 storage mystorageaccount"
        echo "  $0 cosmos mycosmosdb"
        echo "  $0 keyvault mykeyvault"
        echo "  $0 search mysearchservice mystorageaccount storage"
        echo ""
        echo "For 'search' type, you must also provide:"
        echo "  - target-resource: Name of the resource Search needs to access"
        echo "  - target-type: Type of target (storage, cosmos, sql)"
        exit 1
    fi
    
    echo ""
    log_info "🚀 Starting MCAPS-Compliant Deployment"
    echo ""
    
    # Common setup (skip for search - it's Microsoft-managed)
    if [ "$RESOURCE_TYPE" != "search" ]; then
        create_vnet
        create_pe_subnet
        enable_vnet_integration
        enable_managed_identity
        echo ""
    fi
    
    # Resource-specific deployment
    case $RESOURCE_TYPE in
        storage)
            deploy_storage "$RESOURCE_NAME"
            ;;
        cosmos)
            deploy_cosmos "$RESOURCE_NAME"
            ;;
        keyvault)
            deploy_keyvault "$RESOURCE_NAME"
            ;;
        search)
            if [ -z "$TARGET_RESOURCE" ] || [ -z "$TARGET_TYPE" ]; then
                log_error "For search deployment, you must provide target resource and type"
                echo "Usage: $0 search <search-name> <target-resource-name> <target-type>"
                echo "Example: $0 search mysearch mystorageaccount storage"
                exit 1
            fi
            deploy_search_with_shared_link "$RESOURCE_NAME" "$TARGET_RESOURCE" "$TARGET_TYPE"
            ;;
        *)
            log_error "Unknown resource type: $RESOURCE_TYPE"
            echo "Supported types: storage, cosmos, keyvault, search"
            exit 1
            ;;
    esac
    
    echo ""
    
    # Restart app
    restart_app
    
    echo ""
    log_success "🎉 Deployment complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Wait 2-3 minutes for DNS propagation"
    echo "  2. Test DNS resolution from Web App console"
    echo "  3. Test application connectivity"
    echo ""
}

# Run main function
main "$@"
