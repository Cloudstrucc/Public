# Default values for connection parameters
$defaultConnectionConfig = @{
    "clientId" = "<client id>"
    "tenantId" = "<tenant id>"
    "crmInstance" = "https://<crm instance>.api.crm3.dynamics.com"
    "redirectUri" = "https://login.onmicrosoft.com"
}

# Help prompt for connection parameters
Write-Host "Please provide the necessary connection details for your Dynamics 365 environment."

$clientId = Read-Host "Enter the client ID for your application (Azure AD Application Client ID)" -Default $defaultConnectionConfig["clientId"]
$tenantId = Read-Host "Enter your Azure AD tenant ID" -Default $defaultConnectionConfig["tenantId"]
$crmInstance = Read-Host "Enter the URL of your Dynamics 365 environment" -Default $defaultConnectionConfig["crmInstance"]
$redirectUri = Read-Host "Enter the redirect URI for your application" -Default $defaultConnectionConfig["redirectUri"]

$authority = "https://login.microsoftonline.com/$tenantId"
$resource = $crmInstance
$tokenEndpoint = "$authority/oauth2/v2.0/token"

# Help prompt for the CAB file
Write-Host "To install the French language pack, you will need the CAB file for the language pack."
Write-Host "You can obtain the CAB file from the Microsoft Volume Licensing Service Center (VLSC) or the Dynamics 365 admin portal."
Write-Host "If you don't have access to these sources, please contact your Microsoft account representative or support for assistance."

$useJsonConfig = Read-Host "Do you want to provide a JSON configuration file for installation and system settings? (Y/N)"

$jsonConfig = $null

if ($useJsonConfig -eq "Y" -or $useJsonConfig -eq "y") {
    $jsonFilePath = Read-Host "Enter the path to the JSON configuration file"
    if (Test-Path -Path $jsonFilePath -PathType Leaf) {
        $jsonConfig = Get-Content $jsonFilePath | ConvertFrom-Json
    }
}

# Define default configuration values
$defaultConfig = @{
    "languagePackPath" = "C:\Path\To\FrenchLanguagePack.cab" # Path to the French language pack CAB file
    "fileSizeLimit" = 100000 # 100,000 KB (100 MB)
    "allowedExtensions" = "js,css,xml" # Allowed file extensions for annotations
}

# Function to acquire an access token
function Get-AccessToken {
    param (
        [string]$clientId,
        [string]$authority,
        [string]$resource,
        [string]$redirectUri
    )

    $body = @{
        client_id     = $clientId
        scope         = $resource + "/.default"
        grant_type    = "client_credentials"
        redirect_uri  = $redirectUri
        client_secret = "<client secret>" # Replace with your client secret
    }

    $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
    return $authResponse.access_token
}

# Function to install the French language pack
function Install-FrenchLanguagePack {
    param (
        [string]$languagePackPath,
        [string]$accessToken
    )

    $headers = @{
        Authorization = "Bearer $accessToken"
        Accept = "application/json"
    }

    $url = $resource + "/api/data/v9.2/ImportSolution"
    
    $content = Get-Content -Path $languagePackPath -Encoding Byte
    $solution = @{
        SolutionPackageBase64 = [Convert]::ToBase64String($content)
    }

    $solutionJson = $solution | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ContentType "application/json" -Body $solutionJson

    if ($response -match "Succeeded") {
        Write-Host "French Language Pack installed successfully."
    } else {
        Write-Host "Failed to install French Language Pack. Error: $response"
    }
}

# Function to configure system settings for file size limit and allowed extensions
function ConfigureSystemSettings {
    param (
        [int]$fileSizeLimit,
        [string]$allowedExtensions,
        [string]$accessToken
    )

    $headers = @{
        Authorization = "Bearer $accessToken"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        Accept = "application/json"
        Prefer = "return=representation"
    }

    $systemSettingsUrl = $resource + "/api/data/v9.2/organization?$select=organizationid"
    $organization = Invoke-RestMethod -Uri $systemSettingsUrl -Method Get -Headers $headers

    $organizationId = $organization.organizationid
    $settingsUrl = $resource + "/api/data/v9.2/organizationsettings($organizationId)"

    $settings = @{
        maxuploadfilesize = $fileSizeLimit
        blockedattachments = $allowedExtensions
    }

    $settingsJson = $settings | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $settingsUrl -Method Patch -Headers $headers -ContentType "application/json" -Body $settingsJson

    if ($response) {
        Write-Host "System settings updated successfully."
    } else {
        Write-Host "Failed to update system settings."
    }
}

# Main script
$accessToken = Get-AccessToken -clientId $clientId -authority $authority -resource $resource -redirectUri $redirectUri

# Install the French language pack
if ($null -ne $jsonConfig -and $jsonConfig.ContainsKey("languagePackPath")) {
    Install-FrenchLanguagePack -languagePackPath $jsonConfig["languagePackPath"] -accessToken $accessToken
} else {
    Install-FrenchLanguagePack -languagePackPath $defaultConfig["languagePackPath"] -accessToken $accessToken
}

# Configure system settings
if ($null -ne $jsonConfig -and $jsonConfig.ContainsKey("fileSizeLimit") -and $jsonConfig.ContainsKey("allowedExtensions")) {
    ConfigureSystemSettings -fileSizeLimit $jsonConfig["fileSizeLimit"] -allowedExtensions $jsonConfig["allowedExtensions"] -accessToken $accessToken
} else {
    ConfigureSystemSettings -fileSizeLimit $defaultConfig["fileSizeLimit"] -allowedExtensions $defaultConfig["allowedExtensions"] -accessToken $accessToken
}
