# If you have the file locally, just use the path
$runbookPath = "C:\Users\fred.pearson\Repos\Public\docs\Teams\latest\package\final\monitoring\runbook.ps1"

# Import to Azure Automation
Import-AzAutomationRunbook `
    -ResourceGroupName $Global:ResourceGroupName `
    -AutomationAccountName $Global:AutomationAccountName `
    -Name "Sync-TeamsPremiumLicenses" `
    -Type "PowerShell72" `
    -Path $runbookPath `
    -Force

# Publish it
Publish-AzAutomationRunbook `
    -ResourceGroupName $Global:ResourceGroupName `
    -AutomationAccountName $Global:AutomationAccountName `
    -Name "Sync-TeamsPremiumLicenses"

Write-Host "Runbook uploaded and published!" -ForegroundColor Green