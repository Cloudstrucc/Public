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

# Define the Dataverse API URL
$apiUrl = $resource + "/api/data/v9.2/"

# Function to create a webpage in Dataverse
function CreateWebPage {
    param (
        [string]$name,
        [string]$parentPageId
    )
    
    # Logic to determine if this is the home page
    # check the name or ID against known values for the home page
    $isHomePage = $false
    if ($name -eq "themes-dist-14.1.0-gcweb" -or $parentPageId -eq $null) {
        $isHomePage = $true
    }

    $partialUrl = $name.ToLower()

    Write-Host "Page Name: $name, Parent Page ID: $parentPageId, Is Home Page: $isHomePage"
    if ($isHomePage) {
        
        return $existingPage.adx_webpageid
    }
    $filter = "adx_partialurl eq '$partialUrl'"
    if ($parentPageId) {
        $filter += " and _adx_parentpageid_value eq $parentPageId"
    }

    $checkUrl = $apiUrl + "adx_webpages?" + "`$filter=$filter"
    
    Write-Host "Checking URL: $checkUrl"  # Debugging statement
    $existingPages = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers
    $existingPage = $existingPages.value | Select-Object -First 1
    
    $webPage = @{
        "adx_name" = $name
        "adx_partialurl" = $partialUrl
      #  "adx_isroot" = $true
        "adx_pagetemplateid@odata.bind" = "/adx_pagetemplates($pageTemplateId)"
        "adx_websiteid@odata.bind" = "/adx_websites($websiteId)"
        "adx_publishingstateid@odata.bind" = "/adx_publishingstates($publishingStateId)"
    }
    if ($parentPageId) {
        $webPage["adx_parentpageid@odata.bind"] = "/adx_webpages($parentPageId)"
    }
    
    Write-Host "Checking URL: $checkUrl"  # Debugging statement
    $webPageJson = $webPage | ConvertTo-Json
    if ($existingPage) {
        Write-Host "Web page already exists. Updating existing page."
      #  $updateUrl = $apiUrl + "adx_webpages(" + $existingPage.adx_webpageid + ")"
      #  Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPageJson -Headers $headers -ContentType "application/json"
        return $existingPage.adx_webpageid #do nothing
    } else {
        try {
            
            $webPageResponse = Invoke-RestMethod -Uri ($apiUrl + "adx_webpages") -Method Post -Body $webPageJson -Headers $headers -ContentType "application/json"
            $newWebPage = $webPageResponse.adx_webpageid
            $contentPage = @{
                "adx_name" = $name
                "adx_partialurl" = $partialUrl
                "adx_pagetemplateid@odata.bind" = "/adx_pagetemplates($pub)"
                "adx_websiteid@odata.bind" = "/adx_websites($websiteId)"
                "adx_rootwebpageid@odata.bind" = "/adx_webpages($newWebPage)"
                "adx_publishingstateid@odata.bind" = "/adx_publishingstates($publishingStateId)"
                "adx_webpagelanguageid@odata.bind" = "/adx_websitelanguages(2ead7a40-e299-ee11-be37-0022483c04c3)"
            }
            $contentPageJson = $contentPage | ConvertTo-Json
            Invoke-RestMethod -Uri ($apiUrl + "adx_webpages") -Method Post -Body $contentPageJson -Headers $headers -ContentType "application/json"
            
            return $newWebPage
        } catch {
            Write-Error "API call failed with $_.Exception.Message"
        }
    }
}

# Function to create a web file
function CreateWebFile {
    param (
        [string]$filePath,
        [string]$parentPageId
    )
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $partialUrl = $fileName.Replace(" ", "").ToLower()
    $mimeType = [System.Web.MimeMapping]::GetMimeMapping($filePath)
    $fileContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($filePath))
    
    $filter = "adx_partialurl eq '$partialUrl'"
    if ($parentPageId) {
        $filter += " and _adx_parentpageid_value eq $parentPageId"
    }
    
    $checkUrl = $apiUrl + "adx_webfiles?" + "`$filter=$filter"
    $existingFiles = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers
   
    $webFile = @{
        "adx_name" = $fileName
        "adx_partialurl" = $partialUrl           
        "adx_parentpageid@odata.bind" = if ($parentPageId) { "/adx_webpages($parentPageId)" } else { $null }
        "adx_websiteid@odata.bind" = "/adx_websites($websiteId)"  # Match website ID
        "adx_publishingstateid@odata.bind" = "/adx_publishingstates($publishingStateId)"
    }
    try {
        $webFileJson = $webFile | ConvertTo-Json
        if ($existingFiles.value.Count -gt 0) {
            Write-Host "Web file already exists: $filePath"
            $existingFile = $existingFiles.value | Select-Object -First 1
            # Update existing web file
            $updateUrl = $apiUrl + "adx_webfiles(" + $existingFile.adx_webfileid + ")"
            Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webFileJson -Headers $headers -ContentType "application/json"
            $webFileId = $existingFile.adx_webfileid
            $annotation = @{
                "objectid_adx_webfile@odata.bind" = "/adx_webfiles($webFileId)"
                "subject" = $fileName
                "filename" = $fileName
                "mimetype" = $mimeType
                "documentbody" = $fileContent
            }
            Write-Host $webFileId + $existingFile
           Invoke-RestMethod -Uri ($apiUrl + "annotations") -Method Post -Body ($annotation | ConvertTo-Json -Depth 10) -Headers $headers -ContentType "application/json"
           5
        } else {
            $webFileResponse = Invoke-RestMethod -Uri ($apiUrl + "adx_webfiles") -Headers $headers -Method Post -Body $webFileJson -ContentType "application/json"
            $webFileId = $webFileResponse.adx_webfileid
            
            if (-not $webFileId) {
                Write-Error "Failed to create web file for $fileName"
                return
            }
            $annotation = @{
                "objectid_adx_webfile@odata.bind" = "/adx_webfiles($webFileId)"
                "subject" = $fileName
                "filename" = $fileName
                "mimetype" = $mimeType
                "documentbody" = $fileContent
            }
            
           Invoke-RestMethod -Uri ($apiUrl + "annotations") -Method Post -Body ($annotation | ConvertTo-Json -Depth 10) -Headers $headers -ContentType "application/json"
                   
            # Additional logic for theme.css
            if ($fileName -eq "theme.css") {
                $homePageWebFile = @{
                    "adx_name" = $fileName + " - Home Page"
                    "adx_partialurl" = $fileName.Replace(" ", "").ToLower() + "-homepage"
                    "adx_parentpageid@odata.bind" = "/adx_webpages($homePageId)" # Assuming $homePageId is defined
                    "adx_websiteid@odata.bind" = "/adx_websites($websiteId)"
                    "adx_publishingstateid@odata.bind" = "/adx_publishingstates($publishingStateId)"
                }
                $homePageWebFileJson = $homePageWebFile | ConvertTo-Json -Depth 10
                Invoke-RestMethod -Uri ($apiUrl + "adx_webfiles") -Headers $headers -Method Post -Body $homePageWebFileJson -ContentType "application/json"
            }
        } 
    } catch {
        Write-Error "API call failed with $_.Exception.Message"
    }
}


# Function to process folder and create webpages + webfiles
function WriteHierarchy {
    param (
        [string]$path,
        [string]$indent = "",
        [string]$parentPageId = $null
    )
    
    $items = Get-ChildItem -Path $path
    
    foreach ($item in $items) {
        if (-not $item.PSIsContainer) {
            # Process files
            CreateWebFile -filePath $item.FullName -parentPageId $parentPageId
        } else {
            # Process directories
           # $newPageId = CreateWebPage -name $item.Name -parentPageId $parentPageId
            WriteHierarchy -path $item.FullName -indent ("  " + $indent) -parentPageId $newPageId
        }
    }
}


# Extract the zip file
$zipFilePath = "C:\Users\Fred\source\repos\pub\Public\files\themes-dist-14.1.0-gcweb.zip"
$extractionPath = "C:\Users\Fred\source\repos\pub\Public\files"
Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force

# Start processing the extracted folder
Write-Host $extractionPath
WriteHierarchy -path $extractionPath

# Helpers

function DeleteNonRootWebPages {
    $queryUrl = $apiUrl + "adx_webpages?\$filter=" + ("adx_isroot eq false and _adx_websiteid_value" + " eq '$websiteId'")
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



function DeleteTodaysadxWebFiles {
    $today = (Get-Date).Date
    $tomorrow = $today.AddDays(1)

    # Format dates for OData query
    $todayString = $today.ToString("yyyy-MM-ddT00:00:00Z") # Format adjusted here
    $tomorrowString = $tomorrow.ToString("yyyy-MM-ddT00:00:00Z") # Format adjusted here

    # Query to get webfiles created today
    $queryUrl = $apiUrl + "adx_webfiles?`$filter=adx_createdon ge $todayString and adx_createdon lt $tomorrowString"
    
    try {
        $webFilesToday = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers
        foreach ($webFile in $webFilesToday.value) {
            $webFileId = $webFile.adx_webfileid
            $deleteUrl = $apiUrl + "adx_webfiles($webFileId)"
            Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
            Write-Host "Deleted web file: $webFileId"
        }
        Write-Host "All web files created today have been deleted."
    } catch {
        Write-Error "An error occurred: $_.Exception.Message"
    }
}



function FetchSampleadxWebFiles {
    $queryUrl = $apiUrl + 'adx_webfiles?$select=adx_name' # Corrected query
    Write-Host $queryUrl
    try {
        $webFilesSample = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers
        foreach ($webFile in $webFilesSample.value) {
            $webFile | Format-List
        }
    } catch {
        Write-Error "An error occurred: $_.Exception.Message"
    }
}



# FetchSampleadxWebFiles
# Call the function
# DeleteTodaysadxWebFiles
#DeleteNonRootWebPages
