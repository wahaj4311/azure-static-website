# CDN Configuration Guide

This guide covers the configuration of Azure CDN for optimal delivery of your static website content.

## Prerequisites

- Completed [infrastructure setup](./infrastructure-setup.md)
- Deployed [website content](./content-deployment.md)
- Azure CLI installed and logged in

## Basic CDN Configuration

### 1. Configure Caching Rules

```bash
# Set variables
RESOURCE_GROUP="static-web-rg"
CDN_PROFILE_NAME="static-web-cdn"
CDN_ENDPOINT_NAME="static-web-endpoint"

# Set global caching rules
az cdn endpoint update \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query-string-caching-behavior IgnoreQueryString

# Add caching rules for static assets
az cdn endpoint rule add \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --order 1 \
    --rule-name "CacheStaticFiles" \
    --match-variable UrlFileExtension \
    --operator Contains \
    --match-values css js png jpg jpeg gif ico \
    --action-name CacheExpiration \
    --cache-behavior SetIfMissing \
    --cache-duration 7.00:00:00
```

### 2. Enable Compression

```bash
# Enable compression for applicable content types
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
```

### 3. Configure HTTPS

```bash
# Enable HTTPS
az cdn endpoint update \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query-string-caching-behavior IgnoreQueryString \
    --http-port 80 \
    --https-port 443 \
    --minimum-tls-version "TLS12"
```

## Advanced Configuration

### 1. Custom Rules Engine Rules

For Standard/Premium CDN profiles, you can create custom rules:

```bash
# Redirect HTTP to HTTPS
az cdn endpoint rule add \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --order 1 \
    --rule-name "HttpsRedirect" \
    --match-variable RequestScheme \
    --operator Equal \
    --match-values HTTP \
    --action-name "UrlRedirect" \
    --redirect-type Moved \
    --redirect-protocol Https

# Add security headers
az cdn endpoint rule add \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --order 2 \
    --rule-name "SecurityHeaders" \
    --match-variable RequestUri \
    --operator Contains \
    --match-values "/" \
    --action-name ModifyResponseHeader \
    --header-action Append \
    --header-name "X-Content-Type-Options" \
    --header-value "nosniff"
```

### 2. Geo-Filtering (if needed)

```bash
# Allow access only from specific countries
az cdn endpoint rule add \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --order 3 \
    --rule-name "GeoFilter" \
    --match-variable RemoteAddress \
    --operator GeoMatch \
    --match-values US GB CA \
    --action-name "Allow"
```

## Monitoring and Optimization

### 1. Enable Real-time Metrics

```bash
# Enable real-time metrics
az cdn endpoint update \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP \
    --enable-real-time-metrics true
```

### 2. Set up Alerts

```bash
# Create alert for high latency
az monitor metrics alert create \
    --name "CDN-HighLatency" \
    --resource-group $RESOURCE_GROUP \
    --scopes $(az cdn endpoint show \
        --name $CDN_ENDPOINT_NAME \
        --profile-name $CDN_PROFILE_NAME \
        --resource-group $RESOURCE_GROUP \
        --query id -o tsv) \
    --condition "avg LatencyMilliseconds > 1000" \
    --window-size 5m \
    --evaluation-frequency 1m
```

## Maintenance

### 1. Purge Cache

```bash
# Purge entire cache
az cdn endpoint purge \
    --content-paths "/*" \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP

# Purge specific paths
az cdn endpoint purge \
    --content-paths "/css/*" "/js/*" \
    --name $CDN_ENDPOINT_NAME \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $RESOURCE_GROUP
```

### 2. Load Testing

Consider using Azure Load Testing to verify CDN performance:

```bash
# Create a load test
az load test create \
    --name "cdn-load-test" \
    --resource-group $RESOURCE_GROUP \
    --location eastus
```

## Best Practices

1. **Cache Configuration**
   - Set appropriate cache durations for different content types
   - Use query string handling appropriate for your application
   - Implement cache purge strategy for content updates

2. **Security**
   - Enable HTTPS
   - Implement appropriate security headers
   - Configure geo-filtering if needed
   - Use latest TLS version

3. **Performance**
   - Enable compression
   - Optimize origin response times
   - Monitor CDN metrics
   - Implement proper error pages

4. **Monitoring**
   - Set up alerts for key metrics
   - Monitor cache hit ratio
   - Track bandwidth usage
   - Monitor response times 