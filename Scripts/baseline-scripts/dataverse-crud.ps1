#  Exmmple JSON file
# {
#     "clientId": "`````",
#     "tenantId": "````",
#     "crmInstance": "cloudstrucc",
#     "redirectUri": "https://login.onmicrosoft.com",
#     "websiteId": "f1b61453-af8f-47f5-b169-d78ec29cc103",
#     "clientSecret": "---",
#     "blobAddress": "https://csenterprise.blob.core.windows.net/wet141/",
#     "FlowURL": "https://prod-07.cana"
# }

$useJsonConfig = Read-Host "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]"
$jsonConfig = $null

if ($useJsonConfig -eq "Y" -or $useJsonConfig -eq "y") {
    $jsonFilePath = Read-Host "Enter the path to the JSON configuration file"
    if (Test-Path -Path $jsonFilePath -PathType Leaf) {
        $jsonConfig = Get-Content $jsonFilePath | ConvertFrom-Json
    } elseif ($useJsonConfig -eq "H" -or $useJsonConfig -eq "h") {
        # Display a brief description of how the JSON object should be created
        Write-Host "JSON Configuration File Format:"
        Write-Host "{
        `"clientId`": `"<client id>`",
        `"tenantId`": `"<tenant id>`",
        `"crmInstance`": `"<crm instance>`",
        `"redirectUri`": `"https://login.onmicrosoft.com`",
        `"websiteId`": `"<website id>`",
        `"blobAddress`" = `"<blob address>`"
        `"FlowURL`" = `"<flow URL>`"
    }" else {
        exit
    }
    exit
}
  


# Define default values
$defaultConfig = @{
    "clientId" = "<client id>"
    "tenantId" = "<tenant id>"
    "crmInstance" = "<crm instance>"
    "redirectUri" = "https://login.onmicrosoft.com"
    "websiteId" = "<website id>"
    "blobAddress" = "<blob address>"
    "FlowURL" = "<flow url>"
}

# Use user-provided JSON or default values
$config = if ($null -ne $jsonConfig) {
    $jsonConfig
} else {
    $defaultConfig | ForEach-Object {
        $key = $_.Key
        $value = Read-Host "Enter the value for $key (Default: $($_.Value))"
        if ([string]::IsNullOrEmpty($value)) {
            $_.Value
        } else {
            $value
        }
    }
}

# Set the variables based on the configuration
$clientId = $config.clientId
$tenantId = $config.tenantId
$authority = "https://login.microsoftonline.com/$tenantId"
$resource = "https://$($config.crmInstance).api.crm3.dynamics.com"
$redirectUri = $config.redirectUri
$tokenEndpoint = "$authority/oauth2/v2.0/token"
$websiteId = $config.websiteId
$secret = $config.clientSecret
# Prepare the body for the token request
$body = @{
    client_id     = $clientId
    scope         = $resource + "/.default"
    grant_type    = "client_credentials"  # Assuming client credentials flow
    redirect_uri  = $redirectUri
    client_secret = $secret  # Replace with your client secret
}
# Acquire the token
$authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $authResponse.access_token

# Set up the HTTP client headers
$headers = @{
    Authorization = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    Accept = "application/json"
    Prefer = "return=representation"
}
$updateHeaders = @{
    Authorization = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    Accept = "application/json"
    Prefer = "return=representation"
    "If-Match" = "*"
}

# Define the Dataverse API URL
$apiUrl = $resource + "/api/data/v9.2/"


function CreateRecordAPI {
    param (
        [string]$url,
        [string]$body        
    )
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers -ContentType "application/json; charset=utf-8"
    return $response

}

function UpdateRecordAPI {
    param (
        [string]$url,
        [string]$body        
    )
    $response = Invoke-RestMethod -Uri $url -Method Patch -Body $body -Headers $updateHeaders -ContentType "application/json; charset=utf-8"
    return $response
}

function GetRecordAPI {
    param (
        [string]$url        
    )
    
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    return $response
}

function GetRootHomePageID {

    $filter += "_mspp_websiteid_value eq '$websiteId' and mspp_isroot eq true and mspp_name eq 'Home'"
    # Get Website Language IDs by Language Code
    $homePageQuery = $apiUrl + "mspp_webpages?" + "`$filter=$filter"
    $homePage = GetRecordAPI -url $homePageQuery
    $homePageId = $homePage.value[0].mspp_webpageid
    Write-Host "Home Web Page ID: $homePageId"
    return $homePageId
}
$homePageId = GetRootHomePageID