#Requires -Version 5.1

<#
.SYNOPSIS
    Configure Default Meeting Options for LCE M365 Security Group

.DESCRIPTION
    Sets default meeting policies with proper lobby and security settings.
    Configures both Secure and Regular policies with appropriate defaults.

.PARAMETER ApplyToAllGroupMembers
    Apply policies to all group members immediately after configuration

.EXAMPLE
    .\03-Configure-Default-Meeting-Options.ps1
    
.EXAMPLE
    .\03-Configure-Default-Meeting-Options.ps1 -ApplyToAllGroupMembers

.NOTES
    Author: George Zarif
    Version: 1.1
    Last Updated: November 2025
#>

param(
    [switch]$ApplyToAllGroupMembers
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configure Default Meeting Options" -ForegroundColor Cyan
Write-Host "LCE M365 Security Group" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Connect to services
Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Yellow
Connect-MicrosoftTeams

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
Connect-MgGraph -Scopes "Group.Read.All","User.Read.All"

# Get group members
Write-Host ""
Write-Host "Getting LCE M365 Security group members..." -ForegroundColor Yellow
$group = Get-MgGroup -Filter "displayName eq 'LCE M365 Security'"
$members = Get-MgGroupMember -GroupId $group.Id -All
Write-Host "Found $($members.Count) members" -ForegroundColor Green

# ========================================
# Configure Secure Policy
# ========================================

Write-Host ""
Write-Host "Configuring Leonardo-Secure-Meeting-Group policy..." -ForegroundColor Cyan

$secureParams = @{
    Identity = "Leonardo-Secure-Meeting-Group"
    AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"
    AllowPSTNUsersToBypassLobby = $false
    AllowAnonymousUsersToJoinMeeting = $false
    AllowAnonymousUsersToStartMeeting = $false
    AllowWatermarkForCameraVideo = $true
    AllowWatermarkForScreenSharing = $true
    AllowMeetingCoach = $false
    DesignatedPresenterRoleMode = "OrganizerOnlyUserOverride"
    AllowParticipantGiveRequestControl = $false
    AllowExternalParticipantGiveRequestControl = $false
    AllowRecording = $true
    AllowTranscription = $true
    AllowCloudRecording = $true
    AllowBreakoutRooms = $true
    AllowMeetingReactions = $true
    MeetingChatEnabledType = "Enabled"
    AllowOrganizersToOverrideLobbySettings = $false
    Description = "Secure meeting settings with watermarks and strict access controls"
}

$securePolicyExists = $null
try {
    $securePolicyExists = Get-CsTeamsMeetingPolicy -Identity "Leonardo-Secure-Meeting-Group" -ErrorAction SilentlyContinue
}
catch {
    $securePolicyExists = $null
}

if ($securePolicyExists) {
    try {
        Set-CsTeamsMeetingPolicy @secureParams
        Write-Host "  Updated Secure policy" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error updating: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    try {
        New-CsTeamsMeetingPolicy @secureParams
        Write-Host "  Created Secure policy" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error creating: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ========================================
# Configure Regular Policy
# ========================================

Write-Host ""
Write-Host "Configuring Leonardo-Regular-Meeting-Group policy..." -ForegroundColor Cyan

$regularParams = @{
    Identity = "Leonardo-Regular-Meeting-Group"
    AutoAdmittedUsers = "EveryoneInCompany"
    AllowPSTNUsersToBypassLobby = $true
    AllowAnonymousUsersToJoinMeeting = $true
    AllowAnonymousUsersToStartMeeting = $false
    AllowWatermarkForCameraVideo = $false
    AllowWatermarkForScreenSharing = $false
    AllowMeetingCoach = $true
    DesignatedPresenterRoleMode = "EveryoneUserOverride"
    AllowParticipantGiveRequestControl = $true
    AllowExternalParticipantGiveRequestControl = $true
    AllowRecording = $true
    AllowTranscription = $true
    AllowCloudRecording = $true
    AllowBreakoutRooms = $true
    AllowMeetingReactions = $true
    MeetingChatEnabledType = "Enabled"
    Description = "Regular meeting settings for standard collaboration"
}

$regularPolicyExists = $null
try {
    $regularPolicyExists = Get-CsTeamsMeetingPolicy -Identity "Leonardo-Regular-Meeting-Group" -ErrorAction SilentlyContinue
}
catch {
    $regularPolicyExists = $null
}

if ($regularPolicyExists) {
    try {
        Set-CsTeamsMeetingPolicy @regularParams
        Write-Host "  Updated Regular policy" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error updating: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    try {
        New-CsTeamsMeetingPolicy @regularParams
        Write-Host "  Created Regular policy" -ForegroundColor Green
    }
    catch {
        Write-Host "  Error creating: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ========================================
# Apply to members if requested
# ========================================

if ($ApplyToAllGroupMembers) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Applying Policies to Group Members" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $success = 0
    $failed = 0
    
    foreach ($member in $members) {
        $user = Get-MgUser -UserId $member.Id -Property DisplayName,UserPrincipalName
        Write-Host ""
        Write-Host "Processing: $($user.DisplayName)" -ForegroundColor Gray
        
        try {
            Grant-CsTeamsMeetingPolicy -Identity $user.UserPrincipalName -PolicyName "Leonardo-Regular-Meeting-Group"
            Write-Host "  Success" -ForegroundColor Green
            $success++
            Start-Sleep -Seconds 2
        }
        catch {
            Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total: $($members.Count)" -ForegroundColor White
    Write-Host "Success: $success" -ForegroundColor Green
    if ($failed -gt 0) {
        Write-Host "Failed: $failed" -ForegroundColor Red
    }
    else {
        Write-Host "Failed: $failed" -ForegroundColor Green
    }
}

# ========================================
# Show configuration summary
# ========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SECURE POLICY:" -ForegroundColor Yellow
Write-Host "  Lobby: Org users only" -ForegroundColor White
Write-Host "  Anonymous: Blocked" -ForegroundColor White
Write-Host "  Phone dial-in: Must wait in lobby" -ForegroundColor White
Write-Host "  Watermarks: Enabled (camera + screen)" -ForegroundColor Green
Write-Host "  Presenters: Organizer controls" -ForegroundColor White
Write-Host "  Override lobby: DISABLED (locked)" -ForegroundColor Green
Write-Host "  Recording: Enabled" -ForegroundColor White
Write-Host "  Transcription: Enabled" -ForegroundColor White
Write-Host ""
Write-Host "REGULAR POLICY:" -ForegroundColor Yellow
Write-Host "  Lobby: Org + guests" -ForegroundColor White
Write-Host "  Anonymous: Allowed to join" -ForegroundColor White
Write-Host "  Phone dial-in: Can bypass lobby" -ForegroundColor White
Write-Host "  Watermarks: Disabled" -ForegroundColor Gray
Write-Host "  Presenters: Everyone can present" -ForegroundColor White
Write-Host "  Recording: Enabled" -ForegroundColor White
Write-Host "  Meeting Coach: Enabled" -ForegroundColor White

Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  - Settings apply to NEW meetings only" -ForegroundColor White
Write-Host "  - Changes take up to 24 hours to propagate" -ForegroundColor White
Write-Host "  - Users must sign out/in to Teams" -ForegroundColor White
Write-Host "  - Secure meetings: Lobby settings LOCKED" -ForegroundColor White

# Cleanup
Write-Host ""
Disconnect-MicrosoftTeams
Disconnect-MgGraph

Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
Write-Host ""
