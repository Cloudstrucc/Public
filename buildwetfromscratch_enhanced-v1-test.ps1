# Script configuration
param(
    [string]$ConfigPath = "config.json",
    [switch]$UseJsonConfig
)

# Initialize logging
$LogFile = "script_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param([string]$Message)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" | Out-File -Append -FilePath $LogFile
    Write-Host $Message
}

# Load configuration
function Load-Config {
    if ($UseJsonConfig) {
        if (Test-Path $ConfigPath) {
            $config = Get-Content $ConfigPath | ConvertFrom-Json
        } else {
            Write-Log "Config file not found. Using default values."
            $config = Get-DefaultConfig
        }
    } else {
        $config = Get-DefaultConfig
    }
    return $config
}

function Get-DefaultConfig {
    return @{
        BasePath = "C:\Users\pearsof\repos\Public\"
        ZipFilePath = "C:\Users\pearsof\repos\Public\files\themes-dist-15.2.0-gcweb.zip"
        ExtractionPath = "C:\Users\pearsof\repos\Public\files\"
        ThemeRootFolderName = "themes-dist-15.2.0-gcweb"
        EnglishLanguageCode = 1033
        FrenchLanguageCode = 1036
        PageTemplateNameNewHome = "CS-Home-WET"
        WebTemplateHeader = "CS-header"
        WebTemplateFooter = "CS-footer"
        ClientId = "<client id>"
        TenantId = "<tenant id>"
        CrmInstance = "<crm instance>"
        RedirectUri = "https://login.onmicrosoft.com"
        WebsiteId = "<website id>"
        BlobAddress = "<blob address>"
        FlowURL = "<flow url>"
    }
}

# API functions
function Get-AuthToken {
    param($Config)
    $authority = "https://login.microsoftonline.com/$($Config.TenantId)"
    $resource = "https://$($Config.CrmInstance).api.crm3.dynamics.com"
    $tokenEndpoint = "$authority/oauth2/v2.0/token"
    $body = @{
        client_id     = $Config.ClientId
        scope         = "$resource/.default"
        grant_type    = "client_credentials"
        redirect_uri  = $Config.RedirectUri
        client_secret = $Config.ClientSecret
    }
    $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
    return $authResponse.access_token
}

function Invoke-DataverseApi {
    param(
        [string]$Method,
        [string]$Url,
        [object]$Body,
        [hashtable]$Headers,
        [switch]$UseUpdateHeaders
    )
    try {
        $apiHeaders = if ($UseUpdateHeaders) { $script:updateHeaders } else { $script:headers }
        $response = Invoke-RestMethod -Method $Method -Uri $Url -Body ($Body | ConvertTo-Json -Depth 10) -Headers $apiHeaders -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        Write-Log "API call failed: $_"
        throw
    }
}

# Helper functions
function Get-PageTemplateId {
    param([string]$WebsiteId)
    $filter = "_mspp_websiteid_value eq '$WebsiteId' and mspp_name eq 'Access Denied'"
    $pageTemplateQuery = "$script:apiUrl/mspp_pagetemplates?`$filter=$filter"
    $pageTemplate = Invoke-DataverseApi -Method Get -Url $pageTemplateQuery
    return $pageTemplate.value[0].mspp_pagetemplateid
}

function Get-PublishingStateId {
    $publishedStateName = "Published"
    $filter = "mspp_name eq '$publishedStateName'"
    $publishingStateQuery = "$script:apiUrl/mspp_publishingstates?`$filter=$filter"
    $publishingState = Invoke-DataverseApi -Method Get -Url $publishingStateQuery
    return $publishingState.value[0].mspp_publishingstateid
}

function Get-LanguageId {
    param([int]$LanguageCode)
    $filter = "mspp_lcid eq $LanguageCode"
    $languageQuery = "$script:apiUrl/mspp_websitelanguages?`$filter=$filter"
    $language = Invoke-DataverseApi -Method Get -Url $languageQuery
    return $language.value[0].mspp_websitelanguageid
}

function Get-HomePageId {
    param([string]$WebsiteId, [string]$LanguageId = $null)
    $filter = "_mspp_websiteid_value eq '$WebsiteId' and mspp_name eq 'Home'"
    if ($LanguageId) {
        $filter += " and _mspp_webpagelanguageid_value eq '$LanguageId'"
    } else {
        $filter += " and mspp_isroot eq true"
    }
    $homePageQuery = "$script:apiUrl/mspp_webpages?`$filter=$filter"
    $homePage = Invoke-DataverseApi -Method Get -Url $homePageQuery
    return $homePage.value[0].mspp_webpageid
}

function Update-BaselineStyles {
    param([string]$HomePageId)
    $stylePaths = @($script:config.PortalBasicThemePath, $script:config.ThemePath, $script:config.BootstrapPath, $script:config.FaviconPath)
    foreach ($path in $stylePaths) {
        Create-WebFile -FilePath $path -ParentPageId $HomePageId
    }
}

function Create-WebPage {
    param(
        [string]$Name,
        [string]$ParentPageId,
        [string]$WebsiteId,
        [string]$PageTemplateId,
        [string]$PublishingStateId
    )
    $partialUrl = $Name.ToLower()
    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$WebsiteId'"
    if ($ParentPageId) {
        $filter += " and _mspp_parentpageid_value eq $ParentPageId"
    }
    $checkUrl = "$script:apiUrl/mspp_webpages?`$filter=$filter"
    $existingPages = Invoke-DataverseApi -Method Get -Url $checkUrl

    $webPage = @{
        "mspp_name" = $Name
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($PublishingStateId)"
        "mspp_pagetemplateid@odata.bind" = "/mspp_pagetemplates($PageTemplateId)"
    }
    if ($ParentPageId) {
        $webPage["mspp_parentpageid@odata.bind"] = "/mspp_webpages($ParentPageId)"
    }

    if ($existingPages.value.Count -gt 0) {
        $existingPage = $existingPages.value[0]
        $updateUrl = "$script:apiUrl/mspp_webpages($($existingPage.mspp_webpageid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webPage -UseUpdateHeaders
        return $existingPage.mspp_webpageid
    } else {
        $response = Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_webpages" -Body $webPage
        return $response.mspp_webpageid
    }
}

function Create-WebFile {
    param(
        [string]$FilePath,
        [string]$ParentPageId,
        [string]$WebsiteId,
        [string]$PublishingStateId,
        [string]$BlobAddress
    )
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    $partialUrl = $fileName.Replace(" ", "").ToLower()
    $fileContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($FilePath))
    $relativePath = Get-RelativePath -BasePath $script:config.ExtractionPath -TargetPath $FilePath

    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$WebsiteId'"
    if ($ParentPageId) {
        $filter += " and _mspp_parentpageid_value eq $ParentPageId"
    }
    $checkUrl = "$script:apiUrl/mspp_webfiles?`$filter=$filter"
    $existingFiles = Invoke-DataverseApi -Method Get -Url $checkUrl

    $webFile = @{
        "mspp_name" = $fileName
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($PublishingStateId)"
    }
    if ($ParentPageId) {
        $webFile["mspp_parentpageid@odata.bind"] = "/mspp_webpages($ParentPageId)"
    }

    if ($existingFiles.value.Count -gt 0) {
        $existingFile = $existingFiles.value[0]
        $updateUrl = "$script:apiUrl/mspp_webfiles($($existingFile.mspp_webfileid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webFile -UseUpdateHeaders
        $webFileId = $existingFile.mspp_webfileid
    } else {
        $response = Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_webfiles" -Body $webFile
        $webFileId = $response.mspp_webfileid
    }

    $existingRow = Invoke-DataverseApi -Method Get -Url "$script:apiUrl/powerpagecomponents($webFileId)"
    $fileUpdatePayload = @{
        "powerpagecomponentid" = $existingRow.powerpagecomponentid
        "name" = $existingRow.name
        "filecontent" = $fileContent
    }
    Invoke-RestMethod -Uri $script:config.FlowURL -Method Post -Body ($fileUpdatePayload | ConvertTo-Json) -ContentType "application/json; charset=utf-8"
}

function Get-RelativePath {
    param([string]$BasePath, [string]$TargetPath)
    $BasePath = [System.IO.Path]::GetFullPath($BasePath)
    $TargetPath = [System.IO.Path]::GetFullPath($TargetPath)
    if ($TargetPath.StartsWith($BasePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $TargetPath.Substring($BasePath.Length)
        if ($relativePath.StartsWith("\", [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $relativePath.Substring(1)
        }
        return $relativePath.Replace("\", "/")
    }
    return $TargetPath
}

function Write-Hierarchy {
    param(
        [string]$Path,
        [string]$ParentPageId,
        [string]$WebsiteId,
        [string]$PageTemplateId,
        [string]$PublishingStateId
    )
    $items = Get-ChildItem -Path $Path
    foreach ($item in $items) {
        if (-not $item.PSIsContainer) {
            Create-WebFile -FilePath $item.FullName -ParentPageId $ParentPageId -WebsiteId $WebsiteId -PublishingStateId $PublishingStateId -BlobAddress $script:config.BlobAddress
        } else {
            $newPageId = Create-WebPage -Name $item.Name -ParentPageId $ParentPageId -WebsiteId $WebsiteId -PageTemplateId $PageTemplateId -PublishingStateId $PublishingStateId
            Write-Hierarchy -Path $item.FullName -ParentPageId $newPageId -WebsiteId $WebsiteId -PageTemplateId $PageTemplateId -PublishingStateId $PublishingStateId
        }
    }
}

function Create-WebTemplate {
    param(
        [string]$Markup,
        [string]$Filename,
        [string]$WebsiteId
    )
    $webTemplatePayload = @{
        "mspp_name" = $Filename
        "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
        "mspp_source" = $Markup
    }

    $filter = "mspp_name eq '$Filename'"
    $checkUrl = "$script:apiUrl/mspp_webtemplates?`$filter=$filter"
    $existingTemplates = Invoke-DataverseApi -Method Get -Url $checkUrl

    if ($existingTemplates.value.Count -gt 0) {
        $existingTemplate = $existingTemplates.value[0]
        $updateUrl = "$script:apiUrl/mspp_webtemplates($($existingTemplate.mspp_webtemplateid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body @{ "mspp_source" = $Markup } -UseUpdateHeaders
        $webTemplateId = $existingTemplate.mspp_webtemplateid
    } else {
        $response = Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_webtemplates" -Body $webTemplatePayload
        $webTemplateId = $response.mspp_webtemplateid

        $pageTemplatePayload = @{
            "mspp_name" = $Filename
            "mspp_type" = "756150001"
            "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
            "mspp_webtemplateid@odata.bind" = "/mspp_webtemplates($webTemplateId)"
        }
        Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_pagetemplates" -Body $pageTemplatePayload

        if ($Filename -eq $script:config.WebTemplateHeader -or $Filename -eq $script:config.WebTemplateFooter) {
            $webTemplateLookupName = if ($Filename -eq $script:config.WebTemplateHeader) { "mspp_headerwebtemplateid@odata.bind" } else { "mspp_footerwebtemplateid@odata.bind" }
            $websiteRecord = @{ $webTemplateLookupName = "/mspp_webtemplates($webTemplateId)" }
            Invoke-DataverseApi -Method Patch -Url "$script:apiUrl/mspp_websites($WebsiteId)" -Body $websiteRecord -UseUpdateHeaders
        }
    }
}

function Create-Snippets {
    param([string]$WebsiteId, [string]$EnglishLanguageId, [string]$FrenchLanguageId)
    $snippetsJson = Get-Content $script:config.BasePathSnippets | ConvertFrom-Json
    foreach ($entry in
    # Script configuration
param(
    [string]$ConfigPath = "config.json",
    [switch]$UseJsonConfig
)

# Initialize logging
$LogFile = "script_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param([string]$Message)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" | Out-File -Append -FilePath $LogFile
    Write-Host $Message
}

# Load configuration
function Load-Config {
    if ($UseJsonConfig) {
        if (Test-Path $ConfigPath) {
            $config = Get-Content $ConfigPath | ConvertFrom-Json
        } else {
            Write-Log "Config file not found. Using default values."
            $config = Get-DefaultConfig
        }
    } else {
        $config = Get-DefaultConfig
    }
    return $config
}

function Get-DefaultConfig {
    return @{
        BasePath = "C:\Users\pearsof\repos\Public\"
        ZipFilePath = "C:\Users\pearsof\repos\Public\files\themes-dist-15.2.0-gcweb.zip"
        ExtractionPath = "C:\Users\pearsof\repos\Public\files\"
        ThemeRootFolderName = "themes-dist-15.2.0-gcweb"
        EnglishLanguageCode = 1033
        FrenchLanguageCode = 1036
        PageTemplateNameNewHome = "CS-Home-WET"
        WebTemplateHeader = "CS-header"
        WebTemplateFooter = "CS-footer"
        ClientId = "<client id>"
        TenantId = "<tenant id>"
        CrmInstance = "<crm instance>"
        RedirectUri = "https://login.onmicrosoft.com"
        WebsiteId = "<website id>"
        BlobAddress = "<blob address>"
        FlowURL = "<flow url>"
    }
}

# Authentication setup
function Get-AuthToken {
    param($Config)
    $authority = "https://login.microsoftonline.com/$($Config.TenantId)"
    $resource = "https://$($Config.CrmInstance).api.crm3.dynamics.com"
    $tokenEndpoint = "$authority/oauth2/v2.0/token"

    $body = @{
        client_id     = $Config.ClientId
        scope         = "$resource/.default"
        grant_type    = "client_credentials"
        redirect_uri  = $Config.RedirectUri
        client_secret = $Config.ClientSecret
    }

    try {
        $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
        return $authResponse.access_token
    } catch {
        Write-Log "Failed to acquire token: $_"
        throw
    }
}

# API functions
function Invoke-DataverseApi {
    param(
        [string]$Method,
        [string]$Url,
        [object]$Body,
        [hashtable]$Headers,
        [switch]$UseUpdateHeaders
    )
    try {
        $apiHeaders = if ($UseUpdateHeaders) { $script:updateHeaders } else { $script:headers }
        $response = Invoke-RestMethod -Method $Method -Uri $Url -Body ($Body | ConvertTo-Json -Depth 10) -Headers $apiHeaders -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        Write-Log "API call failed: $_"
        throw
    }
}

function Get-PageTemplateId {
    param([string]$WebsiteId)
    $filter = "_mspp_websiteid_value eq '$WebsiteId' and mspp_name eq 'Access Denied'"
    $pageTemplateQuery = "$script:apiUrl/mspp_pagetemplates?`$filter=$filter"
    $pageTemplate = Invoke-DataverseApi -Method Get -Url $pageTemplateQuery
    return $pageTemplate.value[0].mspp_pagetemplateid
}

function Get-PublishingStateId {
    $filter = "mspp_name eq 'Published'"
    $publishingStateQuery = "$script:apiUrl/mspp_publishingstates?`$filter=$filter"
    $publishingState = Invoke-DataverseApi -Method Get -Url $publishingStateQuery
    return $publishingState.value[0].mspp_publishingstateid
}

function Get-LanguageId {
    param([int]$LanguageCode)
    $filter = "mspp_lcid eq $LanguageCode"
    $languageQuery = "$script:apiUrl/mspp_websitelanguages?`$filter=$filter"
    $language = Invoke-DataverseApi -Method Get -Url $languageQuery
    return $language.value[0].mspp_websitelanguageid
}

function Get-HomePageId {
    param([string]$WebsiteId, [string]$LanguageId = $null)
    $filter = "_mspp_websiteid_value eq '$WebsiteId' and mspp_name eq 'Home'"
    if ($LanguageId) {
        $filter += " and _mspp_webpagelanguageid_value eq '$LanguageId'"
    } else {
        $filter += " and mspp_isroot eq true"
    }
    $homePageQuery = "$script:apiUrl/mspp_webpages?`$filter=$filter"
    $homePage = Invoke-DataverseApi -Method Get -Url $homePageQuery
    return $homePage.value[0].mspp_webpageid
}

function Update-BaselineStyles {
    param([string]$HomePageId)
    $stylePaths = @($script:config.PortalBasicThemePath, $script:config.ThemePath, $script:config.BootstrapPath, $script:config.FaviconPath)
    foreach ($path in $stylePaths) {
        Create-WebFile -FilePath $path -ParentPageId $HomePageId
    }
}

function Create-WebPage {
    param(
        [string]$Name,
        [string]$ParentPageId,
        [string]$WebsiteId,
        [string]$PageTemplateId,
        [string]$PublishingStateId
    )
    
    $partialUrl = $Name.ToLower()
    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$WebsiteId'"
    if ($ParentPageId) {
        $filter += " and _mspp_parentpageid_value eq $ParentPageId"
    }

    $checkUrl = "$script:apiUrl/mspp_webpages?`$filter=$filter"
    $existingPages = Invoke-DataverseApi -Method Get -Url $checkUrl

    $webPage = @{
        "mspp_name" = $Name
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($PublishingStateId)"
        "mspp_pagetemplateid@odata.bind" = "/mspp_pagetemplates($PageTemplateId)"
    }
    
    if ($ParentPageId) {
        $webPage["mspp_parentpageid@odata.bind"] = "/mspp_webpages($ParentPageId)"
    }

    if ($existingPages.value) {
        Write-Log "Web page already exists. Updating existing page."
        $updateUrl = "$script:apiUrl/mspp_webpages($($existingPages.value[0].mspp_webpageid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webPage -UseUpdateHeaders
        return $existingPages.value[0].mspp_webpageid
    } else {
        $webPageResponse = Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_webpages" -Body $webPage
        return $webPageResponse.mspp_webpageid
    }
}

function Create-WebFile {
    param(
        [string]$FilePath,
        [string]$ParentPageId,
        [string]$WebsiteId,
        [string]$PublishingStateId,
        [string]$BlobAddress
    )

    $fileName = [System.IO.Path]::GetFileName($FilePath)
    $partialUrl = $fileName.Replace(" ", "").ToLower()
    $fileContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($FilePath))
    $relativePath = Get-RelativePath ($script:config.ExtractionPath + "\$($script:config.ThemeRootFolderName)") $FilePath

    $blobUrl = "$BlobAddress$relativePath$partialUrl"

    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$WebsiteId'"
    if ($ParentPageId) {
        $filter += " and _mspp_parentpageid_value eq $ParentPageId"
    }

    $checkUrl = "$script:apiUrl/mspp_webfiles?`$filter=$filter"
    $existingFiles = Invoke-DataverseApi -Method Get -Url $checkUrl

    $webFile = @{
        "mspp_name" = $fileName
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($PublishingStateId)"
    }

    if ($ParentPageId) {
        $webFile["mspp_parentpageid@odata.bind"] = "/mspp_webpages($ParentPageId)"
    }

    if ($existingFiles.value) {
        Write-Log "Web file already exists: $FilePath"
        $updateUrl = "$script:apiUrl/mspp_webfiles($($existingFiles.value[0].mspp_webfileid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webFile -UseUpdateHeaders
        $webFileId = $existingFiles.value[0].mspp_webfileid
    } else {
        $webFileResponse = Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_webfiles" -Body $webFile
        $webFileId = $webFileResponse.mspp_webfileid
    }

    $existingRow = Invoke-DataverseApi -Method Get -Url "$script:apiUrl/powerpagecomponents($webFileId)"
    $fileUpdatePayload = @{
        "powerpagecomponentid" = $existingRow.powerpagecomponentid
        "name" = $existingRow.name
        "filecontent" = $fileContent
    }

    Invoke-RestMethod -Uri $script:config.FlowURL -Method Post -Body ($fileUpdatePayload | ConvertTo-Json) -ContentType "application/json; charset=utf-8"
}

function Get-RelativePath {
    param([string]$BasePath, [string]$TargetPath)
    $BasePath = [System.IO.Path]::GetFullPath($BasePath)
    $TargetPath = [System.IO.Path]::GetFullPath($TargetPath)

    if ($TargetPath.StartsWith($BasePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $TargetPath.Substring($BasePath.Length)
        if ($relativePath.StartsWith("\", [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $relativePath.Substring(1)
        }
        return $relativePath.Replace("\", "/")
    } else {
        return $TargetPath
    }
}

function Write-Hierarchy {
    param(
        [string]$Path,
        [string]$ParentPageId,
        [string]$WebsiteId,
        [string]$PageTemplateId,
        [string]$PublishingStateId
    )
    
    $items = Get-ChildItem -Path $Path
    
    foreach ($item in $items) {
        if (-not $item.PSIsContainer) {
            if ($null -eq $ParentPageId) {
                $ParentPageId = $script:homePageId
            }
            Write-Log "Processing file: $($item.FullName)"
            Create-WebFile -FilePath $item.FullName -ParentPageId $ParentPageId -WebsiteId $WebsiteId -PublishingStateId $PublishingStateId -BlobAddress $script:config.BlobAddress
        } else {
            Write-Log "Processing folder: $($item.Name)"
            $newPageId = Create-WebPage -Name $item.Name -ParentPageId $ParentPageId -WebsiteId $WebsiteId -PageTemplateId $PageTemplateId -PublishingStateId $PublishingStateId
            Write-Hierarchy -Path $item.FullName -ParentPageId $newPageId -WebsiteId $WebsiteId -PageTemplateId $PageTemplateId -PublishingStateId $PublishingStateId
        }
    }
}

function Create-WebTemplate {
    param(
        [string]$Markup,
        [string]$FileName,
        [string]$WebsiteId
    )

    $webTemplatePayload = @{
        "mspp_name" = $FileName
        "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
        "mspp_source" = $Markup
    }

    $filter = "mspp_name eq '$FileName'"
    $checkWebTemplateExists = "$script:apiUrl/mspp_webtemplates?`$filter=$filter"
    $existingTemplates = Invoke-DataverseApi -Method Get -Url $checkWebTemplateExists

    if ($existingTemplates.value) {
        Write-Log "Web template already exists: $FileName"
        $updateUrl = "$script:apiUrl/mspp_webtemplates($($existingTemplates.value[0].mspp_webtemplateid))"
        $updatePayload = @{ "mspp_source" = $Markup }
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $updatePayload -UseUpdateHeaders
        $webTemplateId = $existingTemplates.value[0].mspp_webtemplateid
    } else {
        $webResponse = Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_webtemplates" -Body $webTemplatePayload
        $webTemplateId = $webResponse.mspp_webtemplateid

        $pageTemplatePayload = @{
            "mspp_name" = $FileName
            "mspp_type" = "756150001"
            "mspp_websiteid@odata.bind" = "/mspp_websites($WebsiteId)"
            "mspp_webtemplateid@odata.bind" = "/mspp_webtemplates($webTemplateId)"
        }
        Invoke-DataverseApi -Method Post -Url "$script:apiUrl/mspp_pagetemplates" -Body $pageTemplatePayload

        if (($FileName -eq $script:config.WebTemplateHeader) -or ($FileName -eq $script:config.WebTemplateFooter)) {
            $webTemplateLookupName = if ($FileName -eq $script:config.WebTemplateHeader) { "mspp_headerwebtemplateid@odata.bind" } else { "mspp_footerwebtemplateid@odata.bind" }
            $webs# Script configuration
param(
    [string]$ConfigPath = "config.json",
    [switch]$UseJsonConfig
)

# Initialize logging
$LogFile = "script_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param([string]$Message)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" | Out-File -Append -FilePath $LogFile
    Write-Host $Message
}

# Load configuration
function Load-Config {
    if ($UseJsonConfig) {
        if (Test-Path $ConfigPath) {
            $config = Get-Content $ConfigPath | ConvertFrom-Json
        } else {
            Write-Log "Config file not found. Using default values."
            $config = Get-DefaultConfig
        }
    } else {
        $config = Get-DefaultConfig
    }
    return $config
}

function Get-DefaultConfig {
    return @{
        BasePath = "C:\Users\pearsof\repos\Public\"
        ZipFilePath = "C:\Users\pearsof\repos\Public\files\themes-dist-15.2.0-gcweb.zip"
        ExtractionPath = "C:\Users\pearsof\repos\Public\files\"
        ThemeRootFolderName = "themes-dist-15.2.0-gcweb"
        EnglishLanguageCode = 1033
        FrenchLanguageCode = 1036
        PageTemplateNameNewHome = "CS-Home-WET"
        WebTemplateHeader = "CS-header"
        WebTemplateFooter = "CS-footer"
        ClientId = "<client id>"
        TenantId = "<tenant id>"
        CrmInstance = "<crm instance>"
        RedirectUri = "https://login.onmicrosoft.com"
        WebsiteId = "<website id>"
        BlobAddress = "<blob address>"
        FlowURL = "<flow url>"
    }
}

# API Helper Functions
function Get-AuthToken {
    param($Config)
    $authority = "https://login.microsoftonline.com/$($Config.TenantId)"
    $resource = "https://$($Config.CrmInstance).api.crm3.dynamics.com"
    $tokenEndpoint = "$authority/oauth2/v2.0/token"

    $body = @{
        client_id     = $Config.ClientId
        scope         = "$resource/.default"
        grant_type    = "client_credentials"
        redirect_uri  = $Config.RedirectUri
        client_secret = $Config.ClientSecret
    }

    $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
    return $authResponse.access_token
}

function Invoke-DataverseApi {
    param(
        [string]$Method,
        [string]$Url,
        [object]$Body,
        [hashtable]$Headers,
        [switch]$UseUpdateHeaders
    )
    try {
        $fullHeaders = $UseUpdateHeaders ? ($Headers + @{"If-Match" = "*"}) : $Headers
        $response = Invoke-RestMethod -Method $Method -Uri $Url -Body $Body -Headers $fullHeaders -ContentType "application/json; charset=utf-8"
        return $response
    } catch {
        Write-Log "API call failed: $_"
        throw
    }
}

# Dataverse Helper Functions
function Get-PageTemplateId {
    param($Config, $Headers)
    $filter = "_mspp_websiteid_value eq '$($Config.WebsiteId)' and mspp_name eq 'Access Denied'"
    $pageTemplateQuery = "$($Config.ApiUrl)mspp_pagetemplates?`$filter=$filter"
    $pageTemplate = Invoke-DataverseApi -Method Get -Url $pageTemplateQuery -Headers $Headers
    return $pageTemplate.value[0].mspp_pagetemplateid
}

function Get-PublishingStateId {
    param($Config, $Headers)
    $filter = "mspp_name eq 'Published'"
    $publishingStateQuery = "$($Config.ApiUrl)mspp_publishingstates?`$filter=$filter"
    $publishingState = Invoke-DataverseApi -Method Get -Url $publishingStateQuery -Headers $Headers
    return $publishingState.value[0].mspp_publishingstateid
}

function Get-LanguageId {
    param($Config, $Headers, [int]$LanguageCode)
    $filter = "mspp_lcid eq $LanguageCode"
    $languageQuery = "$($Config.ApiUrl)mspp_websitelanguages?`$filter=$filter"
    $language = Invoke-DataverseApi -Method Get -Url $languageQuery -Headers $Headers
    return $language.value[0].mspp_websitelanguageid
}

function Get-HomePageId {
    param($Config, $Headers, [string]$LanguageId = $null)
    $filter = "_mspp_websiteid_value eq '$($Config.WebsiteId)' and mspp_name eq 'Home'"
    if ($LanguageId) {
        $filter += " and _mspp_webpagelanguageid_value eq '$LanguageId'"
    } else {
        $filter += " and mspp_isroot eq true"
    }
    $homePageQuery = "$($Config.ApiUrl)mspp_webpages?`$filter=$filter"
    $homePage = Invoke-DataverseApi -Method Get -Url $homePageQuery -Headers $Headers
    return $homePage.value[0].mspp_webpageid
}

# Web Operations Functions
function Update-BaselineStyles {
    param($Config, $Headers, $HomePageId)
    $stylePaths = @(
        $Config.PortalBasicThemePath,
        $Config.ThemePath,
        $Config.BootstrapPath,
        $Config.FaviconPath
    )
    foreach ($path in $stylePaths) {
        Create-WebFile -Config $Config -Headers $Headers -FilePath $path -ParentPageId $HomePageId
    }
}

function Create-WebPage {
    param($Config, $Headers, [string]$Name, [string]$ParentPageId, [string]$PageTemplateId, [string]$PublishingStateId)
    $partialUrl = $Name.ToLower()
    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$($Config.WebsiteId)'"
    if ($ParentPageId) {
        $filter += " and _mspp_parentpageid_value eq $ParentPageId"
    }
    $checkUrl = "$($Config.ApiUrl)mspp_webpages?`$filter=$filter"
    $existingPages = Invoke-DataverseApi -Method Get -Url $checkUrl -Headers $Headers

    $webPage = @{
        "mspp_name" = $Name
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($($Config.WebsiteId))"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($PublishingStateId)"
        "mspp_pagetemplateid@odata.bind" = "/mspp_pagetemplates($PageTemplateId)"
    }
    if ($ParentPageId) {
        $webPage["mspp_parentpageid@odata.bind"] = "/mspp_webpages($ParentPageId)"
    }

    $webPageJson = $webPage | ConvertTo-Json

    if ($existingPages.value.Count -gt 0) {
        $existingPage = $existingPages.value[0]
        $updateUrl = "$($Config.ApiUrl)mspp_webpages($($existingPage.mspp_webpageid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webPageJson -Headers $Headers -UseUpdateHeaders
        return $existingPage.mspp_webpageid
    } else {
        $webPageResponse = Invoke-DataverseApi -Method Post -Url "$($Config.ApiUrl)mspp_webpages" -Body $webPageJson -Headers $Headers
        return $webPageResponse.mspp_webpageid
    }
}

function Create-WebFile {
    param($Config, $Headers, [string]$FilePath, [string]$ParentPageId)
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    $partialUrl = $fileName.Replace(" ", "").ToLower()
    $fileContent = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($FilePath))
    $relativePath = Get-RelativePath -BasePath "$($Config.ExtractionPath)$($Config.ThemeRootFolderName)" -TargetPath $FilePath

    $filter = "mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$($Config.WebsiteId)'"
    if ($ParentPageId) {
        $filter += " and _mspp_parentpageid_value eq $ParentPageId"
    }
    $checkUrl = "$($Config.ApiUrl)mspp_webfiles?`$filter=$filter"
    $existingFiles = Invoke-DataverseApi -Method Get -Url $checkUrl -Headers $Headers

    $webFile = @{
        "mspp_name" = $fileName
        "mspp_partialurl" = $partialUrl
        "mspp_websiteid@odata.bind" = "/mspp_websites($($Config.WebsiteId))"
        "mspp_publishingstateid@odata.bind" = "/mspp_publishingstates($($Config.PublishingStateId))"
    }
    if ($ParentPageId) {
        $webFile["mspp_parentpageid@odata.bind"] = "/mspp_webpages($ParentPageId)"
    }

    $webFileJson = $webFile | ConvertTo-Json

    if ($existingFiles.value.Count -gt 0) {
        $existingFile = $existingFiles.value[0]
        $updateUrl = "$($Config.ApiUrl)mspp_webfiles($($existingFile.mspp_webfileid))"
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webFileJson -Headers $Headers -UseUpdateHeaders
        $webFileId = $existingFile.mspp_webfileid
    } else {
        $webFileResponse = Invoke-DataverseApi -Method Post -Url "$($Config.ApiUrl)mspp_webfiles" -Body $webFileJson -Headers $Headers
        $webFileId = $webFileResponse.mspp_webfileid
    }

    $existingRow = Invoke-DataverseApi -Method Get -Url "$($Config.ApiUrl)powerpagecomponents($webFileId)" -Headers $Headers
    $fileUpdatePayload = @{
        "powerpagecomponentid" = $existingRow.powerpagecomponentid
        "name" = $existingRow.name
        "filecontent" = $fileContent
    } | ConvertTo-Json

    Invoke-WebRequest -Uri $Config.WebFileFlowURL -Method Post -Body $fileUpdatePayload -ContentType "application/json; charset=utf-8"
}

function Get-RelativePath {
    param([string]$BasePath, [string]$TargetPath)
    $BasePath = [System.IO.Path]::GetFullPath($BasePath)
    $TargetPath = [System.IO.Path]::GetFullPath($TargetPath)
    if ($TargetPath.StartsWith($BasePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $TargetPath.Substring($BasePath.Length)
        if ($relativePath.StartsWith("\", [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $relativePath.Substring(1)
        }
        return $relativePath.Replace("\", "/")
    } else {
        return $TargetPath
    }
}

function Write-Hierarchy {
    param($Config, $Headers, [string]$Path, [string]$ParentPageId = $null, [string]$Indent = "")
    $items = Get-ChildItem -Path $Path
    foreach ($item in $items) {
        if (-not $item.PSIsContainer) {
            $effectiveParentId = $ParentPageId ?? $Config.HomePageId
            Write-Log "$Indent Processing file: $($item.Name)"
            Create-WebFile -Config $Config -Headers $Headers -FilePath $item.FullName -ParentPageId $effectiveParentId
        } else {
            Write-Log "$Indent Processing folder: $($item.Name)"
            $newPageId = Create-WebPage -Config $Config -Headers $Headers -Name $item.Name -ParentPageId $ParentPageId -PageTemplateId $Config.PageTemplateId -PublishingStateId $Config.PublishingStateId
            Write-Hierarchy -Config $Config -Headers $Headers -Path $item.FullName -ParentPageId $newPageId -Indent "$Indent  "
        }
    }
}

function Create-WebTemplate {
    param($Config, $Headers, [string]$Markup, [string]$Filename)
    $webTemplatePayload = @{
        "mspp_name" = $Filename
        "mspp_websiteid@odata.bind" = "/mspp_websites($($Config.WebsiteId))"
        "mspp_source" = $Markup
    } | ConvertTo-Json

    $filter = "mspp_name eq '$Filename'"
    $checkUrl = "$($Config.ApiUrl)mspp_webtemplates?`$filter=$filter"
    $existingTemplates = Invoke-DataverseApi -Method Get -Url $checkUrl -Headers $Headers

    if ($existingTemplates.value.Count -gt 0) {
        $existingTemplate = $existingTemplates.value[0]
        $updateUrl = "$($Config.ApiUrl)mspp_webtemplates($($existingTemplate.mspp_webtemplateid))"
        $updatePayload = @{ "mspp_source" = $Markup } | ConvertTo-Json
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $updatePayload -Headers $Headers -UseUpdateHeaders
        $webTemplateId = $existingTemplate.mspp_webtemplateid
    } else {
        $webTemplateResponse = Invoke-DataverseApi -Method Post -Url "$($Config.ApiUrl)mspp_webtemplates" -Body $webTemplatePayload -Headers $Headers
        $webTemplateId = $webTemplateResponse.mspp_webtemplateid

        $pageTemplatePayload = @{
            "mspp_name" = $Filename
            "mspp_type" = "756150001"
            "mspp_websiteid@odata.bind" = "/mspp_websites($($Config.WebsiteId))"
            "mspp_webtemplateid@odata.bind" = "/mspp_webtemplates($webTemplateId)"
        } | ConvertTo-Json

        Invoke-DataverseApi -Method Post -Url "$($Config.ApiUrl)mspp_pagetemplates" -Body $pageTemplatePayload -Headers $Headers
    }

    if ($Filename -eq $Config.WebTemplateHeader -or $Filename -eq $Config.WebTemplateFooter) {
        $websiteUpdatePayload = @{
            "$($Filename -eq $Config.WebTemplateHeader ? 'mspp_headerwebtemplateid' : 'mspp_footerwebtemplateid')@odata.bind" = "/mspp_webtemplates($webTemplateId)"
        } | ConvertTo-Json
        $updateWebsiteUrl = "$($Config.ApiUrl)mspp_websites($($Config.WebsiteId))"
        Invoke-DataverseApi -Method Patch -Url $updateWebsiteUrl -Body $websiteUpdatePayload -Headers $Headers -UseUpdateHeaders
    }
}

function Create-Snippets {
    param($Config, $Headers)
    $snippetsJson = Get-Content $Config.BasePathSnippets | ConvertFrom-Json
    
    foreach ($entry in $snippetsJson.PSObject.Properties) {
        $snippetName = $entry.Name
        $snippetContentEnglish = $entry.Value[0]
        $snippetContentFrench = $entry.Value[1]

        $createOrUpdateSnippet = {
            param($LanguageId, $Content)
            $snippetPayload = @{
                "mspp_name" = $snippetName
                "mspp_websiteid@odata.bind" = "/mspp_websites($($Config.WebsiteId))"
                "mspp_value" = $Content
                "mspp_contentsnippetlanguageid@odata.bind" = "/mspp_websitelanguages($LanguageId)"
            } | ConvertTo-Json

            $filter = "(mspp_name eq '$snippetName' and _mspp_contentsnippetlanguageid_value eq $LanguageId)"
            $checkUrl = "$($Config.ApiUrl)mspp_contentsnippets?`$filter=$filter"
            $existingSnippets = Invoke-DataverseApi -Method Get -Url $checkUrl -Headers $Headers

            if ($existingSnippets.value.Count -gt 0) {
                $existingSnippet = $existingSnippets.value[0]
                $updateUrl = "$($Config.ApiUrl)mspp_contentsnippets($($existingSnippet.mspp_contentsnippetid))"
                Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $snippetPayload -Headers $Headers -UseUpdateHeaders
            } else {
                Invoke-DataverseApi -Method Post -Url "$($Config.ApiUrl)mspp_contentsnippets" -Body $snippetPayload -Headers $Headers
            }
        }

        & $createOrUpdateSnippet $Config.EnglishLanguageId $snippetContentEnglish
        & $createOrUpdateSnippet $Config.FrenchLanguageId $snippetContentFrench
    }
}

function Write-Templates {
    param($Config, $Headers, [string]$FolderPath)
    $files = Get-ChildItem -Path $FolderPath -File
    Write-Log "Processing templates in folder: $($FolderPath | Split-Path -Leaf)"
    
    foreach ($file in $files) {
        Write-Log "Processing template file: $($file.Name)"
        $markup = Get-Content -Path $file.FullName -Raw
        $templateName = $file.BaseName
        Create-WebTemplate -Config $Config -Headers $Headers -Markup $markup -Filename $templateName
    }
}

function Update-HomePage {
    param($Config, $Headers, [string]$PageTemplateName)
    $filter = "mspp_name eq '$PageTemplateName'"
    $checkUrl = "$($Config.ApiUrl)mspp_pagetemplates?`$filter=$filter"
    $existingTemplates = Invoke-DataverseApi -Method Get -Url $checkUrl -Headers $Headers

    if ($existingTemplates.value.Count -gt 0) {
        $existingTemplate = $existingTemplates.value[0]
        $pageTemplateId = $existingTemplate.mspp_pagetemplateid
        
        $updateUrl = "$($Config.ApiUrl)mspp_webpages($($Config.HomePageId))"
        $webPagePayload = @{
            "mspp_pagetemplateid@odata.bind" = "/mspp_pagetemplates($pageTemplateId)"
        } | ConvertTo-Json
        Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $webPagePayload -Headers $Headers -UseUpdateHeaders

        $updateContentPages = {
            param($LanguageId)
            $updateUrl = "$($Config.ApiUrl)mspp_webpages($LanguageId)"
            $contentPagePayload = @{ "mspp_copy" = "" } | ConvertTo-Json
            Invoke-DataverseApi -Method Patch -Url $updateUrl -Body $contentPagePayload -Headers $Headers -UseUpdateHeaders
        }

        & $updateContentPages $Config.HomeContentPageEN
        & $updateContentPages $Config.HomeContentPageFR
    } else {
        Write-Log "Page template '$PageTemplateName' not found."
    }
}

function Install-PortalTemplate {
    param($Config, $Headers)
    try {
        Expand-Archive -Path $Config.ZipFilePath -DestinationPath $Config.ExtractionPath -Force
        Write-Log "Extracted theme to: $($Config.ExtractionPath)"

        Create-Snippets -Config $Config -Headers $Headers
        Write-Templates -Config $Config -Headers $Headers -FolderPath $Config.BasePathTemplates
        Update-HomePage -Config $Config -Headers $Headers -PageTemplateName $Config.PageTemplateNameNewHome
        Write-Hierarchy -Config $Config -Headers $Headers -Path "$($Config.ExtractionPath)$($Config.ThemeRootFolderName)" -ParentPageId $Config.HomePageId
        Update-BaselineStyles -Config $Config -Headers $Headers -HomePageId $Config.HomePageId
    }
    catch {
        Write-Log "An error occurred during portal template installation: $_"
    }
}

# Main execution
try {
    Write-Log "Script started"
    $config = Load-Config
    $token = Get-AuthToken -Config $config
    $headers = @{
        Authorization = "Bearer $token"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        Accept = "application/json"
        Prefer = "return=representation"
    }
    
    $config.ApiUrl = "https://$($config.CrmInstance).api.crm3.dynamics.com/api/data/v9.2/"
    $config.PageTemplateId = Get-PageTemplateId -Config $config -Headers $headers
    $config.PublishingStateId = Get-PublishingStateId -Config $config -Headers $headers
    $config.EnglishLanguageId = Get-LanguageId -Config $config -Headers $headers -LanguageCode $config.EnglishLanguageCode
    $config.FrenchLanguageId = Get-LanguageId -Config $config -Headers $headers -LanguageCode $config.FrenchLanguageCode
    $config.HomePageId = Get-HomePageId -Config $config -Headers $headers
    $config.HomeContentPageEN = Get-HomePageId -Config $config -Headers $headers -LanguageId $config.EnglishLanguageId
    $config.HomeContentPageFR = Get-HomePageId -Config $config -Headers $headers -LanguageId $config.FrenchLanguageId

    Install-PortalTemplate -Config $config -Headers $headers
}
catch {
    Write-Log "An error occurred: $_"
}
finally {
    Write-Log "Script ended"
}