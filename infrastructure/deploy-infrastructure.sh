#!/bin/bash

# Exit on error
set -e

# Configuration
RESOURCE_GROUP="static-web-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="staticweb$(date +%s)"  # Unique name using timestamp
CDN_PROFILE_NAME="static-web-cdn"
CDN_ENDPOINT_NAME="static-web-endpoint"

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
    --enable-https-traffic-only true \
    --min-tls-version TLS1_2

# Enable static website hosting
echo -e "${BLUE}Enabling static website hosting...${NC}"
az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --static-website \
    --index-document index.html \
    --404-document error.html

# Create CDN profile
echo -e "${BLUE}Creating CDN profile...${NC}"
az cdn profile create \
    --name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --sku Standard_Microsoft

# Create CDN endpoint
echo -e "${BLUE}Creating CDN endpoint...${NC}"
az cdn endpoint create \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --origin $(az storage account show -n $STORAGE_ACCOUNT -g $RESOURCE_GROUP --query "primaryEndpoints.web" -o tsv | sed 's/https:\/\///')

# Configure CDN
echo -e "${BLUE}Configuring CDN...${NC}"

# Set global caching rules
az cdn endpoint update \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query-string-caching-behavior IgnoreQueryString

# Enable compression
az cdn endpoint update \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --content-types-to-compress \
        "text/plain" \
        "text/html" \
        "text/css" \
        "text/javascript" \
        "application/x-javascript" \
        "application/javascript" \
        "application/json" \
        "application/xml" \
    --is-compression-enabled true

# Get endpoints
STORAGE_URL=$(az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "primaryEndpoints.web" \
    --output tsv)

CDN_URL=$(az cdn endpoint show \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query hostName \
    --output tsv)

# Save configuration
echo -e "${BLUE}Saving configuration...${NC}"
cat > ../website/.env << EOF
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
RESOURCE_GROUP=$RESOURCE_GROUP
CDN_PROFILE_NAME=$CDN_PROFILE_NAME
CDN_ENDPOINT_NAME=$CDN_ENDPOINT_NAME
STORAGE_URL=$STORAGE_URL
CDN_URL=$CDN_URL
EOF

echo -e "${GREEN}Infrastructure deployment complete!${NC}"
echo -e "${GREEN}Storage Account URL: ${NC}$STORAGE_URL"
echo -e "${GREEN}CDN Endpoint URL: ${NC}https://$CDN_URL"
echo -e "${BLUE}Configuration saved to website/.env${NC}"