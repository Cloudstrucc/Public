# Query the custom table (may take 5-10 minutes for data to appear)
$query = @"
TeamsPremiumLicenses_CL
| where TimeGenerated > ago(1h)
| summarize 
    RecordCount = count(), 
    UniqueUsers = dcount(UserPrincipalName),
    LatestSync = max(TimeGenerated)
"@

Write-Host "Querying Log Analytics..." -ForegroundColor Yellow
Write-Host "Workspace: $Global:WorkspaceName" -ForegroundColor Gray

Invoke-AzOperationalInsightsQuery `
    -WorkspaceId $Global:WorkspaceId `
    -Query $query | 
    Select-Object -ExpandProperty Results | 
    Format-Table