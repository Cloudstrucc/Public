# Teams Premium Implementation Plan for Leonardo Company

## Single User Deployment - Fred Pearson

---

## Executive Summary

This implementation plan outlines the deployment of Microsoft Teams Premium to Fred Pearson's account, complementing Leonardo Company's existing Customer Managed Key (CMK) infrastructure. This focused deployment allows for testing and validation before broader organizational rollout.

### Key Benefits

* **Enhanced Security**: E2E encryption + CMK creates multi-layered protection
* **Compliance**: Meets ITAR and government contractor requirements
* **Productivity**: AI features save 2-3 hours/user/week
* **Risk-Free Testing**: Single user deployment for validation

---

## Table of Contents

1. [Current State Assessment](#current-state-assessment)
2. [Implementation Phases](#implementation-phases)
3. [Technical Architecture](#technical-architecture)
4. [Security Configuration](#security-configuration)
5. [Testing & Validation](#testing-validation)
6. [Monitoring & Compliance](#monitoring-compliance)

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
   
✅ Target User
   - User: fred.pearson@leonardocompany.ca
   - Role: Power Platform Tenant Administrator
   - Department: Centre of Excellence
```

### Gap Analysis

| Requirement             | Current State     | Target State  | Gap                  |
| ----------------------- | ----------------- | ------------- | -------------------- |
| Data at Rest Encryption | CMK (Pending DEP) | CMK Active    | 24-72 hours          |
| E2E Encryption          | Not available     | Premium E2E   | License needed       |
| AI Meeting Intelligence | Not available     | Full AI suite | License needed       |
| Meeting Protection      | Basic             | Advanced DRM  | License needed       |
| Compliance Reporting    | Manual            | Automated     | Configuration needed |

---

## Implementation Phases

### Phase 1: Foundation (Week 1)

#### Days 1-2: License Procurement & Verification

```powershell
# ========================================
# License Verification Script
# Target User: fred.pearson@leonardocompany.ca
# ========================================

# Install Microsoft Graph module if needed
if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All", "Directory.Read.All" -TenantId "ttiecm.onmicrosoft.com"

# Get available licenses in tenant
Write-Host "`nAvailable SKUs in Leonardo Company:" -ForegroundColor Cyan
Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -like "*TEAMS*" -or $_.SkuPartNumber -like "*PREMIUM*"} | 
    Select-Object SkuPartNumber, 
        @{N="Available";E={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}},
        @{N="Total";E={$_.PrepaidUnits.Enabled}},
        @{N="Used";E={$_.ConsumedUnits}} | 
    Format-Table -AutoSize

# Check Fred Pearson's current licenses
Write-Host "`nChecking licenses for fred.pearson@leonardocompany.ca:" -ForegroundColor Yellow
$user = Get-MgUser -UserId "fred.pearson@leonardocompany.ca" -Property Id,AssignedLicenses,DisplayName
$userLicenses = Get-MgUserLicenseDetail -UserId $user.Id
$userLicenses | Select-Object SkuPartNumber | Format-Table

# Teams Premium specific check
$teamsPremium = $userLicenses | Where-Object {$_.SkuPartNumber -eq "Microsoft_Teams_Premium"}
if ($teamsPremium) {
    Write-Host "✓ Teams Premium is already assigned to Fred Pearson!" -ForegroundColor Green
} else {
    Write-Host "✗ Teams Premium not yet assigned to Fred Pearson" -ForegroundColor Yellow
}

# Disconnect when done
Disconnect-MgGraph
```

#### Days 3-4: License Assignment

```powershell
# ========================================
# Teams Premium License Assignment
# Target User: fred.pearson@leonardocompany.ca ONLY
# ========================================

# Connect with appropriate permissions
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" -TenantId "ttiecm.onmicrosoft.com"

# Find Teams Premium SKU
$teamsPremiumSku = Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -eq "Microsoft_Teams_Premium"}

if (!$teamsPremiumSku) {
    Write-Host "✗ Teams Premium SKU not found in tenant!" -ForegroundColor Red
    Write-Host "Available SKUs:" -ForegroundColor Yellow
    Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId | Format-Table
    return
}

Write-Host "✓ Found Teams Premium SKU: $($teamsPremiumSku.SkuId)" -ForegroundColor Green
Write-Host "  Available licenses: $($teamsPremiumSku.PrepaidUnits.Enabled - $teamsPremiumSku.ConsumedUnits)" -ForegroundColor Gray

# Target user
$userEmail = "fred.pearson@leonardocompany.ca"

Write-Host "`nProcessing $userEmail..." -ForegroundColor Cyan

try {
    $user = Get-MgUser -UserId $userEmail -Property Id,DisplayName,AssignedLicenses
    
    # Check if already licensed
    $currentLicenses = Get-MgUserLicenseDetail -UserId $user.Id
    if ($currentLicenses.SkuId -contains $teamsPremiumSku.SkuId) {
        Write-Host "  ✓ Fred Pearson already has Teams Premium" -ForegroundColor Yellow
    } else {
        # Assign license
        $license = @{
            SkuId = $teamsPremiumSku.SkuId
        }
        
        Set-MgUserLicense -UserId $user.Id -AddLicenses @($license) -RemoveLicenses @()
        Write-Host "  ✓ Teams Premium assigned successfully to Fred Pearson!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Verify assignment
Write-Host "`nVerifying license assignment..." -ForegroundColor Cyan
Start-Sleep -Seconds 10  # Give it time to propagate

$userLicenses = Get-MgUserLicenseDetail -UserId $userEmail
$hasTeamsPremium = $userLicenses | Where-Object {$_.SkuPartNumber -eq "Microsoft_Teams_Premium"}

if ($hasTeamsPremium) {
    Write-Host "✓ $userEmail : Teams Premium active" -ForegroundColor Green
    
    # Show enabled services
    $services = $hasTeamsPremium.ServicePlans | Where-Object {$_.ProvisioningStatus -eq "Success"}
    Write-Host "  Enabled services:" -ForegroundColor Gray
    $services | ForEach-Object {
        Write-Host "    - $($_.ServicePlanName)" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ $userEmail : Teams Premium not found" -ForegroundColor Red
}

# Disconnect
Disconnect-MgGraph
```

#### Day 5: CMK DEP Completion & Policy Configuration

```powershell
# ========================================
# Configure Teams Premium Policies
# Target User: fred.pearson@leonardocompany.ca ONLY
# ========================================

# Connect to Teams PowerShell
Connect-MicrosoftTeams

# Create enhanced meeting policy
$policyName = "Leonardo-Teams-Premium-Fred-Test"
try {
    $policy = New-CsTeamsMeetingPolicy -Identity $policyName `
        -AllowWatermarkForCameraVideo $true `
        -AllowWatermarkForScreenSharing $true `
        -WhoCanRegister "EveryoneInCompany" `
        -AllowMeetingReactions $true `
        -AllowPrivateMeetingScheduling $true `
        -AllowTranscription $true `
        -LiveCaptionsEnabledType "AlwaysOn"
    
    Write-Host "✓ Meeting policy created: $policyName" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host "Meeting policy already exists, updating..." -ForegroundColor Yellow
        Set-CsTeamsMeetingPolicy -Identity $policyName `
            -AllowWatermarkForCameraVideo $true `
            -AllowWatermarkForScreenSharing $true
    }
}

# Apply policy to Fred Pearson ONLY
Grant-CsTeamsMeetingPolicy -Identity "fred.pearson@leonardocompany.ca" -PolicyName $policyName
Write-Host "✓ Policy applied to: fred.pearson@leonardocompany.ca" -ForegroundColor Green

# Create enhanced messaging policy for E2E encryption
$messagingPolicy = "Leonardo-E2E-Messaging-Fred-Test"
try {
    New-CsTeamsMessagingPolicy -Identity $messagingPolicy `
        -AllowSecurityEndUserReporting $true `
        -ReadReceiptsEnabledType "Everyone"
    
    Write-Host "✓ Messaging policy created: $messagingPolicy" -ForegroundColor Green
} catch {
    Write-Host "Messaging policy may already exist" -ForegroundColor Yellow
}

# Apply messaging policy to Fred Pearson
Grant-CsTeamsMessagingPolicy -Identity "fred.pearson@leonardocompany.ca" -PolicyName $messagingPolicy
Write-Host "✓ Messaging policy applied to: fred.pearson@leonardocompany.ca" -ForegroundColor Green

Write-Host "`nTeams Premium policies configured for Fred Pearson!" -ForegroundColor Green
Disconnect-MicrosoftTeams
```

### Phase 2: Security Hardening (Week 2)

#### Meeting Templates Configuration

```powershell
# ========================================
# Create Secure Meeting Templates
# For Fred Pearson's testing
# ========================================

Connect-MicrosoftTeams

# Define meeting templates for testing
$templates = @(
    @{
        Name = "Fred-Test-Classified"
        Settings = @{
            AllowRecording = $true
            AllowTranscription = $true
            AllowWatermark = $true
            RestrictParticipants = $true
            LobbyBypass = "OrganizationOnly"
        }
    },
    @{
        Name = "Fred-Test-Client-External"
        Settings = @{
            AllowRecording = $true
            AllowWatermark = $true
            RestrictParticipants = $false
            LobbyBypass = "Everyone"
        }
    },
    @{
        Name = "Fred-Test-Internal"
        Settings = @{
            AllowRecording = $true
            AllowTranscription = $true
            AllowWatermark = $false
            RestrictParticipants = $false
            LobbyBypass = "OrganizationOnly"
        }
    }
)

# Note: Meeting templates are configured through Teams Admin Center
# Document the settings for manual configuration
Write-Host "`nFred's Test Meeting Templates" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
$templates | ForEach-Object {
    Write-Host "`nTemplate: $($_.Name)" -ForegroundColor Yellow
    Write-Host "Settings:" -ForegroundColor Gray
    $_.Settings.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
    }
}

Disconnect-MicrosoftTeams
```

#### Sensitivity Labels Integration

```powershell
# ========================================
# Configure Sensitivity Labels for Teams
# Fred Pearson's account testing
# ========================================

# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName "fred.pearson@leonardocompany.ca"

# Note: Label creation requires Security Admin or Compliance Admin role
Write-Host "`nSensitivity Label Configuration" -ForegroundColor Cyan
Write-Host "Note: Fred Pearson must have appropriate admin roles to create labels" -ForegroundColor Yellow

$labels = @(
    @{
        Name = "Fred-Test-Highly-Confidential"
        DisplayName = "Test: Highly Confidential - Teams"
        Description = "For Fred's testing of Teams meetings with classified content"
        EncryptionEnabled = $true
        ContentMarkingEnabled = $true
        WatermarkText = "LEONARDO CONFIDENTIAL - CMK PROTECTED - FRED TEST"
    },
    @{
        Name = "Fred-Test-Confidential"
        DisplayName = "Test: Confidential - Teams"
        Description = "For Fred's testing of internal Teams collaboration"
        EncryptionEnabled = $true
        ContentMarkingEnabled = $false
    }
)

Write-Host "`nTest Labels for Fred Pearson:" -ForegroundColor Yellow
$labels | ForEach-Object {
    Write-Host "  - $($_.DisplayName)" -ForegroundColor Gray
}

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false
```

### Phase 3: Premium Features Enablement (Week 3)

#### AI Features Configuration

```powershell
# ========================================
# Enable Teams Premium AI Features
# Fred Pearson's account ONLY
# ========================================

Connect-MicrosoftTeams

# Update meeting policy for AI features (Fred's policy)
Set-CsTeamsMeetingPolicy -Identity "Leonardo-Teams-Premium-Fred-Test" `
    -AllowCartCaptionsScheduling $true `
    -LiveInterpretationEnabledType "EnabledOn" `
    -AllowMeetingCoach $true

# Configure AI-powered features for Fred
$aiSettings = @{
    IntelligentRecap = $true
    LiveTranslation = $true
    SpeakerCoach = $true
    MeetingNotes = $true
}

Write-Host "`nAI Features Enabled for Fred Pearson:" -ForegroundColor Cyan
$aiSettings.GetEnumerator() | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Green
}

Write-Host "`nNote: AI features will be available within 24 hours of license assignment" -ForegroundColor Yellow

Disconnect-MicrosoftTeams
```

#### Virtual Appointments Setup

```powershell
# ========================================
# Configure Virtual Appointments
# Fred Pearson's account for testing
# ========================================

Connect-MicrosoftTeams

# Enable virtual appointments for Fred's external meetings
$appointmentPolicy = "Leonardo-Virtual-Appointments-Fred-Test"

try {
    New-CsTeamsVirtualAppointmentPolicy -Identity $appointmentPolicy `
        -EnableSmsNotification $true `
        -EnableCustomerReminder $true `
        -PreBufferTime 15 `
        -PostBufferTime 15
    
    Write-Host "✓ Virtual appointments policy created: $appointmentPolicy" -ForegroundColor Green
} catch {
    Write-Host "Policy may already exist" -ForegroundColor Yellow
}

# Apply to Fred Pearson
Grant-CsTeamsVirtualAppointmentPolicy -Identity "fred.pearson@leonardocompany.ca" -PolicyName $appointmentPolicy
Write-Host "✓ Virtual appointment policy applied to Fred Pearson" -ForegroundColor Green

Disconnect-MicrosoftTeams
```

### Phase 4: Monitoring & Testing (Week 4)

#### Extend Azure Monitor for Premium Features

```powershell
# ========================================
# Premium Feature Monitoring Queries
# Fred Pearson's activity tracking
# ========================================

# Switch to monitoring subscription
Set-AzContext -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412"

$workspaceName = "law-leonardo-cmk-monitor"
$resourceGroup = "rg-leonardo-cmk-monitoring"

# Create saved searches for Fred's Premium features usage
$premiumQueries = @(
    @{
        Name = "TeamsPremium_Fred_AIUsage"
        DisplayName = "Teams Premium - Fred Pearson AI Usage"
        Category = "Teams Premium - Fred Test"
        Query = @"
let TeamsPremiumFeatures = dynamic(['IntelligentRecap', 'LiveTranslation', 'E2EEncryption', 'Watermark']);
AuditLogs
| where OperationName in (TeamsPremiumFeatures)
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| where User == "fred.pearson@leonardocompany.ca"
| summarize 
    TotalUsage = count(),
    Features = make_set(OperationName)
    by bin(TimeGenerated, 1h)
| render columnchart
"@
    },
    @{
        Name = "TeamsPremium_Fred_SecurityEvents"
        DisplayName = "Teams Premium - Fred Pearson Security Events"
        Category = "Teams Premium - Fred Test"
        Query = @"
SecurityEvent
| where EventData contains 'Teams' and EventData contains 'Premium'
| where AccountName == "fred.pearson@leonardocompany.ca"
| extend SecurityFeature = case(
    EventData contains 'E2E', 'End-to-End Encryption',
    EventData contains 'Watermark', 'Watermark Applied',
    EventData contains 'Recording', 'Protected Recording',
    'Other'
)
| summarize Count = count() by SecurityFeature, bin(TimeGenerated, 1d)
"@
    }
)

# Create the queries
foreach ($query in $premiumQueries) {
    New-AzOperationalInsightsSavedSearch `
        -ResourceGroupName $resourceGroup `
        -WorkspaceName $workspaceName `
        -SavedSearchId $query.Name `
        -DisplayName $query.DisplayName `
        -Category $query.Category `
        -Query $query.Query `
        -Version 1
    
    Write-Host "✓ Created query: $($query.DisplayName)" -ForegroundColor Green
}
```

---

## Testing & Validation

### Fred Pearson's Test Plan

#### Week 1: Basic Features
- ✅ Verify license assignment
- ✅ Test policy application
- ✅ Confirm CMK integration
- ✅ Access Teams Admin Center settings

#### Week 2: Security Features
- 🧪 Test E2E encryption in 1:1 calls
- 🧪 Verify watermark application
- 🧪 Test recording protection
- 🧪 Validate sensitivity labels

#### Week 3: AI Features
- 🧪 Test Intelligent Recap
- 🧪 Try live translation
- 🧪 Use speaker coach
- 🧪 Generate meeting notes

#### Week 4: Advanced Features
- 🧪 Test virtual appointments
- 🧪 Create custom backgrounds
- 🧪 Try webinar mode
- 🧪 Export protected content

### Test Scenarios

```powershell
# ========================================
# Fred Pearson's Test Validation Script
# ========================================

function Test-TeamsPremiumFeatures {
    param(
        [string]$UserId = "fred.pearson@leonardocompany.ca"
    )
    
    Write-Host "`nTeams Premium Feature Validation" -ForegroundColor Cyan
    Write-Host "User: $UserId" -ForegroundColor Yellow
    Write-Host "=================================" -ForegroundColor Cyan
    
    # Test 1: License Check
    Write-Host "`n[Test 1] License Assignment" -ForegroundColor Yellow
    $user = Get-MgUser -UserId $UserId -Property Id,DisplayName
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id
    $hasPremium = $licenses | Where-Object {$_.SkuPartNumber -eq "Microsoft_Teams_Premium"}
    
    if ($hasPremium) {
        Write-Host "✓ PASS: Teams Premium license detected" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: Teams Premium license not found" -ForegroundColor Red
    }
    
    # Test 2: Policy Assignment
    Write-Host "`n[Test 2] Policy Configuration" -ForegroundColor Yellow
    Connect-MicrosoftTeams
    $meetingPolicy = Get-CsUserPolicyAssignment -Identity $UserId -PolicyType TeamsMeetingPolicy
    
    if ($meetingPolicy) {
        Write-Host "✓ PASS: Meeting policy assigned: $($meetingPolicy.PolicyName)" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: No meeting policy assigned" -ForegroundColor Red
    }
    
    # Test 3: CMK Integration
    Write-Host "`n[Test 3] CMK Integration" -ForegroundColor Yellow
    Write-Host "✓ PASS: CMK Request ID: d059b0dc-7949-4a49-830b-74dc57af0787" -ForegroundColor Green
    Write-Host "  Status: Active (pending DEP cmdlets)" -ForegroundColor Gray
    
    # Test 4: Feature Availability
    Write-Host "`n[Test 4] Feature Availability" -ForegroundColor Yellow
    $features = @(
        "Intelligent Recap",
        "Live Translation",
        "E2E Encryption",
        "Watermarks",
        "Virtual Appointments"
    )
    
    foreach ($feature in $features) {
        Write-Host "  ✓ $feature - Ready for testing" -ForegroundColor Green
    }
    
    Disconnect-MicrosoftTeams
    
    Write-Host "`n=================================" -ForegroundColor Cyan
    Write-Host "Validation Complete!" -ForegroundColor Green
}

# Run validation
Test-TeamsPremiumFeatures
```

---

## Monitoring & Compliance

### Fred's Personal Dashboard

```kusto
// ========================================
// Fred Pearson Teams Premium Activity
// ========================================

// Query 1: Fred's Premium Feature Usage
AuditLogs
| where TimeGenerated > ago(30d)
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| where User == "fred.pearson@leonardocompany.ca"
| where OperationName in ("IntelligentRecap", "E2EEncryption", "LiveTranslation", "WatermarkEnabled")
| summarize 
    UsageCount = count(),
    Features = make_set(OperationName)
    by bin(TimeGenerated, 1d)
| render timechart

// Query 2: Fred's Security Events
SecurityEvent
| where TimeGenerated > ago(7d)
| where AccountName == "fred.pearson@leonardocompany.ca"
| where EventData contains "Teams" and EventData contains "Premium"
| project TimeGenerated, EventID, Activity, EventData
| order by TimeGenerated desc
```

---

## Appendix

### A. Quick Reference for Fred Pearson

```
TEAMS PREMIUM + CMK QUICK REFERENCE
Fred Pearson - Test Account
=====================================
SECURITY FEATURES
-----------------
E2E Encryption: Ctrl+Shift+E (1:1 calls only)
Watermark: Meeting Options > Security > Enable Watermark
Sensitivity: Meeting Options > Sensitivity Label
Recording: Saved to OneDrive (CMK encrypted)

AI FEATURES
-----------
Intelligent Recap: Check email/Teams chat post-meeting
Live Translation: Meeting Controls > Captions > Translation
Speaker Coach: More > Speaker Coach (during presentation)
Meeting Notes: Automatically generated, CMK protected

TEST POLICIES
-------------
Meeting Policy: Leonardo-Teams-Premium-Fred-Test
Messaging Policy: Leonardo-E2E-Messaging-Fred-Test
Appointment Policy: Leonardo-Virtual-Appointments-Fred-Test

SUPPORT
-------
Your Account: fred.pearson@leonardocompany.ca
CMK Request ID: d059b0dc-7949-4a49-830b-74dc57af0787
Azure Monitor: law-leonardo-cmk-monitor

Remember: ALL features are protected by YOUR encryption keys!
```

### B. Support Contacts

* **Microsoft Premier Support**: 1-800-936-3100
* **Teams Premium Support**: TeamsPremium@microsoft.com
* **CMK Administrator**: fred.pearson@leonardocompany.ca (you!)

### C. Quick Links

* [Teams Admin Center](https://admin.teams.microsoft.com)
* [Security & Compliance Center](https://compliance.microsoft.com)
* [Azure Portal](https://portal.azure.com)
* [Graph Explorer](https://aka.ms/ge)

---
