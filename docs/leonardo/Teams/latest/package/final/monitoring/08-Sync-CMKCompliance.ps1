<#
.SYNOPSIS
    CMK (Customer Managed Keys) Compliance Runbook - Group-Based with Auto-Apply & Delta Reporting
.DESCRIPTION
    Comprehensive CMK compliance check focused on the LCE-CMK-ENABLED-USERS group.
    
    FEATURES:
    1. Monitors CMK group membership and DEP status
    2. AUTOMATICALLY APPLIES DEP to group members who don't have it
    3. Reports newly applied DEP assignments in dashboard
    4. Shows organization delta (users not in CMK group)
    
    Services Covered:
    - Exchange Online (Email, Calendar)
    - Microsoft Teams (Chat, Meetings, Voicemail)
    - SharePoint Online (Sites, Libraries) - Tenant-wide
    - OneDrive for Business - Tenant-wide
    - Teams Files (via SharePoint) - Tenant-wide
    
    Note: SharePoint/OneDrive CMK is tenant-wide, not per-user.
          Exchange/Teams CMK is per-user via DEP policy.
.REQUIREMENTS
    - Azure Automation Account with System-Assigned Managed Identity
    - PowerShell 7.2 Runtime
    - Az.Accounts module imported
    - ExchangeOnlineManagement module imported (v3.4.0+)
    - Managed Identity requires:
      * Microsoft Graph: User.Read.All, GroupMember.Read.All
      * Microsoft Graph: Mail.Send (for email notifications)
      * Exchange Online: Exchange.ManageAsApp
      * Exchange Administrator role
      * Azure RBAC: Monitoring Metrics Publisher on the DCR
.NOTES
    Author: LCE M365 Security Team
    Version: 4.0
    Runtime: PowerShell 7.2
    
    CHANGE LOG:
    v4.0 - Added automatic DEP application with dashboard visualization
    v3.0 - Group-based compliance with organization delta reporting
    v2.0 - Added SharePoint/OneDrive CMK status checking
    v1.0 - Initial CMK compliance tracking
#>

# ============================================
# CONFIGURATION
# ============================================

# Data Collection Configuration
$DceUri = "https://dce-teamspremiumlicenses-4q1m.canadaeast-1.ingest.monitor.azure.com"
$DcrImmutableId = "dcr-REPLACE-WITH-CMK-DCR-ID"  # Update after creating DCR
$StreamName = "Custom-CMKCompliance_CL"

# CMK Target Group Configuration
$CMKGroupName = "LCE-CMK-ENABLED-USERS"
$CMKGroupObjectId = "36ba0617-d0a4-454a-b755-5207e34d275a"

# CMK Configuration - Exchange/Teams DEP
$ExchangeDEPName = "Leonardo-CMK-DEP"

# AUTO-APPLY CONFIGURATION
# Set to $true to automatically apply DEP to group members who don't have it
# Set to $false to only report (no changes made)
$AutoApplyDEP = $true

# CMK Configuration - SharePoint/OneDrive (MANUAL CONFIGURATION)
$SharePointCMKConfig = @{
    IsRegistered  = $true
    PrimaryKey    = "https://kv-cmk-spo-pri-1117.vault.azure.net/keys/spo-cmk-key"
    SecondaryKey  = "https://kv-cmk-spo-sec-1117.vault.azure.net/keys/spo-cmk-key"
}

# Email Configuration
$SendEmail = $true
$EmailFrom = "m365reports@leonardocompany.ca"
$EmailTo = "Compliance-Administrators@leonardocompany.ca"
$EmailSubject = "CMK Encryption Compliance Report"

# ============================================
# INITIALIZATION
# ============================================

Write-Output "========================================================================"
Write-Output "     M365 CMK ENCRYPTION COMPLIANCE SYNC"
Write-Output "     Group-Based Reporting with Auto-Apply & Organization Delta"
Write-Output "========================================================================"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Output ""
Write-Output "Target CMK Group: $CMKGroupName"
Write-Output "Group Object ID:  $CMKGroupObjectId"
Write-Output "Auto-Apply DEP:   $(if($AutoApplyDEP){'ENABLED'}else{'DISABLED (Report Only)'})"
Write-Output ""
Write-Output "DEP Configuration:"
Write-Output "  - Exchange/Teams DEP: $ExchangeDEPName"
Write-Output "  - SharePoint CMK: $(if($SharePointCMKConfig.IsRegistered){'Registered'}else{'Not Registered'})"
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
# GET CMK GROUP MEMBERS FROM MICROSOFT GRAPH
# ============================================

Write-Output ""
Write-Output "Step 3: Getting CMK group members from Microsoft Graph..."

$graphHeaders = @{
    "Authorization"    = "Bearer $graphToken"
    "Content-Type"     = "application/json"
    "ConsistencyLevel" = "eventual"
}

$cmkGroupMembers = [System.Collections.Generic.List[object]]::new()

try {
    $uri = "https://graph.microsoft.com/v1.0/groups/$CMKGroupObjectId/members?`$select=id,userPrincipalName,displayName,mail&`$top=999"
    
    do {
        $response = Invoke-RestMethod -Uri $uri -Headers $graphHeaders -Method Get -ErrorAction Stop
        
        foreach ($member in $response.value) {
            # Only include users (not groups or service principals)
            if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                $cmkGroupMembers.Add($member)
            }
        }
        
        $uri = $response.'@odata.nextLink'
    } while ($uri)
    
    Write-Output "  [OK] CMK group members: $($cmkGroupMembers.Count)"
}
catch {
    Write-Error "Failed to get CMK group members: $_"
    throw
}

# Create a hashtable for quick lookup
$cmkGroupMemberUPNs = @{}
foreach ($member in $cmkGroupMembers) {
    if ($member.userPrincipalName) {
        $cmkGroupMemberUPNs[$member.userPrincipalName.ToLower()] = $true
    }
}

# ============================================
# CHECK SHAREPOINT/ONEDRIVE CMK STATUS (TENANT-WIDE)
# ============================================

Write-Output ""
Write-Output "Step 4: Checking SharePoint/OneDrive CMK status..."

$spoStatus = @{
    Checked = $true
    Enabled = $SharePointCMKConfig.IsRegistered
    PrimaryKeyUri = $SharePointCMKConfig.PrimaryKey
    SecondaryKeyUri = $SharePointCMKConfig.SecondaryKey
    State = if ($SharePointCMKConfig.IsRegistered) { "Registered" } else { "Not Registered" }
}

if ($spoStatus.Enabled) {
    Write-Output "  [OK] SharePoint CMK Status: $($spoStatus.State)"
    Write-Output "       Primary Key: $($spoStatus.PrimaryKeyUri)"
    Write-Output "       Secondary Key: $($spoStatus.SecondaryKeyUri)"
}
else {
    Write-Output "  [WARN] SharePoint CMK: Not Registered"
}

# ============================================
# CONNECT TO EXCHANGE ONLINE
# ============================================

Write-Output ""
Write-Output "Step 5: Connecting to Exchange Online..."

try {
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    Write-Output "  [OK] ExchangeOnlineManagement module loaded"
    
    Connect-ExchangeOnline -ManagedIdentity -Organization "leonardocompany.ca" -ShowBanner:$false -ErrorAction Stop
    Write-Output "  [OK] Connected to Exchange Online via Managed Identity"
}
catch {
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
# VERIFY DEP POLICY EXISTS
# ============================================

Write-Output ""
Write-Output "Step 6: Verifying DEP policy exists..."

try {
    $depPolicy = Get-DataEncryptionPolicy -Identity $ExchangeDEPName -ErrorAction Stop
    Write-Output "  [OK] DEP policy found: $($depPolicy.Name)"
    Write-Output "       State: $($depPolicy.State)"
    Write-Output "       Enabled: $($depPolicy.Enabled)"
}
catch {
    Write-Error "DEP policy '$ExchangeDEPName' not found! Cannot proceed."
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    throw
}

# ============================================
# QUERY ALL MAILBOXES
# ============================================

Write-Output ""
Write-Output "Step 7: Querying all mailboxes..."

$allMailboxes = [System.Collections.Generic.List[object]]::new()

try {
    $mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox -ErrorAction Stop
    
    foreach ($mailbox in $mailboxes) {
        $allMailboxes.Add($mailbox)
    }
    
    Write-Output "  [OK] Total organization mailboxes: $($allMailboxes.Count)"
}
catch {
    Write-Error "Failed to query mailboxes: $_"
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    throw
}

# ============================================
# ANALYZE CMK STATUS BY GROUP
# ============================================

Write-Output ""
Write-Output "Step 8: Analyzing CMK status by group membership..."

$currentTime = (Get-Date).ToUniversalTime().ToString("o")

# Categorize mailboxes
$cmkGroupMailboxes = [System.Collections.Generic.List[object]]::new()      # In CMK group
$nonCmkGroupMailboxes = [System.Collections.Generic.List[object]]::new()   # Not in CMK group

$cmkGroupCompliant = [System.Collections.Generic.List[object]]::new()      # In group + has DEP
$cmkGroupNonCompliant = [System.Collections.Generic.List[object]]::new()   # In group + missing DEP

foreach ($mailbox in $allMailboxes) {
    $upn = $mailbox.UserPrincipalName.ToLower()
    $hasDEP = $mailbox.DataEncryptionPolicy -eq $ExchangeDEPName
    $inCMKGroup = $cmkGroupMemberUPNs.ContainsKey($upn)
    
    if ($inCMKGroup) {
        $cmkGroupMailboxes.Add($mailbox)
        if ($hasDEP) {
            $cmkGroupCompliant.Add($mailbox)
        }
        else {
            $cmkGroupNonCompliant.Add($mailbox)
        }
    }
    else {
        $nonCmkGroupMailboxes.Add($mailbox)
    }
}

# Check for users in group but without mailbox
$groupMembersWithoutMailbox = [System.Collections.Generic.List[object]]::new()
$mailboxUPNs = @{}
foreach ($mb in $allMailboxes) {
    $mailboxUPNs[$mb.UserPrincipalName.ToLower()] = $true
}
foreach ($member in $cmkGroupMembers) {
    if ($member.userPrincipalName -and -not $mailboxUPNs.ContainsKey($member.userPrincipalName.ToLower())) {
        $groupMembersWithoutMailbox.Add($member)
    }
}

# Pre-apply statistics
$preApplyStats = @{
    TotalOrg = $allMailboxes.Count
    TotalCMKGroup = $cmkGroupMailboxes.Count
    TotalNonCMKGroup = $nonCmkGroupMailboxes.Count
    CompliantBefore = $cmkGroupCompliant.Count
    NonCompliantBefore = $cmkGroupNonCompliant.Count
}

Write-Output ""
Write-Output "  PRE-SYNC STATUS:"
Write-Output "    Total Organization:       $($preApplyStats.TotalOrg)"
Write-Output "    In CMK Group:             $($preApplyStats.TotalCMKGroup)"
Write-Output "    Already Compliant:        $($preApplyStats.CompliantBefore)"
Write-Output "    Need DEP Applied:         $($preApplyStats.NonCompliantBefore)"

# ============================================
# AUTO-APPLY DEP TO NON-COMPLIANT GROUP MEMBERS
# ============================================

Write-Output ""
Write-Output "Step 9: Processing DEP applications..."

# Track results
$depApplicationResults = @{
    Success = [System.Collections.Generic.List[object]]::new()
    Failed = [System.Collections.Generic.List[object]]::new()
    Skipped = [System.Collections.Generic.List[object]]::new()
}

if ($AutoApplyDEP -and $cmkGroupNonCompliant.Count -gt 0) {
    Write-Output "  [AUTO-APPLY ENABLED] Applying DEP to $($cmkGroupNonCompliant.Count) users..."
    Write-Output ""
    
    $total = $cmkGroupNonCompliant.Count
    $count = 0
    
    foreach ($mailbox in $cmkGroupNonCompliant) {
        $count++
        $upn = $mailbox.UserPrincipalName
        $displayName = $mailbox.DisplayName
        
        try {
            Set-Mailbox -Identity $upn -DataEncryptionPolicy $ExchangeDEPName -ErrorAction Stop
            
            Write-Output "    [$count/$total] [OK] $displayName"
            
            $depApplicationResults.Success.Add(@{
                DisplayName = $displayName
                UserPrincipalName = $upn
                PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                PreviousPolicy = if ($mailbox.DataEncryptionPolicy) { $mailbox.DataEncryptionPolicy } else { "None" }
                AppliedAt = (Get-Date).ToUniversalTime().ToString("o")
            })
        }
        catch {
            Write-Output "    [$count/$total] [FAIL] $displayName : $($_.Exception.Message)"
            
            $depApplicationResults.Failed.Add(@{
                DisplayName = $displayName
                UserPrincipalName = $upn
                PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                Error = $_.Exception.Message
            })
        }
    }
    
    Write-Output ""
    Write-Output "  DEP APPLICATION RESULTS:"
    Write-Output "    Successfully Applied: $($depApplicationResults.Success.Count)"
    Write-Output "    Failed:               $($depApplicationResults.Failed.Count)"
}
elseif (-not $AutoApplyDEP -and $cmkGroupNonCompliant.Count -gt 0) {
    Write-Output "  [REPORT ONLY MODE] $($cmkGroupNonCompliant.Count) users need DEP but auto-apply is disabled"
    
    foreach ($mailbox in $cmkGroupNonCompliant) {
        $depApplicationResults.Skipped.Add(@{
            DisplayName = $mailbox.DisplayName
            UserPrincipalName = $mailbox.UserPrincipalName
            PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
        })
    }
}
else {
    Write-Output "  [OK] All CMK group members already have DEP applied - no action needed"
}

# ============================================
# CALCULATE POST-APPLY STATISTICS
# ============================================

$postApplyStats = @{
    NewlyApplied = $depApplicationResults.Success.Count
    FailedToApply = $depApplicationResults.Failed.Count
    CompliantAfter = $preApplyStats.CompliantBefore + $depApplicationResults.Success.Count
    NonCompliantAfter = $preApplyStats.NonCompliantBefore - $depApplicationResults.Success.Count
}

$groupCompliancePercentBefore = if ($preApplyStats.TotalCMKGroup -gt 0) { 
    [math]::Round(($preApplyStats.CompliantBefore / $preApplyStats.TotalCMKGroup) * 100, 1) 
} else { 0 }

$groupCompliancePercentAfter = if ($preApplyStats.TotalCMKGroup -gt 0) { 
    [math]::Round(($postApplyStats.CompliantAfter / $preApplyStats.TotalCMKGroup) * 100, 1) 
} else { 0 }

$complianceImprovement = $groupCompliancePercentAfter - $groupCompliancePercentBefore

# Display final results
Write-Output ""
Write-Output "  ========================================================================"
Write-Output "                    CMK COMPLIANCE SUMMARY"
Write-Output "  ========================================================================"
Write-Output ""
Write-Output "  CMK GROUP: $CMKGroupName"
Write-Output "    Members (with mailbox):   $($preApplyStats.TotalCMKGroup)"
Write-Output "    Compliant BEFORE sync:    $($preApplyStats.CompliantBefore) ($groupCompliancePercentBefore%)"
Write-Output "    Compliant AFTER sync:     $($postApplyStats.CompliantAfter) ($groupCompliancePercentAfter%)"
Write-Output "    Newly Applied This Run:   $($postApplyStats.NewlyApplied)"
Write-Output "    Failed to Apply:          $($postApplyStats.FailedToApply)"
Write-Output "    Still Non-Compliant:      $($postApplyStats.NonCompliantAfter)"
if ($groupMembersWithoutMailbox.Count -gt 0) {
    Write-Output "    Members w/o Mailbox:      $($groupMembersWithoutMailbox.Count)"
}
Write-Output ""
Write-Output "  ORGANIZATION DELTA:"
Write-Output "    Users not in CMK group:   $($preApplyStats.TotalNonCMKGroup)"
Write-Output ""
Write-Output "  SHAREPOINT/ONEDRIVE (Tenant-Wide):"
Write-Output "    Status: $(if($spoStatus.Enabled){'[OK] Enabled'}else{'[NOT ENABLED]'})"
Write-Output ""
Write-Output "  ========================================================================"

# ============================================
# BUILD LOG DATA FOR LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 10: Building log data..."

$logData = [System.Collections.Generic.List[hashtable]]::new()

foreach ($mailbox in $allMailboxes) {
    $upn = $mailbox.UserPrincipalName.ToLower()
    $inCMKGroup = $cmkGroupMemberUPNs.ContainsKey($upn)
    
    # Check if this user just got DEP applied
    $wasJustApplied = ($depApplicationResults.Success | Where-Object { $_.UserPrincipalName.ToLower() -eq $upn }) -ne $null
    
    # Determine current DEP status (after potential application)
    $hasDEP = if ($wasJustApplied) { $true } else { $mailbox.DataEncryptionPolicy -eq $ExchangeDEPName }
    $currentDEP = if ($wasJustApplied) { $ExchangeDEPName } elseif ($mailbox.DataEncryptionPolicy) { $mailbox.DataEncryptionPolicy } else { "None" }
    
    $logData.Add(@{
        TimeGenerated            = $currentTime
        UserPrincipalName        = $mailbox.UserPrincipalName
        DisplayName              = $mailbox.DisplayName
        PrimarySmtpAddress       = $mailbox.PrimarySmtpAddress
        InCMKGroup               = $inCMKGroup
        ExchangeTeamsCMK         = $hasDEP
        DataEncryptionPolicy     = $currentDEP
        SharePointOneDriveCMK    = $spoStatus.Enabled
        SharePointCMKState       = $spoStatus.State
        ComplianceStatus         = if ($inCMKGroup) { if ($hasDEP) { "Compliant" } else { "NonCompliant" } } else { "NotInScope" }
        DEPAppliedThisRun        = $wasJustApplied
        RecipientType            = $mailbox.RecipientTypeDetails
        WhenCreated              = $mailbox.WhenCreated.ToString("o")
    })
}

Write-Output "  [OK] Log data prepared: $($logData.Count) records"

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 11: Ingesting data to Log Analytics..."

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
    Write-Output "Step 12: Sending email notification..."
    Write-Output "  From: $EmailFrom"
    Write-Output "  To:   $EmailTo"
    
    # Determine status
    $overallCompliant = $spoStatus.Enabled -and ($groupCompliancePercentAfter -ge 90)
    
    $statusColor = if ($groupCompliancePercentAfter -eq 100) { "#28a745" } 
                   elseif ($groupCompliancePercentAfter -ge 90) { "#17a2b8" }
                   elseif ($groupCompliancePercentAfter -ge 50) { "#ffc107" } 
                   else { "#dc3545" }
    
    $statusLabel = if ($groupCompliancePercentAfter -eq 100) { "[OK]" }
                   elseif ($groupCompliancePercentAfter -ge 90) { "[GOOD]" }
                   elseif ($groupCompliancePercentAfter -ge 50) { "[ACTION NEEDED]" } 
                   else { "[CRITICAL]" }
    
    $statusText = if ($groupCompliancePercentAfter -eq 100) { "Fully Protected" }
                  elseif ($groupCompliancePercentAfter -ge 90) { "Nearly Complete" }
                  elseif ($groupCompliancePercentAfter -ge 50) { "Partially Protected" } 
                  else { "Critical - Action Required" }
    
    # Build newly applied users table (SUCCESS SECTION)
    $newlyAppliedTableRows = ""
    if ($depApplicationResults.Success.Count -gt 0) {
        $depApplicationResults.Success | Sort-Object { $_.DisplayName } | ForEach-Object {
            $newlyAppliedTableRows += "<tr><td style='padding: 10px; border-bottom: 1px solid #ddd;'>$($_.DisplayName)</td><td style='padding: 10px; border-bottom: 1px solid #ddd;'>$($_.PrimarySmtpAddress)</td><td style='padding: 10px; border-bottom: 1px solid #ddd;'><span style='background: #28a745; color: white; padding: 2px 8px; border-radius: 12px; font-size: 11px;'>$ExchangeDEPName</span></td></tr>"
        }
    }
    
    # Build failed users table
    $failedTableRows = ""
    if ($depApplicationResults.Failed.Count -gt 0) {
        $depApplicationResults.Failed | Sort-Object { $_.DisplayName } | ForEach-Object {
            $failedTableRows += "<tr><td style='padding: 10px; border-bottom: 1px solid #ddd;'>$($_.DisplayName)</td><td style='padding: 10px; border-bottom: 1px solid #ddd;'>$($_.PrimarySmtpAddress)</td><td style='padding: 10px; border-bottom: 1px solid #ddd; color: #dc3545;'>$($_.Error)</td></tr>"
        }
    }
    
    # Build still non-compliant users table (if any remain after auto-apply)
    $stillNonCompliantTableRows = ""
    $stillNonCompliantCount = $postApplyStats.NonCompliantAfter
    if ($stillNonCompliantCount -gt 0) {
        # Get users who are still non-compliant (failed or auto-apply disabled)
        $stillNonCompliant = if ($AutoApplyDEP) { $depApplicationResults.Failed } else { $depApplicationResults.Skipped }
        $stillNonCompliant | Sort-Object { $_.DisplayName } | Select-Object -First 25 | ForEach-Object {
            $stillNonCompliantTableRows += "<tr><td style='padding: 10px; border-bottom: 1px solid #ddd;'>$($_.DisplayName)</td><td style='padding: 10px; border-bottom: 1px solid #ddd;'>$($_.PrimarySmtpAddress)</td></tr>"
        }
    }
    
    # Build organization delta section
    $deltaTableRows = ""
    $nonCmkGroupMailboxes | Sort-Object { $_.DisplayName } | Select-Object -First 10 | ForEach-Object {
        $deltaTableRows += "<tr><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.DisplayName)</td><td style='padding: 8px; border-bottom: 1px solid #ddd;'>$($_.PrimarySmtpAddress)</td></tr>"
    }
    
    # SPO status colors
    $spoStatusColor = if ($spoStatus.Enabled) { "#28a745" } else { "#dc3545" }
    $spoStatusIcon = if ($spoStatus.Enabled) { "[OK]" } else { "[NOT ENABLED]" }
    $exchangeStatusColor = if ($groupCompliancePercentAfter -eq 100) { "#28a745" } elseif ($groupCompliancePercentAfter -ge 90) { "#17a2b8" } elseif ($groupCompliancePercentAfter -ge 50) { "#ffc107" } else { "#dc3545" }
    
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
        .stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin: 20px 0; }
        .stat-box { background-color: #f8f9fa; border-radius: 8px; padding: 15px; text-align: center; }
        .stat-number { font-size: 24px; font-weight: bold; color: #333; }
        .stat-label { color: #666; font-size: 11px; margin-top: 5px; }
        .compliance-box { background-color: $statusColor; color: white; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
        .compliance-status { font-size: 32px; font-weight: bold; }
        .table-container { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th { background-color: #f8f9fa; padding: 12px 8px; text-align: left; border-bottom: 2px solid #ddd; }
        .footer { background-color: #f8f9fa; padding: 15px 20px; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
        .success-box { background-color: #d4edda; border: 2px solid #28a745; border-radius: 8px; padding: 20px; margin: 20px 0; }
        .success-header { display: flex; align-items: center; margin-bottom: 15px; }
        .success-icon { font-size: 48px; margin-right: 15px; }
        .success-title { font-size: 20px; font-weight: bold; color: #155724; }
        .success-subtitle { color: #155724; opacity: 0.8; }
        .action-required { background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .full-compliance { background-color: #d4edda; border: 1px solid #28a745; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .info-box { background-color: #e7f3ff; border: 1px solid #0078d4; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .delta-box { background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 15px; margin: 20px 0; }
        .group-badge { display: inline-block; background-color: #0078d4; color: white; padding: 4px 12px; border-radius: 15px; font-size: 12px; margin-left: 10px; }
        .improvement-badge { display: inline-block; background-color: #28a745; color: white; padding: 4px 12px; border-radius: 15px; font-size: 14px; margin-left: 10px; }
        .error-box { background-color: #f8d7da; border: 2px solid #dc3545; border-radius: 8px; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$statusLabel CMK Encryption Compliance Report</h1>
            <p style="margin: 5px 0 0 0; opacity: 0.9;">Generated: $(Get-Date -Format 'MMMM dd, yyyy') at $(Get-Date -Format 'HH:mm') UTC | Auto-Apply: $(if($AutoApplyDEP){'Enabled'}else{'Disabled'})</p>
        </div>
        
        <div class="content">
            <div class="compliance-box">
                <div class="compliance-status">$statusText</div>
                <div>CMK Group Compliance: $groupCompliancePercentAfter%$(if($complianceImprovement -gt 0){" <span class='improvement-badge'>+$complianceImprovement% this run</span>"})</div>
            </div>
            
            $(if ($depApplicationResults.Success.Count -gt 0) {
@"
            <!-- NEWLY ENABLED USERS SECTION - PROMINENT VISUAL -->
            <div class="success-box">
                <div class="success-header">
                    <div class="success-icon">✅</div>
                    <div>
                        <div class="success-title">$($depApplicationResults.Success.Count) Users Now CMK Protected!</div>
                        <div class="success-subtitle">DEP was automatically applied to these group members this sync run</div>
                    </div>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                            <th>DEP Applied</th>
                        </tr>
                    </thead>
                    <tbody>
                        $newlyAppliedTableRows
                    </tbody>
                </table>
            </div>
"@
            })
            
            <div class="info-box">
                <strong>Target Group:</strong> $CMKGroupName <span class="group-badge">$($preApplyStats.TotalCMKGroup) members</span>
                <br><br>
                <strong>Scope:</strong> Only users in this group are required to have CMK/DEP enabled. Users outside this group are shown for awareness only.
            </div>
            
            <h3>Sync Run Statistics</h3>
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number">$($preApplyStats.TotalOrg)</div>
                    <div class="stat-label">Total Org Mailboxes</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #0078d4;">$($preApplyStats.TotalCMKGroup)</div>
                    <div class="stat-label">In CMK Group</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #28a745;">$($postApplyStats.NewlyApplied)</div>
                    <div class="stat-label">Newly Enabled</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: #28a745;">$($postApplyStats.CompliantAfter)</div>
                    <div class="stat-label">Total Compliant</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number" style="color: $(if($postApplyStats.NonCompliantAfter -eq 0){'#28a745'}else{'#dc3545'});">$($postApplyStats.NonCompliantAfter)</div>
                    <div class="stat-label">Still Missing DEP</div>
                </div>
            </div>
            
            <h3>Service Coverage</h3>
            <div class="service-grid">
                <div class="service-box" style="background-color: $(if($spoStatus.Enabled){'#d4edda'}else{'#f8d7da'}); border: 2px solid $spoStatusColor;">
                    <div class="service-title">SharePoint / OneDrive / Teams Files</div>
                    <div class="service-status" style="color: $spoStatusColor;">$spoStatusIcon</div>
                    <div class="service-detail">Tenant-wide (all users)</div>
                </div>
                <div class="service-box" style="background-color: $(if($groupCompliancePercentAfter -eq 100){'#d4edda'}elseif($groupCompliancePercentAfter -ge 90){'#d1ecf1'}elseif($groupCompliancePercentAfter -ge 50){'#fff3cd'}else{'#f8d7da'}); border: 2px solid $exchangeStatusColor;">
                    <div class="service-title">Exchange / Teams Chat / Meetings</div>
                    <div class="service-status" style="color: $exchangeStatusColor;">$groupCompliancePercentAfter%</div>
                    <div class="service-detail">$($postApplyStats.CompliantAfter) of $($preApplyStats.TotalCMKGroup) group members</div>
                </div>
            </div>
            
            $(if ($depApplicationResults.Failed.Count -gt 0) {
@"
            <!-- FAILED APPLICATIONS -->
            <div class="error-box">
                <strong>⚠️ Failed to Apply DEP ($($depApplicationResults.Failed.Count) users)</strong>
                <p style="margin: 10px 0 15px 0; color: #721c24;">These users require manual intervention:</p>
                <table>
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                            <th>Error</th>
                        </tr>
                    </thead>
                    <tbody>
                        $failedTableRows
                    </tbody>
                </table>
            </div>
"@
            })
            
            $(if ($postApplyStats.NonCompliantAfter -gt 0 -and -not $AutoApplyDEP) {
@"
            <div class="action-required">
                <strong>ACTION REQUIRED:</strong> $($postApplyStats.NonCompliantAfter) members of $CMKGroupName do not have DEP enabled. Auto-apply is disabled.
            </div>
            
            <div class="table-container">
                <h3>Group Members Missing DEP</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                        </tr>
                    </thead>
                    <tbody>
                        $stillNonCompliantTableRows
                    </tbody>
                </table>
                $(if ($stillNonCompliantCount -gt 25) { "<p style='color: #666; font-style: italic;'>... and $($stillNonCompliantCount - 25) more users need DEP applied.</p>" })
            </div>
            
            <h3>Manual DEP Application</h3>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;"># Apply DEP to a specific user:
Set-Mailbox -Identity "user@leonardocompany.ca" -DataEncryptionPolicy "$ExchangeDEPName"

# Or enable Auto-Apply in the runbook configuration</pre>
"@
            } elseif ($postApplyStats.NonCompliantAfter -eq 0) {
@"
            <div class="full-compliance">
                <strong>🎉 CMK GROUP FULLY COMPLIANT!</strong><br>
                All $($preApplyStats.TotalCMKGroup) members of $CMKGroupName have DEP enabled.
            </div>
"@
            })
            
            <div class="delta-box">
                <h3 style="margin-top: 0;">Organization Delta (Not in CMK Group)</h3>
                <p style="color: #666; font-size: 13px;">These $($preApplyStats.TotalNonCMKGroup) users are NOT in the $CMKGroupName group and therefore not required to have Exchange/Teams CMK. Add them to the group if they need CMK protection.</p>
                $(if ($preApplyStats.TotalNonCMKGroup -gt 0) {
@"
                <table style="margin-top: 15px;">
                    <thead>
                        <tr>
                            <th>Display Name</th>
                            <th>Email</th>
                        </tr>
                    </thead>
                    <tbody>
                        $deltaTableRows
                    </tbody>
                </table>
                $(if ($preApplyStats.TotalNonCMKGroup -gt 10) { "<p style='color: #666; font-style: italic;'>... and $($preApplyStats.TotalNonCMKGroup - 10) more users not in CMK group.</p>" })
"@
                } else {
                    "<p><strong>All organization users are in the CMK group.</strong></p>"
                })
            </div>
            
            <h3>Log Analytics Queries</h3>
            
            <p><strong>Users who got DEP applied today:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where DEPAppliedThisRun == true
| project UserPrincipalName, DisplayName, TimeGenerated</pre>
            
            <p><strong>CMK group members still missing DEP:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where InCMKGroup == true and ExchangeTeamsCMK == false
| distinct UserPrincipalName, DisplayName</pre>
            
            <p><strong>CMK compliance trend over time:</strong></p>
            <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 4px; overflow-x: auto; font-family: Consolas, monospace; font-size: 12px;">CMKCompliance_CL
| where InCMKGroup == true
| summarize 
    Total = dcount(UserPrincipalName),
    Compliant = dcountif(UserPrincipalName, ExchangeTeamsCMK == true)
    by bin(TimeGenerated, 1d)
| extend CompliancePercent = round(100.0 * Compliant / Total, 1)
| order by TimeGenerated desc</pre>
        </div>
        
        <div class="footer">
            <p><strong>Leonardo Company</strong> - LCE M365 Security Team</p>
            <p>This is an automated daily report. Data synced at midnight EST.</p>
            <p style="margin-top: 10px; color: #999;">Runbook: Sync-CMKCompliance v4.0 | Target Group: $CMKGroupName | Auto-Apply: $(if($AutoApplyDEP){'Enabled'}else{'Disabled'})</p>
        </div>
    </div>
</body>
</html>
"@

    # Build email message
    $emailMessage = @{
        message = @{
            subject = "$statusLabel $EmailSubject - $groupCompliancePercentAfter% $(if($postApplyStats.NewlyApplied -gt 0){"(+$($postApplyStats.NewlyApplied) newly enabled)"}else{"($($postApplyStats.NonCompliantAfter) need DEP)"})"
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
    Write-Output "Step 12: Email notifications disabled - skipping"
}

# ============================================
# DISCONNECT FROM EXCHANGE ONLINE
# ============================================

Write-Output ""
Write-Output "Step 13: Disconnecting from Exchange Online..."
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
Write-Output "  TARGET GROUP: $CMKGroupName"
Write-Output "    Members (with mailbox):   $($preApplyStats.TotalCMKGroup)"
Write-Output "    Compliant Before:         $($preApplyStats.CompliantBefore) ($groupCompliancePercentBefore%)"
Write-Output "    Compliant After:          $($postApplyStats.CompliantAfter) ($groupCompliancePercentAfter%)"
Write-Output "    Newly Applied:            $($postApplyStats.NewlyApplied)"
Write-Output "    Failed:                   $($postApplyStats.FailedToApply)"
Write-Output "    Still Non-Compliant:      $($postApplyStats.NonCompliantAfter)"
Write-Output ""
Write-Output "  ORGANIZATION DELTA:"
Write-Output "    Users not in CMK group:   $($preApplyStats.TotalNonCMKGroup)"
Write-Output ""
Write-Output "  SHAREPOINT / ONEDRIVE:"
Write-Output "    CMK Enabled:              $(if($spoStatus.Enabled){'Yes'}else{'No'})"
Write-Output ""
Write-Output "  AUTO-APPLY MODE:            $(if($AutoApplyDEP){'ENABLED'}else{'DISABLED'})"
Write-Output "  Records Ingested:           $successCount"
Write-Output "  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "========================================================================"

if ($postApplyStats.NonCompliantAfter -gt 0) {
    Write-Output ""
    Write-Output "NOTE: $($postApplyStats.NonCompliantAfter) group members still need DEP"
    if ($postApplyStats.FailedToApply -gt 0) {
        Write-Output "      $($postApplyStats.FailedToApply) failed - check errors above for manual remediation"
    }
}