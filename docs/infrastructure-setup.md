# Infrastructure Setup Guide

This guide details the steps to set up the Azure infrastructure required for hosting a static website with CDN integration.

## Prerequisites

Before starting, ensure you have:
- Azure CLI installed and logged in (`az login`)
- Required Azure permissions to create resources
- Azure subscription ID

## Steps

### 1. Create Resource Group

```bash
# Set variables
RESOURCE_GROUP="static-web-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="staticwebsa$(random string)"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### 2. Create Storage Account

```bash
# Create storage account
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --enable-https-traffic-only true \
    --min-tls-version TLS1_2

# Enable static website hosting
az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --static-website \
    --index-document index.html \
    --404-document error.html
```

### 3. Create CDN Profile and Endpoint

```bash
# Set CDN variables
CDN_PROFILE_NAME="static-web-cdn"
CDN_ENDPOINT_NAME="static-web-endpoint"

# Create CDN profile
az cdn profile create \
    --name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --sku Standard_Microsoft

# Create CDN endpoint
az cdn endpoint create \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --origin $(az storage account show -n $STORAGE_ACCOUNT -g $RESOURCE_GROUP --query "primaryEndpoints.web" -o tsv | sed 's/https:\/\///')
```

### 4. Configure Custom Domain (Optional)

If you have a custom domain:

```bash
# Add custom domain to CDN endpoint
az cdn custom-domain create \
    --endpoint-name $CDN_ENDPOINT_NAME \
    --hostname your-domain.com \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP

# Enable HTTPS for custom domain
az cdn custom-domain enable-https \
    --endpoint-name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --custom-domain-name your-domain-com
```

## Verification

1. Verify storage account static website is enabled:
```bash
az storage blob service-properties show \
    --account-name $STORAGE_ACCOUNT \
    --query staticWebsite
```

2. Get the endpoints:
```bash
# Storage account endpoint
az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "primaryEndpoints.web" \
    --output tsv

# CDN endpoint
az cdn endpoint show \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query hostName \
    --output tsv
```

## Clean Up

To remove all resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## Next Steps

After setting up the infrastructure:
1. [Deploy your website content](./content-deployment.md)
2. [Configure CDN settings](./cdn-configuration.md)