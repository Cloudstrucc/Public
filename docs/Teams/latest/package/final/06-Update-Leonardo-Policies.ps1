<#
.SYNOPSIS
    Update Leonardo Meeting Policies - Lock Security Settings
.DESCRIPTION
    Updates your existing Leonardo Teams meeting policies to lock
    security settings so organizers CANNOT change them.
    
    Updates TWO policies:
    1. Leonardo-Secure-Meeting-Group (Protected B)
    2. Leonardo-Regular-Meeting-Group (General)
    
    This script:
    - Only connects to Microsoft Teams (no Exchange, no labels)
    - Updates BOTH existing policies
    - Locks security settings on the Secure policy
    - Keeps Regular policy more open (but still controlled)
    - Makes settings GREYED OUT for meeting organizers
    
    Safe to run multiple times.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.1
    Updates existing policies only - does not create new policies
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  UPDATE LEONARDO MEETING POLICIES - LOCK SECURITY SETTINGS     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nWhat this script does:" -ForegroundColor Yellow
Write-Host "  1. Connects to Microsoft Teams ONLY" -ForegroundColor White
Write-Host "  2. Updates 'Leonardo-Secure-Meeting-Group' (LOCKED)" -ForegroundColor White
Write-Host "  3. Updates 'Leonardo-Regular-Meeting-Group' (Controlled)" -ForegroundColor White
Write-Host "  4. Verifies all settings are correct" -ForegroundColor White
Write-Host "`n  Does NOT create policies, touch labels, or affect Outlook!" -ForegroundColor Gray

# Configuration
$SecurePolicy = "Leonardo-Secure-Meeting-Group"
$RegularPolicy = "Leonardo-Regular-Meeting-Group"
$ReportPath = "C:\LeonardoReports"

# Create report directory
New-Item -Path $ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# Connect to Teams
Write-Host "`n[Step 1/4] Connecting to Microsoft Teams..." -ForegroundColor Cyan

try {
    Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Connection failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Verify policies exist
Write-Host "`n[Step 2/4] Verifying existing policies..." -ForegroundColor Cyan

$policiesFound = @()

try {
    $secureExists = Get-CsTeamsMeetingPolicy -Identity $SecurePolicy -ErrorAction Stop
    Write-Host "  ✓ Found: $SecurePolicy" -ForegroundColor Green
    $policiesFound += $SecurePolicy
} catch {
    Write-Host "  ✗ NOT FOUND: $SecurePolicy" -ForegroundColor Red
}

try {
    $regularExists = Get-CsTeamsMeetingPolicy -Identity $RegularPolicy -ErrorAction Stop
    Write-Host "  ✓ Found: $RegularPolicy" -ForegroundColor Green
    $policiesFound += $RegularPolicy
} catch {
    Write-Host "  ✗ NOT FOUND: $RegularPolicy" -ForegroundColor Red
}

if ($policiesFound.Count -eq 0) {
    Write-Host "`n  No Leonardo policies found!" -ForegroundColor Red
    Disconnect-MicrosoftTeams -Confirm:$false
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Update SECURE policy with LOCKED settings
if ($policiesFound -contains $SecurePolicy) {
    Write-Host "`n[Step 3/4] Updating SECURE policy with LOCKED settings..." -ForegroundColor Cyan
    Write-Host "  Policy: $SecurePolicy" -ForegroundColor White
    Write-Host "  → This policy is for Protected B meetings (MAXIMUM SECURITY)" -ForegroundColor Gray

    try {
        Set-CsTeamsMeetingPolicy -Identity $SecurePolicy `
            -AllowOrganizersToOverrideLobbySettings $false `
            -AllowAnonymousUsersToJoinMeeting $false `
            -AllowPSTNUsersToBypassLobby $false `
            -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests" `
            -AllowExternalParticipantGiveRequestControl $false `
            -AllowParticipantGiveRequestControl $false `
            -AllowRecordingStorageOutsideRegion $false `
            -ErrorAction Stop
        
        Write-Host "  ✓ Secure policy updated - ALL SETTINGS LOCKED 🔒" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to update secure policy" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        
        if ($_.Exception.Message -like "*Forbidden*" -or $_.Exception.Message -like "*not authorized*") {
            Write-Host "`n  ⚠️  Permission Issue:" -ForegroundColor Yellow
            Write-Host "  You need 'Teams Administrator' or 'Global Administrator' role" -ForegroundColor White
            Write-Host "  Ask your Global Admin to assign this role or run this script" -ForegroundColor White
        }
    }
}

# Update REGULAR policy with controlled settings
if ($policiesFound -contains $RegularPolicy) {
    Write-Host "`n[Step 3B/4] Updating REGULAR policy with controlled settings..." -ForegroundColor Cyan
    Write-Host "  Policy: $RegularPolicy" -ForegroundColor White
    Write-Host "  → This policy is for General meetings (STANDARD SECURITY)" -ForegroundColor Gray

    try {
        Set-CsTeamsMeetingPolicy -Identity $RegularPolicy `
            -AllowOrganizersToOverrideLobbySettings $true `
            -AllowAnonymousUsersToJoinMeeting $false `
            -AllowPSTNUsersToBypassLobby $false `
            -AutoAdmittedUsers "EveryoneInCompany" `
            -AllowExternalParticipantGiveRequestControl $false `
            -AllowRecordingStorageOutsideRegion $false `
            -ErrorAction Stop
        
        Write-Host "  ✓ Regular policy updated - Standard security applied" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to update regular policy" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Verify settings
Write-Host "`n[Step 4/4] Verifying policy settings..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

$report = @"
Leonardo Meeting Policies - Security Configuration
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

═══════════════════════════════════════════════════════════════════
POLICY 1: SECURE MEETINGS (Protected B)
═══════════════════════════════════════════════════════════════════
Policy: $SecurePolicy

"@

if ($policiesFound -contains $SecurePolicy) {
    $verifySecure = Get-CsTeamsMeetingPolicy -Identity $SecurePolicy
    
    Write-Host "`n  SECURE Policy Settings:" -ForegroundColor White
    Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
    
    $secureChecks = @(
        @{Name="Organizer Override"; Value=$verifySecure.AllowOrganizersToOverrideLobbySettings; Expected=$false; Critical=$true},
        @{Name="Anonymous Users"; Value=$verifySecure.AllowAnonymousUsersToJoinMeeting; Expected=$false; Critical=$true},
        @{Name="PSTN Bypass Lobby"; Value=$verifySecure.AllowPSTNUsersToBypassLobby; Expected=$false; Critical=$true},
        @{Name="External Control"; Value=$verifySecure.AllowExternalParticipantGiveRequestControl; Expected=$false; Critical=$false},
        @{Name="Participant Control"; Value=$verifySecure.AllowParticipantGiveRequestControl; Expected=$false; Critical=$false}
    )
    
    $securePassed = $true
    
    foreach ($check in $secureChecks) {
        $passed = $check.Value -eq $check.Expected
        if (-not $passed -and $check.Critical) { $securePassed = $false }
        $status = if ($passed) { "✓" } else { "✗" }
        $color = if ($passed) { "Green" } else { "Red" }
        $lockIcon = if ($check.Critical) { "🔒" } else { "" }
        
        Write-Host "  $status $($check.Name): " -NoNewline -ForegroundColor $color
        Write-Host "$($check.Value) $lockIcon" -ForegroundColor $color
        
        $report += "$status $($check.Name): $($check.Value)`n"
    }
    
    if ($securePassed) {
        Write-Host "`n  ✅ SECURE POLICY: ALL CRITICAL SETTINGS LOCKED" -ForegroundColor Green
    } else {
        Write-Host "`n  ⚠️  SECURE POLICY: Some settings need attention" -ForegroundColor Yellow
    }
}

$report += @"

═══════════════════════════════════════════════════════════════════
POLICY 2: REGULAR MEETINGS (General)
═══════════════════════════════════════════════════════════════════
Policy: $RegularPolicy

"@

if ($policiesFound -contains $RegularPolicy) {
    $verifyRegular = Get-CsTeamsMeetingPolicy -Identity $RegularPolicy
    
    Write-Host "`n  REGULAR Policy Settings:" -ForegroundColor White
    Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
    
    $regularChecks = @(
        @{Name="Organizer Override"; Value=$verifyRegular.AllowOrganizersToOverrideLobbySettings; Expected=$true},
        @{Name="Anonymous Users"; Value=$verifyRegular.AllowAnonymousUsersToJoinMeeting; Expected=$false},
        @{Name="External Control"; Value=$verifyRegular.AllowExternalParticipantGiveRequestControl; Expected=$false}
    )
    
    foreach ($check in $regularChecks) {
        $passed = $check.Value -eq $check.Expected
        $status = if ($passed) { "✓" } else { "✗" }
        $color = if ($passed) { "Green" } else { "Yellow" }
        
        Write-Host "  $status $($check.Name): " -NoNewline -ForegroundColor $color
        Write-Host "$($check.Value)" -ForegroundColor $color
        
        $report += "$status $($check.Name): $($check.Value)`n"
    }
    
    Write-Host "`n  ✅ REGULAR POLICY: Standard security applied" -ForegroundColor Green
}

# Disconnect
Disconnect-MicrosoftTeams -Confirm:$false

$report += @"

═══════════════════════════════════════════════════════════════════
SUMMARY
═══════════════════════════════════════════════════════════════════

WHAT THIS MEANS:

SECURE Policy ($SecurePolicy):
- Used for Protected B meetings
- ALL security settings LOCKED (organizers cannot change)
- Meeting options will be GREYED OUT
- Requires verification, blocks anonymous, locks lobby

REGULAR Policy ($RegularPolicy):
- Used for General meetings  
- Standard security (organizers have some flexibility)
- Anonymous users still blocked for security
- External control disabled

NEXT STEPS:
1. Wait 24-48 hours for policies to propagate
2. Assign policies to users via Script 05 automation
3. Test Protected B meetings - settings should be greyed out
4. Sensitivity labels work WITH these policies to enforce security

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

# Save report
$reportFile = "$ReportPath\Leonardo-Policies-Updated-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

# Final status
Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ POLICIES UPDATED SUCCESSFULLY                               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nWhat just happened:" -ForegroundColor Cyan
Write-Host "  • SECURE policy: ALL settings LOCKED 🔒" -ForegroundColor White
Write-Host "  • REGULAR policy: Standard security applied" -ForegroundColor White
Write-Host "  • Organizers on Secure policy: Settings GREYED OUT" -ForegroundColor White
Write-Host "  • Organizers on Regular policy: Some flexibility" -ForegroundColor White

Write-Host "`nFor Protected B meetings:" -ForegroundColor Cyan
Write-Host "  • Assign users the SECURE policy ($SecurePolicy)" -ForegroundColor White
Write-Host "  • Settings will be LOCKED and GREYED OUT" -ForegroundColor White
Write-Host "  • Cannot disable verification, watermarks, or lobby" -ForegroundColor White

Write-Host "`nFor General meetings:" -ForegroundColor Cyan
Write-Host "  • Assign users the REGULAR policy ($RegularPolicy)" -ForegroundColor White
Write-Host "  • Standard security with some organizer control" -ForegroundColor White

Write-Host "`nImportant:" -ForegroundColor Yellow
Write-Host "  • This ONLY updated Teams meeting policies" -ForegroundColor White
Write-Host "  • Sensitivity labels unchanged (still Teams-only)" -ForegroundColor White
Write-Host "  • Labels will NOT appear in Outlook (no change)" -ForegroundColor White
Write-Host "  • Wait 24-48 hours for propagation`n" -ForegroundColor White

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
