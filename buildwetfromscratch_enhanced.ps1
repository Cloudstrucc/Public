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
        Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webPageJson -Headers $headers -ContentType "application/json; charset=utf-8"
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
            Invoke-RestMethod -Uri $updateUrl -Method Patch -Body $webFileJson -Headers $headers -ContentType "application/json; charset=utf-8"
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
    $liquidFilePath = "liquid\CS-header.liquid"

# Call the function with the liquid file path
    $htmlString = Get-HTMLStringFromLiquidFile -liquidFilePath $liquidFilePath
    # $htmlString = Get-HTMLString
    # Define the JSON payload for the mspp_webtemplate record
    $webTemplatePayload = @{
        "mspp_name" = "MyWebTemplate4"
        "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
        "mspp_source" = "$htmlString"
    } | ConvertTo-Json



    # Make the request to create the adx_webtemplate record
    $webtresponse = Invoke-RestMethod -Uri ($apiUrl + "mspp_webtemplates") -Method Post -Body $webTemplatePayload -Headers $headers -ContentType "application/json; charset=utf-8"

    # Check the response
    if ($webtresponse -ne $null) {
        Write-Host "mspp_webtemplate created successfully with ID: $($response.adx_webtemplateid)"
    } else {
        Write-Host "Failed to create adx_webtemplate"
    }   
}

function Get-HTMLStringFromLiquidFile {
    param (
        [string]$liquidFilePath
    )

    # Check if the liquid file exists
    if (Test-Path $liquidFilePath -PathType Leaf) {
        # Read the content of the liquid file
        $html = Get-Content -Path $liquidFilePath -Raw
        return $html
    } else {
        Write-Host "Liquid file not found: $liquidFilePath"
        return $null
    }
}

function Get-HTMLString {
    $html = @"
    {% if user %}

    <main class="container" property="mainContentOfPage" resource="#wb-main" typeof="WebPageElement">
      <h1 id="wb-cont" property="name">Services and information - Working examples</h1>
      <div class="wb-prettify all-pre hide wb-init wb-prettify-inited" id="wb-auto-4"></div>
    
      <div class="alert alert-info">
        <p>The following working examples are based on the <a href="gc-srvinfo.html">services and information technical specification</a>. The content and structure of this page might not consistant with the rest of this site.</p>
      </div>
    
      <ul class="list-inline">
        <li><a class="btn btn-primary" href="/reference">Documentation</a></li>
        <li><a class="btn btn-primary" href="https://github.com/wet-boew/GCWeb/issues/new?title=gc-srvinfo">Questions ou commentaires?</a></li>
      </ul>
    
      <h2 id="eg1">Example 1: Doormat links in 2 columns pattern</h2>
      <section class="gc-srvinfo">
        <h2>Services and information</h2>
        <div class="wb-eqht row wb-init wb-eqht-inited" id="wb-auto-5">
          <div class="col-md-6" style="vertical-align: top; min-height: 139px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6" style="vertical-align: top; min-height: 139px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6" style="vertical-align: top; min-height: 139px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6" style="vertical-align: top; min-height: 139px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
        </div>
      </section>
      <h3>Code</h3>
      <pre class="prettyprint prettyprinted" style=""><code><span class="pln">
    </span><span class="tag">&lt;section</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"gc-srvinfo"</span><span class="tag">&gt;</span><span class="pln">
        </span><span class="tag">&lt;h2&gt;</span><span class="pln">Services and information</span><span class="tag">&lt;/h2&gt;</span><span class="pln">
            </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"wb-eqht row"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6"</span><span class="tag">&gt;</span><span class="pln">
                </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
                </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
            </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6"</span><span class="tag">&gt;</span><span class="pln">
                </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
                </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
            </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6"</span><span class="tag">&gt;</span><span class="pln">
                </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
                </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
            </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6"</span><span class="tag">&gt;</span><span class="pln">
                </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
                </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
            </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
    </span><span class="tag">&lt;/section&gt;</span></code></pre>
      <h2 id="eg2">Example 2: <strong>Doormat links in single column pattern</strong></h2>
      <section class="gc-srvinfo">
        <h2>Services and information</h2>
        <h3><a href="#">[Subtopic hyperlink text]</a></h3>
        <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
        <h3><a href="#">[Subtopic hyperlink text]</a></h3>
        <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
        <h3><a href="#">[Subtopic hyperlink text]</a></h3>
        <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
      </section>
      <h3>Code</h3>
      <pre class="prettyprint prettyprinted" style=""><code><span class="pln">
    </span><span class="tag">&lt;section</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"gc-srvinfo"</span><span class="tag">&gt;</span><span class="pln">
        </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
        </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
        </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
        </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;</span><span class="pln">
    </span><span class="tag">&lt;/section&gt;</span></code></pre>
      <h2 id="eg3">Example 3: Sequential doormat links in single column pattern</h2>
      <section class="gc-srvinfo">
        <h2>Services and information</h2>
        <ol>
          <li>
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </li>
          <li>
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </li>
          <li>
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </li>
        </ol>
      </section>
      <h3>Code</h3>
      <pre class="prettyprint prettyprinted" style=""><code><span class="pln">
    </span><span class="tag">&lt;section</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"gc-srvinfo"</span><span class="tag">&gt;</span><span class="pln">
    </span><span class="tag">&lt;h2&gt;</span><span class="pln">Services and information</span><span class="tag">&lt;/h2&gt;</span><span class="pln">
    </span><span class="tag">&lt;ol&gt;</span><span class="pln">
        </span><span class="tag">&lt;li&gt;&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;&lt;/li&gt;</span><span class="pln">
        </span><span class="tag">&lt;li&gt;&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;&lt;/li&gt;</span><span class="pln">
        </span><span class="tag">&lt;li&gt;&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</span><span class="tag">&lt;/p&gt;&lt;/li&gt;</span><span class="pln">
    </span><span class="tag">&lt;/ol&gt;</span><span class="pln">
    </span><span class="tag">&lt;/section&gt;</span></code></pre>
      <h2 id="eg4">Example 4:<strong> Doormat links in 3 columns grouped with headings pattern</strong></h2>
      <section class="gc-srvinfo">
        <h2>Services for Canadians in Canada</h2>
        <div class="wb-eqht row wb-init">
          <div class="col-md-6 col-lg-4" style="vertical-align: top; min-height: 165px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6 col-lg-4" style="vertical-align: top; min-height: 165px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6 col-lg-4" style="vertical-align: top; min-height: 165px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
        </div>
      </section>
      <section class="gc-srvinfo">
        <h2>Services for Canadians abroad</h2>
        <div class="wb-eqht row wb-init">
          <div class="col-md-6 col-lg-4" style="vertical-align: top; min-height: 165px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6 col-lg-4" style="vertical-align: top; min-height: 165px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
          <div class="col-md-6 col-lg-4" style="vertical-align: top; min-height: 165px;">
            <h3><a href="#">[Subtopic hyperlink text]</a></h3>
            <p>Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs.</p>
          </div>
        </div>
      </section>
      <h3>Code</h3>
      <pre class="prettyprint prettyprinted" style=""><code><span class="pln">
    </span><span class="tag">&lt;section</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"gc-srvinfo"</span><span class="tag">&gt;</span><span class="pln">
    </span><span class="tag">&lt;h2&gt;</span><span class="pln">Services for Canadians in Canada</span><span class="tag">&lt;/h2&gt;</span><span class="pln">
    </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"wb-eqht row"</span><span class="tag">&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6 col-lg-4"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs. </span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6 col-lg-4"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs. </span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6 col-lg-4"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs. </span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
    </span><span class="tag">&lt;/div&gt;</span><span class="pln">
    </span><span class="tag">&lt;/section&gt;</span><span class="pln">
    </span><span class="tag">&lt;section</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"gc-srvinfo"</span><span class="tag">&gt;</span><span class="pln">
    </span><span class="tag">&lt;h2&gt;</span><span class="pln">Services for Canadians abroad</span><span class="tag">&lt;/h2&gt;</span><span class="pln">
    </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"wb-eqht row"</span><span class="tag">&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6 col-lg-4"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs. </span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6 col-lg-4"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs. </span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
        </span><span class="tag">&lt;div</span><span class="pln"> </span><span class="atn">class</span><span class="pun">=</span><span class="atv">"col-md-6 col-lg-4"</span><span class="tag">&gt;</span><span class="pln">
            </span><span class="tag">&lt;h3&gt;&lt;a</span><span class="pln"> </span><span class="atn">href</span><span class="pun">=</span><span class="atv">"#"</span><span class="tag">&gt;</span><span class="pln">[Subtopic hyperlink text]</span><span class="tag">&lt;/a&gt;&lt;/h3&gt;</span><span class="pln">
            </span><span class="tag">&lt;p&gt;</span><span class="pln">Summary of the information or tasks that can be accomplished on the sub-topic page. Remove prose or promotional messaging. Use action verbs. </span><span class="tag">&lt;/p&gt;</span><span class="pln">
        </span><span class="tag">&lt;/div&gt;</span><span class="pln">
    </span><span class="tag">&lt;/div&gt;</span><span class="pln">
    </span><span class="tag">&lt;/section&gt;</span></code></pre>
    
      <section class="pagedetails">
        <h2 class="wb-inv">Page details</h2>
    
        <div class="row">
          <div class="wb-share col-sm-4 col-md-3 col-sm-push-8 col-md-push-9 wb-init wb-share-inited" data-wb-share='{"lnkClass": "btn btn-default btn-block"}' id="wb-auto-6">
            <section id="shr-pg0" class="shr-pg mfp-hide modal-dialog modal-content overlay-def">
              <header class="modal-header"><h2 class="modal-title">Share this page</h2></header>
              <div class="modal-body">
                <ul class="list-unstyled colcount-xs-2">
                  <li><a href="https://www.blogger.com/blog_this.pyra?t=&amp;u=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;n=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca" class="shr-lnk blogger btn btn-default" rel="noreferrer noopener">Blogger</a></li>
                  <li><a href="https://www.diigo.com/post?url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;title=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca" class="shr-lnk diigo btn btn-default" rel="noreferrer noopener">Diigo</a></li>
                  <li><a href="mailto:?subject=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca&amp;body=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html%0A" class="shr-lnk email btn btn-default" rel="noreferrer noopener">Email</a></li>
                  <li><a href="https://www.facebook.com/sharer.php?u=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;t=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca" class="shr-lnk facebook btn btn-default" rel="noreferrer noopener">Facebook</a></li>
                  <li><a href="https://mail.google.com/mail/?view=cm&amp;fs=1&amp;tf=1&amp;to=&amp;su=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca&amp;body=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html%0A" class="shr-lnk gmail btn btn-default" rel="noreferrer noopener">Gmail</a></li>
                  <li><a href="https://www.linkedin.com/shareArticle?mini=true&amp;url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;title=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca&amp;ro=false&amp;summary=&amp;source=" class="shr-lnk linkedin btn btn-default" rel="noreferrer noopener">LinkedIn®</a></li>
                  <li><a href="https://www.myspace.com/Modules/PostTo/Pages/?u=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;t=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca" class="shr-lnk myspace btn btn-default" rel="noreferrer noopener">MySpace</a></li>
                  <li><a href="https://www.pinterest.com/pin/create/button/?url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;media=&amp;description=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca" class="shr-lnk pinterest btn btn-default" rel="noreferrer noopener">Pinterest</a></li>
                  <li><a href="https://reddit.com/submit?url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;title=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca" class="shr-lnk reddit btn btn-default" rel="noreferrer noopener">reddit</a></li>
                  <li><a href="https://tinyurl.com/create.php?url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html" class="shr-lnk tinyurl btn btn-default" rel="noreferrer noopener">TinyURL</a></li>
                  <li><a href="https://www.tumblr.com/share/link?url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html&amp;name=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca&amp;description=" class="shr-lnk tumblr btn btn-default" rel="noreferrer noopener">tumblr</a></li>
                  <li><a href="https://twitter.com/intent/tweet?text=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca&amp;url=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html" class="shr-lnk twitter btn btn-default" rel="noreferrer noopener">Twitter</a></li>
                  <li><a href="https://api.whatsapp.com/send?text=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca%0A%0Ahttps%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html" class="shr-lnk whatsapp btn btn-default" rel="noreferrer noopener">Whatsapp</a></li>
                  <li><a href="https://compose.mail.yahoo.com/?to=&amp;subject=Services%20and%20information%20-%20Working%20examples%20-%20Canada.ca&amp;body=https%3A%2F%2Fwet-boew.github.io%2FGCWeb%2Fcomponents%2Fgc-servinfo%2Fgc-srvinfo-examples.html%0A" class="shr-lnk yahoomail btn btn-default" rel="noreferrer noopener">Yahoo! Mail</a></li>
                </ul>
                <p class="col-sm-12 shr-dscl">No endorsement of any products or services is expressed or implied.</p>
                <div class="clearfix"></div>
              </div>
            </section>
            <a href="#shr-pg0" aria-controls="shr-pg0" class="shr-opn wb-lbx btn btn-default btn-block wb-lbx-inited wb-init" id="wb-auto-7"><span class="glyphicon glyphicon-share"></span>Share this page</a>
          </div>
          <div class="col-sm-6 col-md-5 col-lg-4 col-sm-pull-4 col-md-pull-3">
            <dl id="wb-dtmd">
              <dt>Date modified:</dt>
              <dd><time property="dateModified">2019-01-16</time></dd>
            </dl>
          </div>
        </div>
      </section>
    </main>
    
    <div id="iacs5gg" class="row sectionBlockLayout text-left" style="display: flex; flex-wrap: wrap; margin: 0px; min-height: auto; padding: 8px;">
      <div class="container" id="igxbayg" style="padding: 0px; display: flex; flex-wrap: wrap;"><div class="col-md-12 columnBlockLayout" style="flex-grow: 1; display: flex; flex-direction: column; min-width: 250px; word-break: break-word;"></div></div>
    </div>
    
    {% else %}
    
    <main property="mainContentOfPage" resource="#wb-main" typeof="WebPageElement">
      <div class="bg-primary text-white" style="background-color:#284162; padding-top: 40px; padding-bottom: 40px;">
      <div class="container">
        <div class="row">
          <div class="col-12">
            <h1 style="border-bottom: 3px solid red; display: inline-block; padding-bottom: 10px;">{{ snippets['CS/HOME/TITLE'] }}</h1>
            <p class="lead" style="font-size: 2rem;">{{ snippets['CS/HOME/SUBTITLE'] }}</p>
            <p>{{ snippets['CS/HOME/DESC'] }}</p>
     <a href="/Account/Login" class="btn btn-light mr-2" style="margin-top: 20px; background-color: #fff; color: #284162; border-radius: 0;">Create an account</a>
            <a href="/Account/SignIn" class="btn btn-outline-light" style="margin-top: 20px; color: #fff; border-color: #fff; border-radius: 0;">Sign in</a>
          </div>
        </div>
      </div>
    </div>
      <section class="home-most-requested well well-sm brdr-0">
        <div class="container">
          <h2 class="mrgn-tp-md">Most requested</h2>
          <ul id="wb-auto-6" class="wb-eqht list-unstyled mrgn-tp-md mrgn-bttm-sm lst-spcd-2 list-responsive wb-init wb-eqht-inited">
            <li id="i5gf7yy" style="vertical-align: top; min-height: 27px;"><a href="https://www.canada.ca/en/government/sign-in-online-account.html">Login to an account</a></li>
            <li id="ilexezm" style="vertical-align: top; min-height: 27px;"><a href="https://www.canada.ca/en/services/benefits/ei.html">Employment Insurance and leave</a></li>
            <li id="ixrr2cg" style="vertical-align: top; min-height: 27px;"><a href="https://www.canada.ca/en/services/benefits/publicpensions.html">Public pensions (CPP and OAS)</a></li>
            <li id="iia0fq5" style="vertical-align: top; min-height: 27px;"><a href="https://www.canada.ca/en/immigration-refugees-citizenship/services/canadian-passports.html">Get a passport</a></li>
            <li id="isy1gsz" style="vertical-align: top; min-height: 27px;"><a href="https://weather.gc.ca/canada_e.html">Weather</a></li>
            <li id="i5nlhel" style="vertical-align: top; min-height: 27px;"><a href="https://www.canada.ca/en/government/grants-funding.html">Grants and funding</a></li>
            <li id="ijnx0xh" style="vertical-align: top; min-height: 27px;"><a href="https://www.canada.ca/en/government/change-address.html">Change your address</a></li>
            <li id="i76sdmq" style="vertical-align: top; min-height: 27px;"><a href="http://www.healthycanadians.gc.ca/recall-alert-rappel-avis/index-eng.php">Product recalls and alerts</a></li>
          </ul>
        </div>
      </section>
      <section class="gc-srvinfo container">
        <h2 class="wb-inv">Services and information</h2>
        <div class="wb-eqht row wb-init">
          <div class="col-lg-4 col-md-6" id="i0lc2x8" style="vertical-align: top; min-height: 114px;">
            <h3><a href="{{ sitemarkers['Search'].url }}">Jobs</a></h3>
            <p>Find a job, training, hiring programs, work permits, Social Insurance Number (SIN)</p>
          </div>
          <div class="col-lg-4 col-md-6" id="ixrj3di" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/immigration-citizenship.html">Immigration and citizenship</a></h3>
            <p>Visit, work, study, immigrate, refugees, permanant residents, apply, check status</p>
          </div>
          <div class="col-lg-4 col-md-6" id="isf4ogu" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://travel.gc.ca">Travel and tourism</a></h3>
            <p>In Canada or abroad, advice, advisories, passports, visit Canada, events, attractions</p>
          </div>
          <div class="col-lg-4 col-md-6" id="i4puu2k" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/business.html">Business and industry</a></h3>
            <p>Starting a business, permits, copyright, business support, selling to government</p>
          </div>
          <div class="col-lg-4 col-md-6" id="i7b1rio" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/benefits.html">Benefits</a></h3>
            <p>EI, family and sickness leave, pensions, housing, student aid, disabilities</p>
          </div>
          <div class="col-lg-4 col-md-6" id="iwr1fhc" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/health.html">Health</a></h3>
            <p>Food, nutrition, diseases, vaccines, drugs, product safety and recalls</p>
          </div>
          <div class="col-lg-4 col-md-6" id="i1twirb" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/taxes.html">Taxes</a></h3>
            <p>Income tax, payroll, GST/HST, contribution limits, tax credits, charities</p>
          </div>
          <div class="col-lg-4 col-md-6" id="ia9ot4x" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/environment.html">Environment and natural resources</a></h3>
            <p>Weather, climate, agriculture, wildlife, pollution, conservation, fisheries</p>
          </div>
          <div class="col-lg-4 col-md-6" id="i19tz7z" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/defence.html">National security and defence</a></h3>
            <p>Military, transportation and cyber security, securing the border, counter-terrorism</p>
          </div>
          <div class="col-lg-4 col-md-6" id="i3opbdq" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/culture.html">Culture, history and sport</a></h3>
            <p>Arts, media, heritage, official languages, national identity and funding</p>
          </div>
          <div class="col-lg-4 col-md-6" id="irps1bg" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/policing.html">Policing, justice and emergencies</a></h3>
            <p>Safety, justice system, prepare for emergencies, services for victims of crime</p>
          </div>
          <div class="col-lg-4 col-md-6" id="ibvmw1c" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/transport.html">Transport and infrastructure</a></h3>
            <p>Aviation, marine, road, rail, dangerous goods, infrastructure projects</p>
          </div>
          <div class="col-lg-4 col-md-6" id="i8uobst" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://international.gc.ca/world-monde/index.aspx?lang=eng">Canada and the world</a></h3>
            <p>Foreign policy, trade agreements, development work, global issues</p>
          </div>
          <div class="col-lg-4 col-md-6" id="ioni1b2" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/finance.html">Money and finances</a></h3>
            <p>Personal finance, credit reports, fraud protection, paying for education</p>
          </div>
          <div class="col-lg-4 col-md-6" id="iyoizsg" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/science.html">Science and innovation</a></h3>
            <p>Scientific research on health, environment and space, grants and funding</p>
          </div>
        </div>
      </section>
      <section class="gc-srvinfo container mrgn-bttm-lg">
        <h2>Focus on</h2>
        <div class="wb-eqht row wb-init">
          <div class="col-lg-4 col-md-6" id="igodoki" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.aadnc-aandc.gc.ca/eng/1461766373625/1461766394598">Indigenous peoples</a></h3>
            <p>Programs and services for First Nations, Inuit and Métis</p>
          </div>
          <div class="col-lg-4 col-md-6" id="ihnz1td" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/veterans.html">Veterans</a></h3>
            <p>Services for current and former military, <abbr title="Royal Canadian Mounted Police">RCMP</abbr> and their families</p>
          </div>
          <div class="col-lg-4 col-md-6" id="ico48zf" style="vertical-align: top; min-height: 114px;">
            <h3><a href="https://www.canada.ca/en/services/youth.html">Youth</a></h3>
            <p>Programs and services for teenagers and young adults</p>
          </div>
        </div>
      </section>
      <section class="home-your-gov well well-bold well-sm brdr-0">
        <div class="container">
          <h2>Your government</h2>
          <div class="row mrgn-bttm-lg">
            <div class="col-lg-7 col-xs-12 col-md-6">
              <ul class="row wb-eqht-grd list-unstyled small">
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://www.canada.ca/en/contact.html">Contact us</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://www.canada.ca/en/news.html">News</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://pm.gc.ca/en">Prime Minister</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://www.canada.ca/en/government/dept.html">Departments and agencies</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://www.canada.ca/en/government/system.html">About government</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://open.canada.ca/en">Open government and data</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://www.canada.ca/en/government/publicservice.html">Working for the government</a></li>
                <li class="col-xs-12 col-sm-6 mrgn-tp-sm mrgn-bttm-sm"><a href="https://www.canada.ca/en/government/system/laws.html">Treaties, laws and regulations</a></li>
              </ul>
            </div>
          </div>
        </div>
      </section>
      <section class="container gc-features">
        <h2>Government initiatives</h2>
        <div class="row wb-eqht wb-init">
          <div class="col-sm-6">
            <div class="well well-sm brdr-rds-0 eqht-trgt" id="ibuw016" style="vertical-align: top; min-height: 314px;">
              <img src="../../components/gc-features/img/initiative-520x200.png" alt="" class="img-responsive full-width" />
              <h3 class="h5"><a href="#" class="stretched-link">[Feature hyperlink text]</a></h3>
              <p>Brief description of the feature being promoted.</p>
            </div>
          </div>
          <div class="col-sm-6">
            <div class="well well-sm brdr-rds-0 eqht-trgt" id="iadzdlk" style="vertical-align: top; min-height: 314px;">
              <img src="../../components/gc-features/img/initiative-520x200.png" alt="" class="img-responsive full-width" />
              <h3 class="h5"><a href="#" class="stretched-link">[Feature hyperlink text]</a></h3>
              <p>Brief description of the feature being promoted.</p>
            </div>
          </div>
        </div>
      </section>
      <section class="pagedetails container">
        <h2 class="wb-inv">Page details</h2>
        <div class="row">
          <div class="col-xs-12">
            <dl id="wb-dtmd">
              <dt>Date modified:</dt>
              <dd><time property="dateModified">2021-07-07</time></dd>
            </dl>
          </div>
        </div>
      </section>
    </main>
    <div id="ismkcwc" class="row sectionBlockLayout text-left" style="display: flex; flex-wrap: wrap; margin: 0px; min-height: auto; padding: 8px;">
      <div class="container" id="isvvdva" style="padding: 0px; display: flex; flex-wrap: wrap;"><div class="col-md-12 columnBlockLayout" style="flex-grow: 1; display: flex; flex-direction: column; min-width: 250px; word-break: break-word;"></div></div>
    </div>
    {% endif %}
    
"@
    return $html
}

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



# Extract the zip file &  runtime script calls
$zipFilePath = "C:\themes-dist-14.1.0-gcweb.zip"
$extractionPath = "C:\Users\Fred\source\repos\pub\Public\files\themes-dist-14.1.0-gcweb" 
# Expand-Archive -Path $zipFilePath -DestinationPath $extractionPath -Force

# Start processing the extracted folder
#Write-Host $extractionPath
#WriteHierarchy -path $extractionPath -parentPageId $homePageId
CreateWebTemplate

## END SETUP POST THEME INSTALL ##