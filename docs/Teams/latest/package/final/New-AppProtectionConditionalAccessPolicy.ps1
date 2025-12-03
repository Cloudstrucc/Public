<#
.SYNOPSIS
    Creates a Conditional Access policy requiring App Protection Policy for mobile devices.

.DESCRIPTION
    This script creates a Conditional Access policy in Microsoft Entra ID that controls 
    how mobile devices (iOS/Android) access Office 365 apps (Outlook, Teams, SharePoint, etc.).
    
    The policy ensures users must use apps protected by Intune App Protection Policies,
    preventing corporate data from being copied to personal apps, screenshots of sensitive
    content, or saving attachments to personal cloud storage.

    ┌─────────────────────────────────────────────────────────────────┐
    │  User tries to access Outlook/Teams/SharePoint on their phone  │
    └─────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │  Conditional Access Policy checks:                              │
    │                                                                 │
    │  ✓ Is the user in the target group?                            │
    │  ✓ Is this an iOS or Android device?                           │
    │  ✓ Is the app protected by Intune App Protection Policy?       │
    └─────────────────────────────┬───────────────────────────────────┘
                                  │
                  ┌───────────────┴───────────────┐
                  ▼                               ▼
    ┌──────────────────────┐         ┌──────────────────────┐
    │  YES - All checks    │         │  NO - Missing        │
    │  pass                │         │  protection          │
    │                      │         │                      │
    │  ✅ ACCESS GRANTED   │         │  ❌ ACCESS BLOCKED   │
    │  User can use app    │         │  Must use managed    │
    │                      │         │  app with protection │
    └──────────────────────┘         └──────────────────────┘

    WHAT THIS SCRIPT DOES (Step-by-Step):
    ─────────────────────────────────────
    Step 1:  Checks if Microsoft.Graph PowerShell module is installed
    Step 2:  Connects to Microsoft Graph API with your admin account
    Step 2b: Finds the target group (e.g., "LCE M365 Security") in Entra ID
    Step 3:  Checks if the policy already exists (updates if yes, creates if no)
    Step 4:  Builds the policy configuration
    Step 5:  Creates/updates the policy in Entra ID

    THE POLICY IT CREATES:
    ──────────────────────
    • Target:       Users in the specified group only
    • Platforms:    iOS and Android devices
    • Apps:         Office 365 (Exchange, SharePoint, Teams, OneDrive, etc.)
    • Requirement:  App Protection Policy OR Approved Client App
    • Initial State: Report-only (logs what would happen, doesn't block yet)

    WHY THIS MATTERS:
    ─────────────────
    Without this policy, someone could:
    • Use an unmanaged email app on their personal phone
    • Copy Protected B data to personal apps
    • Access sensitive information without any security controls

    With this policy, users MUST use apps protected by your Intune App Protection
    Policies, ensuring data stays protected even on mobile devices.

    PREREQUISITES:
    ──────────────
    1. Microsoft.Graph PowerShell module (script will install if missing)
    2. Conditional Access Administrator or Global Administrator role
    3. Microsoft Entra ID P1 or P2 license
    4. Intune App Protection Policies already configured for iOS and Android
       (Apps → App protection policies in Intune admin center)

    HOW TO RUN:
    ───────────
    1. Open a NEW PowerShell window (avoid module conflicts)
    2. Run: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    3. Run: .\New-AppProtectionConditionalAccessPolicy.ps1
    4. Sign in when prompted with admin credentials
    5. Follow the prompts

    AFTER RUNNING:
    ──────────────
    1. The policy is created in REPORT-ONLY mode (doesn't block users yet)
    2. Review sign-in logs in Entra ID for "Report-only: Failure" entries
    3. Verify affected users have Intune app protection policies assigned
    4. When ready, change the policy state from "Report-only" to "On" in Entra ID

.NOTES
    Author:         Leonardo Canada - LCE M365 Security Team
    Date:           December 2025
    Version:        1.0
    
.EXAMPLE
    .\New-AppProtectionConditionalAccessPolicy.ps1
    
    Creates a Conditional Access policy targeting the "LCE M365 Security" group
    in report-only mode.

.LINK
    Intune App Protection Policies:
    https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/appProtection
    
    Entra ID Conditional Access:
    https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Overview
#>

#Requires -Version 5.1

# ============================================================================
# CONFIGURATION - Modify these values as needed
# ============================================================================

# Policy Name
$PolicyName = "Require App Protection Policy - Mobile Devices"
$PolicyDescription = "Requires app protection policy or approved client app for iOS and Android devices accessing Office 365"

# Policy State: "enabled", "disabled", or "enabledForReportingButNotEnforced" (Report-only)
# RECOMMENDED: Start with Report-only to test before enforcing
$PolicyState = "enabledForReportingButNotEnforced"

# Target Group (will look up by name)
$TargetGroupName = "LCE M365 Security"

# Exclude specific users/groups (add Object IDs here)
# IMPORTANT: Always exclude break-glass/emergency access accounts
$ExcludedUserIds = @(
    # "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Example: Emergency Access Account 1
    # "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Example: Emergency Access Account 2
)

# Exclude specific groups (add Object IDs here)
$ExcludedGroupIds = @(
    # "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Example: CA Exclusion Group
)

# ============================================================================
# SCRIPT START
# ============================================================================

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Conditional Access Policy Creation Script" -ForegroundColor Cyan
Write-Host "  Policy: Require App Protection Policy (Mobile)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# STEP 1: Check for Microsoft.Graph module
# ============================================================================

Write-Host "[1/5] Checking for Microsoft.Graph module..." -ForegroundColor Yellow

# Check for module conflicts first
$conflictingModules = @("AzureAD", "AzureADPreview")
foreach ($mod in $conflictingModules) {
    $loadedMod = Get-Module -Name $mod -ErrorAction SilentlyContinue
    if ($loadedMod) {
        Write-Host "      WARNING: $mod module is loaded. This may cause conflicts." -ForegroundColor Yellow
        Write-Host "      Consider running this script in a fresh PowerShell window." -ForegroundColor Yellow
    }
}

$graphModule = Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns | 
               Sort-Object Version -Descending | 
               Select-Object -First 1

if (-not $graphModule) {
    Write-Host "      Microsoft.Graph.Identity.SignIns module not found." -ForegroundColor Red
    Write-Host "      Installing Microsoft.Graph modules..." -ForegroundColor Yellow
    
    try {
        Install-Module -Name Microsoft.Graph.Identity.SignIns -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        Install-Module -Name Microsoft.Graph.Users -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        Install-Module -Name Microsoft.Graph.Groups -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        Write-Host "      Modules installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "      ERROR: Failed to install modules." -ForegroundColor Red
        Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "      Module found (version $($graphModule.Version))." -ForegroundColor Green
}

# Import modules
Import-Module Microsoft.Graph.Identity.SignIns -ErrorAction SilentlyContinue
Import-Module Microsoft.Graph.Users -ErrorAction SilentlyContinue
Import-Module Microsoft.Graph.Groups -ErrorAction SilentlyContinue

# ============================================================================
# STEP 2: Connect to Microsoft Graph
# ============================================================================

Write-Host ""
Write-Host "[2/5] Connecting to Microsoft Graph..." -ForegroundColor Yellow
Write-Host "      (A sign-in prompt will appear - use admin credentials)" -ForegroundColor Gray

try {
    # Check if already connected
    $context = Get-MgContext -ErrorAction SilentlyContinue
    
    if ($context) {
        Write-Host "      Already connected as: $($context.Account)" -ForegroundColor Green
        
        # Check for required scopes
        $requiredScopes = @("Policy.Read.All", "Policy.ReadWrite.ConditionalAccess", "Application.Read.All")
        $missingScopes = $requiredScopes | Where-Object { $context.Scopes -notcontains $_ }
        
        if ($missingScopes) {
            Write-Host "      Missing required scopes. Reconnecting..." -ForegroundColor Yellow
            Disconnect-MgGraph -ErrorAction SilentlyContinue
            $context = $null
        }
    }
    
    if (-not $context) {
        $scopes = @(
            "Policy.Read.All", 
            "Policy.ReadWrite.ConditionalAccess", 
            "Application.Read.All", 
            "User.Read.All", 
            "Group.Read.All"
        )
        
        # Try device code authentication (more reliable with module conflicts)
        Write-Host "      Using device code authentication..." -ForegroundColor Gray
        Write-Host ""
        
        try {
            Connect-MgGraph -Scopes $scopes -UseDeviceCode -ErrorAction Stop
        }
        catch {
            # Fallback to interactive browser if device code fails
            Write-Host "      Device code failed, trying interactive browser..." -ForegroundColor Yellow
            Connect-MgGraph -Scopes $scopes -ErrorAction Stop
        }
    }
    
    $context = Get-MgContext
    Write-Host ""
    Write-Host "      Connected as: $($context.Account)" -ForegroundColor Green
    Write-Host "      Tenant ID:    $($context.TenantId)" -ForegroundColor Gray
}
catch {
    Write-Host "      ERROR: Failed to connect to Microsoft Graph." -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "      TROUBLESHOOTING:" -ForegroundColor Yellow
    Write-Host "      ─────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "      1. Open a NEW PowerShell window (don't reuse existing)" -ForegroundColor White
    Write-Host "      2. Run: Update-Module Microsoft.Graph -Force" -ForegroundColor White
    Write-Host "      3. If still failing, run these commands:" -ForegroundColor White
    Write-Host "         Uninstall-Module Microsoft.Graph -AllVersions -Force" -ForegroundColor Cyan
    Write-Host "         Install-Module Microsoft.Graph -Force -AllowClobber" -ForegroundColor Cyan
    Write-Host "      4. Close PowerShell and reopen before running this script" -ForegroundColor White
    Write-Host ""
    exit 1
}

# ============================================================================
# STEP 2b: Look up target group
# ============================================================================

Write-Host ""
Write-Host "[2b/5] Looking up target group: '$TargetGroupName'..." -ForegroundColor Yellow

$TargetGroupId = $null

try {
    $groups = Get-MgGroup -Filter "displayName eq '$TargetGroupName'" -ErrorAction Stop
    
    if ($groups -and @($groups).Count -gt 0) {
        $targetGroup = @($groups)[0]
        $TargetGroupId = $targetGroup.Id
        Write-Host "      Group found: $($targetGroup.DisplayName)" -ForegroundColor Green
        Write-Host "      Group ID:    $TargetGroupId" -ForegroundColor Gray
        Write-Host "      Members:     $($targetGroup.Members.Count) (approximate)" -ForegroundColor Gray
    }
    else {
        Write-Host "      Group '$TargetGroupName' not found." -ForegroundColor Red
        Write-Host ""
        Write-Host "      Searching for similar groups..." -ForegroundColor Yellow
        
        $similarGroups = Get-MgGroup -Filter "startswith(displayName, 'LCE')" -Top 10 -ErrorAction SilentlyContinue
        
        if ($similarGroups) {
            Write-Host ""
            $index = 1
            foreach ($grp in $similarGroups) {
                Write-Host "      [$index] $($grp.DisplayName)" -ForegroundColor White
                Write-Host "          ID: $($grp.Id)" -ForegroundColor Gray
                $index++
            }
            Write-Host ""
            Write-Host "      [0] Exit script" -ForegroundColor Gray
            Write-Host ""
            
            do {
                $selection = Read-Host "      Enter the number of the group to use (or 0 to exit)"
                
                if ($selection -eq "0") {
                    Write-Host ""
                    Write-Host "      Script cancelled by user." -ForegroundColor Yellow
                    exit 0
                }
                
                $selectionInt = $selection -as [int]
                $groupCount = @($similarGroups).Count
                
                if ($selectionInt -and $selectionInt -ge 1 -and $selectionInt -le $groupCount) {
                    $targetGroup = @($similarGroups)[$selectionInt - 1]
                    $TargetGroupId = $targetGroup.Id
                    $TargetGroupName = $targetGroup.DisplayName
                    Write-Host ""
                    Write-Host "      Selected: $TargetGroupName" -ForegroundColor Green
                    Write-Host "      Group ID: $TargetGroupId" -ForegroundColor Gray
                }
                else {
                    Write-Host "      Invalid selection. Please enter a number between 0 and $groupCount." -ForegroundColor Red
                }
            } while (-not $TargetGroupId)
        }
        else {
            Write-Host "      No similar groups found. Please check the group name." -ForegroundColor Red
            exit 1
        }
    }
}
catch {
    Write-Host "      ERROR: Failed to look up group." -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 3: Check if policy already exists
# ============================================================================

Write-Host ""
Write-Host "[3/5] Checking for existing policy..." -ForegroundColor Yellow

try {
    $existingPolicies = Get-MgIdentityConditionalAccessPolicy -All -ErrorAction Stop
    $existingPolicy = $existingPolicies | Where-Object { $_.DisplayName -eq $PolicyName }
    
    if ($existingPolicy) {
        Write-Host "      Policy '$PolicyName' already exists!" -ForegroundColor Yellow
        Write-Host "      Policy ID: $($existingPolicy.Id)" -ForegroundColor Gray
        Write-Host "      State:     $($existingPolicy.State)" -ForegroundColor Gray
        Write-Host ""
        
        $overwrite = Read-Host "      Do you want to update this policy? (Y/N)"
        
        if ($overwrite -notmatch "^[Yy]") {
            Write-Host ""
            Write-Host "      Script cancelled. Existing policy not modified." -ForegroundColor Yellow
            exit 0
        }
        
        $UpdateExisting = $true
    }
    else {
        Write-Host "      No existing policy found. Will create new policy." -ForegroundColor Green
        $UpdateExisting = $false
    }
}
catch {
    Write-Host "      ERROR: Failed to check existing policies." -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 4: Build Policy Configuration
# ============================================================================

Write-Host ""
Write-Host "[4/5] Building policy configuration..." -ForegroundColor Yellow

# Build exclusions
$excludedUsers = @()
$excludedGroups = @()

if ($ExcludedUserIds.Count -gt 0) {
    $excludedUsers = $ExcludedUserIds
    Write-Host "      Excluding $($ExcludedUserIds.Count) user(s)" -ForegroundColor Gray
}

if ($ExcludedGroupIds.Count -gt 0) {
    $excludedGroups = $ExcludedGroupIds
    Write-Host "      Excluding $($ExcludedGroupIds.Count) group(s)" -ForegroundColor Gray
}

# Office 365 App ID (includes Exchange, SharePoint, Teams, etc.)
$Office365AppId = "Office365"

# Build the policy parameters
$policyParams = @{
    DisplayName = $PolicyName
    State = $PolicyState
    Conditions = @{
        Users = @{
            IncludeGroups = @($TargetGroupId)
            ExcludeUsers = $excludedUsers
            ExcludeGroups = $excludedGroups
        }
        Applications = @{
            IncludeApplications = @($Office365AppId)
        }
        Platforms = @{
            IncludePlatforms = @("android", "iOS")
        }
        ClientAppTypes = @("browser", "mobileAppsAndDesktopClients")
    }
    GrantControls = @{
        Operator = "OR"
        BuiltInControls = @("approvedApplication", "compliantApplication")
    }
}

Write-Host "      Configuration built successfully." -ForegroundColor Green

# Display configuration summary
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "  Policy Configuration Summary" -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Name:           $PolicyName" -ForegroundColor White
Write-Host "  State:          $PolicyState" -ForegroundColor White
Write-Host ""
Write-Host "  Target Group:   $TargetGroupName" -ForegroundColor White
Write-Host "  Group ID:       $TargetGroupId" -ForegroundColor Gray
if ($excludedUsers.Count -gt 0) {
    Write-Host "  Excluded Users: $($excludedUsers.Count) user(s)" -ForegroundColor White
}
if ($excludedGroups.Count -gt 0) {
    Write-Host "  Excluded Groups: $($excludedGroups.Count) group(s)" -ForegroundColor White
}
Write-Host ""
Write-Host "  Target Apps:    Office 365 (Exchange, SharePoint, Teams, etc.)" -ForegroundColor White
Write-Host "  Platforms:      iOS, Android" -ForegroundColor White
Write-Host "  Client Apps:    Browser, Mobile apps and desktop clients" -ForegroundColor White
Write-Host ""
Write-Host "  Grant Controls: Require ONE of:" -ForegroundColor White
Write-Host "                  - Approved client app" -ForegroundColor White
Write-Host "                  - App protection policy" -ForegroundColor White
Write-Host ""

if ($PolicyState -eq "enabledForReportingButNotEnforced") {
    Write-Host "  ⚠️  Policy will be created in REPORT-ONLY mode" -ForegroundColor Yellow
    Write-Host "      Review sign-in logs before enabling enforcement" -ForegroundColor Yellow
}
elseif ($PolicyState -eq "enabled") {
    Write-Host "  ⚠️  Policy will be ENABLED immediately" -ForegroundColor Red
    Write-Host "      Users will be affected right away!" -ForegroundColor Red
}
Write-Host ""

$confirm = Read-Host "  Proceed with creating/updating this policy? (Y/N)"

if ($confirm -notmatch "^[Yy]") {
    Write-Host ""
    Write-Host "  Script cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================================
# STEP 5: Create or Update Policy
# ============================================================================

Write-Host ""
Write-Host "[5/5] Creating/updating policy..." -ForegroundColor Yellow

try {
    if ($UpdateExisting) {
        # Update existing policy
        Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $existingPolicy.Id -BodyParameter $policyParams -ErrorAction Stop
        Write-Host "      Policy updated successfully!" -ForegroundColor Green
        $policyId = $existingPolicy.Id
    }
    else {
        # Create new policy
        $newPolicy = New-MgIdentityConditionalAccessPolicy -BodyParameter $policyParams -ErrorAction Stop
        Write-Host "      Policy created successfully!" -ForegroundColor Green
        $policyId = $newPolicy.Id
    }
}
catch {
    Write-Host "      ERROR: Failed to create/update policy." -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Configuration Complete" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Policy Name:   $PolicyName" -ForegroundColor White
Write-Host "  Policy ID:     $policyId" -ForegroundColor White
Write-Host "  State:         $PolicyState" -ForegroundColor White
Write-Host "  Target Group:  $TargetGroupName" -ForegroundColor White
Write-Host ""

if ($PolicyState -eq "enabledForReportingButNotEnforced") {
    Write-Host "  NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "  ──────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  1. Review sign-in logs in Entra ID for this policy" -ForegroundColor White
    Write-Host "  2. Check for 'Report-only: Failure' entries" -ForegroundColor White
    Write-Host "  3. Verify affected users have Intune app protection" -ForegroundColor White
    Write-Host "  4. When ready, change policy state to 'Enabled'" -ForegroundColor White
    Write-Host ""
    Write-Host "  View policy: https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$policyId" -ForegroundColor Cyan
}
else {
    Write-Host "  Policy is now ACTIVE and enforcing." -ForegroundColor Green
    Write-Host ""
    Write-Host "  View policy: https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$policyId" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan

# ============================================================================
# END OF SCRIPT
# ============================================================================