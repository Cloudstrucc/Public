<#
.SYNOPSIS
    PHASE 3B: Configure Sensitivity Label Meeting Enforcement Settings
.DESCRIPTION
    This script checks the current meeting settings on your sensitivity labels
    and provides guidance on how to configure them to LOCK meeting options.
    
    IMPORTANT: Meeting enforcement settings (watermarks, lobby, E2EE, etc.) 
    must be configured through the Microsoft Purview portal - they cannot be
    fully configured via PowerShell alone.
    
    This script will:
    1. Connect to Microsoft Purview
    2. Show current label configurations
    3. Display what settings CAN be configured via PowerShell
    4. Provide step-by-step instructions for Purview portal configuration
    
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 27, 2025
.NOTES
    VERSION 1.0
    
    REQUIREMENTS:
    - Teams Premium licenses (for watermarks, E2EE enforcement)
    - Exchange Online PowerShell module
    - Compliance Administrator or Global Administrator role
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 3B: SENSITIVITY LABEL MEETING ENFORCEMENT                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nThis script configures sensitivity labels to LOCK meeting options." -ForegroundColor Yellow
Write-Host "When users select 'Protected B - Secure Meeting', settings will be" -ForegroundColor Yellow
Write-Host "greyed out and enforced automatically.`n" -ForegroundColor Yellow

# ============================================================
# CONFIGURATION
# ============================================================

$CONFIG = @{
    ProtectedBLabel = "Protected B - Secure Meeting"
    GeneralLabel = "General - Regular Meeting"
    ReportPath = "C:\LeonardoReports"
}

New-Item -Path $CONFIG.ReportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# ============================================================
# CONNECT TO PURVIEW
# ============================================================

Write-Host "[Step 1/4] Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected to Purview" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n  Try running: Install-Module ExchangeOnlineManagement -Force" -ForegroundColor Yellow
    exit 1
}

# ============================================================
# GET CURRENT LABEL CONFIGURATIONS
# ============================================================

Write-Host "`n[Step 2/4] Retrieving current label configurations..." -ForegroundColor Cyan

$protectedBLabel = Get-Label -Identity $CONFIG.ProtectedBLabel -ErrorAction SilentlyContinue
$generalLabel = Get-Label -Identity $CONFIG.GeneralLabel -ErrorAction SilentlyContinue

if (-not $protectedBLabel) {
    Write-Host "  ✗ Label not found: $($CONFIG.ProtectedBLabel)" -ForegroundColor Red
    Write-Host "  Run Phase 2 first to create the labels." -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "  ✓ Found: $($protectedBLabel.DisplayName)" -ForegroundColor Green
Write-Host "    GUID: $($protectedBLabel.Guid)" -ForegroundColor Gray

if ($generalLabel) {
    Write-Host "  ✓ Found: $($generalLabel.DisplayName)" -ForegroundColor Green
    Write-Host "    GUID: $($generalLabel.Guid)" -ForegroundColor Gray
}

# ============================================================
# DISPLAY CURRENT SETTINGS
# ============================================================

Write-Host "`n[Step 3/4] Current Label Settings..." -ForegroundColor Cyan

Write-Host "`n  ═══════════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host "  PROTECTED B - SECURE MEETING" -ForegroundColor Cyan
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor White

# Get advanced settings
$advancedSettings = $protectedBLabel.Settings
Write-Host "`n  Advanced Settings:" -ForegroundColor Yellow

if ($advancedSettings -and $advancedSettings.Count -gt 0) {
    foreach ($setting in $advancedSettings) {
        Write-Host "    • $setting" -ForegroundColor Gray
    }
} else {
    Write-Host "    (No advanced settings configured)" -ForegroundColor Gray
}

# Check content type/scope
Write-Host "`n  Label Scope:" -ForegroundColor Yellow
Write-Host "    Content Type: $($protectedBLabel.ContentType)" -ForegroundColor Gray

# Check if meetings scope is enabled
$hasMeetingsScope = $protectedBLabel.ContentType -match "Meeting"
if ($hasMeetingsScope) {
    Write-Host "    ✓ Meetings scope is ENABLED" -ForegroundColor Green
} else {
    Write-Host "    ⚠ Meetings scope may not be enabled" -ForegroundColor Yellow
}

# ============================================================
# CONFIGURE VIA POWERSHELL (LIMITED)
# ============================================================

Write-Host "`n[Step 4/4] Applying PowerShell configurations..." -ForegroundColor Cyan

Write-Host "`n  Note: Most meeting enforcement settings must be configured" -ForegroundColor Yellow
Write-Host "  through the Microsoft Purview portal. PowerShell can only set" -ForegroundColor Yellow
Write-Host "  limited advanced settings.`n" -ForegroundColor Yellow

# Set color for Protected B (dark red)
try {
    Set-Label -Identity $CONFIG.ProtectedBLabel -AdvancedSettings @{color = "#A4262C"} -ErrorAction Stop
    Write-Host "  ✓ Set Protected B color: #A4262C (dark red)" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Could not set color: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Set color for General (green)
if ($generalLabel) {
    try {
        Set-Label -Identity $CONFIG.GeneralLabel -AdvancedSettings @{color = "#107C10"} -ErrorAction Stop
        Write-Host "  ✓ Set General color: #107C10 (green)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not set General color: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ============================================================
# DISCONNECT
# ============================================================

Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# ============================================================
# MANUAL CONFIGURATION INSTRUCTIONS
# ============================================================

$instructions = @"

╔══════════════════════════════════════════════════════════════════════════════╗
║  MANUAL CONFIGURATION REQUIRED - MICROSOFT PURVIEW PORTAL                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Meeting enforcement settings MUST be configured through the Purview portal.
Follow these steps to configure your "Protected B - Secure Meeting" label:

═══════════════════════════════════════════════════════════════════════════════
STEP 1: OPEN MICROSOFT PURVIEW PORTAL
═══════════════════════════════════════════════════════════════════════════════

1. Go to: https://compliance.microsoft.com
2. Sign in with your admin account
3. Navigate to: Information protection → Labels
4. Find and click on: "Protected B - Secure Meeting"
5. Click "Edit label"

═══════════════════════════════════════════════════════════════════════════════
STEP 2: CONFIGURE LABEL SCOPE
═══════════════════════════════════════════════════════════════════════════════

On the "Define the scope for this label" page, ensure these are checked:
  ☑ Files & other data assets
  ☑ Emails  
  ☑ Meetings

Click Next.

═══════════════════════════════════════════════════════════════════════════════
STEP 3: CONFIGURE PROTECTION SETTINGS
═══════════════════════════════════════════════════════════════════════════════

On the "Choose protection settings for labeled items" page:
  ☑ Apply or remove encryption (optional - for invite encryption)
  ☑ Apply content marking (optional - for headers/footers)
  ☑ Protect Teams meetings and chat  ← THIS IS CRITICAL

Click Next.

═══════════════════════════════════════════════════════════════════════════════
STEP 4: CONFIGURE TEAMS MEETING SETTINGS (CRITICAL)
═══════════════════════════════════════════════════════════════════════════════

On the "Settings for Teams meetings and chat" page, configure:

WHO CAN BYPASS THE LOBBY:
  ☑ Control who can bypass the lobby
  → Select: "Only organizers and co-organizers"
  
WHO CAN PRESENT:
  ☑ Control who can present
  → Select: "Only organizers and co-organizers"

WHO CAN RECORD:
  ☑ Control who can record and transcribe
  → Select: "Organizers and co-organizers"

END-TO-END ENCRYPTION (Teams Premium Required):
  ☑ Control end-to-end encryption for meeting video and audio
  → Select: "Apply end-to-end encryption"

WATERMARKS (Teams Premium Required):
  ☑ Control watermarks
  → ☑ Apply watermark to shared content
  → ☑ Apply watermark to everyone's video feed

AUTOMATIC RECORDING:
  ☑ Control automatic recording
  → Select your preference (recommended: On for compliance)

PREVENT COPYING CHAT:
  ☑ Prevent copying and forwarding of meeting chat

Click Next and complete the wizard.

═══════════════════════════════════════════════════════════════════════════════
STEP 5: PUBLISH THE LABEL (if not already published)
═══════════════════════════════════════════════════════════════════════════════

If you modified the label scope, you may need to republish:
1. Go to: Information protection → Label policies
2. Edit your "LCE Meeting Labels" policy
3. Ensure the modified label is included
4. Save changes

═══════════════════════════════════════════════════════════════════════════════
STEP 6: WAIT FOR PROPAGATION
═══════════════════════════════════════════════════════════════════════════════

• Changes take 24-48 hours to propagate fully
• Users may need to restart Teams/Outlook
• Test with a new meeting to verify settings are locked

═══════════════════════════════════════════════════════════════════════════════
WHAT USERS WILL SEE
═══════════════════════════════════════════════════════════════════════════════

When a user creates a meeting and selects "Protected B - Secure Meeting":

1. Meeting Options page shows settings with LOCK icons 🔒
2. Greyed-out settings cannot be changed
3. Message displays: "This setting is applied by a sensitivity label"
4. Watermarks automatically appear on video and shared content
5. E2E encryption is enforced (if configured)
6. Only organizers can bypass lobby and present

═══════════════════════════════════════════════════════════════════════════════
LICENSE REQUIREMENTS
═══════════════════════════════════════════════════════════════════════════════

For FULL enforcement, users need:
• Teams Premium - Required for watermarks, E2EE, advanced meeting controls
• Microsoft 365 E5 or E5 Compliance - For sensitivity labels

Without Teams Premium:
• Watermarks will NOT be enforced
• E2E encryption will NOT be enforced  
• Basic lobby/presenter controls still work

═══════════════════════════════════════════════════════════════════════════════
TESTING YOUR CONFIGURATION
═══════════════════════════════════════════════════════════════════════════════

After 24-48 hours:

1. Open Teams → Calendar → New Meeting
2. Click "Sensitivity" and select "Protected B - Secure Meeting"
3. Click "Meeting options"
4. Verify settings show lock icons and are greyed out
5. Try to change a locked setting - should be prevented
6. Start the meeting and verify:
   - Watermarks appear on video
   - Watermarks appear on shared content
   - External users wait in lobby

═══════════════════════════════════════════════════════════════════════════════

"@

Write-Host $instructions

# Save instructions to file
$reportFile = "$($CONFIG.ReportPath)\Phase3B-Label-Meeting-Settings-$(Get-Date -Format 'yyyyMMdd-HHmm').txt"
$instructions | Out-File $reportFile -Encoding UTF8

Write-Host "📄 Instructions saved: $reportFile" -ForegroundColor Gray

# ============================================================
# QUICK REFERENCE - PURVIEW PORTAL LINK
# ============================================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ PHASE 3B GUIDANCE COMPLETE                                  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n🔗 QUICK LINK:" -ForegroundColor Cyan
Write-Host "   https://compliance.microsoft.com/informationprotection/labels" -ForegroundColor White

Write-Host "`n📋 SUMMARY:" -ForegroundColor Cyan
Write-Host "   1. Open the Purview portal link above" -ForegroundColor White
Write-Host "   2. Edit 'Protected B - Secure Meeting' label" -ForegroundColor White
Write-Host "   3. Enable 'Protect Teams meetings and chat'" -ForegroundColor White
Write-Host "   4. Configure lobby, presenter, watermark, E2EE settings" -ForegroundColor White
Write-Host "   5. Save and wait 24-48 hours" -ForegroundColor White
Write-Host "   6. Test with a new meeting`n" -ForegroundColor White

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")