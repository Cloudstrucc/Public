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
    `"blobAddress`" = `"<blob address>`"
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
$englishLanguageId = '20f6128a-d758-4de0-88df-6201e6ccd8b6'
$frenchLanguageId = '20f6128a-d758-4de0-88df-6201e6ccd8b6'

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
        Write-Host "Page Name: $name, Parent Page ID: $parentPageId, Is Home Page: $isHomePage"
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
        "mspp_parentpageid@odata.bind" = "/mspp_webpages($parentPageId)"
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
        Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPageJson -Headers $updateHeaders -ContentType "application/json; charset=utf-8"
        return $existingPage.mspp_webpageid
    } else {
        try {
            $webPageResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_webpages") -Method Post -Body $webPageJson -Headers $headers -ContentType "application/json; charset=utf-8"
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
            Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webFileJson -Headers $updateHeaders -ContentType "application/json; charset=utf-8"
            $webFileId = $existingFile.mspp_webfileid
        } else {
            $webFileResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_webfiles") -Headers $headers -Method Post -Body $webFileJson -ContentType "application/json; charset=utf-8"
            $webFileId = $webFileResponse.mspp_webfileid

            if (-not $webFileId) {
                Write-Error "Failed to create web file for $fileName"
                return
            }
        }

        $existingRow = Invoke-RestMethod -Uri ($apiUrl + "powerpagecomponents($webFileId)") -Method Get -Headers $headers

        Write-Host "File Name: $($existingRow.name)"
        $existingRow = @{
            "powerpagecomponentid" = $existingRow.powerpagecomponentid
            "name" = $existingRow.name
            "filecontent" = $fileContent
        } | ConvertTo-Json

        # Set this to the url, of your automation, which places the file
        $apiUrl = "https://prod-16.canadacentral.logic.azure.com:443/workflows/d0266af9e24b457e81d042e204f1c990/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=cnCrDBP18LAb40X3H7E_dtydKWbGK9GpdL0tK68_z8s"
       
        Invoke-WebRequest -Uri $apiUrl -Method Post -Body $existingRow -ContentType "application/json; charset=utf-8"

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
            #Process files
            
            if ($null -eq $parentPageId) {
                $parentPageId = $homePageId
            }
            Write-Host "IS NOT FOLDER + $parentPageId + $item"
            CreateWebFile -filePath $item.FullName -parentPageId $parentPageId 
                   
        } else {
            # Process directoriesY
            Write-Host "IS FOLDER + $parentPageId + $item"
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

function CreateWebTemplate {
    param (       
        [string]$markup = "",
        [string]$filename = ""
    )
   

    $htmlString = $markup

    $webTemplatePayload = @{
        "mspp_name" = $filename
        "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
        "mspp_source" = "$htmlString"
    } | ConvertTo-Json
    

    $filter = "mspp_name eq '$filename'"
    $checkWebTemplateExists = $apiUrl + "mspp_webtemplates?" + "`$filter=$filter"
    $existingTemplates = Invoke-RestMethod -Uri $checkWebTemplateExists -Method Get -Headers $headers -ContentType "application/json; charset=utf-8"
    if ($existingTemplates.value.Count -gt 0) {
        Write-Host "Web template already exists: $filename"

        $existingTemplate = $existingTemplates.value[0]  # Access first item in the array
        Write-Host $existingTemplate
        # Check if 'mspp_webtemplateid' property exists in the existing template
        if ($existingTemplate.PSObject.Properties["mspp_webtemplateid"]) {
        
            # $existingTemplate = $existingTemplates.value | Select-Object -First 1
            $updateUrl = $apiUrl + "mspp_webtemplates(" + $existingTemplate.mspp_webtemplateid + ")"
            
            Write-Host "$updateUrl"
            $webTemplatePayloadUpdate = @{
                "mspp_source" = $htmlString
            } | ConvertTo-Json
            $webtresponse = Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webTemplatePayloadUpdate -Headers $updateHeaders -ContentType "application/json; charset=utf-8;"
            # -ContentType "application/json; charset=utf-8"
            if ($webtresponse -ne $null) {
                Write-Host "mspp_webtemplate UPDATED successfully with ID: $($response.mspp_webtemplateid)"
            } else {
                Write-Host "Failed to UPDATE mspp_webtemplate"
            }  
            $webtemplatedid = $existingTemplate.mspp_webtemplateid
        }
        
    } else {
            # Make the request to create the mspp_webtemplate record
            $webresponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_webtemplates") -Method Post -Body $webTemplatePayload -Headers $headers -ContentType "application/json; charset=utf-8"

            # Check the response
            if ($webresponse -ne $null) {
                Write-Host "mspp_webtemplate created successfully with ID: $($webresponse.mspp_webtemplateid)"
                $pageTemplateId = $webresponse.mspp_webtemplateid
                $pageTemplatePayload = @{
                    "mspp_name" = $filename
                    "mspp_type" = "756150001"
                    "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
                    "mspp_webtemplateid@odata.bind" = "/mspp_webtemplates($pageTemplateId)"
                } | ConvertTo-Json
                $pageTemplateResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_pagetemplates") -Method Post -Body $pageTemplatePayload -Headers $headers -ContentType "application/json; charset=utf-8"
            } else {
                Write-Host "Failed to create mspp_webtemplate"
            }  
    }
    
}

function CreateSnippets {

    # Read snippet content from the JSON file
    $jsonFilePath = "C:\Users\Fred\source\repos\pub\Public\liquid\contentsnippets\snippets.json"
    $snippetsJson = Get-Content $jsonFilePath | ConvertFrom-Json
    
    # Iterate through each entry in the JSON object
    foreach ($entry in $snippetsJson.PSObject.Properties) {
        $snippetName = $entry.Name
        $snippetContentEnglish = $entry.Value[0]
        $snippetContentFrench = $entry.Value[1]
        # Define the JSON payload for the mspp_contentsnippet record
        $snippetPayloadEnglish = @{
            "mspp_name" = $snippetName
            "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
            "mspp_value" = $snippetContentEnglish
            "mspp_contentsnippetlanguageid@odata.bind"= "/mspp_websitelanguages($englishLanguageId)"
        } | ConvertTo-Json
        $snippetPayloadFrench = @{
            "mspp_name" = $snippetName
            "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
            "mspp_value" = $snippetContentFrench
            "mspp_contentsnippetlanguageid@odata.bind"= "/mspp_websitelanguages($frenchLanguageId)"
        } | ConvertTo-Json

        # Check if the snippet already exists
        # $filter = "mspp_name eq '$snippetName' and _contentsnippetlanguageid_value eq $englishLanguageId"
        $filter = "(mspp_name eq '$snippetName' and _mspp_contentsnippetlanguageid_value eq $englishLanguageId) or (mspp_name eq '$snippetName' and _mspp_contentsnippetlanguageid_value eq $frenchLanguageId)"

        $checkSnippetExists = $apiUrl + "mspp_contentsnippets?" + "`$filter=$filter"
        $existingSnippets = Invoke-RestMethod -Uri $checkSnippetExists -Method Get -Headers $headers -ContentType "application/json; charset=utf-8"

        if ($existingSnippets.value.Count -gt 0) {
            Write-Host "Snippet already exists: $snippetName"
            $existingSnippet = $existingSnippets.value[0]  # Access first item in the array

            # Check if 'mspp_contentsnippetid' property exists in the existing snippet
            if ($existingSnippet.PSObject.Properties["mspp_contentsnippetid"]) {
                $updateUrl = $apiUrl + "mspp_contentsnippets(" + $existingSnippet.mspp_contentsnippetid + ")"
               

                # Perform PATCH request to update the snippet
                $snippetResponse = Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $snippetPayloadEnglish -Headers $updateHeaders -ContentType "application/json; charset=utf-8"

                if ($snippetResponse -ne $null) {
                    Write-Host "Snippet UPDATED successfully with ID: $($existingSnippet.mspp_contentsnippetid)"
                } else {
                    Write-Host "Failed to UPDATE snippet"
                }
            }
        } else {
            # Make the request to create the snippet record
            $snippetResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_contentsnippets") -Method Post -Body $snippetPayloadEnglish -Headers $headers -ContentType "application/json; charset=utf-8"

            # Check the response
            if ($snippetResponse -ne $null) {
                Write-Host "Snippet created successfully with ID: $($snippetResponse.mspp_contentsnippetid)"
            } else {
                Write-Host "Failed to create snippet"
            }
        }
    }
}


function Write-Templates {
    param (
        [string]$folderPath,
        [string]$indent = ""
    )

    # Get child folders and files
    $folders = Get-ChildItem -Path $folderPath
    $files = Get-ChildItem -Path $folderPath -File

    # Write folder name
    Write-Host "${indent}Folder: $($folderPath | Split-Path -Leaf)"
    
    # Write content of files in the current folder
    foreach ($file in $files) {
        Write-Host "${indent}  File: $($file.Name.Substring(0, $file.Name.LastIndexOf('.')))"
        $html = Get-Content -Path $file.FullName 
        CreateWebTemplate -filename $file.Name.Substring(0, $file.Name.LastIndexOf('.')) -markup "${html} $_ "
        
       
    }
           
}

## SETUP POST THEME INSTALL ##
function CreateCustomHeader {

}

function CreateCustomFooter {

}

function UpdateHomePage {
    param (
        [string]$pageTemplateName,
        [string]$indent = ""
    )

    $filter = "mspp_name eq '$pageTemplateName'"
    $checkPageTemplateExists = $apiUrl + "mspp_pagetemplates?" + "`$filter=$filter"
    $existingTemplates = Invoke-RestMethod -Uri $checkPageTemplateExists -Method Get -Headers $headers -ContentType "application/json; charset=utf-8"
    
   

    if ($existingTemplates.value.Count -gt 0) {
        Write-Host "Page template exists: $filename"

        $existingTemplate = $existingTemplates.value[0]  # Access first item in the array
        Write-Host $existingTemplate
        $pageTemplateId = $existingTemplate.mspp_pagetemplateid
        # Update Home Page
        $updateUrl = $apiUrl + "mspp_webpages(" + $homePageId + ")"
        
        Write-Host "$updateUrl"
        $webPagePayload = @{
            "mspp_pagetemplateid@odata.bind" = "/mspp_pagetemplates($pageTemplateId)"
        } | ConvertTo-Json
        $webPageResponse = Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPagePayload -Headers $updateHeaders -ContentType "application/json; charset=utf-8;"
        # -ContentType "application/json; charset=utf-8"
        if ($webPageResponse -ne $null) {
            Write-Host "mspp_webpage UPDATED successfully"
        } else {
            Write-Host "Failed to UPDATE home page"
        }  
   
        
        
    }
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



function RunPortalTemplateInstall {
    $zipFilePath = "C:\themes-dist-14.1.0-gcweb.zip"
    $extractionPath = "C:\Users\Fred\source\repos\pub\Public\files\themes-dist-14.1.0-gcweb" 
    $rootFolderPath = "C:\Users\Fred\source\repos\pub\Public\liquid\webtemplates"
    Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force
    Write-Host $extractionPath
    WriteHierarchy -path $extractionPath -parentPageId $homePageId
    CreateSnippets
    Write-Templates -folderPath $rootFolderPath
    UpdateHomePage -pageTemplateName "CS-Home-WET"
}

RunPortalTemplateInstall


## END SETUP POST THEME INSTALL ##