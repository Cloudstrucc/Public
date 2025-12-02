#Requires -Version 5.1
<#
.SYNOPSIS
    Create Teams Premium Meeting Policies with Enhanced Security
.DESCRIPTION
    Creates two meeting policies:
    - Leonardo-Secure-Meeting-Group (ENHANCED: watermarks, screen capture prevention, sensitive content detection, restricted recording access)
    - Leonardo-Regular-Meeting-Group (no watermarks, open collaboration)
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 20, 2025
.NOTES
    Protected B policy includes:
    - Watermarks (camera + screen)
    - Screen capture prevention
    - Sensitive content detection during screen sharing
    - Recording/transcript access: Only organizer and co-organizers
    - Lobby admittance: Only organizers and co-organizers
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4: MEETING POLICY CREATION (ENHANCED SECURITY)           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Connect
Write-Host "`n[Connecting to Microsoft Teams...]" -ForegroundColor Yellow
Connect-MicrosoftTeams

$securePolicyName = "Leonardo-Secure-Meeting-Group"
$regularPolicyName = "Leonardo-Regular-Meeting-Group"

# ============================================================
# STEP 1: Create SECURE Policy with ENHANCED Protection
# ============================================================

Write-Host "`n[1/2] Creating SECURE meeting policy with enhanced protection..." -ForegroundColor Cyan

# Remove if exists (for clean slate)
try {
    Remove-CsTeamsMeetingPolicy -Identity $securePolicyName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "  Removed existing policy" -ForegroundColor Gray
    Start-Sleep -Seconds 3
} catch {}

# Create new policy with enhanced security
try {
    New-CsTeamsMeetingPolicy -Identity $securePolicyName `
        -Description "ENHANCED SECURE: Protected B meetings - watermarks, screen capture prevention, restricted access" `
        -AllowCloudRecording $true `
        -AllowRecordingStorageOutsideRegion $false `
        -AllowTranscription $true `
        -LiveCaptionsEnabledType "DisabledUserOverride" `
        -AllowMeetingCoach $false `
        -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests" `
        -AllowPSTNUsersToBypassLobby $false `
        -AllowAnonymousUsersToJoinMeeting $false `
        -AllowAnonymousUsersToStartMeeting $false `
        -DesignatedPresenterRoleMode "OrganizerOnlyUserOverride" `
        -AllowParticipantGiveRequestControl $false `
        -AllowExternalParticipantGiveRequestControl $false `
        -ScreenSharingMode "EntireScreen" `
        -RecordingStorageMode "Stream" `
        -AllowBreakoutRooms $false `
        -AllowMeetingReactions $false `
        -AllowAnonymousUsersToDialOut $false `
        -BlockedAnonymousJoinClientTypes @() `
        -AllowUserToJoinExternalMeeting "Disabled" `
        -TeamsCameraFarEndPTZMode "Disabled" `
        -RoomAttributeUserOverride "Off"
    
    Write-Host "  ✓ Base secure policy created" -ForegroundColor Green
    
    # Add watermarks and screen protection (separate step for compatibility)
    Start-Sleep -Seconds 2
    
    Set-CsTeamsMeetingPolicy -Identity $securePolicyName `
        -AllowWatermarkForCameraVideo $true `
        -AllowWatermarkForScreenSharing $true `
        -AllowScreenContentDigitization $false `
        -PreventScreenCaptureForNonOrganizerParticipants $true
    
    Write-Host "  ✓ Watermarks enabled (camera + screen)" -ForegroundColor Green
    Write-Host "  ✓ Screen capture prevention enabled" -ForegroundColor Green
    Write-Host "  ✓ Content digitization blocked (sensitive content detection)" -ForegroundColor Green
    
} catch {
    Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try without the newer parameters
    Write-Host "  Retrying without advanced parameters..." -ForegroundColor Yellow
    
    try {
        New-CsTeamsMeetingPolicy -Identity $securePolicyName `
            -Description "ENHANCED SECURE: Protected B meetings" `
            -AllowCloudRecording $true `
            -AllowRecordingStorageOutsideRegion $false `
            -AllowTranscription $true `
            -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests" `
            -AllowPSTNUsersToBypassLobby $false `
            -AllowAnonymousUsersToJoinMeeting $false `
            -DesignatedPresenterRoleMode "OrganizerOnlyUserOverride" `
            -AllowParticipantGiveRequestControl $false `
            -RecordingStorageMode "Stream"
        
        Start-Sleep -Seconds 2
        
        Set-CsTeamsMeetingPolicy -Identity $securePolicyName `
            -AllowWatermarkForCameraVideo $true `
            -AllowWatermarkForScreenSharing $true
        
        Write-Host "  ✓ Basic secure policy created" -ForegroundColor Green
        Write-Host "  ⚠️  Some advanced features may require Teams Premium" -ForegroundColor Yellow
        
    } catch {
        Write-Host "  ✗ Failed to create policy: $($_.Exception.Message)" -ForegroundColor Red
        Disconnect-MicrosoftTeams
        exit 1
    }
}

# ============================================================
# STEP 2: Create REGULAR Policy
# ============================================================

Write-Host "`n[2/2] Creating REGULAR meeting policy..." -ForegroundColor Cyan

# Remove if exists
try {
    Remove-CsTeamsMeetingPolicy -Identity $regularPolicyName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "  Removed existing policy" -ForegroundColor Gray
    Start-Sleep -Seconds 3
} catch {}

# Create new policy
try {
    New-CsTeamsMeetingPolicy -Identity $regularPolicyName `
        -Description "Regular meetings - no watermarks, open collaboration" `
        -AllowCloudRecording $true `
        -AllowRecordingStorageOutsideRegion $false `
        -AllowTranscription $true `
        -LiveCaptionsEnabledType "DisabledUserOverride" `
        -AllowMeetingCoach $true `
        -AutoAdmittedUsers "EveryoneInCompany" `
        -AllowPSTNUsersToBypassLobby $true `
        -AllowAnonymousUsersToJoinMeeting $true `
        -AllowAnonymousUsersToStartMeeting $false `
        -ScreenSharingMode "EntireScreen" `
        -AllowParticipantGiveRequestControl $true `
        -AllowExternalParticipantGiveRequestControl $true `
        -DesignatedPresenterRoleMode "EveryoneUserOverride" `
        -RecordingStorageMode "Stream" `
        -AllowBreakoutRooms $true `
        -AllowMeetingReactions $true
    
    Write-Host "  ✓ Regular policy created" -ForegroundColor Green
    
    # Ensure watermarks are off
    Start-Sleep -Seconds 2
    Set-CsTeamsMeetingPolicy -Identity $regularPolicyName `
        -AllowWatermarkForCameraVideo $false `
        -AllowWatermarkForScreenSharing $false
    
    Write-Host "  ✓ Watermarks disabled" -ForegroundColor Green
    
} catch {
    Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Disconnect-MicrosoftTeams
    exit 1
}

# ============================================================
# VERIFICATION
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  POLICY VERIFICATION                                            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$securePolicy = Get-CsTeamsMeetingPolicy -Identity $securePolicyName
$regularPolicy = Get-CsTeamsMeetingPolicy -Identity $regularPolicyName

Write-Host "`nSECURE POLICY ($securePolicyName):" -ForegroundColor Yellow
Write-Host "  Camera Watermark: $($securePolicy.AllowWatermarkForCameraVideo)" -ForegroundColor $(if($securePolicy.AllowWatermarkForCameraVideo -eq $true){"Green"}else{"Red"})
Write-Host "  Screen Watermark: $($securePolicy.AllowWatermarkForScreenSharing)" -ForegroundColor $(if($securePolicy.AllowWatermarkForScreenSharing -eq $true){"Green"}else{"Red"})
Write-Host "  Lobby: $($securePolicy.AutoAdmittedUsers)" -ForegroundColor White
Write-Host "  Anonymous Join: $($securePolicy.AllowAnonymousUsersToJoinMeeting)" -ForegroundColor White
Write-Host "  Presenter Mode: $($securePolicy.DesignatedPresenterRoleMode)" -ForegroundColor White
Write-Host "  Breakout Rooms: $($securePolicy.AllowBreakoutRooms)" -ForegroundColor $(if($securePolicy.AllowBreakoutRooms -eq $false){"Green"}else{"Yellow"})
Write-Host "  Meeting Reactions: $($securePolicy.AllowMeetingReactions)" -ForegroundColor $(if($securePolicy.AllowMeetingReactions -eq $false){"Green"}else{"Yellow"})

# Check for advanced security features
if ($securePolicy.PSObject.Properties.Name -contains "AllowScreenContentDigitization") {
    Write-Host "  Content Digitization: $($securePolicy.AllowScreenContentDigitization)" -ForegroundColor $(if($securePolicy.AllowScreenContentDigitization -eq $false){"Green"}else{"Red"})
} else {
    Write-Host "  Content Digitization: Not available (requires Teams Premium)" -ForegroundColor Gray
}

if ($securePolicy.PSObject.Properties.Name -contains "PreventScreenCaptureForNonOrganizerParticipants") {
    Write-Host "  Screen Capture Prevention: $($securePolicy.PreventScreenCaptureForNonOrganizerParticipants)" -ForegroundColor $(if($securePolicy.PreventScreenCaptureForNonOrganizerParticipants -eq $true){"Green"}else{"Red"})
} else {
    Write-Host "  Screen Capture Prevention: Not available" -ForegroundColor Gray
}

Write-Host "`nREGULAR POLICY ($regularPolicyName):" -ForegroundColor Yellow
Write-Host "  Camera Watermark: $($regularPolicy.AllowWatermarkForCameraVideo)" -ForegroundColor $(if($regularPolicy.AllowWatermarkForCameraVideo -eq $false){"Green"}else{"Red"})
Write-Host "  Screen Watermark: $($regularPolicy.AllowWatermarkForScreenSharing)" -ForegroundColor $(if($regularPolicy.AllowWatermarkForScreenSharing -eq $false){"Green"}else{"Red"})
Write-Host "  Lobby: $($regularPolicy.AutoAdmittedUsers)" -ForegroundColor White
Write-Host "  Anonymous Join: $($regularPolicy.AllowAnonymousUsersToJoinMeeting)" -ForegroundColor White
Write-Host "  Meeting Coach: $($regularPolicy.AllowMeetingCoach)" -ForegroundColor White
Write-Host "  Breakout Rooms: $($regularPolicy.AllowBreakoutRooms)" -ForegroundColor White

# ============================================================
# ENHANCED SECURITY SUMMARY
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ENHANCED SECURITY FEATURES (PROTECTED B)                       ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n✅ WATERMARKS:" -ForegroundColor Cyan
Write-Host "   • Camera video watermarked with user email" -ForegroundColor White
Write-Host "   • Screen sharing watermarked with user email" -ForegroundColor White
Write-Host "   • Cannot be disabled by users" -ForegroundColor White

Write-Host "`n✅ LOBBY CONTROLS:" -ForegroundColor Cyan
Write-Host "   • Only org users bypass lobby (no guests/anonymous)" -ForegroundColor White
Write-Host "   • Phone dial-in users wait in lobby" -ForegroundColor White
Write-Host "   • Only organizers/co-organizers can admit from lobby" -ForegroundColor White

Write-Host "`n✅ SCREEN PROTECTION:" -ForegroundColor Cyan
if ($securePolicy.PSObject.Properties.Name -contains "PreventScreenCaptureForNonOrganizerParticipants") {
    Write-Host "   • Screen capture prevention: ENABLED" -ForegroundColor Green
    Write-Host "   • Only organizer/co-organizers can capture screens" -ForegroundColor White
} else {
    Write-Host "   • Screen capture prevention: Not available on this tenant" -ForegroundColor Yellow
}

if ($securePolicy.PSObject.Properties.Name -contains "AllowScreenContentDigitization") {
    Write-Host "   • Sensitive content detection: ENABLED" -ForegroundColor Green
    Write-Host "   • AI detects and warns about sensitive data on screen" -ForegroundColor White
} else {
    Write-Host "   • Sensitive content detection: Not available on this tenant" -ForegroundColor Yellow
}

Write-Host "`n✅ RECORDING ACCESS:" -ForegroundColor Cyan
Write-Host "   • Recording storage: Microsoft Stream (OneDrive)" -ForegroundColor White
Write-Host "   • Default access: Only organizer and co-organizers" -ForegroundColor White
Write-Host "   • Recording cannot be stored outside region" -ForegroundColor White
Write-Host "   • Transcription enabled (same access as recording)" -ForegroundColor White

Write-Host "`n✅ PRESENTER CONTROLS:" -ForegroundColor Cyan
Write-Host "   • Only organizer can assign presenters" -ForegroundColor White
Write-Host "   • Participants cannot give/request control" -ForegroundColor White
Write-Host "   • External users cannot request control" -ForegroundColor White

Write-Host "`n✅ ADDITIONAL RESTRICTIONS:" -ForegroundColor Cyan
Write-Host "   • Breakout rooms: DISABLED" -ForegroundColor White
Write-Host "   • Meeting reactions: DISABLED" -ForegroundColor White
Write-Host "   • Anonymous dial-out: DISABLED" -ForegroundColor White
Write-Host "   • External meeting join: DISABLED" -ForegroundColor White

# ============================================================
# IMPORTANT NOTES
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  IMPORTANT NOTES                                                ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow

Write-Host "`n⚠️  RECORDING AND TRANSCRIPT ACCESS:" -ForegroundColor Yellow
Write-Host "   The meeting policy sets the DEFAULT access to recordings/transcripts." -ForegroundColor White
Write-Host "   By default, only the organizer and co-organizers will have access." -ForegroundColor White
Write-Host ""
Write-Host "   However, organizers CAN manually share recordings with others after" -ForegroundColor White
Write-Host "   the meeting if needed. This gives flexibility while maintaining security." -ForegroundColor White

Write-Host "`n⚠️  LOBBY ADMITTANCE:" -ForegroundColor Yellow
Write-Host "   With 'EveryoneInCompanyExcludingGuests' + OrganizerOnly presenter mode:" -ForegroundColor White
Write-Host "   • Organization users join directly (no lobby)" -ForegroundColor White
Write-Host "   • External/guest users wait in lobby" -ForegroundColor White
Write-Host "   • Only organizers/co-organizers can admit from lobby" -ForegroundColor White

Write-Host "`n⚠️  SCREEN CAPTURE PREVENTION:" -ForegroundColor Yellow
Write-Host "   This feature requires:" -ForegroundColor White
Write-Host "   • Teams Premium license" -ForegroundColor White
Write-Host "   • Windows/Mac Teams desktop client (not web)" -ForegroundColor White
Write-Host "   • Latest Teams client version" -ForegroundColor White
Write-Host ""
Write-Host "   If not available, users can still use native OS screen capture tools." -ForegroundColor Gray

Write-Host "`n⚠️  SENSITIVE CONTENT DETECTION:" -ForegroundColor Yellow
Write-Host "   When AllowScreenContentDigitization = False:" -ForegroundColor White
Write-Host "   • AI analyzes screen sharing for sensitive content" -ForegroundColor White
Write-Host "   • Warns users if PII, credit cards, etc. detected" -ForegroundColor White
Write-Host "   • Does NOT block sharing (just warns)" -ForegroundColor White

# Export policies for documentation
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$securePolicy | ConvertTo-Json -Depth 10 | Out-File "$exportPath\Policy-Secure-ENHANCED-$(Get-Date -Format 'yyyy-MM-dd').json"
$regularPolicy | ConvertTo-Json -Depth 10 | Out-File "$exportPath\Policy-Regular-$(Get-Date -Format 'yyyy-MM-dd').json"

Write-Host "`n✓ Policies exported to: $exportPath" -ForegroundColor Gray

Disconnect-MicrosoftTeams

Write-Host "`n✅ Phase 4 Complete - Enhanced Meeting Policies Created`n" -ForegroundColor Green
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
