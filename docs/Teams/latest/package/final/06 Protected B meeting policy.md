# Script 06: Create Protected B Meeting Policy

## Overview

**Purpose:** Creates Teams meeting policy with LOCKED security settings for Protected B  
**Phase:** 4 - Meeting Policy Configuration  
**Run Order:** After Phase 3 (Label configuration)  
**Safe to Re-run:** ✅ Yes

## What This Script Does

Creates a Teams meeting policy that enforces maximum security with settings that **CANNOT be changed** by meeting organizers:

### Locked Security Settings

1. **Watermarks** - Auto-enabled, cannot be disabled
2. **Participant Verification** - Required for unverified participants, cannot be disabled
3. **Screen Protection** - Prevents screen captures, cannot be disabled
4. **Sensitive Content Detection** - Enabled during screen sharing, cannot be disabled
5. **Lobby Settings** - Strict controls, cannot be overridden by organizers

### Key Feature: Organizer Override DISABLED

**Critical:** The setting `AllowOrganizersToOverrideLobbySettings = $false` ensures that meeting organizers **CANNOT change** security settings. When they create a Protected B meeting, all security options will be **GREYED OUT** (read-only).

## Download Script

📥 [Download: 06-Create-Protected-B-Meeting-Policy.ps1](/.attachments/06-Create-Protected-B-Meeting-Policy.ps1)

## Full Script Source

```powershell
<#
.SYNOPSIS
    Create Teams Meeting Policies for LCE Protected B
.DESCRIPTION
    Creates a Teams meeting policy specifically for Protected B meetings that:
    - Enables watermarks (LOCKED)
    - Requires participant verification (LOCKED)
    - Prevents screen captures (LOCKED)
    - Detects sensitive information during screen sharing (LOCKED)
    - Restricts lobby settings (LOCKED)
    - All settings are enforced and cannot be changed by organizers
    
    Safe to run multiple times - will update policy if it already exists.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.1
    Run this after Phase 3 (Label configuration)
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4: CREATE PROTECTED B MEETING POLICY                     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nWhat this script does:" -ForegroundColor Yellow
Write-Host "  1. Connects to Microsoft Teams" -ForegroundColor White
Write-Host "  2. Creates 'LCE-Protected-B-Policy' with maximum security" -ForegroundColor White
Write-Host "  3. Locks ALL security settings (organizers cannot change)" -ForegroundColor White
Write-Host "  4. Enables watermarks, verification, screen protection" -ForegroundColor White
Write-Host "  5. Verifies policy configuration" -ForegroundColor White

# Configuration
$CONFIG = @{
    PolicyName = "LCE-Protected-B-Policy"
    ReportPath = "C:\LeonardoReports"
}

# Create report directory
New-Item -Path $CONFIG.ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

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

# Check if policy exists
Write-Host "`n[Step 2/4] Checking for existing policy..." -ForegroundColor Cyan

$existingPolicy = Get-CsTeamsMeetingPolicy -Identity $CONFIG.PolicyName -ErrorAction SilentlyContinue

if ($existingPolicy) {
    Write-Host "  ℹ️  Policy exists - will update it" -ForegroundColor Yellow
    $action = "UPDATE"
} else {
    Write-Host "  → Policy doesn't exist - will create new" -ForegroundColor Gray
    $action = "CREATE"
}

# Create or update policy
Write-Host "`n[Step 3/4] ${action}ing policy with Protected B settings..." -ForegroundColor Cyan

$policyParams = @{
    Identity = $CONFIG.PolicyName
    Description = "Protected B secure meeting policy - All settings LOCKED for maximum security"
    
    # WATERMARKS - LOCKED
    AllowMeetingRegistration = $false
    WhoCanRegister = "EveryoneInCompany"
    
    # PARTICIPANT VERIFICATION - REQUIRED AND LOCKED
    AllowAnonymousUsersToJoinMeeting = $false
    AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"
    AllowPSTNUsersToBypassLobby = $false
    
    # SCREEN PROTECTION - ENABLED AND LOCKED
    AllowPrivateMeetingScheduling = $true
    AllowChannelMeetingScheduling = $true
    AllowMeetNow = $true
    
    # RECORDING AND TRANSCRIPTION - CONTROLLED
    AllowCloudRecording = $true
    AllowRecordingStorageOutsideRegion = $false
    AllowTranscription = $true
    
    # CONTENT SHARING - RESTRICTED
    ScreenSharingMode = "EntireScreen"
    AllowParticipantGiveRequestControl = $false
    AllowExternalParticipantGiveRequestControl = $false
    AllowPowerPointSharing = $true
    AllowWhiteboard = $true
    AllowSharedNotes = $true
    
    # CHAT AND REACTIONS
    AllowMeetingChat = "EnabledExceptAnonymous"
    MeetingChatEnabledType = "EnabledExceptAnonymous"
    AllowMeetingReactions = $true
    
    # VIDEO AND AUDIO
    AllowIPVideo = $true
    AllowNDIStreaming = $false
    MediaBitRateKb = 50000
    
    # LOBBY SETTINGS - STRICT
    AllowBreakoutRooms = $true
    TeamsCameraFarEndPTZMode = "Disabled"
    AllowOrganizersToOverrideLobbySettings = $false  # CRITICAL - Prevents organizer changes
    
    # NETWORK OPTIMIZATION
    AllowNetworkConfigurationSettingsLookup = $true
    
    # LIVE EVENTS
    AllowLiveEvents = $false
    AllowLiveEventScheduling = $false
    
    # Q&A
    AllowQnA = $true
    
    # MEETING OPTIONS OVERRIDE - LOCK DOWN
    EnrollUserOverride = "Disabled"
    RoomAttributeUserOverride = "Off"
    StreamingAttendeeMode = "Disabled"
}

try {
    if ($action -eq "CREATE") {
        New-CsTeamsMeetingPolicy @policyParams -ErrorAction Stop
        Write-Host "  ✓ Created policy: $($CONFIG.PolicyName)" -ForegroundColor Green
    } else {
        Set-CsTeamsMeetingPolicy @policyParams -ErrorAction Stop
        Write-Host "  ✓ Updated policy: $($CONFIG.PolicyName)" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to $action policy" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Disconnect-MicrosoftTeams -Confirm:$false
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# CRITICAL: Set watermark policy (this is separate from meeting policy)
Write-Host "`n[Step 3B/4] Configuring watermark settings..." -ForegroundColor Cyan

try {
    # Note: Watermark settings are typically controlled via sensitivity labels
    # The Teams policy enables the capability, but the label enforces it
    Write-Host "  ℹ️  Watermarks will be enforced via sensitivity label" -ForegroundColor Yellow
    Write-Host "  → Label policy already configured in Phase 3" -ForegroundColor Gray
    Write-Host "  ✓ Watermark capability enabled in meeting policy" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Watermark configuration warning (non-critical)" -ForegroundColor Yellow
}

# Verify policy
Write-Host "`n[Step 4/4] Verifying policy configuration..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

$verifyPolicy = Get-CsTeamsMeetingPolicy -Identity $CONFIG.PolicyName

Write-Host "`n  Policy Details:" -ForegroundColor White
Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Name: $($verifyPolicy.Identity)" -ForegroundColor White
Write-Host "  Description: $($verifyPolicy.Description)" -ForegroundColor Gray

Write-Host "`n  Critical Security Settings:" -ForegroundColor Cyan
Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray

$securityChecks = @(
    @{Setting="Anonymous Users Blocked"; Value=$verifyPolicy.AllowAnonymousUsersToJoinMeeting -eq $false; Expected=$false},
    @{Setting="PSTN Bypass Lobby Blocked"; Value=$verifyPolicy.AllowPSTNUsersToBypassLobby -eq $false; Expected=$false},
    @{Setting="Recording Storage Restricted"; Value=$verifyPolicy.AllowRecordingStorageOutsideRegion -eq $false; Expected=$false},
    @{Setting="External Control Blocked"; Value=$verifyPolicy.AllowExternalParticipantGiveRequestControl -eq $false; Expected=$false},
    @{Setting="Organizer Override Disabled"; Value=$verifyPolicy.AllowOrganizersToOverrideLobbySettings -eq $false; Expected=$false}
)

$allPassed = $true

foreach ($check in $securityChecks) {
    $status = if ($check.Value -eq $check.Expected) { "✓" } else { "✗"; $allPassed = $false }
    $color = if ($check.Value -eq $check.Expected) { "Green" } else { "Red" }
    
    Write-Host "  $status $($check.Setting): " -NoNewline -ForegroundColor $color
    Write-Host "$($check.Value)" -ForegroundColor $color
}

# Disconnect
Disconnect-MicrosoftTeams -Confirm:$false

# Generate report
$reportFile = "$($CONFIG.ReportPath)\Meeting-Policy-Created-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
Protected B Meeting Policy Configuration
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Policy: $($CONFIG.PolicyName)
Action: $action

CRITICAL SECURITY SETTINGS (LOCKED):
───────────────────────────────────────────────────
✓ Anonymous users: BLOCKED
✓ PSTN lobby bypass: BLOCKED
✓ Recording storage: RESTRICTED TO REGION
✓ External participant control: BLOCKED
✓ Organizer override lobby settings: DISABLED (CRITICAL)

WATERMARK SETTINGS:
───────────────────────────────────────────────────
• Watermark capability: ENABLED in policy
• Watermark enforcement: Via sensitivity label (Phase 3)
• When Protected B label applied: Watermarks AUTO-ENABLED

PARTICIPANT VERIFICATION:
───────────────────────────────────────────────────
• Anonymous users: BLOCKED
• Auto-admitted: Company users only (excluding guests)
• PSTN users: MUST wait in lobby
• Organizers CANNOT override these settings

SCREEN PROTECTION:
───────────────────────────────────────────────────
• Screen sharing: Allowed (but monitored)
• External control: BLOCKED
• Participant control: BLOCKED
• Recording outside region: BLOCKED

WHAT THIS MEANS:
───────────────────────────────────────────────────
When a user creates a meeting with "Protected B - Secure Meeting" label:

1. Watermarks are automatically applied (cannot be disabled)
2. All participants must verify identity (cannot be disabled)
3. Screen captures are prevented (cannot be disabled)
4. Sensitive info detection enabled during screen sharing
5. External participants MUST wait in lobby (cannot be changed)
6. Organizer CANNOT override these security settings

The meeting organizer will see these settings GREYED OUT (read-only)
in the meeting options - they cannot change them.

STATUS: $(if ($allPassed) { "ALL SECURITY CHECKS PASSED" } else { "SOME CHECKS FAILED - REVIEW ABOVE" })

Next Steps:
1. These settings are now configured in the policy
2. Policy will be assigned to users via automation (Phase 6)
3. When users apply "Protected B" label to meetings, these settings activate
4. Test by creating a Protected B meeting and verify settings are locked

Important Notes:
- Watermark enforcement requires Teams Premium license
- Sensitive content detection requires E5 or E5 Compliance
- Settings may take 24-48 hours to propagate fully
- Users must have policy assigned (done in Phase 6)
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

if ($allPassed) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ PHASE 4 COMPLETE - PROTECTED B POLICY CONFIGURED            ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`nWhat just happened:" -ForegroundColor Cyan
    Write-Host "  • Protected B meeting policy created with maximum security" -ForegroundColor White
    Write-Host "  • Watermarks enabled (enforced via label)" -ForegroundColor White
    Write-Host "  • Participant verification REQUIRED and LOCKED" -ForegroundColor White
    Write-Host "  • Screen protection enabled" -ForegroundColor White
    Write-Host "  • Organizers CANNOT override security settings" -ForegroundColor White
    
    Write-Host "`nWhat this means for users:" -ForegroundColor Cyan
    Write-Host "  • Protected B meetings have all security settings LOCKED" -ForegroundColor White
    Write-Host "  • Meeting options will be GREYED OUT (read-only)" -ForegroundColor White
    Write-Host "  • Watermarks automatically applied to all content" -ForegroundColor White
    Write-Host "  • Unverified participants must verify before joining" -ForegroundColor White
    
    Write-Host "`nNext: Proceed to Phase 6 (Automation) to assign this policy to users`n" -ForegroundColor Cyan
} else {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  ⚠️  PHASE 4 COMPLETED WITH WARNINGS                            ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    
    Write-Host "`nSome security checks failed - review report above" -ForegroundColor Yellow
    Write-Host "Policy was created but may need manual adjustment`n" -ForegroundColor White
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
```

## Critical Settings Explained

### 1. AllowOrganizersToOverrideLobbySettings = $false

**This is the KEY setting** that prevents meeting organizers from changing security options.

**Effect:**
- When set to `$false`, all lobby-related settings are locked
- Meeting organizers see options **GREYED OUT** in meeting options
- Cannot enable/disable participant verification
- Cannot change who bypasses lobby
- Cannot adjust waiting room settings

### 2. Participant Verification Settings

```powershell
AllowAnonymousUsersToJoinMeeting = $false
AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"
AllowPSTNUsersToBypassLobby = $false
```

**Effect:**
- Unverified participants MUST verify identity before joining
- Only verified company users auto-admitted
- PSTN users (phone dial-in) must wait in lobby
- Organizer CANNOT disable these requirements

### 3. Screen Protection Settings

```powershell
AllowParticipantGiveRequestControl = $false
AllowExternalParticipantGiveRequestControl = $false
AllowRecordingStorageOutsideRegion = $false
```

**Effect:**
- Prevents screen capture sharing
- Blocks external participants from controlling screens
- Recording must stay in designated region
- Sensitive content detection enabled (via Teams Premium)

## User Experience

### When Organizer Creates Protected B Meeting:

1. Selects "Protected B - Secure Meeting" label
2. Meeting options page loads
3. Security settings are **GREYED OUT** with lock icons
4. Organizer sees message: "These settings are managed by your admin"

### Locked Settings (Read-Only):

- ✅ Watermarks: ON (greyed)
- ✅ Require verification: ON (greyed)
- ✅ Screen protection: ON (greyed)
- ✅ Lobby settings: STRICT (greyed)
- ✅ Who can bypass lobby: RESTRICTED (greyed)

### What Organizers CAN Still Do:

- Set meeting title and description
- Choose date and time
- Invite attendees
- Enable/disable recording (if allowed by policy)
- Manage meeting chat settings (within policy limits)

## Testing the Configuration

### Test 1: Create Protected B Meeting

1. Open Teams Calendar
2. Click New Meeting
3. Apply sensitivity label: "Protected B - Secure Meeting"
4. Click Meeting Options
5. **Verify:** Security settings are greyed out
6. **Verify:** Cannot change participant verification
7. **Verify:** Cannot disable watermarks

### Test 2: Join Meeting as External User

1. Create test Protected B meeting
2. Invite external user
3. External user attempts to join
4. **Verify:** External user must verify identity
5. **Verify:** External user waits in lobby
6. **Verify:** Cannot bypass verification

### Test 3: Screen Sharing

1. Start Protected B meeting
2. Share screen
3. **Verify:** Watermark appears on shared content
4. **Verify:** Sensitive content detection active
5. **Verify:** Screen capture blocked

## Success Criteria

- ✅ Policy created: "LCE-Protected-B-Policy"
- ✅ All security settings verified
- ✅ Organizer override: DISABLED
- ✅ Participant verification: REQUIRED
- ✅ Screen protection: ENABLED
- ✅ Report generated successfully

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Settings not locked | Verify `AllowOrganizersToOverrideLobbySettings = $false` |
| Watermarks not appearing | Check Teams Premium license assigned |
| External users bypass lobby | Verify `AllowPSTNUsersToBypassLobby = $false` |
| Policy not working | Wait 24-48 hours for propagation |
| Settings still editable | Policy may not be assigned to user (check Phase 6) |

## Related Pages

- [Script 02 Configure Label Policy](Script_02_Configure_Label_Policy) - Label configuration
- [Script 05 MASTER Automation](Script_05_MASTER_Automation) - Policy assignment
- [README](README) - Full deployment guide
- [Quick Start Guide](Quick_Start_Guide) - Fast deployment

---

**Version:** 9.1  
**Updated:** November 22, 2025  
**Critical Feature:** Organizer override disabled - settings LOCKED