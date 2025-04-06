#!/bin/bash

# Exit on error
set -e

# Configuration
RESOURCE_GROUP="static-web-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="staticweb$(date +%s)"  # Unique name using timestamp

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating Azure infrastructure for static website hosting...${NC}"

# Create resource group
echo -e "${BLUE}Creating resource group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
echo -e "${BLUE}Creating storage account...${NC}"
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access true

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query "[0].value" \
    --output tsv)

# Enable static website hosting
echo -e "${BLUE}Enabling static website hosting...${NC}"
az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --static-website \
    --index-document index.html \
    --404-document error.html

# Get endpoints
STORAGE_URL=$(az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "primaryEndpoints.web" \
    --output tsv)

# Save configuration
echo -e "${BLUE}Saving configuration...${NC}"
mkdir -p ../website
cat > ../website/.env << EOF
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
RESOURCE_GROUP=$RESOURCE_GROUP
STORAGE_KEY=$STORAGE_KEY
STORAGE_URL=$STORAGE_URL
EOF

echo -e "${GREEN}Infrastructure deployment complete!${NC}"
echo -e "${GREEN}Storage Account URL: ${NC}$STORAGE_URL"
echo -e "${BLUE}Configuration saved to website/.env${NC}"

echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Deploy your website content:"
echo "   cd ../website && ./deploy-content.sh"
echo -e "\n2. Access your website at:"
echo "   $STORAGE_URL"