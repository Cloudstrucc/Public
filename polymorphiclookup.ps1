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

# Headers for update operations
$updateHeaders = @{
    Authorization = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    Accept = "application/json"
    "If-Match" = "*"
    Prefer = "return=representation"
}

# API URL
$apiUrl = $resource + "/api/data/v9.2/"

# Function to get solution by unique name
function Get-Solution {
    param (
        [string]$solutionUniqueName
    )
    
    $getSolutionUrl = $apiUrl + "solutions?`$filter=uniquename eq '$solutionUniqueName'"
    try {
        $response = Invoke-RestMethod -Uri $getSolutionUrl -Method Get -Headers $headers
        if ($response.value.Count -gt 0) {
            return $response.value[0]
        }
        return $null
    } catch {
        Write-Host "Error getting solution: $_"
        return $null
    }
}

# Function to add component to solution
function Add-ComponentToSolution {
    param (
        [string]$solutionId,
        [string]$componentId,
        [int]$componentType
    )
    
    $addComponentUrl = $apiUrl + "AddSolutionComponent"
    $addComponentBody = @{
        ComponentId = $componentId
        ComponentType = $componentType  # 2 for entity attributes
        SolutionUniqueName = $solutionId
        AddRequiredComponents = $true
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $addComponentUrl -Method Post -Body $addComponentBody -Headers $headers -ContentType "application/json"
        Write-Host "Component added to solution successfully!"
        return $true
    } catch {
        Write-Host "Error adding component to solution: $_"
        return $false
    }
}

# Function to get existing attribute
function Get-ExistingAttribute {
    param (
        [string]$entityName,
        [string]$attributeName
    )
    
    $getUrl = $apiUrl + "EntityDefinitions(LogicalName='$entityName')/Attributes(LogicalName='$attributeName')"
    try {
        $response = Invoke-RestMethod -Uri $getUrl -Method Get -Headers $headers
        return $response
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            return $null
        }
        throw $_
    }
}

# Function to create lookup definition
function New-LookupDefinition {
    param (
        [PSCustomObject]$config,
        [bool]$isUpdate
    )

    $lookupDefinition = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.LookupAttributeMetadata"
        SchemaName = $config.lookup.schemaName
        LogicalName = $config.lookup.name.ToLower()
        DisplayName = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.Label"
            LocalizedLabels = @(
                @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    Label = $config.lookup.displayName
                    LanguageCode = 1033
                }
            )
        }
        Description = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.Label"
            LocalizedLabels = @(
                @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    Label = $config.lookup.description
                    LanguageCode = 1033
                }
            )
        }
        RequiredLevel = @{
            Value = if ($config.lookup.required) { "Required" } else { "None" }
            "@odata.type" = "Microsoft.Dynamics.CRM.AttributeRequiredLevelManagedProperty"
        }
        Targets = $config.lookup.targetEntities
        IsSearchable = $config.lookup.searchable
        IsCustomField = $true
    }

    # Remove properties that can't be updated if this is an update operation
    if ($isUpdate) {
        $lookupDefinition.Remove("SchemaName")
        $lookupDefinition.Remove("LogicalName")
        $lookupDefinition.Remove("IsCustomField")
    }

    return $lookupDefinition
}

# Main execution
$entityName = $jsonConfig.lookup.entityName
$attributeName = $jsonConfig.lookup.name.ToLower()

# Check if the attribute exists
$existingAttribute = Get-ExistingAttribute -entityName $entityName -attributeName $attributeName

# Determine if we should create or update based on both existence and configuration
$shouldCreate = ($jsonConfig.lookup.operation -eq "create") -or ($null -eq $existingAttribute)
$shouldUpdate = ($jsonConfig.lookup.operation -eq "update") -and ($null -ne $existingAttribute)

if ($shouldCreate) {
    Write-Host "Creating new polymorphic lookup..."
    $lookupDefinition = New-LookupDefinition -config $jsonConfig -isUpdate $false
    $lookupDefinitionJson = $lookupDefinition | ConvertTo-Json -Depth 10
    $createUrl = $apiUrl + "EntityDefinitions(LogicalName='$entityName')/Attributes"
    
    try {
        $response = Invoke-RestMethod -Uri $createUrl -Method Post -Body $lookupDefinitionJson -Headers $headers -ContentType "application/json"
        Write-Host "Polymorphic lookup created successfully!"
        
        # Add to solution if specified
        if ($jsonConfig.solution -and $jsonConfig.solution.uniqueName) {
            Write-Host "Adding new attribute to solution..."
            $solution = Get-Solution -solutionUniqueName $jsonConfig.solution.uniqueName
            if ($solution) {
                $addResult = Add-ComponentToSolution -solutionId $jsonConfig.solution.uniqueName `
                                                   -componentId $response.MetadataId `
                                                   -componentType 2
                if ($addResult) {
                    Write-Host "Attribute successfully added to solution $($jsonConfig.solution.uniqueName)"
                }
            } else {
                Write-Host "Solution $($jsonConfig.solution.uniqueName) not found!"
            }
        }
        
        $response
    } catch {
        Write-Host "Error creating polymorphic lookup: $_"
        Write-Host $_.Exception.Response.GetResponseStream()
    }
}
elseif ($shouldUpdate) {
    Write-Host "Updating existing polymorphic lookup..."
    $lookupDefinition = New-LookupDefinition -config $jsonConfig -isUpdate $true
    $lookupDefinitionJson = $lookupDefinition | ConvertTo-Json -Depth 10
    $updateUrl = $apiUrl + "EntityDefinitions(LogicalName='$entityName')/Attributes(LogicalName='$attributeName')"
    
    try {
        $response = Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $lookupDefinitionJson -Headers $updateHeaders -ContentType "application/json"
        Write-Host "Polymorphic lookup updated successfully!"
        $response
    } catch {
        Write-Host "Error updating polymorphic lookup: $_"
        Write-Host $_.Exception.Response.GetResponseStream()
    }
}
else {
    Write-Host "Invalid operation specified in configuration or attribute state mismatch."
}