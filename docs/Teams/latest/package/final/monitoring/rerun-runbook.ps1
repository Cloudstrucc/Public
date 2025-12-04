# Start the runbook again
$job = Start-AzAutomationRunbook `
    -ResourceGroupName $Global:ResourceGroupName `
    -AutomationAccountName $Global:AutomationAccountName `
    -Name "Sync-TeamsPremiumLicenses"

Write-Host "Job started: $($job.JobId)" -ForegroundColor Cyan

# Monitor the job
do {
    Start-Sleep -Seconds 5
    $jobStatus = Get-AzAutomationJob `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Id $job.JobId
    Write-Host "Status: $($jobStatus.Status)"
} while ($jobStatus.Status -notin @("Completed", "Failed", "Stopped", "Suspended"))

# Get output
Write-Host "`n========== JOB OUTPUT ==========" -ForegroundColor Cyan
Get-AzAutomationJobOutput `
    -ResourceGroupName $Global:ResourceGroupName `
    -AutomationAccountName $Global:AutomationAccountName `
    -Id $job.JobId `
    -Stream Any | 
    ForEach-Object { Write-Host $_.Summary }