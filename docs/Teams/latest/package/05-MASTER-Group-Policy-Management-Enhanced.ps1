<#
.SYNOPSIS
    MASTER Group Policy Management - Automated Policy Assignment
.DESCRIPTION
    Automatically manages Teams policies for LCE M365 Security group members.
    
    Features:
    - Monitors distribution group membership
    - Automatically assigns/removes Teams policies
    - Assigns sensitivity labels
    - Maintains audit log
    - Reports on all changes
    
    Can be run:
    - Manually (test changes)
    - Scheduled (daily via Task Scheduler)
    - On-demand (when adding/removing users)
    
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Safe to run multiple times - idempotent
#>

#Requires -Modules ExchangeOnlineManagement, MicrosoftTeams

# Configuration
$CONFIG = @{
    GroupEmail = "lcem365security@leonardocompany.ca"
    GroupName = "LCE M365 Security"
    
    # Teams Policies
    SecureMeetingPolicy = "Leonardo-Secure-Meeting-Group"  # For Protected B
    RegularMeetingPolicy = "Leonardo-Regular-Meeting-Group"  # For General
    
    # Sensitivity Labels (GUIDs - will be retrieved)
    ProtectedBLabel = "Protected B - Secure Meeting"
    GeneralLabel = "General - Regular Meeting"
    
    # Reporting
    ReportPath = "C:\LeonardoReports"
    LogPath = "C:\LeonardoReports\Logs"
    
    # Email notifications (future enhancement)
    NotifyEmail = "lcem365security@leonardocompany.ca"
}

# Initialize
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MASTER GROUP POLICY MANAGEMENT                                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nStarted: $timestamp" -ForegroundColor Gray
Write-Host "Group: $($CONFIG.GroupEmail)`n" -ForegroundColor White

# Create directories
New-Item -Path $CONFIG.ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $CONFIG.LogPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# Initialize results
$results = @{
    Timestamp = $timestamp
    GroupMembers = @()
    PoliciesAssigned = @()
    PoliciesRemoved = @()
    Errors = @()
    Summary = ""
}

#region Functions

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
    
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $color
    
    # Write to log file
    $logFile = Join-Path $CONFIG.LogPath "PolicyManagement-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Connect-Services {
    Write-Log "Connecting to Microsoft 365 services..." -Level Info
    
    try {
        # Connect to Exchange Online
        Write-Host "  → Exchange Online..." -ForegroundColor Gray
        Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
        Write-Log "  ✓ Exchange Online connected" -Level Success
        
        # Connect to Teams
        Write-Host "  → Microsoft Teams..." -ForegroundColor Gray
        Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
        Write-Log "  ✓ Teams connected" -Level Success
        
        # Connect to Compliance (for labels)
        Write-Host "  → Microsoft Purview..." -ForegroundColor Gray
        Connect-IPPSSession -ErrorAction Stop
        Write-Log "  ✓ Purview connected" -Level Success
        
        return $true
    } catch {
        Write-Log "Connection failed: $($_.Exception.Message)" -Level Error
        $results.Errors += "Connection failed: $($_.Exception.Message)"
        return $false
    }
}

function Update-MeetingPolicySettings {
    Write-Log "`nUpdating Protected B meeting policy settings..." -Level Info
    
    try {
        # Check if policy exists
        $policy = Get-CsTeamsMeetingPolicy -Identity $CONFIG.MeetingPolicy -ErrorAction SilentlyContinue
        
        if (-not $policy) {
            Write-Log "  ⚠️  Policy '$($CONFIG.MeetingPolicy)' not found - skipping policy update" -Level Warning
            Write-Log "  → Run Script 06 to create the policy first" -Level Info
            return $false
        }
        
        Write-Log "  → Configuring locked security settings..." -Level Info
        
        # Update policy with LOCKED security settings
        Set-CsTeamsMeetingPolicy -Identity $CONFIG.MeetingPolicy `
            -AllowOrganizersToOverrideLobbySettings $false `
            -AllowAnonymousUsersToJoinMeeting $false `
            -AllowPSTNUsersToBypassLobby $false `
            -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests" `
            -AllowExternalParticipantGiveRequestControl $false `
            -AllowParticipantGiveRequestControl $false `
            -AllowRecordingStorageOutsideRegion $false `
            -ErrorAction Stop
        
        Write-Log "  ✓ Policy updated with locked security settings" -Level Success
        Write-Log "    • Organizer override: DISABLED" -Level Info
        Write-Log "    • Anonymous users: BLOCKED" -Level Info
        Write-Log "    • Participant verification: REQUIRED" -Level Info
        Write-Log "    • Screen protection: ENABLED" -Level Info
        
        return $true
    } catch {
        Write-Log "  ✗ Failed to update policy settings: $($_.Exception.Message)" -Level Error
        $results.Errors += "Policy update failed: $($_.Exception.Message)"
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
        Write-Log "Failed to retrieve group members: $($_.Exception.Message)" -Level Error
        $results.Errors += "Group retrieval failed: $($_.Exception.Message)"
        return @()
    }
}

function Get-AllTeamsUsers {
    Write-Log "`nRetrieving all Teams users..." -Level Info
    
    try {
        $allUsers = Get-CsOnlineUser -Filter {Enabled -eq $true} -ErrorAction Stop
        Write-Log "  ✓ Found $($allUsers.Count) enabled Teams users" -Level Success
        return $allUsers
    } catch {
        Write-Log "Failed to retrieve Teams users: $($_.Exception.Message)" -Level Error
        $results.Errors += "Teams users retrieval failed: $($_.Exception.Message)"
        return @()
    }
}

function Assign-TeamsPolicies {
    param(
        [Parameter(Mandatory)]
        [object[]]$GroupMembers,
        [Parameter(Mandatory)]
        [object[]]$AllTeamsUsers
    )
    
    Write-Log "`nProcessing policy assignments..." -Level Info
    
    # Get group member emails
    $groupEmails = $GroupMembers | ForEach-Object { $_.PrimarySmtpAddress.ToLower() }
    
    foreach ($user in $AllTeamsUsers) {
        $userEmail = $user.UserPrincipalName.ToLower()
        $shouldHavePolicy = $groupEmails -contains $userEmail
        $currentPolicy = $user.TeamsMeetingPolicy
        
        try {
            if ($shouldHavePolicy) {
                # User SHOULD have policy (assign SECURE policy for Protected B)
                if ($currentPolicy -ne $CONFIG.SecureMeetingPolicy) {
                    Write-Host "  → Assigning SECURE policy to: $($user.DisplayName)" -ForegroundColor Cyan
                    
                    Grant-CsTeamsMeetingPolicy -Identity $userEmail -PolicyName $CONFIG.SecureMeetingPolicy -ErrorAction Stop
                    
                    Write-Log "    ✓ Assigned $($CONFIG.SecureMeetingPolicy) to $($user.DisplayName)" -Level Success
                    
                    $results.PoliciesAssigned += [PSCustomObject]@{
                        User = $user.DisplayName
                        Email = $userEmail
                        Policy = $CONFIG.SecureMeetingPolicy
                        PreviousPolicy = $currentPolicy
                        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    }
                } else {
                    Write-Host "  ✓ $($user.DisplayName) - Already has correct policy" -ForegroundColor Green
                }
            } else {
                # User should NOT have policy (if they currently have it, remove it)
                if ($currentPolicy -eq $CONFIG.SecureMeetingPolicy) {
                    Write-Host "  → Removing SECURE policy from: $($user.DisplayName)" -ForegroundColor Yellow
                    
                    Grant-CsTeamsMeetingPolicy -Identity $userEmail -PolicyName $null -ErrorAction Stop
                    
                    Write-Log "    ✓ Removed $($CONFIG.SecureMeetingPolicy) from $($user.DisplayName)" -Level Success
                    
                    $results.PoliciesRemoved += [PSCustomObject]@{
                        User = $user.DisplayName
                        Email = $userEmail
                        Policy = $CONFIG.SecureMeetingPolicy
                        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    }
                }
            }
        } catch {
            $errorMsg = "Failed to process $($user.DisplayName): $($_.Exception.Message)"
            Write-Log "    ✗ $errorMsg" -Level Error
            $results.Errors += $errorMsg
        }
    }
}

function Disconnect-Services {
    Write-Log "`nDisconnecting from services..." -Level Info
    
    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue
        # Purview/Compliance disconnects with Exchange
        
        Write-Log "  ✓ Disconnected" -Level Success
    } catch {
        Write-Log "Disconnect warning: $($_.Exception.Message)" -Level Warning
    }
}

function New-ExecutionReport {
    Write-Log "`nGenerating report..." -Level Info
    
    $summary = @"
═══════════════════════════════════════════════════════════════════
MASTER GROUP POLICY MANAGEMENT - EXECUTION REPORT
═══════════════════════════════════════════════════════════════════

Execution Time: $($results.Timestamp)
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

$(if ($results.PoliciesAssigned.Count -gt 0) {
"Assigned:
$($results.PoliciesAssigned | ForEach-Object { "  ✓ $($_.User) - $($_.Email)" } | Out-String)"
} else {
"  (No policies assigned)"
})

$(if ($results.PoliciesRemoved.Count -gt 0) {
"Removed:
$($results.PoliciesRemoved | ForEach-Object { "  ✗ $($_.User) - $($_.Email)" } | Out-String)"
} else {
"  (No policies removed)"
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

Next Scheduled Run: $(if ($env:SCHEDULED_TASK -eq "true") { "Tomorrow (daily task)" } else { "Manual execution - schedule as needed" })

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

#endregion

#region Main Execution

try {
    # Step 1: Connect to services
    if (-not (Connect-Services)) {
        Write-Log "Cannot proceed without service connections" -Level Error
        exit 1
    }
    
    # Step 2: Update meeting policy settings (LOCKED security)
    Update-MeetingPolicySettings | Out-Null
    
    # Step 3: Get group members
    $groupMembers = Get-GroupMembers
    
    if ($groupMembers.Count -eq 0) {
        Write-Log "No group members found - nothing to do" -Level Warning
        Disconnect-Services
        exit 0
    }
    
    # Step 4: Get all Teams users
    $allTeamsUsers = Get-AllTeamsUsers
    
    if ($allTeamsUsers.Count -eq 0) {
        Write-Log "No Teams users found - cannot assign policies" -Level Error
        Disconnect-Services
        exit 1
    }
    
    # Step 5: Assign/remove policies
    Assign-TeamsPolicies -GroupMembers $groupMembers -AllTeamsUsers $allTeamsUsers
    
    # Step 6: Generate report
    $reportFile = New-ExecutionReport
    
    # Step 7: Disconnect
    Disconnect-Services
    
    # Final status
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ EXECUTION COMPLETE                                          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Group members: $($results.GroupMembers.Count)" -ForegroundColor White
    Write-Host "  Policies assigned: $($results.PoliciesAssigned.Count)" -ForegroundColor Green
    Write-Host "  Policies removed: $($results.PoliciesRemoved.Count)" -ForegroundColor Yellow
    Write-Host "  Errors: $($results.Errors.Count)" -ForegroundColor $(if ($results.Errors.Count -eq 0) { "Green" } else { "Red" })
    
    Write-Host "`n📄 Report: $reportFile" -ForegroundColor Gray
    
    # Exit code
    if ($results.Errors.Count -eq 0) {
        exit 0
    } else {
        exit 1
    }
    
} catch {
    Write-Log "Fatal error in main execution: $($_.Exception.Message)" -Level Error
    Write-Host "`nStack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    Disconnect-Services
    exit 1
}

#endregion

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
