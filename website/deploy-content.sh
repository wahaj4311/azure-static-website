#!/bin/bash

# Exit on error
set -e

# Load configuration
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please run the infrastructure deployment script first."
    exit 1
fi

source .env

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Deploying website content to Azure Storage...${NC}"

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query "[0].value" \
    --output tsv)

# Upload content
echo -e "${BLUE}Uploading content to $STORAGE_ACCOUNT...${NC}"
az storage blob upload-batch \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --source . \
    --destination '$web' \
    --pattern "*.html" \
    --content-cache-control "public, max-age=3600" \
    --overwrite

echo -e "${GREEN}Content deployment complete!${NC}"
echo -e "${GREEN}Your website is now available at: ${NC}$STORAGE_URL" 