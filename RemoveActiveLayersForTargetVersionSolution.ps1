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
        Write-Host "Invalid file path provided"
        exit
    }
}

# Set up authentication parameters
$clientId = $jsonConfig.auth.clientId
$tenantId = $jsonConfig.auth.tenantId
$sourceUrl = $jsonConfig.environments.source.url
$targetUrl = $jsonConfig.environments.target.url
$clientSecret = $jsonConfig.auth.clientSecret
$solutionUniqueName = $jsonConfig.solution.uniqueName

# Function to get access token
function Get-AccessToken {
    param (
        [string]$url
    )
    
    $authority = "https://login.microsoftonline.com/$tenantId"
    $resource = "https://$url.api.crm.dynamics.com"
    $tokenEndpoint = "$authority/oauth2/v2.0/token"

    $body = @{
        client_id     = $clientId
        scope         = "$resource/.default"
        grant_type    = "client_credentials"
        client_secret = $clientSecret
    }

    $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
    return $authResponse.access_token
}

# Function to get solution components
function Get-SolutionComponents {
    param (
        [string]$environmentUrl,
        [string]$token,
        [string]$solutionName
    )

    $headers = @{
        Authorization = "Bearer $token"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        Accept = "application/json"
    }

    $apiUrl = "https://$environmentUrl.api.crm.dynamics.com/api/data/v9.2/"
    $fetchUrl = $apiUrl + "solutions?`$filter=uniquename eq '$solutionName'&`$expand=components"

    try {
        $response = Invoke-RestMethod -Uri $fetchUrl -Method Get -Headers $headers
        return $response.value[0].components
    }
    catch {
        Write-Warning "Error getting solution components: $_"
        return $null
    }
}

# Function to remove active layers
function Remove-ActiveLayer {
    param (
        [string]$environmentUrl,
        [string]$token,
        [string]$componentId,
        [int]$componentType
    )

    $headers = @{
        Authorization = "Bearer $token"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        Accept = "application/json"
        "If-Match" = "*"
    }

    $apiUrl = "https://$environmentUrl.api.crm.dynamics.com/api/data/v9.2/"
    $layerUrl = $apiUrl + "DeleteActiveCustomizations(ComponentId=@p1,ComponentType=@p2)?@p1='$componentId'&@p2=$componentType"

    try {
        Invoke-RestMethod -Uri $layerUrl -Method Post -Headers $headers
        Write-Host "Successfully removed active layer for component $componentId"
    }
    catch {
        Write-Warning "Failed to remove active layer for component $componentId : $_"
    }
}

# Main execution
try {
    # Get tokens for both environments
    Write-Host "Getting access tokens..."
    $sourceToken = Get-AccessToken -url $sourceUrl
    $targetToken = Get-AccessToken -url $targetUrl

    # Get solution components from source
    Write-Host "Getting solution components from source..."
    $sourceComponents = Get-SolutionComponents -environmentUrl $sourceUrl -token $sourceToken -solutionName $solutionUniqueName

    if ($null -eq $sourceComponents) {
        Write-Host "No components found in source solution"
        exit
    }

    # Process each component
    Write-Host "Processing components..."
    foreach ($component in $sourceComponents) {
        Write-Host "Processing component: $($component.componenttype)"
        Remove-ActiveLayer -environmentUrl $targetUrl -token $targetToken -componentId $component.objectid -componentType $component.componenttype
    }

    Write-Host "Layer cleanup complete!"
}
catch {
    Write-Host "An error occurred: $_"
}