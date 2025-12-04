<#
.SYNOPSIS
    Teams Premium License Compliance Runbook
.DESCRIPTION
    Queries Microsoft Graph for ALL users and their Teams Premium license status.
    Ingests data to Log Analytics to track license compliance over time.
    
    Goal: Ensure all employees have Teams Premium licenses.
    This runbook identifies users WITHOUT licenses so they can be assigned.
.REQUIREMENTS
    - Azure Automation Account with System-Assigned Managed Identity enabled
    - PowerShell 7.2 Runtime
    - Az.Accounts module imported in Automation Account
    - Managed Identity requires:
      * Microsoft Graph: User.Read.All (Application permission)
      * Azure RBAC: Monitoring Metrics Publisher on the DCR
.NOTES
    Author: LCE M365 Security Team
    Version: 2.0
    Runtime: PowerShell 7.2
    
    CHANGE LOG:
    v2.0 - Now tracks ALL users (licensed AND unlicensed) for compliance reporting
    v1.1 - Added detailed troubleshooting output
    v1.0 - Initial release (tracked licensed users only)
#>

# ============================================
# CONFIGURATION
# ============================================

$DceUri = "https://dce-teamspremiumlicenses-4q1m.canadaeast-1.ingest.monitor.azure.com"
$DcrImmutableId = "dcr-80aee557ba12478a9dff76584b61ec38"
$StreamName = "Custom-TeamsPremiumLicenses_CL"
$TeamsPremiumSkuId = "36a0f3b3-adb5-49ea-bf66-762134cf063a"  # Leonardo Canada Teams Premium SKU

# ============================================
# INITIALIZATION
# ============================================

Write-Output "╔════════════════════════════════════════════════════════════════╗"
Write-Output "║     TEAMS PREMIUM LICENSE COMPLIANCE SYNC                      ║"
Write-Output "╚════════════════════════════════════════════════════════════════╝"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Output ""

# ============================================
# AUTHENTICATION
# ============================================

Write-Output "Step 1: Authenticating with Managed Identity..."

try {
    $azConnect = Connect-AzAccount -Identity -ErrorAction Stop
    
    Write-Output "  ✓ Connected as: $($azConnect.Context.Account.Id)"
    Write-Output "  ✓ Tenant: $($azConnect.Context.Tenant.Id)"
}
catch {
    Write-Error "Failed to authenticate: $_"
    throw
}

# Get tokens
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
            # Only include enabled user accounts (exclude disabled/terminated)
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
    
    # Add to log data (tracking ALL users)
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

# Show sample of unlicensed users (first 10)
if ($unlicensedCount -gt 0) {
    Write-Output "  Sample of users WITHOUT Teams Premium (first 10):"
    Write-Output "  ─────────────────────────────────────────────────────────"
    $unlicensedUsers | Select-Object -First 10 | ForEach-Object {
        Write-Output "    • $($_.displayName) ($($_.userPrincipalName))"
    }
    if ($unlicensedCount -gt 10) {
        Write-Output "    ... and $($unlicensedCount - 10) more"
    }
    Write-Output ""
}

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output "Step 5: Ingesting data to Log Analytics..."
Write-Output "  Records to ingest: $($logData.Count)"

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
# FINAL SUMMARY
# ============================================

Write-Output ""
Write-Output "╔════════════════════════════════════════════════════════════════╗"
Write-Output "║                    SYNC COMPLETED                              ║"
Write-Output "╠════════════════════════════════════════════════════════════════╣"
Write-Output "║                                                                ║"
Write-Output "║  TENANT LICENSE STATUS:                                        ║"
Write-Output "║  ────────────────────────────────────────────────────────────  ║"
Write-Output "║    Total Users:              $($totalUsers.ToString().PadLeft(6))                          ║"
Write-Output "║    Licensed (Teams Premium): $($licensedCount.ToString().PadLeft(6))   ($compliancePercent%)                  ║"
Write-Output "║    Unlicensed:               $($unlicensedCount.ToString().PadLeft(6))   (need licenses)          ║"
Write-Output "║                                                                ║"
Write-Output "║  DATA INGESTION:                                               ║"
Write-Output "║  ────────────────────────────────────────────────────────────  ║"
Write-Output "║    Successfully ingested:    $($successCount.ToString().PadLeft(6))                          ║"
Write-Output "║    Failed:                   $($failCount.ToString().PadLeft(6))                          ║"
Write-Output "║                                                                ║"
Write-Output "║  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC                       ║"
Write-Output "╚════════════════════════════════════════════════════════════════╝"

if ($unlicensedCount -gt 0) {
    Write-Output ""
    Write-Output "⚠ ACTION REQUIRED: $unlicensedCount users need Teams Premium licenses"
    Write-Output ""
    Write-Output "To view unlicensed users, run this KQL query in Log Analytics:"
    Write-Output ""
    Write-Output "  TeamsPremiumLicenses_CL"
    Write-Output "  | where TimeGenerated > ago(1d)"
    Write-Output "  | where LicenseAssigned == false"
    Write-Output "  | distinct UserPrincipalName, DisplayName"
    Write-Output "  | order by DisplayName asc"
    Write-Output ""
}

if ($failCount -gt 0) {
    Write-Warning "Some records failed to ingest. Check the errors above."
}