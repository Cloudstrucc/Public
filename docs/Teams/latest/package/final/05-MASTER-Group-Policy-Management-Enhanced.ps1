<#
.SYNOPSIS
    MASTER Group Policy Management - Automated Policy Assignment
.DESCRIPTION
    Automatically manages Teams policies for LCE M365 Security group members.
    
    Features:
    - Monitors distribution group membership
    - Automatically assigns/removes Teams meeting policies
    - Maintains audit log
    - Reports on all changes
    
    Can be run:
    - Manually (test changes)
    - Scheduled (daily via Task Scheduler)
    - On-demand (when adding/removing users)
    
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 27, 2025
.NOTES
    VERSION 10.0
    - Fixed policy name to match actual policy
    - Simplified connection logic
    - Removed unused Purview connection
    - Added policy existence validation
    Safe to run multiple times - idempotent
#>

#Requires -Modules ExchangeOnlineManagement, MicrosoftTeams

# ============================================================
# CONFIGURATION - UPDATE THESE VALUES AS NEEDED
# ============================================================

$CONFIG = @{
    # Distribution group containing Protected B users
    GroupEmail = "lcem365security@leonardocompany.ca"
    GroupName = "LCE M365 Security"
    
    # Teams Meeting Policy to assign (MUST MATCH ACTUAL POLICY NAME)
    MeetingPolicy = "Leonardo-Secure-Meeting-Group"
    
    # Reporting paths
    ReportPath = "C:\LeonardoReports"
    LogPath = "C:\LeonardoReports\Logs"
}

# ============================================================
# INITIALIZATION
# ============================================================

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MASTER GROUP POLICY MANAGEMENT v10.0                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nStarted: $timestamp" -ForegroundColor Gray
Write-Host "Group: $($CONFIG.GroupEmail)" -ForegroundColor White
Write-Host "Policy: $($CONFIG.MeetingPolicy)`n" -ForegroundColor White

# Create directories
New-Item -Path $CONFIG.ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $CONFIG.LogPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# Initialize results tracking
$results = @{
    Timestamp = $timestamp
    GroupMembers = @()
    PoliciesAssigned = @()
    PoliciesRemoved = @()
    AlreadyCorrect = @()
    Errors = @()
}

# ============================================================
# FUNCTIONS
# ============================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $color = switch ($Level) {
        'Info' { 'White' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
    }
    
    $logTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$logTimestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $color
    
    # Write to daily log file
    $logFile = Join-Path $CONFIG.LogPath "PolicyManagement-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Connect-Services {
    Write-Log "Connecting to Microsoft 365 services..." -Level Info
    
    $connected = @{
        Exchange = $false
        Teams = $false
    }
    
    # Connect to Exchange Online (for distribution group)
    Write-Host "  → Exchange Online..." -ForegroundColor Gray
    try {
        # Check if already connected
        $exoTest = Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened" }
        if ($exoTest) {
            Write-Log "  ✓ Exchange Online (existing session)" -Level Success
            $connected.Exchange = $true
        } else {
            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
            Write-Log "  ✓ Exchange Online connected" -Level Success
            $connected.Exchange = $true
        }
    } catch {
        Write-Log "  ✗ Exchange Online failed: $($_.Exception.Message)" -Level Error
        $results.Errors += "Exchange connection failed: $($_.Exception.Message)"
    }
    
    # Connect to Teams (for policy assignment)
    Write-Host "  → Microsoft Teams..." -ForegroundColor Gray
    try {
        Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
        Write-Log "  ✓ Teams connected" -Level Success
        $connected.Teams = $true
    } catch {
        Write-Log "  ✗ Teams failed: $($_.Exception.Message)" -Level Error
        $results.Errors += "Teams connection failed: $($_.Exception.Message)"
    }
    
    return ($connected.Exchange -and $connected.Teams)
}

function Test-PolicyExists {
    Write-Log "Validating policy exists..." -Level Info
    
    try {
        $policy = Get-CsTeamsMeetingPolicy -Identity $CONFIG.MeetingPolicy -ErrorAction Stop
        Write-Log "  ✓ Policy found: $($policy.Identity)" -Level Success
        return $true
    } catch {
        Write-Log "  ✗ Policy NOT FOUND: $($CONFIG.MeetingPolicy)" -Level Error
        Write-Host "`n  Available policies:" -ForegroundColor Yellow
        Get-CsTeamsMeetingPolicy | Where-Object { $_.Identity -notlike "Tag:*Global*" } | ForEach-Object {
            Write-Host "    • $($_.Identity)" -ForegroundColor Gray
        }
        $results.Errors += "Policy not found: $($CONFIG.MeetingPolicy)"
        return $false
    }
}

function Get-GroupMembers {
    Write-Log "`nRetrieving group members..." -Level Info
    
    try {
        $members = Get-DistributionGroupMember -Identity $CONFIG.GroupEmail -ErrorAction Stop
        
        Write-Log "  ✓ Found $($members.Count) members" -Level Success
        
        foreach ($member in $members) {
            Write-Host "    • $($member.DisplayName) - $($member.PrimarySmtpAddress)" -ForegroundColor Gray
            
            $results.GroupMembers += [PSCustomObject]@{
                DisplayName = $member.DisplayName
                Email = $member.PrimarySmtpAddress
                UserPrincipalName = $member.PrimarySmtpAddress
            }
        }
        
        return $members
    } catch {
        Write-Log "  ✗ Failed to retrieve group members: $($_.Exception.Message)" -Level Error
        $results.Errors += "Group retrieval failed: $($_.Exception.Message)"
        return @()
    }
}

function Get-AllTeamsUsers {
    Write-Log "`nRetrieving Teams users..." -Level Info
    
    try {
        # Get all users (filter removed - was causing errors in newer module versions)
        # We'll filter in PowerShell instead
        $allUsers = Get-CsOnlineUser -ResultSize Unlimited -ErrorAction Stop | 
                    Where-Object { $_.AccountEnabled -eq $true }
        Write-Log "  ✓ Found $($allUsers.Count) enabled Teams users" -Level Success
        return $allUsers
    } catch {
        # Fallback: try without any filtering
        try {
            Write-Log "  ⚠ Retrying without filter..." -Level Warning
            $allUsers = Get-CsOnlineUser -ResultSize Unlimited -ErrorAction Stop
            Write-Log "  ✓ Found $($allUsers.Count) Teams users (unfiltered)" -Level Success
            return $allUsers
        } catch {
            Write-Log "  ✗ Failed to retrieve Teams users: $($_.Exception.Message)" -Level Error
            $results.Errors += "Teams users retrieval failed: $($_.Exception.Message)"
            return @()
        }
    }
}

function Sync-TeamsPolicies {
    param(
        [Parameter(Mandatory)]
        [object[]]$GroupMembers,
        [Parameter(Mandatory)]
        [object[]]$AllTeamsUsers
    )
    
    Write-Log "`nSynchronizing policy assignments..." -Level Info
    
    # Get group member emails (lowercase for comparison)
    $groupEmails = $GroupMembers | ForEach-Object { $_.PrimarySmtpAddress.ToLower() }
    
    # Expected policy name format (with or without Tag: prefix)
    $expectedPolicies = @(
        $CONFIG.MeetingPolicy,
        "Tag:$($CONFIG.MeetingPolicy)"
    )
    
    foreach ($user in $AllTeamsUsers) {
        $userEmail = $user.UserPrincipalName.ToLower()
        $userDisplayName = $user.DisplayName
        $shouldHavePolicy = $groupEmails -contains $userEmail
        $currentPolicy = $user.TeamsMeetingPolicy
        
        # Check if user has the correct policy (handle Tag: prefix)
        $hasCorrectPolicy = $expectedPolicies -contains $currentPolicy
        
        try {
            if ($shouldHavePolicy) {
                # User IS in group - should have policy
                if (-not $hasCorrectPolicy) {
                    Write-Host "  → Assigning policy to: $userDisplayName" -ForegroundColor Cyan
                    
                    Grant-CsTeamsMeetingPolicy -Identity $userEmail -PolicyName $CONFIG.MeetingPolicy -ErrorAction Stop
                    
                    Write-Log "    ✓ Assigned to $userDisplayName (was: $currentPolicy)" -Level Success
                    
                    $results.PoliciesAssigned += [PSCustomObject]@{
                        User = $userDisplayName
                        Email = $userEmail
                        Policy = $CONFIG.MeetingPolicy
                        PreviousPolicy = $currentPolicy
                        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    }
                } else {
                    $results.AlreadyCorrect += $userDisplayName
                }
            } else {
                # User NOT in group - should NOT have this policy
                if ($hasCorrectPolicy) {
                    Write-Host "  → Removing policy from: $userDisplayName" -ForegroundColor Yellow
                    
                    Grant-CsTeamsMeetingPolicy -Identity $userEmail -PolicyName $null -ErrorAction Stop
                    
                    Write-Log "    ✓ Removed from $userDisplayName (reverted to Global)" -Level Success
                    
                    $results.PoliciesRemoved += [PSCustomObject]@{
                        User = $userDisplayName
                        Email = $userEmail
                        Policy = $CONFIG.MeetingPolicy
                        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    }
                }
            }
        } catch {
            $errorMsg = "Failed to process $userDisplayName : $($_.Exception.Message)"
            Write-Log "    ✗ $errorMsg" -Level Error
            $results.Errors += $errorMsg
        }
    }
    
    # Summary of users already correct
    if ($results.AlreadyCorrect.Count -gt 0) {
        Write-Host "`n  Already have correct policy:" -ForegroundColor Green
        foreach ($user in $results.AlreadyCorrect) {
            Write-Host "    ✓ $user" -ForegroundColor Green
        }
    }
}

function Disconnect-Services {
    Write-Log "`nDisconnecting from services..." -Level Info
    
    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue
        Write-Log "  ✓ Disconnected" -Level Success
    } catch {
        Write-Log "  ⚠ Disconnect warning: $($_.Exception.Message)" -Level Warning
    }
}

function New-ExecutionReport {
    Write-Log "`nGenerating report..." -Level Info
    
    $summary = @"
═══════════════════════════════════════════════════════════════════
MASTER GROUP POLICY MANAGEMENT - EXECUTION REPORT
═══════════════════════════════════════════════════════════════════

Execution Time: $($results.Timestamp)
Script Version: 10.0

CONFIGURATION
───────────────────────────────────────────────────────────────────
Group: $($CONFIG.GroupEmail)
Policy: $($CONFIG.MeetingPolicy)

GROUP MEMBERSHIP
───────────────────────────────────────────────────────────────────
Total Members: $($results.GroupMembers.Count)

$($results.GroupMembers | ForEach-Object { "  • $($_.DisplayName) - $($_.Email)" } | Out-String)

POLICY CHANGES
───────────────────────────────────────────────────────────────────
Policies Assigned: $($results.PoliciesAssigned.Count)
Policies Removed: $($results.PoliciesRemoved.Count)
Already Correct: $($results.AlreadyCorrect.Count)

$(if ($results.PoliciesAssigned.Count -gt 0) {
"ASSIGNED:
$($results.PoliciesAssigned | ForEach-Object { "  ✓ $($_.User) ($($_.Email)) - was: $($_.PreviousPolicy)" } | Out-String)"
})

$(if ($results.PoliciesRemoved.Count -gt 0) {
"REMOVED:
$($results.PoliciesRemoved | ForEach-Object { "  ✗ $($_.User) ($($_.Email))" } | Out-String)"
})

$(if ($results.AlreadyCorrect.Count -gt 0) {
"ALREADY CORRECT:
$($results.AlreadyCorrect | ForEach-Object { "  ✓ $_" } | Out-String)"
})

ERRORS
───────────────────────────────────────────────────────────────────
Total Errors: $($results.Errors.Count)

$(if ($results.Errors.Count -gt 0) {
$results.Errors | ForEach-Object { "  • $_" } | Out-String
} else {
"  ✓ No errors"
})

STATUS
───────────────────────────────────────────────────────────────────
Overall: $(if ($results.Errors.Count -eq 0) { "SUCCESS" } else { "COMPLETED WITH ERRORS" })

═══════════════════════════════════════════════════════════════════
"@

    # Save report
    $reportFile = Join-Path $CONFIG.ReportPath "PolicyManagement-$reportTimestamp.txt"
    $summary | Out-File $reportFile -Encoding UTF8
    
    # Display summary
    Write-Host "`n$summary" -ForegroundColor White
    
    Write-Log "Report saved: $reportFile" -Level Success
    
    return $reportFile
}

# ============================================================
# MAIN EXECUTION
# ============================================================

try {
    # Step 1: Connect to services
    Write-Host "[Step 1/5] " -NoNewline -ForegroundColor Cyan
    if (-not (Connect-Services)) {
        Write-Log "Cannot proceed without service connections" -Level Error
        exit 1
    }
    
    # Step 2: Validate policy exists
    Write-Host "`n[Step 2/5] " -NoNewline -ForegroundColor Cyan
    if (-not (Test-PolicyExists)) {
        Write-Log "Cannot proceed - policy does not exist" -Level Error
        Write-Host "`n  Update the `$CONFIG.MeetingPolicy variable to match your policy name" -ForegroundColor Yellow
        Disconnect-Services
        exit 1
    }
    
    # Step 3: Get group members
    Write-Host "`n[Step 3/5] " -NoNewline -ForegroundColor Cyan
    $groupMembers = Get-GroupMembers
    
    if ($groupMembers.Count -eq 0) {
        Write-Log "No group members found - nothing to do" -Level Warning
        Disconnect-Services
        exit 0
    }
    
    # Step 4: Get all Teams users and sync policies
    Write-Host "`n[Step 4/5] " -NoNewline -ForegroundColor Cyan
    $allTeamsUsers = Get-AllTeamsUsers
    
    if ($allTeamsUsers.Count -eq 0) {
        Write-Log "No Teams users found - cannot assign policies" -Level Error
        Disconnect-Services
        exit 1
    }
    
    Sync-TeamsPolicies -GroupMembers $groupMembers -AllTeamsUsers $allTeamsUsers
    
    # Step 5: Generate report and disconnect
    Write-Host "`n[Step 5/5] " -NoNewline -ForegroundColor Cyan
    $reportFile = New-ExecutionReport
    Disconnect-Services
    
    # Final status
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor $(if ($results.Errors.Count -eq 0) { "Green" } else { "Yellow" })
    Write-Host "║  $(if ($results.Errors.Count -eq 0) { "✅ EXECUTION COMPLETE" } else { "⚠️  COMPLETED WITH ERRORS" })                                          ║" -ForegroundColor $(if ($results.Errors.Count -eq 0) { "Green" } else { "Yellow" })
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor $(if ($results.Errors.Count -eq 0) { "Green" } else { "Yellow" })
    
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Group members: $($results.GroupMembers.Count)" -ForegroundColor White
    Write-Host "  Policies assigned: $($results.PoliciesAssigned.Count)" -ForegroundColor $(if ($results.PoliciesAssigned.Count -gt 0) { "Green" } else { "White" })
    Write-Host "  Policies removed: $($results.PoliciesRemoved.Count)" -ForegroundColor $(if ($results.PoliciesRemoved.Count -gt 0) { "Yellow" } else { "White" })
    Write-Host "  Already correct: $($results.AlreadyCorrect.Count)" -ForegroundColor Green
    Write-Host "  Errors: $($results.Errors.Count)" -ForegroundColor $(if ($results.Errors.Count -eq 0) { "Green" } else { "Red" })
    
    Write-Host "`n📄 Report: $reportFile" -ForegroundColor Gray
    
    # Exit code
    exit $(if ($results.Errors.Count -eq 0) { 0 } else { 1 })
    
} catch {
    Write-Log "Fatal error: $($_.Exception.Message)" -Level Error
    Write-Host "`nStack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    Disconnect-Services
    exit 1
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")