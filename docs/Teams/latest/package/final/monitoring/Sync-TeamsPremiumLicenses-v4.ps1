<#
.SYNOPSIS
    M365 Security License Compliance Runbook with Email Notification
.DESCRIPTION
    Queries Microsoft Graph for ALL users and their security license status.
    Tracks multiple licenses: Teams Premium, Defender/Purview, etc.
    Ingests data to Log Analytics and sends a compliance report email.
    
    Goal: Ensure all employees have required security licenses.
.REQUIREMENTS
    - Azure Automation Account with System-Assigned Managed Identity
    - PowerShell 7.2 Runtime
    - Az.Accounts module imported
    - Managed Identity requires:
      * Microsoft Graph: User.Read.All (Application permission)
      * Microsoft Graph: Mail.Send (Application permission)
      * Azure RBAC: Monitoring Metrics Publisher on the DCR
.NOTES
    Author: LCE M365 Security Team
    Version: 4.0
    Runtime: PowerShell 7.2
    
    CHANGE LOG:
    v4.0 - Multi-license tracking (Teams Premium + Defender/Purview)
    v3.0 - Added email notification
    v2.0 - Tracks ALL users for compliance reporting
    v1.0 - Initial release
#>

# ============================================
# CONFIGURATION
# ============================================

# Data Collection Configuration
$DceUri = "https://dce-teamspremiumlicenses-4q1m.canadaeast-1.ingest.monitor.azure.com"
$DcrImmutableId = "dcr-80aee557ba12478a9dff76584b61ec38"
$StreamName = "Custom-TeamsPremiumLicenses_CL"

# License Configuration - Add/modify licenses to track here
$LicensesToTrack = @(
    @{
        Name  = "Teams Premium"
        SkuId = "36a0f3b3-adb5-49ea-bf66-762134cf063a"
        Short = "TeamsPremium"
    },
    @{
        Name  = "Defender & Purview (Business Premium)"
        SkuId = "28278257-fb5e-468e-90e5-02867681527a"
        Short = "DefenderPurview"
    }
)

# Email Configuration
$SendEmail = $true
$EmailFrom = "m365reports@leonardocompany.ca"
$EmailTo = "Compliance-Administrators@leonardocompany.ca"
$EmailSubject = "M365 Secure Users Compliance Report"

# ============================================
# INITIALIZATION
# ============================================

Write-Output "========================================================================"
Write-Output "     M365 SECURE USERS COMPLIANCE SYNC"
Write-Output "========================================================================"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Output "Licenses Tracked: $($LicensesToTrack.Count)"
$LicensesToTrack | ForEach-Object { Write-Output "  - $($_.Name)" }
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
    Write-Error "Failed to authenticate: $_"
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
# QUERY ALL USERS FROM MICROSOFT GRAPH
# ============================================

Write-Output ""
Write-Output "Step 3: Querying Microsoft Graph for all users..."

$graphHeaders = @{
    "Authorization"    = "Bearer $graphToken"
    "Content-Type"     = "application/json"
    "ConsistencyLevel" = "eventual"
}

$allUsers = [System.Collections.Generic.List[object]]::new()
$uri = "https://graph.microsoft.com/v1.0/users?`$select=id,userPrincipalName,displayName,assignedLicenses,accountEnabled,userType&`$filter=userType eq 'Member'&`$top=999"
$pageCount = 0

try {
    do {
        $pageCount++
        $response = Invoke-RestMethod -Uri $uri -Headers $graphHeaders -Method Get -ErrorAction Stop
        
        foreach ($user in $response.value) {
            if ($user.accountEnabled -eq $true) {
                $allUsers.Add($user)
            }
        }
        
        $uri = $response.'@odata.nextLink'
        
        if ($pageCount % 5 -eq 0) {
            Write-Output "  Retrieved $($allUsers.Count) enabled users (page $pageCount)..."
        }
    } while ($uri)
    
    Write-Output "  [OK] Total enabled Member users: $($allUsers.Count)"
}
catch {
    Write-Error "Failed to query Microsoft Graph: $_"
    throw
}

# ============================================
# ANALYZE LICENSE STATUS
# ============================================

Write-Output ""
Write-Output "Step 4: Analyzing license assignments..."

$currentTime = (Get-Date).ToUniversalTime().ToString("o")
$totalUsers = $allUsers.Count

# Initialize results storage
$licenseResults = @{}
foreach ($license in $LicensesToTrack) {
    $licenseResults[$license.Short] = @{
        Name           = $license.Name
        SkuId          = $license.SkuId
        LicensedUsers  = [System.Collections.Generic.List[object]]::new()
        UnlicensedUsers = [System.Collections.Generic.List[object]]::new()
    }
}

# Track users missing ALL required licenses (for "fully compliant" metric)
$fullyCompliantUsers = [System.Collections.Generic.List[object]]::new()
$partiallyCompliantUsers = [System.Collections.Generic.List[object]]::new()
$nonCompliantUsers = [System.Collections.Generic.List[object]]::new()

# Analyze each user
foreach ($user in $allUsers) {
    $userLicenses = $user.assignedLicenses.skuId
    $licensesHeld = 0
    
    foreach ($license in $LicensesToTrack) {
        $hasLicense = $userLicenses -contains $license.SkuId
        
        if ($hasLicense) {
            $licenseResults[$license.Short].LicensedUsers.Add($user)
            $licensesHeld++
        }
        else {
            $licenseResults[$license.Short].UnlicensedUsers.Add($user)
        }
    }
    
    # Categorize user compliance
    if ($licensesHeld -eq $LicensesToTrack.Count) {
        $fullyCompliantUsers.Add($user)
    }
    elseif ($licensesHeld -gt 0) {
        $partiallyCompliantUsers.Add($user)
    }
    else {
        $nonCompliantUsers.Add($user)
    }
}

# Calculate statistics
$fullyCompliantCount = $fullyCompliantUsers.Count
$partialCount = $partiallyCompliantUsers.Count
$nonCompliantCount = $nonCompliantUsers.Count
$overallCompliancePercent = if ($totalUsers -gt 0) { [math]::Round(($fullyCompliantCount / $totalUsers) * 100, 1) } else { 0 }

# Display results
Write-Output ""
Write-Output "  ========================================================================"
Write-Output "                    LICENSE COMPLIANCE SUMMARY"
Write-Output "  ========================================================================"
Write-Output ""
Write-Output "  Total Enabled Users: $totalUsers"
Write-Output ""
Write-Output "  OVERALL COMPLIANCE:"
Write-Output "    Fully Compliant (all licenses):    $fullyCompliantCount ($overallCompliancePercent%)"
Write-Output "    Partially Compliant:               $partialCount"
Write-Output "    Non-Compliant (no licenses):       $nonCompliantCount"
Write-Output ""
Write-Output "  PER-LICENSE BREAKDOWN:"

foreach ($license in $LicensesToTrack) {
    $result = $licenseResults[$license.Short]
    $licensedCount = $result.LicensedUsers.Count
    $unlicensedCount = $result.UnlicensedUsers.Count
    $pct = if ($totalUsers -gt 0) { [math]::Round(($licensedCount / $totalUsers) * 100, 1) } else { 0 }
    
    Write-Output "    $($license.Name):"
    Write-Output "      Licensed:   $licensedCount ($pct%)"
    Write-Output "      Unlicensed: $unlicensedCount"
    Write-Output ""
}

Write-Output "  ========================================================================"

# ============================================
# BUILD LOG DATA FOR LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 5: Building log data..."

$logData = [System.Collections.Generic.List[hashtable]]::new()

foreach ($user in $allUsers) {
    $userLicenses = $user.assignedLicenses.skuId
    
    # Check each tracked license
    $hasTeamsPremium = $userLicenses -contains $LicensesToTrack[0].SkuId
    $hasDefenderPurview = $userLicenses -contains $LicensesToTrack[1].SkuId
    
    $logData.Add(@{
        TimeGenerated     = $currentTime
        UserPrincipalName = $user.userPrincipalName
        DisplayName       = $user.displayName
        LicenseAssigned   = $hasTeamsPremium  # Keep for backward compatibility
        TeamsPremium      = $hasTeamsPremium
        DefenderPurview   = $hasDefenderPurview
        FullyCompliant    = ($hasTeamsPremium -and $hasDefenderPurview)
        ObjectId          = $user.id
    })
}

Write-Output "  [OK] Log data prepared: $($logData.Count) records"

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 6: Ingesting data to Log Analytics..."

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
    Write-Output "Step 7: Sending email notification..."
    Write-Output "  From: $EmailFrom"
    Write-Output "  To:   $EmailTo"
    
    # Determine status color/label
    $statusColor = if ($overallCompliancePercent -ge 90) { "#28a745" } 
                   elseif ($overallCompliancePercent -ge 50) { "#ffc107" } 
                   else { "#dc3545" }
    
    $statusLabel = if ($overallCompliancePercent -ge 90) { "[OK]" } 
                   elseif ($overallCompliancePercent -ge 50) { "[ACTION NEEDED]" } 
                   else { "[CRITICAL]" }
    
    $statusText = if ($overallCompliancePercent -ge 90) { "Excellent" } 
                  elseif ($overallCompliancePercent -ge 50) { "Needs Attention" } 
                  else { "Critical" }
    
    # Build per-license HTML sections
    $licenseTableRows = ""
    foreach ($license in $LicensesToTrack) {
        $result = $licenseResults[$license.Short]
        $licensedCount = $result.LicensedUsers.Count
        $unlicensedCount = $result.UnlicensedUsers.Count
        $pct = if ($totalUsers -gt 0) { [math]::Round(($licensedCount / $totalUsers) * 100, 1) } else { 0 }
        
        $rowColor = if ($pct -ge 90) { "#28a745" } elseif ($pct -ge 50) { "#ffc107" } else { "#dc3545" }
        
        $licenseTableRows += @"
        <tr>
            <td style='padding: 12px; border-bottom: 1px solid #ddd;'><strong>$($license.Name)</strong></td>
            <td style='padding: 12px; border-bottom: 1px solid #ddd; text-align: center; color: #28a745;'>$licensedCount</td>
            <td style='padding: 12px; border-bottom: 1px solid #ddd; text-align: center; color: #dc3545;'>$unlicensedCount</td>
            <td style='padding: 12px; border-bottom: 1px solid #ddd; text-align: center;'><span style='color: $rowColor; font-weight: bold;'>$pct%</span></td>
        </tr>
"@
    }
    
    # Build non-compliant users table (users missing ANY license - first 25)
    $nonCompliantTableRows = ""
    $usersNeedingLicenses = $allUsers | Where-Object {
        $userLicenses = $_.assignedLicenses.skuId
        $missingAny = $false
        foreach ($license in $LicensesToTrack) {
            if ($userLicenses -notcontains $license.SkuId) {
                $missingAny = $true
                break
            }
        }
        $missingAny
    } | Sort-Object { $_.displayName }
    
    $totalNeedingLicenses = $usersNeedingLicenses.Count
    
    $usersNeedingLicenses | Select-Object -First 25 | ForEach-Object {
        $userLicenses = $_.assignedLicenses.skuId
        $missingList = @()
        foreach ($license in $LicensesToTrack) {
            if ($userLicenses -notcontains $license.SkuId) {
                $missingList += $license.Name
            }
        }
        $missingStr = $missingList -join ", "
        
        $nonCompliantTableRows += "<tr><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.displayName)</td><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.userPrincipalName)</td><td style='padding: 8px; border-bottom: 1px solid #ddd; color: #dc3545;'>$missingStr</td></tr>"
    }
    
    $moreUsersNote = ""
    if ($totalNeedingLicenses -gt 25) {
        $moreUsersNote = "<p style='color: #666; font-style: italic;'>... and $($totalNeedingLicenses - 25) more users need licenses. Query Log Analytics for the full list.</p>"
    }
    
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
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin: 20px 0; }
        .stat-box { background-color: #f8f9fa; border-radius: 8px; padding: 15px; text-align: center; }
        .stat-number { font-size: 28px; font-weight: bold; color: #333; }
        .stat-label { color: #666; font-size: 12px; margin-top: 5px; }
        .compliance-box { background-color: $statusColor; color: white; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
        .compliance-percent { font-size: 48px; font-weight: bold; }
        .table-container { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f8f9fa; padding: 12px 8px; text-align: left; border-bottom: 2px solid #ddd; }
        .footer { background-color: #f8f9fa; padding: 15px 20px; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
        .action-required { background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .full-compliance { background-color: #d4edda; border: 1px solid #28a745; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .license-table th { text-align: center; }
        .license-table th:first-child { text-align: left; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$statusLabel M365 Secure Users Compliance Report</h1>
            <p style="margin: 5px 0 0 0; opacity: 0.9;">Generated: $(Get-Date -Format 'MMMM dd, yyyy') at $(Get-Date -Format 'HH:mm') UTC</p>
        </div>
        
        <div class="content">
            <div class="compliance-box">
                <div class="compliance-percent">$overallCompliancePercent%</div>
                <div>Overall Compliance Rate (users with ALL licenses) - $statusText</div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number">$totalUsers</div>
                    <div class="stat-label">Total Users</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #28a745;">$fullyCompliantCount</div>
                    <div class="stat-label">Fully Compliant</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #ffc107;">$partialCount</div>
                    <div class="stat-label">Partially Compliant</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #dc3545;">$nonCompliantCount</div>
                    <div class="stat-label">Non-Compliant</div>
                </div>
            </div>
            
            <h3>License Breakdown</h3>
            <div class="table-container">
                <table class="license-table">
                    <thead>
                        <tr>
                            <th>License</th>
                            <th style="text-align: center;">Licensed</th>
                            <th style="text-align: center;">Unlicensed</th>
                            <th style="text-align: center;">Compliance</th>
                        </tr>
                    </thead>
                    <tbody>
                        $licenseTableRows
                    </tbody>
                </table>
            </div>
            
            $(if ($totalNeedingLicenses -gt 0) {
@"

            <div class="action-required">
                <strong>ACTION REQUIRED:</strong> $totalNeedingLicenses users are missing one or more required security licenses.
            </div>
            
            <div class="table-container">
                <h3>Users Missing Licenses</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                            <th>Missing Licenses</th>
                        </tr>
                    </thead>
                    <tbody>
                        $nonCompliantTableRows
                    </tbody>
                </table>
                $moreUsersNote
            </div>
"@
            } else {
@"

            <div class="full-compliance">
                <strong>FULL COMPLIANCE ACHIEVED!</strong> All $totalUsers users have all required security licenses assigned. Great work!
            </div>
"@
            })
            
            <h3>How to View Full Details</h3>
            <p>Run these KQL queries in <strong>Log Analytics</strong>:</p>
            
            <p><strong>Users missing Teams Premium:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">TeamsPremiumLicenses_CL
| where TimeGenerated > ago(1d)
| where LicenseAssigned == false
| distinct UserPrincipalName, DisplayName</pre>
            
            <p><strong>Users missing any license:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">TeamsPremiumLicenses_CL
| where TimeGenerated > ago(1d)
| where FullyCompliant == false
| distinct UserPrincipalName, DisplayName, TeamsPremium, DefenderPurview</pre>
        </div>
        
        <div class="footer">
            <p><strong>Leonardo Company</strong> - LCE M365 Security Team</p>
            <p>This is an automated daily report from Azure Automation. Data is synced at midnight EST.</p>
            <p style="margin-top: 10px; color: #999;">Automation Account: AA-TeamsPremiumLicenseSync | Runbook: Sync-TeamsPremiumLicenses</p>
        </div>
    </div>
</body>
</html>
"@

    # Build email message
    $emailMessage = @{
        message = @{
            subject = "$statusLabel $EmailSubject - $overallCompliancePercent% Compliance ($totalNeedingLicenses users need licenses)"
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
    Write-Output "Step 7: Email notifications disabled - skipping"
}

# ============================================
# FINAL SUMMARY
# ============================================

Write-Output ""
Write-Output "========================================================================"
Write-Output "                         SYNC COMPLETED"
Write-Output "========================================================================"
Write-Output "  Total Users:            $totalUsers"
Write-Output "  Fully Compliant:        $fullyCompliantCount ($overallCompliancePercent%)"
Write-Output "  Partially Compliant:    $partialCount"
Write-Output "  Non-Compliant:          $nonCompliantCount"
Write-Output "  Records Ingested:       $successCount"
Write-Output "  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "========================================================================"

if ($totalNeedingLicenses -gt 0) {
    Write-Output ""
    Write-Output "ACTION REQUIRED: $totalNeedingLicenses users need security licenses assigned"
}