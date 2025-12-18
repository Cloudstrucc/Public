#Requires -Modules Az.OperationalInsights, Az.Monitor, Az.Resources

<#
.SYNOPSIS
    Deploys the Teams Premium & CMK Compliance Workbook and Alert Rules

.DESCRIPTION
    This script deploys:
    1. Azure Monitor Workbook for compliance tracking
    2. Action Group for admin notifications
    3. Scheduled Query Alert Rule for non-compliance detection

.PARAMETER SubscriptionId
    Azure Subscription ID

.PARAMETER ResourceGroupName
    Resource Group containing Log Analytics workspace

.PARAMETER WorkspaceName
    Name of the Log Analytics workspace with Entra ID logs

.PARAMETER AdminEmail
    Email address for compliance alert notifications

.PARAMETER AlertFrequencyHours
    How often to check for non-compliance (default: 24 hours)

.PARAMETER Location
    Azure region for deployment. Must be canadacentral or canadaeast for Leonardo compliance.
    Default: canadacentral

.EXAMPLE
    .\Deploy-ComplianceMonitoring.ps1 `
        -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412" `
        -ResourceGroupName "rg-lce-monitoring" `
        -WorkspaceName "ComplianceLogsM365" `
        -AdminEmail "fred.pearson@leonardocanada.ca" `
        -Location "canadacentral" `
        -SkipWorkbook
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $true)]
    [string]$AdminEmail,

    [Parameter(Mandatory = $false)]
    [ValidateSet("canadaeast", "canadacentral", "eastus", "eastus2", "westus", "westus2", "northeurope", "westeurope")]
    [string]$Location = "canadacentral",

    [Parameter(Mandatory = $false)]
    [int]$AlertFrequencyHours = 24,

    [Parameter(Mandatory = $false)]
    [string]$WorkbookDisplayName = "Teams Premium & CMK Compliance Dashboard",

    [Parameter(Mandatory = $false)]
    [switch]$SkipWorkbook,

    [Parameter(Mandatory = $false)]
    [switch]$SkipAlert
)

#region Functions

function Write-LogMessage {
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "Info"    { "Cyan" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        "Success" { "Green" }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-LogMessage "Checking prerequisites..." -Level Info
    
    # Check Azure connection
    $context = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $context) {
        Write-LogMessage "Not connected to Azure. Please run Connect-AzAccount first." -Level Error
        return $false
    }
    
    # Set subscription
    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
    Write-LogMessage "Connected to subscription: $SubscriptionId" -Level Success
    
    # Verify workspace exists
    $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
    if (-not $workspace) {
        Write-LogMessage "Log Analytics workspace '$WorkspaceName' not found in resource group '$ResourceGroupName'" -Level Error
        return $false
    }
    Write-LogMessage "Found workspace: $WorkspaceName" -Level Success
    
    return $true
}

function Deploy-Workbook {
    param(
        [string]$WorkspaceResourceId,
        [string]$WorkbookContent,
        [string]$DeploymentLocation
    )
    
    Write-LogMessage "Deploying Azure Monitor Workbook to $DeploymentLocation..." -Level Info
    
    $workbookId = [guid]::NewGuid().ToString()
    $workbookName = $workbookId
    
    # Create workbook resource
    $workbookParams = @{
        ResourceGroupName = $ResourceGroupName
        ResourceType      = "Microsoft.Insights/workbooks"
        ResourceName      = $workbookName
        Location          = $DeploymentLocation
        ApiVersion        = "2022-04-01"
        Properties        = @{
            displayName    = $WorkbookDisplayName
            serializedData = $WorkbookContent
            category       = "workbook"
            sourceId       = $WorkspaceResourceId
        }
        Kind              = "shared"
    }
    
    try {
        $workbook = New-AzResource @workbookParams -Force
        Write-LogMessage "Workbook deployed successfully: $($workbook.ResourceId)" -Level Success
        return $workbook.ResourceId
    }
    catch {
        Write-LogMessage "Failed to deploy workbook: $_" -Level Error
        return $null
    }
}

function Deploy-AlertRule {
    param(
        [string]$TemplateFile,
        [string]$WorkspaceResourceGroup,
        [string]$WorkspaceName,
        [string]$AdminEmail,
        [int]$FrequencyMinutes,
        [string]$DeploymentLocation
    )
    
    Write-LogMessage "Deploying Alert Rule and Action Group to $DeploymentLocation..." -Level Info
    
    $deploymentParams = @{
        workspaceName           = $WorkspaceName
        workspaceResourceGroup  = $WorkspaceResourceGroup
        actionGroupEmail        = $AdminEmail
        alertFrequencyMinutes   = $FrequencyMinutes
        location                = $DeploymentLocation
    }
    
    try {
        $deployment = New-AzResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterObject $deploymentParams `
            -Name "TeamsPremiumCMKAlert-$(Get-Date -Format 'yyyyMMddHHmmss')" `
            -ErrorAction Stop
        
        Write-LogMessage "Alert rule deployed successfully" -Level Success
        Write-LogMessage "Alert Rule ID: $($deployment.Outputs.alertRuleId.Value)" -Level Info
        Write-LogMessage "Action Group ID: $($deployment.Outputs.actionGroupId.Value)" -Level Info
        
        return $deployment
    }
    catch {
        Write-LogMessage "Failed to deploy alert rule: $_" -Level Error
        return $null
    }
}

#endregion Functions

#region Main Execution

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Teams Premium & CMK Compliance Monitoring Deployment" -ForegroundColor Cyan
Write-Host "  Leonardo Company - LCE M365 Security Team" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Verify prerequisites
if (-not (Test-Prerequisites)) {
    Write-LogMessage "Prerequisites check failed. Exiting." -Level Error
    exit 1
}

# Get workspace details
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
$workspaceResourceId = $workspace.ResourceId

# Deploy Workbook
if (-not $SkipWorkbook) {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $workbookTemplatePath = Join-Path $scriptPath "workbook-template.json"
    
    if (Test-Path $workbookTemplatePath) {
        $workbookContent = Get-Content $workbookTemplatePath -Raw
        $workbookId = Deploy-Workbook -WorkspaceResourceId $workspaceResourceId -WorkbookContent $workbookContent -DeploymentLocation $Location
    }
    else {
        Write-LogMessage "Workbook template not found at: $workbookTemplatePath" -Level Warning
    }
}
else {
    Write-LogMessage "Skipping workbook deployment (SkipWorkbook flag set)" -Level Info
}

# Deploy Alert Rule
if (-not $SkipAlert) {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $alertTemplatePath = Join-Path $scriptPath "alert-rule-template.json"
    
    if (Test-Path $alertTemplatePath) {
        $alertDeployment = Deploy-AlertRule `
            -TemplateFile $alertTemplatePath `
            -WorkspaceResourceGroup $ResourceGroupName `
            -WorkspaceName $WorkspaceName `
            -AdminEmail $AdminEmail `
            -FrequencyMinutes ($AlertFrequencyHours * 60) `
            -DeploymentLocation $Location
    }
    else {
        Write-LogMessage "Alert rule template not found at: $alertTemplatePath" -Level Warning
    }
}
else {
    Write-LogMessage "Skipping alert rule deployment (SkipAlert flag set)" -Level Info
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Deployment Complete" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-LogMessage "Next Steps:" -Level Info
Write-Host "  1. Navigate to Azure Monitor > Workbooks" -ForegroundColor White
Write-Host "  2. Find '$WorkbookDisplayName'" -ForegroundColor White
Write-Host "  3. Verify data is populating (may take up to 24 hours for initial data)" -ForegroundColor White
Write-Host "  4. Add additional email recipients to the Action Group if needed" -ForegroundColor White
Write-Host ""

#endregion Main Execution
