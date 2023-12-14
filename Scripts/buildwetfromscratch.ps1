#Pre requisites and post running
# System settings
# app registration / sys admin
# post: download the css/theme.css - replace the root theme.css - comment all css in the portalbasictheme.css file

# to do: update the header footer and body html with boiler plate (automate steps above)

# Connection details (replace placeholders with actual values)
$clientId = "4ff994b1-9789-40e1-874c-50fc92007812"
$tenantId = "24a46daa-7b87-4566-9eea-281326a1b75c"  # Replace with your Azure AD tenant ID
$authority = "https://login.microsoftonline.com/$tenantId"
$resource = "https://goc-wetv14.api.crm3.dynamics.com"
$redirectUri = "https://login.onmicrosoft.com" # Redirect URI for the app
$tokenEndpoint = "$authority/oauth2/v2.0/token"
$websiteId = "27ad7a40-e299-ee11-be37-0022483c04c3"
$pageTemplateId = "cb07803a-e299-ee11-be37-0022483c04c3"
$publishingStateId = "e007803a-e299-ee11-be37-0022483c04c3"
$homePageId = "e3ac7a40-e299-ee11-be37-0022483c04c3"
# Prepare the body for the token request
$body = @{
    client_id     = $clientId
    scope         = $resource + "/.default"
    grant_type    = "client_credentials"  # Assuming client credentials flow
    redirect_uri  = $redirectUri
    client_secret = "SIf8Q~KwaXZdzgC0gBwELfF2rgHPq5TcW-bM-b9w"  # Replace with your client secret
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
    
    $partialUrl = $name.ToLower()
    $filter = "adx_partialurl eq '$partialUrl'"
    if ($parentPageId) {
        $filter += " and _adx_parentpageid_value eq $parentPageId"
    }
    
    # Check if the webpage exists
    $checkUrl = $apiUrl + "adx_webpages?`$filter=$filter"
    $existingPages = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers
    $existingPage = $existingPages.value | Select-Object -First 1
    
    $webPage = @{
        "adx_name" = $name
        "adx_partialurl" = $name.ToLower()
        "adx_isroot" = $true
        "adx_pagetemplateid@odata.bind" = "/adx_pagetemplates($pageTemplateId)"
        "adx_websiteid@odata.bind" = "/adx_websites($websiteId)" 
        "adx_publishingstateid@odata.bind" = "/adx_publishingstates($publishingStateId)" 
        
    }
    if ($parentPageId) {
        $webPage["adx_parentpageid@odata.bind"] = "/adx_webpages($parentPageId)" 
    }
    $webPageJson = $webPage | ConvertTo-Json
    if ($existingPage) {
        # Update existing webpage
        $updateUrl = $apiUrl + "adx_webpages(" + $existingPage.adx_webpageid + ")"
        Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPageJson -Headers $headers -ContentType "application/json"
        return $existingPage.adx_webpageid
    } else {
        try {
            
            $webPageResponse = Invoke-RestMethod -Uri ($apiUrl + "adx_webpages") -Method Post -Body $webPageJson -Headers $headers -ContentType "application/json"
            $newWebPage = $webPageResponse.adx_webpageid
            $contentPage = @{
                "adx_name" = $name
                "adx_partialurl" = $name.ToLower()
                "adx_pagetemplateid@odata.bind" = "/adx_pagetemplates(cb07803a-e299-ee11-be37-0022483c04c3)"
                "adx_websiteid@odata.bind" = "/adx_websites(27ad7a40-e299-ee11-be37-0022483c04c3)" 
                "adx_rootwebpageid@odata.bind" = "/adx_webpages($newWebPage)"
                "adx_publishingstateid@odata.bind" = "/adx_publishingstates(e007803a-e299-ee11-be37-0022483c04c3)"
                "adx_webpagelanguageid@odata.bind" = "/adx_websitelanguages(2ead7a40-e299-ee11-be37-0022483c04c3)"  
            }
            $contentPageJson = $contentPage | ConvertTo-Json
            Invoke-RestMethod -Uri ($apiUrl + "adx_webpages") -Method Post -Body $contentPageJson -Headers $headers -ContentType "application/json"
            
            return $webPageResponse.adx_webpageid
        } catch {
            Write-Error "API call failed with $_.Exception.Message"
        }
    }
}
function CreateWebFile {
    param (
    [string]$filePath,
    [string]$parentPageId
    )
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $partialUrl = $fileName.Replace(" ", "").ToLower()
    $mimeType = [System.Web.MimeMapping]::GetMimeMapping($filePath)
    $fileContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($filePath))
    
    # Check if the web file exists
   $filter = "adx_partialurl eq '$partialUrl'"
    if ($parentPageId) {
        $filter += " and _adx_parentpageid_value eq $parentPageId"
    }
    
    $checkUrl = $apiUrl + "adx_webfiles?`$filter=$filter"
    $existingFiles = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers
    $existingFile = $existingFiles.value | Select-Object -First 1
    
    
    $webFile = @{
        "adx_name" = $fileName
        "adx_partialurl" = $fileName.Replace(" ", "").ToLower()
        "adx_parentpageid@odata.bind" = if ($parentPageId) { "/adx_webpages($parentPageId)" } else { $null }
        "adx_websiteid@odata.bind" = "/adx_websites($websiteId)"  # Match website ID
        "adx_publishingstateid@odata.bind" = "/adx_publishingstates($publishingStateId)"
    }
    try {
        $webFileJson = $webFile | ConvertTo-Json -Depth 10
        if ($existingFile) {
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
            
            Invoke-RestMethod -Uri ($apiUrl + "annotations") -Method Post -Body ($annotation | ConvertTo-Json -Depth 10) -Headers $headers -ContentType "application/json"
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
$zipFilePath = "C:\Users\Fred\projects\GOC-COE\GOC-CoE-Portal\themes-dist-14.1.0-gcweb.zip"
$extractionPath = "C:\Users\Fred\projects\GOC-COE\GOC-CoE-Portal\files"
Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force
# Start processing the extracted folder
WriteHierarchy -path $extractionPath


# Helpers
function DeleteNonRootWebPages {
    $queryUrl = $apiUrl + "adx_webpages?`$filter=adx_isroot eq false and _adx_websiteid_value eq '$websiteId'"
    try {
        $webPages = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers
        foreach ($webPage in $webPages.value) {
            $deleteUrl = $apiUrl + "adx_webpages(" + $webPage.adx_webpageid + ")"
            Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
            Write-Host "Deleted web page: $($webPage.adx_name)"
        }
    } catch {
        Write-Error "Error in deleting non-root web pages: $_"
    }
}
# Call the function
#DeleteNonRootWebPages