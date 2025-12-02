<#
.SYNOPSIS
    Remove Outlook From LCE Meeting Labels - Focused Tool
.DESCRIPTION
    Focused script specifically for removing Outlook/Exchange locations
    from the LCE Meeting Labels policy.
    
    This is a simplified, targeted version of the emergency script.
    Use when you just need to clean up Exchange locations.
    
    Safe to run multiple times.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Focused on Exchange/Outlook removal only
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  REMOVE OUTLOOK FROM LCE MEETING LABELS                         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nPurpose: Remove Exchange/Outlook locations from label policy" -ForegroundColor Yellow
Write-Host "Result: Labels will NOT appear in Outlook email composition`n" -ForegroundColor Yellow

# Connect to Microsoft Purview
Write-Host "[Step 1/3] Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "✓ Connected`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Connection failed: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# Get current policy state
Write-Host "[Step 2/3] Checking current configuration..." -ForegroundColor Cyan

try {
    $policy = Get-LabelPolicy -Identity "LCE Meeting Labels" -ErrorAction Stop
    
    Write-Host "Current state:" -ForegroundColor White
    Write-Host "  Exchange locations: $($policy.ExchangeLocation.Count)" -ForegroundColor $(if ($policy.ExchangeLocation.Count -eq 0) { "Green" } else { "Yellow" })
    Write-Host "  SharePoint locations: $($policy.SharePointLocation.Count)" -ForegroundColor Gray
    Write-Host "  OneDrive locations: $($policy.OneDriveLocation.Count)`n" -ForegroundColor Gray
    
    if ($policy.ExchangeLocation.Count -eq 0) {
        Write-Host "✓ Exchange already clean - no action needed" -ForegroundColor Green
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "`nPress any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
    
} catch {
    Write-Host "✗ Policy not found: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Run 02-Configure-Label-Policy-TeamsOnly.ps1 first`n" -ForegroundColor Yellow
    exit 1
}

# Remove Exchange locations
Write-Host "[Step 3/3] Removing Exchange locations..." -ForegroundColor Cyan

$methods = @(
    @{Name="Clear All"; Command={Set-LabelPolicy -Identity "LCE Meeting Labels" -RemoveExchangeLocation "All"}},
    @{Name="Force Empty"; Command={Set-LabelPolicy -Identity "LCE Meeting Labels" -AddExchangeLocation @()}},
    @{Name="Disable Advanced"; Command={
        Set-LabelPolicy -Identity "LCE Meeting Labels" -AdvancedSettings @{
            OutlookDefaultLabel = "None"
            DisableMandatoryInOutlook = "True"
        }
    }}
)

foreach ($method in $methods) {
    Write-Host "  Trying: $($method.Name)..." -ForegroundColor Gray
    try {
        & $method.Command
        Write-Host "  ✓ Success" -ForegroundColor Green
    } catch {
        Write-Host "  ~ Warning: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Verify
Write-Host "`nVerifying..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

$verifyPolicy = Get-LabelPolicy -Identity "LCE Meeting Labels"

Write-Host "`nFinal state:" -ForegroundColor White
Write-Host "  Exchange locations: $($verifyPolicy.ExchangeLocation.Count)" -ForegroundColor $(if ($verifyPolicy.ExchangeLocation.Count -eq 0) { "Green" } else { "Red" })

$success = $verifyPolicy.ExchangeLocation.Count -eq 0

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Quick report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Outlook-Removal-$(Get-Date -Format 'yyyyMMdd-HHmm').txt"

@"
Outlook Removal - LCE Meeting Labels
$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Before: $($policy.ExchangeLocation.Count) Exchange locations
After: $($verifyPolicy.ExchangeLocation.Count) Exchange locations

Status: $(if ($success) { "SUCCESS" } else { "NEEDS ATTENTION" })

Next: $(if ($success) { "Wait 24-48 hours, test in Outlook" } else { "Run: .\02B-Emergency-Remove-Outlook-Labels.ps1" })
"@ | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 $reportFile" -ForegroundColor Gray

if ($success) {
    Write-Host "`n✅ SUCCESS - Exchange locations removed" -ForegroundColor Green
    Write-Host "Wait 24-48 hours, then verify labels don't appear in Outlook`n" -ForegroundColor White
} else {
    Write-Host "`n⚠️  Exchange locations still present: $($verifyPolicy.ExchangeLocation.Count)" -ForegroundColor Red
    Write-Host "Try: .\02B-Emergency-Remove-Outlook-Labels.ps1`n" -ForegroundColor Yellow
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
