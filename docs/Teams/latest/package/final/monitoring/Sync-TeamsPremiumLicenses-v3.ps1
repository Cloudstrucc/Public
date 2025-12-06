<#
.SYNOPSIS
    Teams Premium License Compliance Runbook with Email Notification
.DESCRIPTION
    Queries Microsoft Graph for ALL users and their Teams Premium license status.
    Ingests data to Log Analytics and sends a compliance report email to Compliance Administrators.
    
    Goal: Ensure all employees have Teams Premium licenses.
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
    Version: 3.0
    Runtime: PowerShell 7.2
    
    CHANGE LOG:
    v3.0 - Added email notification to Compliance Administrators
    v2.0 - Tracks ALL users for compliance reporting
    v1.0 - Initial release
#>

# ============================================
# CONFIGURATION
# ============================================

$DceUri = "https://dce-teamspremiumlicenses-4q1m.canadaeast-1.ingest.monitor.azure.com"
$DcrImmutableId = "dcr-80aee557ba12478a9dff76584b61ec38"
$StreamName = "Custom-TeamsPremiumLicenses_CL"
$TeamsPremiumSkuId = "36a0f3b3-adb5-49ea-bf66-762134cf063a"

# Email Configuration
$SendEmail = $true
$EmailFrom = "m365reports@leonardocompany.ca"                    # Shared mailbox to send FROM
$EmailTo = "Compliance-Administrators@leonardocompany.ca"        # Group to send TO

# ============================================
# INITIALIZATION
# ============================================

Write-Output "╔════════════════════════════════════════════════════════════════╗"
Write-Output "║     TEAMS PREMIUM LICENSE COMPLIANCE SYNC                      ║"
Write-Output "╚════════════════════════════════════════════════════════════════╝"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Output "Email Notifications: $(if($SendEmail){'Enabled - ' + $EmailTo}else{'Disabled'})"
Write-Output ""

# ============================================
# AUTHENTICATION
# ============================================

Write-Output "Step 1: Authenticating with Managed Identity..."

try {
    $azConnect = Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "  ✓ Connected as: $($azConnect.Context.Account.Id)"
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
    Write-Output "  ✓ Graph and Monitor tokens acquired"
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
    
    Write-Output "  ✓ Total enabled Member users: $($allUsers.Count)"
}
catch {
    Write-Error "Failed to query Microsoft Graph: $_"
    throw
}

# ============================================
# ANALYZE LICENSE STATUS
# ============================================

Write-Output ""
Write-Output "Step 4: Analyzing Teams Premium license assignments..."

$currentTime = (Get-Date).ToUniversalTime().ToString("o")
$logData = [System.Collections.Generic.List[hashtable]]::new()

$licensedUsers = [System.Collections.Generic.List[object]]::new()
$unlicensedUsers = [System.Collections.Generic.List[object]]::new()

foreach ($user in $allUsers) {
    $hasTeamsPremium = $user.assignedLicenses.skuId -contains $TeamsPremiumSkuId
    
    if ($hasTeamsPremium) {
        $licensedUsers.Add($user)
    }
    else {
        $unlicensedUsers.Add($user)
    }
    
    $logData.Add(@{
        TimeGenerated     = $currentTime
        UserPrincipalName = $user.userPrincipalName
        DisplayName       = $user.displayName
        LicenseAssigned   = $hasTeamsPremium
        ObjectId          = $user.id
    })
}

# Calculate statistics
$totalUsers = $allUsers.Count
$licensedCount = $licensedUsers.Count
$unlicensedCount = $unlicensedUsers.Count
$compliancePercent = if ($totalUsers -gt 0) { [math]::Round(($licensedCount / $totalUsers) * 100, 1) } else { 0 }

Write-Output ""
Write-Output "  ╔═══════════════════════════════════════════════════════════╗"
Write-Output "  ║            LICENSE COMPLIANCE SUMMARY                     ║"
Write-Output "  ╠═══════════════════════════════════════════════════════════╣"
Write-Output "  ║  Total Enabled Users:          $($totalUsers.ToString().PadLeft(6))                    ║"
Write-Output "  ║  Users WITH Teams Premium:     $($licensedCount.ToString().PadLeft(6))  ✓              ║"
Write-Output "  ║  Users WITHOUT Teams Premium:  $($unlicensedCount.ToString().PadLeft(6))  ⚠              ║"
Write-Output "  ║  Compliance Rate:              $($compliancePercent.ToString().PadLeft(5))%                  ║"
Write-Output "  ╚═══════════════════════════════════════════════════════════╝"
Write-Output ""

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output "Step 5: Ingesting data to Log Analytics..."

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
        Write-Output "  ✓ Batch $batchNumber/$totalBatches : $($batch.Count) records ingested"
    }
    catch {
        $failCount += $batch.Count
        Write-Warning "  ✗ Batch $batchNumber/$totalBatches : FAILED - $_"
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
    Write-Output "Step 6: Sending email notification..."
    Write-Output "  From: $EmailFrom"
    Write-Output "  To:   $EmailTo"
    
    # Determine status color/label for email (no emojis - they don't render in Azure Automation)
    $statusColor = if ($compliancePercent -ge 90) { "#28a745" } 
                   elseif ($compliancePercent -ge 50) { "#ffc107" } 
                   else { "#dc3545" }
    
    $statusLabel = if ($compliancePercent -ge 90) { "[OK]" } 
                   elseif ($compliancePercent -ge 50) { "[ACTION NEEDED]" } 
                   else { "[CRITICAL]" }
    
    $statusText = if ($compliancePercent -ge 90) { "Excellent" } 
                  elseif ($compliancePercent -ge 50) { "Needs Attention" } 
                  else { "Critical" }
    
    # Build unlicensed users table (first 25)
    $unlicensedTableRows = ""
    $sortedUnlicensed = $unlicensedUsers | Sort-Object { $_.displayName }
    $sortedUnlicensed | Select-Object -First 25 | ForEach-Object {
        $unlicensedTableRows += "<tr><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.displayName)</td><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.userPrincipalName)</td></tr>"
    }
    
    $moreUsersNote = ""
    if ($unlicensedCount -gt 25) {
        $moreUsersNote = "<p style='color: #666; font-style: italic;'>... and $($unlicensedCount - 25) more users without licenses. Query Log Analytics for the full list.</p>"
    }
    
    # Build HTML email body
    $emailBody = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { background-color: #0078d4; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
        .header h1 { margin: 0; font-size: 24px; }
        .content { padding: 20px; }
        .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin: 20px 0; }
        .stat-box { background-color: #f8f9fa; border-radius: 8px; padding: 15px; text-align: center; }
        .stat-number { font-size: 32px; font-weight: bold; color: #333; }
        .stat-label { color: #666; font-size: 14px; margin-top: 5px; }
        .compliance-box { background-color: $statusColor; color: white; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
        .compliance-percent { font-size: 48px; font-weight: bold; }
        .table-container { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f8f9fa; padding: 12px 8px; text-align: left; border-bottom: 2px solid #ddd; }
        .footer { background-color: #f8f9fa; padding: 15px 20px; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
        .action-required { background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .full-compliance { background-color: #d4edda; border: 1px solid #28a745; border-radius: 8px; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$statusLabel Teams Premium License Compliance Report</h1>
            <p style="margin: 5px 0 0 0; opacity: 0.9;">Generated: $(Get-Date -Format 'MMMM dd, yyyy') at $(Get-Date -Format 'HH:mm') UTC</p>
        </div>
        
        <div class="content">
            <div class="compliance-box">
                <div class="compliance-percent">$compliancePercent%</div>
                <div>License Compliance Rate - $statusText</div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number">$totalUsers</div>
                    <div class="stat-label">Total Enabled Users</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #28a745;">$licensedCount</div>
                    <div class="stat-label">Users WITH Teams Premium</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #dc3545;">$unlicensedCount</div>
                    <div class="stat-label">Users WITHOUT Teams Premium</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">$([math]::Round($successCount))</div>
                    <div class="stat-label">Records Synced to Log Analytics</div>
                </div>
            </div>
            
            $(if ($unlicensedCount -gt 0) {
@"

            <div class="action-required">
                <strong>ACTION REQUIRED:</strong> $unlicensedCount users need Teams Premium licenses assigned to achieve full compliance.
            </div>
            
            <div class="table-container">
                <h3>Users Without Teams Premium License</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                        </tr>
                    </thead>
                    <tbody>
                        $unlicensedTableRows
                    </tbody>
                </table>
                $moreUsersNote
            </div>
"@
            } else {
@"

            <div class="full-compliance">
                <strong>FULL COMPLIANCE ACHIEVED!</strong> All $totalUsers users have Teams Premium licenses assigned. Great work!
            </div>
"@
            })
            
            <h3>How to View Full Details</h3>
            <p>Run this KQL query in <strong>Log Analytics</strong> to see all unlicensed users:</p>
            <pre style="background-color: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 13px;">TeamsPremiumLicenses_CL
| where TimeGenerated > ago(1d)
| where LicenseAssigned == false
| distinct UserPrincipalName, DisplayName
| order by DisplayName asc</pre>
            
            <h3>View Compliance Trend</h3>
            <pre style="background-color: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 13px;">TeamsPremiumLicenses_CL
| summarize 
    Licensed = dcountif(UserPrincipalName, LicenseAssigned == true),
    Unlicensed = dcountif(UserPrincipalName, LicenseAssigned == false)
    by bin(TimeGenerated, 1d)
| extend CompliancePercent = round(100.0 * Licensed / (Licensed + Unlicensed), 1)
| order by TimeGenerated asc</pre>
        </div>
        
        <div class="footer">
            <p><strong>Leonardo Company</strong> - LCE M365 Security Team</p>
            <p>This is an automated daily report from Azure Automation. Data is synced at midnight EST and stored in Log Analytics.</p>
            <p style="margin-top: 10px; color: #999;">Automation Account: AA-TeamsPremiumLicenseSync | Runbook: Sync-TeamsPremiumLicenses | Workspace: rg-lce-m365-security-group-monnitor</p>
        </div>
    </div>
</body>
</html>
"@

    # Build email message
    $emailMessage = @{
        message = @{
            subject = "$statusLabel Teams Premium License Report - $compliancePercent% Compliance ($unlicensedCount need licenses)"
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
    
    # Send email via Microsoft Graph (from shared mailbox to group)
    try {
        $sendMailUri = "https://graph.microsoft.com/v1.0/users/$EmailFrom/sendMail"
        
        $null = Invoke-RestMethod `
            -Uri $sendMailUri `
            -Headers $graphHeaders `
            -Method Post `
            -Body $emailJson `
            -ContentType "application/json" `
            -ErrorAction Stop
        
        Write-Output "  ✓ Email sent successfully!"
        Write-Output "    From: $EmailFrom"
        Write-Output "    To:   $EmailTo"
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Warning "  ✗ Failed to send email: $errorMsg"
        Write-Output ""
        Write-Output "  TROUBLESHOOTING:"
        Write-Output "  1. Ensure shared mailbox '$EmailFrom' exists"
        Write-Output "  2. Verify Mail.Send permission is assigned to Managed Identity"
        Write-Output "  3. The compliance data has been logged to Log Analytics successfully"
        Write-Output "  4. You can view the report using the KQL queries in the runbook output"
    }
}
else {
    Write-Output ""
    Write-Output "Step 6: Email notifications disabled - skipping"
}

# ============================================
# FINAL SUMMARY
# ============================================

Write-Output ""
Write-Output "╔════════════════════════════════════════════════════════════════╗"
Write-Output "║                    SYNC COMPLETED                              ║"
Write-Output "╠════════════════════════════════════════════════════════════════╣"
Write-Output "║  Total Users:              $($totalUsers.ToString().PadLeft(6))                              ║"
Write-Output "║  Licensed:                 $($licensedCount.ToString().PadLeft(6))  ($compliancePercent%)                       ║"
Write-Output "║  Unlicensed:               $($unlicensedCount.ToString().PadLeft(6))                              ║"
Write-Output "║  Records Ingested:         $($successCount.ToString().PadLeft(6))                              ║"
Write-Output "║  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC                         ║"
Write-Output "╚════════════════════════════════════════════════════════════════╝"

if ($unlicensedCount -gt 0) {
    Write-Output ""
    Write-Output "⚠ ACTION REQUIRED: $unlicensedCount users need Teams Premium licenses"
}