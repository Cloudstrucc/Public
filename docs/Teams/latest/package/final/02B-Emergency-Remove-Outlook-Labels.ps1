<#
.SYNOPSIS
    Emergency: Remove Labels from Outlook
.DESCRIPTION
    If labels are appearing in Outlook after Phase 3, this script
    forcefully removes all Exchange locations from the policy.
    
    This is the EMERGENCY script - use if verification shows Exchange
    locations still configured.
    
    Safe to run multiple times.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Run this ONLY if labels appear in Outlook after Phase 3
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║  EMERGENCY: REMOVE LABELS FROM OUTLOOK                          ║" -ForegroundColor Red
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red

Write-Host "`n⚠️  WARNING: You should only run this if:" -ForegroundColor Yellow
Write-Host "  • Labels are appearing in Outlook email composition" -ForegroundColor White
Write-Host "  • Verification showed Exchange locations > 0" -ForegroundColor White
Write-Host "  • Phase 3 script didn't fully remove Outlook" -ForegroundColor White

Write-Host "`nPress any key to continue or Ctrl+C to cancel..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Connect to Microsoft Purview
Write-Host "`n[Step 1/4] Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Connection failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Get the policy
Write-Host "`n[Step 2/4] Finding LCE Meeting Labels policy..." -ForegroundColor Cyan

try {
    $policy = Get-LabelPolicy -Identity "LCE Meeting Labels" -ErrorAction Stop
    Write-Host "  ✓ Found policy" -ForegroundColor Green
    Write-Host "  Current Exchange locations: $($policy.ExchangeLocation.Count)" -ForegroundColor $(if ($policy.ExchangeLocation.Count -eq 0) { "Green" } else { "Yellow" })
} catch {
    Write-Host "  ✗ Policy not found!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`n  You must run Phase 3 first (02-Configure-Label-Policy-TeamsOnly.ps1)" -ForegroundColor Yellow
    exit 1
}

# Remove Exchange locations - Method 1
Write-Host "`n[Step 3/4] Removing Exchange locations (Method 1)..." -ForegroundColor Cyan

try {
    Set-LabelPolicy -Identity "LCE Meeting Labels" `
        -RemoveExchangeLocation "All" `
        -ErrorAction Stop
    
    Write-Host "  ✓ Removed all Exchange locations" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Method 1 warning: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Remove Exchange locations - Method 2 (force empty array)
Write-Host "`n[Step 3B/4] Removing Exchange locations (Method 2 - Force)..." -ForegroundColor Cyan

try {
    Set-LabelPolicy -Identity "LCE Meeting Labels" `
        -AddExchangeLocation @() `
        -ErrorAction Stop
    
    Write-Host "  ✓ Forced Exchange locations to empty" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Method 2 warning: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Set advanced settings to disable Outlook
Write-Host "`n[Step 3C/4] Setting Outlook disable flags..." -ForegroundColor Cyan

try {
    Set-LabelPolicy -Identity "LCE Meeting Labels" `
        -AdvancedSettings @{
            OutlookDefaultLabel = "None"
            DisableMandatoryInOutlook = "True"
            OutlookBlockUntrustedCollaborationLabel = ""
            OutlookBlockTrustedDomains = ""
            OutlookUnlabeledCollaborationAction = "None"
        } `
        -ErrorAction Stop
    
    Write-Host "  ✓ Outlook disabled via advanced settings" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Advanced settings warning: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Verify the fix
Write-Host "`n[Step 4/4] Verifying Exchange removal..." -ForegroundColor Cyan

Start-Sleep -Seconds 3

$verifyPolicy = Get-LabelPolicy -Identity "LCE Meeting Labels"

Write-Host "`n  Verification Results:" -ForegroundColor White
Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Exchange Locations: $($verifyPolicy.ExchangeLocation.Count)" -ForegroundColor $(if ($verifyPolicy.ExchangeLocation.Count -eq 0) { "Green" } else { "Red" })
Write-Host "  SharePoint Locations: $($verifyPolicy.SharePointLocation.Count)" -ForegroundColor $(if ($verifyPolicy.SharePointLocation.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "  OneDrive Locations: $($verifyPolicy.OneDriveLocation.Count)" -ForegroundColor $(if ($verifyPolicy.OneDriveLocation.Count -eq 0) { "Green" } else { "Yellow" })

$success = $verifyPolicy.ExchangeLocation.Count -eq 0

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Save report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Emergency-Outlook-Removal-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
Emergency Outlook Label Removal
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Policy: LCE Meeting Labels

Before Cleanup:
  Exchange Locations: $($policy.ExchangeLocation.Count)

After Cleanup:
  Exchange Locations: $($verifyPolicy.ExchangeLocation.Count)

Methods Applied:
  1. RemoveExchangeLocation "All"
  2. AddExchangeLocation @() (force empty)
  3. Advanced settings: DisableMandatoryInOutlook = True

Result: $(if ($success) { "SUCCESS - Exchange fully removed" } else { "FAILED - Manual intervention needed" })

Next Steps:
$(if ($success) {
"1. Wait 24-48 hours for Microsoft propagation
2. Test in Outlook - labels should NOT appear
3. Test in Teams - labels should still appear
4. If labels still appear in Outlook, run: .\02C-DELETE-LCE-Meeting-Labels-Policy.ps1"
} else {
"1. Run diagnostic: .\Diagnose-Label-Policy-Status.ps1
2. Consider nuclear option: .\02C-DELETE-LCE-Meeting-Labels-Policy.ps1
3. Contact Microsoft Support if issue persists"
})
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

if ($success) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ EMERGENCY FIX SUCCESSFUL                                    ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`nWhat just happened:" -ForegroundColor Cyan
    Write-Host "  • All Exchange locations removed from policy" -ForegroundColor White
    Write-Host "  • Outlook explicitly disabled via advanced settings" -ForegroundColor White
    Write-Host "  • Verification shows 0 Exchange locations" -ForegroundColor White
    
    Write-Host "`nWhat happens next:" -ForegroundColor Cyan
    Write-Host "  • Wait 24-48 hours for changes to propagate" -ForegroundColor White
    Write-Host "  • Clear Outlook cache if labels still appear" -ForegroundColor White
    Write-Host "  • Labels should only appear in Teams" -ForegroundColor White
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║  ❌ EMERGENCY FIX DID NOT FULLY RESOLVE ISSUE                   ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    
    Write-Host "`nExchange locations still configured: $($verifyPolicy.ExchangeLocation.Count)" -ForegroundColor Yellow
    Write-Host "`nNuclear option:" -ForegroundColor Red
    Write-Host "  Run: .\02C-DELETE-LCE-Meeting-Labels-Policy.ps1" -ForegroundColor White
    Write-Host "  This will delete the entire policy and start fresh" -ForegroundColor Yellow
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
