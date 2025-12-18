# Teams Premium License Sync to Azure Monitor

## Build Book - Custom Log Table with Data Collection Rules (DCR)

**Version:** 1.0  
**Author:** LCE M365 Security Team  
**Last Updated:** December 2025  
**Classification:** Internal Use

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Prerequisites](#3-prerequisites)
4. [Step 0: Configuration Variables](#step-0-configuration-variables)
5. [Step 1: Environment Preparation](#step-1-environment-preparation)
6. [Step 2: Create Log Analytics Custom Table](#step-2-create-log-analytics-custom-table)
7. [Step 3: Create Data Collection Endpoint (DCE)](#step-3-create-data-collection-endpoint-dce)
8. [Step 4: Create Data Collection Rule (DCR)](#step-4-create-data-collection-rule-dcr)
9. [Step 5: Create Azure Automation Account](#step-5-create-azure-automation-account)
10. [Step 6: Configure Managed Identity Permissions](#step-6-configure-managed-identity-permissions)
11. [Step 7: Create and Configure the Runbook](#step-7-create-and-configure-the-runbook)
12. [Step 8: Schedule the Runbook](#step-8-schedule-the-runbook)
13. [Step 9: Validation and Testing](#step-9-validation-and-testing)
14. [KQL Queries](#kql-queries)
15. [Troubleshooting](#troubleshooting)
16. [Maintenance](#maintenance)
17. [Appendix](#appendix)

---

## 1. Overview

### Purpose

This build book provides step-by-step instructions to deploy an automated solution that syncs Microsoft Teams Premium license assignments to Azure Monitor Log Analytics. This enables KQL queries to identify active users without Teams Premium licenses.

### Business Value

- Identify users who need Teams Premium licenses
- Track license compliance over time
- Enable automated alerting for license management
- Support capacity planning and cost optimization

### Solution Components

| Component | Purpose |
|-----------|---------|
| Custom Log Table | Stores Teams Premium license data natively in Log Analytics |
| Data Collection Endpoint (DCE) | Ingestion endpoint for the Logs Ingestion API |
| Data Collection Rule (DCR) | Defines data transformation and destination |
| Azure Automation | Hosts the scheduled PowerShell runbook |
| Managed Identity | Secure, passwordless authentication to Graph and Azure |

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AZURE AUTOMATION                             │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    PowerShell Runbook                        │    │
│  │         (Scheduled: Daily at 2:00 AM UTC)                    │    │
│  └──────────────────────┬──────────────────────────────────────┘    │
│                         │                                            │
│            Managed Identity Authentication                           │
└─────────────────────────┼────────────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │                               │
          ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│   Microsoft Graph   │         │  Data Collection    │
│       API           │         │    Endpoint (DCE)   │
│                     │         │                     │
│  • User.Read.All    │         │  Logs Ingestion API │
│  • License data     │         │                     │
└─────────────────────┘         └──────────┬──────────┘
                                           │
                                           ▼
                                ┌─────────────────────┐
                                │  Data Collection    │
                                │    Rule (DCR)       │
                                │                     │
                                │  Transform & Route  │
                                └──────────┬──────────┘
                                           │
                                           ▼
                                ┌─────────────────────┐
                                │   Log Analytics     │
                                │     Workspace       │
                                │                     │
                                │ TeamsPremiumLicenses│
                                │       _CL           │
                                └─────────────────────┘
```

---

## 3. Prerequisites

### Required Access

| Requirement | Minimum Role |
|-------------|--------------|
| Azure Subscription | Contributor on Resource Group |
| Log Analytics Workspace | Log Analytics Contributor |
| Microsoft Entra ID | Global Administrator (for Graph API consent) |
| Azure Automation | Automation Contributor |

### Required Information

Before starting, gather the following:

```
Azure Subscription ID:      ________________________________
Resource Group Name:        ________________________________
Log Analytics Workspace:    ________________________________
Region:                     ________________________________ (e.g., canadacentral)
```

### PowerShell Execution Policy

> **IMPORTANT:** PowerShell scripts require appropriate execution policies. Run PowerShell as Administrator.

```powershell
# Check current execution policy
Get-ExecutionPolicy -List

# Set execution policy to RemoteSigned (recommended for enterprise)
# This allows local scripts to run and requires remote scripts to be signed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Alternative: Set for LocalMachine (requires admin rights)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

**Execution Policy Options:**
- `Restricted` - No scripts can run (default on Windows clients)
- `RemoteSigned` - Local scripts run freely; downloaded scripts require signature
- `Unrestricted` - All scripts run with warnings for downloaded scripts
- `Bypass` - No restrictions (not recommended for production)

---

## Step 0: Configuration Variables

> **IMPORTANT:** Run this script FIRST before any other steps. This sets all the configuration variables used throughout the deployment. Keep this PowerShell session open for all subsequent steps.

### 0.1 Save Configuration Script

Save this as `Set-DeploymentConfig.ps1` and run it at the start of your deployment session:

```powershell
<#
.SYNOPSIS
    Teams Premium License Sync - Configuration Variables
.DESCRIPTION
    Sets all configuration variables required for the deployment.
    RUN THIS SCRIPT FIRST and keep the PowerShell session open.
    
    If required values are not set, the script will interactively
    prompt you to select from available Azure resources.
.NOTES
    Author: LCE M365 Security Team
    Version: 1.1
    
    INSTRUCTIONS:
    1. Optionally update the values in the "USER CONFIGURATION" section below
    2. Run this script: .\Set-DeploymentConfig.ps1
    3. If values are blank, you'll be prompted to select from available resources
    4. Keep this PowerShell session open for all subsequent steps
#>

#Requires -Version 5.1

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                           USER CONFIGURATION                                  ║
# ║              UPDATE THESE VALUES OR LEAVE BLANK FOR INTERACTIVE              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ------------------------------------------------------------------------------
# AZURE SUBSCRIPTION & RESOURCE GROUP
# Leave blank to select interactively from available options
# ------------------------------------------------------------------------------
$Global:SubscriptionId        = ""                                 # Leave blank to select interactively
$Global:ResourceGroupName     = ""                                 # Leave blank to select interactively
$Global:Location              = ""                                 # Will be auto-detected from Resource Group if blank

# ------------------------------------------------------------------------------
# LOG ANALYTICS WORKSPACE
# Leave blank to select interactively from available options
# ------------------------------------------------------------------------------
$Global:WorkspaceName         = ""                                 # Leave blank to select interactively
$Global:TableName             = "TeamsPremiumLicenses"             # Custom table name (will become TeamsPremiumLicenses_CL)
$Global:TableRetentionDays    = 90                                 # Data retention in days (30-730)
$Global:TableTotalRetention   = 365                                # Total retention including archive (90-2555)

# ------------------------------------------------------------------------------
# DATA COLLECTION ENDPOINT (DCE)
# ------------------------------------------------------------------------------
$Global:DceName               = "DCE-TeamsPremiumLicenses"         # Data Collection Endpoint name

# ------------------------------------------------------------------------------
# DATA COLLECTION RULE (DCR)
# ------------------------------------------------------------------------------
$Global:DcrName               = "DCR-TeamsPremiumLicenses"         # Data Collection Rule name
$Global:StreamName            = "Custom-TeamsPremiumLicenses_CL"   # Stream name (must match table)

# ------------------------------------------------------------------------------
# AZURE AUTOMATION
# ------------------------------------------------------------------------------
$Global:AutomationAccountName = "AA-TeamsPremiumLicenseSync"       # Automation Account name
$Global:RunbookName           = "Sync-TeamsPremiumLicenses"        # Runbook name
$Global:ScheduleName          = "Daily-TeamsPremiumSync"           # Schedule name
$Global:ScheduleTimeZone      = "Eastern Standard Time"            # Time zone for schedule
$Global:ScheduleStartHour     = 2                                  # Hour to run (24-hour format, e.g., 2 = 2:00 AM)

# ------------------------------------------------------------------------------
# MICROSOFT 365 LICENSE
# ------------------------------------------------------------------------------
$Global:TeamsPremiumSkuId     = "36a0f3b3-adb5-49ea-bf66-762134cf063a"  # Teams Premium SKU ID - VERIFY for your tenant

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                      DO NOT MODIFY BELOW THIS LINE                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║            TEAMS PREMIUM LICENSE SYNC - DEPLOYMENT CONFIGURATION             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# HELPER FUNCTION: Show Selection Menu
# ------------------------------------------------------------------------------

function Show-SelectionMenu {
    <#
    .SYNOPSIS
        Displays an interactive selection menu
    .PARAMETER Title
        Menu title
    .PARAMETER Options
        Array of options to display
    .PARAMETER PropertyName
        Property to display (for objects)
    #>
    param(
        [string]$Title,
        [array]$Options,
        [string]$PropertyName = $null
    )
    
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "  $("-" * $Title.Length)" -ForegroundColor Yellow
    Write-Host ""
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $displayValue = if ($PropertyName) { $Options[$i].$PropertyName } else { $Options[$i] }
        Write-Host "    [$($i + 1)] $displayValue" -ForegroundColor White
    }
    
    Write-Host ""
    
    do {
        $selection = Read-Host "  Enter selection (1-$($Options.Count))"
        $index = [int]$selection - 1
    } while ($index -lt 0 -or $index -ge $Options.Count)
    
    return $Options[$index]
}

# ------------------------------------------------------------------------------
# ENSURE AZURE CONNECTION
# ------------------------------------------------------------------------------

Write-Host "Checking Azure connection..." -ForegroundColor Yellow

$context = Get-AzContext -ErrorAction SilentlyContinue

if ($null -eq $context) {
    Write-Host "  Not connected to Azure. Initiating login..." -ForegroundColor Yellow
    Write-Host ""
    Connect-AzAccount | Out-Null
    $context = Get-AzContext
}

Write-Host "  ✓ Connected as: $($context.Account.Id)" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------------------------
# SELECT SUBSCRIPTION (if not set)
# ------------------------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($Global:SubscriptionId) -or $Global:SubscriptionId -match "^<.*>$") {
    
    Write-Host "Retrieving available subscriptions..." -ForegroundColor Yellow
    $subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" } | Sort-Object Name
    
    if ($subscriptions.Count -eq 0) {
        Write-Error "No active subscriptions found. Please check your Azure access."
        $Global:ConfigurationValid = $false
        return
    }
    elseif ($subscriptions.Count -eq 1) {
        $selectedSub = $subscriptions[0]
        Write-Host "  Only one subscription available: $($selectedSub.Name)" -ForegroundColor Gray
    }
    else {
        $selectedSub = Show-SelectionMenu -Title "Select Azure Subscription" -Options $subscriptions -PropertyName "Name"
    }
    
    $Global:SubscriptionId = $selectedSub.Id
    Write-Host ""
    Write-Host "  ✓ Selected subscription: $($selectedSub.Name)" -ForegroundColor Green
}

# Set subscription context
Set-AzContext -SubscriptionId $Global:SubscriptionId | Out-Null

# ------------------------------------------------------------------------------
# SELECT RESOURCE GROUP (if not set or doesn't exist)
# ------------------------------------------------------------------------------

$rgExists = $false

if (-not [string]::IsNullOrWhiteSpace($Global:ResourceGroupName) -and $Global:ResourceGroupName -notmatch "^<.*>$") {
    # Check if specified RG exists
    $existingRg = Get-AzResourceGroup -Name $Global:ResourceGroupName -ErrorAction SilentlyContinue
    if ($existingRg) {
        $rgExists = $true
        Write-Host "  ✓ Resource Group exists: $($Global:ResourceGroupName)" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ Resource Group '$($Global:ResourceGroupName)' not found" -ForegroundColor Yellow
    }
}

if (-not $rgExists) {
    Write-Host ""
    Write-Host "Retrieving available Resource Groups..." -ForegroundColor Yellow
    $resourceGroups = Get-AzResourceGroup | Sort-Object ResourceGroupName
    
    if ($resourceGroups.Count -eq 0) {
        Write-Error "No Resource Groups found in subscription. Please create one first."
        $Global:ConfigurationValid = $false
        return
    }
    
    # Add option to create new
    $rgOptions = @()
    $rgOptions += [PSCustomObject]@{ ResourceGroupName = "[CREATE NEW RESOURCE GROUP]"; Location = "" }
    $rgOptions += $resourceGroups
    
    $selectedRg = Show-SelectionMenu -Title "Select Resource Group" -Options $rgOptions -PropertyName "ResourceGroupName"
    
    if ($selectedRg.ResourceGroupName -eq "[CREATE NEW RESOURCE GROUP]") {
        Write-Host ""
        $newRgName = Read-Host "  Enter new Resource Group name"
        
        # Get available locations
        $locations = Get-AzLocation | Where-Object { $_.Providers -contains "Microsoft.OperationalInsights" } | Sort-Object DisplayName
        $selectedLocation = Show-SelectionMenu -Title "Select Location for Resource Group" -Options $locations -PropertyName "DisplayName"
        
        Write-Host ""
        Write-Host "  Creating Resource Group '$newRgName' in $($selectedLocation.Location)..." -ForegroundColor Yellow
        
        $newRg = New-AzResourceGroup -Name $newRgName -Location $selectedLocation.Location
        $Global:ResourceGroupName = $newRg.ResourceGroupName
        $Global:Location = $newRg.Location
        
        Write-Host "  ✓ Resource Group created: $($Global:ResourceGroupName)" -ForegroundColor Green
    }
    else {
        $Global:ResourceGroupName = $selectedRg.ResourceGroupName
        $Global:Location = $selectedRg.Location
        Write-Host ""
        Write-Host "  ✓ Selected Resource Group: $($Global:ResourceGroupName)" -ForegroundColor Green
    }
}

# Get location from RG if not set
if ([string]::IsNullOrWhiteSpace($Global:Location)) {
    $rg = Get-AzResourceGroup -Name $Global:ResourceGroupName
    $Global:Location = $rg.Location
}

# ------------------------------------------------------------------------------
# SELECT LOG ANALYTICS WORKSPACE (if not set or doesn't exist)
# ------------------------------------------------------------------------------

Write-Host ""
$workspaceExists = $false

if (-not [string]::IsNullOrWhiteSpace($Global:WorkspaceName) -and $Global:WorkspaceName -notmatch "^<.*>$") {
    # Check if specified workspace exists (in RG or subscription)
    $existingWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $Global:ResourceGroupName -Name $Global:WorkspaceName -ErrorAction SilentlyContinue
    
    if ($null -eq $existingWorkspace) {
        # Try to find in entire subscription
        $existingWorkspace = Get-AzOperationalInsightsWorkspace | Where-Object { $_.Name -eq $Global:WorkspaceName } | Select-Object -First 1
    }
    
    if ($existingWorkspace) {
        $workspaceExists = $true
        Write-Host "  ✓ Log Analytics Workspace exists: $($Global:WorkspaceName)" -ForegroundColor Green
        
        # Update RG if workspace is in different RG
        if ($existingWorkspace.ResourceGroupName -ne $Global:ResourceGroupName) {
            Write-Host "    Note: Workspace is in Resource Group '$($existingWorkspace.ResourceGroupName)'" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  ⚠ Log Analytics Workspace '$($Global:WorkspaceName)' not found" -ForegroundColor Yellow
    }
}

if (-not $workspaceExists) {
    Write-Host ""
    Write-Host "Retrieving available Log Analytics Workspaces..." -ForegroundColor Yellow
    
    # Get all workspaces in subscription
    $workspaces = Get-AzOperationalInsightsWorkspace | Sort-Object Name
    
    if ($workspaces.Count -eq 0) {
        Write-Host "  No Log Analytics Workspaces found in subscription." -ForegroundColor Yellow
        Write-Host ""
        
        $createNew = Read-Host "  Would you like to create a new workspace? (Y/N)"
        
        if ($createNew -eq "Y" -or $createNew -eq "y") {
            $newWorkspaceName = Read-Host "  Enter new Log Analytics Workspace name"
            
            Write-Host ""
            Write-Host "  Creating Log Analytics Workspace '$newWorkspaceName'..." -ForegroundColor Yellow
            
            $newWorkspace = New-AzOperationalInsightsWorkspace `
                -ResourceGroupName $Global:ResourceGroupName `
                -Name $newWorkspaceName `
                -Location $Global:Location `
                -Sku "PerGB2018"
            
            $Global:WorkspaceName = $newWorkspace.Name
            Write-Host "  ✓ Log Analytics Workspace created: $($Global:WorkspaceName)" -ForegroundColor Green
        }
        else {
            Write-Error "A Log Analytics Workspace is required for this deployment."
            $Global:ConfigurationValid = $false
            return
        }
    }
    else {
        # Add option to create new
        $workspaceOptions = @()
        $workspaceOptions += [PSCustomObject]@{ 
            Name = "[CREATE NEW WORKSPACE]"
            ResourceGroupName = ""
            Location = ""
        }
        $workspaceOptions += $workspaces
        
        # Build display with RG info
        Write-Host ""
        Write-Host "  Select Log Analytics Workspace" -ForegroundColor Yellow
        Write-Host "  -------------------------------" -ForegroundColor Yellow
        Write-Host ""
        
        for ($i = 0; $i -lt $workspaceOptions.Count; $i++) {
            if ($i -eq 0) {
                Write-Host "    [$($i + 1)] $($workspaceOptions[$i].Name)" -ForegroundColor Cyan
            }
            else {
                Write-Host "    [$($i + 1)] $($workspaceOptions[$i].Name) " -NoNewline -ForegroundColor White
                Write-Host "(RG: $($workspaceOptions[$i].ResourceGroupName))" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        
        do {
            $selection = Read-Host "  Enter selection (1-$($workspaceOptions.Count))"
            $index = [int]$selection - 1
        } while ($index -lt 0 -or $index -ge $workspaceOptions.Count)
        
        $selectedWorkspace = $workspaceOptions[$index]
        
        if ($selectedWorkspace.Name -eq "[CREATE NEW WORKSPACE]") {
            Write-Host ""
            $newWorkspaceName = Read-Host "  Enter new Log Analytics Workspace name"
            
            Write-Host ""
            Write-Host "  Creating Log Analytics Workspace '$newWorkspaceName'..." -ForegroundColor Yellow
            
            $newWorkspace = New-AzOperationalInsightsWorkspace `
                -ResourceGroupName $Global:ResourceGroupName `
                -Name $newWorkspaceName `
                -Location $Global:Location `
                -Sku "PerGB2018"
            
            $Global:WorkspaceName = $newWorkspace.Name
            Write-Host "  ✓ Log Analytics Workspace created: $($Global:WorkspaceName)" -ForegroundColor Green
        }
        else {
            $Global:WorkspaceName = $selectedWorkspace.Name
            
            # If workspace is in different RG, ask if user wants to use that RG
            if ($selectedWorkspace.ResourceGroupName -ne $Global:ResourceGroupName) {
                Write-Host ""
                Write-Host "  Note: Selected workspace is in Resource Group '$($selectedWorkspace.ResourceGroupName)'" -ForegroundColor Yellow
                $useWorkspaceRg = Read-Host "  Deploy to workspace's Resource Group? (Y/N)"
                
                if ($useWorkspaceRg -eq "Y" -or $useWorkspaceRg -eq "y") {
                    $Global:ResourceGroupName = $selectedWorkspace.ResourceGroupName
                    $Global:Location = $selectedWorkspace.Location
                    Write-Host "  ✓ Updated Resource Group to: $($Global:ResourceGroupName)" -ForegroundColor Green
                }
            }
            
            Write-Host ""
            Write-Host "  ✓ Selected workspace: $($Global:WorkspaceName)" -ForegroundColor Green
        }
    }
}

# ------------------------------------------------------------------------------
# DERIVED VARIABLES (automatically calculated)
# ------------------------------------------------------------------------------
$Global:FullTableName         = "$($Global:TableName)_CL"
$Global:ScheduleStartTime     = (Get-Date).AddDays(1).Date.AddHours($Global:ScheduleStartHour)

# These will be populated during deployment
$Global:WorkspaceResourceId   = $null
$Global:WorkspaceId           = $null
$Global:DceResourceId         = $null
$Global:DceLogsIngestionUri   = $null
$Global:DcrResourceId         = $null
$Global:DcrImmutableId        = $null
$Global:AutomationAccountPrincipalId = $null

# ------------------------------------------------------------------------------
# CONFIGURATION OBJECT (for easy reference)
# ------------------------------------------------------------------------------
$Global:Config = @{
    # Azure
    SubscriptionId        = $Global:SubscriptionId
    ResourceGroupName     = $Global:ResourceGroupName
    Location              = $Global:Location
    
    # Log Analytics
    WorkspaceName         = $Global:WorkspaceName
    TableName             = $Global:TableName
    FullTableName         = $Global:FullTableName
    TableRetentionDays    = $Global:TableRetentionDays
    TableTotalRetention   = $Global:TableTotalRetention
    
    # DCE
    DceName               = $Global:DceName
    
    # DCR
    DcrName               = $Global:DcrName
    StreamName            = $Global:StreamName
    
    # Automation
    AutomationAccountName = $Global:AutomationAccountName
    RunbookName           = $Global:RunbookName
    ScheduleName          = $Global:ScheduleName
    ScheduleTimeZone      = $Global:ScheduleTimeZone
    ScheduleStartTime     = $Global:ScheduleStartTime
    
    # License
    TeamsPremiumSkuId     = $Global:TeamsPremiumSkuId
}

# ------------------------------------------------------------------------------
# FINAL VALIDATION
# ------------------------------------------------------------------------------

function Test-FinalConfiguration {
    $errors = @()
    
    # Validate subscription ID format
    if ($Global:SubscriptionId -notmatch "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$") {
        $errors += "SubscriptionId format is invalid"
    }
    
    # Validate required values are set
    if ([string]::IsNullOrWhiteSpace($Global:ResourceGroupName)) {
        $errors += "ResourceGroupName is not set"
    }
    if ([string]::IsNullOrWhiteSpace($Global:WorkspaceName)) {
        $errors += "WorkspaceName is not set"
    }
    if ([string]::IsNullOrWhiteSpace($Global:Location)) {
        $errors += "Location is not set"
    }
    
    # Validate retention values
    if ($Global:TableRetentionDays -lt 30 -or $Global:TableRetentionDays -gt 730) {
        $errors += "TableRetentionDays must be between 30 and 730"
    }
    
    return $errors
}

# ------------------------------------------------------------------------------
# DISPLAY FINAL CONFIGURATION
# ------------------------------------------------------------------------------

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Validate
$validationErrors = Test-FinalConfiguration

if ($validationErrors.Count -gt 0) {
    Write-Host "⚠ CONFIGURATION ERRORS DETECTED:" -ForegroundColor Red
    Write-Host ""
    foreach ($err in $validationErrors) {
        Write-Host "  ✗ $err" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please fix the errors and run the script again." -ForegroundColor Yellow
    Write-Host ""
    $Global:ConfigurationValid = $false
}
else {
    Write-Host "FINAL CONFIGURATION SUMMARY" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Azure Configuration:" -ForegroundColor Yellow
    Write-Host "  Subscription ID:      $Global:SubscriptionId" -ForegroundColor White
    Write-Host "  Resource Group:       $Global:ResourceGroupName" -ForegroundColor White
    Write-Host "  Location:             $Global:Location" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Log Analytics:" -ForegroundColor Yellow
    Write-Host "  Workspace:            $Global:WorkspaceName" -ForegroundColor White
    Write-Host "  Custom Table:         $Global:FullTableName" -ForegroundColor White
    Write-Host "  Retention:            $Global:TableRetentionDays days" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Data Collection:" -ForegroundColor Yellow
    Write-Host "  DCE Name:             $Global:DceName" -ForegroundColor White
    Write-Host "  DCR Name:             $Global:DcrName" -ForegroundColor White
    Write-Host "  Stream:               $Global:StreamName" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Automation:" -ForegroundColor Yellow
    Write-Host "  Account Name:         $Global:AutomationAccountName" -ForegroundColor White
    Write-Host "  Runbook:              $Global:RunbookName" -ForegroundColor White
    Write-Host "  Schedule:             $Global:ScheduleName" -ForegroundColor White
    Write-Host "  Run Time:             Daily at $($Global:ScheduleStartHour):00 ($Global:ScheduleTimeZone)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "License SKU:" -ForegroundColor Yellow
    Write-Host "  Teams Premium:        $Global:TeamsPremiumSkuId" -ForegroundColor White
    Write-Host ""
    
    Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✓ Configuration loaded successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "  1. Keep this PowerShell session open" -ForegroundColor White
    Write-Host "  2. Proceed to Step 1: Environment Preparation" -ForegroundColor White
    Write-Host ""
    
    $Global:ConfigurationValid = $true
}

# ------------------------------------------------------------------------------
# HELPER FUNCTION: Get Azure REST API Headers
# ------------------------------------------------------------------------------

function Get-AzureHeaders {
    <#
    .SYNOPSIS
        Gets authorization headers for Azure REST API calls
    .DESCRIPTION
        Returns headers with current access token for Azure management API
    #>
    
    $token = Get-AzAccessToken -ResourceUrl "https://management.azure.com"
    return @{
        "Authorization" = "Bearer $($token.Token)"
        "Content-Type"  = "application/json"
    }
}

# Export for use in subsequent steps
$Global:GetAzureHeaders = ${function:Get-AzureHeaders}

# ------------------------------------------------------------------------------
# HELPER FUNCTION: Update Runtime Variables
# ------------------------------------------------------------------------------

function Set-RuntimeVariable {
    <#
    .SYNOPSIS
        Updates runtime variables during deployment
    .PARAMETER Name
        Variable name (e.g., "DceLogsIngestionUri")
    .PARAMETER Value
        Variable value
    #>
    param(
        [string]$Name,
        [string]$Value
    )
    
    Set-Variable -Name $Name -Value $Value -Scope Global
    
    # Also update Config hashtable
    if ($Global:Config.ContainsKey($Name)) {
        $Global:Config[$Name] = $Value
    }
    else {
        $Global:Config.Add($Name, $Value)
    }
}

$Global:SetRuntimeVariable = ${function:Set-RuntimeVariable}

Write-Host "Helper functions loaded: Get-AzureHeaders, Set-RuntimeVariable" -ForegroundColor Gray
Write-Host ""
```

### 0.2 Run the Configuration Script

```powershell
# Navigate to your scripts directory
cd C:\Scripts\TeamsPremiumLicenseSync

# Run the configuration script
.\Set-DeploymentConfig.ps1

# Verify configuration is valid
if ($Global:ConfigurationValid -eq $true) {
    Write-Host "Ready to proceed with deployment!" -ForegroundColor Green
}
else {
    Write-Host "Please fix configuration errors before proceeding." -ForegroundColor Red
}
```

### 0.3 Quick Reference: Configuration Variables

After running the configuration script, these global variables are available in your session:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `$Global:SubscriptionId` | Azure Subscription ID | `12345678-1234-1234-1234-123456789012` |
| `$Global:ResourceGroupName` | Resource Group name | `rg-m365-security` |
| `$Global:Location` | Azure region | `canadacentral` |
| `$Global:WorkspaceName` | Log Analytics Workspace | `law-m365-security` |
| `$Global:FullTableName` | Custom table name | `TeamsPremiumLicenses_CL` |
| `$Global:DceName` | Data Collection Endpoint | `DCE-TeamsPremiumLicenses` |
| `$Global:DcrName` | Data Collection Rule | `DCR-TeamsPremiumLicenses` |
| `$Global:StreamName` | DCR stream name | `Custom-TeamsPremiumLicenses_CL` |
| `$Global:AutomationAccountName` | Automation Account | `AA-TeamsPremiumLicenseSync` |
| `$Global:RunbookName` | Runbook name | `Sync-TeamsPremiumLicenses` |
| `$Global:TeamsPremiumSkuId` | Teams Premium SKU ID | `36a0f3b3-adb5-49ea-bf66-762134cf063a` |

**Runtime Variables** (populated during deployment):

| Variable | Populated In | Description |
|----------|--------------|-------------|
| `$Global:WorkspaceResourceId` | Step 2 | Full ARM resource ID of workspace |
| `$Global:DceResourceId` | Step 3 | Full ARM resource ID of DCE |
| `$Global:DceLogsIngestionUri` | Step 3 | Logs ingestion endpoint URL |
| `$Global:DcrResourceId` | Step 4 | Full ARM resource ID of DCR |
| `$Global:DcrImmutableId` | Step 4 | Immutable ID for DCR (used in runbook) |
| `$Global:AutomationAccountPrincipalId` | Step 5 | Managed Identity Object ID |

---

## Step 1: Environment Preparation

### 1.1 Module Check and Installation Script

Create and run this script to ensure all required modules are installed:

```powershell
<#
.SYNOPSIS
    Teams Premium License Sync - Module Installation Script
.DESCRIPTION
    Checks for and installs required PowerShell modules for the 
    Teams Premium License Sync solution.
.NOTES
    Run as Administrator for machine-wide installation
    Run as current user for user-scope installation
#>

#Requires -Version 5.1

# ============================================
# CONFIGURATION
# ============================================

$RequiredModules = @(
    @{
        Name           = "Az.Accounts"
        MinimumVersion = "2.12.0"
        Description    = "Azure authentication and account management"
    },
    @{
        Name           = "Az.Resources"
        MinimumVersion = "6.0.0"
        Description    = "Azure resource management (RBAC, resource groups)"
    },
    @{
        Name           = "Az.OperationalInsights"
        MinimumVersion = "3.0.0"
        Description    = "Log Analytics workspace management"
    },
    @{
        Name           = "Az.Automation"
        MinimumVersion = "1.9.0"
        Description    = "Azure Automation account and runbook management"
    },
    @{
        Name           = "Az.Monitor"
        MinimumVersion = "4.0.0"
        Description    = "Data Collection Rules and Endpoints"
    },
    @{
        Name           = "Microsoft.Graph.Authentication"
        MinimumVersion = "2.0.0"
        Description    = "Microsoft Graph authentication"
    },
    @{
        Name           = "Microsoft.Graph.Users"
        MinimumVersion = "2.0.0"
        Description    = "Microsoft Graph user operations"
    },
    @{
        Name           = "Microsoft.Graph.Applications"
        MinimumVersion = "2.0.0"
        Description    = "Microsoft Graph application/service principal operations"
    }
)

# ============================================
# FUNCTIONS
# ============================================

function Write-LogMessage {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "Info"    { "Cyan" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
    }
    
    Write-Host "[$timestamp] " -NoNewline -ForegroundColor Gray
    Write-Host "[$Level] " -NoNewline -ForegroundColor $color
    Write-Host $Message
}

function Test-ModuleInstalled {
    param(
        [string]$ModuleName,
        [string]$MinimumVersion
    )
    
    $module = Get-Module -ListAvailable -Name $ModuleName | 
              Sort-Object Version -Descending | 
              Select-Object -First 1
    
    if ($null -eq $module) {
        return @{ Installed = $false; Version = $null }
    }
    
    $versionOk = [Version]$module.Version -ge [Version]$MinimumVersion
    return @{ Installed = $versionOk; Version = $module.Version }
}

function Install-RequiredModule {
    param(
        [string]$ModuleName,
        [string]$MinimumVersion
    )
    
    try {
        Write-LogMessage "Installing $ModuleName (minimum version: $MinimumVersion)..." -Level Info
        
        Install-Module -Name $ModuleName `
                       -MinimumVersion $MinimumVersion `
                       -Scope CurrentUser `
                       -AllowClobber `
                       -Force `
                       -Repository PSGallery
        
        Write-LogMessage "$ModuleName installed successfully" -Level Success
        return $true
    }
    catch {
        Write-LogMessage "Failed to install $ModuleName : $_" -Level Error
        return $false
    }
}

# ============================================
# MAIN EXECUTION
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Teams Premium License Sync            " -ForegroundColor Cyan
Write-Host " Module Installation Script            " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
Write-LogMessage "PowerShell Version: $($PSVersionTable.PSVersion)" -Level Info

# Check execution policy
$execPolicy = Get-ExecutionPolicy -Scope CurrentUser
Write-LogMessage "Execution Policy (CurrentUser): $execPolicy" -Level Info

if ($execPolicy -eq "Restricted") {
    Write-LogMessage "Execution policy is Restricted. Please run:" -Level Warning
    Write-LogMessage "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -Level Warning
    return
}

# Set TLS 1.2 for PowerShell Gallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Register PSGallery if needed
$psGallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($null -eq $psGallery) {
    Write-LogMessage "Registering PSGallery repository..." -Level Info
    Register-PSRepository -Default
}

# Trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Check and install NuGet provider
$nuget = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if ($null -eq $nuget -or $nuget.Version -lt [Version]"2.8.5.201") {
    Write-LogMessage "Installing NuGet package provider..." -Level Info
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
}

Write-Host ""
Write-LogMessage "Checking required modules..." -Level Info
Write-Host ""

# Track results
$results = @()

foreach ($module in $RequiredModules) {
    $check = Test-ModuleInstalled -ModuleName $module.Name -MinimumVersion $module.MinimumVersion
    
    if ($check.Installed) {
        Write-LogMessage "$($module.Name) v$($check.Version) - OK" -Level Success
        $results += @{
            Module  = $module.Name
            Status  = "Installed"
            Version = $check.Version
        }
    }
    else {
        if ($check.Version) {
            Write-LogMessage "$($module.Name) v$($check.Version) - Upgrade needed (min: $($module.MinimumVersion))" -Level Warning
        }
        else {
            Write-LogMessage "$($module.Name) - Not installed" -Level Warning
        }
        
        $installed = Install-RequiredModule -ModuleName $module.Name -MinimumVersion $module.MinimumVersion
        
        $results += @{
            Module  = $module.Name
            Status  = if ($installed) { "Installed" } else { "Failed" }
            Version = $module.MinimumVersion
        }
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Installation Summary                  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$failed = $results | Where-Object { $_.Status -eq "Failed" }

if ($failed.Count -eq 0) {
    Write-LogMessage "All modules installed successfully!" -Level Success
    Write-Host ""
    Write-LogMessage "You can now proceed with the deployment steps." -Level Info
}
else {
    Write-LogMessage "Some modules failed to install:" -Level Error
    foreach ($f in $failed) {
        Write-LogMessage "  - $($f.Module)" -Level Error
    }
    Write-Host ""
    Write-LogMessage "Please resolve these issues before proceeding." -Level Warning
}

Write-Host ""
```

### 1.2 Run the Module Installation

```powershell
# Save the above script as: Install-RequiredModules.ps1
# Then run:
.\Install-RequiredModules.ps1
```

### 1.3 Authenticate to Azure and Microsoft Graph

```powershell
# ============================================
# Authenticate to Azure (if not already done in Step 0)
# ============================================

# Check if already connected
$context = Get-AzContext
if ($null -eq $context) {
    Connect-AzAccount
}

# Verify correct subscription is selected
if ($context.Subscription.Id -ne $Global:SubscriptionId) {
    Write-Host "Switching to configured subscription..." -ForegroundColor Yellow
    Set-AzContext -SubscriptionId $Global:SubscriptionId | Out-Null
}

# Display current context
$context = Get-AzContext
Write-Host "Connected to Azure:" -ForegroundColor Green
Write-Host "  Account:      $($context.Account.Id)" -ForegroundColor White
Write-Host "  Subscription: $($context.Subscription.Name)" -ForegroundColor White
Write-Host "  Tenant:       $($context.Tenant.Id)" -ForegroundColor White

# ============================================
# Authenticate to Microsoft Graph
# ============================================
# Required scopes for this deployment
$GraphScopes = @(
    "User.Read.All",
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All"
)

Connect-MgGraph -Scopes $GraphScopes -NoWelcome

# Verify connection
$mgContext = Get-MgContext
Write-Host ""
Write-Host "Connected to Microsoft Graph:" -ForegroundColor Green
Write-Host "  Account:  $($mgContext.Account)" -ForegroundColor White
Write-Host "  Tenant:   $($mgContext.TenantId)" -ForegroundColor White
```

---

## Step 2: Create Log Analytics Custom Table

### 2.1 Verify Configuration and Connect

```powershell
<#
.SYNOPSIS
    Step 2: Create Log Analytics Custom Table
.DESCRIPTION
    Creates the TeamsPremiumLicenses_CL custom table in Log Analytics
.NOTES
    Requires: Step 0 configuration loaded, Azure authentication
#>

# Verify configuration is loaded
if ($null -eq $Global:Config -or $Global:ConfigurationValid -ne $true) {
    Write-Error "Configuration not loaded. Please run Set-DeploymentConfig.ps1 first."
    return
}

# Verify Azure connection
$context = Get-AzContext
if ($null -eq $context) {
    Write-Host "Not connected to Azure. Connecting now..." -ForegroundColor Yellow
    Connect-AzAccount
    Set-AzContext -SubscriptionId $Global:SubscriptionId
}
elseif ($context.Subscription.Id -ne $Global:SubscriptionId) {
    Write-Host "Switching to configured subscription..." -ForegroundColor Yellow
    Set-AzContext -SubscriptionId $Global:SubscriptionId
}

Write-Host "Connected to subscription: $($context.Subscription.Name)" -ForegroundColor Green
```

### 2.2 Create the Custom Table

```powershell
# ============================================
# Get Log Analytics Workspace
# ============================================

$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $Global:ResourceGroupName `
    -Name $Global:WorkspaceName `
    -ErrorAction SilentlyContinue

if ($null -eq $workspace) {
    Write-Host "ERROR: Workspace '$($Global:WorkspaceName)' not found in resource group '$($Global:ResourceGroupName)'" -ForegroundColor Red
    Write-Host "Please verify the workspace name and resource group in Step 0 configuration." -ForegroundColor Yellow
    return
}

Write-Host "Found workspace: $($workspace.Name)" -ForegroundColor Green
Write-Host "  Resource ID: $($workspace.ResourceId)" -ForegroundColor Gray
Write-Host "  Location: $($workspace.Location)" -ForegroundColor Gray

# Store for later steps
Set-RuntimeVariable -Name "WorkspaceResourceId" -Value $workspace.ResourceId
Set-RuntimeVariable -Name "WorkspaceId" -Value $workspace.CustomerId

# ============================================
# Force Fresh Azure Authentication
# ============================================

Write-Host ""
Write-Host "Ensuring fresh Azure authentication..." -ForegroundColor Yellow

# Show current context
$currentContext = Get-AzContext
Write-Host "  Current Account: $($currentContext.Account.Id)" -ForegroundColor Gray
Write-Host "  Current Subscription: $($currentContext.Subscription.Name)" -ForegroundColor Gray
Write-Host "  Current Tenant: $($currentContext.Tenant.Id)" -ForegroundColor Gray

# Clear token cache and re-authenticate
Write-Host ""
Write-Host "  Clearing token cache and re-authenticating..." -ForegroundColor Yellow

try {
    # Disconnect and reconnect to force fresh tokens
    Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
    
    # Reconnect with explicit subscription
    $reconnectResult = Connect-AzAccount -Subscription $Global:SubscriptionId -ErrorAction Stop
    
    Write-Host "  ✓ Re-authenticated as: $($reconnectResult.Context.Account.Id)" -ForegroundColor Green
}
catch {
    Write-Host "  Auto-reconnect failed. Please authenticate manually:" -ForegroundColor Yellow
    Connect-AzAccount
    Set-AzContext -SubscriptionId $Global:SubscriptionId | Out-Null
}

# Get fresh token
$tokenResponse = Get-AzAccessToken -ResourceUrl "https://management.azure.com"
Write-Host "  ✓ Token acquired, expires: $($tokenResponse.ExpiresOn)" -ForegroundColor Green

# Build headers with fresh token
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.Token)"
    "Content-Type"  = "application/json"
}

# ============================================
# Create Custom Table using REST API
# ============================================

$tableResourceId = "$($workspace.ResourceId)/tables/$($Global:FullTableName)"

Write-Host ""
Write-Host "Building table request..." -ForegroundColor Yellow
Write-Host "  Table: $($Global:FullTableName)" -ForegroundColor Gray

$tableDefinition = @{
    properties = @{
        schema = @{
            name    = $Global:FullTableName
            columns = @(
                @{ name = "TimeGenerated"; type = "datetime"; description = "Timestamp of the sync" }
                @{ name = "UserPrincipalName"; type = "string"; description = "User's UPN" }
                @{ name = "DisplayName"; type = "string"; description = "User's display name" }
                @{ name = "LicenseAssigned"; type = "boolean"; description = "Whether Teams Premium is assigned" }
                @{ name = "ObjectId"; type = "string"; description = "User's Entra Object ID" }
            )
        }
        retentionInDays      = $Global:TableRetentionDays
        totalRetentionInDays = $Global:TableTotalRetention
    }
}

$tableBody = $tableDefinition | ConvertTo-Json -Depth 10
$apiVersion = "2022-10-01"
$uri = "https://management.azure.com$($tableResourceId)?api-version=$apiVersion"

Write-Host ""
Write-Host "Creating custom table: $($Global:FullTableName)..." -ForegroundColor Yellow

try {
    # Method 1: Try using Invoke-AzRestMethod (uses Az module's built-in auth)
    Write-Host "  Attempting with Invoke-AzRestMethod..." -ForegroundColor Gray
    
    $restResult = Invoke-AzRestMethod `
        -Path "$($tableResourceId)?api-version=$apiVersion" `
        -Method PUT `
        -Payload $tableBody `
        -ErrorAction Stop
    
    if ($restResult.StatusCode -in @(200, 201)) {
        $response = $restResult.Content | ConvertFrom-Json
        Write-Host ""
        Write-Host "Custom table created successfully!" -ForegroundColor Green
        Write-Host "  Table Name: $($response.name)" -ForegroundColor Gray
        Write-Host "  Retention: $($response.properties.retentionInDays) days" -ForegroundColor Gray
    }
    elseif ($restResult.StatusCode -eq 409) {
        Write-Host ""
        Write-Host "Table already exists - continuing..." -ForegroundColor Yellow
    }
    else {
        Write-Host ""
        Write-Host "Unexpected response: $($restResult.StatusCode)" -ForegroundColor Yellow
        Write-Host $restResult.Content -ForegroundColor Gray
    }
}
catch {
    $errorMsg = $_.Exception.Message
    
    if ($errorMsg -like "*Conflict*" -or $errorMsg -like "*409*") {
        Write-Host ""
        Write-Host "Table already exists - continuing..." -ForegroundColor Yellow
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Failed to create table" -ForegroundColor Red
        Write-Host "  Error: $errorMsg" -ForegroundColor Red
        
        # Try to get more details
        if ($_.ErrorDetails.Message) {
            Write-Host "  Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "Manual Alternative - Run this in Azure Cloud Shell:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "az monitor log-analytics workspace table create \" -ForegroundColor Cyan
        Write-Host "  --resource-group `"$($Global:ResourceGroupName)`" \" -ForegroundColor Cyan
        Write-Host "  --workspace-name `"$($Global:WorkspaceName)`" \" -ForegroundColor Cyan
        Write-Host "  --name `"$($Global:FullTableName)`" \" -ForegroundColor Cyan
        Write-Host "  --retention-time $($Global:TableRetentionDays) \" -ForegroundColor Cyan
        Write-Host "  --columns TimeGenerated=datetime UserPrincipalName=string DisplayName=string LicenseAssigned=boolean ObjectId=string" -ForegroundColor Cyan
        Write-Host ""
        
        return
    }
}
```

---

## Step 3: Create Data Collection Endpoint (DCE)

```powershell
<#
.SYNOPSIS
    Step 3: Create Data Collection Endpoint
.DESCRIPTION
    Creates the DCE for log ingestion
.NOTES
    Requires: Step 0 configuration loaded, Step 2 completed
#>

# Verify configuration
if ($null -eq $Global:WorkspaceResourceId) {
    Write-Host "ERROR: WorkspaceResourceId not set. Please complete Step 2 first." -ForegroundColor Red
    return
}

# ============================================
# Create Data Collection Endpoint
# ============================================

Write-Host "Creating Data Collection Endpoint..." -ForegroundColor Yellow
Write-Host "  Name: $($Global:DceName)" -ForegroundColor Gray
Write-Host "  Location: $($Global:Location)" -ForegroundColor Gray

$dceResourcePath = "/subscriptions/$($Global:SubscriptionId)/resourceGroups/$($Global:ResourceGroupName)/providers/Microsoft.Insights/dataCollectionEndpoints/$($Global:DceName)"

$dceDefinition = @{
    location   = $Global:Location
    properties = @{
        description           = "DCE for Teams Premium License data ingestion"
        networkAcls           = @{
            publicNetworkAccess = "Enabled"
        }
    }
}

$dceBody = $dceDefinition | ConvertTo-Json -Depth 10

try {
    Write-Host ""
    Write-Host "  Sending request..." -ForegroundColor Gray
    
    $restResult = Invoke-AzRestMethod `
        -Path "$($dceResourcePath)?api-version=2022-06-01" `
        -Method PUT `
        -Payload $dceBody `
        -ErrorAction Stop
    
    if ($restResult.StatusCode -in @(200, 201)) {
        $dceResponse = $restResult.Content | ConvertFrom-Json
        
        Write-Host ""
        Write-Host "Data Collection Endpoint created successfully!" -ForegroundColor Green
        Write-Host "  Name: $($dceResponse.name)" -ForegroundColor Gray
        Write-Host "  Logs Ingestion URI: $($dceResponse.properties.logsIngestion.endpoint)" -ForegroundColor Cyan
        
        # Store for later
        Set-RuntimeVariable -Name "DceLogsIngestionUri" -Value $dceResponse.properties.logsIngestion.endpoint
        Set-RuntimeVariable -Name "DceResourceId" -Value $dceResponse.id
    }
    elseif ($restResult.StatusCode -eq 409) {
        Write-Host ""
        Write-Host "DCE already exists - retrieving details..." -ForegroundColor Yellow
        
        # Get existing DCE
        $getResult = Invoke-AzRestMethod `
            -Path "$($dceResourcePath)?api-version=2022-06-01" `
            -Method GET
        
        $dceResponse = $getResult.Content | ConvertFrom-Json
        Set-RuntimeVariable -Name "DceLogsIngestionUri" -Value $dceResponse.properties.logsIngestion.endpoint
        Set-RuntimeVariable -Name "DceResourceId" -Value $dceResponse.id
        Write-Host "  Logs Ingestion URI: $($Global:DceLogsIngestionUri)" -ForegroundColor Cyan
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Unexpected response: $($restResult.StatusCode)" -ForegroundColor Red
        Write-Host $restResult.Content -ForegroundColor Red
        return
    }
}
catch {
    if ($_.Exception.Message -like "*Conflict*" -or $_.Exception.Message -like "*409*") {
        Write-Host ""
        Write-Host "DCE already exists - retrieving details..." -ForegroundColor Yellow
        
        $getResult = Invoke-AzRestMethod `
            -Path "$($dceResourcePath)?api-version=2022-06-01" `
            -Method GET
        
        $dceResponse = $getResult.Content | ConvertFrom-Json
        Set-RuntimeVariable -Name "DceLogsIngestionUri" -Value $dceResponse.properties.logsIngestion.endpoint
        Set-RuntimeVariable -Name "DceResourceId" -Value $dceResponse.id
        Write-Host "  Logs Ingestion URI: $($Global:DceLogsIngestionUri)" -ForegroundColor Cyan
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Failed to create DCE" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.ErrorDetails.Message) {
            Write-Host "  Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        return
    }
}

Write-Host ""
Write-Host "=== IMPORTANT: Runtime Variable Set ===" -ForegroundColor Magenta
Write-Host "DCE Logs Ingestion URI: $Global:DceLogsIngestionUri" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Magenta
```

---

## Step 4: Create Data Collection Rule (DCR)

```powershell
<#
.SYNOPSIS
    Step 4: Create Data Collection Rule
.DESCRIPTION
    Creates the DCR that defines data transformation and routing
.NOTES
    Requires: Step 0 configuration loaded, Steps 2-3 completed
#>

# Verify prerequisites
if ($null -eq $Global:DceResourceId) {
    Write-Host "ERROR: DceResourceId not set. Please complete Step 3 first." -ForegroundColor Red
    return
}

# ============================================
# Create Data Collection Rule
# ============================================

Write-Host "Creating Data Collection Rule..." -ForegroundColor Yellow
Write-Host "  Name: $($Global:DcrName)" -ForegroundColor Gray
Write-Host "  Stream: $($Global:StreamName)" -ForegroundColor Gray

$dcrResourcePath = "/subscriptions/$($Global:SubscriptionId)/resourceGroups/$($Global:ResourceGroupName)/providers/Microsoft.Insights/dataCollectionRules/$($Global:DcrName)"

$dcrDefinition = @{
    location   = $Global:Location
    properties = @{
        description              = "DCR for Teams Premium License sync"
        dataCollectionEndpointId = $Global:DceResourceId
        streamDeclarations       = @{
            "$($Global:StreamName)" = @{
                columns = @(
                    @{ name = "TimeGenerated"; type = "datetime" }
                    @{ name = "UserPrincipalName"; type = "string" }
                    @{ name = "DisplayName"; type = "string" }
                    @{ name = "LicenseAssigned"; type = "boolean" }
                    @{ name = "ObjectId"; type = "string" }
                )
            }
        }
        destinations             = @{
            logAnalytics = @(
                @{
                    workspaceResourceId = $Global:WorkspaceResourceId
                    name                = "LogAnalyticsDestination"
                }
            )
        }
        dataFlows                = @(
            @{
                streams      = @($Global:StreamName)
                destinations = @("LogAnalyticsDestination")
                transformKql = "source"
                outputStream = $Global:StreamName
            }
        )
    }
}

$dcrBody = $dcrDefinition | ConvertTo-Json -Depth 10

try {
    Write-Host ""
    Write-Host "  Sending request..." -ForegroundColor Gray
    
    $restResult = Invoke-AzRestMethod `
        -Path "$($dcrResourcePath)?api-version=2022-06-01" `
        -Method PUT `
        -Payload $dcrBody `
        -ErrorAction Stop
    
    if ($restResult.StatusCode -in @(200, 201)) {
        $dcrResponse = $restResult.Content | ConvertFrom-Json
        
        Write-Host ""
        Write-Host "Data Collection Rule created successfully!" -ForegroundColor Green
        Write-Host "  Name: $($dcrResponse.name)" -ForegroundColor Gray
        Write-Host "  Immutable ID: $($dcrResponse.properties.immutableId)" -ForegroundColor Cyan
        
        # Store for later
        Set-RuntimeVariable -Name "DcrImmutableId" -Value $dcrResponse.properties.immutableId
        Set-RuntimeVariable -Name "DcrResourceId" -Value $dcrResponse.id
    }
    elseif ($restResult.StatusCode -eq 409) {
        Write-Host ""
        Write-Host "DCR already exists - retrieving details..." -ForegroundColor Yellow
        
        $getResult = Invoke-AzRestMethod `
            -Path "$($dcrResourcePath)?api-version=2022-06-01" `
            -Method GET
        
        $dcrResponse = $getResult.Content | ConvertFrom-Json
        Set-RuntimeVariable -Name "DcrImmutableId" -Value $dcrResponse.properties.immutableId
        Set-RuntimeVariable -Name "DcrResourceId" -Value $dcrResponse.id
        Write-Host "  Immutable ID: $($Global:DcrImmutableId)" -ForegroundColor Cyan
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Unexpected response: $($restResult.StatusCode)" -ForegroundColor Red
        Write-Host $restResult.Content -ForegroundColor Red
        return
    }
}
catch {
    if ($_.Exception.Message -like "*Conflict*" -or $_.Exception.Message -like "*409*") {
        Write-Host ""
        Write-Host "DCR already exists - retrieving details..." -ForegroundColor Yellow
        
        $getResult = Invoke-AzRestMethod `
            -Path "$($dcrResourcePath)?api-version=2022-06-01" `
            -Method GET
        
        $dcrResponse = $getResult.Content | ConvertFrom-Json
        Set-RuntimeVariable -Name "DcrImmutableId" -Value $dcrResponse.properties.immutableId
        Set-RuntimeVariable -Name "DcrResourceId" -Value $dcrResponse.id
        Write-Host "  Immutable ID: $($Global:DcrImmutableId)" -ForegroundColor Cyan
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Failed to create DCR" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.ErrorDetails.Message) {
            Write-Host "  Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        return
    }
}

Write-Host ""
Write-Host "=== IMPORTANT: Runtime Variables Set ===" -ForegroundColor Magenta
Write-Host "DCR Immutable ID: $Global:DcrImmutableId" -ForegroundColor White
Write-Host "Stream Name: $($Global:StreamName)" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor Magenta
```

---

## Step 5: Create Azure Automation Account

```powershell
<#
.SYNOPSIS
    Step 5: Create Azure Automation Account
.DESCRIPTION
    Creates an Automation Account with System-Assigned Managed Identity
.NOTES
    Requires: Step 0 configuration loaded
#>

# ============================================
# Create Automation Account
# ============================================

Write-Host "Creating Azure Automation Account..." -ForegroundColor Yellow
Write-Host "  Name: $($Global:AutomationAccountName)" -ForegroundColor Gray
Write-Host "  Location: $($Global:Location)" -ForegroundColor Gray

try {
    $automationAccount = Get-AzAutomationAccount `
        -ResourceGroupName $Global:ResourceGroupName `
        -Name $Global:AutomationAccountName `
        -ErrorAction SilentlyContinue
    
    if ($automationAccount) {
        Write-Host "  Automation Account already exists" -ForegroundColor Yellow
    }
    else {
        Write-Host "  Creating new Automation Account..." -ForegroundColor Gray
        
        $automationAccount = New-AzAutomationAccount `
            -ResourceGroupName $Global:ResourceGroupName `
            -Name $Global:AutomationAccountName `
            -Location $Global:Location `
            -AssignSystemIdentity
        
        Write-Host "  ✓ Automation Account created" -ForegroundColor Green
    }
    
    # Ensure System-Assigned Managed Identity is enabled using Invoke-AzRestMethod
    Write-Host ""
    Write-Host "  Ensuring System-Assigned Managed Identity is enabled..." -ForegroundColor Yellow
    
    $aaResourcePath = "/subscriptions/$($Global:SubscriptionId)/resourceGroups/$($Global:ResourceGroupName)/providers/Microsoft.Automation/automationAccounts/$($Global:AutomationAccountName)"
    
    # Get current state
    $getResult = Invoke-AzRestMethod `
        -Path "$($aaResourcePath)?api-version=2023-11-01" `
        -Method GET
    
    $aaResponse = $getResult.Content | ConvertFrom-Json
    
    if ($null -eq $aaResponse.identity -or $aaResponse.identity.type -ne "SystemAssigned") {
        Write-Host "  Enabling System-Assigned Managed Identity..." -ForegroundColor Yellow
        
        $identityPayload = @{
            identity = @{
                type = "SystemAssigned"
            }
        } | ConvertTo-Json
        
        $patchResult = Invoke-AzRestMethod `
            -Path "$($aaResourcePath)?api-version=2023-11-01" `
            -Method PATCH `
            -Payload $identityPayload
        
        $aaResponse = $patchResult.Content | ConvertFrom-Json
        Write-Host "  ✓ Managed Identity enabled" -ForegroundColor Green
    }
    else {
        Write-Host "  ✓ Managed Identity already enabled" -ForegroundColor Green
    }
    
    Set-RuntimeVariable -Name "AutomationAccountPrincipalId" -Value $aaResponse.identity.principalId
    
    Write-Host ""
    Write-Host "  Name: $($Global:AutomationAccountName)" -ForegroundColor Gray
    Write-Host "  Managed Identity Object ID: $Global:AutomationAccountPrincipalId" -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "ERROR: Failed to create Automation Account" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "=== IMPORTANT: Runtime Variable Set ===" -ForegroundColor Magenta
Write-Host "Managed Identity Object ID: $Global:AutomationAccountPrincipalId" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Magenta
```

---

## Step 6: Configure Managed Identity Permissions

### 6.1 Assign Microsoft Graph API Permissions

```powershell
<#
.SYNOPSIS
    Step 6.1: Assign Graph API Permissions to Managed Identity
.DESCRIPTION
    Grants User.Read.All permission to the Automation Account's Managed Identity
.NOTES
    Requires: Global Administrator or Privileged Role Administrator
    Requires: Step 5 completed (AutomationAccountPrincipalId set)
#>

# Verify prerequisites
if ($null -eq $Global:AutomationAccountPrincipalId) {
    Write-Error "AutomationAccountPrincipalId not set. Please complete Step 5 first."
    return
}

# Ensure connected to Microsoft Graph with required scopes
$mgContext = Get-MgContext
if ($null -eq $mgContext) {
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
    Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"
}

Write-Host "Assigning Microsoft Graph permissions..." -ForegroundColor Yellow

# Microsoft Graph App ID (constant)
$GraphAppId = "00000003-0000-0000-c000-000000000000"

# Get the Microsoft Graph Service Principal
$graphSP = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"

if ($null -eq $graphSP) {
    Write-Error "Microsoft Graph service principal not found"
    return
}

# Define required permissions
$requiredPermissions = @(
    @{
        Name        = "User.Read.All"
        Description = "Read all users' full profiles"
    }
)

foreach ($permission in $requiredPermissions) {
    $appRole = $graphSP.AppRoles | Where-Object { $_.Value -eq $permission.Name }
    
    if ($null -eq $appRole) {
        Write-Warning "Permission '$($permission.Name)' not found in Microsoft Graph"
        continue
    }
    
    # Check if already assigned
    $existingAssignment = Get-MgServicePrincipalAppRoleAssignment `
        -ServicePrincipalId $Global:AutomationAccountPrincipalId `
        -ErrorAction SilentlyContinue | 
        Where-Object { $_.AppRoleId -eq $appRole.Id }
    
    if ($existingAssignment) {
        Write-Host "  $($permission.Name) - Already assigned" -ForegroundColor Gray
    }
    else {
        try {
            New-MgServicePrincipalAppRoleAssignment `
                -ServicePrincipalId $Global:AutomationAccountPrincipalId `
                -PrincipalId $Global:AutomationAccountPrincipalId `
                -ResourceId $graphSP.Id `
                -AppRoleId $appRole.Id | Out-Null
            
            Write-Host "  $($permission.Name) - Assigned successfully" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to assign $($permission.Name): $_"
        }
    }
}

Write-Host "Graph API permissions configured!" -ForegroundColor Green
```

### 6.2 Assign Azure RBAC Permissions

```powershell
<#
.SYNOPSIS
    Step 6.2: Assign Azure RBAC Permissions
.DESCRIPTION
    Grants Monitoring Metrics Publisher role on the DCR to the Managed Identity
.NOTES
    Requires: Steps 4 and 5 completed
#>

# Verify prerequisites
if ($null -eq $Global:DcrResourceId) {
    Write-Error "DcrResourceId not set. Please complete Step 4 first."
    return
}

Write-Host "Assigning Azure RBAC permissions..." -ForegroundColor Yellow

# Assign "Monitoring Metrics Publisher" role on the DCR
$roleDefinitionName = "Monitoring Metrics Publisher"

try {
    $existingAssignment = Get-AzRoleAssignment `
        -ObjectId $Global:AutomationAccountPrincipalId `
        -Scope $Global:DcrResourceId `
        -RoleDefinitionName $roleDefinitionName `
        -ErrorAction SilentlyContinue
    
    if ($existingAssignment) {
        Write-Host "  $roleDefinitionName on DCR - Already assigned" -ForegroundColor Gray
    }
    else {
        New-AzRoleAssignment `
            -ObjectId $Global:AutomationAccountPrincipalId `
            -Scope $Global:DcrResourceId `
            -RoleDefinitionName $roleDefinitionName | Out-Null
        
        Write-Host "  $roleDefinitionName on DCR - Assigned successfully" -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to assign RBAC role: $_"
    return
}

Write-Host "Azure RBAC permissions configured!" -ForegroundColor Green
```

---

## Step 7: Create and Configure the Runbook

### 7.1 Create the Runbook Script

Save this as `Sync-TeamsPremiumLicenses.ps1`:

```powershell
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
```

### 7.2 Deploy the Runbook

```powershell
<#
.SYNOPSIS
    Step 7.2: Deploy the Runbook to Azure Automation
.DESCRIPTION
    Creates the runbook and imports the script with configuration values
.NOTES
    Requires: Steps 3-5 completed (DCE, DCR, Automation Account created)
#>

# Verify prerequisites
if ($null -eq $Global:DceLogsIngestionUri -or $null -eq $Global:DcrImmutableId) {
    Write-Error "DCE or DCR not configured. Please complete Steps 3 and 4 first."
    return
}

# ============================================
# Prepare Runbook Script with Configuration
# ============================================

Write-Host "Preparing runbook script with configuration values..." -ForegroundColor Yellow

$runbookContent = @"
<#
.SYNOPSIS
    Teams Premium License Sync Runbook
.DESCRIPTION
    Queries Microsoft Graph for Teams Premium license assignments
    and ingests the data into Log Analytics via DCR
.NOTES
    Runs in Azure Automation with System-Assigned Managed Identity
    Requires: User.Read.All Graph permission, Monitoring Metrics Publisher on DCR
#>

# ============================================
# CONFIGURATION
# ============================================

`$DceUri = "$($Global:DceLogsIngestionUri)"
`$DcrImmutableId = "$($Global:DcrImmutableId)"
`$StreamName = "$($Global:StreamName)"
`$TeamsPremiumSkuId = "$($Global:TeamsPremiumSkuId)"

# ============================================
# AUTHENTICATION
# ============================================

Write-Output "Starting Teams Premium License Sync..."
Write-Output "Timestamp: `$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"

try {
    Write-Output "Authenticating with Managed Identity..."
    Connect-AzAccount -Identity | Out-Null
    
    `$graphToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
    `$monitorToken = (Get-AzAccessToken -ResourceUrl "https://monitor.azure.com").Token
    
    Write-Output "Authentication successful"
}
catch {
    Write-Error "Authentication failed: `$_"
    throw
}

# ============================================
# QUERY MICROSOFT GRAPH
# ============================================

Write-Output "Querying Microsoft Graph for user licenses..."

`$graphHeaders = @{
    "Authorization" = "Bearer `$graphToken"
    "Content-Type"  = "application/json"
    "ConsistencyLevel" = "eventual"
}

`$users = @()
`$uri = "https://graph.microsoft.com/v1.0/users?```$select=id,userPrincipalName,displayName,assignedLicenses&```$top=999"

try {
    do {
        `$response = Invoke-RestMethod -Uri `$uri -Headers `$graphHeaders -Method Get
        `$users += `$response.value
        `$uri = `$response.'@odata.nextLink'
        
        if (`$users.Count % 1000 -eq 0) {
            Write-Output "  Retrieved `$(`$users.Count) users..."
        }
    } while (`$uri)
    
    Write-Output "Total users retrieved: `$(`$users.Count)"
}
catch {
    Write-Error "Failed to query Microsoft Graph: `$_"
    throw
}

# ============================================
# FILTER TEAMS PREMIUM USERS
# ============================================

Write-Output "Filtering Teams Premium license holders..."

`$teamsPremiumUsers = `$users | Where-Object {
    `$_.assignedLicenses.skuId -contains `$TeamsPremiumSkuId
}

Write-Output "Users with Teams Premium: `$(`$teamsPremiumUsers.Count)"

if (`$teamsPremiumUsers.Count -eq 0) {
    Write-Output "No Teams Premium users found. Exiting."
    return
}

# ============================================
# BUILD LOG PAYLOAD
# ============================================

Write-Output "Building log ingestion payload..."

`$currentTime = (Get-Date).ToUniversalTime().ToString("o")

`$logData = `$teamsPremiumUsers | ForEach-Object {
    @{
        TimeGenerated     = `$currentTime
        UserPrincipalName = `$_.userPrincipalName
        DisplayName       = `$_.displayName
        LicenseAssigned   = `$true
        ObjectId          = `$_.id
    }
}

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output "Ingesting data to Log Analytics..."

`$ingestUri = "`$DceUri/dataCollectionRules/`$DcrImmutableId/streams/`$StreamName```?api-version=2023-01-01"

`$ingestHeaders = @{
    "Authorization" = "Bearer `$monitorToken"
    "Content-Type"  = "application/json"
}

`$batchSize = 500
`$totalBatches = [math]::Ceiling(`$logData.Count / `$batchSize)
`$successCount = 0
`$failCount = 0

for (`$i = 0; `$i -lt `$logData.Count; `$i += `$batchSize) {
    `$batchNumber = [math]::Floor(`$i / `$batchSize) + 1
    `$batch = `$logData[`$i..([math]::Min(`$i + `$batchSize - 1, `$logData.Count - 1))]
    `$batchBody = `$batch | ConvertTo-Json -AsArray -Depth 10 -Compress
    
    try {
        Invoke-RestMethod -Uri `$ingestUri -Headers `$ingestHeaders -Method Post -Body `$batchBody | Out-Null
        `$successCount += `$batch.Count
        Write-Output "  Batch `$batchNumber/`$totalBatches : `$(`$batch.Count) records ingested"
    }
    catch {
        `$failCount += `$batch.Count
        Write-Warning "  Batch `$batchNumber/`$totalBatches : Failed - `$_"
    }
    
    if (`$batchNumber -lt `$totalBatches) {
        Start-Sleep -Milliseconds 500
    }
}

# ============================================
# SUMMARY
# ============================================

Write-Output ""
Write-Output "========================================="
Write-Output "SYNC COMPLETED"
Write-Output "========================================="
Write-Output "Total Teams Premium users: `$(`$teamsPremiumUsers.Count)"
Write-Output "Successfully ingested: `$successCount"
Write-Output "Failed: `$failCount"
Write-Output "Timestamp: `$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "========================================="
"@

# Save to temp file
$tempFile = Join-Path $env:TEMP "$($Global:RunbookName).ps1"
$runbookContent | Out-File -FilePath $tempFile -Encoding UTF8 -Force

# ============================================
# Create and Import Runbook
# ============================================

Write-Host "Creating runbook in Azure Automation..." -ForegroundColor Yellow

try {
    # Check if runbook exists
    $existingRunbook = Get-AzAutomationRunbook `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Name $Global:RunbookName `
        -ErrorAction SilentlyContinue
    
    if ($existingRunbook) {
        Write-Host "Runbook exists - updating..." -ForegroundColor Yellow
    }
    
    # Import runbook
    Import-AzAutomationRunbook `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Name $Global:RunbookName `
        -Type "PowerShell72" `
        -Description "Syncs Teams Premium license data to Log Analytics" `
        -Path $tempFile `
        -Force | Out-Null
    
    Write-Host "Runbook imported successfully" -ForegroundColor Green
    
    # Publish runbook
    Write-Host "Publishing runbook..." -ForegroundColor Yellow
    
    Publish-AzAutomationRunbook `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Name $Global:RunbookName | Out-Null
    
    Write-Host "Runbook published successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to create runbook: $_"
    return
}
finally {
    # Cleanup temp file
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}
```

---

## Step 8: Schedule the Runbook

```powershell
<#
.SYNOPSIS
    Step 8: Create Schedule for the Runbook
.DESCRIPTION
    Creates a daily schedule for the license sync runbook
.NOTES
    Requires: Step 7 completed (Runbook created)
#>

# ============================================
# Create Schedule
# ============================================

Write-Host "Creating schedule..." -ForegroundColor Yellow

try {
    # Check if schedule exists
    $existingSchedule = Get-AzAutomationSchedule `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Name $Global:ScheduleName `
        -ErrorAction SilentlyContinue
    
    if ($existingSchedule) {
        Write-Host "Schedule already exists - skipping creation" -ForegroundColor Yellow
    }
    else {
        New-AzAutomationSchedule `
            -ResourceGroupName $Global:ResourceGroupName `
            -AutomationAccountName $Global:AutomationAccountName `
            -Name $Global:ScheduleName `
            -StartTime $Global:ScheduleStartTime `
            -DayInterval 1 `
            -TimeZone $Global:ScheduleTimeZone `
            -Description "Daily sync of Teams Premium license data" | Out-Null
        
        Write-Host "Schedule created successfully" -ForegroundColor Green
    }
    
    # Link schedule to runbook
    Write-Host "Linking schedule to runbook..." -ForegroundColor Yellow
    
    Register-AzAutomationScheduledRunbook `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -RunbookName $Global:RunbookName `
        -ScheduleName $Global:ScheduleName `
        -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "Schedule linked to runbook!" -ForegroundColor Green
    Write-Host "  Schedule: $($Global:ScheduleName)" -ForegroundColor Cyan
    Write-Host "  Next run: $($Global:ScheduleStartTime)" -ForegroundColor Cyan
    Write-Host "  Time Zone: $($Global:ScheduleTimeZone)" -ForegroundColor Cyan
}
catch {
    if ($_.Exception.Message -like "*already registered*") {
        Write-Host "Schedule already linked to runbook" -ForegroundColor Yellow
    }
    else {
        Write-Error "Failed to create schedule: $_"
    }
}
```

---

## Step 9: Validation and Testing

### 9.1 Manual Test Run

```powershell
<#
.SYNOPSIS
    Step 9.1: Manually test the runbook
.DESCRIPTION
    Triggers a test run of the runbook and monitors output
.NOTES
    Requires: Steps 1-8 completed
#>

Write-Host "Starting manual test run..." -ForegroundColor Yellow

$job = Start-AzAutomationRunbook `
    -ResourceGroupName $Global:ResourceGroupName `
    -AutomationAccountName $Global:AutomationAccountName `
    -Name $Global:RunbookName

Write-Host "Job started: $($job.JobId)" -ForegroundColor Cyan

# Wait for job completion
Write-Host "Waiting for job to complete..." -ForegroundColor Yellow

do {
    Start-Sleep -Seconds 10
    $jobStatus = Get-AzAutomationJob `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Id $job.JobId
    
    Write-Host "  Status: $($jobStatus.Status)" -ForegroundColor Gray
} while ($jobStatus.Status -notin @("Completed", "Failed", "Stopped", "Suspended"))

# Get job output
Write-Host ""
Write-Host "Job Output:" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan

$output = Get-AzAutomationJobOutput `
    -ResourceGroupName $Global:ResourceGroupName `
    -AutomationAccountName $Global:AutomationAccountName `
    -Id $job.JobId `
    -Stream Any

foreach ($line in $output) {
    $color = switch ($line.Type) {
        "Output"  { "White" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        default   { "Gray" }
    }
    Write-Host $line.Summary -ForegroundColor $color
}

if ($jobStatus.Status -eq "Completed") {
    Write-Host ""
    Write-Host "Test run completed successfully!" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "Test run failed with status: $($jobStatus.Status)" -ForegroundColor Red
    
    # Get error details
    $errors = Get-AzAutomationJobOutput `
        -ResourceGroupName $Global:ResourceGroupName `
        -AutomationAccountName $Global:AutomationAccountName `
        -Id $job.JobId `
        -Stream Error
    
    foreach ($err in $errors) {
        Write-Host "ERROR: $($err.Summary)" -ForegroundColor Red
    }
}
```

### 9.2 Verify Data in Log Analytics

```powershell
<#
.SYNOPSIS
    Step 9.2: Verify data in Log Analytics
.DESCRIPTION
    Runs a KQL query to verify data was ingested
#>

Write-Host "Verifying data in Log Analytics..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Run this query in Log Analytics (Azure Portal):" -ForegroundColor Cyan
Write-Host ""

$verifyQuery = @"
$($Global:FullTableName)
| where TimeGenerated > ago(1h)
| summarize 
    RecordCount = count(),
    UniqueUsers = dcount(UserPrincipalName),
    LatestSync = max(TimeGenerated)
| project 
    RecordCount,
    UniqueUsers,
    LatestSync,
    SyncAge = datetime_diff('minute', now(), LatestSync)
"@

Write-Host $verifyQuery -ForegroundColor White
Write-Host ""

# Attempt to query via API
try {
    $workspaceId = (Get-AzOperationalInsightsWorkspace `
        -ResourceGroupName $Global:ResourceGroupName `
        -Name $Global:WorkspaceName).CustomerId

    $queryResult = Invoke-AzOperationalInsightsQuery `
        -WorkspaceId $workspaceId `
        -Query $verifyQuery `
        -ErrorAction Stop

    Write-Host "Query Results:" -ForegroundColor Green
    $queryResult.Results | Format-Table -AutoSize
}
catch {
    Write-Host "Could not query via API. Please run the query manually in the Azure Portal." -ForegroundColor Yellow
    Write-Host "Navigate to: Log Analytics workspace > Logs" -ForegroundColor Gray
}
```

### 9.3 Deployment Summary

```powershell
<#
.SYNOPSIS
    Step 9.3: Display deployment summary
.DESCRIPTION
    Shows all deployed resources and their configurations
#>

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    DEPLOYMENT COMPLETED SUCCESSFULLY                         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "Deployed Resources:" -ForegroundColor Yellow
Write-Host "  Custom Table:        $($Global:FullTableName)" -ForegroundColor White
Write-Host "  DCE:                 $($Global:DceName)" -ForegroundColor White
Write-Host "  DCR:                 $($Global:DcrName)" -ForegroundColor White
Write-Host "  Automation Account:  $($Global:AutomationAccountName)" -ForegroundColor White
Write-Host "  Runbook:             $($Global:RunbookName)" -ForegroundColor White
Write-Host "  Schedule:            $($Global:ScheduleName)" -ForegroundColor White
Write-Host ""

Write-Host "Runtime Values (save these for reference):" -ForegroundColor Yellow
Write-Host "  DCE Ingestion URI:   $($Global:DceLogsIngestionUri)" -ForegroundColor Cyan
Write-Host "  DCR Immutable ID:    $($Global:DcrImmutableId)" -ForegroundColor Cyan
Write-Host "  Managed Identity ID: $($Global:AutomationAccountPrincipalId)" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Verify first sync completed (Step 9.1)" -ForegroundColor White
Write-Host "  2. Query data in Log Analytics (Step 9.2)" -ForegroundColor White
Write-Host "  3. Use KQL queries from the 'KQL Queries' section" -ForegroundColor White
Write-Host ""
```

---

## KQL Queries

### Active Users Without Teams Premium

```kql
// Active users in last 30 days who don't have Teams Premium
let ActiveUsers = SigninLogs
    | where TimeGenerated > ago(30d)
    | summarize 
        LastSignIn = max(TimeGenerated),
        SignInCount = count()
      by UserPrincipalName;
let TeamsPremiumUsers = TeamsPremiumLicenses_CL
    | where TimeGenerated > ago(2d)
    | where LicenseAssigned == true
    | distinct UserPrincipalName;
ActiveUsers
| join kind=leftanti TeamsPremiumUsers on UserPrincipalName
| order by LastSignIn desc
```

### Active Users Without Teams Premium (with details)

```kql
// Active users without Teams Premium - with user details
let ActiveUsers = SigninLogs
    | where TimeGenerated > ago(30d)
    | summarize 
        LastSignIn = max(TimeGenerated),
        SignInCount = count(),
        AppNames = make_set(AppDisplayName, 5)
      by UserPrincipalName, UserDisplayName;
let TeamsPremiumUsers = TeamsPremiumLicenses_CL
    | where TimeGenerated > ago(2d)
    | where LicenseAssigned == true
    | distinct UserPrincipalName;
ActiveUsers
| join kind=leftanti TeamsPremiumUsers on UserPrincipalName
| project 
    UserPrincipalName,
    UserDisplayName,
    LastSignIn,
    SignInCount,
    DaysSinceLastSignIn = datetime_diff('day', now(), LastSignIn),
    TopApps = AppNames
| order by SignInCount desc
```

### License Assignment Trend

```kql
// Teams Premium license count over time
TeamsPremiumLicenses_CL
| summarize LicensedUsers = dcount(UserPrincipalName) by bin(TimeGenerated, 1d)
| order by TimeGenerated asc
| render timechart
```

### Sync Health Check

```kql
// Check sync job health
TeamsPremiumLicenses_CL
| summarize 
    LastSync = max(TimeGenerated),
    TotalRecords = count(),
    UniqueUsers = dcount(UserPrincipalName)
| extend 
    HoursSinceSync = datetime_diff('hour', now(), LastSync),
    SyncStatus = iff(datetime_diff('hour', now(), LastSync) < 26, "Healthy", "Stale")
```

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Runbook fails with "Not authorized" | Missing Graph permissions | Re-run Step 6.1 to assign User.Read.All |
| Runbook fails with "403 Forbidden" on ingestion | Missing DCR permissions | Re-run Step 6.2 to assign Monitoring Metrics Publisher |
| No data in custom table | DCR stream name mismatch | Verify StreamName matches in DCR and runbook |
| Table not found error | Table not created | Re-run Step 2 to create the table |
| Empty results from Graph | Managed Identity not working | Verify MI is enabled in Automation Account |
| "0 Teams Premium users found" | Wrong SKU ID | Run SKU verification script below |
| "ManagedIdentityCredential authentication failed" | Running locally instead of in Azure | Runbook must run IN Azure Automation, not locally |
| "InvalidAuthenticationToken" when running locally | Local PC has no Managed Identity | Use Start-AzAutomationRunbook to run in Azure |
| Token expires during deployment | Session timeout | Use Invoke-AzRestMethod instead of manual tokens |
| "exit 1" kills VS Code terminal | Script termination issue | Scripts updated to use "return" instead |

### Critical: Runbook Must Run IN Azure Automation

The runbook uses `Connect-AzAccount -Identity` which ONLY works inside Azure services (Automation, VMs, Functions). 

**Where the runbook CAN run:**
- ✅ Azure Automation (scheduled or manual via Start-AzAutomationRunbook)
- ✅ Azure VM with Managed Identity
- ✅ Azure Functions with Managed Identity

**Where the runbook CANNOT run:**
- ❌ Your local PC / VS Code terminal
- ❌ Azure Cloud Shell (no MI by default)
- ❌ Any machine outside Azure

**If you see this error locally:**
```
ManagedIdentityCredential authentication failed: Retry failed after 5 tries.
(169.254.169.254:80) connection failed
```

**Solution:** Run the runbook FROM Azure, not locally:
```powershell
# Start runbook in Azure Automation (run this locally)
$job = Start-AzAutomationRunbook `
    -ResourceGroupName "rg-lce-monitoring" `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
    -Name "Sync-TeamsPremiumLicenses"

# Monitor job status
do {
    Start-Sleep -Seconds 5
    $jobStatus = Get-AzAutomationJob `
        -ResourceGroupName "rg-lce-monitoring" `
        -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
        -Id $job.JobId
    Write-Host "Status: $($jobStatus.Status)"
} while ($jobStatus.Status -notin @("Completed", "Failed", "Stopped", "Suspended"))

# Get output
Get-AzAutomationJobOutput `
    -ResourceGroupName "rg-lce-monitoring" `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
    -Id $job.JobId -Stream Any | 
    ForEach-Object { Write-Host $_.Summary }
```

### Verify Teams Premium SKU ID

The Teams Premium SKU ID varies by tenant. Run this to find yours:

```powershell
# Connect to Graph
Connect-MgGraph -Scopes "Organization.Read.All" -NoWelcome

# Find Teams-related SKUs
Get-MgSubscribedSku | 
    Where-Object { $_.SkuPartNumber -like "*Teams*" -or $_.SkuPartNumber -like "*PREMIUM*" } | 
    Select-Object SkuPartNumber, SkuId, 
        @{N="Assigned";E={$_.ConsumedUnits}},
        @{N="Available";E={$_.PrepaidUnits.Enabled}} |
    Format-Table -AutoSize

# Show ALL SKUs if Teams Premium not obvious
Write-Host "`nAll SKUs in tenant:" -ForegroundColor Yellow
Get-MgSubscribedSku | 
    Select-Object SkuPartNumber, SkuId | 
    Sort-Object SkuPartNumber | 
    Format-Table -AutoSize
```

**Known Teams Premium SKU IDs:**
| SKU Part Number | SKU ID |
|-----------------|--------|
| Microsoft_Teams_Premium | `36a0f3b3-adb5-49ea-bf66-762134cf063a` |
| Teams_Premium | `36a0f3b3-adb5-49ea-bf66-762134cf063a` |
| Teams Premium (Trial) | `f5fa4fa8-8bec-4d38-b1e1-e5d3c23f7f23` |

> **Note:** Your tenant uses SKU ID `36a0f3b3-adb5-49ea-bf66-762134cf063a`

### Debug Commands

```powershell
# Check Automation Account Managed Identity
$aaResourcePath = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Automation/automationAccounts/<aa-name>"
$result = Invoke-AzRestMethod -Path "$aaResourcePath`?api-version=2023-11-01" -Method GET
($result.Content | ConvertFrom-Json).identity

# Check Graph permissions on Managed Identity
$miObjectId = "<Managed-Identity-Object-ID>"
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $miObjectId | 
    Select-Object AppRoleId, ResourceDisplayName

# Check RBAC on DCR
Get-AzRoleAssignment -ObjectId $miObjectId -Scope "<DCR-Resource-ID>"

# Get recent job failures with full error output
Get-AzAutomationJob `
    -ResourceGroupName "<RG>" `
    -AutomationAccountName "<AA-Name>" `
    -Status Failed | 
    Select-Object -First 3 | 
    ForEach-Object { 
        Write-Host "Job: $($_.JobId)" -ForegroundColor Cyan
        Get-AzAutomationJobOutput `
            -ResourceGroupName "<RG>" `
            -AutomationAccountName "<AA-Name>" `
            -Id $_.JobId -Stream Error |
            ForEach-Object { Write-Host $_.Summary -ForegroundColor Red }
    }

# Verify runbook exists and is published
Get-AzAutomationRunbook `
    -ResourceGroupName "<RG>" `
    -AutomationAccountName "<AA-Name>" |
    Select-Object Name, RunbookType, State |
    Format-Table
```

### Token/Authentication Issues During Deployment

If you get "InvalidAuthenticationToken" errors when running deployment scripts:

**Problem:** Azure tokens expire (usually after 1 hour), causing REST API calls to fail.

**Solution 1:** Use `Invoke-AzRestMethod` instead of `Invoke-RestMethod` with manual headers:
```powershell
# Instead of this (can fail with expired tokens):
$headers = @{ "Authorization" = "Bearer $token" }
Invoke-RestMethod -Uri $uri -Headers $headers -Method Put -Body $body

# Use this (handles auth automatically):
Invoke-AzRestMethod -Path $resourcePath -Method PUT -Payload $body
```

**Solution 2:** Re-authenticate before critical operations:
```powershell
Disconnect-AzAccount -ErrorAction SilentlyContinue
Connect-AzAccount -Subscription $Global:SubscriptionId
```

### Az Modules in Automation Account

The runbook requires Az.Accounts module. Verify it's imported:

```powershell
# Check modules in Automation Account
Get-AzAutomationModule `
    -ResourceGroupName "rg-lce-monitoring" `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" |
    Where-Object { $_.Name -like "Az.*" } |
    Select-Object Name, ProvisioningState |
    Format-Table

# Import Az.Accounts if missing
Import-AzAutomationModule `
    -ResourceGroupName "rg-lce-monitoring" `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
    -Name "Az.Accounts" `
    -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/Az.Accounts"
```

---

## Maintenance

### Monthly Tasks

1. **Review sync job history** for failures
2. **Verify data freshness** using the Sync Health Check query
3. **Update SKU ID** if Microsoft changes it (rare)

### Quarterly Tasks

1. **Review Managed Identity permissions** - remove any unused
2. **Check Log Analytics retention** settings
3. **Update runbook** if Graph API changes

### Annual Tasks

1. **Review solution architecture** against new Azure features
2. **Update PowerShell modules** in Automation Account

---

## Appendix

### A. Complete Deployment Script

For convenience, here's a consolidated script that runs all steps:

```powershell
<#
.SYNOPSIS
    Complete Teams Premium License Sync Deployment
.DESCRIPTION
    Deploys all components for the license sync solution
.PARAMETER SubscriptionId
    Azure Subscription ID
.PARAMETER ResourceGroupName
    Target Resource Group
.PARAMETER WorkspaceName
    Log Analytics Workspace name
.PARAMETER Location
    Azure region (e.g., canadacentral)
.EXAMPLE
    .\Deploy-TeamsPremiumLicenseSync.ps1 -SubscriptionId "xxx" -ResourceGroupName "rg-security" -WorkspaceName "law-security" -Location "canadacentral"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceName,
    
    [Parameter(Mandatory = $true)]
    [string]$Location
)

# Store in config hashtable
$Config = @{
    SubscriptionId    = $SubscriptionId
    ResourceGroupName = $ResourceGroupName
    WorkspaceName     = $WorkspaceName
    Location          = $Location
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Teams Premium License Sync Deployment " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Run each step...
# (Include all the steps from above)
```

### B. Resource Naming Convention

| Resource | Naming Pattern | Example |
|----------|----------------|---------|
| Custom Table | `TeamsPremiumLicenses_CL` | `TeamsPremiumLicenses_CL` |
| DCE | `DCE-<Purpose>` | `DCE-TeamsPremiumLicenses` |
| DCR | `DCR-<Purpose>` | `DCR-TeamsPremiumLicenses` |
| Automation Account | `AA-<Purpose>` | `AA-TeamsPremiumLicenseSync` |
| Runbook | `<Verb>-<Noun>` | `Sync-TeamsPremiumLicenses` |
| Schedule | `<Frequency>-<Purpose>` | `Daily-TeamsPremiumSync` |

### C. Security Considerations

1. **Managed Identity** - Uses system-assigned MI (no secrets to manage)
2. **Least Privilege** - Only User.Read.All (not Directory.Read.All)
3. **Network** - DCE uses public endpoint by default; consider Private Link for production
4. **Data** - License data stored in Log Analytics with configured retention
5. **Audit** - All automation jobs logged in Azure Activity Log

### D. Cost Estimate

| Component | Estimated Monthly Cost (CAD) |
|-----------|------------------------------|
| Azure Automation | ~$0.50 (30 job runs @ 2 min each) |
| Log Analytics Ingestion | ~$2-5 (depends on user count) |
| Log Analytics Retention | Included in first 31 days |
| DCE/DCR | Free |
| **Total** | **~$3-6/month** |

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | LCE M365 Security Team | Initial release |

---