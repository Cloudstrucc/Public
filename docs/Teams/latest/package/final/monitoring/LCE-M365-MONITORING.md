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
4. [Step 1: Environment Preparation](#step-1-environment-preparation)
5. [Step 2: Create Log Analytics Custom Table](#step-2-create-log-analytics-custom-table)
6. [Step 3: Create Data Collection Endpoint (DCE)](#step-3-create-data-collection-endpoint-dce)
7. [Step 4: Create Data Collection Rule (DCR)](#step-4-create-data-collection-rule-dcr)
8. [Step 5: Create Azure Automation Account](#step-5-create-azure-automation-account)
9. [Step 6: Configure Managed Identity Permissions](#step-6-configure-managed-identity-permissions)
10. [Step 7: Create and Configure the Runbook](#step-7-create-and-configure-the-runbook)
11. [Step 8: Schedule the Runbook](#step-8-schedule-the-runbook)
12. [Step 9: Validation and Testing](#step-9-validation-and-testing)
13. [KQL Queries](#kql-queries)
14. [Troubleshooting](#troubleshooting)
15. [Maintenance](#maintenance)
16. [Appendix](#appendix)

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
    exit 1
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
# Authenticate to Azure
# ============================================
Connect-AzAccount

# Select the correct subscription if you have multiple
Get-AzSubscription | Format-Table Name, Id, State
Set-AzContext -SubscriptionId "<Your-Subscription-Id>"

# ============================================
# Authenticate to Microsoft Graph
# ============================================
# Required scopes for this deployment
$GraphScopes = @(
    "User.Read.All",
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All"
)

Connect-MgGraph -Scopes $GraphScopes

# Verify connection
Get-MgContext | Format-List Account, TenantId, Scopes
```

---

## Step 2: Create Log Analytics Custom Table

### 2.1 Define Variables

```powershell
<#
.SYNOPSIS
    Step 2: Create Log Analytics Custom Table
.DESCRIPTION
    Creates the TeamsPremiumLicenses_CL custom table in Log Analytics
#>

# ============================================
# CONFIGURATION - UPDATE THESE VALUES
# ============================================

$Config = @{
    SubscriptionId        = "<Your-Subscription-Id>"
    ResourceGroupName     = "<Your-Resource-Group>"
    WorkspaceName         = "<Your-Log-Analytics-Workspace>"
    Location              = "canadacentral"  # Update to your region
    TableName             = "TeamsPremiumLicenses"
}

# Verify connection
$context = Get-AzContext
if ($null -eq $context) {
    Write-Error "Not connected to Azure. Run Connect-AzAccount first."
    exit 1
}

Write-Host "Connected to subscription: $($context.Subscription.Name)" -ForegroundColor Green
```

### 2.2 Create the Custom Table

```powershell
# ============================================
# Get Log Analytics Workspace
# ============================================

$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $Config.ResourceGroupName `
    -Name $Config.WorkspaceName

if ($null -eq $workspace) {
    Write-Error "Workspace '$($Config.WorkspaceName)' not found in resource group '$($Config.ResourceGroupName)'"
    exit 1
}

Write-Host "Found workspace: $($workspace.Name)" -ForegroundColor Green
Write-Host "  Resource ID: $($workspace.ResourceId)" -ForegroundColor Gray
Write-Host "  Location: $($workspace.Location)" -ForegroundColor Gray

# ============================================
# Create Custom Table using REST API
# ============================================

$tableResourceId = "$($workspace.ResourceId)/tables/$($Config.TableName)_CL"

$tableDefinition = @{
    properties = @{
        schema = @{
            name    = "$($Config.TableName)_CL"
            columns = @(
                @{ name = "TimeGenerated"; type = "datetime"; description = "Timestamp of the sync" }
                @{ name = "UserPrincipalName"; type = "string"; description = "User's UPN" }
                @{ name = "DisplayName"; type = "string"; description = "User's display name" }
                @{ name = "LicenseAssigned"; type = "boolean"; description = "Whether Teams Premium is assigned" }
                @{ name = "ObjectId"; type = "string"; description = "User's Entra Object ID" }
            )
        }
        retentionInDays      = 90
        totalRetentionInDays = 365
    }
}

$tableBody = $tableDefinition | ConvertTo-Json -Depth 10

# Get access token
$token = Get-AzAccessToken -ResourceUrl "https://management.azure.com"
$headers = @{
    "Authorization" = "Bearer $($token.Token)"
    "Content-Type"  = "application/json"
}

# Create table
$apiVersion = "2022-10-01"
$uri = "https://management.azure.com$($tableResourceId)?api-version=$apiVersion"

try {
    Write-Host "Creating custom table: $($Config.TableName)_CL..." -ForegroundColor Yellow
    
    $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $tableBody
    
    Write-Host "Custom table created successfully!" -ForegroundColor Green
    Write-Host "  Table Name: $($response.name)" -ForegroundColor Gray
    Write-Host "  Retention: $($response.properties.retentionInDays) days" -ForegroundColor Gray
}
catch {
    if ($_.Exception.Response.StatusCode -eq "Conflict") {
        Write-Host "Table already exists - continuing..." -ForegroundColor Yellow
    }
    else {
        Write-Error "Failed to create table: $_"
        exit 1
    }
}

# Store for later steps
$Script:WorkspaceResourceId = $workspace.ResourceId
$Script:WorkspaceId = $workspace.CustomerId
```

---

## Step 3: Create Data Collection Endpoint (DCE)

```powershell
<#
.SYNOPSIS
    Step 3: Create Data Collection Endpoint
.DESCRIPTION
    Creates the DCE for log ingestion
#>

# ============================================
# CONFIGURATION
# ============================================

$DceConfig = @{
    Name              = "DCE-TeamsPremiumLicenses"
    ResourceGroupName = $Config.ResourceGroupName
    Location          = $Config.Location
}

# ============================================
# Create Data Collection Endpoint
# ============================================

Write-Host "Creating Data Collection Endpoint..." -ForegroundColor Yellow

$dceResourceId = "/subscriptions/$($Config.SubscriptionId)/resourceGroups/$($Config.ResourceGroupName)/providers/Microsoft.Insights/dataCollectionEndpoints/$($DceConfig.Name)"

$dceDefinition = @{
    location   = $DceConfig.Location
    properties = @{
        description           = "DCE for Teams Premium License data ingestion"
        networkAcls           = @{
            publicNetworkAccess = "Enabled"
        }
    }
}

$dceBody = $dceDefinition | ConvertTo-Json -Depth 10

$uri = "https://management.azure.com$($dceResourceId)?api-version=2022-06-01"

try {
    $dceResponse = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $dceBody
    
    Write-Host "Data Collection Endpoint created successfully!" -ForegroundColor Green
    Write-Host "  Name: $($dceResponse.name)" -ForegroundColor Gray
    Write-Host "  Logs Ingestion URI: $($dceResponse.properties.logsIngestion.endpoint)" -ForegroundColor Cyan
    
    # Store for later
    $Script:DceLogsIngestionUri = $dceResponse.properties.logsIngestion.endpoint
    $Script:DceResourceId = $dceResponse.id
}
catch {
    if ($_.Exception.Response.StatusCode -eq "Conflict") {
        Write-Host "DCE already exists - retrieving details..." -ForegroundColor Yellow
        $dceResponse = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
        $Script:DceLogsIngestionUri = $dceResponse.properties.logsIngestion.endpoint
        $Script:DceResourceId = $dceResponse.id
        Write-Host "  Logs Ingestion URI: $($Script:DceLogsIngestionUri)" -ForegroundColor Cyan
    }
    else {
        Write-Error "Failed to create DCE: $_"
        exit 1
    }
}

Write-Host ""
Write-Host "=== IMPORTANT: Save this value ===" -ForegroundColor Magenta
Write-Host "DCE Logs Ingestion URI: $Script:DceLogsIngestionUri" -ForegroundColor White
Write-Host "=================================" -ForegroundColor Magenta
```

---

## Step 4: Create Data Collection Rule (DCR)

```powershell
<#
.SYNOPSIS
    Step 4: Create Data Collection Rule
.DESCRIPTION
    Creates the DCR that defines data transformation and routing
#>

# ============================================
# CONFIGURATION
# ============================================

$DcrConfig = @{
    Name              = "DCR-TeamsPremiumLicenses"
    ResourceGroupName = $Config.ResourceGroupName
    Location          = $Config.Location
    StreamName        = "Custom-TeamsPremiumLicenses_CL"
}

# ============================================
# Create Data Collection Rule
# ============================================

Write-Host "Creating Data Collection Rule..." -ForegroundColor Yellow

$dcrResourceId = "/subscriptions/$($Config.SubscriptionId)/resourceGroups/$($Config.ResourceGroupName)/providers/Microsoft.Insights/dataCollectionRules/$($DcrConfig.Name)"

$dcrDefinition = @{
    location   = $DcrConfig.Location
    properties = @{
        description              = "DCR for Teams Premium License sync"
        dataCollectionEndpointId = $Script:DceResourceId
        streamDeclarations       = @{
            "$($DcrConfig.StreamName)" = @{
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
                    workspaceResourceId = $Script:WorkspaceResourceId
                    name                = "LogAnalyticsDestination"
                }
            )
        }
        dataFlows                = @(
            @{
                streams      = @($DcrConfig.StreamName)
                destinations = @("LogAnalyticsDestination")
                transformKql = "source"
                outputStream = $DcrConfig.StreamName
            }
        )
    }
}

$dcrBody = $dcrDefinition | ConvertTo-Json -Depth 10

$uri = "https://management.azure.com$($dcrResourceId)?api-version=2022-06-01"

try {
    $dcrResponse = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $dcrBody
    
    Write-Host "Data Collection Rule created successfully!" -ForegroundColor Green
    Write-Host "  Name: $($dcrResponse.name)" -ForegroundColor Gray
    Write-Host "  Immutable ID: $($dcrResponse.properties.immutableId)" -ForegroundColor Cyan
    
    # Store for later
    $Script:DcrImmutableId = $dcrResponse.properties.immutableId
    $Script:DcrResourceId = $dcrResponse.id
}
catch {
    if ($_.Exception.Response.StatusCode -eq "Conflict") {
        Write-Host "DCR already exists - retrieving details..." -ForegroundColor Yellow
        $dcrResponse = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
        $Script:DcrImmutableId = $dcrResponse.properties.immutableId
        $Script:DcrResourceId = $dcrResponse.id
        Write-Host "  Immutable ID: $($Script:DcrImmutableId)" -ForegroundColor Cyan
    }
    else {
        Write-Error "Failed to create DCR: $_"
        exit 1
    }
}

Write-Host ""
Write-Host "=== IMPORTANT: Save these values ===" -ForegroundColor Magenta
Write-Host "DCR Immutable ID: $Script:DcrImmutableId" -ForegroundColor White
Write-Host "Stream Name: $($DcrConfig.StreamName)" -ForegroundColor White
Write-Host "====================================" -ForegroundColor Magenta
```

---

## Step 5: Create Azure Automation Account

```powershell
<#
.SYNOPSIS
    Step 5: Create Azure Automation Account
.DESCRIPTION
    Creates an Automation Account with System-Assigned Managed Identity
#>

# ============================================
# CONFIGURATION
# ============================================

$AutomationConfig = @{
    Name              = "AA-TeamsPremiumLicenseSync"
    ResourceGroupName = $Config.ResourceGroupName
    Location          = $Config.Location
}

# ============================================
# Create Automation Account
# ============================================

Write-Host "Creating Azure Automation Account..." -ForegroundColor Yellow

try {
    $automationAccount = Get-AzAutomationAccount `
        -ResourceGroupName $AutomationConfig.ResourceGroupName `
        -Name $AutomationConfig.Name `
        -ErrorAction SilentlyContinue
    
    if ($automationAccount) {
        Write-Host "Automation Account already exists" -ForegroundColor Yellow
    }
    else {
        $automationAccount = New-AzAutomationAccount `
            -ResourceGroupName $AutomationConfig.ResourceGroupName `
            -Name $AutomationConfig.Name `
            -Location $AutomationConfig.Location `
            -AssignSystemIdentity
        
        Write-Host "Automation Account created successfully!" -ForegroundColor Green
    }
    
    # Ensure System-Assigned Managed Identity is enabled
    $aaResourceId = "/subscriptions/$($Config.SubscriptionId)/resourceGroups/$($AutomationConfig.ResourceGroupName)/providers/Microsoft.Automation/automationAccounts/$($AutomationConfig.Name)"
    
    $aaResponse = Invoke-RestMethod `
        -Uri "https://management.azure.com$($aaResourceId)?api-version=2023-11-01" `
        -Method Get `
        -Headers $headers
    
    if ($null -eq $aaResponse.identity -or $aaResponse.identity.type -ne "SystemAssigned") {
        Write-Host "Enabling System-Assigned Managed Identity..." -ForegroundColor Yellow
        
        $identityBody = @{
            identity = @{
                type = "SystemAssigned"
            }
        } | ConvertTo-Json
        
        $aaResponse = Invoke-RestMethod `
            -Uri "https://management.azure.com$($aaResourceId)?api-version=2023-11-01" `
            -Method Patch `
            -Headers $headers `
            -Body $identityBody
    }
    
    $Script:AutomationAccountPrincipalId = $aaResponse.identity.principalId
    
    Write-Host "  Name: $($AutomationConfig.Name)" -ForegroundColor Gray
    Write-Host "  Managed Identity Object ID: $Script:AutomationAccountPrincipalId" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to create Automation Account: $_"
    exit 1
}

Write-Host ""
Write-Host "=== IMPORTANT: Save this value ===" -ForegroundColor Magenta
Write-Host "Managed Identity Object ID: $Script:AutomationAccountPrincipalId" -ForegroundColor White
Write-Host "==================================" -ForegroundColor Magenta
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
    Requires Global Administrator or Privileged Role Administrator
#>

# Ensure connected to Microsoft Graph with required scopes
$mgContext = Get-MgContext
if ($null -eq $mgContext) {
    Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"
}

Write-Host "Assigning Microsoft Graph permissions..." -ForegroundColor Yellow

# Microsoft Graph App ID (constant)
$GraphAppId = "00000003-0000-0000-c000-000000000000"

# Get the Microsoft Graph Service Principal
$graphSP = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"

if ($null -eq $graphSP) {
    Write-Error "Microsoft Graph service principal not found"
    exit 1
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
        -ServicePrincipalId $Script:AutomationAccountPrincipalId `
        -ErrorAction SilentlyContinue | 
        Where-Object { $_.AppRoleId -eq $appRole.Id }
    
    if ($existingAssignment) {
        Write-Host "  $($permission.Name) - Already assigned" -ForegroundColor Gray
    }
    else {
        try {
            New-MgServicePrincipalAppRoleAssignment `
                -ServicePrincipalId $Script:AutomationAccountPrincipalId `
                -PrincipalId $Script:AutomationAccountPrincipalId `
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
#>

Write-Host "Assigning Azure RBAC permissions..." -ForegroundColor Yellow

# Assign "Monitoring Metrics Publisher" role on the DCR
$roleDefinitionName = "Monitoring Metrics Publisher"

try {
    $existingAssignment = Get-AzRoleAssignment `
        -ObjectId $Script:AutomationAccountPrincipalId `
        -Scope $Script:DcrResourceId `
        -RoleDefinitionName $roleDefinitionName `
        -ErrorAction SilentlyContinue
    
    if ($existingAssignment) {
        Write-Host "  $roleDefinitionName on DCR - Already assigned" -ForegroundColor Gray
    }
    else {
        New-AzRoleAssignment `
            -ObjectId $Script:AutomationAccountPrincipalId `
            -Scope $Script:DcrResourceId `
            -RoleDefinitionName $roleDefinitionName | Out-Null
        
        Write-Host "  $roleDefinitionName on DCR - Assigned successfully" -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to assign RBAC role: $_"
    exit 1
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
    Teams Premium License Sync Runbook
.DESCRIPTION
    Queries Microsoft Graph for Teams Premium license assignments
    and ingests the data into Log Analytics via DCR
.NOTES
    Runs in Azure Automation with System-Assigned Managed Identity
    Requires: User.Read.All Graph permission, Monitoring Metrics Publisher on DCR
#>

# ============================================
# CONFIGURATION - UPDATE THESE VALUES
# ============================================

$DceUri = "<Your-DCE-Logs-Ingestion-URI>"          # e.g., https://dce-xxx.canadacentral-1.ingest.monitor.azure.com
$DcrImmutableId = "<Your-DCR-Immutable-ID>"        # e.g., dcr-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$StreamName = "Custom-TeamsPremiumLicenses_CL"
$TeamsPremiumSkuId = "16ddbbfc-09ea-4de2-b1d7-312db6112d70"  # Teams Premium SKU ID

# ============================================
# AUTHENTICATION
# ============================================

Write-Output "Starting Teams Premium License Sync..."
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"

try {
    # Authenticate using Managed Identity
    Write-Output "Authenticating with Managed Identity..."
    Connect-AzAccount -Identity | Out-Null
    
    # Get Graph token
    $graphToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
    
    # Get Monitor token for log ingestion
    $monitorToken = (Get-AzAccessToken -ResourceUrl "https://monitor.azure.com").Token
    
    Write-Output "Authentication successful"
}
catch {
    Write-Error "Authentication failed: $_"
    throw
}

# ============================================
# QUERY MICROSOFT GRAPH
# ============================================

Write-Output "Querying Microsoft Graph for user licenses..."

$graphHeaders = @{
    "Authorization" = "Bearer $graphToken"
    "Content-Type"  = "application/json"
    "ConsistencyLevel" = "eventual"
}

$users = @()
$uri = "https://graph.microsoft.com/v1.0/users?`$select=id,userPrincipalName,displayName,assignedLicenses&`$top=999"

try {
    do {
        $response = Invoke-RestMethod -Uri $uri -Headers $graphHeaders -Method Get
        $users += $response.value
        $uri = $response.'@odata.nextLink'
        
        if ($users.Count % 1000 -eq 0) {
            Write-Output "  Retrieved $($users.Count) users..."
        }
    } while ($uri)
    
    Write-Output "Total users retrieved: $($users.Count)"
}
catch {
    Write-Error "Failed to query Microsoft Graph: $_"
    throw
}

# ============================================
# FILTER TEAMS PREMIUM USERS
# ============================================

Write-Output "Filtering Teams Premium license holders..."

$teamsPremiumUsers = $users | Where-Object {
    $_.assignedLicenses.skuId -contains $TeamsPremiumSkuId
}

Write-Output "Users with Teams Premium: $($teamsPremiumUsers.Count)"

if ($teamsPremiumUsers.Count -eq 0) {
    Write-Output "No Teams Premium users found. Exiting."
    return
}

# ============================================
# BUILD LOG PAYLOAD
# ============================================

Write-Output "Building log ingestion payload..."

$currentTime = (Get-Date).ToUniversalTime().ToString("o")

$logData = $teamsPremiumUsers | ForEach-Object {
    @{
        TimeGenerated     = $currentTime
        UserPrincipalName = $_.userPrincipalName
        DisplayName       = $_.displayName
        LicenseAssigned   = $true
        ObjectId          = $_.id
    }
}

# ============================================
# INGEST TO LOG ANALYTICS
# ============================================

Write-Output "Ingesting data to Log Analytics..."

$ingestUri = "$DceUri/dataCollectionRules/$DcrImmutableId/streams/$StreamName`?api-version=2023-01-01"

$ingestHeaders = @{
    "Authorization" = "Bearer $monitorToken"
    "Content-Type"  = "application/json"
}

# Send in batches of 500 (conservative limit for reliability)
$batchSize = 500
$totalBatches = [math]::Ceiling($logData.Count / $batchSize)
$successCount = 0
$failCount = 0

for ($i = 0; $i -lt $logData.Count; $i += $batchSize) {
    $batchNumber = [math]::Floor($i / $batchSize) + 1
    $batch = $logData[$i..([math]::Min($i + $batchSize - 1, $logData.Count - 1))]
    $batchBody = $batch | ConvertTo-Json -AsArray -Depth 10 -Compress
    
    try {
        Invoke-RestMethod -Uri $ingestUri -Headers $ingestHeaders -Method Post -Body $batchBody | Out-Null
        $successCount += $batch.Count
        Write-Output "  Batch $batchNumber/$totalBatches : $($batch.Count) records ingested"
    }
    catch {
        $failCount += $batch.Count
        Write-Warning "  Batch $batchNumber/$totalBatches : Failed - $_"
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
Write-Output "========================================="
Write-Output "SYNC COMPLETED"
Write-Output "========================================="
Write-Output "Total Teams Premium users: $($teamsPremiumUsers.Count)"
Write-Output "Successfully ingested: $successCount"
Write-Output "Failed: $failCount"
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC"
Write-Output "========================================="
```

### 7.2 Deploy the Runbook

```powershell
<#
.SYNOPSIS
    Step 7.2: Deploy the Runbook to Azure Automation
.DESCRIPTION
    Creates the runbook and imports the script
#>

# ============================================
# CONFIGURATION
# ============================================

$RunbookConfig = @{
    Name                  = "Sync-TeamsPremiumLicenses"
    AutomationAccountName = "AA-TeamsPremiumLicenseSync"
    ResourceGroupName     = $Config.ResourceGroupName
    Type                  = "PowerShell72"
    Description           = "Syncs Teams Premium license data to Log Analytics"
}

# ============================================
# Update Runbook Script with Actual Values
# ============================================

Write-Host "Preparing runbook script with configuration values..." -ForegroundColor Yellow

# Read the template (or use the content above)
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

`$DceUri = "$Script:DceLogsIngestionUri"
`$DcrImmutableId = "$Script:DcrImmutableId"
`$StreamName = "Custom-TeamsPremiumLicenses_CL"
`$TeamsPremiumSkuId = "16ddbbfc-09ea-4de2-b1d7-312db6112d70"

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
$tempFile = Join-Path $env:TEMP "Sync-TeamsPremiumLicenses.ps1"
$runbookContent | Out-File -FilePath $tempFile -Encoding UTF8 -Force

# ============================================
# Create and Import Runbook
# ============================================

Write-Host "Creating runbook in Azure Automation..." -ForegroundColor Yellow

try {
    # Check if runbook exists
    $existingRunbook = Get-AzAutomationRunbook `
        -ResourceGroupName $RunbookConfig.ResourceGroupName `
        -AutomationAccountName $RunbookConfig.AutomationAccountName `
        -Name $RunbookConfig.Name `
        -ErrorAction SilentlyContinue
    
    if ($existingRunbook) {
        Write-Host "Runbook exists - updating..." -ForegroundColor Yellow
    }
    
    # Import runbook
    Import-AzAutomationRunbook `
        -ResourceGroupName $RunbookConfig.ResourceGroupName `
        -AutomationAccountName $RunbookConfig.AutomationAccountName `
        -Name $RunbookConfig.Name `
        -Type $RunbookConfig.Type `
        -Description $RunbookConfig.Description `
        -Path $tempFile `
        -Force | Out-Null
    
    Write-Host "Runbook imported successfully" -ForegroundColor Green
    
    # Publish runbook
    Write-Host "Publishing runbook..." -ForegroundColor Yellow
    
    Publish-AzAutomationRunbook `
        -ResourceGroupName $RunbookConfig.ResourceGroupName `
        -AutomationAccountName $RunbookConfig.AutomationAccountName `
        -Name $RunbookConfig.Name | Out-Null
    
    Write-Host "Runbook published successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to create runbook: $_"
    exit 1
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
#>

# ============================================
# CONFIGURATION
# ============================================

$ScheduleConfig = @{
    Name                  = "Daily-TeamsPremiumSync"
    AutomationAccountName = "AA-TeamsPremiumLicenseSync"
    ResourceGroupName     = $Config.ResourceGroupName
    StartTime             = (Get-Date).AddDays(1).Date.AddHours(2)  # Tomorrow at 2 AM
    TimeZone              = "Eastern Standard Time"
    Description           = "Daily sync of Teams Premium license data"
}

# ============================================
# Create Schedule
# ============================================

Write-Host "Creating schedule..." -ForegroundColor Yellow

try {
    # Check if schedule exists
    $existingSchedule = Get-AzAutomationSchedule `
        -ResourceGroupName $ScheduleConfig.ResourceGroupName `
        -AutomationAccountName $ScheduleConfig.AutomationAccountName `
        -Name $ScheduleConfig.Name `
        -ErrorAction SilentlyContinue
    
    if ($existingSchedule) {
        Write-Host "Schedule already exists - skipping creation" -ForegroundColor Yellow
    }
    else {
        New-AzAutomationSchedule `
            -ResourceGroupName $ScheduleConfig.ResourceGroupName `
            -AutomationAccountName $ScheduleConfig.AutomationAccountName `
            -Name $ScheduleConfig.Name `
            -StartTime $ScheduleConfig.StartTime `
            -DayInterval 1 `
            -TimeZone $ScheduleConfig.TimeZone `
            -Description $ScheduleConfig.Description | Out-Null
        
        Write-Host "Schedule created successfully" -ForegroundColor Green
    }
    
    # Link schedule to runbook
    Write-Host "Linking schedule to runbook..." -ForegroundColor Yellow
    
    Register-AzAutomationScheduledRunbook `
        -ResourceGroupName $ScheduleConfig.ResourceGroupName `
        -AutomationAccountName $ScheduleConfig.AutomationAccountName `
        -RunbookName "Sync-TeamsPremiumLicenses" `
        -ScheduleName $ScheduleConfig.Name `
        -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "Schedule linked to runbook!" -ForegroundColor Green
    Write-Host "  Next run: $($ScheduleConfig.StartTime)" -ForegroundColor Cyan
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
#>

Write-Host "Starting manual test run..." -ForegroundColor Yellow

$job = Start-AzAutomationRunbook `
    -ResourceGroupName $Config.ResourceGroupName `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
    -Name "Sync-TeamsPremiumLicenses"

Write-Host "Job started: $($job.JobId)" -ForegroundColor Cyan

# Wait for job completion
Write-Host "Waiting for job to complete..." -ForegroundColor Yellow

do {
    Start-Sleep -Seconds 10
    $jobStatus = Get-AzAutomationJob `
        -ResourceGroupName $Config.ResourceGroupName `
        -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
        -Id $job.JobId
    
    Write-Host "  Status: $($jobStatus.Status)" -ForegroundColor Gray
} while ($jobStatus.Status -notin @("Completed", "Failed", "Stopped", "Suspended"))

# Get job output
Write-Host ""
Write-Host "Job Output:" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan

$output = Get-AzAutomationJobOutput `
    -ResourceGroupName $Config.ResourceGroupName `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
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
        -ResourceGroupName $Config.ResourceGroupName `
        -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
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
TeamsPremiumLicenses_CL
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
        -ResourceGroupName $Config.ResourceGroupName `
        -Name $Config.WorkspaceName).CustomerId

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

### Debug Commands

```powershell
# Check Automation Account Managed Identity
$aa = Get-AzAutomationAccount -ResourceGroupName "<RG>" -Name "<AA-Name>"
$aa.Identity

# Check Graph permissions on Managed Identity
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId "<MI-Object-ID>"

# Check RBAC on DCR
Get-AzRoleAssignment -Scope "<DCR-Resource-ID>"

# Get recent job failures
Get-AzAutomationJob -ResourceGroupName "<RG>" -AutomationAccountName "<AA-Name>" -Status Failed | 
    Select-Object -First 5 | 
    ForEach-Object { 
        Get-AzAutomationJobOutput -Id $_.JobId -ResourceGroupName "<RG>" -AutomationAccountName "<AA-Name>" -Stream Error 
    }
```

### Teams Premium SKU ID Reference

```powershell
# If you need to verify the Teams Premium SKU ID in your tenant:
Connect-MgGraph -Scopes "Organization.Read.All"

Get-MgSubscribedSku | 
    Where-Object { $_.SkuPartNumber -like "*Teams*" } | 
    Select-Object SkuPartNumber, SkuId, ConsumedUnits

# Common SKU IDs:
# Teams Premium: 16ddbbfc-09ea-4de2-b1d7-312db6112d70
# Teams Premium (trial): f5fa4fa8-8bec-4d38-b1e1-e5d3c23f7f23
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

*End of Build Book*