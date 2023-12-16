# Pre requisites and post running
## System settings
## app registration / sys admin
## post: download the css/theme.css - replace the root theme.css - comment all css in the portalbasictheme.css file
## to do: update the header footer and body html with boiler plate (automate steps above)

# Prompt the user for input or provide a JSON file option
$useJsonConfig = Read-Host "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]"
$jsonConfig = $null

if ($useJsonConfig -eq "Y" -or $useJsonConfig -eq "y") {
    $jsonFilePath = Read-Host "Enter the path to the JSON configuration file"
    if (Test-Path -Path $jsonFilePath -PathType Leaf) {
        $jsonConfig = Get-Content $jsonFilePath | ConvertFrom-Json
    }
} elseif ($useJsonConfig -eq "H" -or $useJsonConfig -eq "h") {
    # Display a brief description of how the JSON object should be created
    Write-Host "JSON Configuration File Format:"
    Write-Host "{
    `"clientId`": `"<client id>`",
    `"tenantId`": `"<tenant id>`",
    `"crmInstance`": `"<crm instance>`",
    `"redirectUri`": `"https://login.onmicrosoft.com`",
    `"websiteId`": `"<website id>`",
    `"pageTemplateId`": `"<page template id>`",
    `"publishingStateId`": `"<publishing state id>`",
    `"homePageId`": `"<home page's webpage id value>`",
    `"edm`": `$false,
    `"clientSecret`": `"app registration client secret`",
}"

    # Exit the script
    exit
}

# Define default values
$defaultConfig = @{
    "clientId" = "<client id>"
    "tenantId" = "<tenant id>"
    "crmInstance" = "<crm instance>"
    "redirectUri" = "https://login.onmicrosoft.com"
    "websiteId" = "<website id>"
    "pageTemplateId" = "<page template id>"
    "publishingStateId" = "<publishing state id>"
    "homePageId" = "<home page's webpage id value>"
    "edm" = $false
    "clientSecret" = "SIf8Q~KwaXZdzgC0gBwELfF2rgHPq5TcW-bM-b9w"
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
$pageTemplateId = $config.pageTemplateId
$publishingStateId = $config.publishingStateId
$homePageId = $config.homePageId
$edm = $true
$secret = $config.clientSecret
$prefix = "mspp"
# Function to apply prefix
function ApplyPrefix($attributeName) {
    return $(if ($edm) { $attributeName -replace "adx", $prefix } else { $attributeName -replace "adx", $prefix })
}

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

# Define the Dataverse API URL
$apiUrl = $resource + "/api/data/v9.2/"

# Function to create a webpage in Dataverse
# Function to create a webpage in Dataverse
# Function to create a webpage in Dataverse
function CreateWebPage {
    param (
        [string]$name,
        [string]$parentPageId
    )
    
    $partialUrl = $name.ToLower()
    $filter = (ApplyPrefix("adx_partialurl eq '$partialUrl'"))
    if ($parentPageId) {
        $filter += " and " + (ApplyPrefix("_adx_parentpageid_value")) + " eq $parentPageId"
    }
    
    # Check if the webpage exists
    $checkUrl = $apiUrl + (ApplyPrefix("adx_webpages")) + "?" + "$filter=$filter"
    $existingPages = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers
    $existingPage = $existingPages.value | Select-Object -First 1
    
    $webPage = @{
        (ApplyPrefix("adx_name")) = $name
        (ApplyPrefix("adx_partialurl")) = $partialUrl
        (ApplyPrefix("adx_isroot")) = $true
        (ApplyPrefix("adx_pagetemplateid@odata.bind")) = "/adx_pagetemplates($pageTemplateId)"
        (ApplyPrefix("adx_websiteid@odata.bind")) = "/adx_websites($websiteId)" 
        (ApplyPrefix("adx_publishingstateid@odata.bind")) = "/adx_publishingstates($publishingStateId)" 
        
    }
    if ($parentPageId) {
        $webPage[(ApplyPrefix("adx_parentpageid@odata.bind"))] = "/adx_webpages($parentPageId)" 
    }
    $webPageJson = $webPage | ConvertTo-Json
    if ($existingPage) {
        # Update existing webpage
        $updateUrl = $apiUrl + (ApplyPrefix("adx_webpages(" + $existingPage.adx_webpageid + ")"))
        Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPageJson -Headers $headers -ContentType "application/json"
        return $existingPage.adx_webpageid
    } else {
        try {
            
            $webPageResponse = Invoke-RestMethod -Uri ($apiUrl + (ApplyPrefix("adx_webpages"))) -Method Post -Body $webPageJson -Headers $headers -ContentType "application/json"
            $newWebPage = $webPageResponse.adx_webpageid
            $contentPage = @{
                (ApplyPrefix("adx_name")) = $name
                (ApplyPrefix("adx_partialurl")) = $partialUrl
                (ApplyPrefix("adx_pagetemplateid@odata.bind")) = "/adx_pagetemplates(cb07803a-e299-ee11-be37-0022483c04c3)"
                (ApplyPrefix("adx_websiteid@odata.bind")) = "/adx_websites(27ad7a40-e299-ee11-be37-0022483c04c3)" 
                (ApplyPrefix("adx_rootwebpageid@odata.bind")) = "/adx_webpages($newWebPage)"
                (ApplyPrefix("adx_publishingstateid@odata.bind")) = "/adx_publishingstates(e007803a-e299-ee11-be37-0022483c04c3)"
                (ApplyPrefix("adx_webpagelanguageid@odata.bind")) = "/adx_websitelanguages(2ead7a40-e299-ee11-be37-0022483c04c3)"  
            }
            $contentPageJson = $contentPage | ConvertTo-Json
            Invoke-RestMethod -Uri ($apiUrl + (ApplyPrefix("adx_webpages"))) -Method Post -Body $contentPageJson -Headers $headers -ContentType "application/json"
            
            return $webPageResponse.adx_webpageid
        } catch {
            Write-Error "API call failed with $_.Exception.Message"
        }
    }
}



# Function to process folder and create webpages + webfiles
function WriteHierarchy {
    param (
        [string]$path,
        [string]$indent = "",
        [string]$parentPageId = $null # This is the ID of the parent webpage, if any
    )
    $extractedFolderName = "themes-dist-14.1.0-gcweb"
    $items = Get-ChildItem -Path $path
    
    foreach ($item in $items) {
        
        # Skip the initial extracted folder
        if ($item.Name -eq $extractedFolderName) {
            
            WriteHierarchy -path $item.FullName -indent ("  " + $indent) -parentPageId $homePageId
            continue
        }
        if (Test-Path -Path $item.FullName -PathType Container) {
            Write-Host $item.Name
            # Create a webpage for the folder
            $newPageId =  CreateWebPage -name $item.Name -parentPageId $parentPageId
            
            # Recursively call Write-Hierarchy for the subfolder, passing the new page ID as parentPageId
            WriteHierarchy -path $item.FullName -indent ("  " + $indent) -parentPageId $newPageId
        } else {
            # If it's a file, create a web file and associate it with the parent webpage
            if ($parentPageId) {
                CreateWebFile -filePath $item.FullName -parentPageId $parentPageId
            }
        }
    }
}

# Extract the zip file
$zipFilePath = "C:\Users\Fred\source\repos\pub\Public\files\themes-dist-14.1.0-gcweb.zip"
$extractionPath = "C:\Users\Fred\projects\GOC-COE\GOC-CoE-Portal\files"
Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force

# Start processing the extracted folder
WriteHierarchy -path $extractionPath

# Helpers
function DeleteNonRootWebPages {
    $queryUrl = $apiUrl + "adx_webpages?\$filter=" + (ApplyPrefix("adx_isroot eq false and _adx_websiteid_value") + " eq '$websiteId'")
    try {
        $webPages = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers
        foreach ($webPage in $webPages.value) {
            $deleteUrl = $apiUrl + "adx_webpages(" + $webPage.adx_webpageid + ")"
            Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
            Write-Host "Deleted web page: $($webPage | Select-Object -ExpandProperty $(ApplyPrefix("adx_name")))"
        }
    } catch {
        Write-Error "Error in deleting non-root web pages: $_"
    }
}


# Call the function
#DeleteNonRootWebPages
