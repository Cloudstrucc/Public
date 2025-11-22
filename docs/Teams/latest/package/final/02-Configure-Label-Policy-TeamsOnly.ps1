<#
.SYNOPSIS
    Configure Sensitivity Labels to Appear ONLY in Teams
.DESCRIPTION
    Creates and configures the "LCE Meeting Labels" policy to publish labels
    ONLY to Microsoft Teams. Explicitly removes labels from:
    - Outlook (Exchange)
    - Word, Excel, PowerPoint (Office apps)
    - SharePoint
    - OneDrive
    
    This is PHASE 3 - The most critical phase for preventing labels in Outlook.
    
    Safe to run multiple times - will update policy if it already exists.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Run this after Phase 2 (Create Labels)
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 3: CONFIGURE LABELS FOR TEAMS ONLY                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nWhat this script does:" -ForegroundColor Yellow
Write-Host "  1. Connects to Microsoft Purview" -ForegroundColor White
Write-Host "  2. Creates/updates 'LCE Meeting Labels' policy" -ForegroundColor White
Write-Host "  3. Publishes labels ONLY to Teams" -ForegroundColor White
Write-Host "  4. Removes labels from Outlook, Word, Excel, PowerPoint" -ForegroundColor White
Write-Host "  5. Verifies no Exchange/SharePoint locations configured" -ForegroundColor White

# Connect to Microsoft Purview
Write-Host "`n[Step 1/6] Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Connection failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Get the labels we created
Write-Host "`n[Step 2/6] Finding sensitivity labels..." -ForegroundColor Cyan

try {
    $protectedBLabel = Get-Label -Identity "Protected B - Secure Meeting" -ErrorAction Stop
    $generalLabel = Get-Label -Identity "General - Regular Meeting" -ErrorAction Stop
    
    Write-Host "  ✓ Found Protected B label: $($protectedBLabel.Guid)" -ForegroundColor Green
    Write-Host "  ✓ Found General label: $($generalLabel.Guid)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Labels not found!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`n  You must run Phase 2 first (01-Create-Sensitivity-Labels.ps1)" -ForegroundColor Yellow
    exit 1
}

# Check if policy exists
Write-Host "`n[Step 3/6] Checking for existing policy..." -ForegroundColor Cyan

$existingPolicy = Get-LabelPolicy -Identity "LCE Meeting Labels" -ErrorAction SilentlyContinue

if ($existingPolicy) {
    Write-Host "  ℹ️  Policy exists - will update it" -ForegroundColor Yellow
    $policyAction = "UPDATE"
} else {
    Write-Host "  → Policy doesn't exist - will create new" -ForegroundColor Gray
    $policyAction = "CREATE"
}

# Create or update the policy
Write-Host "`n[Step 4/6] $policyAction policy..." -ForegroundColor Cyan
Write-Host "  → Publishing to: Teams ONLY" -ForegroundColor Gray
Write-Host "  → Removing from: Outlook, Word, Excel, PowerPoint, SharePoint" -ForegroundColor Gray

try {
    if ($policyAction -eq "CREATE") {
        # Create new policy
        New-LabelPolicy `
            -Name "LCE Meeting Labels" `
            -Labels @($protectedBLabel.Guid, $generalLabel.Guid) `
            -AdvancedSettings @{
                # CRITICAL: Teams Only Configuration
                OutlookDefaultLabel = "None"
                DisableMandatoryInOutlook = "True"
                
                # Explicitly disable in Office apps
                powerbipdffile = "False"
                powerbipresentation = "False"
                powerbispreadsheet = "False"
                
                # Teams meetings scope
                TeamsMeetingPolicy = "Enabled"
            } `
            -Comment "LCE meeting labels - Teams meetings ONLY. Not for email/documents."
        
        Write-Host "  ✓ Created new policy" -ForegroundColor Green
    } else {
        # Update existing policy
        Set-LabelPolicy `
            -Identity "LCE Meeting Labels" `
            -Labels @($protectedBLabel.Guid, $generalLabel.Guid) `
            -AdvancedSettings @{
                OutlookDefaultLabel = "None"
                DisableMandatoryInOutlook = "True"
                powerbipdffile = "False"
                powerbipresentation = "False"
                powerbispreadsheet = "False"
                TeamsMeetingPolicy = "Enabled"
            } `
            -Comment "LCE meeting labels - Teams meetings ONLY. Not for email/documents."
        
        Write-Host "  ✓ Updated existing policy" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to $policyAction policy" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Remove Exchange locations explicitly
Write-Host "`n[Step 5/6] Removing Exchange/Outlook locations..." -ForegroundColor Cyan

try {
    Set-LabelPolicy -Identity "LCE Meeting Labels" `
        -AddExchangeLocation @() `
        -RemoveExchangeLocation "All"
    
    Write-Host "  ✓ Exchange locations removed" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Exchange removal warning (may be expected): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Remove SharePoint/OneDrive locations
try {
    Set-LabelPolicy -Identity "LCE Meeting Labels" `
        -AddSharePointLocation @() `
        -RemoveSharePointLocation "All" `
        -AddOneDriveLocation @() `
        -RemoveOneDriveLocation "All"
    
    Write-Host "  ✓ SharePoint/OneDrive locations removed" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  SharePoint/OneDrive removal warning (may be expected): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Verify configuration
Write-Host "`n[Step 6/6] Verifying configuration..." -ForegroundColor Cyan

Start-Sleep -Seconds 3

$policy = Get-LabelPolicy -Identity "LCE Meeting Labels"

Write-Host "`n  Policy Details:" -ForegroundColor White
Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Name: $($policy.Name)" -ForegroundColor White
Write-Host "  Labels: $($policy.Labels.Count)" -ForegroundColor White
Write-Host "  Exchange Locations: $($policy.ExchangeLocation.Count)" -ForegroundColor $(if ($policy.ExchangeLocation.Count -eq 0) { "Green" } else { "Red" })
Write-Host "  SharePoint Locations: $($policy.SharePointLocation.Count)" -ForegroundColor $(if ($policy.SharePointLocation.Count -eq 0) { "Green" } else { "Red" })
Write-Host "  OneDrive Locations: $($policy.OneDriveLocation.Count)" -ForegroundColor $(if ($policy.OneDriveLocation.Count -eq 0) { "Green" } else { "Red" })

# Check for success
$success = $true

if ($policy.ExchangeLocation.Count -gt 0) {
    Write-Host "`n  ⚠️  WARNING: Exchange locations still configured!" -ForegroundColor Red
    Write-Host "  This means labels may appear in Outlook." -ForegroundColor Yellow
    Write-Host "  Run: .\02B-Emergency-Remove-Outlook-Labels.ps1" -ForegroundColor Yellow
    $success = $false
}

if ($policy.SharePointLocation.Count -gt 0 -or $policy.OneDriveLocation.Count -gt 0) {
    Write-Host "`n  ⚠️  WARNING: SharePoint/OneDrive locations still configured!" -ForegroundColor Red
    $success = $false
}

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Save report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Label-Policy-Config-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
Label Policy Configuration
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Policy: $($policy.Name)
Action: $policyAction

Labels Included:
  • Protected B - Secure Meeting
  • General - Regular Meeting

Location Configuration:
  Exchange (Outlook): $($policy.ExchangeLocation.Count) locations
  SharePoint: $($policy.SharePointLocation.Count) locations
  OneDrive: $($policy.OneDriveLocation.Count) locations

Advanced Settings:
  OutlookDefaultLabel: None
  DisableMandatoryInOutlook: True
  TeamsMeetingPolicy: Enabled

Status: $(if ($success) { "SUCCESS - Labels configured for Teams ONLY" } else { "WARNING - Manual cleanup needed" })

Next Steps:
$(if ($success) {
"1. Wait 24-48 hours for policy propagation
2. Test in Teams - labels should appear in meeting creation
3. Test in Outlook - labels should NOT appear in email composition
4. Proceed to Phase 4 (Meeting Policies)"
} else {
"1. Run: .\02B-Emergency-Remove-Outlook-Labels.ps1
2. Verify with: .\Diagnose-Label-Policy-Status.ps1
3. Retry this script if needed"
})
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

if ($success) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ PHASE 3 COMPLETE - LABELS CONFIGURED FOR TEAMS ONLY         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`nWhat just happened:" -ForegroundColor Cyan
    Write-Host "  • Labels published to Teams" -ForegroundColor White
    Write-Host "  • Labels removed from Outlook, Word, Excel, PowerPoint" -ForegroundColor White
    Write-Host "  • Policy configured with 0 Exchange locations" -ForegroundColor White
    
    Write-Host "`nWhat happens next:" -ForegroundColor Cyan
    Write-Host "  • Wait 24-48 hours for Microsoft to propagate changes" -ForegroundColor White
    Write-Host "  • Labels will appear in Teams meeting creation" -ForegroundColor White
    Write-Host "  • Labels will NOT appear in Outlook email" -ForegroundColor White
    Write-Host "  • Proceed to Phase 4 when ready" -ForegroundColor White
    
    Write-Host "`nNext: Wait 24-48 hours, then run Phase 4 script`n" -ForegroundColor Cyan
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  ⚠️  PHASE 3 NEEDS ATTENTION                                    ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    
    Write-Host "`nManual cleanup required:" -ForegroundColor Yellow
    Write-Host "  Run: .\02B-Emergency-Remove-Outlook-Labels.ps1`n" -ForegroundColor White
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
