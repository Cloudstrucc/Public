<#
.SYNOPSIS
    Deploys Power Platform CoE Portal site markers and content snippets

.DESCRIPTION
    This script deploys all required site markers and content snippets for the 
    Power Platform Centre of Excellence portal to a Power Pages environment.
    
    Prerequisites:
    - Power Platform CLI (pac) must be installed
    - User must have System Administrator role in target environment
    - Power Pages site must already exist

.PARAMETER EnvironmentUrl
    The URL of the Power Platform environment (e.g., https://yourorg.crm.dynamics.com)

.PARAMETER WebsiteId
    The GUID of the Power Pages website. If not provided, script will attempt to find it.

.PARAMETER UpdateExisting
    Switch to update existing site markers and snippets instead of creating new ones

.PARAMETER Language
    Language code for the content (default: 1033 for English)

.EXAMPLE
    .\Deploy-CoEPortal.ps1 -EnvironmentUrl "https://yourorg.crm.dynamics.com"

.EXAMPLE
    .\Deploy-CoEPortal.ps1 -EnvironmentUrl "https://yourorg.crm.dynamics.com" -WebsiteId "12345678-1234-1234-1234-123456789012" -UpdateExisting

.NOTES
    Author: Power Platform CoE Team
    Version: 1.0
    Created: 2025
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$EnvironmentUrl,
    
    [Parameter(Mandatory = $false)]
    [string]$WebsiteId,
    
    [Parameter(Mandatory = $false)]
    [switch]$UpdateExisting,
    
    [Parameter(Mandatory = $false)]
    [int]$Language = 1033
)

# Error handling
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $currentColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $currentColor
}

# Function to check if pac CLI is installed
function Test-PacCli {
    try {
        $pacVersion = pac --version 2>$null
        if ($pacVersion) {
            Write-ColorOutput "✅ Power Platform CLI found: $pacVersion" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "❌ Power Platform CLI not found. Please install it first." "Red"
        Write-ColorOutput "Download from: https://aka.ms/PowerPlatformCLI" "Yellow"
        return $false
    }
}

# Function to authenticate to Power Platform
function Connect-PowerPlatform {
    param([string]$Environment)
    
    Write-ColorOutput "🔐 Authenticating to Power Platform..." "Yellow"
    
    try {
        pac auth create --url $Environment
        Write-ColorOutput "✅ Successfully authenticated to $Environment" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to authenticate to Power Platform: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Function to get website ID if not provided
function Get-WebsiteId {
    param([string]$Environment)
    
    if (-not [string]::IsNullOrEmpty($WebsiteId)) {
        return $WebsiteId
    }
    
    Write-ColorOutput "🔍 Looking for Power Pages website..." "Yellow"
    
    try {
        # Query for websites in the environment
        $websites = pac data list --environment $Environment --table "adx_website" --columns "adx_websiteid,adx_name" | ConvertFrom-Json
        
        if ($websites.Count -eq 0) {
            throw "No Power Pages websites found in the environment"
        }
        elseif ($websites.Count -eq 1) {
            $siteId = $websites[0].adx_websiteid
            Write-ColorOutput "✅ Found website: $($websites[0].adx_name) ($siteId)" "Green"
            return $siteId
        }
        else {
            Write-ColorOutput "Multiple websites found. Please specify WebsiteId parameter:" "Yellow"
            foreach ($site in $websites) {
                Write-ColorOutput "  - $($site.adx_name): $($site.adx_websiteid)" "White"
            }
            throw "Multiple websites found"
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to retrieve website information: $($_.Exception.Message)" "Red"
        throw
    }
}

# Function to create or update site marker
function Set-SiteMarker {
    param(
        [string]$Name,
        [string]$Value,
        [string]$WebsiteId,
        [bool]$Update = $false
    )
    
    try {
        # Check if site marker already exists
        $existingMarker = $null
        try {
            $query = "adx_sitemarkers?`$filter=adx_name eq '$Name' and _adx_websiteid_value eq $WebsiteId"
            $existingMarker = pac data list --environment $EnvironmentUrl --table "adx_sitemarker" --filter "adx_name eq '$Name'" | ConvertFrom-Json
        }
        catch {
            # Marker doesn't exist, which is fine for new creation
        }
        
        if ($existingMarker -and $existingMarker.Count -gt 0) {
            if ($Update -or $UpdateExisting) {
                # Update existing marker
                $markerId = $existingMarker[0].adx_sitemarkerid
                pac data update --environment $EnvironmentUrl --table "adx_sitemarker" --id $markerId --data "{ `"adx_value`": `"$Value`" }"
                Write-ColorOutput "  ✅ Updated site marker: $Name" "Green"
            }
            else {
                Write-ColorOutput "  ⚠️  Site marker already exists: $Name (use -UpdateExisting to update)" "Yellow"
            }
        }
        else {
            # Create new marker
            $data = @{
                "adx_name" = $Name
                "adx_value" = $Value
                "adx_websiteid@odata.bind" = "/adx_websites($WebsiteId)"
            } | ConvertTo-Json -Compress
            
            pac data create --environment $EnvironmentUrl --table "adx_sitemarker" --data $data
            Write-ColorOutput "  ✅ Created site marker: $Name" "Green"
        }
    }
    catch {
        Write-ColorOutput "  ❌ Failed to create/update site marker '$Name': $($_.Exception.Message)" "Red"
    }
}

# Function to create or update content snippet
function Set-ContentSnippet {
    param(
        [string]$Name,
        [string]$Value,
        [string]$WebsiteId,
        [int]$LanguageCode = 1033,
        [bool]$Update = $false
    )
    
    try {
        # Check if content snippet already exists
        $existingSnippet = $null
        try {
            $existingSnippet = pac data list --environment $EnvironmentUrl --table "adx_contentsnippet" --filter "adx_name eq '$Name'" | ConvertFrom-Json
        }
        catch {
            # Snippet doesn't exist, which is fine for new creation
        }
        
        if ($existingSnippet -and $existingSnippet.Count -gt 0) {
            if ($Update -or $UpdateExisting) {
                # Update existing snippet
                $snippetId = $existingSnippet[0].adx_contentsnippetid
                pac data update --environment $EnvironmentUrl --table "adx_contentsnippet" --id $snippetId --data "{ `"adx_value`": `"$Value`" }"
                Write-ColorOutput "  ✅ Updated content snippet: $Name" "Green"
            }
            else {
                Write-ColorOutput "  ⚠️  Content snippet already exists: $Name (use -UpdateExisting to update)" "Yellow"
            }
        }
        else {
            # Create new snippet
            $data = @{
                "adx_name" = $Name
                "adx_value" = $Value
                "adx_contentsnippetlanguageid" = $LanguageCode
                "adx_websiteid@odata.bind" = "/adx_websites($WebsiteId)"
            } | ConvertTo-Json -Compress
            
            pac data create --environment $EnvironmentUrl --table "adx_contentsnippet" --data $data
            Write-ColorOutput "  ✅ Created content snippet: $Name" "Green"
        }
    }
    catch {
        Write-ColorOutput "  ❌ Failed to create/update content snippet '$Name': $($_.Exception.Message)" "Red"
    }
}

# Site markers configuration
$siteMarkers = @{
    # Core Navigation & Branding
    "Page Title" = "Power Platform Excellence Centre"
    "Skip to Main Content" = "Skip to main content"
    "Skip to Footer" = "Skip to footer"
    "French Page URL" = "/fr/accueil"
    "Elections Canada Home" = "https://www.elections.ca"
    "Elections Canada Logo" = "/assets/img/ec-logo.png"
    "Home Page" = "/"
    
    # Authentication & User Experience
    "Sign In URL" = "/signin"
    "Sign In Button Text" = "Sign In"
    "Sign In Prompt" = "Please sign in to access citizen developer services and request resources."
    
    # Hero Section Content
    "Hero Title" = "Power Platform Excellence Centre"
    "Hero Subtitle" = "Empowering Elections Canada citizen developers with governed, secure, and innovative Power Platform solutions."
    
    # Anonymous User Welcome
    "Anonymous Welcome Title" = "Welcome to the Power Platform Excellence Centre"
    "Anonymous Welcome Text" = "The Power Platform Excellence Centre (CoE) helps Elections Canada staff leverage Microsoft Power Platform tools to create innovative solutions while maintaining security and governance standards."
    
    # Service Tiles Configuration
    "Services Title" = "Available Services"
    "Services Description" = "Access the tools and resources you need for Power Platform development at Elections Canada."
    
    # Environment Request Service
    "Environment Request Title" = "Environment Request"
    "Environment Request Description" = "Request new development, test, or production environments for your Power Platform projects with proper governance and security controls."
    "Environment Request URL" = "/environment-request"
    
    # DLP Policy Service
    "DLP Request Title" = "DLP Policy Request"
    "DLP Request Description" = "Request changes to Data Loss Prevention policies or analyze the impact of connector usage on your applications and flows."
    "DLP Request URL" = "/dlp-request"
    
    # App Catalog Service
    "App Catalog Title" = "App Catalog"
    "App Catalog Description" = "Browse and discover approved Power Platform applications available for use across Elections Canada departments."
    "App Catalog URL" = "/app-catalog"
    
    # Developer Compliance Service
    "Compliance Title" = "Developer Compliance"
    "Compliance Description" = "Ensure your applications meet Elections Canada standards and compliance requirements through our guided assessment process."
    "Compliance URL" = "/compliance-center"
    
    # Training & Resources Service
    "Training Title" = "Training & Resources"
    "Training Description" = "Access training materials, best practices, templates, and community resources to enhance your Power Platform skills."
    "Training URL" = "/training"
    
    # Support Service
    "Support Title" = "Support & Feedback"
    "Support Description" = "Get help with your Power Platform projects, submit feedback, or connect with the CoE team for guidance and support."
    "Support URL" = "/support"
    
    # About Section
    "About CoE Title" = "About the Power Platform Excellence Centre"
    "About CoE Text" = "The Power Platform Excellence Centre at Elections Canada provides governance, guidance, and support for citizen developers using Microsoft Power Platform tools. Our mission is to enable innovation while maintaining security, compliance, and operational excellence."
    "Key Benefits Title" = "Key Benefits"
    
    # Quick Links Section
    "Quick Links Title" = "Quick Links"
    "CoE Documentation" = "/documentation"
    "Best Practices" = "/best-practices"
    "Governance Policies" = "/governance"
    "Community Forum" = "/community"
    
    # Footer Links
    "Elections Canada Contact" = "https://www.elections.ca/content.aspx?section=cont"
    "Privacy" = "/privacy"
    "Terms" = "/terms"
    "Social Media" = "https://www.elections.ca/content.aspx?section=med&dir=soc"
    "Mobile App" = "https://www.elections.ca/content.aspx?section=vot&dir=mob"
    "Canada Wordmark" = "/assets/img/wmms-blk.svg"
}

# Content snippets configuration
$contentSnippets = @{
    # Statistics Section (Anonymous Users)
    "Active Apps Count" = "250+"
    "Citizen Developers Count" = "75+"
    "Environments Count" = "12"
    "Automated Processes" = "180+"
    
    # Key Benefits List
    "Benefit 1" = "Streamlined environment provisioning with proper governance"
    "Benefit 2" = "Data Loss Prevention policy management and impact analysis"
    "Benefit 3" = "Centralized app catalog for discovery and reuse"
    "Benefit 4" = "Compliance monitoring and developer guidance"
    "Benefit 5" = "Training resources and community support"
}

# Main execution
try {
    Write-ColorOutput "🚀 Starting Power Platform CoE Portal Deployment" "Cyan"
    Write-ColorOutput "Environment: $EnvironmentUrl" "White"
    Write-ColorOutput "Update Mode: $UpdateExisting" "White"
    Write-ColorOutput "" "White"
    
    # Check prerequisites
    if (-not (Test-PacCli)) {
        exit 1
    }
    
    # Authenticate
    if (-not (Connect-PowerPlatform -Environment $EnvironmentUrl)) {
        exit 1
    }
    
    # Get website ID
    $websiteId = Get-WebsiteId -Environment $EnvironmentUrl
    if (-not $websiteId) {
        exit 1
    }
    
    Write-ColorOutput "" "White"
    Write-ColorOutput "📝 Deploying Site Markers..." "Cyan"
    Write-ColorOutput "Total site markers to deploy: $($siteMarkers.Count)" "White"
    
    # Deploy site markers
    $markerCount = 0
    foreach ($marker in $siteMarkers.GetEnumerator()) {
        $markerCount++
        Write-ColorOutput "[$markerCount/$($siteMarkers.Count)] $($marker.Key)" "White"
        Set-SiteMarker -Name $marker.Key -Value $marker.Value -WebsiteId $websiteId -Update $UpdateExisting
    }
    
    Write-ColorOutput "" "White"
    Write-ColorOutput "📄 Deploying Content Snippets..." "Cyan"
    Write-ColorOutput "Total content snippets to deploy: $($contentSnippets.Count)" "White"
    
    # Deploy content snippets
    $snippetCount = 0
    foreach ($snippet in $contentSnippets.GetEnumerator()) {
        $snippetCount++
        Write-ColorOutput "[$snippetCount/$($contentSnippets.Count)] $($snippet.Key)" "White"
        Set-ContentSnippet -Name $snippet.Key -Value $snippet.Value -WebsiteId $websiteId -LanguageCode $Language -Update $UpdateExisting
    }
    
    Write-ColorOutput "" "White"
    Write-ColorOutput "🎉 Deployment completed successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "Next Steps:" "Yellow"
    Write-ColorOutput "1. Upload the home page template to your Power Pages site" "White"
    Write-ColorOutput "2. Upload the custom CSS and JavaScript files" "White"
    Write-ColorOutput "3. Configure authentication providers if needed" "White"
    Write-ColorOutput "4. Test the portal with both anonymous and authenticated users" "White"
    Write-ColorOutput "5. Update any URLs in site markers to match your actual service endpoints" "White"
    
}
catch {
    Write-ColorOutput "" "White"
    Write-ColorOutput "❌ Deployment failed: $($_.Exception.Message)" "Red"
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}

Write-ColorOutput "" "White"
Write-ColorOutput "📋 Deployment Summary:" "Cyan"
Write-ColorOutput "- Site Markers: $($siteMarkers.Count) items" "White"
Write-ColorOutput "- Content Snippets: $($contentSnippets.Count) items" "White"
Write-ColorOutput "- Target Environment: $EnvironmentUrl" "White"
Write-ColorOutput "- Website ID: $websiteId" "White"
Write-ColorOutput "" "White"