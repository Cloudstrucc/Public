# Import configuration
$useJsonConfig = Read-Host "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]"
$jsonConfig = $null

if ($useJsonConfig -eq "Y" -or $useJsonConfig -eq "y") {
    $jsonFilePath = Read-Host "Enter the path to the JSON configuration file"
    if (Test-Path -Path $jsonFilePath -PathType Leaf) {
        $jsonConfig = Get-Content $jsonFilePath | ConvertFrom-Json
    } elseif ($useJsonConfig -eq "H" -or $useJsonConfig -eq "h") {
        Write-Host "Please see configuration.json example for the required format"
        exit
    } else {
        exit
    }
}

# Set up authentication parameters
$clientId = $jsonConfig.auth.clientId
$tenantId = $jsonConfig.auth.tenantId
$authority = "https://login.microsoftonline.com/$tenantId"
$resource = "https://$($jsonConfig.auth.crmInstance).api.crm3.dynamics.com"
$redirectUri = $jsonConfig.auth.redirectUri
$tokenEndpoint = "$authority/oauth2/v2.0/token"
$secret = $jsonConfig.auth.clientSecret

# Prepare token request
$body = @{
    client_id     = $clientId
    scope         = $resource + "/.default"
    grant_type    = "client_credentials"
    redirect_uri  = $redirectUri
    client_secret = $secret
}

# Get token
$authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $authResponse.access_token

# Set up headers
$headers = @{
    Authorization = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    Accept = "application/json"
    Prefer = "return=representation"
}

# API URL
$apiUrl = $resource + "/api/data/v9.2/"

# Create polymorphic lookup definition
$lookupDefinition = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.LookupAttributeMetadata"
    SchemaName = $jsonConfig.lookup.schemaName
    LogicalName = $jsonConfig.lookup.name.ToLower()
    DisplayName = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        LocalizedLabels = @(
            @{
                "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                Label = $jsonConfig.lookup.displayName
                LanguageCode = 1033
            }
        )
    }
    Description = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        LocalizedLabels = @(
            @{
                "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                Label = $jsonConfig.lookup.description
                LanguageCode = 1033
            }
        )
    }
    RequiredLevel = @{
        Value = if ($jsonConfig.lookup.required) { "Required" } else { "None" }
        "@odata.type" = "Microsoft.Dynamics.CRM.AttributeRequiredLevelManagedProperty"
    }
    Targets = $jsonConfig.lookup.targetEntities
    IsSearchable = $jsonConfig.lookup.searchable
    IsCustomField = $true
}

# Convert to JSON
$lookupDefinitionJson = $lookupDefinition | ConvertTo-Json -Depth 10

# Create the attribute
$createUrl = $apiUrl + "EntityDefinitions(LogicalName='$($jsonConfig.lookup.entityName)')/Attributes"
try {
    $response = Invoke-RestMethod -Uri $createUrl -Method Post -Body $lookupDefinitionJson -Headers $headers -ContentType "application/json"
    Write-Host "Polymorphic lookup created successfully!"
    $response
} catch {
    Write-Host "Error creating polymorphic lookup: $_"
    Write-Host $_.Exception.Response.GetResponseStream()
}