<#
.SYNOPSIS
    Assign Teams Meeting Policy to Distribution Group Members
.DESCRIPTION
    Assigns the Protected B meeting policy to all members of the 
    LCE M365 Security distribution group.
    
    Uses Exchange Online ONLY to read group membership (not for labels).
    Labels are NOT affected by this script.
    
    NOTE: Connecting to Exchange is required to query distribution group
    membership - this has NO effect on sensitivity labels in Outlook.
    Your labels are configured for Teams-only (Phase 3).
    
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 27, 2025
.NOTES
    VERSION 10.1
    - Simplified approach using group membership
    - No problematic Get-CsOnlineUser queries
    - Dynamic - just update group membership to add/remove users
#>

#Requires -Modules ExchangeOnlineManagement, MicrosoftTeams

# ============================================================
# CONFIGURATION
# ============================================================

$CONFIG = @{
    GroupEmail = "lcem365security@leonardocompany.ca"
    MeetingPolicy = "Leonardo-Secure-Meeting-Group"
    ReportPath = "C:\LeonardoReports"
}

# ============================================================
# INITIALIZATION
# ============================================================

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  TEAMS POLICY ASSIGNMENT - GROUP BASED v10.1                    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nStarted: $timestamp" -ForegroundColor Gray
Write-Host "Group: $($CONFIG.GroupEmail)" -ForegroundColor White
Write-Host "Policy: $($CONFIG.MeetingPolicy)" -ForegroundColor White

Write-Host "`n📝 Note: Exchange connection is for reading group membership only." -ForegroundColor DarkGray
Write-Host "   This does NOT affect sensitivity labels (they stay Teams-only).`n" -ForegroundColor DarkGray

# Create report directory
New-Item -Path $CONFIG.ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# Results tracking
$results = @{
    Assigned = @()
    AlreadyCorrect = @()
    Failed = @()
}

# ============================================================
# CONNECT TO SERVICES
# ============================================================

Write-Host "[Step 1/4] Connecting to services..." -ForegroundColor Cyan

# Exchange Online (for group membership query only)
Write-Host "  → Exchange Online (for group query)..." -ForegroundColor Gray
try {
    $exoConnected = Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened" }
    if (-not $exoConnected) {
        Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
    }
    Write-Host "  ✓ Exchange Online" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Exchange failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Microsoft Teams (for policy assignment)
Write-Host "  → Microsoft Teams..." -ForegroundColor Gray
try {
    Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
    Write-Host "  ✓ Microsoft Teams" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Teams failed: $($_.Exception.Message)" -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

# ============================================================
# VALIDATE POLICY EXISTS
# ============================================================

Write-Host "`n[Step 2/4] Validating policy..." -ForegroundColor Cyan

try {
    $policy = Get-CsTeamsMeetingPolicy -Identity $CONFIG.MeetingPolicy -ErrorAction Stop
    Write-Host "  ✓ Policy found: $($policy.Identity)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Policy not found: $($CONFIG.MeetingPolicy)" -ForegroundColor Red
    Write-Host "`n  Available policies:" -ForegroundColor Yellow
    Get-CsTeamsMeetingPolicy | ForEach-Object { Write-Host "    • $($_.Identity)" -ForegroundColor Gray }
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

# ============================================================
# GET GROUP MEMBERS
# ============================================================

Write-Host "`n[Step 3/4] Getting group members..." -ForegroundColor Cyan

try {
    $members = Get-DistributionGroupMember -Identity $CONFIG.GroupEmail -ErrorAction Stop
    Write-Host "  ✓ Found $($members.Count) members" -ForegroundColor Green
    
    foreach ($member in $members) {
        Write-Host "    • $($member.DisplayName) - $($member.PrimarySmtpAddress)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✗ Failed to get group members: $($_.Exception.Message)" -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

if ($members.Count -eq 0) {
    Write-Host "  ⚠ No members in group - nothing to do" -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue
    exit 0
}

# ============================================================
# ASSIGN POLICIES
# ============================================================

Write-Host "`n[Step 4/4] Assigning policies..." -ForegroundColor Cyan

# Expected policy formats (Teams adds "Tag:" prefix)
$expectedPolicies = @(
    $CONFIG.MeetingPolicy,
    "Tag:$($CONFIG.MeetingPolicy)"
)

foreach ($member in $members) {
    $email = $member.PrimarySmtpAddress
    $name = $member.DisplayName
    
    Write-Host "  → $name... " -NoNewline
    
    try {
        # Check current policy
        $currentUser = Get-CsOnlineUser -Identity $email -ErrorAction Stop
        $currentPolicy = $currentUser.TeamsMeetingPolicy
        
        if ($expectedPolicies -contains $currentPolicy) {
            Write-Host "✓ Already assigned" -ForegroundColor Green
            $results.AlreadyCorrect += @{Name=$name; Email=$email}
        } else {
            # Assign policy
            Grant-CsTeamsMeetingPolicy -Identity $email -PolicyName $CONFIG.MeetingPolicy -ErrorAction Stop
            Write-Host "✓ Assigned (was: $currentPolicy)" -ForegroundColor Green
            $results.Assigned += @{Name=$name; Email=$email; Previous=$currentPolicy}
        }
    } catch {
        Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        $results.Failed += @{Name=$name; Email=$email; Error=$_.Exception.Message}
    }
}

# ============================================================
# DISCONNECT
# ============================================================

Write-Host "`nDisconnecting..." -ForegroundColor Gray
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue

# ============================================================
# REPORT
# ============================================================

$reportFile = "$($CONFIG.ReportPath)\PolicyAssignment-$(Get-Date -Format 'yyyyMMdd-HHmm').txt"

$report = @"
═══════════════════════════════════════════════════════════════════
TEAMS POLICY ASSIGNMENT REPORT
═══════════════════════════════════════════════════════════════════

Executed: $timestamp
Group: $($CONFIG.GroupEmail)
Policy: $($CONFIG.MeetingPolicy)

SUMMARY
───────────────────────────────────────────────────────────────────
Total Members: $($members.Count)
Newly Assigned: $($results.Assigned.Count)
Already Correct: $($results.AlreadyCorrect.Count)
Failed: $($results.Failed.Count)

$(if ($results.Assigned.Count -gt 0) {
"NEWLY ASSIGNED:
$($results.Assigned | ForEach-Object { "  ✓ $($_.Name) ($($_.Email)) - was: $($_.Previous)" } | Out-String)"
})

$(if ($results.AlreadyCorrect.Count -gt 0) {
"ALREADY HAD CORRECT POLICY:
$($results.AlreadyCorrect | ForEach-Object { "  ✓ $($_.Name) ($($_.Email))" } | Out-String)"
})

$(if ($results.Failed.Count -gt 0) {
"FAILED:
$($results.Failed | ForEach-Object { "  ✗ $($_.Name) ($($_.Email)): $($_.Error)" } | Out-String)"
})

STATUS: $(if ($results.Failed.Count -eq 0) { "SUCCESS" } else { "COMPLETED WITH ERRORS" })

═══════════════════════════════════════════════════════════════════
"@

$report | Out-File $reportFile -Encoding UTF8

# Display summary
Write-Host "`n═══════════════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host "  Total Members:    $($members.Count)" -ForegroundColor White
Write-Host "  Newly Assigned:   $($results.Assigned.Count)" -ForegroundColor $(if ($results.Assigned.Count -gt 0) { "Green" } else { "White" })
Write-Host "  Already Correct:  $($results.AlreadyCorrect.Count)" -ForegroundColor Green
Write-Host "  Failed:           $($results.Failed.Count)" -ForegroundColor $(if ($results.Failed.Count -eq 0) { "White" } else { "Red" })

Write-Host "`n📄 Report: $reportFile" -ForegroundColor Gray

# Final status
if ($results.Failed.Count -eq 0) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ ALL POLICIES ASSIGNED SUCCESSFULLY                          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  ⚠️  COMPLETED WITH $($results.Failed.Count) ERROR(S)                                   ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
}

Write-Host "`nTo add/remove users from this policy:" -ForegroundColor Cyan
Write-Host "  1. Add/remove them from the '$($CONFIG.GroupEmail)' group" -ForegroundColor White
Write-Host "  2. Re-run this script" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")