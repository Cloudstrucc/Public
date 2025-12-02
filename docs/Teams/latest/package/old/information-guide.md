# Microsoft Teams Premium Feature Guide for Leonardo Company

## Executive Summary

Leonardo Company is upgrading to Microsoft Teams Premium, advanced security, and enhanced engagement features to transform how we work together. This guide outlines the new capabilities and includes implementation scripts for our secure meeting framework.

---

## 🚀 New Teams Premium Features

### 🤖 Intelligent Collaboration
**Focus on what matters most with AI-powered meetings**

#### AI-Generated Meeting Intelligence
- **Meeting Notes & Tasks**: Automatically captures key decisions and action items
- **Smart Chapters**: AI divides recordings into logical sections for easy navigation
- **Personalized Timeline Markers**: Jump to moments when you were mentioned or specific topics discussed
- **Speaker Attribution**: AI identifies who said what in transcripts

#### Live Translation
- **40 Languages Supported**: Real-time caption translation
- **Cross-border Collaboration**: No language barriers in global meetings
- **Automatic Detection**: Recognizes speaker language automatically

**Example Use Case**: *During our quarterly review with international partners, attendees can follow along in their preferred language while AI captures all action items automatically.*

---

### 🔐 Advanced Protection
**Enterprise-grade security for sensitive discussions**

#### Meeting Security Features
- **Watermarking**: Visual deterrent on video, audio, and shared content
- **End-to-End Encryption**: Secure calls for up to 200 participants
- **Recording Controls**: Restrict who can record meetings
- **Content Protection**: Disable copy/paste in meeting chat
- **Sensitivity Labels**: Classify meetings by confidentiality level

#### Controlled-Content Templates
- Pre-configured security settings
- Automatic policy application
- Compliance-ready meetings

**Example Use Case**: *Board meetings and M&A discussions automatically apply watermarks and prevent unauthorized recording.*

---

### 🎯 Rich Engagements
**Professional experiences for clients and teams**

#### Advanced Events
- **Webinars**: Registration, custom emails, attendee insights
- **Town Halls**: Stream to 20,000 participants
- **Green Room**: Presenter staging area
- **Post-Event Analytics**: Detailed engagement metrics

#### Customer Experience
- **Virtual Appointments**: Automated SMS reminders
- **Queue Management**: Intelligent routing and wait times
- **Silent Coaching**: Help agents in real-time
- **Branded Backgrounds**: Company-approved virtual backgrounds

**Example Use Case**: *Product launches stream to entire organization with real-time Q&A and automatic follow-up emails to attendees.*

---

## 🛡️ Secure Meeting Implementation

### Meeting Type Selection Framework

We're implementing two meeting types that users must choose when scheduling:

1. **🔒 Secure Meeting** - For confidential discussions
2. **📅 Standard Meeting** - For regular collaboration

### Implementation Scripts

#### 1. Create Meeting Policies

```powershell
# ========================================
# Leonardo Teams Premium Meeting Policies
# ========================================

Connect-MicrosoftTeams
Connect-IPPSSession # For sensitivity labels

# Policy 1: Secure Meetings
$securePolicyParams = @{
    Identity = "Leonardo-Secure-Meetings"
    Description = "High-security meetings with watermarks and restrictions"
    
    # Core Security Settings
    AllowCloudRecording = $true
    AllowRecordingStorageOutsideRegion = $false
    RecordingStorageMode = "OneDriveForBusiness"
    
    # Watermarking (Teams Premium)
    AllowWatermarkForCameraVideo = $true
    AllowWatermarkForScreenSharing = $true
    
    # Access Controls
    AllowAnonymousUsersToJoinMeeting = $false
    AllowAnonymousUsersToStartMeeting = $false
    AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"
    AllowPSTNUsersToBypassLobby = $false
    
    # Content Protection
    AllowMeetingChat = $true
    MeetingChatEnabledType = "EnabledExceptAnonymous"
    AllowSharedNotes = $false
    AllowWhiteboard = $false
    
    # Participant Controls
    AllowParticipantGiveRequestControl = $false
    AllowExternalParticipantGiveRequestControl = $false
    AllowPowerPointSharing = $true
    AllowTranscription = $true
    
    # Teams Premium Features
    AllowCartCaptionsScheduling = "DisabledUserOverride"
    LiveCaptionsEnabledType = "DisabledUserOverride"
    AllowMeetingRegistration = $false
    AllowEngagementReport = "Enabled"
    AllowPrivateMeetingScheduling = $true
    
    # Recording Restrictions
    AllowRecordingDownload = $false  # Prevents download
    ChannelRecordingDownload = "Deny"
    
    # Additional Security
    AllowIPVideo = $true
    MediaBitRateKb = 50000
    ScreenSharingMode = "EntireScreen"
    AllowNDIStreaming = $false
}

try {
    New-CsTeamsMeetingPolicy @securePolicyParams
    Write-Host "✓ Secure meeting policy created" -ForegroundColor Green
} catch {
    Set-CsTeamsMeetingPolicy @securePolicyParams
    Write-Host "✓ Secure meeting policy updated" -ForegroundColor Green
}

# Policy 2: Standard Meetings
$standardPolicyParams = @{
    Identity = "Leonardo-Standard-Meetings"
    Description = "Regular collaboration meetings"
    
    # Standard Settings
    AllowCloudRecording = $true
    RecordingStorageMode = "Stream"
    AllowWatermarkForCameraVideo = $false
    AllowWatermarkForScreenSharing = $false
    
    # Open Access
    AllowAnonymousUsersToJoinMeeting = $true
    AutoAdmittedUsers = "EveryoneInCompany"
    
    # Full Collaboration
    AllowMeetingChat = $true
    MeetingChatEnabledType = "Enabled"
    AllowSharedNotes = $true
    AllowWhiteboard = $true
    AllowParticipantGiveRequestControl = $true
    AllowTranscription = $true
    
    # Teams Premium Features
    AllowCartCaptionsScheduling = "EnabledUserOverride"
    LiveCaptionsEnabledType = "AlwaysOn"
    AllowEngagementReport = "Enabled"
}

try {
    New-CsTeamsMeetingPolicy @standardPolicyParams
    Write-Host "✓ Standard meeting policy created" -ForegroundColor Green
} catch {
    Set-CsTeamsMeetingPolicy @standardPolicyParams
    Write-Host "✓ Standard meeting policy updated" -ForegroundColor Green
}

Disconnect-MicrosoftTeams
```

#### 2. Configure Recording Storage Locations

```powershell
# ========================================
# Configure Secure Recording Storage
# ========================================

Connect-PnPOnline -Url "https://leonardocompany.sharepoint.com" -Interactive

# Create secure recordings library
$secureLibraryName = "SecureMeetingRecordings"
$secureLibraryParams = @{
    Title = $secureLibraryName
    Template = "DocumentLibrary"
    OnQuickLaunch = $false  # Hidden from navigation
}

New-PnPList @secureLibraryParams

# Set permissions for secure recordings
Set-PnPList -Identity $secureLibraryName -BreakRoleInheritance
Add-PnPListItem -List $secureLibraryName

# Create restricted access group
$secureRecordingsGroup = New-PnPGroup -Title "Secure Recordings Access" `
    -Description "Users with access to secure meeting recordings"

# Set custom permissions
Set-PnPGroupPermissions -Identity $secureRecordingsGroup -List $secureLibraryName `
    -AddRole "Read" -RemoveRole "Edit"

Write-Host "✓ Secure recordings library created" -ForegroundColor Green

# Configure retention policy for secure recordings
$retentionParams = @{
    Name = "SecureMeetingRecordings-Retention"
    SharePointLocation = "/sites/SecureRecordings"
    RetentionDuration = 90  # Days
    RetentionAction = "Delete"
}

# This requires Security & Compliance PowerShell
New-RetentionCompliancePolicy @retentionParams

Disconnect-PnPOnline
```

#### 3. Create Sensitivity Labels

```powershell
# ========================================
# Configure Sensitivity Labels for Teams
# ========================================

Connect-IPPSSession

# Label 1: Highly Confidential Meetings
$highlyConfidentialParams = @{
    DisplayName = "Highly Confidential - Teams Meetings"
    Name = "HighlyConfidentialTeamsMeetings"
    Comment = "For board meetings, M&A discussions, and sensitive HR matters"
    Tooltip = "This meeting will be watermarked and restricted to internal attendees only"
    
    # Encryption settings
    EncryptionEnabled = $true
    EncryptionProtectionType = "Template"
    EncryptionPromptUser = $false
    ContentExpirationDate = (Get-Date).AddDays(30)
    OfflineAccessDays = 7
    
    # Meeting specific settings
    MeetingProtectionEnabled = $true
    WatermarkEnabled = $true
    RestrictPeoplePickerEnabled = $true
    BlockGuestsEnabled = $true
    
    # Advanced settings
    AdvancedSettings = @{
        "teamslobbybypassscope" = "organizationonly"
        "teamscopypasteallowed" = "false"
        "teamsallowedpresenters" = "organization"
        "teamsvideorecordingpermission" = "organizeronly"
    }
}

New-Label @highlyConfidentialParams

# Label 2: Confidential Meetings
$confidentialParams = @{
    DisplayName = "Confidential - Teams Meetings"
    Name = "ConfidentialTeamsMeetings"
    Comment = "For internal project discussions"
    Tooltip = "This meeting is for internal use only"
    
    EncryptionEnabled = $true
    WatermarkEnabled = $false
    BlockGuestsEnabled = $false
    
    AdvancedSettings = @{
        "teamslobbybypassscope" = "everyone"
        "teamscopypasteallowed" = "true"
        "teamsallowedpresenters" = "everyoneincompanyincludingguests"
    }
}

New-Label @confidentialParams

# Label 3: Public Meetings
$publicParams = @{
    DisplayName = "Public - Teams Meetings"
    Name = "PublicTeamsMeetings"
    Comment = "For webinars and public events"
    Tooltip = "This meeting can be attended by anyone"
    
    EncryptionEnabled = $false
    WatermarkEnabled = $false
    BlockGuestsEnabled = $false
}

New-Label @publicParams

Write-Host "✓ Sensitivity labels created" -ForegroundColor Green

# Create label policy
$labelPolicyParams = @{
    Name = "Leonardo-Teams-Label-Policy"
    Labels = @(
        "HighlyConfidentialTeamsMeetings",
        "ConfidentialTeamsMeetings",
        "PublicTeamsMeetings"
    )
    Users = @("All")
    
    # Advanced settings
    AdvancedSettings = @{
        "requiredowngradejustification" = "true"
        "defaultlabelid" = "ConfidentialTeamsMeetings"  # Default to Confidential
        "outlookdefaultlabel" = "ConfidentialTeamsMeetings"
        "teamsmandatory" = "true"  # Force label selection
    }
}

New-LabelPolicy @labelPolicyParams

Disconnect-ExchangeOnline -Confirm:$false
```

#### 4. Configure DLP for Sensitive Content Detection

```powershell
# ========================================
# Data Loss Prevention for Teams Chat
# ========================================

# Create DLP policy for Teams chat monitoring
$dlpPolicyParams = @{
    Name = "Leonardo-Teams-Sensitive-Content"
    Mode = "Enable"
    
    # Locations
    ExchangeLocation = @("All")
    TeamsLocation = @("All")
    
    # What to detect
    ContentContainsSensitiveInformation = @(
        @{Name="Credit Card Number"; MinCount="1"},
        @{Name="Canadian Social Insurance Number"; MinCount="1"},
        @{Name="Leonardo Confidential"; MinCount="1"}  # Custom keyword
    )
}

New-DlpCompliancePolicy @dlpPolicyParams

# Create DLP rule for notifications
$dlpRuleParams = @{
    Name = "Notify-On-Sensitive-Content"
    Policy = "Leonardo-Teams-Sensitive-Content"
    
    # Actions
    GenerateAlert = $true
    NotifyUser = @("LastModifier", "Owner")
    NotifyUserType = "NotSet"
    NotificationContent = @"
⚠️ Sensitive Content Detected
Your message contains potentially sensitive information. Please ensure you're following Leonardo Company data protection policies.

If this is intentional, please add a sensitivity label to this conversation.
"@
    
    # Conditions
    ContentContainsSensitiveInformation = @(
        @{Name="Credit Card Number"; MinCount="1"}
    )
}

New-DlpComplianceRule @dlpRuleParams

# Create custom sensitive info type for Leonardo-specific terms
$customSensitiveType = @{
    Name = "Leonardo Confidential Terms"
    Description = "Leonardo Company confidential project names and terms"
    
    # Keywords to detect
    Keywords = @(
        "Project Tempest",
        "Operation Lightning",
        "Confidential - Do Not Share",
        "Leonardo Proprietary"
    )
}

New-DlpSensitiveInformationType @customSensitiveType
```

#### 5. Meeting Creation UI Customization

```powershell
# ========================================
# Teams App Manifest for Meeting Selection
# ========================================

# This creates a custom meeting creation experience
$manifestJson = @{
    "$schema" = "https://developer.microsoft.com/json-schemas/teams/v1.13/MicrosoftTeams.schema.json"
    "manifestVersion" = "1.13"
    "version" = "1.0.0"
    "id" = "leonardo-secure-meetings"
    "packageName" = "com.leonardocompany.securemeetings"
    "developer" = @{
        "name" = "Leonardo Company IT"
        "websiteUrl" = "https://leonardocompany.ca"
        "privacyUrl" = "https://leonardocompany.ca/privacy"
        "termsOfUseUrl" = "https://leonardocompany.ca/terms"
    }
    "name" = @{
        "short" = "Secure Meeting Selector"
        "full" = "Leonardo Secure Meeting Selector"
    }
    "description" = @{
        "short" = "Choose between Secure or Standard meetings"
        "full" = "Ensures users select appropriate security level when creating meetings"
    }
    "icons" = @{
        "outline" = "icon-outline.png"
        "color" = "icon-color.png"
    }
    "accentColor" = "#0078D4"
    
    # Meeting extension
    "meetingExtensionDefinition" = @{
        "scenes" = @(
            @{
                "id" = "meetingSetup"
                "name" = "Meeting Security Selection"
                "file" = "meetingSetup.html"
                "preview" = "preview.png"
            }
        )
        "filters" = @("meetingSetup")
    }
}

$manifestJson | ConvertTo-Json -Depth 10 | Out-File "leonardo-secure-meetings-manifest.json"
Write-Host "✓ Teams app manifest created" -ForegroundColor Green
```

#### 6. Automated Policy Assignment

```powershell
# ========================================
# Automatic Policy Assignment Based on Security Level
# ========================================

function Assign-MeetingSecurityPolicy {
    param(
        [string]$MeetingId,
        [string]$SecurityLevel,
        [string]$Organizer
    )
    
    Connect-MicrosoftTeams
    
    switch ($SecurityLevel) {
        "Secure" {
            # Apply secure meeting policy
            Grant-CsTeamsMeetingPolicy -Identity $Organizer `
                -PolicyName "Leonardo-Secure-Meetings"
            
            # Apply sensitivity label
            Set-TeamsMeetingSensitivityLabel -MeetingId $MeetingId `
                -Label "HighlyConfidentialTeamsMeetings"
            
            # Configure recording location
            Set-TeamsMeetingRecordingPath -MeetingId $MeetingId `
                -Path "/sites/SecureRecordings/SecureMeetingRecordings"
            
            Write-Host "✓ Secure meeting configured" -ForegroundColor Green
            
            # Send notification to attendees
            Send-SecureMeetingNotification -MeetingId $MeetingId
        }
        
        "Standard" {
            # Apply standard meeting policy
            Grant-CsTeamsMeetingPolicy -Identity $Organizer `
                -PolicyName "Leonardo-Standard-Meetings"
            
            # Apply standard label
            Set-TeamsMeetingSensitivityLabel -MeetingId $MeetingId `
                -Label "PublicTeamsMeetings"
            
            Write-Host "✓ Standard meeting configured" -ForegroundColor Green
        }
    }
    
    Disconnect-MicrosoftTeams
}

# Function to send secure meeting notifications
function Send-SecureMeetingNotification {
    param([string]$MeetingId)
    
    $emailTemplate = @"
<div style='border: 2px solid #FF0000; padding: 10px; background-color: #FFF0F0;'>
    <h2>🔒 Secure Meeting Notice</h2>
    <p>This meeting has been classified as <strong>SECURE</strong> with the following restrictions:</p>
    <ul>
        <li>✓ Watermarking enabled on all content</li>
        <li>✓ Recording restricted to organizer only</li>
        <li>✓ No anonymous participants allowed</li>
        <li>✓ Meeting chat cannot be copied</li>
        <li>✓ External screen recording blocked</li>
    </ul>
    <p><strong>Important:</strong> Do not share meeting details outside authorized attendees.</p>
</div>
"@
    
    # Send to all attendees
    Send-MailMessage -To $attendees -Subject "Secure Meeting: $subject" -Body $emailTemplate -BodyAsHtml
}
```

---

## 📋 Meeting Security Quick Reference

### For Meeting Organizers

| Feature | Secure Meeting | Standard Meeting |
|---------|---------------|------------------|
| **Watermarks** | ✅ Always On | ❌ Disabled |
| **Recording** | 🔒 Organizer Only | ✅ Anyone |
| **Download Recording** | ❌ Blocked | ✅ Allowed |
| **Anonymous Join** | ❌ Blocked | ✅ Allowed |
| **Chat Copy/Paste** | ❌ Disabled | ✅ Enabled |
| **Screen Capture** | ⚠️ Watermarked | ✅ Allowed |
| **External Sharing** | ❌ Blocked | ✅ Allowed |
| **Transcription** | 🔒 Secured | ✅ Standard |
| **AI Features** | 🔒 Internal Only | ✅ Full Access |
| **Storage Location** | 🔐 Secure Library | 📁 User OneDrive |

### Choosing Meeting Type

**Use SECURE Meeting for:**
- Board meetings
- HR discussions
- Financial reviews
- M&A planning
- Legal matters
- Confidential projects

**Use STANDARD Meeting for:**
- Team stand-ups
- Training sessions
- Public webinars
- Social events
- General collaboration
- External presentations

---

## 🚨 Compliance & Monitoring

### Automated Alerts

The system will automatically alert when:
- Sensitive information is shared in chat
- Unauthorized recording attempts
- External users try to join secure meetings
- Meeting policies are violated

### Monthly Compliance Report

IT will receive automated reports including:
- Number of secure vs standard meetings
- Policy violations
- Recording storage usage
- Sensitivity label adoption
- External participant statistics

---

## 🎯 Best Practices

1. **Default to Secure**: When in doubt, choose Secure meeting
2. **Review Attendees**: Verify all participants before secure meetings
3. **Test Features**: Practice with watermarks before important meetings
4. **Label Everything**: Apply sensitivity labels to all meetings
5. **Report Issues**: Contact IT if security features aren't working

---

## 📞 Support

**Teams Premium Features**: teams-support@leonardocompany.ca  
**Security Questions**: security@leonardocompany.ca  
**Training Requests**: training@leonardocompany.ca

---

*This document is classified as: Leonardo Internal Use Only*  
*Last Updated: November 2024*  
*Version: 1.0*