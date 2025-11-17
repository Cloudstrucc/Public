# Teams Premium Implementation Plan for Leonardo Company

## Group Deployment - LCE M365 Security

---

## Executive Summary

This implementation plan outlines the deployment of Microsoft Teams Premium to all members of the "LCE M365 Security" group, complementing Leonardo Company's existing Customer Managed Key (CMK) infrastructure. This group-based deployment provides enhanced security and AI-powered features to the security-focused team members.

### Key Benefits

* **Enhanced Security**: E2E encryption + CMK creates multi-layered protection
* **Compliance**: Meets ITAR and government contractor requirements
* **Productivity**: AI features save 2-3 hours/user/week
* **Group-Based Management**: Automatic policy application for all group members
* **Flexible Security**: Users choose between Secure and Regular meeting types

---

## Table of Contents

1. [Current State Assessment](#current-state-assessment)
2. [Implementation Phases](#implementation-phases)
3. [Group Management](#group-management)
4. [Technical Architecture](#technical-architecture)
5. [Security Configuration](#security-configuration)
6. [User Guide](#user-guide)
7. [Monitoring & Compliance](#monitoring-compliance)

---

## Current State Assessment

### Existing Infrastructure

```
✅ Customer Key Implementation
   - Status: Enabled (Request ID: d059b0dc-7949-4a49-830b-74dc57af0787)
   - Key Vaults: Configured and operational
   - DEP: Pending cmdlet availability (24-72 hours)
   
✅ Azure Monitoring
   - Log Analytics: Ready for deployment
   - Key Vault diagnostics: Configured
   
✅ Target Group
   - Group Name: LCE M365 Security
   - Members: Centre of Excellence team
   - Purpose: Microsoft 365 and Power Platform implementations
```

### Gap Analysis

| Requirement             | Current State     | Target State  | Gap                  |
| ----------------------- | ----------------- | ------------- | -------------------- |
| Data at Rest Encryption | CMK (Pending DEP) | CMK Active    | 24-72 hours          |
| E2E Encryption          | Not available     | Premium E2E   | License needed       |
| AI Meeting Intelligence | Not available     | Full AI suite | License needed       |
| Meeting Protection      | Basic             | Advanced DRM  | License needed       |
| Compliance Reporting    | Manual            | Automated     | Configuration needed |
| Group Policy Management | Manual            | Automated     | Script needed        |

---

## Implementation Phases

### Phase 1: Group Discovery & Policy Creation (Day 1)

#### Step 1: Identify Group Members

```powershell
# ========================================
# Discover LCE M365 Security Group Members
# ========================================

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All", "Directory.Read.All" -TenantId "ttiecm.onmicrosoft.com"

# Find the group
$groupName = "LCE M365 Security"
$group = Get-MgGroup -Filter "displayName eq '$groupName'"

if (!$group) {
    Write-Host "✗ Group not found! Searching for similar names..." -ForegroundColor Red
    $similarGroups = Get-MgGroup -Filter "startswith(displayName, 'LCE')" -All
    $similarGroups | Select-Object DisplayName, Id, Mail | Format-Table -AutoSize
    exit 1
}

Write-Host "✓ Found group: $($group.DisplayName)" -ForegroundColor Green
Write-Host "  Group ID: $($group.Id)" -ForegroundColor Gray

# Get all group members
$members = Get-MgGroupMember -GroupId $group.Id -All

Write-Host "✓ Found $($members.Count) member(s)" -ForegroundColor Green

# Get detailed user info
$users = @()
foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property Id,DisplayName,UserPrincipalName,Mail,JobTitle,Department
    $users += $user
}

# Display members
Write-Host "`nGroup Members:" -ForegroundColor Cyan
$users | Select-Object DisplayName, UserPrincipalName, JobTitle, Department | Format-Table -AutoSize

# Export for records
$users | Export-Csv "C:\LeonardoReports\LCE-M365-Security-Members.csv" -NoTypeInformation
Write-Host "`n✓ Member list exported to: C:\LeonardoReports\LCE-M365-Security-Members.csv" -ForegroundColor Green

Disconnect-MgGraph
```

#### Step 2: Verify Licenses

```powershell
# ========================================
# Verify Teams Premium Licenses for Group
# ========================================

Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All", "Directory.Read.All"

# Get group members
$groupName = "LCE M365 Security"
$group = Get-MgGroup -Filter "displayName eq '$groupName'"
$members = Get-MgGroupMember -GroupId $group.Id -All

Write-Host "`nChecking Teams Premium licenses for group members:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan

$licenseReport = @()

foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property Id,DisplayName,UserPrincipalName
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id
    
    $hasTeamsPremium = $licenses | Where-Object {$_.SkuPartNumber -eq "Microsoft_Teams_Premium"}
    
    $licenseReport += [PSCustomObject]@{
        User = $user.DisplayName
        Email = $user.UserPrincipalName
        HasTeamsPremium = if($hasTeamsPremium){"✓ Yes"}else{"✗ No"}
        LicenseCount = $licenses.Count
    }
    
    if ($hasTeamsPremium) {
        Write-Host "✓ $($user.DisplayName): Teams Premium active" -ForegroundColor Green
    } else {
        Write-Host "✗ $($user.DisplayName): Teams Premium NOT assigned" -ForegroundColor Yellow
    }
}

Write-Host "`nLicense Summary:" -ForegroundColor Cyan
$licenseReport | Format-Table -AutoSize

$withLicense = ($licenseReport | Where-Object {$_.HasTeamsPremium -eq "✓ Yes"}).Count
$withoutLicense = ($licenseReport | Where-Object {$_.HasTeamsPremium -eq "✗ No"}).Count

Write-Host "Total members: $($licenseReport.Count)" -ForegroundColor White
Write-Host "With Teams Premium: $withLicense" -ForegroundColor Green
Write-Host "Without Teams Premium: $withoutLicense" -ForegroundColor $(if($withoutLicense -gt 0){"Yellow"}else{"Green"})

if ($withoutLicense -gt 0) {
    Write-Host "`n⚠️  Note: Users without Teams Premium will need licenses assigned" -ForegroundColor Yellow
    Write-Host "   before policies can provide full functionality." -ForegroundColor Yellow
}

Disconnect-MgGraph
```

#### Step 3: Create Group-Based Policies

```powershell
# ========================================
# Create Teams Premium Policies for Group
# Two policies: Secure and Regular
# ========================================

Connect-MicrosoftTeams

$securePolicyName = "Leonardo-Secure-Meeting-Group"
$regularPolicyName = "Leonardo-Regular-Meeting-Group"

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  CREATING GROUP POLICIES                                        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# ========================================
# POLICY 1: SECURE MEETINGS
# ========================================

Write-Host "`n[1/2] Creating SECURE meeting policy..." -ForegroundColor Yellow

# Remove if exists
try {
    Remove-CsTeamsMeetingPolicy -Identity $securePolicyName -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
} catch {}

try {
    New-CsTeamsMeetingPolicy -Identity $securePolicyName `
        -Description "Secure meetings for LCE M365 Security group members" `
        `
        # === WATERMARKS - AUTO-ENABLED === #
        -AllowWatermarkForCameraVideo $true `
        -AllowWatermarkForScreenSharing $true `
        `
        # === RECORDING & TRANSCRIPTION - AUTO-ENABLED === #
        -AllowCloudRecording $true `
        -AllowRecordingStorageOutsideRegion $false `
        -AllowTranscription $true `
        -AllowCartCaptionsScheduling "EnabledUserOverride" `
        `
        # === CAPTIONS - AUTO-ENABLED === #
        -LiveCaptionsEnabledType "DisabledUserOverride" `
        `
        # === AI FEATURES - AUTO-ENABLED === #
        -AllowMeetingCoach $true `
        -LiveInterpretationEnabledType "DisabledUserOverride" `
        `
        # === STRICT SECURITY === #
        -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests" `
        -AllowPSTNUsersToBypassLobby $false `
        -AllowAnonymousUsersToJoinMeeting $false `
        -AllowAnonymousUsersToStartMeeting $false `
        `
        # === CONTENT SHARING - RESTRICTED === #
        -ScreenSharingMode "EntireScreen" `
        -AllowParticipantGiveRequestControl $true `
        -AllowExternalParticipantGiveRequestControl $false `
        `
        # === FEATURES === #
        -WhoCanRegister "EveryoneInCompany" `
        -AllowMeetingRegistration $true `
        -AllowMeetingReactions $true `
        -AllowPrivateMeetingScheduling $true `
        -AllowWhiteboard $true `
        -AllowSharedNotes $true `
        -AllowPowerPointSharing $true
    
    Write-Host "  ✓ Secure policy created!" -ForegroundColor Green
    
} catch {
    Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Disconnect-MicrosoftTeams
    exit 1
}

# ========================================
# POLICY 2: REGULAR MEETINGS
# ========================================

Write-Host "`n[2/2] Creating REGULAR meeting policy..." -ForegroundColor Yellow

# Remove if exists
try {
    Remove-CsTeamsMeetingPolicy -Identity $regularPolicyName -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
} catch {}

try {
    New-CsTeamsMeetingPolicy -Identity $regularPolicyName `
        -Description "Regular meetings for LCE M365 Security group members" `
        `
        # === WATERMARKS - DISABLED === #
        -AllowWatermarkForCameraVideo $false `
        -AllowWatermarkForScreenSharing $false `
        `
        # === RECORDING & TRANSCRIPTION - USER CHOICE === #
        -AllowCloudRecording $true `
        -AllowRecordingStorageOutsideRegion $false `
        -AllowTranscription $true `
        -AllowCartCaptionsScheduling "EnabledUserOverride" `
        `
        # === CAPTIONS - USER CHOICE === #
        -LiveCaptionsEnabledType "DisabledUserOverride" `
        `
        # === AI FEATURES - STILL AVAILABLE === #
        -AllowMeetingCoach $true `
        -LiveInterpretationEnabledType "DisabledUserOverride" `
        `
        # === RELAXED SECURITY === #
        -AutoAdmittedUsers "Everyone" `
        -AllowPSTNUsersToBypassLobby $true `
        -AllowAnonymousUsersToJoinMeeting $true `
        -AllowAnonymousUsersToStartMeeting $false `
        `
        # === CONTENT SHARING - MORE OPEN === #
        -ScreenSharingMode "EntireScreen" `
        -AllowParticipantGiveRequestControl $true `
        -AllowExternalParticipantGiveRequestControl $true `
        `
        # === FEATURES === #
        -WhoCanRegister "Everyone" `
        -AllowMeetingRegistration $true `
        -AllowMeetingReactions $true `
        -AllowPrivateMeetingScheduling $true `
        -AllowWhiteboard $true `
        -AllowSharedNotes $true `
        -AllowPowerPointSharing $true
    
    Write-Host "  ✓ Regular policy created!" -ForegroundColor Green
    
} catch {
    Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Disconnect-MicrosoftTeams
    exit 1
}

Write-Host "`n✅ Both policies created successfully!" -ForegroundColor Green

Disconnect-MicrosoftTeams
```

### Phase 2: Group Deployment (Days 2-3)

#### Deploy Policies to All Group Members

```powershell
# ========================================
# Deploy Teams Premium Policies to Group
# Target Group: LCE M365 Security
# ========================================

Connect-MicrosoftTeams
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All", "Directory.Read.All"

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  TEAMS PREMIUM GROUP DEPLOYMENT                                 ║" -ForegroundColor Cyan
Write-Host "║  Target Group: LCE M365 Security                                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Get group and members
$groupName = "LCE M365 Security"
$regularPolicyName = "Leonardo-Regular-Meeting-Group"

$group = Get-MgGroup -Filter "displayName eq '$groupName'"
if (!$group) {
    Write-Host "✗ Group not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Found group: $($group.DisplayName)" -ForegroundColor Green

$members = Get-MgGroupMember -GroupId $group.Id -All
Write-Host "✓ Found $($members.Count) member(s)" -ForegroundColor Green

# Get detailed user info
$users = @()
foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property Id,DisplayName,UserPrincipalName,Mail
    $users += $user
}

Write-Host "`nGroup members:" -ForegroundColor Cyan
$users | Select-Object DisplayName, UserPrincipalName | Format-Table -AutoSize

# Apply policies
Write-Host "`nApplying policies to group members..." -ForegroundColor Yellow
Write-Host "Default policy: $regularPolicyName (Regular meetings)" -ForegroundColor Gray
Write-Host "(Users can switch to Secure via meeting templates)" -ForegroundColor Gray
Write-Host ""

$successCount = 0
$failCount = 0
$results = @()

foreach ($user in $users) {
    Write-Host "Processing: $($user.DisplayName) ($($user.UserPrincipalName))..." -ForegroundColor Cyan
    
    try {
        # Apply Regular policy as default
        Grant-CsTeamsMeetingPolicy -Identity $user.UserPrincipalName -PolicyName $regularPolicyName
        Write-Host "  ✓ Policy applied successfully" -ForegroundColor Green
        
        $successCount++
        $results += [PSCustomObject]@{
            User = $user.DisplayName
            Email = $user.UserPrincipalName
            Status = "Success"
            Policy = $regularPolicyName
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        # Small delay to avoid throttling
        Start-Sleep -Seconds 2
        
    } catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        
        $failCount++
        $results += [PSCustomObject]@{
            User = $user.DisplayName
            Email = $user.UserPrincipalName
            Status = "Failed"
            Policy = "N/A"
            Error = $_.Exception.Message
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# Summary
Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  DEPLOYMENT SUMMARY                                             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nGroup: $groupName" -ForegroundColor Yellow
Write-Host "Total members: $($users.Count)" -ForegroundColor White
Write-Host "Successfully configured: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if($failCount -gt 0){"Red"}else{"Green"})

Write-Host "`nDetailed Results:" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Export results
$reportPath = "C:\LeonardoReports"
New-Item -Path $reportPath -ItemType Directory -Force | Out-Null

$reportFile = "$reportPath\TeamsPremium-GroupDeployment-$(Get-Date -Format 'yyyy-MM-dd-HHmm').csv"
$results | Export-Csv -Path $reportFile -NoTypeInformation
Write-Host "`n✓ Report saved to: $reportFile" -ForegroundColor Green

Disconnect-MicrosoftTeams
Disconnect-MgGraph

Write-Host "`n✅ Group deployment complete!" -ForegroundColor Green
```

### Phase 3: Meeting Templates (Day 4)

#### Create Meeting Templates in Teams Admin Center

**Manual Steps** (PowerShell cannot create templates yet):

1. Navigate to: https://admin.teams.microsoft.com/meetings/templates
2. Click "+ Add" button
3. Create the following templates:

**Template 1: Leonardo - Secure Meeting**
```
Name: Leonardo - Secure Meeting
Description: For classified, NDA, or sensitive content for LCE M365 Security team
Template type: Custom

Settings:
  Security:
    ✅ Watermark everyone's video
    ✅ Watermark shared content
    
  Lobby:
    Who can bypass: People in my organization and guests
    People dialing in can bypass: OFF
    
  Engagement:
    Who can present: Only organizers and co-organizers
    Allow mic for attendees: ON
    Allow camera for attendees: ON
    Allow meeting chat: Enabled
    Allow reactions: ON
    
  Recording & transcription:
    Automatically record: Organizer can choose
    Who can record: Organizers and co-organizers
```

**Template 2: Leonardo - Regular Meeting**
```
Name: Leonardo - Regular Meeting
Description: For team syncs and external collaboration (LCE M365 Security)
Template type: Custom

Settings:
  Security:
    ❌ Watermark everyone's video
    ❌ Watermark shared content
    
  Lobby:
    Who can bypass: Everyone
    People dialing in can bypass: ON
    
  Engagement:
    Who can present: Everyone
    Allow mic for attendees: ON
    Allow camera for attendees: ON
    Allow meeting chat: Enabled
    Allow reactions: ON
    
  Recording & transcription:
    Automatically record: Organizer can choose
    Who can record: Organizers, co-organizers, presenters
```

### Phase 4: User Communication & Training (Day 5)

#### Email Template for Group Members

```
Subject: Microsoft Teams Premium Now Available for LCE M365 Security Group

Hello LCE M365 Security Team,

You now have access to Microsoft Teams Premium features! This gives you enhanced security and AI-powered productivity tools for your meetings.

WHAT'S NEW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Intelligent Meeting Recap - AI-generated summaries after every meeting
✅ Live Transcription - Real-time captions with speaker names
✅ Meeting Coach - Get feedback on your presentation skills
✅ Watermarks - Add security to sensitive meetings
✅ Enhanced Security - All content encrypted with our CMK keys

HOW TO USE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
When creating a meeting, you can now choose:

📋 Regular Meeting (Default)
   → Use for: Team syncs, casual calls, external collaboration
   → Features: AI tools available, open access, no watermarks

🔒 Secure Meeting (Select from template)
   → Use for: Classified content, NDA discussions, sensitive projects
   → Features: AI tools + watermarks + strict security

GETTING STARTED:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Sign out and back in to Microsoft Teams
2. Create a new meeting (Calendar → New Meeting)
3. Choose your meeting template from the dropdown:
   • "Leonardo - Regular Meeting" OR
   • "Leonardo - Secure Meeting"
4. Send invite - features are automatically configured!

DECISION GUIDE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Use SECURE meetings for:
  • Classified information
  • Financial data
  • NDA discussions
  • Legal matters
  • Personnel issues
  • Sensitive client projects

Use REGULAR meetings for:
  • Team standups
  • Casual 1:1s
  • Training sessions
  • Open brainstorming
  • External collaboration
  • Customer demos

IMPORTANT NOTES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• It may take 1-2 hours for all features to become available
• Sign out/in to Teams to refresh your policies
• All recordings are encrypted with our Customer Managed Keys
• Quick Start Guide attached

SUPPORT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Questions? Contact: fred.pearson@leonardocompany.ca
Documentation: [Link to SharePoint]
Training Videos: [Link to training]

Thank you,
Fred Pearson
Power Platform Tenant Administrator
Leonardo Company - Centre of Excellence
```

---

## Group Management

### Automatic Sync Script

This script automatically applies policies to new group members:

```powershell
# ========================================
# Sync Teams Premium Policies with Group
# Run daily to catch new members
# ========================================

param(
    [switch]$WhatIf,  # Test mode
    [switch]$Force     # Force reapply to all
)

Connect-MicrosoftTeams
Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All"

$groupName = "LCE M365 Security"
$regularPolicyName = "Leonardo-Regular-Meeting-Group"

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  TEAMS PREMIUM GROUP SYNC                                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "`n⚠️  RUNNING IN TEST MODE (WhatIf) - No changes will be made" -ForegroundColor Yellow
}

# Get group and members
$group = Get-MgGroup -Filter "displayName eq '$groupName'"
if (!$group) {
    Write-Host "✗ Group not found!" -ForegroundColor Red
    exit 1
}

$members = Get-MgGroupMember -GroupId $group.Id -All
Write-Host "`n✓ Found $($members.Count) member(s) in group" -ForegroundColor Green

# Check current policy assignments
Write-Host "`nChecking current policy assignments..." -ForegroundColor Cyan

$needsUpdate = @()

foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property Id,DisplayName,UserPrincipalName
    
    try {
        $currentPolicy = Get-CsUserPolicyAssignment -Identity $user.UserPrincipalName -PolicyType TeamsMeetingPolicy
        
        if ($currentPolicy.PolicyName -ne $regularPolicyName -or $Force) {
            $needsUpdate += [PSCustomObject]@{
                User = $user.DisplayName
                Email = $user.UserPrincipalName
                CurrentPolicy = $currentPolicy.PolicyName
                NewPolicy = $regularPolicyName
            }
        }
    } catch {
        # User doesn't have policy assigned yet
        $needsUpdate += [PSCustomObject]@{
            User = $user.DisplayName
            Email = $user.UserPrincipalName
            CurrentPolicy = "None"
            NewPolicy = $regularPolicyName
        }
    }
}

if ($needsUpdate.Count -eq 0) {
    Write-Host "✓ All group members already have correct policy!" -ForegroundColor Green
    Disconnect-MicrosoftTeams
    Disconnect-MgGraph
    exit 0
}

Write-Host "`n⚠️  Found $($needsUpdate.Count) user(s) needing policy update:" -ForegroundColor Yellow
$needsUpdate | Format-Table -AutoSize

if ($WhatIf) {
    Write-Host "`n(WhatIf mode - no changes made)" -ForegroundColor Yellow
    Disconnect-MicrosoftTeams
    Disconnect-MgGraph
    exit 0
}

Write-Host "`nApplying policies..." -ForegroundColor Cyan

foreach ($item in $needsUpdate) {
    Write-Host "Updating: $($item.User)..." -ForegroundColor White
    
    try {
        Grant-CsTeamsMeetingPolicy -Identity $item.Email -PolicyName $regularPolicyName
        Write-Host "  ✓ Policy applied" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

Write-Host "`n✅ Sync complete!" -ForegroundColor Green

Disconnect-MicrosoftTeams
Disconnect-MgGraph
```

**Usage:**
```powershell
# Test what would change
.\Sync-TeamsPremium-Group.ps1 -WhatIf

# Apply updates to new members
.\Sync-TeamsPremium-Group.ps1

# Force reapply to everyone
.\Sync-TeamsPremium-Group.ps1 -Force
```

### Scheduled Task for Automation

```powershell
# ========================================
# Create Scheduled Task for Daily Sync
# ========================================

$scriptPath = "C:\Scripts\Sync-TeamsPremium-Group.ps1"

$action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File $scriptPath"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am

$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName "Teams Premium - LCE Group Sync" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Automatically applies Teams Premium policies to new LCE M365 Security group members"

Write-Host "✓ Scheduled task created - runs daily at 2am" -ForegroundColor Green
```

---

## User Guide

### Quick Start for Group Members

```
╔══════════════════════════════════════════════════════════════════╗
║     TEAMS PREMIUM QUICK START - LCE M365 Security Group         ║
╚══════════════════════════════════════════════════════════════════╝

🎯 YOU HAVE TWO MEETING TYPES
══════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────┐
│ 🔒 SECURE MEETING                                               │
│    For: Classified, Client NDA, Sensitive Projects             │
│    Features: Watermarks, Strict Security, Full AI              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📋 REGULAR MEETING (Default)                                    │
│    For: Team Syncs, Casual Calls, External Collaboration       │
│    Features: Open Access, AI Available, No Watermarks          │
└─────────────────────────────────────────────────────────────────┘

HOW TO CREATE A MEETING
══════════════════════════════════════════════════════════════════

STEP 1: Open Teams Calendar
   └─ Click "Calendar" in left sidebar

STEP 2: Create New Meeting
   └─ Click "New meeting" button (top right)

STEP 3: Choose Your Template
   
   For REGULAR Meeting (default):
   ┌─────────────────────────────────────────┐
   │ Title: Weekly Team Sync                 │
   │ Template: [Select template ▼]           │
   │    └─ Leonardo - Regular Meeting        │
   │ Attendees: Add people...                │
   │ Date/Time: Select...                    │
   └─────────────────────────────────────────┘
   
   For SECURE Meeting:
   ┌─────────────────────────────────────────┐
   │ Title: Q4 Budget Discussion             │
   │ Template: [Select template ▼]           │
   │    └─ Leonardo - Secure Meeting ✅      │
   │ Attendees: Add people...                │
   │ Date/Time: Select...                    │
   └─────────────────────────────────────────┘

STEP 4: Click "Send"
   └─ Done! Meeting configured automatically

DECISION GUIDE
══════════════════════════════════════════════════════════════════

Use SECURE for:                 Use REGULAR for:
  • Classified info               • Team standups
  • Financial data                • Casual 1:1s
  • NDA discussions               • Training
  • Legal matters                 • Brainstorming
  • Personnel issues              • External collab
  • Sensitive projects            • Customer demos

AUTOMATIC FEATURES (No Action Needed)
══════════════════════════════════════════════════════════════════

After every meeting:
  ✅ Intelligent Recap (10-30 min via email/chat)
  ✅ Full transcript with timestamps
  ✅ Meeting notes
  ✅ CMK encryption on all content
  ✅ Watermarks (Secure meetings only)

ONE-CLICK FEATURES (During Meeting)
══════════════════════════════════════════════════════════════════

  🎥 Recording: Click "Record" button
  💬 Live Captions: Ctrl+Shift+C
  🧑‍🏫 Speaker Coach: More (...) → Speaker Coach
  📋 Whiteboard: Share → Whiteboard

KEYBOARD SHORTCUTS
══════════════════════════════════════════════════════════════════

  Ctrl + Shift + E    E2E Encryption (1:1 calls only)
  Ctrl + Shift + C    Toggle Live Captions
  Ctrl + Shift + R    Start/Stop Recording
  Ctrl + Shift + M    Mute/Unmute
  Ctrl + Shift + O    Video On/Off

SUPPORT
══════════════════════════════════════════════════════════════════

Questions: fred.pearson@leonardocompany.ca
MS Support: 1-800-936-3100
Training: [SharePoint link]
```

---

## Monitoring & Compliance

### Group Activity Dashboard

```kusto
// ========================================
// LCE M365 Security Group - Teams Premium Usage
// ========================================

// Query 1: Group Member Activity
let GroupMembers = dynamic([
    'fred.pearson@leonardocompany.ca'
    // Add all group member emails
]);
AuditLogs
| where TimeGenerated > ago(30d)
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| where User in (GroupMembers)
| where OperationName in ("IntelligentRecap", "E2EEncryption", "LiveTranslation", "WatermarkEnabled")
| summarize 
    TotalUsage = count(),
    UniqueUsers = dcount(User),
    Features = make_set(OperationName)
    by bin(TimeGenerated, 1d)
| render timechart

// Query 2: Secure vs Regular Meeting Usage
let GroupMembers = dynamic([
    'fred.pearson@leonardocompany.ca'
]);
AuditLogs
| where TimeGenerated > ago(30d)
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| where User in (GroupMembers)
| extend MeetingType = case(
    EventData contains 'Watermark', 'Secure Meeting',
    EventData contains 'Teams' and EventData contains 'Meeting', 'Regular Meeting',
    'Other'
)
| summarize Count = count() by MeetingType, bin(TimeGenerated, 1d)
| render columnchart

// Query 3: Feature Adoption by User
let GroupMembers = dynamic([
    'fred.pearson@leonardocompany.ca'
]);
AuditLogs
| where TimeGenerated > ago(30d)
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| where User in (GroupMembers)
| where OperationName in ("IntelligentRecap", "Recording", "LiveCaptions", "Watermark")
| summarize 
    MeetingsWithAI = countif(OperationName == "IntelligentRecap"),
    RecordedMeetings = countif(OperationName == "Recording"),
    CaptionUsage = countif(OperationName == "LiveCaptions"),
    SecureMeetings = countif(OperationName == "Watermark")
    by User
| order by MeetingsWithAI desc
```

### Monthly Group Report

```powershell
# ========================================
# Generate Monthly Group Report
# ========================================

function New-GroupPremiumReport {
    param(
        [string]$GroupName = "LCE M365 Security",
        [DateTime]$ReportMonth = (Get-Date).AddMonths(-1)
    )
    
    Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All"
    Connect-MicrosoftTeams
    
    $report = [PSCustomObject]@{
        ReportDate = Get-Date
        Period = $ReportMonth.ToString("MMMM yyyy")
        GroupName = $GroupName
        
        # Group Info
        GroupInfo = @{
            TotalMembers = 0
            MembersWithPremium = 0
            MembersWithPolicy = 0
        }
        
        # Usage Metrics
        Usage = @{
            TotalMeetings = 0
            SecureMeetings = 0
            RegularMeetings = 0
            AIRecapsGenerated = 0
            RecordedMeetings = 0
        }
        
        # Feature Adoption
        Adoption = @{
            WatermarkUsage = 0
            LiveCaptionsUsage = 0
            SpeakerCoachUsage = 0
            TranscriptionUsage = 0
        }
        
        # CMK Integration
        CMKStatus = @{
            EncryptedMeetings = 0
            KeyVaultOperations = 0
            Availability = "99.9%"
        }
    }
    
    # Get group members
    $group = Get-MgGroup -Filter "displayName eq '$GroupName'"
    $members = Get-MgGroupMember -GroupId $group.Id -All
    
    $report.GroupInfo.TotalMembers = $members.Count
    
    # Check licenses and policies for each member
    foreach ($member in $members) {
        $user = Get-MgUser -UserId $member.Id
        
        # Check Teams Premium license
        $licenses = Get-MgUserLicenseDetail -UserId $user.Id
        if ($licenses.SkuPartNumber -contains "Microsoft_Teams_Premium") {
            $report.GroupInfo.MembersWithPremium++
        }
        
        # Check policy assignment
        try {
            $policy = Get-CsUserPolicyAssignment -Identity $user.UserPrincipalName -PolicyType TeamsMeetingPolicy
            if ($policy.PolicyName -like "Leonardo-*") {
                $report.GroupInfo.MembersWithPolicy++
            }
        } catch {
            # No policy assigned
        }
    }
    
    # Export report
    $reportPath = "C:\LeonardoReports\TeamsPremium-Group-Report-$(Get-Date -Format 'yyyy-MM').json"
    $report | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding UTF8
    
    Write-Host "✓ Group report generated: $reportPath" -ForegroundColor Green
    
    Disconnect-MgGraph
    Disconnect-MicrosoftTeams
    
    return $report
}

# Generate report
$report = New-GroupPremiumReport
$report | Format-List
```

---

## Appendix

### A. Group Member Management

**Add new member to group:**
```powershell
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All"

$groupName = "LCE M365 Security"
$newMemberEmail = "john.doe@leonardocompany.ca"

$group = Get-MgGroup -Filter "displayName eq '$groupName'"
$user = Get-MgUser -Filter "userPrincipalName eq '$newMemberEmail'"

New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id

Write-Host "✓ Added $newMemberEmail to group" -ForegroundColor Green
Write-Host "Note: Run sync script to apply Teams Premium policies" -ForegroundColor Yellow
```

**Remove member from group:**
```powershell
Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $user.Id
Write-Host "✓ Removed $newMemberEmail from group" -ForegroundColor Green
```

### B. Policy Verification

```powershell
# Check which users have which policies
Connect-MicrosoftTeams

$groupName = "LCE M365 Security"
$group = Get-MgGroup -Filter "displayName eq '$groupName'"
$members = Get-MgGroupMember -GroupId $group.Id -All

Write-Host "`nPolicy Assignments for $groupName :" -ForegroundColor Cyan

foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property DisplayName,UserPrincipalName
    $policy = Get-CsUserPolicyAssignment -Identity $user.UserPrincipalName -PolicyType TeamsMeetingPolicy
    
    Write-Host "$($user.DisplayName): $($policy.PolicyName)" -ForegroundColor White
}
```

### C. Support Contacts

* **Group Administrator**: fred.pearson@leonardocompany.ca
* **Microsoft Premier Support**: 1-800-936-3100
* **Teams Premium Support**: TeamsPremium@microsoft.com
* **Internal IT Support**: [TBD]

### D. Quick Links

* [Teams Admin Center](https://admin.teams.microsoft.com)
* [Security & Compliance Center](https://compliance.microsoft.com)
* [Azure Portal - CMK Monitoring](https://portal.azure.com)
* [Graph Explorer](https://aka.ms/ge)
* [LCE M365 Security Group SharePoint](https://leonardocompany.sharepoint.com/sites/lce-security)

### E. Change Log

* **v3.0** (November 2025): Updated for LCE M365 Security group deployment
* **v2.0** (November 2025): Updated with Microsoft Graph PowerShell commands
* **v1.0** (November 2025): Initial single-user build book

---