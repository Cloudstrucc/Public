### TO DO ###
# UPDATE the breadcrumps webtemplate & the language toggle
##############

#####################################
# GC WET RELEASES: https://github.com/wet-boew/GCWeb/releases
#####################################

$basePath = "C:\Users\Fred\source\repos\pub\Public\"
$basePathSnippets = $basePath + "liquid\contentsnippets\snippets.json"
$portalBasicThemePath = $basePath + "portalbasictheme.css"
$themePath = $basePath + "theme.css"
$bootstrapPath = $basePath + "bootstrap.min.css"
$faviconPath = $basePath + "favicon.ico"
$zipFilePath = "C:\themes-dist-15.0.0-gcweb.zip"
$extractionPath = $basePath + "files\" 
$themeRootFolderName = "themes-dist-15.0.0-gcweb"
$basePathTemplates = $basePath + "liquid\webtemplates"
$pageTemplateNameNewHome = "CS-Home-WET"
$webTemplateHeader = "CS-header"
$webTemplateFooter = "CS-footer"
$englishLanguageCode = 1033  # Example language code for English
$frenchLanguageCode = 1036  # Example language code for French

####################################

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
    `"blobAddress`" = `"<blob address>`"
    `"FlowURL`" = `"<flow URL>`"
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
$blobAddress = $config.blobAddress
$webFileFlowURL = $config.FlowURL

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


function GetPageTemplateID {

    $filter += "_mspp_websiteid_value eq '$websiteId' and mspp_name eq 'Access Denied'"
    # Get Website Language IDs by Language Code
    $pageTemplateQuery = $apiUrl + "mspp_pagetemplates?" + "`$filter=$filter"
    Write-Host $pageTemplateQuery
    $pageTemplate = GetRecordAPI -url $pageTemplateQuery
    $pageTemplateId = $pageTemplate.value[0].mspp_pagetemplateid
    Write-Host "Page Template ID: $pageTemplateId"
    return $pageTemplateId
}

$pageTemplateId = GetPageTemplateID

function GetPublishingStateID {
    $publishedStateName = "Published"   
    $filter += "mspp_name eq '$publishedStateName'"
    $publishingStateQuery = $apiUrl + "mspp_publishingstates?" + "`$filter=$filter"
    Write-Host $publishingStateQuery
    $publishingState = GetRecordAPI -url $publishingStateQuery
    $publishingStateId = $publishingState.value[0].mspp_publishingstateid
    return $publishingStateId
}

$publishingStateId = GetPublishingStateID # $config.publishingStateId

function GetPublishingStateID {
    $publishedStateName = "Published"   
    $filter += "mspp_name eq '$publishedStateName'"
    $publishingStateQuery = $apiUrl + "mspp_publishingstates?" + "`$filter=$filter"
    Write-Host $publishingStateQuery
    $publishingState = GetRecordAPI -url $publishingStateQuery
    $publishingStateId = $publishingState.value[0].mspp_publishingstateid
    return $publishingStateId
}
$publishingStateId = GetPublishingStateID

function GetEnglishLanguageID {

    $filter += "mspp_lcid eq $englishLanguageCode"
    # Get Website Language IDs by Language Code
    $languageQuery = $apiUrl + "mspp_websitelanguages?" + "`$filter=$filter"
    Write-Host $languageQuery
    $englishLanguage = GetRecordAPI -url $languageQuery
    $englishLanguageId = $englishLanguage.value[0].mspp_websitelanguageid
    Write-Host "English Language ID: $englishLanguageId"
    return $englishLanguageId
}
$englishLanguageId = GetEnglishLanguageID
function GetFrenchLanguageID {
    $filter += "mspp_lcid eq $frenchLanguageCode"
    # Get Website Language IDs by Language Code
    $languageQuery = $apiUrl + "mspp_websitelanguages?" + "`$filter=$filter"
    $frenchLanguage = GetRecordAPI -url $languageQuery
    $frenchLanguageId = $frenchLanguage.value[0].mspp_websitelanguageid
    Write-Host "English Language ID: $frenchLanguageId"
    return $frenchLanguageId
}
$frenchLanguageId = GetFrenchLanguageID

function GetRootHomePageID {

    $filter += "_mspp_websiteid_value eq '$websiteId' and mspp_isroot eq true"
    # Get Website Language IDs by Language Code
    $homePageQuery = $apiUrl + "mspp_webpages?" + "`$filter=$filter"
    $homePage = GetRecordAPI -url $homePageQuery
    $homePageId = $homePage.value[0].mspp_webpageid
    Write-Host "Home Web Page ID: $homePageId"
    return $homePageId
}
$homePageId = GetRootHomePageID

function GetEnglishHomePageID {

    $filter += "_mspp_websiteid_value eq '$websiteId' and mspp_name eq 'Home' and _mspp_webpagelanguageid_value eq '$englishLanguageId'"
    # Get Website Language IDs by Language Code
    $homePageQuery = $apiUrl + "mspp_webpages?" + "`$filter=$filter"
    Write-Host $homePageQuery
    $homePage = GetRecordAPI -url $homePageQuery
    $homePageEnId = $homePage.value[0].mspp_webpageid
    Write-Host "EN Home Web Page ID: $homePageEnId"
    return $homePageEnId
}
$homeContentPageEN = GetEnglishHomePageID

function GetFrenchHomePageID {

    $filter += "_mspp_websiteid_value eq '$websiteId' and mspp_name eq 'Home' and _mspp_webpagelanguageid_value eq '$frenchLanguageId'"
    # Get Website Language IDs by Language Code
    $homePageQuery = $apiUrl + "mspp_webpages?" + "`$filter=$filter"
    $homePage = GetRecordAPI -url $homePageQuery
    $homePageFrId = $homePage.value[0].mspp_webpageid
    Write-Host "EN Home Web Page ID: $homePageFrId"
    return $homePageFrId
}
$homeContentPageFR = GetFrenchHomePageID

function UpdateBaselineStyles {
    CreateWebFile -filePath $portalBasicThemePath -parentPageId $homePageId
    CreateWebFile -filePath $themePath -parentPageId $homePageId
    CreateWebFile -filePath $bootstrapPath -parentPageId $homePageId
    CreateWebFile -filePath $faviconPath -parentPageId $homePageId

}
# Function to create or update a web page
function CreateWebPage {
    param (
        [string]$name,
        [string]$parentPageId
    )
    
    # Logic to determine if this is the home page
    # Check the name or ID against known values for the home page
    $isHomePage = $false
    if ($name -eq "$themeRootFolderName" -or $parentPageId -eq $null) {
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
    $relativePath = Get-RelativePath ($extractionPath + "\$themeRootFolderName") $filePath

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
        $apiUrl = $webFileFlowUrl 
       
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
            $wtid = $webresponse.mspp_webtemplateid
            $pageTemplatePayload = @{
                "mspp_name" = $filename
                "mspp_type" = "756150001"
                "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
                "mspp_webtemplateid@odata.bind" = "/mspp_webtemplates($wtid)"
            } | ConvertTo-Json

            Invoke-RestMethod -Uri ($apiUrl + "mspp_pagetemplates") -Method Post -Body $pageTemplatePayload -Headers $headers -ContentType "application/json; charset=utf-8"
            
            # Check the response
            if ($null -ne $webresponse) {
                Write-Host "mspp_webtemplate created successfully with ID: $($webresponse.mspp_webtemplateid)"
                $updateUrlWT = $apiUrl + "mspp_websites(" + $websiteId + ")"
                
               
                Write-Host $updateUrlWT
                if (($filename -eq $webTemplateHeader) -or ($filename -eq $webTemplateFooter)){
                    $templateId = $webresponse.mspp_webtemplateid
                    $templateName = $webresponse.mspp_name
                    $webTemplateLookupName = "mspp_headerwebtemplateid@odata.bind"
                    if ($templateName -eq $webTemplateHeader) {
                        $webTemplateLookupName = "mspp_headerwebtemplateid@odata.bind"
                    } else {
                        $webTemplateLookupName = "mspp_footerwebtemplateid@odata.bind"
                    }
                    $websiteRecord = @{                        
                        "$webTemplateLookupName" = "/mspp_webtemplates($templateId)"
                    } | ConvertTo-Json
                    Invoke-RestMethod -Uri $updateUrlWT -Method Patch -Body $websiteRecord -Headers $updateHeaders -ContentType "application/json; charset=utf-8"                   
                } else {
                    $webTemplateId = $webresponse.mspp_webtemplateid

                    $updateUrlWebTemp = $apiUrl + "mspp_webtemplates(" + $webTemplateId + ")"
                    Invoke-RestMethod -Uri $updateUrlWebTemp -Method Patch -Body $webTemplatePayload -Headers $updateHeaders -ContentType "application/json; charset=utf-8"                    
                }                
            } else {
                Write-Host "Failed to create mspp_webtemplate"
            }  
    }
    
}

function CreateSnippets {

    # Read snippet content from the JSON file
    $jsonFilePath = $basePathSnippets
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
                 # Perform PATCH request to update the snippet
                 $snippetResponseFR = Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $snippetPayloadFrench -Headers $updateHeaders -ContentType "application/json; charset=utf-8"

                if ($null -ne $snippetResponse) {
                    Write-Host "Snippet UPDATED successfully with ID: $($existingSnippet.mspp_contentsnippetid)"
                } else {
                    Write-Host "Failed to UPDATE snippet"
                }
                if ($null -ne $snippetResponseFR) {
                    Write-Host "Snippet UPDATED successfully with ID: $($existingSnippet.mspp_contentsnippetid)"
                } else {
                    Write-Host "Failed to UPDATE snippet"
                }
            }
        } else {
            # Make the request to create the snippet record
            $snippetResponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_contentsnippets") -Method Post -Body $snippetPayloadEnglish -Headers $headers -ContentType "application/json; charset=utf-8"

            $snippetResponseFR = Invoke-RestMethod -Uri ($apiUrl + "mspp_contentsnippets") -Method Post -Body $snippetPayloadFrench -Headers $headers -ContentType "application/json; charset=utf-8"

            # Check the response
            if ($null -ne $snippetResponse) {
                Write-Host "Snippet created successfully with ID: $($snippetResponse.mspp_contentsnippetid)"
            } else {
                Write-Host "Failed to create snippet"
            }
            # Check the response
            if ($null -ne $snippetResponseFR) {
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

    # Get child files
    # $folders = Get-ChildItem -Path $folderPath
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
function UpsertCustomHeader {

}

function UpsertCustomFooter {

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
        if ($null -ne $webPageResponse) {
            Write-Host "mspp_webpage UPDATED successfully"
        } else {
            Write-Host "Failed to UPDATE home page"
        }  
        $updateUrlContentEN = $apiUrl + "mspp_webpages(" + $homeContentPageEN + ")"
        $contentPagePayloadEN = @{
            "mspp_copy" = ""
        } | ConvertTo-Json
        Invoke-RestMethod -Uri $updateUrlContentEN -Method Patch -Body $contentPagePayloadEN -Headers $updateHeaders -ContentType "application/json; charset=utf-8;"

        $updateUrlContentFR = $apiUrl + "mspp_webpages(" + $homeContentPageFR + ")"
        $contentPagePayloadFR = @{
            "mspp_copy" = ""
        } | ConvertTo-Json
        Invoke-RestMethod -Uri $updateUrlContentFR -Method Patch -Body $contentPagePayloadFR -Headers $updateHeaders -ContentType "application/json; charset=utf-8;"
   
    }
}

function UpsertStyleGuidePage {

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
    
    Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force
    Write-Host $extractionPath          
    CreateSnippets    
    Write-Templates -folderPath $basePathTemplates
    UpdateHomePage -pageTemplateName $pageTemplateNameNewHome
    WriteHierarchy -path $($extractionPath + $themeRootFolderName) -parentPageId $homePageId 
    UpdateBaselineStyles
}

RunPortalTemplateInstall



## END SETUP POST THEME INSTALL ##