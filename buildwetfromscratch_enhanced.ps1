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
$blobAddress = $config.blobAddress

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
# Function to create or update a web page
function CreateWebPage {
    param (
        [string]$name,
        [string]$parentPageId
    )
    
    # Logic to determine if this is the home page
    # Check the name or ID against known values for the home page
    $isHomePage = $false
    if ($name -eq "themes-dist-14.1.0-gcweb" -or $parentPageId -eq $null) {
        $isHomePage = $true
    }

    $partialUrl = $name.ToLower()

    Write-Host "Page Name: $name, Parent Page ID: $parentPageId, Is Home Page: $isHomePage"
    
    if ($isHomePage) {
        return $existingPage.mspp_webpageid
    }

    # Include the website ID in the filter condition
    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value" + " eq '$websiteId'"

    if ($parentPageId) {
        $filter += " and _mspp_parentpageid_value eq $parentPageId"
    }

    $checkUrl = $apiUrl + "mspp_webpages?" + "`$filter=$filter"
    
    Write-Host "Checking URL: $checkUrl"  # Debugging statement
    $existingPages = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers
    $existingPage = $existingPages.value | Select-Object -First 1
    
    $webPage = @{
        "mspp_name" = $name
        "mspp_partialurl" = $partialUrl
        "mspp_pagetemplateid@odata.bind" = "/mspp_pagetemplates($pageTemplateId)"
        "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($publishingStateId)"
    }
    
    if ($parentPageId) {
        $webPage["mspp_parentpageid@odata.bind"] = "/mspp_webpages($parentPageId)"
    }
    
    Write-Host "Checking URL: $checkUrl"  # Debugging statement
    $webPageJson = $webPage | ConvertTo-Json
    
    if ($existingPage) {
        Write-Host "Web page already exists. Updating existing page."
        $updateUrl = $apiUrl + "mspp_webpages(" + $existingPage.mspp_webpageid + ")"
        Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPageJson -Headers $headers -ContentType "application/json"
        return $existingPage.mspp_webpageid
    } else {
        try {
            $webPageResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_webpages") -Method Post -Body $webPageJson -Headers $headers -ContentType "application/json"
            $newWebPage = $webPageResponse.mspp_webpageid
            return $newWebPage
        } catch {
            Write-Error "API call failed with $_.Exception.Message"
        }
    }
}

#### create example wizard form end ########

# Function to create or update a web file with the parent web page ID
function CreateWebFile {
    param (
        [string]$filePath,
        [string]$parentPageId
    )

    $fileName = [System.IO.Path]::GetFileName($filePath)
    $partialUrl = $fileName.Replace(" ", "").ToLower()
    $mimeType = [System.Web.MimeMapping]::GetMimeMapping($filePath)
    $fileContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($filePath))
    $relativePath = Get-RelativePath ($extractionPath + "\themes-dist-14.1.0-gcweb") $filePath

    # Construct the blob storage URL
    $blobUrl = "$blobAddress$relativePath$partialUrl"

    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value" + " eq '$websiteId'"

    if ($parentPageId) {
        $filter += " and _mspp_parentpageid_value eq $parentPageId"
    }

    $checkUrl = $apiUrl + "mspp_webfiles?" + "`$filter=$filter"
    $existingFiles = Invoke-RestMethod -Uri $checkUrl -Method Get -Headers $headers

    $webFile = @{
        "mspp_name" = $fileName
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"  # Match website ID
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($publishingStateId)"
        "mspp_cloudblobaddress" = $blobUrl  # Set the blob storage URL to the full path
    }

    if ($parentPageId) {
        $webFile["mspp_parentpageid@odata.bind"] = "/mspp_webpages($parentPageId)"
    }

    try {
        $webFileJson = $webFile | ConvertTo-JSon

        if ($existingFiles.value.Count -gt 0) {
            Write-Host "Web file already exists: $filePath"
            $existingFile = $existingFiles.value | Select-Object -First 1
            $updateUrl = $apiUrl + "mspp_webfiles(" + $existingFile.mspp_webfileid + ")"
            Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webFileJson -Headers $headers -ContentType "application/json"
            $webFileId = $existingFile.mspp_webfileid
        } else {
            $webFileResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_webfiles") -Headers $headers -Method Post -Body $webFileJson -ContentType "application/json"
            $webFileId = $webFileResponse.mspp_webfileid

            if (-not $webFileId) {
                Write-Error "Failed to create web file for $fileName"
                return
            }
        }

        $annotationData = @{
            "objectid_mspp_webfile@odata.bind" = "/mspp_webfiles($webFileId)"
            "subject" = "Uploaded File"
            "filename" = $fileName
            "mimetype" = $mimeType
            "documentbody" = $fileContent
        } | ConvertTo-Json

      #  Invoke-RestMethod -Uri ($apiUrl + "annotations") -Method Post -Body ($annotationData | ConvertTo-Json -Depth 10) -Headers $headers -ContentType "application/json"

    } catch {
        Write-Error "API call failed with $_.Exception.Message"
    }
}

function Get-RelativePath {
    param (
        [string]$basePath,
        [string]$targetPath
    )

    $basePath = [System.IO.Path]::GetFullPath($basePath)
    $targetPath = [System.IO.Path]::GetFullPath($targetPath)

    if ($targetPath.StartsWith($basePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $targetPath.Substring($basePath.Length)
        if ($relativePath.StartsWith("\", [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $relativePath.Substring(1)
        }
        return $relativePath.Replace("\", "/")
    }
    else {
        return $targetPath
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
            if ($null -eq $parentPageId) {
                $parentPageId = $homePageId
            }
            CreateWebFile -filePath $item.FullName -parentPageId $parentPageId         
        } else {
            # Process directories
            $newPageId = CreateWebPage -name $item.Name -parentPageId $parentPageId
            WriteHierarchy -path $item.FullName -indent ("  " + $indent) -parentPageId $newPageId
        }
    }
}

# Helpers

function DeleteNonRootWebPages {
    $queryUrl = $apiUrl + "mspp_webpages?\$filter=" + ("mspp_isroot eq false and _mspp_websiteid_value" + " eq '$websiteId'")
    try {
        $webPages = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers
        foreach ($webPage in $webPages.value) {
            $deleteUrl = $apiUrl + "mspp_webpages(" + $webPage.mspp_webpageid + ")"
            Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
            Write-Host "Deleted web page: $($webPage | Select-Object -ExpandProperty $(ApplyPrefix("mspp_name")))"
        }
    } catch {
        Write-Error "Error in deleting non-root web pages: $_"
    }
}



function DeleteTodaysMsppWebFiles {
    $today = (Get-Date).Date
    $tomorrow = $today.AddDays(1)

    # Format dates for OData query
    $todayString = $today.ToString("yyyy-MM-ddT00:00:00Z") # Format adjusted here
    $tomorrowString = $tomorrow.ToString("yyyy-MM-ddT00:00:00Z") # Format adjusted here

    # Query to get webfiles created today
    $queryUrl = $apiUrl + "mspp_webfiles?`$filter=mspp_createdon ge $todayString and mspp_createdon lt $tomorrowString"
    
    try {
        $webFilesToday = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $headers
        foreach ($webFile in $webFilesToday.value) {
            $webFileId = $webFile.mspp_webfileid
            $deleteUrl = $apiUrl + "mspp_webfiles($webFileId)"
            Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers
            Write-Host "Deleted web file: $webFileId"
        }
        Write-Host "All web files created today have been deleted."
    } catch {
        Write-Error "An error occurred: $_.Exception.Message"
    }
}



function FetchSampleMsppWebFiles {
    $queryUrl = $apiUrl + 'mspp_webfiles?$select=mspp_name' # Corrected query
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


#DeleteNonRootWebPages
# FetchSampleMsppWebFiles
# Call the function
# DeleteTodaysMsppWebFiles

Function DeleteAnnotations($webfileId) {
    $annotationsUrl = "annotations"
    $annotationsQuery = "?`$filter=_objectid_value eq $webfileId and filename ne null&`$orderby=createdon desc"
    
    $response = $httpClient.GetAsync("$annotationsUrl$annotationsQuery").Result
    if ($response.IsSuccessStatusCode) {
        $annotations = $response.Content.ReadAsAsync([PSCustomObject[]]).Result

        # Keep track of the latest annotation with an attachment
        $latestAnnotationWithAttachment = $null

        # Loop through annotations and delete
        foreach ($annotation in $annotations) {
            if ($null -eq $latestAnnotationWithAttachment -and $null -ne $annotation.filename) {
                # Keep the first annotation with an attachment as the latest
                $latestAnnotationWithAttachment = $annotation
            } else {
                # Delete other annotations
                $annotationId = $annotation.annotationid
                $deleteResponse = $httpClient.DeleteAsync("$annotationsUrl($annotationId)").Result
                if ($deleteResponse.IsSuccessStatusCode) {
                    Write-Host "Deleted annotation with ID: $annotationId"
                } else {
                    Write-Host "Failed to delete annotation with ID: $annotationId"
                }
            }
        }
    } else {
        Write-Host "Failed to retrieve annotations for webfile with ID: $webfileId"
    }
}

Function PurgeDubAnnocations {
    # Query and delete annotations for each webfile
$webfilesUrl = "adx_webfiles"
$webfilesQuery = "?`$select=adx_webfileid"
$response = $httpClient.GetAsync("$webfilesUrl$webfilesQuery").Result

if ($response.IsSuccessStatusCode) {
    $webfiles = $response.Content.ReadAsAsync([PSCustomObject[]]).Result

    foreach ($webfile in $webfiles) {
        $webfileId = $webfile.adx_webfileid
        Write-Host "Processing webfile with ID: $webfileId"
        DeleteAnnotations $webfileId
    }
} else {
    Write-Host "Failed to retrieve webfiles"
}
}

# Extract the zip file &  runtime script calls
$zipFilePath = "C:\Users\Fred\source\repos\pub\Public\files\themes-dist-14.1.0-gcweb.zip"
$extractionPath = "C:\Users\Fred\source\repos\pub\Public\files"
Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force

# Start processing the extracted folder
Write-Host $extractionPath
WriteHierarchy -path ($extractionPath + "\themes-dist-14.1.0-gcweb")



## SETUP POST THEME INSTALL ##
function CreateCustomHeader {

}

function CreateCustomFooter {

}

function UpdateHomePage {

}

function CreateStyleGuidePage {

}

#### wizard feature pre-requisites
function CreateWizardWebTemplates {
    # create based on files/liquid
}
function CreateWizardPageTemplate {
    # include the update only, the insert should simply use the standardtemplate
}
#### wizard feature set up end ########

#### create example wizard form
function CreateSampleWizardForm {
    # call the helper methods below
}

function CreateSampleWizardPageCreate {
    # use a form for oob table with insert (so create basic form with insert) then create web page and associate default page tempalte and the basic form
    # make sure the basic form has redirect to first step
}
function CreateSampleWizardPageEdit {
    # once all pages are created, make sure to create the web link set for these
}

function CreateSampleWeblinkSetWizard {
    # create all wiziard pages before this - so this s/b called in a callback for the wizard web page creates.
}
## END SETUP POST THEME INSTALL ##