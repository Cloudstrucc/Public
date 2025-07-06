param (
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName,

    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$false)]
    [string[]]$ResourceGroups
)

# Validate input
if (-not $EnvironmentName -and (-not $SubscriptionId -or -not $ResourceGroups)) {
    Write-Host "❗ You must specify at least one of the following:" -ForegroundColor Red
    Write-Host "   -EnvironmentName to purge Dataverse policy assignment" -ForegroundColor Yellow
    Write-Host "   -SubscriptionId AND -ResourceGroups to delete Azure resource groups" -ForegroundColor Yellow
    Write-Host "`nExample 1: .\Purge-PP-EnvAndAzure.ps1 -EnvironmentName 'YourEnvName'"
    Write-Host "Example 2: .\Purge-PP-EnvAndAzure.ps1 -SubscriptionId '0000...' -ResourceGroups @('rg1','rg2')"
    Write-Host "Example 3: .\Purge-PP-EnvAndAzure.ps1 -EnvironmentName 'YourEnvName' -SubscriptionId '0000...' -ResourceGroups @('rg1','rg2')"
    exit 1
}

# -------- Power Platform Enterprise Policy Removal --------
if ($EnvironmentName) {
    Write-Host "`n========== [ Power Platform Enterprise Policy Removal ] ==========" -ForegroundColor Cyan

    if (-not (Get-Module -ListAvailable -Name Microsoft.PowerApps.Administration.PowerShell)) {
        Write-Host "PowerApps Administration module not found. Please install it first:" -ForegroundColor Red
        Write-Host "Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force" -ForegroundColor Yellow
        exit 1
    }

    Import-Module Microsoft.PowerApps.Administration.PowerShell

    try {
        Write-Host "Logging into Power Platform..." -ForegroundColor Cyan
        Add-PowerAppsAccount -ErrorAction Stop
    }
    catch {
        Write-Host "Power Platform login failed: $_" -ForegroundColor Red
        exit 1
    }

    Write-Host "`nRemoving Enterprise Policy assignment from environment '$EnvironmentName'..." -ForegroundColor Yellow
    try {
        Remove-AdminPowerPlatformDataverseVNetEnterprisePolicy -EnvironmentName $EnvironmentName -Confirm:$false -ErrorAction Stop
        Write-Host "✅ Enterprise Policy has been removed from environment '$EnvironmentName'." -ForegroundColor Green
    }
    catch {
        Write-Host "❗ Failed to remove Enterprise Policy: $_" -ForegroundColor Red
    }

    Write-Host "`nVerifying if any Enterprise Policy is still assigned..." -ForegroundColor Cyan
    try {
        $policyStatus = Get-AdminPowerPlatformDataverseVNetEnterprisePolicy -EnvironmentName $EnvironmentName -ErrorAction Stop
        if ($policyStatus) {
            Write-Host "❌ An Enterprise Policy is still assigned: $($policyStatus.PolicyId)" -ForegroundColor Red
        }
        else {
            Write-Host "✅ No Enterprise Policy assigned to environment '$EnvironmentName'." -ForegroundColor Green
        }
    }
    catch {
        if ($_.Exception.Message -match "not found") {
            Write-Host "✅ No Enterprise Policy assigned to environment '$EnvironmentName'." -ForegroundColor Green
        }
        else {
            Write-Host "Error verifying policy status: $_" -ForegroundColor Red
        }
    }
}

# -------- Azure Resource Group Cleanup --------
if ($SubscriptionId -and $ResourceGroups) {
    Write-Host "`n========== [ Azure Resource Groups Cleanup ] ==========" -ForegroundColor Cyan

    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-Host "Az PowerShell module not found. Please install it first:" -ForegroundColor Red
        Write-Host "Install-Module -Name Az -AllowClobber -Force" -ForegroundColor Yellow
        exit 1
    }

    try {
        Write-Host "Logging into Azure..." -ForegroundColor Cyan
        Connect-AzAccount -ErrorAction Stop
    }
    catch {
        Write-Host "Azure login failed: $_" -ForegroundColor Red
        exit 1
    }

    try {
        Write-Host "Setting subscription context to '$SubscriptionId'..." -ForegroundColor Cyan
        Select-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to set subscription context: $_" -ForegroundColor Red
        exit 1
    }

    foreach ($rg in $ResourceGroups) {
        Write-Host "`nChecking if resource group '$rg' exists..." -ForegroundColor Cyan
        $rgObj = Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue
        if ($rgObj) {
            Write-Host "Deleting resource group '$rg' and all contained resources..." -ForegroundColor Yellow
            Remove-AzResourceGroup -Name $rg -Force -AsJob
        }
        else {
            Write-Host "Resource group '$rg' does not exist or was already deleted." -ForegroundColor Green
        }
    }
}

Write-Host "`n🎉 Requested purge operations complete. Monitor Azure Portal and your Power Platform Admin Center to confirm cleanup." -ForegroundColor Green
