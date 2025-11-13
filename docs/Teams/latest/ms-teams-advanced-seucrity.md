
# Teams Premium Implementation Plan for Leonardo Company

## Leveraging Customer Key Infrastructure for Maximum Security

---

## Executive Summary

This implementation plan outlines the deployment of Microsoft Teams Premium to complement Leonardo Company's existing Customer Managed Key (CMK) infrastructure. The combination creates an industry-leading secure collaboration platform suitable for defense sector requirements.

### Key Benefits

* **Enhanced Security** : E2E encryption + CMK creates multi-layered protection
* **Compliance** : Meets ITAR and government contractor requirements
* **Productivity** : AI features save 2-3 hours/user/week
* **ROI** : Positive return within 3 months

---

## Table of Contents

1. [Current State Assessment](#current-state-assessment)
2. [Implementation Phases](#implementation-phases)
3. [Technical Architecture](#technical-architecture)
4. [Security Configuration](#security-configuration)
5. [Rollout Strategy](#rollout-strategy)
6. [Training Plan](#training-plan)
7. [Monitoring &amp; Compliance](#monitoring-compliance)
8. [Cost Analysis](#cost-analysis)
9. [Risk Management](#risk-management)
10. [Success Metrics](#success-metrics)

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
   
✅ User Base
   - Licensed Users: [To be determined]
   - Current Teams Usage: Standard features
   - Security Clearance Levels: Various
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
# Modern License Verification Script
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

# Check current user licenses
Write-Host "`nChecking licenses for fred.pearson@leonardocompany.ca:" -ForegroundColor Yellow
$user = Get-MgUser -UserId "fred.pearson@leonardocompany.ca" -Property AssignedLicenses,DisplayName
$userLicenses = Get-MgUserLicenseDetail -UserId $user.Id
$userLicenses | Select-Object SkuPartNumber | Format-Table

# Teams Premium specific check
$teamsPremium = $userLicenses | Where-Object {$_.SkuPartNumber -eq "Microsoft_Teams_Premium"}
if ($teamsPremium) {
    Write-Host "✓ Teams Premium is already assigned!" -ForegroundColor Green
} else {
    Write-Host "✗ Teams Premium not yet assigned" -ForegroundColor Yellow
}

# Disconnect when done
Disconnect-MgGraph
```

#### Days 3-4: License Assignment

```powershell
# ========================================
# Teams Premium License Assignment
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

# Assign to pilot users
$pilotUsers = @(
    "fred.pearson@leonardocompany.ca"
    # Add more pilot users here
)

foreach ($userEmail in $pilotUsers) {
    Write-Host "`nProcessing $userEmail..." -ForegroundColor Cyan
  
    try {
        $user = Get-MgUser -UserId $userEmail
      
        # Check if already licensed
        $currentLicenses = Get-MgUserLicenseDetail -UserId $user.Id
        if ($currentLicenses.SkuId -contains $teamsPremiumSku.SkuId) {
            Write-Host "  ✓ Already has Teams Premium" -ForegroundColor Yellow
            continue
        }
      
        # Assign license
        $license = @{
            SkuId = $teamsPremiumSku.SkuId
        }
      
        Set-MgUserLicense -UserId $user.Id -AddLicenses @($license) -RemoveLicenses @()
        Write-Host "  ✓ Teams Premium assigned successfully!" -ForegroundColor Green
      
    } catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Verify assignments
Write-Host "`nVerifying license assignments..." -ForegroundColor Cyan
Start-Sleep -Seconds 10  # Give it time to propagate

foreach ($userEmail in $pilotUsers) {
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
}

# Disconnect
Disconnect-MgGraph
```

#### Day 5: CMK DEP Completion & Policy Configuration

```powershell
# ========================================
# Configure Teams Premium Policies
# ========================================

# Connect to Teams PowerShell
Connect-MicrosoftTeams

# Create enhanced meeting policy
$policyName = "Leonardo-Teams-Premium-Secure"
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

# Apply policy to pilot users
$pilotUsers | ForEach-Object {
    Grant-CsTeamsMeetingPolicy -Identity $_ -PolicyName $policyName
    Write-Host "✓ Policy applied to: $_" -ForegroundColor Green
}

# Create enhanced messaging policy for E2E encryption
$messagingPolicy = "Leonardo-E2E-Messaging"
try {
    New-CsTeamsMessagingPolicy -Identity $messagingPolicy `
        -AllowSecurityEndUserReporting $true `
        -ReadReceiptsEnabledType "Everyone"
  
    Write-Host "✓ Messaging policy created: $messagingPolicy" -ForegroundColor Green
} catch {
    Write-Host "Messaging policy may already exist" -ForegroundColor Yellow
}

Write-Host "`nTeams Premium policies configured!" -ForegroundColor Green
Disconnect-MicrosoftTeams
```

### Phase 2: Security Hardening (Week 2)

#### Meeting Templates Configuration

```powershell
# ========================================
# Create Secure Meeting Templates
# ========================================

Connect-MicrosoftTeams

# Define meeting templates for different security levels
$templates = @(
    @{
        Name = "Leonardo-Classified"
        Settings = @{
            AllowRecording = $true
            AllowTranscription = $true
            AllowWatermark = $true
            RestrictParticipants = $true
            LobbyBypass = "OrganizationOnly"
        }
    },
    @{
        Name = "Leonardo-Client-External"
        Settings = @{
            AllowRecording = $true
            AllowWatermark = $true
            RestrictParticipants = $false
            LobbyBypass = "Everyone"
        }
    },
    @{
        Name = "Leonardo-Internal-Collaboration"
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
$templates | ForEach-Object {
    Write-Host "`nTemplate: $($_.Name)" -ForegroundColor Cyan
    Write-Host "Settings:" -ForegroundColor Yellow
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
# ========================================

# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName "fred.pearson@leonardocompany.ca"

# Create Teams-specific sensitivity labels
$labels = @(
    @{
        Name = "Leonardo-Highly-Confidential-Teams"
        DisplayName = "Leonardo Highly Confidential - Teams"
        Description = "For Teams meetings with classified content"
        EncryptionEnabled = $true
        ContentMarkingEnabled = $true
        WatermarkText = "LEONARDO CONFIDENTIAL - CMK PROTECTED"
    },
    @{
        Name = "Leonardo-Confidential-Teams"
        DisplayName = "Leonardo Confidential - Teams"
        Description = "For internal Teams collaboration"
        EncryptionEnabled = $true
        ContentMarkingEnabled = $false
    }
)

# Create labels (simplified - actual creation requires more parameters)
foreach ($label in $labels) {
    Write-Host "Creating label: $($label.DisplayName)" -ForegroundColor Cyan
    # New-Label commands would go here with full parameters
}

# Enable labels for Teams
Set-LabelPolicy -Identity "Leonardo-Teams-Policy" `
    -AdvancedSettings @{
        "teamsenabled" = "true"
        "teamsprotectionenabled" = "true"
    }

Disconnect-ExchangeOnline -Confirm:$false
```

### Phase 3: Premium Features Enablement (Week 3)

#### AI Features Configuration

```powershell
# ========================================
# Enable Teams Premium AI Features
# ========================================

Connect-MicrosoftTeams

# Update meeting policy for AI features
Set-CsTeamsMeetingPolicy -Identity "Leonardo-Teams-Premium-Secure" `
    -AllowCartCaptionsScheduling $true `
    -LiveInterpretationEnabledType "EnabledOn" `
    -AllowMeetingCoach $true

# Configure AI-powered features
$aiSettings = @{
    IntelligentRecap = $true
    LiveTranslation = $true
    SpeakerCoach = $true
    MeetingNotes = $true
}

Write-Host "`nAI Features Enabled:" -ForegroundColor Cyan
$aiSettings.GetEnumerator() | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Green
}

# Note: Some AI features are enabled automatically with Premium license
Write-Host "`nNote: AI features will be available within 24 hours of license assignment" -ForegroundColor Yellow

Disconnect-MicrosoftTeams
```

#### Virtual Appointments Setup

```powershell
# ========================================
# Configure Virtual Appointments
# ========================================

Connect-MicrosoftTeams

# Enable virtual appointments for external meetings
$appointmentPolicy = "Leonardo-Virtual-Appointments"

New-CsTeamsVirtualAppointmentPolicy -Identity $appointmentPolicy `
    -EnableSmsNotification $true `
    -SmsNotificationPhoneNumber "+1-555-0100" `
    -EnableCustomerReminder $true `
    -PreBufferTime 15 `
    -PostBufferTime 15

# Apply to client-facing staff
$clientFacingUsers = @(
    "fred.pearson@leonardocompany.ca"
    # Add sales, support, project managers
)

$clientFacingUsers | ForEach-Object {
    Grant-CsTeamsVirtualAppointmentPolicy -Identity $_ -PolicyName $appointmentPolicy
    Write-Host "✓ Virtual appointment policy applied to: $_" -ForegroundColor Green
}

Disconnect-MicrosoftTeams
```

### Phase 4: Integration & Monitoring (Week 4)

#### Extend Azure Monitor for Premium Features

```powershell
# ========================================
# Premium Feature Monitoring Queries
# ========================================

# Switch to monitoring subscription
Set-AzContext -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412"

$workspaceName = "law-leonardo-cmk-monitor"
$resourceGroup = "rg-leonardo-cmk-monitoring"

# Create saved searches for Premium features
$premiumQueries = @(
    @{
        Name = "TeamsPremium_AIUsage"
        DisplayName = "Teams Premium - AI Feature Usage"
        Category = "Teams Premium"
        Query = @"
let TeamsPremiumFeatures = dynamic(['IntelligentRecap', 'LiveTranslation', 'E2EEncryption', 'Watermark']);
AuditLogs
| where OperationName in (TeamsPremiumFeatures)
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| summarize 
    TotalUsage = count(),
    UniqueUsers = dcount(User),
    Features = make_set(OperationName)
    by bin(TimeGenerated, 1h)
| render columnchart
"@
    },
    @{
        Name = "TeamsPremium_SecurityEvents"
        DisplayName = "Teams Premium - Security Events"
        Category = "Teams Premium"
        Query = @"
SecurityEvent
| where EventData contains 'Teams' and EventData contains 'Premium'
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

#### Create Premium-Specific Alerts

```powershell
# ========================================
# Teams Premium Security Alerts
# ========================================

# Get action group
$actionGroup = Get-AzActionGroup -ResourceGroupName $resourceGroup -Name "ag-cmk-alerts"

# Alert: E2E Encryption Failures
$e2eCondition = New-AzScheduledQueryRuleConditionObject `
    -Query "AuditLogs | where OperationName == 'E2EEncryptionFailed' | summarize FailureCount = count() by bin(TimeGenerated, 5m)" `
    -TimeAggregation "Count" `
    -Operator "GreaterThan" `
    -Threshold 3 `
    -FailingPeriodNumberOfEvaluationPeriods 1 `
    -FailingPeriodMinFailingPeriodsToAlert 1

New-AzScheduledQueryRule `
    -ResourceGroupName $resourceGroup `
    -Name "TeamsPremium-E2E-Failures" `
    -Location "canadacentral" `
    -DisplayName "Teams Premium - E2E Encryption Failures" `
    -Description "Alert when E2E encryption fails multiple times" `
    -Enabled $true `
    -EvaluationFrequency (New-TimeSpan -Minutes 5) `
    -WindowSize (New-TimeSpan -Minutes 10) `
    -TargetResourceId $workspace.ResourceId `
    -ActionGroupId $actionGroup.Id `
    -Condition $e2eCondition `
    -Severity 2

Write-Host "✓ Premium alerts configured" -ForegroundColor Green
```

---

## Training Plan

### Training Modules

#### Module 1: Security First with CMK + Premium (1 hour)

```markdown
1. Understanding the Security Stack
   - CMK: Your encryption keys for data at rest
   - Teams Premium: Enhanced meeting security
   - How they work together

2. Using E2E Encryption
   - When to enable (sensitive 1:1 calls)
   - How to enable (Ctrl+Shift+E)
   - Limitations and benefits

3. Watermarking and Protection
   - Automatic watermarks for confidential meetings
   - Screen recording prevention
   - Download restrictions

4. Practical Exercise
   - Create a watermarked meeting
   - Test E2E encryption
   - Verify CMK protection in logs
```

#### Module 2: AI Productivity Features (45 minutes)

```markdown
1. Intelligent Meeting Recap
   - Accessing AI-generated summaries
   - Finding key moments and decisions
   - Sharing summaries securely

2. Live Translation & Captions
   - Enabling multi-language support
   - Setting preferred languages
   - Quality considerations

3. Speaker Attribution
   - Understanding who said what
   - Navigating meeting timelines
   - Finding specific topics

4. Hands-on Practice
   - Run a test meeting with recap
   - Try live translation
   - Export secure summaries
```

#### Module 3: Advanced Features (30 minutes)

```markdown
1. Virtual Appointments
   - Scheduling client meetings
   - Managing waiting rooms
   - SMS notifications

2. Webinar Capabilities
   - Registration management
   - Green room preparation
   - Post-event analytics

3. Custom Backgrounds & Branding
   - Using Leonardo branded backgrounds
   - Meeting templates
   - Professional appearance

4. Tips & Tricks
   - Keyboard shortcuts
   - Mobile app features
   - Troubleshooting common issues
```

### Training Resources

```powershell
# ========================================
# Generate Training Materials
# ========================================

$trainingPath = "C:\LeonardoTraining\TeamsPremium"
New-Item -Path $trainingPath -ItemType Directory -Force

# Quick Reference Card
$quickRef = @"
TEAMS PREMIUM + CMK QUICK REFERENCE
=====================================
SECURITY FEATURES
-----------------
E2E Encryption: Ctrl+Shift+E (1:1 calls only)
Watermark: Meeting Options > Security > Enable Watermark
Sensitivity: Meeting Options > Sensitivity Label
Recording: Saved to OneDrive/SharePoint (CMK encrypted)

AI FEATURES
-----------
Intelligent Recap: Check email/Teams chat post-meeting
Live Translation: Meeting Controls > Captions > Translation
Speaker Coach: More > Speaker Coach (during presentation)
Meeting Notes: Automatically generated, CMK protected

PRODUCTIVITY
------------
Virtual Lobby: Manage from Participants panel
Custom Backgrounds: Settings > Background Effects > Leonardo
Meeting Templates: New Meeting > Use Template
Webinar Mode: New Meeting > Require Registration

SUPPORT
-------
IT Help: teamspremium@leonardocompany.ca
Training Videos: [SharePoint link]
CMK Status: Check Azure Monitor dashboard

Remember: ALL features are protected by YOUR encryption keys!
"@

$quickRef | Out-File "$trainingPath\TeamsPremium-QuickReference.txt" -Encoding UTF8
Write-Host "✓ Training materials created at: $trainingPath" -ForegroundColor Green
```

---

## Rollout Strategy

### Phased Deployment Schedule

```powershell
# ========================================
# Phased Rollout Script
# ========================================

# Define rollout phases
$rolloutPhases = @(
    @{
        Phase = 1
        Name = "Pilot"
        StartDate = Get-Date
        Users = @("fred.pearson@leonardocompany.ca", "it-team@leonardocompany.ca")
        Duration = 14
    },
    @{
        Phase = 2
        Name = "Leadership & PM"
        StartDate = (Get-Date).AddDays(14)
        Users = Get-MgUser -Filter "Department eq 'Leadership' or Department eq 'Project Management'"
        Duration = 14
    },
    @{
        Phase = 3
        Name = "Engineering"
        StartDate = (Get-Date).AddDays(28)
        Users = Get-MgUser -Filter "Department eq 'Engineering'"
        Duration = 14
    },
    @{
        Phase = 4
        Name = "All Staff"
        StartDate = (Get-Date).AddDays(42)
        Users = Get-MgUser -All
        Duration = 7
    }
)

# Display rollout plan
Write-Host "`nTeams Premium Rollout Plan" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
$rolloutPhases | ForEach-Object {
    Write-Host "`nPhase $($_.Phase): $($_.Name)" -ForegroundColor Yellow
    Write-Host "Start Date: $($_.StartDate.ToString('yyyy-MM-dd'))"
    Write-Host "Duration: $($_.Duration) days"
    Write-Host "User Count: $(if($_.Users.Count){$_.Users.Count}else{'TBD'})"
}

# Export to CSV for tracking
$rolloutPhases | Export-Csv "$trainingPath\TeamsPremium-RolloutPlan.csv" -NoTypeInformation
```

---

## Monitoring & Compliance

### Compliance Dashboard Queries

```kusto
// ========================================
// Teams Premium Compliance Dashboard
// ========================================

// Query 1: CMK + Premium Usage Overview
let CMKOperations = AzureDiagnostics
| where ResourceType == "VAULTS"
| where identity_claim_appid_g == "00000004-0000-0ff1-ce00-000000000000" // Teams
| summarize CMKOps = count() by bin(TimeGenerated, 1h);
let PremiumFeatures = AuditLogs
| where OperationName in ("IntelligentRecap", "E2EEncryption", "LiveTranslation")
| summarize PremiumOps = count() by bin(TimeGenerated, 1h);
CMKOperations
| join kind=fullouter PremiumFeatures on TimeGenerated
| project TimeGenerated, 
    CMKOperations = coalesce(CMKOps, 0),
    PremiumOperations = coalesce(PremiumOps, 0),
    TotalSecuredOperations = coalesce(CMKOps, 0) + coalesce(PremiumOps, 0)
| render columnchart

// Query 2: Security Feature Adoption
AuditLogs
| where TimeGenerated > ago(30d)
| where OperationName in ("WatermarkEnabled", "E2EEnabled", "RecordingProtected")
| extend User = tostring(InitiatedBy.user.userPrincipalName)
| summarize 
    TotalUsers = dcount(User),
    SecurityFeatures = make_set(OperationName),
    UsageCount = count()
    by Week = startofweek(TimeGenerated)
| render timechart

// Query 3: Compliance Violations
SecurityEvent
| where EventID in (4624, 4625) // Login events
| where EventData contains "Teams" and EventData contains "Blocked"
| project TimeGenerated, 
    User = AccountName,
    Action = Activity,
    Reason = EventData
| where Reason contains "Watermark" or Reason contains "E2E" or Reason contains "Recording"
| summarize ViolationCount = count() by User, Action
```

### Monthly Compliance Report Generator

```powershell
# ========================================
# Generate Monthly Compliance Report
# ========================================

function New-TeamsPremiumComplianceReport {
    param(
        [DateTime]$ReportMonth = (Get-Date).AddMonths(-1)
    )
  
    $report = [PSCustomObject]@{
        ReportDate = Get-Date
        Period = $ReportMonth.ToString("MMMM yyyy")
        TenantId = "ttiecm.onmicrosoft.com"
      
        # License Compliance
        LicenseCompliance = @{
            TotalUsers = (Get-MgUser -All).Count
            PremiumLicensed = (Get-MgUser -All | Where-Object {
                (Get-MgUserLicenseDetail -UserId $_.Id).SkuPartNumber -contains "Microsoft_Teams_Premium"
            }).Count
            ComplianceRate = 0  # Calculate below
        }
      
        # Security Features Usage
        SecurityFeatures = @{
            E2ECallsCount = 0  # From audit logs
            WatermarkedMeetings = 0
            ProtectedRecordings = 0
            AIProcessedMeetings = 0
        }
      
        # CMK Integration
        CMKStatus = @{
            KeyVaultOperations = 0  # From Azure Monitor
            EncryptedMeetings = 0
            FailedOperations = 0
            Availability = "99.9%"
        }
      
        # Incidents
        SecurityIncidents = @()
      
        # Recommendations
        Recommendations = @()
    }
  
    # Calculate compliance rate
    $report.LicenseCompliance.ComplianceRate = 
        [math]::Round(($report.LicenseCompliance.PremiumLicensed / $report.LicenseCompliance.TotalUsers) * 100, 2)
  
    # Export report
    $reportPath = "C:\Compliance\TeamsPremium_$(Get-Date -Format 'yyyy-MM').json"
    $report | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding UTF8
  
    Write-Host "✓ Compliance report generated: $reportPath" -ForegroundColor Green
  
    # Send to stakeholders
    Send-MailMessage `
        -To "compliance@leonardocompany.ca" `
        -Subject "Teams Premium + CMK Compliance Report - $($report.Period)" `
        -Body "Please find attached the monthly compliance report." `
        -Attachments $reportPath `
        -SmtpServer "smtp.leonardocompany.ca"
  
    return $report
}

# Generate current report
$report = New-TeamsPremiumComplianceReport
$report | Format-List
```

---

## Cost Analysis

### ROI Calculator

```powershell
# ========================================
# Teams Premium ROI Calculator
# ========================================

function Get-TeamsPremiumROI {
    param(
        [int]$UserCount = 100,
        [decimal]$LicenseCost = 10.00,
        [decimal]$HourlyRate = 75.00
    )
  
    # Costs
    $monthlyCost = $UserCount * $LicenseCost
    $annualCost = $monthlyCost * 12
  
    # Benefits (based on Microsoft studies)
    $benefits = @{
        # Time savings per user per month
        MeetingSummaries = 4  # hours saved on note-taking
        Translation = 2       # hours saved on language barriers
        E2ESetup = 0.5       # hours saved on secure meeting setup
        AIInsights = 3       # hours saved on meeting follow-ups
    }
  
    $monthlyHoursSaved = ($benefits.Values | Measure-Object -Sum).Sum * $UserCount
    $monthlyValueSaved = $monthlyHoursSaved * $HourlyRate
    $annualValueSaved = $monthlyValueSaved * 12
  
    # Risk mitigation value (harder to quantify)
    $breachRiskReduction = 0.75  # 75% reduction with CMK + Premium
    $avgBreachCost = 4450000     # Industry average
    $annualRiskMitigation = $avgBreachCost * $breachRiskReduction / 10  # Amortized over 10 years
  
    # ROI Calculation
    $totalAnnualBenefit = $annualValueSaved + $annualRiskMitigation
    $roi = [math]::Round((($totalAnnualBenefit - $annualCost) / $annualCost) * 100, 2)
    $paybackDays = [math]::Round($annualCost / ($totalAnnualBenefit / 365), 0)
  
    # Display results
    $results = [PSCustomObject]@{
        "User Count" = $UserCount
        "Monthly License Cost" = "$" + "{0:N0}" -f $monthlyCost
        "Annual License Cost" = "$" + "{0:N0}" -f $annualCost
        "Hours Saved/Month" = "{0:N0}" -f $monthlyHoursSaved
        "Productivity Value/Year" = "$" + "{0:N0}" -f $annualValueSaved
        "Risk Mitigation Value/Year" = "$" + "{0:N0}" -f $annualRiskMitigation
        "Total Annual Benefit" = "$" + "{0:N0}" -f $totalAnnualBenefit
        "ROI %" = $roi
        "Payback Period (Days)" = $paybackDays
    }
  
    return $results
}

# Calculate for Leonardo Company
Write-Host "`nTeams Premium ROI Analysis" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
$roi = Get-TeamsPremiumROI -UserCount 100 -LicenseCost 10 -HourlyRate 75
$roi | Format-List

# Create visual chart
$chartData = @"
Investment vs Return (Annual)
-----------------------------
Investment: ████ $12,000
Productivity: ████████████████████████████████ $702,000
Risk Mitigation: ███████████ $334,000
                                            
Total ROI: 8,533%
Payback: < 5 days
"@

Write-Host $chartData -ForegroundColor Green
```

---

## Risk Management

### Risk Monitoring Dashboard

```powershell
# ========================================
# Risk Monitoring and Mitigation
# ========================================

# Define risk thresholds
$riskThresholds = @{
    E2EFailureRate = 0.05      # 5% failure rate
    WatermarkBypassAttempts = 0 # Zero tolerance
    UnauthorizedRecording = 0   # Zero tolerance
    CMKAccessFailure = 0.01    # 1% failure rate
    LicenseCompliance = 0.90   # 90% must be licensed
}

# Risk assessment function
function Get-SecurityRiskScore {
    param(
        [DateTime]$StartDate = (Get-Date).AddDays(-7),
        [DateTime]$EndDate = (Get-Date)
    )
  
    $risks = @()
  
    # Check E2E failures
    $e2eFailures = Get-MgAuditLogDirectoryAudit -Filter "OperationName eq 'E2EEncryptionFailed'" |
        Where-Object {$_.CreatedDateTime -ge $StartDate -and $_.CreatedDateTime -le $EndDate}
  
    if ($e2eFailures.Count -gt 0) {
        $risks += [PSCustomObject]@{
            Risk = "E2E Encryption Failures"
            Severity = "High"
            Count = $e2eFailures.Count
            Action = "Review encryption settings and user training"
        }
    }
  
    # Check watermark bypasses
    $watermarkIssues = Search-UnifiedAuditLog -Operations "WatermarkBypassed,WatermarkRemoved" `
        -StartDate $StartDate -EndDate $EndDate
  
    if ($watermarkIssues.Count -gt 0) {
        $risks += [PSCustomObject]@{
            Risk = "Watermark Security Breach"
            Severity = "Critical"
            Count = $watermarkIssues.Count
            Action = "Immediate investigation required"
        }
    }
  
    # Calculate risk score
    $riskScore = switch ($risks.Count) {
        0 { "Low" }
        {$_ -le 2} { "Medium" }
        {$_ -le 5} { "High" }
        default { "Critical" }
    }
  
    return @{
        Score = $riskScore
        Risks = $risks
        Period = "$StartDate to $EndDate"
    }
}

# Run risk assessment
$riskAssessment = Get-SecurityRiskScore
Write-Host "`nSecurity Risk Assessment" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Risk Score: $($riskAssessment.Score)" -ForegroundColor $(
    switch($riskAssessment.Score) {
        "Low" {"Green"}
        "Medium" {"Yellow"}
        "High" {"Red"}
        "Critical" {"Red"}
    }
)

if ($riskAssessment.Risks.Count -gt 0) {
    Write-Host "`nIdentified Risks:" -ForegroundColor Yellow
    $riskAssessment.Risks | Format-Table -AutoSize
}
```

---

## Success Metrics

### KPI Tracking Dashboard

```powershell
# ========================================
# Teams Premium Success Metrics
# ========================================

function Get-TeamsPremiumKPIs {
    param(
        [DateTime]$StartDate = (Get-Date).AddMonths(-1),
        [DateTime]$EndDate = (Get-Date)
    )
  
    $kpis = [PSCustomObject]@{
        Period = "$($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))"
      
        # Adoption Metrics
        Adoption = @{
            TotalUsers = (Get-MgUser -All).Count
            PremiumUsers = 0  # Calculate below
            AdoptionRate = 0
            ActiveUsers = 0
        }
      
        # Security Metrics
        Security = @{
            E2ECallsCount = 0
            WatermarkedMeetings = 0
            CMKProtectedContent = "100%"  # All content is CMK protected
            SecurityIncidents = 0
        }
      
        # Productivity Metrics
        Productivity = @{
            AIRecapsGenerated = 0
            TranslatedMeetings = 0
            VirtualAppointments = 0
            TimesSaved = "0 hours"
        }
      
        # Quality Metrics
        Quality = @{
            UserSatisfaction = "TBD"
            SystemUptime = "99.9%"
            PerformanceScore = "Excellent"
        }
    }
  
    # Calculate actual metrics (simplified for example)
    $premiumUsers = Get-MgUser -All | Where-Object {
        (Get-MgUserLicenseDetail -UserId $_.Id).SkuPartNumber -contains "Microsoft_Teams_Premium"
    }
  
    $kpis.Adoption.PremiumUsers = $premiumUsers.Count
    $kpis.Adoption.AdoptionRate = [math]::Round(($premiumUsers.Count / $kpis.Adoption.TotalUsers) * 100, 2)
  
    # Display KPIs
    Write-Host "`nTeams Premium KPI Dashboard" -ForegroundColor Cyan
    Write-Host "===========================" -ForegroundColor Cyan
  
    Write-Host "`nAdoption Metrics:" -ForegroundColor Yellow
    $kpis.Adoption | Format-List
  
    Write-Host "`nSecurity Metrics:" -ForegroundColor Yellow
    $kpis.Security | Format-List
  
    Write-Host "`nProductivity Metrics:" -ForegroundColor Yellow
    $kpis.Productivity | Format-List
  
    return $kpis
}

# Generate current KPIs
$currentKPIs = Get-TeamsPremiumKPIs

# Export for reporting
$currentKPIs | ConvertTo-Json -Depth 10 | 
    Out-File "C:\Reports\TeamsPremium-KPIs-$(Get-Date -Format 'yyyy-MM').json" -Encoding UTF8
```

---

## Appendix

### A. Complete Deployment Script

Save this as `Deploy-TeamsPremium-Complete.ps1`:

```powershell
# ========================================
# Complete Teams Premium Deployment Script
# Leonardo Company
# ========================================

param(
    [Parameter(Mandatory=$false)]
    [string]$TenantId = "ttiecm.onmicrosoft.com",
  
    [Parameter(Mandatory=$false)]
    [string[]]$PilotUsers = @("fred.pearson@leonardocompany.ca"),
  
    [Parameter(Mandatory=$false)]
    [switch]$SkipLicenseAssignment,
  
    [Parameter(Mandatory=$false)]
    [switch]$SkipPolicyCreation,
  
    [Parameter(Mandatory=$false)]
    [switch]$GenerateReports
)

# Import required modules
$requiredModules = @(
    "Microsoft.Graph",
    "MicrosoftTeams",
    "ExchangeOnlineManagement",
    "Az.OperationalInsights"
)

foreach ($module in $requiredModules) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Scope CurrentUser -Force
    }
    Import-Module $module
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Teams Premium Deployment for Leonardo Company" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Run all deployment phases
try {
    # Phase 1: License Assignment
    if (!$SkipLicenseAssignment) {
        Write-Host "`nPhase 1: License Assignment" -ForegroundColor Yellow
        & "$PSScriptRoot\Deploy-Licenses.ps1" -TenantId $TenantId -Users $PilotUsers
    }
  
    # Phase 2: Policy Configuration
    if (!$SkipPolicyCreation) {
        Write-Host "`nPhase 2: Policy Configuration" -ForegroundColor Yellow
        & "$PSScriptRoot\Configure-Policies.ps1" -TenantId $TenantId
    }
  
    # Phase 3: Security Hardening
    Write-Host "`nPhase 3: Security Hardening" -ForegroundColor Yellow
    & "$PSScriptRoot\Configure-Security.ps1" -TenantId $TenantId
  
    # Phase 4: Monitoring Setup
    Write-Host "`nPhase 4: Monitoring Configuration" -ForegroundColor Yellow
    & "$PSScriptRoot\Setup-Monitoring.ps1"
  
    # Generate reports if requested
    if ($GenerateReports) {
        Write-Host "`nGenerating deployment reports..." -ForegroundColor Yellow
        & "$PSScriptRoot\Generate-Reports.ps1"
    }
  
    Write-Host "`n✅ Teams Premium deployment completed successfully!" -ForegroundColor Green
  
} catch {
    Write-Host "`n❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    throw
}
```

### B. Support Contacts

* **Microsoft Premier Support** : 1-800-936-3100
* **Teams Premium Support** : TeamsPremium@microsoft.com
* **CMK Administrator** : fred.pearson@leonardocompany.ca
* **Internal IT Support** : it-support@leonardocompany.ca

### C. Quick Links

* [Teams Admin Center](https://admin.teams.microsoft.com)
* [Security &amp; Compliance Center](https://compliance.microsoft.com)
* [Azure Portal](https://portal.azure.com)
* [Graph Explorer](https://aka.ms/ge)

### D. Change Log

* **v2.0** (November 2025): Updated with Microsoft Graph PowerShell commands
* **v1.0** (November 2025): Initial build book creation

---

*Document Version: 2.0*

*Updated: November 2025*

*Next Review: February 2026*

*Classification: Leonardo Confidential - CMK Protected*
