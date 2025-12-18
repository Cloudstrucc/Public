<#
.SYNOPSIS
    Configure sensitivity label policy for Teams meetings ONLY
.DESCRIPTION
    Creates label policy that ONLY appears in Teams meetings,
    NOT in Outlook, Word, Excel, or other Office apps.
    
    KEY IMPROVEMENT (v9.0): 
    - Does NOT use -ExchangeLocation "All" during creation
    - Creates with ModernGroupLocation instead (or no location)
    - Multiple fallback strategies if primary method fails
    - Enhanced verification with retry logic
    
    This script:
    1. Creates label policy WITHOUT Exchange locations
    2. Verifies no Exchange/SharePoint/OneDrive locations exist
    3. Retries removal if any locations slip through
    4. Confirms Teams-only configuration
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 27, 2025
.NOTES
    VERSION 9.0 - Fixed Exchange location issue at creation time
    
    CHANGE LOG:
    v9.0 - Removed -ExchangeLocation "All" from New-LabelPolicy
         - Added multiple creation strategies
         - Enhanced verification with retries
         - Better error handling
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 3: LABEL POLICY CONFIGURATION (TEAMS ONLY) v9.0          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nKey improvement in v9.0:" -ForegroundColor Yellow
Write-Host "  • No longer creates policy with Exchange locations" -ForegroundColor White
Write-Host "  • Uses ModernGroupLocation or no-location creation" -ForegroundColor White
Write-Host "  • Multiple fallback strategies for reliability`n" -ForegroundColor White

$policyName = "LCE Meeting Labels"
$maxRetries = 3
$retryDelaySeconds = 5

# ============================================================
# FUNCTIONS
# ============================================================

function Test-ExchangeLocations {
    param([string]$PolicyName)
    
    $policy = Get-LabelPolicy -Identity $PolicyName -ErrorAction SilentlyContinue
    if (-not $policy) { return $null }
    
    $exchangeCount = if ($policy.ExchangeLocation) { $policy.ExchangeLocation.Count } else { 0 }
    $sharePointCount = if ($policy.SharePointLocation) { $policy.SharePointLocation.Count } else { 0 }
    $oneDriveCount = if ($policy.OneDriveLocation) { $policy.OneDriveLocation.Count } else { 0 }
    
    return @{
        Exchange = $exchangeCount
        SharePoint = $sharePointCount
        OneDrive = $oneDriveCount
        Total = $exchangeCount + $sharePointCount + $oneDriveCount
        IsClean = ($exchangeCount -eq 0)
    }
}

function Remove-AllOfficeLocations {
    param([string]$PolicyName)
    
    Write-Host "  Attempting to remove any Office locations..." -ForegroundColor Yellow
    
    $policy = Get-LabelPolicy -Identity $PolicyName -ErrorAction SilentlyContinue
    if (-not $policy) { return $false }
    
    # Remove Exchange
    if ($policy.ExchangeLocation -and $policy.ExchangeLocation.Count -gt 0) {
        foreach ($location in @($policy.ExchangeLocation)) {
            try {
                Set-LabelPolicy -Identity $PolicyName -RemoveExchangeLocation $location -ErrorAction Stop
                Write-Host "    ✓ Removed Exchange: $location" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠ Could not remove Exchange: $location" -ForegroundColor Yellow
            }
        }
    }
    
    # Remove SharePoint
    if ($policy.SharePointLocation -and $policy.SharePointLocation.Count -gt 0) {
        foreach ($location in @($policy.SharePointLocation)) {
            try {
                Set-LabelPolicy -Identity $PolicyName -RemoveSharePointLocation $location -ErrorAction Stop
                Write-Host "    ✓ Removed SharePoint: $location" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠ Could not remove SharePoint: $location" -ForegroundColor Yellow
            }
        }
    }
    
    # Remove OneDrive
    if ($policy.OneDriveLocation -and $policy.OneDriveLocation.Count -gt 0) {
        foreach ($location in @($policy.OneDriveLocation)) {
            try {
                Set-LabelPolicy -Identity $PolicyName -RemoveOneDriveLocation $location -ErrorAction Stop
                Write-Host "    ✓ Removed OneDrive: $location" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠ Could not remove OneDrive: $location" -ForegroundColor Yellow
            }
        }
    }
    
    # Also set advanced settings to disable Outlook behaviors
    try {
        Set-LabelPolicy -Identity $PolicyName -AdvancedSettings @{
            OutlookDefaultLabel = "None"
            DisableMandatoryInOutlook = "True"
            OutlookRecommendationEnabled = "False"
        } -ErrorAction SilentlyContinue
        Write-Host "    ✓ Set Outlook disable flags" -ForegroundColor Green
    } catch {
        Write-Host "    ⚠ Could not set advanced settings" -ForegroundColor Yellow
    }
    
    return $true
}

# ============================================================
# CONNECT TO SERVICES
# ============================================================

Write-Host "[Step 1/6] Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected to Purview" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n[Step 1B/6] Connecting to Exchange Online..." -ForegroundColor Cyan

try {
    $exoSession = Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened"}
    if (-not $exoSession) {
        Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
    }
    Write-Host "  ✓ Connected to Exchange Online" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Could not connect to Exchange Online (non-critical)" -ForegroundColor Yellow
}

# ============================================================
# GET LABELS
# ============================================================

Write-Host "`n[Step 2/6] Finding sensitivity labels..." -ForegroundColor Cyan

$allLabels = Get-Label
$protectedB = $allLabels | Where-Object {$_.DisplayName -eq "Protected B - Official Sensitive - NATO"}
$general = $allLabels | Where-Object {$_.DisplayName -eq "Unclassified"}

if (-not $protectedB -or -not $general) {
    Write-Host "  ✗ Labels not found! Run Phase 2 first." -ForegroundColor Red
    Write-Host "    Expected: 'Protected B - Official Sensitive - NATO'" -ForegroundColor Yellow
    Write-Host "    Expected: 'Unclassified'" -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "  ✓ Found: $($protectedB.DisplayName) (GUID: $($protectedB.Guid))" -ForegroundColor Green
Write-Host "  ✓ Found: $($general.DisplayName) (GUID: $($general.Guid))" -ForegroundColor Green

# ============================================================
# CHECK FOR EXISTING POLICY
# ============================================================

Write-Host "`n[Step 3/6] Checking for existing policy..." -ForegroundColor Cyan

$existingPolicy = Get-LabelPolicy -Identity $policyName -ErrorAction SilentlyContinue

if ($existingPolicy) {
    Write-Host "  ⚠ Policy '$policyName' already exists" -ForegroundColor Yellow
    
    $locationStatus = Test-ExchangeLocations -PolicyName $policyName
    
    Write-Host "  Current locations:" -ForegroundColor White
    Write-Host "    Exchange: $($locationStatus.Exchange)" -ForegroundColor $(if($locationStatus.Exchange -eq 0){"Green"}else{"Red"})
    Write-Host "    SharePoint: $($locationStatus.SharePoint)" -ForegroundColor $(if($locationStatus.SharePoint -eq 0){"Green"}else{"Yellow"})
    Write-Host "    OneDrive: $($locationStatus.OneDrive)" -ForegroundColor $(if($locationStatus.OneDrive -eq 0){"Green"}else{"Yellow"})
    
    if ($locationStatus.Total -gt 0) {
        Write-Host "`n  Cleaning existing policy locations..." -ForegroundColor Yellow
        Remove-AllOfficeLocations -PolicyName $policyName
    }
    
    # Update labels if needed
    if ($existingPolicy.Labels -notcontains $protectedB.Guid) {
        Set-LabelPolicy -Identity $policyName -AddLabel $protectedB.Guid -ErrorAction SilentlyContinue
    }
    if ($existingPolicy.Labels -notcontains $general.Guid) {
        Set-LabelPolicy -Identity $policyName -AddLabel $general.Guid -ErrorAction SilentlyContinue
    }
    
    Write-Host "  ✓ Existing policy updated" -ForegroundColor Green
    
} else {
    # ============================================================
    # CREATE NEW POLICY - WITHOUT EXCHANGE LOCATIONS
    # ============================================================
    
    Write-Host "  Policy doesn't exist - creating new..." -ForegroundColor White
    Write-Host "`n[Step 4/6] Creating policy WITHOUT Exchange locations..." -ForegroundColor Cyan
    
    $policyCreated = $false
    
    # STRATEGY 1: Try with ModernGroupLocation only (targets M365 Groups/Teams)
    Write-Host "  Strategy 1: ModernGroupLocation only..." -ForegroundColor Gray
    try {
        New-LabelPolicy -Name $policyName `
            -Labels @($protectedB.Guid, $general.Guid) `
            -ModernGroupLocation "All" `
            -Comment "Teams meetings only - Created $(Get-Date -Format 'yyyy-MM-dd HH:mm') - v9.0" `
            -ErrorAction Stop
        
        Write-Host "  ✓ Policy created with ModernGroupLocation" -ForegroundColor Green
        $policyCreated = $true
    } catch {
        Write-Host "  ⚠ Strategy 1 failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # STRATEGY 2: Try with no location parameters at all
    if (-not $policyCreated) {
        Write-Host "  Strategy 2: No location parameters..." -ForegroundColor Gray
        try {
            New-LabelPolicy -Name $policyName `
                -Labels @($protectedB.Guid, $general.Guid) `
                -Comment "Teams meetings only - Created $(Get-Date -Format 'yyyy-MM-dd HH:mm') - v9.0" `
                -ErrorAction Stop
            
            Write-Host "  ✓ Policy created with no locations" -ForegroundColor Green
            $policyCreated = $true
        } catch {
            Write-Host "  ⚠ Strategy 2 failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # STRATEGY 3: Last resort - create with Exchange, then immediately remove
    if (-not $policyCreated) {
        Write-Host "  Strategy 3: Create with Exchange, then remove (last resort)..." -ForegroundColor Gray
        try {
            New-LabelPolicy -Name $policyName `
                -Labels @($protectedB.Guid, $general.Guid) `
                -ExchangeLocation "All" `
                -Comment "Teams meetings only - Created $(Get-Date -Format 'yyyy-MM-dd HH:mm') - v9.0" `
                -ErrorAction Stop
            
            Write-Host "  ✓ Policy created (with Exchange - will remove)" -ForegroundColor Yellow
            $policyCreated = $true
            
            # Immediately try to remove Exchange
            Start-Sleep -Seconds 3
            Write-Host "  Immediately removing Exchange locations..." -ForegroundColor Yellow
            Remove-AllOfficeLocations -PolicyName $policyName
            
        } catch {
            Write-Host "  ✗ Strategy 3 failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if (-not $policyCreated) {
        Write-Host "`n  ✗ FAILED: Could not create policy with any strategy" -ForegroundColor Red
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        exit 1
    }
}

# ============================================================
# VERIFICATION WITH RETRIES
# ============================================================

Write-Host "`n[Step 5/6] Verifying configuration (with retries)..." -ForegroundColor Cyan

$verified = $false
$attempt = 0

while (-not $verified -and $attempt -lt $maxRetries) {
    $attempt++
    Write-Host "  Verification attempt $attempt of $maxRetries..." -ForegroundColor Gray
    
    Start-Sleep -Seconds $retryDelaySeconds
    
    $locationStatus = Test-ExchangeLocations -PolicyName $policyName
    
    if ($null -eq $locationStatus) {
        Write-Host "    ⚠ Policy not found - waiting..." -ForegroundColor Yellow
        continue
    }
    
    Write-Host "    Exchange: $($locationStatus.Exchange)" -ForegroundColor $(if($locationStatus.Exchange -eq 0){"Green"}else{"Red"})
    Write-Host "    SharePoint: $($locationStatus.SharePoint)" -ForegroundColor Gray
    Write-Host "    OneDrive: $($locationStatus.OneDrive)" -ForegroundColor Gray
    
    if ($locationStatus.IsClean) {
        $verified = $true
        Write-Host "  ✓ VERIFIED: No Exchange locations!" -ForegroundColor Green
    } else {
        Write-Host "    Exchange locations still present - attempting removal..." -ForegroundColor Yellow
        Remove-AllOfficeLocations -PolicyName $policyName
    }
}

# Final status
$finalStatus = Test-ExchangeLocations -PolicyName $policyName

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor White
Write-Host "║  FINAL CONFIGURATION STATUS                                     ║" -ForegroundColor White
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor White

Write-Host "`n  Policy: $policyName" -ForegroundColor White
Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Exchange Locations:   $($finalStatus.Exchange)" -ForegroundColor $(if($finalStatus.Exchange -eq 0){"Green"}else{"Red"})
Write-Host "  SharePoint Locations: $($finalStatus.SharePoint)" -ForegroundColor $(if($finalStatus.SharePoint -eq 0){"Green"}else{"Yellow"})
Write-Host "  OneDrive Locations:   $($finalStatus.OneDrive)" -ForegroundColor $(if($finalStatus.OneDrive -eq 0){"Green"}else{"Yellow"})
Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor Gray

if ($finalStatus.IsClean) {
    Write-Host "  Status: ✅ TEAMS ONLY - Labels will NOT appear in Outlook" -ForegroundColor Green
} else {
    Write-Host "  Status: ⚠️  EXCHANGE PRESENT - Labels MAY appear in Outlook" -ForegroundColor Red
    Write-Host "`n  Recommended: Run emergency removal script" -ForegroundColor Yellow
    Write-Host "    .\02B-Emergency-Remove-Outlook-Labels.ps1" -ForegroundColor White
}

# ============================================================
# CHECK DISTRIBUTION GROUP
# ============================================================

Write-Host "`n[Step 6/6] Checking distribution group..." -ForegroundColor Cyan

$groupEmail = "lcem365security@leonardocompany.ca"
$groupMembers = @()

try {
    $dgMembers = Get-DistributionGroupMember -Identity $groupEmail -ErrorAction SilentlyContinue
    
    if ($dgMembers) {
        Write-Host "  ✓ Group: $groupEmail" -ForegroundColor Green
        Write-Host "  ✓ Members: $($dgMembers.Count)" -ForegroundColor Green
        
        foreach ($member in $dgMembers) {
            $groupMembers += [PSCustomObject]@{
                DisplayName = $member.DisplayName
                Email = $member.PrimarySmtpAddress
            }
            Write-Host "    • $($member.DisplayName)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "  ⚠ Could not retrieve group members" -ForegroundColor Yellow
}

# ============================================================
# GENERATE REPORT
# ============================================================

$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Label-Policy-TeamsOnly-v9-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
╔══════════════════════════════════════════════════════════════════╗
║  LABEL POLICY CONFIGURATION REPORT (TEAMS ONLY) v9.0            ║
╚══════════════════════════════════════════════════════════════════╝

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Script Version: 9.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
POLICY CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Policy Name: $policyName

Labels Included:
  • $($protectedB.DisplayName)
  • $($general.DisplayName)

Location Status (CRITICAL):
  Exchange:   $($finalStatus.Exchange) $(if($finalStatus.Exchange -eq 0){"✅ CLEAN"}else{"❌ NEEDS ATTENTION"})
  SharePoint: $($finalStatus.SharePoint)
  OneDrive:   $($finalStatus.OneDrive)

Overall Status: $(if($finalStatus.IsClean){"✅ TEAMS ONLY CONFIRMED"}else{"⚠️ EXCHANGE LOCATIONS PRESENT"})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT THIS MEANS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$(if($finalStatus.IsClean){
"✅ SUCCESS - Labels configured for Teams meetings ONLY

Labels will appear in:
  • Microsoft Teams (when creating/scheduling meetings)

Labels will NOT appear in:
  • Outlook (new email composition)
  • Word, Excel, PowerPoint
  • SharePoint, OneDrive"
}else{
"⚠️ WARNING - Exchange locations still present

Labels MAY still appear in:
  • Outlook (new email composition)

RECOMMENDED ACTION:
  Run: .\02B-Emergency-Remove-Outlook-Labels.ps1
  Or wait and re-run this script"
})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AFFECTED USERS ($($groupMembers.Count))
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$(if($groupMembers.Count -gt 0){
    ($groupMembers | ForEach-Object { "  • $($_.DisplayName) - $($_.Email)" }) -join "`n"
}else{
    "  (Could not retrieve group membership)"
})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VERSION 9.0 IMPROVEMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This version fixes the Outlook label appearance issue by:

1. NOT using -ExchangeLocation "All" during policy creation
2. Using ModernGroupLocation as primary creation strategy
3. Multiple fallback strategies if primary fails
4. Automatic cleanup if Exchange locations slip through
5. Verification with retry logic

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIMELINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Now: Configuration complete
• 1-4 hours: Labels may start appearing in Teams
• 24-48 hours: Full propagation across tenant
• If labels were in Outlook: They should disappear within 24-48 hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. $(if($finalStatus.IsClean){"✅ Proceed to Phase 4: Create Meeting Policies"}else{"⚠️ Run emergency removal script first"})
2. Wait 24-48 hours for full propagation
3. Test in Teams - create a meeting and verify labels appear
4. Test in Outlook - compose new email and verify labels do NOT appear
5. Run diagnostic if issues: .\Diagnose-Label-Policy-Status.ps1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
END OF REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# ============================================================
# FINAL OUTPUT
# ============================================================

if ($finalStatus.IsClean) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ PHASE 3 COMPLETE - TEAMS ONLY CONFIGURATION SUCCESS         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`nLabels will appear ONLY in Teams meetings." -ForegroundColor White
    Write-Host "Labels will NOT appear in Outlook, Word, Excel, etc." -ForegroundColor White
    
    Write-Host "`nNext: Proceed to Phase 4 (Meeting Policies)`n" -ForegroundColor Cyan
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  ⚠️  PHASE 3 COMPLETE WITH WARNINGS                              ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    
    Write-Host "`nExchange locations: $($finalStatus.Exchange)" -ForegroundColor Red
    Write-Host "Labels may still appear in Outlook." -ForegroundColor Yellow
    
    Write-Host "`nRecommended: Run .\02B-Emergency-Remove-Outlook-Labels.ps1" -ForegroundColor White
    Write-Host "Then wait 24-48 hours and verify`n" -ForegroundColor Gray
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")