<#
.SYNOPSIS
    CMK (Customer Managed Keys) Compliance Runbook with Email Notification
.DESCRIPTION
    Comprehensive CMK compliance check across ALL M365 services:
    - Exchange Online (Email, Calendar)
    - Microsoft Teams (Chat, Meetings, Voicemail)
    - SharePoint Online (Sites, Lists, Libraries)
    - OneDrive for Business (Personal storage)
    - Teams Files (Stored in SharePoint)
    
    Exchange/Teams: Per-user DEP via Set-Mailbox
    SharePoint/OneDrive: Tenant-wide DEP via Register-SPODataEncryptionPolicy
    
    Ingests data to Log Analytics and sends a compliance report email.
.REQUIREMENTS
    - Azure Automation Account with System-Assigned Managed Identity
    - PowerShell 7.2 Runtime
    - Az.Accounts module imported
    - ExchangeOnlineManagement module imported (v3.4.0+)
    - Managed Identity requires:
      * Microsoft Graph: User.Read.All (Application permission)
      * Microsoft Graph: Mail.Send (Application permission)
      * Exchange Online: Exchange.ManageAsApp (Application permission)
      * Exchange Administrator role assignment
      * Azure RBAC: Monitoring Metrics Publisher on the DCR
    
    Note: SharePoint CMK status is configured manually in the runbook
    based on your Register-SPODataEncryptionPolicy settings.
.NOTES
    Author: LCE M365 Security Team
    Version: 2.0
    Runtime: PowerShell 7.2
    
    CHANGE LOG:
    v2.0 - Added SharePoint/OneDrive CMK status checking
    v1.0 - Initial CMK compliance tracking (Exchange only)
#>

# ============================================
# CONFIGURATION
# ============================================

# Data Collection Configuration
$DceUri = "https://dce-teamspremiumlicenses-4q1m.canadaeast-1.ingest.monitor.azure.com"
$DcrImmutableId = "dcr-80aee557ba12478a9dff76584b61ec38"
$StreamName = "Custom-CMKCompliance_CL"

# CMK Configuration - Exchange/Teams DEP
$ExchangeDEPName = "Leonardo-CMK-DEP"

# CMK Configuration - SharePoint/OneDrive (MANUAL CONFIGURATION)
# Update these values based on your SPO CMK registration status
# Run Get-SPODataEncryptionPolicy locally to verify current state
$SharePointCMKConfig = @{
    IsRegistered  = $true  # Set to $false if SPO CMK is not yet registered
    PrimaryKey    = "https://kv-cmk-spo-pri-1117.vault.azure.net/keys/spo-cmk-key"
    SecondaryKey  = "https://kv-cmk-spo-sec-1117.vault.azure.net/keys/spo-cmk-key"
}

# Email Configuration
$SendEmail = $true
$EmailFrom = "m365reports@leonardocompany.ca"
$EmailTo = "Compliance-Administrators@leonardocompany.ca"
$EmailSubject = "M365 CMK Encryption Compliance Report"

# ============================================
# INITIALIZATION
# ============================================

Write-Output "========================================================================"
Write-Output "     M365 CMK ENCRYPTION COMPLIANCE SYNC"
Write-Output "========================================================================"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Output ""
Write-Output "Services Checked:"
Write-Output "  - Exchange Online (Email, Calendar)"
Write-Output "  - Microsoft Teams (Chat, Meetings, Voicemail)"
Write-Output "  - SharePoint Online (Sites, Libraries)"
Write-Output "  - OneDrive for Business"
Write-Output "  - Teams Files (via SharePoint)"
Write-Output ""
Write-Output "DEP Configuration:"
Write-Output "  - Exchange/Teams DEP: $ExchangeDEPName"
Write-Output "  - SharePoint CMK Registered: $($SharePointCMKConfig.IsRegistered)"
Write-Output ""

# ============================================
# AUTHENTICATION
# ============================================

Write-Output "Step 1: Authenticating with Managed Identity..."

try {
    $azConnect = Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "  [OK] Connected as: $($azConnect.Context.Account.Id)"
}
catch {
    Write-Error "Failed to authenticate to Azure: $_"
    throw
}

Write-Output ""
Write-Output "Step 2: Acquiring API tokens..."

try {
    $graphToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com" -ErrorAction Stop).Token
    $monitorToken = (Get-AzAccessToken -ResourceUrl "https://monitor.azure.com" -ErrorAction Stop).Token
    Write-Output "  [OK] Graph and Monitor tokens acquired"
}
catch {
    Write-Error "Failed to acquire tokens: $_"
    throw
}

# ============================================
# CHECK SHAREPOINT/ONEDRIVE CMK STATUS (TENANT-WIDE)
# ============================================

Write-Output ""
Write-Output "Step 3: Checking SharePoint/OneDrive CMK status..."

$spoStatus = @{
    Checked = $true
    Enabled = $SharePointCMKConfig.IsRegistered
    PrimaryKeyUri = $SharePointCMKConfig.PrimaryKey
    SecondaryKeyUri = $SharePointCMKConfig.SecondaryKey
    State = if ($SharePointCMKConfig.IsRegistered) { "Registered" } else { "Not Registered" }
    ErrorMessage = $null
}

if ($spoStatus.Enabled) {
    Write-Output "  [OK] SharePoint CMK Status: $($spoStatus.State)"
    Write-Output "       Primary Key: $($spoStatus.PrimaryKeyUri)"
    Write-Output "       Secondary Key: $($spoStatus.SecondaryKeyUri)"
    Write-Output "       (From runbook configuration - verify with Get-SPODataEncryptionPolicy)"
}
else {
    Write-Output "  [WARN] SharePoint CMK: Not Registered"
    Write-Output "       Update SharePointCMKConfig.IsRegistered = `$true after running Register-SPODataEncryptionPolicy"
}

# ============================================
# CONNECT TO EXCHANGE ONLINE
# ============================================

Write-Output ""
Write-Output "Step 4: Connecting to Exchange Online..."

try {
    # Import the module explicitly first
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    Write-Output "  [OK] ExchangeOnlineManagement module loaded"
    
    # Connect using Managed Identity
    Connect-ExchangeOnline -ManagedIdentity -Organization "leonardocompany.ca" -ShowBanner:$false -ErrorAction Stop
    Write-Output "  [OK] Connected to Exchange Online via Managed Identity"
}
catch {
    # Try alternative connection method with access token
    Write-Output "  [INFO] Managed Identity failed, trying access token method..."
    try {
        $exchangeTokenResponse = Get-AzAccessToken -ResourceUrl "https://outlook.office365.com" -ErrorAction Stop
        Connect-ExchangeOnline -AccessToken $exchangeTokenResponse.Token -Organization "leonardocompany.ca" -ShowBanner:$false -ErrorAction Stop
        Write-Output "  [OK] Connected to Exchange Online via Access Token"
    }
    catch {
        Write-Error "Failed to connect to Exchange Online: $_"
        throw
    }
}

# ============================================
# QUERY ALL MAILBOXES FOR EXCHANGE/TEAMS CMK STATUS
# ============================================

Write-Output ""
Write-Output "Step 5: Querying mailboxes for Exchange/Teams CMK status..."

$allMailboxes = [System.Collections.Generic.List[object]]::new()

try {
    # Get all user mailboxes
    $mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox -ErrorAction Stop
    
    foreach ($mailbox in $mailboxes) {
        $allMailboxes.Add($mailbox)
    }
    
    Write-Output "  [OK] Total user mailboxes: $($allMailboxes.Count)"
}
catch {
    Write-Error "Failed to query mailboxes: $_"
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    throw
}

# ============================================
# ANALYZE EXCHANGE/TEAMS CMK STATUS
# ============================================

Write-Output ""
Write-Output "Step 6: Analyzing Exchange/Teams CMK encryption status..."

$currentTime = (Get-Date).ToUniversalTime().ToString("o")
$totalUsers = $allMailboxes.Count

# Categorize users
$cmkEnabledUsers = [System.Collections.Generic.List[object]]::new()
$cmkDisabledUsers = [System.Collections.Generic.List[object]]::new()

foreach ($mailbox in $allMailboxes) {
    $hasCMK = $mailbox.DataEncryptionPolicy -eq $ExchangeDEPName
    
    if ($hasCMK) {
        $cmkEnabledUsers.Add($mailbox)
    }
    else {
        $cmkDisabledUsers.Add($mailbox)
    }
}

# Calculate statistics
$cmkEnabledCount = $cmkEnabledUsers.Count
$cmkDisabledCount = $cmkDisabledUsers.Count
$exchangeCompliancePercent = if ($totalUsers -gt 0) { [math]::Round(($cmkEnabledCount / $totalUsers) * 100, 1) } else { 0 }

# Display results
Write-Output ""
Write-Output "  ========================================================================"
Write-Output "                    CMK COMPLIANCE SUMMARY"
Write-Output "  ========================================================================"
Write-Output ""
Write-Output "  SHAREPOINT/ONEDRIVE (Tenant-Wide):"
Write-Output "    Status:           $(if($spoStatus.Enabled){'[OK] Enabled'}else{'[NOT ENABLED]'})"
Write-Output "    State:            $($spoStatus.State)"
if ($spoStatus.Enabled) {
    Write-Output "    Primary Key:      $($spoStatus.PrimaryKeyUri)"
    Write-Output "    Secondary Key:    $($spoStatus.SecondaryKeyUri)"
}
Write-Output ""
Write-Output "  EXCHANGE/TEAMS (Per-User):"
Write-Output "    Total Mailboxes:  $totalUsers"
Write-Output "    CMK Enabled:      $cmkEnabledCount ($exchangeCompliancePercent%)"
Write-Output "    CMK Not Enabled:  $cmkDisabledCount"
Write-Output "    DEP Policy:       $ExchangeDEPName"
Write-Output ""
Write-Output "  ========================================================================"

# Show sample of users without CMK
if ($cmkDisabledCount -gt 0) {
    Write-Output ""
    Write-Output "  Sample users without CMK (first 10):"
    $cmkDisabledUsers | Select-Object -First 10 | ForEach-Object {
        Write-Output "    - $($_.DisplayName) ($($_.PrimarySmtpAddress))"
    }
}

# ============================================
# BUILD LOG DATA FOR LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 7: Building log data..."

$logData = [System.Collections.Generic.List[hashtable]]::new()

foreach ($mailbox in $allMailboxes) {
    $hasCMK = $mailbox.DataEncryptionPolicy -eq $ExchangeDEPName
    $currentDEP = if ($mailbox.DataEncryptionPolicy) { $mailbox.DataEncryptionPolicy } else { "None" }
    
    $logData.Add(@{
        TimeGenerated            = $currentTime
        UserPrincipalName        = $mailbox.UserPrincipalName
        DisplayName              = $mailbox.DisplayName
        PrimarySmtpAddress       = $mailbox.PrimarySmtpAddress
        ExchangeTeamsCMK         = $hasCMK
        DataEncryptionPolicy     = $currentDEP
        SharePointOneDriveCMK    = $spoStatus.Enabled
        SharePointCMKState       = $spoStatus.State
        RecipientType            = $mailbox.RecipientTypeDetails
        WhenCreated              = $mailbox.WhenCreated.ToString("o")
    })
}

Write-Output "  [OK] Log data prepared: $($logData.Count) records"

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 8: Ingesting data to Log Analytics..."

$ingestUri = "$DceUri/dataCollectionRules/$DcrImmutableId/streams/$StreamName`?api-version=2023-01-01"

$ingestHeaders = @{
    "Authorization" = "Bearer $monitorToken"
    "Content-Type"  = "application/json"
}

$batchSize = 500
$totalBatches = [math]::Ceiling($logData.Count / $batchSize)
$successCount = 0
$failCount = 0

for ($i = 0; $i -lt $logData.Count; $i += $batchSize) {
    $batchNumber = [math]::Floor($i / $batchSize) + 1
    $endIndex = [math]::Min($i + $batchSize - 1, $logData.Count - 1)
    $batch = $logData[$i..$endIndex]
    
    $batchBody = ConvertTo-Json -InputObject @($batch) -Depth 10 -Compress
    
    try {
        $null = Invoke-RestMethod -Uri $ingestUri -Headers $ingestHeaders -Method Post -Body $batchBody -ErrorAction Stop
        $successCount += $batch.Count
        Write-Output "  [OK] Batch $batchNumber/$totalBatches : $($batch.Count) records ingested"
    }
    catch {
        $failCount += $batch.Count
        Write-Warning "  [FAIL] Batch $batchNumber/$totalBatches : $_"
    }
    
    if ($batchNumber -lt $totalBatches) {
        Start-Sleep -Milliseconds 500
    }
}

# ============================================
# SEND EMAIL NOTIFICATION
# ============================================

if ($SendEmail) {
    Write-Output ""
    Write-Output "Step 9: Sending email notification..."
    Write-Output "  From: $EmailFrom"
    Write-Output "  To:   $EmailTo"
    
    # Calculate overall compliance (both services must be enabled)
    $overallCompliant = $spoStatus.Enabled -and ($exchangeCompliancePercent -ge 90)
    
    # Determine status color/label based on overall compliance
    $statusColor = if ($overallCompliant) { "#28a745" } 
                   elseif ($spoStatus.Enabled -or $exchangeCompliancePercent -ge 50) { "#ffc107" } 
                   else { "#dc3545" }
    
    $statusLabel = if ($overallCompliant) { "[OK]" } 
                   elseif ($spoStatus.Enabled -or $exchangeCompliancePercent -ge 50) { "[ACTION NEEDED]" } 
                   else { "[CRITICAL]" }
    
    $statusText = if ($overallCompliant) { "Fully Protected" } 
                  elseif ($spoStatus.Enabled -or $exchangeCompliancePercent -ge 50) { "Partially Protected" } 
                  else { "Critical - Action Required" }
    
    # Build non-compliant users table (first 25)
    $nonCompliantTableRows = ""
    $cmkDisabledUsers | Sort-Object { $_.DisplayName } | Select-Object -First 25 | ForEach-Object {
        $currentDEP = if ($_.DataEncryptionPolicy) { $_.DataEncryptionPolicy } else { "None" }
        $nonCompliantTableRows += "<tr><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.DisplayName)</td><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.PrimarySmtpAddress)</td><td style='padding: 8px; border-bottom: 1px solid #ddd; color: #dc3545;'>$currentDEP</td></tr>"
    }
    
    $moreUsersNote = ""
    if ($cmkDisabledCount -gt 25) {
        $moreUsersNote = "<p style='color: #666; font-style: italic;'>... and $($cmkDisabledCount - 25) more users need Exchange/Teams CMK. Query Log Analytics for the full list.</p>"
    }
    
    # SharePoint status display
    $spoStatusColor = if ($spoStatus.Enabled) { "#28a745" } else { "#dc3545" }
    $spoStatusIcon = if ($spoStatus.Enabled) { "[OK]" } else { "[NOT ENABLED]" }
    $exchangeStatusColor = if ($exchangeCompliancePercent -ge 90) { "#28a745" } elseif ($exchangeCompliancePercent -ge 50) { "#ffc107" } else { "#dc3545" }
    
    # Build HTML email body
    $emailBody = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { background-color: #0078d4; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
        .header h1 { margin: 0; font-size: 24px; }
        .content { padding: 20px; }
        .service-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin: 20px 0; }
        .service-box { border-radius: 8px; padding: 20px; text-align: center; }
        .service-title { font-size: 14px; font-weight: bold; margin-bottom: 10px; }
        .service-status { font-size: 24px; font-weight: bold; }
        .service-detail { font-size: 12px; color: #666; margin-top: 5px; }
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin: 20px 0; }
        .stat-box { background-color: #f8f9fa; border-radius: 8px; padding: 15px; text-align: center; }
        .stat-number { font-size: 28px; font-weight: bold; color: #333; }
        .stat-label { color: #666; font-size: 12px; margin-top: 5px; }
        .compliance-box { background-color: $statusColor; color: white; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
        .compliance-status { font-size: 32px; font-weight: bold; }
        .table-container { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f8f9fa; padding: 12px 8px; text-align: left; border-bottom: 2px solid #ddd; }
        .footer { background-color: #f8f9fa; padding: 15px 20px; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
        .action-required { background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .full-compliance { background-color: #d4edda; border: 1px solid #28a745; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .info-box { background-color: #e7f3ff; border: 1px solid #0078d4; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .key-info { font-family: Consolas, monospace; font-size: 11px; word-break: break-all; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$statusLabel M365 CMK Encryption Compliance Report</h1>
            <p style="margin: 5px 0 0 0; opacity: 0.9;">Generated: $(Get-Date -Format 'MMMM dd, yyyy') at $(Get-Date -Format 'HH:mm') UTC</p>
        </div>
        
        <div class="content">
            <div class="compliance-box">
                <div class="compliance-status">$statusText</div>
                <div>Customer Managed Keys Encryption Status</div>
            </div>
            
            <h3>Service Coverage</h3>
            <div class="service-grid">
                <div class="service-box" style="background-color: $(if($spoStatus.Enabled){'#d4edda'}else{'#f8d7da'}); border: 2px solid $spoStatusColor;">
                    <div class="service-title">SharePoint / OneDrive / Teams Files</div>
                    <div class="service-status" style="color: $spoStatusColor;">$spoStatusIcon</div>
                    <div class="service-detail">Tenant-wide encryption</div>
                    <div class="service-detail">State: $($spoStatus.State)</div>
                </div>
                <div class="service-box" style="background-color: $(if($exchangeCompliancePercent -ge 90){'#d4edda'}elseif($exchangeCompliancePercent -ge 50){'#fff3cd'}else{'#f8d7da'}); border: 2px solid $exchangeStatusColor;">
                    <div class="service-title">Exchange / Teams Chat / Meetings</div>
                    <div class="service-status" style="color: $exchangeStatusColor;">$exchangeCompliancePercent%</div>
                    <div class="service-detail">Per-user DEP policy</div>
                    <div class="service-detail">$cmkEnabledCount of $totalUsers users</div>
                </div>
            </div>
            
            <div class="info-box">
                <strong>What CMK Protects:</strong>
                <table style="width: 100%; margin-top: 10px; font-size: 13px;">
                    <tr>
                        <td style="padding: 5px;"><strong>SharePoint DEP:</strong></td>
                        <td style="padding: 5px;">SharePoint sites, OneDrive files, Teams file storage, Lists & Libraries</td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;"><strong>Exchange DEP:</strong></td>
                        <td style="padding: 5px;">Email, Calendar, Teams chat messages, Teams meetings, Voicemail</td>
                    </tr>
                </table>
            </div>
            
            $(if ($spoStatus.Enabled) {
@"

            <h3>SharePoint/OneDrive Key Configuration</h3>
            <table style="width: 100%; margin-bottom: 20px;">
                <tr>
                    <td style="padding: 8px; background: #f8f9fa; width: 120px;"><strong>Primary Key:</strong></td>
                    <td style="padding: 8px;" class="key-info">$($spoStatus.PrimaryKeyUri)</td>
                </tr>
                <tr>
                    <td style="padding: 8px; background: #f8f9fa;"><strong>Secondary Key:</strong></td>
                    <td style="padding: 8px;" class="key-info">$($spoStatus.SecondaryKeyUri)</td>
                </tr>
            </table>
"@
            } else {
@"

            <div class="action-required">
                <strong>SharePoint/OneDrive CMK Not Enabled!</strong><br>
                Run <code>Register-SPODataEncryptionPolicy</code> to enable tenant-wide encryption for SharePoint, OneDrive, and Teams files.
            </div>
"@
            })
            
            <h3>Exchange/Teams CMK Status</h3>
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number">$totalUsers</div>
                    <div class="stat-label">Total Mailboxes</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #28a745;">$cmkEnabledCount</div>
                    <div class="stat-label">CMK Enabled</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #dc3545;">$cmkDisabledCount</div>
                    <div class="stat-label">CMK Not Enabled</div>
                </div>
            </div>
            
            $(if ($cmkDisabledCount -gt 0) {
@"

            <div class="action-required">
                <strong>ACTION REQUIRED:</strong> $cmkDisabledCount users do not have Exchange/Teams CMK encryption enabled.
            </div>
            
            <div class="table-container">
                <h3>Users Without Exchange/Teams CMK</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                            <th>Current DEP</th>
                        </tr>
                    </thead>
                    <tbody>
                        $nonCompliantTableRows
                    </tbody>
                </table>
                $moreUsersNote
            </div>
            
            <h3>How to Enable Exchange/Teams CMK</h3>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">Set-Mailbox -Identity "user@leonardocompany.ca" -DataEncryptionPolicy "$ExchangeDEPName"</pre>
"@
            } else {
@"

            <div class="full-compliance">
                <strong>Exchange/Teams CMK Complete!</strong> All $totalUsers mailboxes have CMK encryption enabled.
            </div>
"@
            })
            
            <h3>Log Analytics Queries</h3>
            
            <p><strong>Users without Exchange/Teams CMK:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where ExchangeTeamsCMK == false
| distinct UserPrincipalName, DisplayName, DataEncryptionPolicy</pre>
            
            <p><strong>CMK compliance by service:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">CMKCompliance_CL
| where TimeGenerated > ago(1d)
| summarize 
    ExchangeTeamsEnabled = dcountif(UserPrincipalName, ExchangeTeamsCMK == true),
    ExchangeTeamsDisabled = dcountif(UserPrincipalName, ExchangeTeamsCMK == false),
    SharePointEnabled = max(SharePointOneDriveCMK)
| extend ExchangeTeamsPercent = round(100.0 * ExchangeTeamsEnabled / (ExchangeTeamsEnabled + ExchangeTeamsDisabled), 1)</pre>
        </div>
        
        <div class="footer">
            <p><strong>Leonardo Company</strong> - LCE M365 Security Team</p>
            <p>This is an automated daily report from Azure Automation. Data is synced at midnight EST.</p>
            <p style="margin-top: 10px; color: #999;">Automation Account: AA-TeamsPremiumLicenseSync | Runbook: Sync-CMKCompliance</p>
        </div>
    </div>
</body>
</html>
"@

    # Build email message
    $emailMessage = @{
        message = @{
            subject = "$statusLabel $EmailSubject - SPO: $($spoStatus.State), Exchange: $exchangeCompliancePercent%"
            body = @{
                contentType = "HTML"
                content = $emailBody
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = $EmailTo
                    }
                }
            )
        }
        saveToSentItems = $false
    }
    
    $emailJson = $emailMessage | ConvertTo-Json -Depth 10
    
    # Send email via Microsoft Graph
    $graphHeaders = @{
        "Authorization" = "Bearer $graphToken"
        "Content-Type"  = "application/json"
    }
    
    try {
        $sendMailUri = "https://graph.microsoft.com/v1.0/users/$EmailFrom/sendMail"
        
        $null = Invoke-RestMethod `
            -Uri $sendMailUri `
            -Headers $graphHeaders `
            -Method Post `
            -Body $emailJson `
            -ContentType "application/json" `
            -ErrorAction Stop
        
        Write-Output "  [OK] Email sent successfully!"
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Warning "  [FAIL] Failed to send email: $errorMsg"
    }
}
else {
    Write-Output ""
    Write-Output "Step 9: Email notifications disabled - skipping"
}

# ============================================
# DISCONNECT FROM EXCHANGE ONLINE
# ============================================

Write-Output ""
Write-Output "Step 10: Disconnecting from Exchange Online..."
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
Write-Output "  [OK] Disconnected"

# ============================================
# FINAL SUMMARY
# ============================================

Write-Output ""
Write-Output "========================================================================"
Write-Output "                         SYNC COMPLETED"
Write-Output "========================================================================"
Write-Output ""
Write-Output "  SHAREPOINT / ONEDRIVE / TEAMS FILES:"
Write-Output "    CMK Enabled:          $(if($spoStatus.Enabled){'Yes'}else{'No'})"
Write-Output "    State:                $($spoStatus.State)"
Write-Output ""
Write-Output "  EXCHANGE / TEAMS CHAT / MEETINGS:"
Write-Output "    Total Mailboxes:      $totalUsers"
Write-Output "    CMK Enabled:          $cmkEnabledCount ($exchangeCompliancePercent%)"
Write-Output "    CMK Not Enabled:      $cmkDisabledCount"
Write-Output "    DEP Policy:           $ExchangeDEPName"
Write-Output ""
Write-Output "  Records Ingested:       $successCount"
Write-Output "  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "========================================================================"

if (-not $spoStatus.Enabled) {
    Write-Output ""
    Write-Output "ACTION REQUIRED: SharePoint/OneDrive CMK is not enabled!"
    Write-Output "  Run: Register-SPODataEncryptionPolicy to enable tenant-wide encryption"
}

if ($cmkDisabledCount -gt 0) {
    Write-Output ""
    Write-Output "ACTION REQUIRED: $cmkDisabledCount users need Exchange/Teams CMK enabled"
    Write-Output "  Run: Set-Mailbox -Identity <user> -DataEncryptionPolicy '$ExchangeDEPName'"
}