# Import configuration
$useJsonConfig = Read-Host "Do you want to provide a JSON configuration file? (Y/N)"
$jsonConfig = $null

if ($useJsonConfig -eq "Y" -or $useJsonConfig -eq "y") {
    $jsonFilePath = Read-Host "Enter the path to the JSON configuration file"
    if (Test-Path -Path $jsonFilePath -PathType Leaf) {
        $jsonConfig = Get-Content $jsonFilePath | ConvertFrom-Json
    } else {
        Write-Host "File not found. Please ensure you provide a valid JSON configuration file with auth details."
        exit
    }
}

# Set up authentication parameters
$clientId = $jsonConfig.auth.clientId
$tenantId = $jsonConfig.auth.tenantId
$authority = "https://login.microsoftonline.com/$tenantId"
$resource = "https://$($jsonConfig.auth.crmInstance).api.crm3.dynamics.com"
$redirectUri = $jsonConfig.auth.redirectUri
$tokenEndpoint = "$authority/oauth2/v2.0/token"
$secret = $jsonConfig.auth.clientSecret

# Prepare token request
$body = @{
    client_id     = $clientId
    scope         = $resource + "/.default"
    grant_type    = "client_credentials"
    redirect_uri  = $redirectUri
    client_secret = $secret
}

# Get token
try {
    $authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"
    $token = $authResponse.access_token
    Write-Host "Authentication successful!" -ForegroundColor Green
} catch {
    Write-Host "Authentication failed: $_" -ForegroundColor Red
    exit
}

# Set up headers
$headers = @{
    Authorization = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    Accept = "application/json"
    Prefer = "return=representation"
}

# API URL
$apiUrl = $resource + "/api/data/v9.2/"

# Function to check if content is HTML
function Is-HtmlContent {
    param (
        [string]$content
    )
    
    # Check for common HTML indicators
    $htmlPatterns = @(
        '<[^>]+>',                    # HTML tags
        '&[a-zA-Z]+;',               # Named HTML entities
        '<!DOCTYPE',                  # DOCTYPE declaration
        '<html',                      # HTML root element
        '<script',                    # Script tags
        '<style',                     # Style tags
        '<link',                      # Link tags
        '<meta'                       # Meta tags
    )

    foreach ($pattern in $htmlPatterns) {
        if ($content -match $pattern) {
            return $true
        }
    }
    return $false
}

# Function to clean snippet content
function Clean-SnippetContent {
    param (
        [string]$content
    )
    
    if ([string]::IsNullOrEmpty($content)) {
        return $content
    }

    return $content `
        -replace '&#\d+;', ' ' `  # Remove HTML character codes
        -replace '"', '' `        # Remove double quotes
        -replace '\"', '' `       # Remove escaped double quotes
        -replace '\s+', ' ' `     # Replace multiple spaces with single space
        -trim                     # Trim whitespace
}

# Function to get all content snippets
function Get-ContentSnippets {
    # Note: webresourcetype eq 11 is for Text web resources
    $fetchUrl = $apiUrl + "webresourceset?`$filter=webresourcetype eq 11"
    
    try {
        $response = Invoke-RestMethod -Uri $fetchUrl -Method Get -Headers $headers
        return $response.value
    } catch {
        Write-Host "Error getting content snippets: $_" -ForegroundColor Red
        return $null
    }
}

# Function to update a content snippet
function Update-ContentSnippet {
    param (
        [string]$webResourceId,
        [string]$name,
        [string]$content
    )
    
    $updateUrl = $apiUrl + "webresourceset($webResourceId)"
    
    $updateBody = @{
        content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
    } | ConvertTo-Json

    try {
        $headers["If-Match"] = "*"
        Invoke-RestMethod -Uri $updateUrl -Method Patch -Headers $headers -Body $updateBody -ContentType "application/json"
        Write-Host "Successfully updated snippet: $name" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Error updating snippet $name : $_" -ForegroundColor Red
        return $false
    }
}

# Function to publish customizations
function Publish-Customizations {
    param (
        [array]$webResourceIds
    )
    
    $publishUrl = $apiUrl + "PublishXml"
    
    $parameterXml = "<importexportxml><webresources>"
    foreach ($id in $webResourceIds) {
        $parameterXml += "<webresource>{$id}</webresource>"
    }
    $parameterXml += "</webresources></importexportxml>"
    
    $publishBody = @{
        ParameterXml = $parameterXml
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $publishUrl -Method Post -Headers $headers -Body $publishBody -ContentType "application/json"
        Write-Host "Successfully published customizations" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Error publishing customizations: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Fetching content snippets..." -ForegroundColor Yellow
$snippets = Get-ContentSnippets

if ($snippets) {
    Write-Host "Found $($snippets.Count) text-type content snippets" -ForegroundColor Yellow
    
    $updatedSnippetIds = @()
    $totalUpdated = 0
    $skippedHtml = 0
    
    foreach ($snippet in $snippets) {
        # Decode the content from base64
        $content = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($snippet.content))
        
        # Skip if content appears to be HTML
        if (Is-HtmlContent -content $content) {
            Write-Host "Skipping $($snippet.name) - Contains HTML content" -ForegroundColor Yellow
            $skippedHtml++
            continue
        }

        # Clean the content
        $cleanedContent = Clean-SnippetContent -content $content
        
        # Only update if content changed
        if ($cleanedContent -ne $content) {
            Write-Host "`nProcessing: $($snippet.name)" -ForegroundColor Yellow
            Write-Host "Original: $content"
            Write-Host "Cleaned:  $cleanedContent"
            
            $proceed = Read-Host "Update this snippet? (Y/N)"
            if ($proceed -eq "Y" -or $proceed -eq "y") {
                if (Update-ContentSnippet -webResourceId $snippet.webresourceid -name $snippet.name -content $cleanedContent) {
                    $updatedSnippetIds += $snippet.webresourceid
                    $totalUpdated++
                }
            }
        }
    }
    
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "Total snippets processed: $($snippets.Count)" -ForegroundColor Cyan
    Write-Host "Skipped HTML content: $skippedHtml" -ForegroundColor Yellow
    Write-Host "Updated: $totalUpdated" -ForegroundColor Green
    
    if ($totalUpdated -gt 0) {
        Write-Host "`nPublishing changes..." -ForegroundColor Yellow
        Publish-Customizations -webResourceIds $updatedSnippetIds
        Write-Host "Successfully updated and published $totalUpdated snippets" -ForegroundColor Green
    } else {
        Write-Host "`nNo snippets were updated" -ForegroundColor Yellow
    }
} else {
    Write-Host "No content snippets found or error occurred" -ForegroundColor Red
}

Write-Host "`nScript execution completed." -ForegroundColor Green