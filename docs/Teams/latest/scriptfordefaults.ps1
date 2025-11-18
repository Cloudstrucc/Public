# ========================================
# Configure Default Meeting Options
# Sets default meeting access, lobby, and security settings
# Owner: George Zarif
# ========================================

<#
.SYNOPSIS
    Configures default meeting options for LCE M365 Security group members

.DESCRIPTION
    This script applies default meeting settings that will be pre-selected
    when users create new meetings. Settings include lobby controls,
    participant verification, and access permissions.

.NOTES
    Run this after adding new users to the LCE M365 Security group
    Settings apply to future meetings only (not retroactive)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Secure", "Regular", "Both")]
    [string]$PolicyType = "Both",
    
    [Parameter(Mandatory=$false)]
    [switch]$ApplyToAllGroupMembers
)

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  CONFIGURE DEFAULT MEETING OPTIONS                              ║" -ForegroundColor Cyan
Write-Host "║  LCE M365 Security Group                                        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Connect to required services
Write-Host ""
Write-Host "Connecting to Microsoft services..." -ForegroundColor Yellow
Connect-MicrosoftTeams
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All"

# Get group members
Write-Host ""
Write-Host "Retrieving LCE M365 Security group members..." -ForegroundColor Yellow
$group = Get-MgGroup -Filter "displayName eq 'LCE M365 Security'"
$members = Get-MgGroupMember -GroupId $group.Id -All

Write-Host "  Found $($members.Count) members" -ForegroundColor Green

# Define meeting option configurations
$secureSettings = @{
    PolicyName = "Leonardo-Secure-Meeting-Group"
    Settings = @{
        AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"
        AllowPSTNUsersToBypassLobby = $false
        AllowAnonymousUsersToJoinMeeting = $false
        AllowAnonymousUsersToStartMeeting = $false
        AllowExternalParticipantGiveRequestControl = $false
        AllowMeetingReactions = $true
        AllowRecording = $true
        AllowTranscription = $true
        DesignatedPresenterRoleMode = "OrganizerOnlyUserOverride"
        AllowWatermarkForCameraVideo = $true
        AllowWatermarkForScreenSharing = $true
        AllowScreenContentDigitalization = $false
        AllowMeetingCoach = $false
        AllowBreakoutRooms = $true
        AllowMeetingRegistration = $false
        AllowCloudRecording = $true
        AllowParticipantGiveRequestControl = $false
        AllowNDIStreaming = $false
        Description = "Secure meeting settings with watermarks and strict access controls"
    }
}

$regularSettings = @{
    PolicyName = "Leonardo-Regular-Meeting-Group"
    Settings = @{
        AutoAdmittedUsers = "EveryoneInCompany"
        AllowPSTNUsersToBypassLobby = $true
        AllowAnonymousUsersToJoinMeeting = $true
        AllowAnonymousUsersToStartMeeting = $false
        AllowExternalParticipantGiveRequestControl = $true
        AllowMeetingReactions = $true
        AllowRecording = $true
        AllowTranscription = $true
        DesignatedPresenterRoleMode = "EveryoneUserOverride"
        AllowWatermarkForCameraVideo = $false
        AllowWatermarkForScreenSharing = $false
        AllowScreenContentDigitalization = $true
        AllowMeetingCoach = $true
        AllowBreakoutRooms = $true
        AllowMeetingRegistration = $true
        AllowCloudRecording = $true
        AllowParticipantGiveRequestControl = $true
        AllowNDIStreaming = $false
        Description = "Regular meeting settings for standard collaboration"
    }
}

# Function to apply meeting policy
function Set-MeetingPolicySettings {
    param(
        [string]$PolicyName,
        [hashtable]$Settings
    )
    
    Write-Host ""
    Write-Host "  Configuring: $PolicyName" -ForegroundColor Cyan
    
    try {
        # Check if policy exists
        $existingPolicy = Get-CsTeamsMeetingPolicy -Identity $PolicyName -ErrorAction SilentlyContinue
        
        if ($existingPolicy) {
            Write-Host "    Policy exists - updating settings..." -ForegroundColor Yellow
            
            # Update policy using splatting
            $updateParams = @{
                Identity = $PolicyName
            }
            $updateParams += $Settings
            
            Set-CsTeamsMeetingPolicy @updateParams
            
            Write-Host "    ✓ Policy updated successfully" -ForegroundColor Green
        }
        else {
            Write-Host "    Policy doesn't exist - creating new..." -ForegroundColor Yellow
            
            # Create new policy using splatting
            $createParams = @{
                Identity = $PolicyName
            }
            $createParams += $Settings
            
            New-CsTeamsMeetingPolicy @createParams
            
            Write-Host "    ✓ Policy created successfully" -ForegroundColor Green
        }
        
        return $true
    }
    catch {
        Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Apply configurations based on PolicyType parameter
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  APPLYING POLICY CONFIGURATIONS                                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$policiesConfigured = @()

if ($PolicyType -eq "Secure" -or $PolicyType -eq "Both") {
    if (Set-MeetingPolicySettings -PolicyName $secureSettings.PolicyName -Settings $secureSettings.Settings) {
        $policiesConfigured += "Secure"
    }
}

if ($PolicyType -eq "Regular" -or $PolicyType -eq "Both") {
    if (Set-MeetingPolicySettings -PolicyName $regularSettings.PolicyName -Settings $regularSettings.Settings) {
        $policiesConfigured += "Regular"
    }
}

# Apply policies to group members
if ($ApplyToAllGroupMembers) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  APPLYING POLICIES TO GROUP MEMBERS                             ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    $successCount = 0
    $failCount = 0
    
    foreach ($member in $members) {
        $user = Get-MgUser -UserId $member.Id -Property DisplayName,UserPrincipalName
        
        Write-Host ""
        Write-Host "  Processing: $($user.DisplayName)" -ForegroundColor Gray
        
        try {
            # Apply Regular policy by default
            Grant-CsTeamsMeetingPolicy -Identity $user.UserPrincipalName -PolicyName "Leonardo-Regular-Meeting-Group"
            Write-Host "    ✓ Policy applied: Leonardo-Regular-Meeting-Group" -ForegroundColor Green
            $successCount++
            
            # Small delay to avoid throttling
            Start-Sleep -Seconds 2
        }
        catch {
            Write-Host "    ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
            $failCount++
        }
    }
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  POLICY APPLICATION SUMMARY                                     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Members: $($members.Count)" -ForegroundColor White
    Write-Host "Successfully Applied: $successCount" -ForegroundColor Green
    if ($failCount -gt 0) {
        Write-Host "Failed: $failCount" -ForegroundColor Red
    }
    else {
        Write-Host "Failed: $failCount" -ForegroundColor Green
    }
}

# Display settings summary
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  CONFIGURATION SUMMARY                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "POLICY: Leonardo-Secure-Meeting-Group" -ForegroundColor Yellow
Write-Host "  Lobby Bypass: Organization users only" -ForegroundColor White
Write-Host "  Anonymous Users: Blocked" -ForegroundColor White
Write-Host "  Phone Dial-in: Must wait in lobby" -ForegroundColor White
Write-Host "  Watermarks: ✓ Enabled (camera + screen)" -ForegroundColor Green
Write-Host "  Presenters: Organizer controls" -ForegroundColor White
Write-Host "  External Control: Disabled" -ForegroundColor White
Write-Host "  AI Content Extraction: Disabled" -ForegroundColor White

Write-Host ""
Write-Host "POLICY: Leonardo-Regular-Meeting-Group" -ForegroundColor Yellow
Write-Host "  Lobby Bypass: Organization + guests" -ForegroundColor White
Write-Host "  Anonymous Users: Allowed to join" -ForegroundColor White
Write-Host "  Phone Dial-in: Can bypass lobby" -ForegroundColor White
Write-Host "  Watermarks: ✗ Disabled" -ForegroundColor Gray
Write-Host "  Presenters: Anyone can present" -ForegroundColor White
Write-Host "  External Control: Enabled" -ForegroundColor White
Write-Host "  AI Content Extraction: Enabled" -ForegroundColor White

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  IMPORTANT NOTES                                                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "⚠️  These settings apply to NEW meetings only" -ForegroundColor Yellow
Write-Host "⚠️  Existing meetings retain their original settings" -ForegroundColor Yellow
Write-Host "⚠️  Users can override some settings per meeting" -ForegroundColor Yellow
Write-Host "⚠️  Policy changes can take up to 24 hours to propagate" -ForegroundColor Yellow

Write-Host ""
Write-Host "📝 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Wait 24 hours for policy propagation" -ForegroundColor White
Write-Host "  2. Have users sign out and back into Teams" -ForegroundColor White
Write-Host "  3. Create test meetings to verify settings" -ForegroundColor White
Write-Host "  4. Document in change log" -ForegroundColor White

# Export configuration for documentation
$exportData = @{
    Date = Get-Date
    PoliciesConfigured = $policiesConfigured
    SecureSettings = $secureSettings.Settings
    RegularSettings = $regularSettings.Settings
    MembersProcessed = $members.Count
    AppliedToMembers = $ApplyToAllGroupMembers.IsPresent
}

$exportPath = "C:\LeonardoReports\MeetingOptions-Config-$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
New-Item -Path "C:\LeonardoReports" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
$exportData | ConvertTo-Json -Depth 10 | Out-File $exportPath

Write-Host ""
Write-Host "✓ Configuration exported: $exportPath" -ForegroundColor Gray

# Cleanup
Disconnect-MicrosoftTeams
Disconnect-MgGraph

Write-Host ""
Write-Host "✅ Default meeting options configured successfully" -ForegroundColor Green
Write-Host ""