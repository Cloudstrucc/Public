# **Call from Power Automate**

1. **Method** : GET
2. **URI** : `https://your-function-app.azurewebsites.net/api/InternalDnsLookup?hostname=your-internal-apim.azure-api.net`
3. **Headers** : `x-functions-key: your-function-key`

## Method 2: Use APIM Test Console Endpoint

If your APIM has the test console enabled, you can call a simple endpoint to get connection info:

**HTTP Action in Power Automate:**

1. **Method** : GET
2. **URI** : `https://your-internal-apim.azure-api.net/status-0123456789abcdef`
3. This will tell you if the connection works and what IP it resolved to
