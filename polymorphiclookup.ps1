# Import configuration
$useJsonConfig = Read-Host "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]"
$jsonConfig = $null

if ($useJsonConfig -eq "Y" -or $useJsonConfig -eq "y") {
    $jsonFilePath = Read-Host "Enter the path to the JSON configuration file"
    if (Test-Path -Path $jsonFilePath -PathType Leaf) {
        $jsonConfig = Get-Content $jsonFilePath | ConvertFrom-Json
    } elseif ($useJsonConfig -eq "H" -or $useJsonConfig -eq "h") {
        Write-Host "Please see configuration.json example for the required format"
        Write-Host "JSON Configuration File Format:"
        Write-Host "{
            `"auth`": {
                `"clientId`": `"your-client-id`",
                `"tenantId`": `"your-tenant-id`",
                `"crmInstance`": `"your-instance`",
                `"redirectUri`": `"https://login.onmicrosoft.com`",
                `"clientSecret`": `"your-client-secret`"
            },
            `"solution`": {
                `"uniqueName`": `"YourSolutionUniqueName`"
            },
            `"lookup`": {
                `"operation`": `"create`",
                `"entityName`": `"new_fptest`",
                `"name`": `"new_fppoly`",
                `"schemaName`": `"new_FpPoly`",
                `"displayName`": `"FP Poly`",
                `"targetEntities`": [`"account`", `"contact`"]
            }
        }"
        exit
    } else {
        exit
    }
}

# Validate configuration
if (-not $jsonConfig.lookup.entityName) {
    Write-Host "Error: entityName is required in the configuration."
    exit
}

if (-not $jsonConfig.lookup.name) {
    Write-Host "Error: name is required in the configuration."
    exit
}

if (-not $jsonConfig.lookup.schemaName) {
    Write-Host "Error: schemaName is required in the configuration."
    exit
}

if (-not $jsonConfig.lookup.displayName) {
    Write-Host "Error: displayName is required in the configuration."
    exit
}

if (-not $jsonConfig.lookup.targetEntities -or $jsonConfig.lookup.targetEntities.Count -eq 0) {
    Write-Host "Error: targetEntities array is required and must not be empty."
    exit
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
try {
    $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
    $token = $authResponse.access_token
    Write-Host "Authentication successful!"
} catch {
    Write-Host "Authentication failed: $_"
    exit
}

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

# Function to get attribute metadata
function Get-AttributeMetadata {
    param (
        [string]$entityName,
        [string]$attributeName
    )
    
    $getUrl = $apiUrl + "EntityDefinitions(LogicalName='$entityName')/Attributes(LogicalName='$attributeName')"
    try {
        Write-Host "Getting attribute metadata for $attributeName..."
        $response = Invoke-RestMethod -Uri $getUrl -Method Get -Headers $headers
        return $response
    } catch {
        Write-Host "Error getting attribute metadata: $_"
        return $null
    }
}

# Function to get existing relationship
function Get-ExistingRelationship {
    param (
        [string]$relationshipName
    )
    
    $getUrl = $apiUrl + "RelationshipDefinitions?`$filter=SchemaName eq '$relationshipName'"
    try {
        $response = Invoke-RestMethod -Uri $getUrl -Method Get -Headers $headers
        if ($response.value.Count -gt 0) {
            return $response.value[0]
        }
        return $null
    } catch {
        Write-Host "Error getting relationship: $_"
        return $null
    }
}

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
        ComponentType = $componentType  # 2 for attributes, 10 for relationships
        SolutionUniqueName = $solutionId
        AddRequiredComponents = $true
    } | ConvertTo-Json

    try {
        Write-Host "Adding component to solution with payload:"
        Write-Host $addComponentBody
        
        $response = Invoke-RestMethod -Uri $addComponentUrl -Method Post -Body $addComponentBody -Headers $headers -ContentType "application/json"
        Write-Host "Component added to solution successfully!"
        return $true
    } catch {
        Write-Host "Error adding component to solution: $_"
        return $false
    }
}

# Function to create polymorphic lookup
function New-PolymorphicLookup {
    param (
        [PSCustomObject]$config
    )
    
    $createUrl = $apiUrl + "CreatePolymorphicLookupAttribute"
    
    # Build the relationships array
    $relationships = @()
    foreach ($targetEntity in $config.lookup.targetEntities) {
        $relationships += @{
            SchemaName = "$($config.lookup.name.ToLower())_$targetEntity"
            ReferencedEntity = $targetEntity
            ReferencingEntity = $config.lookup.entityName
            CascadeConfiguration = @{
                Assign = "NoCascade"
                Delete = "RemoveLink"
                Merge = "NoCascade"
                Reparent = "NoCascade"
                Share = "NoCascade"
                Unshare = "NoCascade"
            }
        }
    }

    # Build the complete request payload
    $lookupRequest = @{
        OneToManyRelationships = $relationships
        Lookup = @{
            AttributeType = "Lookup"
            AttributeTypeName = @{
                Value = "LookupType"
            }
            Description = @{
                "@odata.type" = "Microsoft.Dynamics.CRM.Label"
                LocalizedLabels = @(
                    @{
                        "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                        Label = "$($config.lookup.displayName) Polymorphic Lookup Attribute"
                        LanguageCode = 1033
                    }
                )
                UserLocalizedLabel = @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    Label = "$($config.lookup.displayName) Polymorphic Lookup Attribute"
                    LanguageCode = 1033
                }
            }
            DisplayName = @{
                "@odata.type" = "Microsoft.Dynamics.CRM.Label"
                LocalizedLabels = @(
                    @{
                        "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                        Label = $config.lookup.displayName
                        LanguageCode = 1033
                    }
                )
                UserLocalizedLabel = @{
                    "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
                    Label = $config.lookup.displayName
                    LanguageCode = 1033
                }
            }
            SchemaName = $config.lookup.schemaName
            "@odata.type" = "Microsoft.Dynamics.CRM.ComplexLookupAttributeMetadata"
        }
    }

    $createBody = $lookupRequest | ConvertTo-Json -Depth 10

    try {
        Write-Host "Creating polymorphic lookup with payload:"
        Write-Host $createBody

        $response = Invoke-RestMethod -Uri $createUrl -Method Post -Body $createBody -Headers $headers -ContentType "application/json"
        return $response
    } catch {
        Write-Host "Error creating polymorphic lookup: $_"
        $errorResponse = $_.ErrorDetails.Message
        if ($errorResponse) {
            Write-Host "Error details: $errorResponse"
        }
        Write-Host "Response status code: $($_.Exception.Response.StatusCode.value__)"
        Write-Host "Response status description: $($_.Exception.Response.StatusDescription)"
        
        try {
            $rawError = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($rawError)
            $rawErrorContent = $reader.ReadToEnd()
            Write-Host "Raw error content: $rawErrorContent"
        } catch {
            Write-Host "Could not read detailed error message"
        }
        return $null
    }
}

# Main execution
if ($jsonConfig.lookup.operation -eq "create") {
    Write-Host "Creating new polymorphic lookup..."
    $response = New-PolymorphicLookup -config $jsonConfig
    
    if ($response) {
        Write-Host "Polymorphic lookup created successfully!"
        
        # Add to solution if specified
        if ($jsonConfig.solution -and $jsonConfig.solution.uniqueName) {
            Write-Host "Adding new attribute to solution..."
            $solution = Get-Solution -solutionUniqueName $jsonConfig.solution.uniqueName
            
            if ($solution) {
                # Wait for attribute creation to complete
                Write-Host "Waiting for attribute creation to complete..."
                Start-Sleep -Seconds 10
                
                # Get the attribute metadata to get the correct ID
                $attributeMetadata = Get-AttributeMetadata -entityName $jsonConfig.lookup.entityName -attributeName $jsonConfig.lookup.name.ToLower()
                
                if ($attributeMetadata -and $attributeMetadata.MetadataId) {
                    $addResult = Add-ComponentToSolution -solutionId $jsonConfig.solution.uniqueName `
                                                       -componentId $attributeMetadata.MetadataId `
                                                       -componentType 2
                    if ($addResult) {
                        Write-Host "Attribute added to solution successfully"
                        
                        # Add relationships to solution
                        Write-Host "Adding relationships to solution..."
                        foreach ($targetEntity in $jsonConfig.lookup.targetEntities) {
                            $relationshipName = "$($jsonConfig.lookup.name.ToLower())_$targetEntity"
                            Write-Host "Getting relationship metadata for $relationshipName..."
                            Start-Sleep -Seconds 2  # Give time for relationship to be available
                            
                            $relationship = Get-ExistingRelationship -relationshipName $relationshipName
                            if ($relationship -and $relationship.MetadataId) {
                                $addRelResult = Add-ComponentToSolution -solutionId $jsonConfig.solution.uniqueName `
                                                                      -componentId $relationship.MetadataId `
                                                                      -componentType 10
                                if ($addRelResult) {
                                    Write-Host "Relationship $relationshipName added to solution successfully"
                                }
                            } else {
                                Write-Host "Could not find relationship $relationshipName"
                            }
                        }
                    }
                } else {
                    Write-Host "Could not get attribute metadata"
                }
            } else {
                Write-Host "Solution $($jsonConfig.solution.uniqueName) not found!"
            }
        }
    } else {
        Write-Host "Failed to create polymorphic lookup."
    }
}
elseif ($jsonConfig.lookup.operation -eq "update") {
    Write-Host "Update operation for polymorphic lookups is not supported."
    Write-Host "Please create new relationships using the 'create' operation."
}
else {
    Write-Host "Invalid operation specified in configuration. Use 'create'."
}

Write-Host "Script execution completed."