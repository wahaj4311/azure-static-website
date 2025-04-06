# Content Deployment Guide

This guide explains how to deploy your static website content to Azure Storage.

## Prerequisites

- Completed [infrastructure setup](./infrastructure-setup.md)
- Azure CLI installed and logged in
- Your static website files ready for deployment

## Deployment Steps

### 1. Prepare Your Content

Ensure your static website content is built and ready for deployment. Your content should include at minimum:
- `index.html` (main page)
- `error.html` (404 error page)
- Any other static assets (CSS, JavaScript, images, etc.)

### 2. Get Storage Account Details

```bash
# Set variables (same as in infrastructure setup)
RESOURCE_GROUP="static-web-rg"
STORAGE_ACCOUNT="your-storage-account-name"

# Get the storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query "[0].value" \
    --output tsv)
```

### 3. Upload Content

```bash
# Navigate to your website directory
cd website

# Upload all files to the $web container
az storage blob upload-batch \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --source . \
    --destination '$web' \
    --pattern "*" \
    --content-cache-control "public, max-age=3600"
```

### 4. Verify Deployment

1. Get the website URL:
```bash
az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "primaryEndpoints.web" \
    --output tsv
```

2. Open the URL in a browser to verify your content is accessible.

## Automated Deployment Script

Create a `deploy-content.sh` script in your project:

```bash
#!/bin/bash

# Configuration
RESOURCE_GROUP="static-web-rg"
STORAGE_ACCOUNT="your-storage-account-name"

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query "[0].value" \
    --output tsv)

# Upload content
echo "Uploading content to $STORAGE_ACCOUNT..."
az storage blob upload-batch \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --source . \
    --destination '$web' \
    --pattern "*" \
    --content-cache-control "public, max-age=3600"

# Purge CDN endpoint (if using CDN)
echo "Purging CDN cache..."
az cdn endpoint purge \
    --content-paths "/*" \
    --profile-name "static-web-cdn" \
    --name "static-web-endpoint" \
    --resource-group $RESOURCE_GROUP

echo "Deployment complete!"
```

Make the script executable:
```bash
chmod +x deploy-content.sh
```

## Continuous Deployment

For automated deployments, consider:
1. Setting up a GitHub Actions workflow
2. Using Azure DevOps pipelines
3. Implementing a CI/CD solution of your choice

## Next Steps

After deploying your content:
1. [Configure CDN settings](./cdn-configuration.md) for optimal delivery
2. Set up custom domain (if applicable)
3. Implement continuous deployment 