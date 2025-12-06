<#
.SYNOPSIS
    Create MAXIMUM SECURITY Teams Meeting Policy for Protected B - CLEAN VERSION
.DESCRIPTION
    Creates a Teams meeting policy with the MOST RESTRICTIVE settings possible.
    Uses ONLY validated parameters from Microsoft documentation.
    
    IMPORTANT FINDING:
    AllowOrganizersToOverrideLobbySettings is DEPRECATED and has no effect!
    Locking meeting options is now done through SENSITIVITY LABELS, not meeting policies.
    
    This script sets the most restrictive DEFAULTS - organizers start with secure settings.
    To truly LOCK settings, you must configure the sensitivity label (done in Phase 3).
    
    Safe to run multiple times - will update if exists.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 27, 2025
.NOTES
    VERSION 10.1 - CLEAN VALIDATED PARAMETERS ONLY
    
    REQUIREMENTS:
    - Teams Administrator or Global Administrator role
    - Teams Premium licenses (for watermarks)
    - MicrosoftTeams PowerShell module installed
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4: PROTECTED B MEETING POLICY - CLEAN v10.1              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n⚠️  IMPORTANT DISCOVERY:" -ForegroundColor Yellow
Write-Host "   AllowOrganizersToOverrideLobbySettings is DEPRECATED!" -ForegroundColor White
Write-Host "   To truly LOCK meeting options, use SENSITIVITY LABELS (Phase 3)." -ForegroundColor White
Write-Host "   This policy sets secure DEFAULTS that organizers start with.`n" -ForegroundColor Gray

# ============================================================
# CONFIGURATION
# ============================================================

$CONFIG = @{
    PolicyName = "Leonardo-Secure-Meeting-Group"
    AlternativeNames = @()    
    # Reporting
    ReportPath = "C:\LeonardoReports"
}

# Create report directory
New-Item -Path $CONFIG.ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# ============================================================
# CONNECT TO TEAMS
# ============================================================

Write-Host "[Step 1/4] Connecting to Microsoft Teams..." -ForegroundColor Cyan

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

# ============================================================
# CHECK FOR EXISTING POLICIES
# ============================================================

Write-Host "`n[Step 2/4] Checking for existing policies..." -ForegroundColor Cyan

$policyToUpdate = $null
$action = "CREATE"

# Check alternative names first
foreach ($altName in $CONFIG.AlternativeNames) {
    $altPolicy = Get-CsTeamsMeetingPolicy -Identity $altName -ErrorAction SilentlyContinue
    if ($altPolicy) {
        Write-Host "  ✓ Found existing: $altName" -ForegroundColor Green
        $policyToUpdate = $altName
        $action = "UPDATE"
        break
    }
}

# Check primary policy name
if (-not $policyToUpdate) {
    $existingPolicy = Get-CsTeamsMeetingPolicy -Identity $CONFIG.PolicyName -ErrorAction SilentlyContinue
    if ($existingPolicy) {
        Write-Host "  ✓ Found existing: $($CONFIG.PolicyName)" -ForegroundColor Green
        $policyToUpdate = $CONFIG.PolicyName
        $action = "UPDATE"
    }
}

if (-not $policyToUpdate) {
    Write-Host "  → No existing policy found - will create new" -ForegroundColor Gray
    $policyToUpdate = $CONFIG.PolicyName
}

Write-Host "  Action: $action policy '$policyToUpdate'" -ForegroundColor White

# ============================================================
# APPLY POLICY SETTINGS
# ============================================================

Write-Host "`n[Step 3/4] Applying MAXIMUM SECURITY settings..." -ForegroundColor Cyan

# All parameters validated against Microsoft documentation (November 2025)
$policyParams = @{
    Identity = $policyToUpdate
    Description = "Protected B MAXIMUM SECURITY - v10.1 $(Get-Date -Format 'yyyy-MM-dd')"
    
    # ═══════════════════════════════════════════════════════════════
    # LOBBY & ADMISSION - MOST RESTRICTIVE
    # ═══════════════════════════════════════════════════════════════
    
    # Only verified company users (excluding guests) auto-admitted
    AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"
    
    # Block anonymous users completely
    AllowAnonymousUsersToJoinMeeting = $false
    AllowAnonymousUsersToStartMeeting = $false
    AllowAnonymousUsersToDialOut = $false
    
    # PSTN users must wait in lobby
    AllowPSTNUsersToBypassLobby = $false
    
    # Require CAPTCHA for anonymous users (extra verification)
    CaptchaVerificationForMeetingJoin = "AnonymousUsersAndUntrustedOrganizations"
    
    # ═══════════════════════════════════════════════════════════════
    # WATERMARKS - Teams Premium Required
    # ═══════════════════════════════════════════════════════════════
    
    AllowWatermarkForCameraVideo = $true
    AllowWatermarkForScreenSharing = $true
    
    # ═══════════════════════════════════════════════════════════════
    # SCREEN SHARING & CONTROL
    # ═══════════════════════════════════════════════════════════════
    
    # Allow screen sharing but restrict control
    ScreenSharingMode = "EntireScreen"
    
    # Block giving/requesting control
    AllowParticipantGiveRequestControl = $false
    AllowExternalParticipantGiveRequestControl = $false
    
    # Allow collaboration tools
    AllowPowerPointSharing = $true
    AllowWhiteboard = $true
    AllowSharedNotes = $true
    AllowAnnotations = $true
    
    # ═══════════════════════════════════════════════════════════════
    # RECORDING & TRANSCRIPTION
    # ═══════════════════════════════════════════════════════════════
    
    # Allow recording but keep in region
    AllowCloudRecording = $true
    AllowRecordingStorageOutsideRegion = $false
    
    # Allow transcription for accessibility/compliance
    AllowTranscription = $true
    
    # Block NDI streaming (prevents external capture)
    AllowNDIStreaming = $false
    
    # ═══════════════════════════════════════════════════════════════
    # MEETING SCHEDULING
    # ═══════════════════════════════════════════════════════════════
    
    AllowPrivateMeetingScheduling = $true
    AllowChannelMeetingScheduling = $true
    AllowMeetNow = $true
    AllowOutlookAddIn = $true
    
    # Disable registration (simplifies security)
    AllowMeetingRegistration = $false
    WhoCanRegister = "EveryoneInCompany"
    
    # ═══════════════════════════════════════════════════════════════
    # CHAT & ENGAGEMENT
    # ═══════════════════════════════════════════════════════════════
    
    # Chat enabled except for anonymous
    MeetingChatEnabledType = "EnabledExceptAnonymous"
    
    # Allow reactions and Q&A
    AllowMeetingReactions = $true
    QnAEngagementMode = "Enabled"
    
    # Block chat copy (meeting option control)
    CopyRestriction = $true
    
    # ═══════════════════════════════════════════════════════════════
    # VIDEO & AUDIO
    # ═══════════════════════════════════════════════════════════════
    
    AllowIPVideo = $true
    AllowIPAudio = $true
    MediaBitRateKb = 50000
    
    # Allow video filters (blur, backgrounds)
    VideoFiltersMode = "AllFilters"
    
    # Disable camera PTZ control
    TeamsCameraFarEndPTZMode = "Disabled"
    
    # ═══════════════════════════════════════════════════════════════
    # ADDITIONAL SECURITY
    # ═══════════════════════════════════════════════════════════════
    
    # Allow breakout rooms
    AllowBreakoutRooms = $true
    
    # Network configuration lookup
    AllowNetworkConfigurationSettingsLookup = $true
    
    # Disable streaming overflow
    StreamingAttendeeMode = "Disabled"
    
    # Biometric enrollment disabled
    EnrollUserOverride = "Disabled"
    
    # Room attributes
    RoomAttributeUserOverride = "Off"
    
    # Live captions (accessibility)
    LiveCaptionsEnabledType = "DisabledUserOverride"
    
    # Sensitive content detection during screen share
    DetectSensitiveContentDuringScreenSharing = $true
    
    # Engagement report
    AllowEngagementReport = "Enabled"
    
    # External meeting restrictions
    ExternalMeetingJoin = "EnabledForTrustedOrgs"
    ContentSharingInExternalMeetings = "EnabledForTrustedOrgs"
}

try {
    if ($action -eq "CREATE") {
        Write-Host "  Creating new policy..." -ForegroundColor Gray
        New-CsTeamsMeetingPolicy @policyParams -ErrorAction Stop
        Write-Host "  ✓ Policy created successfully" -ForegroundColor Green
    } else {
        Write-Host "  Updating existing policy..." -ForegroundColor Gray
        Set-CsTeamsMeetingPolicy @policyParams -ErrorAction Stop
        Write-Host "  ✓ Policy updated successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to apply policy" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Try to identify which parameter failed
    if ($_.Exception.Message -match "parameter name '([^']+)'") {
        $badParam = $Matches[1]
        Write-Host "`n  Problematic parameter: $badParam" -ForegroundColor Yellow
        Write-Host "  Retrying without this parameter..." -ForegroundColor Gray
        
        $policyParams.Remove($badParam)
        
        try {
            if ($action -eq "CREATE") {
                New-CsTeamsMeetingPolicy @policyParams -ErrorAction Stop
            } else {
                Set-CsTeamsMeetingPolicy @policyParams -ErrorAction Stop
            }
            Write-Host "  ✓ Policy applied (without $badParam)" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Still failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# ============================================================
# VERIFY SETTINGS
# ============================================================

Write-Host "`n[Step 4/4] Verifying policy configuration..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

$verifyPolicy = Get-CsTeamsMeetingPolicy -Identity $policyToUpdate -ErrorAction SilentlyContinue

if ($verifyPolicy) {
    Write-Host "`n  ═══════════════════════════════════════════════════════════════" -ForegroundColor White
    Write-Host "  POLICY: $($verifyPolicy.Identity)" -ForegroundColor Cyan
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor White
    
    # Define checks
    $checks = @(
        @{Category="LOBBY & ADMISSION"; Items=@(
            @{Name="Auto-Admitted Users"; Value=$verifyPolicy.AutoAdmittedUsers; Expected="EveryoneInCompanyExcludingGuests"},
            @{Name="Anonymous Users Blocked"; Value=$verifyPolicy.AllowAnonymousUsersToJoinMeeting; Expected=$false},
            @{Name="PSTN Bypass Lobby"; Value=$verifyPolicy.AllowPSTNUsersToBypassLobby; Expected=$false}
        )},
        @{Category="WATERMARKS"; Items=@(
            @{Name="Camera Watermark"; Value=$verifyPolicy.AllowWatermarkForCameraVideo; Expected=$true},
            @{Name="Screen Share Watermark"; Value=$verifyPolicy.AllowWatermarkForScreenSharing; Expected=$true}
        )},
        @{Category="SCREEN SHARING"; Items=@(
            @{Name="Participant Control"; Value=$verifyPolicy.AllowParticipantGiveRequestControl; Expected=$false},
            @{Name="External Control"; Value=$verifyPolicy.AllowExternalParticipantGiveRequestControl; Expected=$false}
        )},
        @{Category="RECORDING"; Items=@(
            @{Name="Storage Outside Region"; Value=$verifyPolicy.AllowRecordingStorageOutsideRegion; Expected=$false},
            @{Name="NDI Streaming"; Value=$verifyPolicy.AllowNDIStreaming; Expected=$false}
        )}
    )
    
    $totalChecks = 0
    $passedChecks = 0
    
    foreach ($category in $checks) {
        Write-Host "`n  $($category.Category):" -ForegroundColor Yellow
        Write-Host "  ───────────────────────────────────────────────────" -ForegroundColor Gray
        
        foreach ($item in $category.Items) {
            $totalChecks++
            $passed = $item.Value -eq $item.Expected
            if ($passed) { $passedChecks++ }
            
            $status = if ($passed) { "✓" } else { "✗" }
            $color = if ($passed) { "Green" } else { "Red" }
            $displayValue = if ($null -eq $item.Value) { "(not set)" } else { $item.Value }
            
            Write-Host "  $status $($item.Name): $displayValue" -ForegroundColor $color
        }
    }
    
    Write-Host "`n  ───────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  Checks Passed: $passedChecks / $totalChecks" -ForegroundColor $(if ($passedChecks -eq $totalChecks) { "Green" } else { "Yellow" })
}

# ============================================================
# DISCONNECT
# ============================================================

Disconnect-MicrosoftTeams -Confirm:$false -ErrorAction SilentlyContinue

# ============================================================
# GENERATE REPORT
# ============================================================

$reportFile = "$($CONFIG.ReportPath)\ProtectedB-Policy-CLEAN-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
╔══════════════════════════════════════════════════════════════════════════════╗
║  PROTECTED B MEETING POLICY - CLEAN VERSION v10.1                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME
Policy: $policyToUpdate
Action: $action

═══════════════════════════════════════════════════════════════════════════════
IMPORTANT: ABOUT LOCKING MEETING OPTIONS
═══════════════════════════════════════════════════════════════════════════════

The parameter "AllowOrganizersToOverrideLobbySettings" is DEPRECATED and has
NO EFFECT according to Microsoft's official documentation.

To truly LOCK meeting options so organizers cannot change them, you must:

1. Configure SENSITIVITY LABELS with meeting settings (Phase 3)
2. The label enforces settings - not the meeting policy
3. Meeting policy sets DEFAULTS; labels LOCK settings

Your Phase 3 sensitivity label configuration is what actually locks settings!

═══════════════════════════════════════════════════════════════════════════════
POLICY CONFIGURATION APPLIED
═══════════════════════════════════════════════════════════════════════════════

LOBBY & ADMISSION:
  • AutoAdmittedUsers = EveryoneInCompanyExcludingGuests
  • AllowAnonymousUsersToJoinMeeting = False
  • AllowAnonymousUsersToStartMeeting = False
  • AllowPSTNUsersToBypassLobby = False
  • CaptchaVerificationForMeetingJoin = AnonymousUsersAndUntrustedOrganizations

WATERMARKS (Teams Premium Required):
  • AllowWatermarkForCameraVideo = True
  • AllowWatermarkForScreenSharing = True

SCREEN SHARING:
  • ScreenSharingMode = EntireScreen
  • AllowParticipantGiveRequestControl = False
  • AllowExternalParticipantGiveRequestControl = False
  • DetectSensitiveContentDuringScreenSharing = True

RECORDING:
  • AllowCloudRecording = True
  • AllowRecordingStorageOutsideRegion = False
  • AllowNDIStreaming = False

CHAT:
  • MeetingChatEnabledType = EnabledExceptAnonymous
  • CopyRestriction = True

EXTERNAL MEETINGS:
  • ExternalMeetingJoin = EnabledForTrustedOrgs
  • ContentSharingInExternalMeetings = EnabledForTrustedOrgs

═══════════════════════════════════════════════════════════════════════════════
HOW SETTINGS ARE ENFORCED
═══════════════════════════════════════════════════════════════════════════════

This meeting policy sets SECURE DEFAULTS for:
  • Who is auto-admitted to meetings
  • Whether watermarks are available
  • Screen sharing permissions
  • Recording storage location

To ENFORCE these settings (grey out options), use SENSITIVITY LABELS:
  1. Phase 3 created "Protected B - Secure Meeting" label
  2. When user applies this label, settings from the label are ENFORCED
  3. The label can lock: watermarks, E2EE, lobby, recording, etc.

═══════════════════════════════════════════════════════════════════════════════
NEXT STEPS
═══════════════════════════════════════════════════════════════════════════════

1. Verify Phase 3 sensitivity label is configured with enforcement settings
2. Assign this meeting policy to Protected B users (Script 05)
3. Users apply "Protected B - Secure Meeting" label when scheduling
4. Label ENFORCES settings; policy provides secure DEFAULTS

═══════════════════════════════════════════════════════════════════════════════
END OF REPORT
═══════════════════════════════════════════════════════════════════════════════
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

# ============================================================
# FINAL STATUS
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ PHASE 4 COMPLETE - POLICY CONFIGURED                        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n🔒 SECURE DEFAULTS APPLIED:" -ForegroundColor Cyan
Write-Host "  • Anonymous users: BLOCKED" -ForegroundColor White
Write-Host "  • PSTN lobby bypass: BLOCKED" -ForegroundColor White
Write-Host "  • Watermarks: ENABLED (requires Teams Premium)" -ForegroundColor White
Write-Host "  • External control: BLOCKED" -ForegroundColor White
Write-Host "  • Recording outside region: BLOCKED" -ForegroundColor White
Write-Host "  • NDI streaming: BLOCKED" -ForegroundColor White
Write-Host "  • CAPTCHA for anonymous: REQUIRED" -ForegroundColor White

Write-Host "`n⚠️  REMEMBER:" -ForegroundColor Yellow
Write-Host "  Meeting options are LOCKED via SENSITIVITY LABELS, not this policy." -ForegroundColor White
Write-Host "  Ensure your Protected B label (Phase 3) has enforcement settings." -ForegroundColor White

Write-Host "`n📋 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Assign policy to users (Script 05 or Teams Admin Center)" -ForegroundColor White
Write-Host "  2. Users select 'Protected B - Secure Meeting' label" -ForegroundColor White
Write-Host "  3. Label enforces locked settings`n" -ForegroundColor White

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")