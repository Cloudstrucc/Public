<#
.SYNOPSIS
    NUCLEAR OPTION: Delete Entire LCE Meeting Labels Policy
.DESCRIPTION
    ⚠️  WARNING: This completely deletes the label policy.
    
    Use this ONLY if:
    - Emergency script didn't work
    - Exchange locations won't clear
    - You want to start Phase 3 completely fresh
    
    After running this:
    - Labels still exist (won't be deleted)
    - Policy is completely removed
    - You must re-run 02-Configure-Label-Policy-TeamsOnly.ps1
    
    Safe to run - but you'll need to reconfigure the policy.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    This is the FALLBACK - Last resort only
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║  ⚠️⚠️⚠️  NUCLEAR OPTION: DELETE POLICY  ⚠️⚠️⚠️                  ║" -ForegroundColor Red
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red

Write-Host "`n🛑 STOP AND READ THIS:" -ForegroundColor Red
Write-Host "`nThis script will COMPLETELY DELETE the 'LCE Meeting Labels' policy." -ForegroundColor Yellow
Write-Host "`nWhat gets deleted:" -ForegroundColor White
Write-Host "  ✓ The entire label policy" -ForegroundColor Yellow
Write-Host "  ✓ All location assignments" -ForegroundColor Yellow
Write-Host "  ✓ All advanced settings" -ForegroundColor Yellow
Write-Host "`nWhat does NOT get deleted:" -ForegroundColor White
Write-Host "  ✓ The sensitivity labels themselves" -ForegroundColor Green
Write-Host "  ✓ Your distribution group" -ForegroundColor Green
Write-Host "  ✓ Any existing meeting policies" -ForegroundColor Green
Write-Host "`nAfter running this, you must:" -ForegroundColor White
Write-Host "  1. Re-run: 02-Configure-Label-Policy-TeamsOnly.ps1" -ForegroundColor Cyan
Write-Host "  2. Wait 24-48 hours for propagation" -ForegroundColor Cyan
Write-Host "  3. Verify with diagnostic script" -ForegroundColor Cyan

Write-Host "`n❓ Are you absolutely sure you want to delete this policy?" -ForegroundColor Yellow
Write-Host "   Type 'DELETE' (in capitals) to confirm, or Ctrl+C to cancel: " -ForegroundColor White -NoNewline

$confirmation = Read-Host

if ($confirmation -ne "DELETE") {
    Write-Host "`n✋ Cancelled - Policy was NOT deleted" -ForegroundColor Green
    Write-Host "   Exiting safely...`n" -ForegroundColor Gray
    exit 0
}

Write-Host "`n⚠️  Final confirmation: Are you REALLY sure?" -ForegroundColor Red
Write-Host "   Type 'YES DELETE IT' to proceed: " -ForegroundColor White -NoNewline

$finalConfirmation = Read-Host

if ($finalConfirmation -ne "YES DELETE IT") {
    Write-Host "`n✋ Cancelled - Policy was NOT deleted" -ForegroundColor Green
    Write-Host "   Exiting safely...`n" -ForegroundColor Gray
    exit 0
}

Write-Host "`n🔥 Confirmed - Proceeding with deletion..." -ForegroundColor Red

# Connect to Microsoft Purview
Write-Host "`n[Step 1/3] Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Connection failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Get policy details before deletion
Write-Host "`n[Step 2/3] Retrieving policy details before deletion..." -ForegroundColor Cyan

try {
    $policy = Get-LabelPolicy -Identity "LCE Meeting Labels" -ErrorAction Stop
    
    Write-Host "  Policy found:" -ForegroundColor White
    Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  Name: $($policy.Name)" -ForegroundColor White
    Write-Host "  GUID: $($policy.Guid)" -ForegroundColor Gray
    Write-Host "  Created: $($policy.WhenCreated)" -ForegroundColor Gray
    Write-Host "  Labels: $($policy.Labels.Count)" -ForegroundColor White
    Write-Host "  Exchange Locations: $($policy.ExchangeLocation.Count)" -ForegroundColor White
    Write-Host "  SharePoint Locations: $($policy.SharePointLocation.Count)" -ForegroundColor White
    Write-Host "  OneDrive Locations: $($policy.OneDriveLocation.Count)" -ForegroundColor White
    
} catch {
    Write-Host "  ℹ️  Policy 'LCE Meeting Labels' not found" -ForegroundColor Yellow
    Write-Host "  Nothing to delete - policy doesn't exist" -ForegroundColor Gray
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

# Delete the policy
Write-Host "`n[Step 3/3] Deleting policy..." -ForegroundColor Red

try {
    Remove-LabelPolicy -Identity "LCE Meeting Labels" -Confirm:$false -ErrorAction Stop
    Write-Host "  ✓ Policy deleted successfully" -ForegroundColor Green
    $deletionSuccess = $true
} catch {
    Write-Host "  ✗ Deletion failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    $deletionSuccess = $false
}

# Verify deletion
if ($deletionSuccess) {
    Write-Host "`n[Verification] Confirming deletion..." -ForegroundColor Cyan
    
    Start-Sleep -Seconds 2
    
    $checkPolicy = Get-LabelPolicy -Identity "LCE Meeting Labels" -ErrorAction SilentlyContinue
    
    if ($checkPolicy) {
        Write-Host "  ⚠️  Policy still exists (may be delayed)" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Confirmed - Policy no longer exists" -ForegroundColor Green
    }
}

# Check that labels still exist
Write-Host "`n[Verification] Checking labels still exist..." -ForegroundColor Cyan

try {
    $protectedBLabel = Get-Label -Identity "Protected B - Official Sensitive - NATO" -ErrorAction SilentlyContinue
    $generalLabel = Get-Label -Identity "Unclassified" -ErrorAction SilentlyContinue
    
    if ($protectedBLabel -and $generalLabel) {
        Write-Host "  ✓ Labels still exist (good - they weren't deleted)" -ForegroundColor Green
        Write-Host "    • Protected B - Official Sensitive - NATO" -ForegroundColor Gray
        Write-Host "    • Unclassified" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠️  One or both labels missing" -ForegroundColor Yellow
        Write-Host "    You may need to re-run: 01-Create-Sensitivity-Labels.ps1" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Error checking labels: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Save report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Policy-Deletion-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
LCE Meeting Labels Policy Deletion
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Policy Deleted: LCE Meeting Labels
Deletion Status: $(if ($deletionSuccess) { "SUCCESS" } else { "FAILED" })

Policy Details (Before Deletion):
  Name: $($policy.Name)
  GUID: $($policy.Guid)
  Created: $($policy.WhenCreated)
  Labels: $($policy.Labels.Count)
  Exchange Locations: $($policy.ExchangeLocation.Count)
  SharePoint Locations: $($policy.SharePointLocation.Count)
  OneDrive Locations: $($policy.OneDriveLocation.Count)

Labels Still Exist:
  • Protected B - Official Sensitive - NATO: $(if ($protectedBLabel) { "Yes" } else { "No" })
  • Unclassified: $(if ($generalLabel) { "Yes" } else { "No" })

REQUIRED NEXT STEPS:
1. Re-run: 02-Configure-Label-Policy-TeamsOnly.ps1
   This will recreate the policy with correct Teams-only configuration
   
2. Wait 24-48 hours for Microsoft propagation

3. Verify with: .\Diagnose-Label-Policy-Status.ps1
   Ensure Exchange locations = 0

4. Test in Teams and Outlook
   - Teams: Labels should appear in meeting creation
   - Outlook: Labels should NOT appear in email

5. If labels still missing, verify:
   - Labels exist (run 01-Create-Sensitivity-Labels.ps1 if needed)
   - Policy was recreated successfully
   - Sufficient time for propagation
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

if ($deletionSuccess) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ POLICY DELETED SUCCESSFULLY                                 ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`nWhat just happened:" -ForegroundColor Cyan
    Write-Host "  • 'LCE Meeting Labels' policy completely removed" -ForegroundColor White
    Write-Host "  • Labels still exist (Protected B and General)" -ForegroundColor White
    Write-Host "  • All location assignments cleared" -ForegroundColor White
    
    Write-Host "`nCRITICAL - You must now:" -ForegroundColor Red
    Write-Host "  1. Re-run: .\02-Configure-Label-Policy-TeamsOnly.ps1" -ForegroundColor Yellow
    Write-Host "     This recreates the policy with correct Teams-only settings" -ForegroundColor Gray
    Write-Host "`n  2. Wait 24-48 hours for propagation" -ForegroundColor Yellow
    Write-Host "`n  3. Verify: .\Diagnose-Label-Policy-Status.ps1" -ForegroundColor Yellow
    Write-Host "     Confirm Exchange locations = 0" -ForegroundColor Gray
    
    Write-Host "`nWithout step 1, labels won't appear anywhere!`n" -ForegroundColor Red
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║  ❌ POLICY DELETION FAILED                                      ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    
    Write-Host "`nDeletion failed - possible reasons:" -ForegroundColor Yellow
    Write-Host "  • Insufficient permissions" -ForegroundColor White
    Write-Host "  • Policy is in use" -ForegroundColor White
    Write-Host "  • Microsoft 365 sync issue" -ForegroundColor White
    
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Verify you're a Global Admin or Compliance Admin" -ForegroundColor White
    Write-Host "  2. Try again in 5-10 minutes" -ForegroundColor White
    Write-Host "  3. Contact Microsoft Support if issue persists" -ForegroundColor White
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
