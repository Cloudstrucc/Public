<#
.SYNOPSIS
    Create Meeting Sensitivity Labels for LCE
.DESCRIPTION
    Creates two sensitivity labels for Teams meetings:
    - Protected B - Secure Meeting (dark red, maximum security)
    - General - Regular Meeting (green, standard collaboration)
    
    IMPORTANT: These labels will ONLY appear in Teams after Phase 3.
    
    Safe to run multiple times - will update labels if they already exist.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Run this ONCE during initial setup
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 2: CREATE SENSITIVITY LABELS                             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nWhat this script does:" -ForegroundColor Yellow
Write-Host "  1. Connects to Microsoft Purview (Security & Compliance)" -ForegroundColor White
Write-Host "  2. Creates 'Protected B - Secure Meeting' label (dark red)" -ForegroundColor White
Write-Host "  3. Creates 'General - Regular Meeting' label (green)" -ForegroundColor White
Write-Host "  4. Verifies both labels exist" -ForegroundColor White
Write-Host "`n  These labels won't appear anywhere yet - Phase 3 publishes them." -ForegroundColor Gray

# Connect to Microsoft Purview
Write-Host "`n[Step 1/4] Connecting to Microsoft Purview..." -ForegroundColor Cyan
Write-Host "  → A sign-in window will appear" -ForegroundColor Gray
Write-Host "  → Use your admin account" -ForegroundColor Gray

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Connection failed" -ForegroundColor Red
    Write-Host "`n  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`n  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "    1. Make sure you're a Global Admin or Compliance Admin" -ForegroundColor White
    Write-Host "    2. Check your internet connection" -ForegroundColor White
    Write-Host "    3. Try running: Install-Module ExchangeOnlineManagement -Force" -ForegroundColor White
    Write-Host "    4. Close PowerShell and try again" -ForegroundColor White
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Create Protected B label
Write-Host "`n[Step 2/4] Creating 'Protected B - Secure Meeting' label..." -ForegroundColor Cyan
Write-Host "  → Color: Dark red (#A4262C)" -ForegroundColor Gray
Write-Host "  → Purpose: Classified/sensitive meetings" -ForegroundColor Gray

try {
    # Check if it already exists
    $existingProtectedB = Get-Label -Identity "Protected B - Secure Meeting" -ErrorAction SilentlyContinue
    
    if ($existingProtectedB) {
        Write-Host "  ℹ️  Label already exists - updating it" -ForegroundColor Yellow
        
        Set-Label -Identity "Protected B - Secure Meeting" `
            -DisplayName "Protected B - Secure Meeting" `
            -Tooltip "Use for classified/sensitive government meetings (Protected B)" `
            -Comment "Protected B classification - Watermarks, restricted lobby, CMK encryption, ALL SETTINGS LOCKED" `
            -AdvancedSettings @{
                color = "#A4262C"
            }
        
        Write-Host "  ✓ Updated existing label" -ForegroundColor Green
    } else {
        Write-Host "  → Creating new label..." -ForegroundColor Gray
        
        New-Label `
            -DisplayName "Protected B - Secure Meeting" `
            -Name "ProtectedB-SecureMeeting" `
            -Tooltip "Use for classified/sensitive government meetings (Protected B)" `
            -Comment "Protected B classification - Watermarks, restricted lobby, CMK encryption, ALL SETTINGS LOCKED" `
            -AdvancedSettings @{
                color = "#A4262C"
            }
        
        Write-Host "  ✓ Created new label" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to create Protected B label" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Create General label
Write-Host "`n[Step 3/4] Creating 'General - Regular Meeting' label..." -ForegroundColor Cyan
Write-Host "  → Color: Green (#107C10)" -ForegroundColor Gray
Write-Host "  → Purpose: Regular, non-classified meetings" -ForegroundColor Gray

try {
    # Check if it already exists
    $existingGeneral = Get-Label -Identity "General - Regular Meeting" -ErrorAction SilentlyContinue
    
    if ($existingGeneral) {
        Write-Host "  ℹ️  Label already exists - updating it" -ForegroundColor Yellow
        
        Set-Label -Identity "General - Regular Meeting" `
            -DisplayName "General - Regular Meeting" `
            -Tooltip "Use for regular, non-classified meetings" `
            -Comment "General/Unclassified - Open collaboration, standard security" `
            -AdvancedSettings @{
                color = "#107C10"
            }
        
        Write-Host "  ✓ Updated existing label" -ForegroundColor Green
    } else {
        Write-Host "  → Creating new label..." -ForegroundColor Gray
        
        New-Label `
            -DisplayName "General - Regular Meeting" `
            -Name "General-RegularMeeting" `
            -Tooltip "Use for regular, non-classified meetings" `
            -Comment "General/Unclassified - Open collaboration, standard security" `
            -AdvancedSettings @{
                color = "#107C10"
            }
        
        Write-Host "  ✓ Created new label" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to create General label" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Verify labels were created
Write-Host "`n[Step 4/4] Verifying labels..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

$allLabels = Get-Label | Where-Object {$_.DisplayName -like "*Meeting"}

if ($allLabels.Count -ge 2) {
    Write-Host "  ✓ Verification successful!" -ForegroundColor Green
    Write-Host "`n  Labels found:" -ForegroundColor White
    foreach ($label in $allLabels) {
        $color = $label.AdvancedSettings.color
        Write-Host "    • $($label.DisplayName)" -ForegroundColor Green
        Write-Host "      Color: $color | Created: $($label.WhenCreated)" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠️  Warning: Expected 2 labels, found $($allLabels.Count)" -ForegroundColor Yellow
}

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Save a simple report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Labels-Created-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
Sensitivity Labels Created
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Labels Created:
$(($allLabels | ForEach-Object { "  • $($_.DisplayName) (Color: $($_.AdvancedSettings.color))" }) -join "`n")

Next Steps:
1. These labels are created but NOT published yet
2. Run Phase 3 script to publish them to Teams
3. After Phase 3, labels will appear ONLY in Teams meeting creation
4. Labels will NOT appear in Outlook, Word, Excel, or PowerPoint
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ PHASE 2 COMPLETE - LABELS CREATED                           ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nWhat just happened:" -ForegroundColor Cyan
Write-Host "  • Two sensitivity labels were created" -ForegroundColor White
Write-Host "  • They exist in Microsoft Purview but aren't published yet" -ForegroundColor White
Write-Host "  • Users cannot see them anywhere (Teams, Outlook, etc.)" -ForegroundColor White

Write-Host "`nWhat happens next:" -ForegroundColor Cyan
Write-Host "  • Run Phase 3 to publish these labels" -ForegroundColor White
Write-Host "  • Phase 3 ensures labels ONLY appear in Teams" -ForegroundColor White
Write-Host "  • After Phase 3, wait 24-48 hours for propagation" -ForegroundColor White

Write-Host "`nNext: Run Phase 3 script (02-Configure-Label-Policy-TeamsOnly.ps1)`n" -ForegroundColor Cyan

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
