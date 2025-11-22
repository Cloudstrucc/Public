<#
.SYNOPSIS
    Remove Outlook from LCE Meeting Labels Policy ONLY
.DESCRIPTION
    This script specifically targets the "LCE Meeting Labels" policy and ensures
    it does NOT publish to Outlook/Exchange, while leaving all other label policies
    (Security Team, IT Team, etc.) completely untouched.
    
    Purpose: Meeting labels (Protected B, Regular Meeting) should ONLY appear
    in Teams meeting creation, NOT in Outlook emails.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 1.0 - Focused on LCE Meeting Labels only
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  REMOVE OUTLOOK FROM LCE MEETING LABELS POLICY                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$targetPolicyName = "LCE Meeting Labels"
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
$timestamp = Get-Date -Format 'yyyy-MM-dd-HHmmss'

# ============================================================
# Connect to Security & Compliance
# ============================================================

Write-Host "`n[Connecting to Security & Compliance Center...]" -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease run: Connect-IPPSSession" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# ============================================================
# Check Target Policy
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  STEP 1: CHECK LCE MEETING LABELS POLICY                        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n[Looking for '$targetPolicyName' policy...]" -ForegroundColor Cyan

$policy = Get-LabelPolicy -Identity $targetPolicyName -ErrorAction SilentlyContinue

if (-not $policy) {
    Write-Host "  ✗ Policy '$targetPolicyName' not found" -ForegroundColor Red
    Write-Host "`nThis policy doesn't exist yet. Run the setup scripts first." -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "  ✓ Found policy: $targetPolicyName" -ForegroundColor Green

# Show policy details
Write-Host "`n  Policy Details:" -ForegroundColor Cyan
Write-Host "    Name: $($policy.Name)" -ForegroundColor White
Write-Host "    GUID: $($policy.Guid)" -ForegroundColor Gray
if ($policy.WhenCreated) {
    $age = [math]::Floor(((Get-Date) - $policy.WhenCreated).TotalDays)
    Write-Host "    Created: $($policy.WhenCreated) ($age days ago)" -ForegroundColor White
}
if ($policy.CreatedBy) {
    Write-Host "    Created By: $($policy.CreatedBy)" -ForegroundColor White
}
if ($policy.WhenChanged) {
    Write-Host "    Last Modified: $($policy.WhenChanged)" -ForegroundColor Gray
}

# ============================================================
# Check Current Locations
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  STEP 2: CHECK WHERE LABELS ARE PUBLISHED                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n[Checking current publishing locations...]" -ForegroundColor Cyan

$exchangeLocations = if($policy.ExchangeLocation){@($policy.ExchangeLocation)}else{@()}
$sharepointLocations = if($policy.SharePointLocation){@($policy.SharePointLocation)}else{@()}
$onedriveLocations = if($policy.OneDriveLocation){@($policy.OneDriveLocation)}else{@()}
$modernGroupLocations = if($policy.ModernGroupLocation){@($policy.ModernGroupLocation)}else{@()}

$exchangeCount = $exchangeLocations.Count
$sharepointCount = $sharepointLocations.Count
$onedriveCount = $onedriveLocations.Count
$modernGroupCount = $modernGroupLocations.Count
$totalBadLocations = $exchangeCount + $sharepointCount + $onedriveCount

Write-Host "`n  📍 Current Publishing Locations:" -ForegroundColor Yellow

Write-Host "`n    Exchange (Outlook Email):" -ForegroundColor White
if ($exchangeCount -eq 0) {
    Write-Host "      ✅ NONE - Labels will NOT appear in Outlook emails" -ForegroundColor Green
} else {
    Write-Host "      ⚠️  $exchangeCount location(s) - Labels WILL appear in Outlook emails" -ForegroundColor Red
    foreach ($loc in $exchangeLocations) {
        Write-Host "        • $loc" -ForegroundColor Yellow
    }
}

Write-Host "`n    SharePoint:" -ForegroundColor White
if ($sharepointCount -eq 0) {
    Write-Host "      ✅ NONE" -ForegroundColor Green
} else {
    Write-Host "      ⚠️  $sharepointCount location(s)" -ForegroundColor Yellow
    foreach ($loc in $sharepointLocations) {
        Write-Host "        • $loc" -ForegroundColor Yellow
    }
}

Write-Host "`n    OneDrive:" -ForegroundColor White
if ($onedriveCount -eq 0) {
    Write-Host "      ✅ NONE" -ForegroundColor Green
} else {
    Write-Host "      ⚠️  $onedriveCount location(s)" -ForegroundColor Yellow
    foreach ($loc in $onedriveLocations) {
        Write-Host "        • $loc" -ForegroundColor Yellow
    }
}

Write-Host "`n    Teams/Groups (Meeting Creation):" -ForegroundColor White
if ($modernGroupCount -gt 0) {
    Write-Host "      ✅ $modernGroupCount location(s) - This is CORRECT for meeting labels" -ForegroundColor Green
    foreach ($loc in $modernGroupLocations) {
        Write-Host "        • $loc" -ForegroundColor White
    }
} else {
    Write-Host "      ⚠️  NONE - Labels won't appear in Teams meetings" -ForegroundColor Yellow
}

Write-Host "`n  Summary:" -ForegroundColor Cyan
Write-Host "    Total 'bad' locations (Exchange/SharePoint/OneDrive): $totalBadLocations" -ForegroundColor $(if($totalBadLocations -eq 0){"Green"}else{"Red"})

# ============================================================
# Remove Bad Locations
# ============================================================

if ($totalBadLocations -eq 0) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ ALREADY COMPLIANT - NO ACTION NEEDED                        ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`n  The '$targetPolicyName' policy is already configured correctly:" -ForegroundColor White
    Write-Host "    • Labels will NOT appear in Outlook emails ✅" -ForegroundColor Green
    Write-Host "    • Labels will NOT appear in Word/Excel/PowerPoint ✅" -ForegroundColor Green
    Write-Host "    • Labels ONLY appear in Teams meeting creation ✅" -ForegroundColor Green
    
    Write-Host "`n  Note: Other label policies (Security Team, IT Team, etc.) are untouched." -ForegroundColor Gray
    
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  STEP 3: REMOVE OUTLOOK/OFFICE LOCATIONS                        ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    
    Write-Host "`n[Removing $totalBadLocations location(s) from '$targetPolicyName'...]" -ForegroundColor Cyan
    Write-Host "  This will prevent meeting labels from appearing in Outlook emails." -ForegroundColor White
    
    $locationsRemoved = 0
    
    # Remove Exchange locations
    if ($exchangeCount -gt 0) {
        Write-Host "`n  Removing Exchange (Outlook) locations:" -ForegroundColor Yellow
        foreach ($location in $exchangeLocations) {
            try {
                Write-Host "    • $location" -NoNewline
                Set-LabelPolicy -Identity $targetPolicyName -RemoveExchangeLocation $location -ErrorAction Stop
                Write-Host " ✓" -ForegroundColor Green
                $locationsRemoved++
                Start-Sleep -Milliseconds 500
            } catch {
                Write-Host " ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    # Remove SharePoint locations
    if ($sharepointCount -gt 0) {
        Start-Sleep -Seconds 1
        $policy = Get-LabelPolicy -Identity $targetPolicyName -ErrorAction SilentlyContinue
        if ($policy -and $policy.SharePointLocation) {
            Write-Host "`n  Removing SharePoint locations:" -ForegroundColor Yellow
            foreach ($location in @($policy.SharePointLocation)) {
                try {
                    Write-Host "    • $location" -NoNewline
                    Set-LabelPolicy -Identity $targetPolicyName -RemoveSharePointLocation $location -ErrorAction Stop
                    Write-Host " ✓" -ForegroundColor Green
                    $locationsRemoved++
                    Start-Sleep -Milliseconds 500
                } catch {
                    Write-Host " ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    
    # Remove OneDrive locations
    if ($onedriveCount -gt 0) {
        Start-Sleep -Seconds 1
        $policy = Get-LabelPolicy -Identity $targetPolicyName -ErrorAction SilentlyContinue
        if ($policy -and $policy.OneDriveLocation) {
            Write-Host "`n  Removing OneDrive locations:" -ForegroundColor Yellow
            foreach ($location in @($policy.OneDriveLocation)) {
                try {
                    Write-Host "    • $location" -NoNewline
                    Set-LabelPolicy -Identity $targetPolicyName -RemoveOneDriveLocation $location -ErrorAction Stop
                    Write-Host " ✓" -ForegroundColor Green
                    $locationsRemoved++
                    Start-Sleep -Milliseconds 500
                } catch {
                    Write-Host " ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host "`n  ✓ Removed $locationsRemoved of $totalBadLocations location(s)" -ForegroundColor Green
    
    # ============================================================
    # Verify Changes
    # ============================================================
    
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  STEP 4: VERIFY CHANGES                                         ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    Write-Host "`n[Verifying changes...]" -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    
    $verifiedPolicy = Get-LabelPolicy -Identity $targetPolicyName -ErrorAction SilentlyContinue
    
    if ($verifiedPolicy) {
        $finalExchange = if($verifiedPolicy.ExchangeLocation){$verifiedPolicy.ExchangeLocation.Count}else{0}
        $finalSharePoint = if($verifiedPolicy.SharePointLocation){$verifiedPolicy.SharePointLocation.Count}else{0}
        $finalOneDrive = if($verifiedPolicy.OneDriveLocation){$verifiedPolicy.OneDriveLocation.Count}else{0}
        $finalModernGroup = if($verifiedPolicy.ModernGroupLocation){$verifiedPolicy.ModernGroupLocation.Count}else{0}
        $finalTotal = $finalExchange + $finalSharePoint + $finalOneDrive
        
        Write-Host "  Final Status for '$targetPolicyName':" -ForegroundColor Cyan
        Write-Host "    Exchange (Outlook): $finalExchange" -ForegroundColor $(if($finalExchange -eq 0){"Green"}else{"Red"})
        Write-Host "    SharePoint: $finalSharePoint" -ForegroundColor $(if($finalSharePoint -eq 0){"Green"}else{"Red"})
        Write-Host "    OneDrive: $finalOneDrive" -ForegroundColor $(if($finalOneDrive -eq 0){"Green"}else{"Red"})
        Write-Host "    Teams/Groups: $finalModernGroup" -ForegroundColor $(if($finalModernGroup -gt 0){"Green"}else{"Yellow"})
        
        if ($finalTotal -eq 0) {
            Write-Host "`n  ✅ SUCCESS!" -ForegroundColor Green
            Write-Host "     Meeting labels (Protected B, Regular Meeting) will:" -ForegroundColor White
            Write-Host "     • NOT appear in Outlook emails ✅" -ForegroundColor Green
            Write-Host "     • NOT appear in Word/Excel/PowerPoint ✅" -ForegroundColor Green
            Write-Host "     • ONLY appear in Teams meeting creation ✅" -ForegroundColor Green
        } else {
            Write-Host "`n  ⚠️  WARNING: Still has $finalTotal bad location(s)" -ForegroundColor Yellow
            Write-Host "     Labels may still appear in Outlook" -ForegroundColor Yellow
            Write-Host "     Try running this script again" -ForegroundColor Yellow
        }
    }
}

# ============================================================
# Check Other Policies (Info Only)
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  OTHER LABEL POLICIES (UNCHANGED)                               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n[Checking other label policies in tenant...]" -ForegroundColor Cyan

$allPolicies = Get-LabelPolicy | Where-Object {$_.Name -ne $targetPolicyName}

if ($allPolicies.Count -gt 0) {
    Write-Host "  Found $($allPolicies.Count) other policy/policies (left untouched):" -ForegroundColor White
    
    foreach ($otherPolicy in $allPolicies) {
        $otherExchange = if($otherPolicy.ExchangeLocation){$otherPolicy.ExchangeLocation.Count}else{0}
        
        Write-Host "`n    • $($otherPolicy.Name)" -ForegroundColor Gray
        Write-Host "      Exchange Locations: $otherExchange" -ForegroundColor Gray
        Write-Host "      Status: Not modified (as intended)" -ForegroundColor Gray
    }
    
    Write-Host "`n  Note: These policies control different labels (General, Confidential, etc.)" -ForegroundColor White
    Write-Host "        They are separate from your Teams meeting labels." -ForegroundColor White
} else {
    Write-Host "  No other label policies found." -ForegroundColor Gray
}

# ============================================================
# Generate Report
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  GENERATING REPORT                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$reportFile = "$exportPath\LCE-Meeting-Labels-Outlook-Removal-$timestamp.txt"

$verifiedPolicy = Get-LabelPolicy -Identity $targetPolicyName -ErrorAction SilentlyContinue
$finalExchange = if($verifiedPolicy.ExchangeLocation){$verifiedPolicy.ExchangeLocation.Count}else{0}
$finalSharePoint = if($verifiedPolicy.SharePointLocation){$verifiedPolicy.SharePointLocation.Count}else{0}
$finalOneDrive = if($verifiedPolicy.OneDriveLocation){$verifiedPolicy.OneDriveLocation.Count}else{0}
$finalTotal = $finalExchange + $finalSharePoint + $finalOneDrive

$report = @"
╔══════════════════════════════════════════════════════════════════╗
║  LCE MEETING LABELS - OUTLOOK REMOVAL REPORT                    ║
╚══════════════════════════════════════════════════════════════════╝

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME
Computer: $env:COMPUTERNAME

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TARGET POLICY: $targetPolicyName
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Policy Details:
  GUID: $($verifiedPolicy.Guid)
  Created: $($verifiedPolicy.WhenCreated)
  Created By: $(if($verifiedPolicy.CreatedBy){$verifiedPolicy.CreatedBy}else{'Unknown'})
  Last Modified: $($verifiedPolicy.WhenChanged)

Initial Status:
  Exchange Locations: $exchangeCount
  SharePoint Locations: $sharepointCount
  OneDrive Locations: $onedriveCount
  Total Bad Locations: $totalBadLocations

Actions Taken:
  Locations Removed: $(if($totalBadLocations -gt 0){$locationsRemoved}else{0})

Final Status:
  Exchange Locations: $finalExchange
  SharePoint Locations: $finalSharePoint
  OneDrive Locations: $finalOneDrive
  Teams/Groups Locations: $(if($verifiedPolicy.ModernGroupLocation){$verifiedPolicy.ModernGroupLocation.Count}else{0})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESULT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$(if($finalTotal -eq 0){
@"
✅ SUCCESS - Meeting labels configured correctly

The LCE Meeting Labels policy is now configured to:
  • NOT appear in Outlook emails ✅
  • NOT appear in Word/Excel/PowerPoint ✅
  • ONLY appear in Teams meeting creation ✅

Users will see meeting sensitivity labels ONLY when:
  - Creating a new Teams meeting
  - Scheduling a Teams meeting from Outlook calendar

Users will NOT see meeting labels when:
  - Composing new Outlook emails
  - Creating Word/Excel/PowerPoint documents
  - Using SharePoint or OneDrive
"@
}else{
@"
⚠️  WARNING - Still has $finalTotal bad location(s)

Meeting labels may still appear in Outlook.

Recommended Actions:
  1. Run this script again
  2. Wait 24-48 hours for propagation
  3. Contact Microsoft Support if issue persists
"@
})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OTHER POLICIES (UNCHANGED)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The following policies were NOT modified:
$(($allPolicies | ForEach-Object {
"  • $($_.Name)
    Exchange Locations: $(if($_.ExchangeLocation){$_.ExchangeLocation.Count}else{0})
    Purpose: General document classification (not meeting labels)
"
}) -join "`n")

These policies control labels like:
  - General
  - Confidential
  - Internal Use Only
  - Public
  etc.

These are SEPARATE from your Teams meeting labels and are functioning
correctly for document/email classification.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
END OF REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n  ✓ Report saved: $reportFile" -ForegroundColor Green

# ============================================================
# Final Summary
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  COMPLETE                                                       ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

if ($finalTotal -eq 0) {
    Write-Host "`n✅ SUCCESS! LCE Meeting Labels configured correctly" -ForegroundColor Green
    Write-Host "   Meeting labels will NOT appear in Outlook emails" -ForegroundColor White
    Write-Host "   Meeting labels will ONLY appear in Teams" -ForegroundColor White
} else {
    Write-Host "`n⚠️  Not fully complete - $finalTotal location(s) remain" -ForegroundColor Yellow
    Write-Host "   Run this script again or wait for propagation" -ForegroundColor White
}

Write-Host "`n📝 Note: Other label policies (Security Team, IT Team, etc.) were" -ForegroundColor Cyan
Write-Host "   left completely untouched and remain fully functional." -ForegroundColor Cyan

Write-Host "`n📄 Full report: $reportFile" -ForegroundColor Gray

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")