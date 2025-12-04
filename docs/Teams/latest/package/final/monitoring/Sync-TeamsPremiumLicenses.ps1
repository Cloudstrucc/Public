<#
.SYNOPSIS
    Teams Premium License Sync Runbook
.DESCRIPTION
    Queries Microsoft Graph for Teams Premium license assignments
    and ingests the data into Log Analytics via DCR.
    
    This runbook runs in Azure Automation using a System-Assigned Managed Identity.
.REQUIREMENTS
    - Azure Automation Account with System-Assigned Managed Identity enabled
    - PowerShell 7.2 Runtime (NOT PowerShell 5.1)
    - Az.Accounts module imported in Automation Account
    - Managed Identity requires:
      * Microsoft Graph: User.Read.All (Application permission)
      * Azure RBAC: Monitoring Metrics Publisher on the DCR
.NOTES
    Author: LCE M365 Security Team
    Version: 1.1
    Runtime: PowerShell 7.2
#>

# ============================================
# CONFIGURATION
# ============================================

$DceUri = "https://dce-teamspremiumlicenses-4q1m.canadaeast-1.ingest.monitor.azure.com"
$DcrImmutableId = "dcr-80aee557ba12478a9dff76584b61ec38"
$StreamName = "Custom-TeamsPremiumLicenses_CL"
$TeamsPremiumSkuId = "16ddbbfc-09ea-4de2-b1d7-312db6112d70"

# ============================================
# INITIALIZATION
# ============================================

Write-Output "============================================"
Write-Output "Teams Premium License Sync Runbook"
Write-Output "============================================"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Output ""
Write-Output "Configuration:"
Write-Output "  DCE URI: $DceUri"
Write-Output "  DCR Immutable ID: $DcrImmutableId"
Write-Output "  Stream: $StreamName"
Write-Output ""

# ============================================
# AUTHENTICATION
# ============================================

Write-Output "Step 1: Authenticating with Managed Identity..."

try {
    $azConnect = Connect-AzAccount -Identity -ErrorAction Stop
    
    Write-Output "  ✓ Azure connection established"
    Write-Output "    Account Type: $($azConnect.Context.Account.Type)"
    Write-Output "    Account ID: $($azConnect.Context.Account.Id)"
    Write-Output "    Tenant: $($azConnect.Context.Tenant.Id)"
    Write-Output "    Subscription: $($azConnect.Context.Subscription.Name)"
}
catch {
    Write-Error "Failed to authenticate with Managed Identity"
    Write-Output ""
    Write-Output "ERROR DETAILS: $_"
    Write-Output ""
    Write-Output "TROUBLESHOOTING:"
    Write-Output "  1. Verify System-Assigned Managed Identity is ENABLED on the Automation Account"
    Write-Output "  2. Ensure this runbook is configured to use PowerShell 7.2 runtime"
    Write-Output "  3. Check that Az.Accounts module is imported in the Automation Account"
    Write-Output "  4. In Azure Portal: Automation Account > Identity > System assigned = ON"
    throw
}

# Get Microsoft Graph token
Write-Output ""
Write-Output "Step 2: Acquiring Microsoft Graph token..."

try {
    $graphTokenResponse = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com" -ErrorAction Stop
    $graphToken = $graphTokenResponse.Token
    
    Write-Output "  ✓ Graph token acquired"
    Write-Output "    Expires: $($graphTokenResponse.ExpiresOn)"
}
catch {
    Write-Error "Failed to acquire Microsoft Graph token"
    Write-Output ""
    Write-Output "ERROR DETAILS: $_"
    Write-Output ""
    Write-Output "TROUBLESHOOTING:"
    Write-Output "  1. Verify User.Read.All permission is granted to the Managed Identity"
    Write-Output "  2. In Azure Portal: Entra ID > Enterprise Apps > (your Automation Account MI)"
    Write-Output "  3. Check Permissions > Application permissions > User.Read.All"
    Write-Output "  4. Re-run Step 6.1 from the Build Book"
    throw
}

# Get Azure Monitor token
Write-Output ""
Write-Output "Step 3: Acquiring Azure Monitor token..."

try {
    $monitorTokenResponse = Get-AzAccessToken -ResourceUrl "https://monitor.azure.com" -ErrorAction Stop
    $monitorToken = $monitorTokenResponse.Token
    
    Write-Output "  ✓ Monitor token acquired"
    Write-Output "    Expires: $($monitorTokenResponse.ExpiresOn)"
}
catch {
    Write-Error "Failed to acquire Azure Monitor token"
    Write-Output ""
    Write-Output "ERROR DETAILS: $_"
    throw
}

Write-Output ""
Write-Output "Authentication completed successfully!"

# ============================================
# QUERY MICROSOFT GRAPH
# ============================================

Write-Output ""
Write-Output "Step 4: Querying Microsoft Graph for users..."

$graphHeaders = @{
    "Authorization"    = "Bearer $graphToken"
    "Content-Type"     = "application/json"
    "ConsistencyLevel" = "eventual"
}

$users = [System.Collections.Generic.List[object]]::new()
$uri = "https://graph.microsoft.com/v1.0/users?`$select=id,userPrincipalName,displayName,assignedLicenses&`$top=999"
$pageCount = 0

try {
    do {
        $pageCount++
        $response = Invoke-RestMethod -Uri $uri -Headers $graphHeaders -Method Get -ErrorAction Stop
        
        foreach ($user in $response.value) {
            $users.Add($user)
        }
        
        $uri = $response.'@odata.nextLink'
        
        if ($pageCount % 5 -eq 0) {
            Write-Output "  Retrieved $($users.Count) users (page $pageCount)..."
        }
    } while ($uri)
    
    Write-Output "  ✓ Total users retrieved: $($users.Count)"
}
catch {
    Write-Error "Failed to query Microsoft Graph"
    Write-Output ""
    Write-Output "ERROR DETAILS: $_"
    
    if ($_.ErrorDetails.Message) {
        Write-Output "API ERROR: $($_.ErrorDetails.Message)"
    }
    throw
}

# ============================================
# FILTER TEAMS PREMIUM USERS
# ============================================

Write-Output ""
Write-Output "Step 5: Filtering Teams Premium license holders..."

$teamsPremiumUsers = $users | Where-Object {
    $_.assignedLicenses.skuId -contains $TeamsPremiumSkuId
}

Write-Output "  ✓ Users with Teams Premium: $($teamsPremiumUsers.Count)"

if ($teamsPremiumUsers.Count -eq 0) {
    Write-Output ""
    Write-Output "No Teams Premium users found. Nothing to sync."
    Write-Output ""
    Write-Output "NOTE: If you expect users, verify the Teams Premium SKU ID is correct."
    Write-Output "Current SKU ID: $TeamsPremiumSkuId"
    return
}

# ============================================
# BUILD LOG PAYLOAD
# ============================================

Write-Output ""
Write-Output "Step 6: Building ingestion payload..."

$currentTime = (Get-Date).ToUniversalTime().ToString("o")

$logData = [System.Collections.Generic.List[hashtable]]::new()

foreach ($user in $teamsPremiumUsers) {
    $logData.Add(@{
        TimeGenerated     = $currentTime
        UserPrincipalName = $user.userPrincipalName
        DisplayName       = $user.displayName
        LicenseAssigned   = $true
        ObjectId          = $user.id
    })
}

Write-Output "  ✓ Payload built: $($logData.Count) records"

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output ""
Write-Output "Step 7: Ingesting data to Log Analytics..."

$ingestUri = "$DceUri/dataCollectionRules/$DcrImmutableId/streams/$StreamName`?api-version=2023-01-01"

Write-Output "  Target URI: $ingestUri"

$ingestHeaders = @{
    "Authorization" = "Bearer $monitorToken"
    "Content-Type"  = "application/json"
}

$batchSize = 500
$totalBatches = [math]::Ceiling($logData.Count / $batchSize)
$successCount = 0
$failCount = 0

Write-Output "  Batch size: $batchSize"
Write-Output "  Total batches: $totalBatches"
Write-Output ""

for ($i = 0; $i -lt $logData.Count; $i += $batchSize) {
    $batchNumber = [math]::Floor($i / $batchSize) + 1
    $endIndex = [math]::Min($i + $batchSize - 1, $logData.Count - 1)
    $batch = $logData[$i..$endIndex]
    
    # Convert to JSON array
    $batchBody = ConvertTo-Json -InputObject @($batch) -Depth 10 -Compress
    
    try {
        $null = Invoke-RestMethod -Uri $ingestUri -Headers $ingestHeaders -Method Post -Body $batchBody -ErrorAction Stop
        $successCount += $batch.Count
        Write-Output "  ✓ Batch $batchNumber/$totalBatches : $($batch.Count) records ingested"
    }
    catch {
        $failCount += $batch.Count
        Write-Warning "  ✗ Batch $batchNumber/$totalBatches : FAILED"
        Write-Warning "    Error: $_"
        
        if ($_.ErrorDetails.Message) {
            Write-Warning "    Details: $($_.ErrorDetails.Message)"
        }
    }
    
    # Small delay between batches to avoid throttling
    if ($batchNumber -lt $totalBatches) {
        Start-Sleep -Milliseconds 500
    }
}

# ============================================
# SUMMARY
# ============================================

Write-Output ""
Write-Output "============================================"
Write-Output "SYNC COMPLETED"
Write-Output "============================================"
Write-Output ""
Write-Output "Results:"
Write-Output "  Total Teams Premium users: $($teamsPremiumUsers.Count)"
Write-Output "  Successfully ingested:     $successCount"
Write-Output "  Failed:                    $failCount"
Write-Output ""
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "============================================"

if ($failCount -gt 0) {
    Write-Warning "Some records failed to ingest. Check the errors above."
}