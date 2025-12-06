# Azure Customer Managed Keys (CMK) Configuration Guide v5.0

## Complete Implementation for Exchange, Teams, SharePoint, and OneDrive

## Leonardo Canada Inc. - Canadian Deployment with RBAC Configuration

**Version:** 5.0  
**Author:** LCE M365 Security Team  
**Last Updated:** December 2025  
**Classification:** Internal Use Only

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Architecture](#3-architecture)
4. [PowerShell Environment Setup](#4-powershell-environment-setup)
5. [Configuration Variables](#5-configuration-variables)
6. [Authentication](#6-authentication)
7. [Register Service Principals](#7-register-service-principals)
8. [Exchange/Teams CMK Setup](#8-exchangeteams-cmk-setup)
9. [SharePoint/OneDrive CMK Setup](#9-sharepointonedrive-cmk-setup)
10. [Customer Key Enablement Request](#10-customer-key-enablement-request)
11. [Create Data Encryption Policy (DEP)](#11-create-data-encryption-policy-dep)
12. [Apply DEP to Users/Groups](#12-apply-dep-to-usersgroups)
13. [Monitoring and Compliance Runbooks](#13-monitoring-and-compliance-runbooks)
14. [Key Management Procedures](#14-key-management-procedures)
15. [Troubleshooting](#15-troubleshooting)
16. [Appendix A: Complete Setup Scripts](#appendix-a-complete-setup-scripts)
17. [Appendix B: KQL Queries](#appendix-b-kql-queries)

---

## 1. Overview

### 1.1 Purpose

This guide provides comprehensive instructions for implementing Customer Managed Keys (CMK) across all Microsoft 365 services at Leonardo Canada Inc., including automated monitoring and compliance enforcement.

### 1.2 Services Covered

| Service | CMK Type | Application Method | Key Vault |
|---------|----------|-------------------|-----------|
| Exchange Online (Email/Calendar) | Data Encryption Policy (DEP) | Per-user via mailbox | kv-cmk-exo-* |
| Microsoft Teams (Chat/Meetings/Voicemail) | Data Encryption Policy (DEP) | Per-user via mailbox | kv-cmk-exo-* |
| SharePoint Online | SPO DEP | Tenant-wide | kv-cmk-spo-* |
| OneDrive for Business | SPO DEP | Tenant-wide | kv-cmk-spo-* |
| Teams Files | SPO DEP (via SharePoint) | Tenant-wide | kv-cmk-spo-* |

### 1.3 Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| Exchange/Teams Key Vaults | ✅ Complete | kv-cmk-exo-pri-1117, kv-cmk-exo-sec-1117 |
| SharePoint/OneDrive Key Vaults | ✅ Complete | kv-cmk-spo-pri-1117, kv-cmk-spo-sec-1117 |
| RBAC Permissions | ✅ Complete | Compliance-Administrators group configured |
| Customer Key Enablement | ⏳ Pending | Awaiting Microsoft provisioning |
| DEP Creation | ⏳ Pending | Requires Customer Key enablement |
| Monitoring Runbooks | ✅ Complete | Auto-apply functionality ready |

---

## 2. Prerequisites

### 2.1 Required Licenses

- Microsoft 365 E5 or Office 365 E5 license (for all target users)
- Microsoft Teams Premium license (for all target users)
- **Two paid Azure subscriptions** (Free/Trial subscriptions are NOT eligible)

### 2.2 Required Permissions

| Requirement | Minimum Role |
|-------------|--------------|
| Azure Subscription | Owner or User Access Administrator |
| Microsoft Entra ID | Global Administrator |
| Exchange Online | Exchange Administrator |
| SharePoint Online | SharePoint Administrator |
| Key Vault | Key Vault Administrator (via RBAC) |

### 2.3 Critical Requirements

- **Two separate Azure subscriptions are mandatory** - Customer Key will not work with a single subscription
- Both subscriptions must be under the same Azure AD tenant
- All resources deployed in **Canada Central** and **Canada East** regions for data sovereignty

---

## 3. Architecture

### 3.1 Complete CMK Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LEONARDO CANADA CMK ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    EXCHANGE / TEAMS CMK                              │   │
│  │  ┌─────────────────────┐       ┌─────────────────────┐              │   │
│  │  │   PRIMARY VAULT     │       │  SECONDARY VAULT    │              │   │
│  │  │  Canada Central     │       │   Canada East       │              │   │
│  │  ├─────────────────────┤       ├─────────────────────┤              │   │
│  │  │ kv-cmk-exo-pri-1117 │       │ kv-cmk-exo-sec-1117 │              │   │
│  │  │    └── exo-cmk-key  │       │    └── exo-cmk-key  │              │   │
│  │  │    Subscription:    │       │    Subscription:    │              │   │
│  │  │    6f114bd7-...     │       │    6fe93f46-...     │              │   │
│  │  └──────────┬──────────┘       └──────────┬──────────┘              │   │
│  │             │                              │                         │   │
│  │             └──────────────┬───────────────┘                         │   │
│  │                           │                                          │   │
│  │                    ┌──────▼──────┐                                   │   │
│  │                    │  LCE-CMK-DEP │ ← Data Encryption Policy        │   │
│  │                    └──────┬──────┘                                   │   │
│  │                           │                                          │   │
│  │           ┌───────────────┼───────────────┐                         │   │
│  │           │               │               │                         │   │
│  │    ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐                 │   │
│  │    │  Exchange   │ │   Teams     │ │   Teams     │                 │   │
│  │    │   Email     │ │   Chat      │ │  Meetings   │                 │   │
│  │    └─────────────┘ └─────────────┘ └─────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                 SHAREPOINT / ONEDRIVE CMK                            │   │
│  │  ┌─────────────────────┐       ┌─────────────────────┐              │   │
│  │  │   PRIMARY VAULT     │       │  SECONDARY VAULT    │              │   │
│  │  │  Canada Central     │       │   Canada East       │              │   │
│  │  ├─────────────────────┤       ├─────────────────────┤              │   │
│  │  │ kv-cmk-spo-pri-1117 │       │ kv-cmk-spo-sec-1117 │              │   │
│  │  │    └── spo-cmk-key  │       │    └── spo-cmk-key  │              │   │
│  │  └──────────┬──────────┘       └──────────┬──────────┘              │   │
│  │             │                              │                         │   │
│  │             └──────────────┬───────────────┘                         │   │
│  │                           │                                          │   │
│  │           ┌───────────────┼───────────────┐                         │   │
│  │           │               │               │                         │   │
│  │    ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐                 │   │
│  │    │ SharePoint  │ │  OneDrive   │ │ Teams Files │                 │   │
│  │    │   Sites     │ │  Personal   │ │ (via SPO)   │                 │   │
│  │    └─────────────┘ └─────────────┘ └─────────────┘                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MONITORING & AUTOMATION                           │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │   │
│  │  │ Azure Automation │  │  Log Analytics  │  │ Email Reports   │     │   │
│  │  │ AA-TeamsPremium  │→ │ CMKCompliance_CL│→ │ Compliance-     │     │   │
│  │  │ LicenseSync      │  │                 │  │ Administrators  │     │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Security Groups

| Group Name | Object ID | Purpose |
|------------|-----------|---------|
| LCE-CMK-ENABLED-USERS | `36ba0617-d0a4-454a-b755-5207e34d275a` | Users requiring CMK/DEP |
| Compliance-Administrators | `55ee252d-9a4c-4159-828f-a4e8fe98d3c5` | Key Vault admins + report recipients |
| LCE M365 Security | `ffde4f56-194f-4c76-9916-31375e6d7fe5` | Security team members |

---

## 4. PowerShell Environment Setup

### 4.1 Required Modules

```powershell
# Install required modules
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force
Install-Module -Name M365CustomerKeyOnboarding -Scope CurrentUser -Force

# Verify installation
Get-Module -ListAvailable Az*, Microsoft.Graph*, ExchangeOnline*, Microsoft.Online.SharePoint*
```

### 4.2 Execution Policy

```powershell
# Set execution policy (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

---

## 5. Configuration Variables

### 5.1 Master Configuration Block

```powershell
# ============================================
# CMK MASTER CONFIGURATION
# ============================================

$global:CMKConfig = @{
    # Tenant
    TenantId = "80b1ce91-e920-49d4-a52e-4ab189c64592"
    PrimaryDomain = "leonardocompany.ca"
    
    # Subscriptions
    PrimarySubscriptionId = "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
    SecondarySubscriptionId = "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"
    
    # Regions
    PrimaryLocation = "Canada Central"
    SecondaryLocation = "Canada East"
    
    # Exchange/Teams Key Vaults
    ExoKeyVaults = @{
        Primary = @{
            Name = "kv-cmk-exo-pri-1117"
            ResourceGroup = "rg-cmk-exo-primary"
            KeyName = "exo-cmk-key"
            KeyUri = "https://kv-cmk-exo-pri-1117.vault.azure.net/keys/exo-cmk-key/f2de6544a73f4e318fbf88cbc97a1f57"
        }
        Secondary = @{
            Name = "kv-cmk-exo-sec-1117"
            ResourceGroup = "rg-cmk-exo-secondary"
            KeyName = "exo-cmk-key"
            KeyUri = "https://kv-cmk-exo-sec-1117.vault.azure.net/keys/exo-cmk-key/aa47ab596f4b4e01a49dbc5f73370e23"
        }
    }
    
    # SharePoint/OneDrive Key Vaults
    SpoKeyVaults = @{
        Primary = @{
            Name = "kv-cmk-spo-pri-1117"
            ResourceGroup = "rg-cmk-primary-multiworkload"
            KeyName = "spo-cmk-key"
            KeyUri = "https://kv-cmk-spo-pri-1117.vault.azure.net/keys/spo-cmk-key/8114590cfda44f22b6cc3581dc004bb7"
        }
        Secondary = @{
            Name = "kv-cmk-spo-sec-1117"
            ResourceGroup = "rg-cmk-secondary-multiworkload"
            KeyName = "spo-cmk-key"
            KeyUri = "https://kv-cmk-spo-sec-1117.vault.azure.net/keys/spo-cmk-key/ec2682182b854c888d5124b2863e2b71"
        }
    }
    
    # DEP Configuration
    DEPName = "LCE-CMK-DEP"
    DEPDescription = "Leonardo Company CMK for Exchange Online and Teams"
    
    # Security Groups
    CMKGroupId = "36ba0617-d0a4-454a-b755-5207e34d275a"
    CMKGroupName = "LCE-CMK-ENABLED-USERS"
    ComplianceAdminsGroupId = "55ee252d-9a4c-4159-828f-a4e8fe98d3c5"
    
    # Automation
    AutomationAccount = "AA-TeamsPremiumLicenseSync"
    AutomationRG = "rg-lce-monitoring"
    ManagedIdentityId = "88b19c56-4a06-4e35-9a8d-129e30d1398c"
    
    # Backup
    BackupPath = "$HOME\CMK-Key-Backups"
}

# Display configuration
Write-Host "CMK Configuration Loaded:" -ForegroundColor Cyan
Write-Host "  Tenant: $($global:CMKConfig.TenantId)"
Write-Host "  Exchange DEP: $($global:CMKConfig.DEPName)"
Write-Host "  CMK Group: $($global:CMKConfig.CMKGroupName)"
```

---

## 6. Authentication

### 6.1 Connect to Azure

```powershell
# Clear existing contexts
Clear-AzContext -Force -ErrorAction SilentlyContinue

# Connect to Azure
Connect-AzAccount -TenantId $global:CMKConfig.TenantId

# Verify connection
$context = Get-AzContext
if ($context.Tenant.Id -ne $global:CMKConfig.TenantId) {
    Write-Error "Connected to wrong tenant!"
} else {
    Write-Host "Connected to: $($context.Tenant.Id)" -ForegroundColor Green
}
```

### 6.2 Connect to Microsoft Graph

```powershell
# Connect with required scopes
Connect-MgGraph -Scopes @(
    "Application.ReadWrite.All",
    "Group.Read.All",
    "User.Read.All",
    "Directory.Read.All"
) -TenantId $global:CMKConfig.TenantId -NoWelcome

# Verify connection
$mgContext = Get-MgContext
Write-Host "Graph connected as: $($mgContext.Account)" -ForegroundColor Green
```

---

## 7. Register Service Principals

### 7.1 Required Service Principals

**IMPORTANT:** Use Microsoft Graph PowerShell, not the deprecated AzureAD module.

```powershell
# ============================================
# REGISTER SERVICE PRINCIPALS (Microsoft Graph)
# ============================================

Write-Host "Registering required service principals..." -ForegroundColor Cyan

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Service Principals Required for CMK
$servicePrincipals = @(
    @{ AppId = "00000002-0000-0ff1-ce00-000000000000"; Name = "Office 365 Exchange Online" }
    @{ AppId = "00000007-0000-0ff1-ce00-000000000000"; Name = "Microsoft Exchange Online Protection" }
    @{ AppId = "00000003-0000-0ff1-ce00-000000000000"; Name = "Office 365 SharePoint Online" }
    @{ AppId = "c066d759-24ae-40e7-a56f-027002b5d3e4"; Name = "M365DataAtRestEncryption" }
    @{ AppId = "19f7f505-34aa-44a4-9dcc-6a768854d2ea"; Name = "Customer Key Onboarding" }
)

foreach ($sp in $servicePrincipals) {
    $existing = Get-MgServicePrincipal -Filter "AppId eq '$($sp.AppId)'" -ErrorAction SilentlyContinue
    
    if ($existing) {
        Write-Host "[EXISTS] $($sp.Name): $($existing.Id)" -ForegroundColor DarkGreen
    } else {
        try {
            $newSp = New-MgServicePrincipal -AppId $sp.AppId
            Write-Host "[CREATED] $($sp.Name): $($newSp.Id)" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] $($sp.Name): $_" -ForegroundColor Red
        }
    }
}
```

---

## 8. Exchange/Teams CMK Setup

### 8.1 Complete Idempotent Setup Script

This script creates all Exchange/Teams CMK infrastructure with proper checks for existing resources.

```powershell
<#
.SYNOPSIS
    Complete Exchange/Teams CMK Setup - Key Vaults, Keys, RBAC, and DEP
.DESCRIPTION
    Creates all Exchange/Teams CMK infrastructure:
    1. Resource Groups (if not exist)
    2. Key Vaults with Premium SKU and Purge Protection (if not exist)
    3. RBAC role assignments for current user AND Compliance-Administrators group
    4. RSA 2048 keys in both vaults (if not exist)
    5. Exchange Online service principal access
    6. Data Encryption Policy (requires Customer Key enablement)
    
    All operations are idempotent - safe to run multiple times.
.NOTES
    Author: LCE M365 Security Team
    Version: 2.0
#>

# ============================================
# CONFIGURATION
# ============================================

$TenantId = "80b1ce91-e920-49d4-a52e-4ab189c64592"
$PrimarySubscriptionId = "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
$SecondarySubscriptionId = "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"

$PrimaryResourceGroup = "rg-cmk-exo-primary"
$SecondaryResourceGroup = "rg-cmk-exo-secondary"

$PrimaryKeyVaultName = "kv-cmk-exo-pri-1117"
$SecondaryKeyVaultName = "kv-cmk-exo-sec-1117"

$PrimaryLocation = "Canada Central"
$SecondaryLocation = "Canada East"

$KeyName = "exo-cmk-key"
$DEPName = "LCE-CMK-DEP"
$DEPDescription = "Leonardo Company CMK for Exchange Online and Teams"

$ComplianceAdministratorsGroupId = "55ee252d-9a4c-4159-828f-a4e8fe98d3c5"
$ExchangeServicePrincipalAppId = "00000002-0000-0ff1-ce00-000000000000"

# ============================================
# HELPER FUNCTIONS
# ============================================

function Test-RoleAssignmentExists {
    param (
        [string]$ObjectId,
        [string]$RoleDefinitionName,
        [string]$Scope
    )
    $existing = Get-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $RoleDefinitionName -Scope $Scope -ErrorAction SilentlyContinue
    return ($null -ne $existing)
}

function Grant-KeyVaultRBAC {
    param (
        [string]$ObjectId,
        [string]$ObjectName,
        [string]$KeyVaultName,
        [string]$Scope
    )
    
    $roles = @("Key Vault Crypto Officer", "Key Vault Secrets Officer")
    
    foreach ($role in $roles) {
        if (Test-RoleAssignmentExists -ObjectId $ObjectId -RoleDefinitionName $role -Scope $Scope) {
            Write-Host "    [EXISTS] $role for $ObjectName" -ForegroundColor DarkGreen
        }
        else {
            try {
                New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $role -Scope $Scope -ErrorAction Stop | Out-Null
                Write-Host "    [ADDED] $role for $ObjectName" -ForegroundColor Green
            }
            catch {
                if ($_.Exception.Message -like "*Conflict*" -or $_.Exception.Message -like "*already exists*") {
                    Write-Host "    [EXISTS] $role for $ObjectName" -ForegroundColor DarkGreen
                }
                else {
                    Write-Host "    [WARN] Could not assign $role to $ObjectName : $_" -ForegroundColor Yellow
                }
            }
        }
    }
}

# ============================================
# STEP 1: CONNECT TO AZURE
# ============================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   EXCHANGE/TEAMS CMK COMPLETE SETUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nStep 1: Connecting to Azure..." -ForegroundColor Yellow

$context = Get-AzContext
if (-not $context -or $context.Tenant.Id -ne $TenantId) {
    Connect-AzAccount -TenantId $TenantId
}

$currentUser = Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id -ErrorAction SilentlyContinue
if ($currentUser) {
    $currentUserObjectId = $currentUser.Id
    Write-Host "  [OK] Connected as: $($currentUser.DisplayName)" -ForegroundColor Green
}

# ============================================
# STEP 2: CREATE PRIMARY RESOURCES
# ============================================

Write-Host "`nStep 2: Setting up PRIMARY resources ($PrimaryLocation)..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null

# Resource Group
$rg = Get-AzResourceGroup -Name $PrimaryResourceGroup -ErrorAction SilentlyContinue
if ($rg) {
    Write-Host "  [EXISTS] Resource Group: $PrimaryResourceGroup" -ForegroundColor DarkGreen
} else {
    New-AzResourceGroup -Name $PrimaryResourceGroup -Location $PrimaryLocation | Out-Null
    Write-Host "  [CREATED] Resource Group: $PrimaryResourceGroup" -ForegroundColor Green
}

# Key Vault
$primaryKv = Get-AzKeyVault -VaultName $PrimaryKeyVaultName -ResourceGroupName $PrimaryResourceGroup -ErrorAction SilentlyContinue
if ($primaryKv) {
    Write-Host "  [EXISTS] Key Vault: $PrimaryKeyVaultName" -ForegroundColor DarkGreen
} else {
    $primaryKv = New-AzKeyVault -Name $PrimaryKeyVaultName -ResourceGroupName $PrimaryResourceGroup `
        -Location $PrimaryLocation -Sku Premium -EnablePurgeProtection
    Write-Host "  [CREATED] Key Vault: $PrimaryKeyVaultName" -ForegroundColor Green
    Write-Host "  [WAIT] Waiting 60 seconds for DNS propagation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
}

$PrimaryKeyVaultScope = "/subscriptions/$PrimarySubscriptionId/resourceGroups/$PrimaryResourceGroup/providers/Microsoft.KeyVault/vaults/$PrimaryKeyVaultName"

# ============================================
# STEP 3: CREATE SECONDARY RESOURCES
# ============================================

Write-Host "`nStep 3: Setting up SECONDARY resources ($SecondaryLocation)..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null

# Resource Group
$rg = Get-AzResourceGroup -Name $SecondaryResourceGroup -ErrorAction SilentlyContinue
if ($rg) {
    Write-Host "  [EXISTS] Resource Group: $SecondaryResourceGroup" -ForegroundColor DarkGreen
} else {
    New-AzResourceGroup -Name $SecondaryResourceGroup -Location $SecondaryLocation | Out-Null
    Write-Host "  [CREATED] Resource Group: $SecondaryResourceGroup" -ForegroundColor Green
}

# Key Vault
$secondaryKv = Get-AzKeyVault -VaultName $SecondaryKeyVaultName -ResourceGroupName $SecondaryResourceGroup -ErrorAction SilentlyContinue
if ($secondaryKv) {
    Write-Host "  [EXISTS] Key Vault: $SecondaryKeyVaultName" -ForegroundColor DarkGreen
} else {
    $secondaryKv = New-AzKeyVault -Name $SecondaryKeyVaultName -ResourceGroupName $SecondaryResourceGroup `
        -Location $SecondaryLocation -Sku Premium -EnablePurgeProtection
    Write-Host "  [CREATED] Key Vault: $SecondaryKeyVaultName" -ForegroundColor Green
    Write-Host "  [WAIT] Waiting 60 seconds for DNS propagation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
}

$SecondaryKeyVaultScope = "/subscriptions/$SecondarySubscriptionId/resourceGroups/$SecondaryResourceGroup/providers/Microsoft.KeyVault/vaults/$SecondaryKeyVaultName"

# ============================================
# STEP 4-5: CONFIGURE RBAC ON BOTH VAULTS
# ============================================

Write-Host "`nStep 4: Configuring RBAC on PRIMARY Key Vault..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null

if ($currentUserObjectId) {
    Write-Host "  Granting access to current user..."
    Grant-KeyVaultRBAC -ObjectId $currentUserObjectId -ObjectName "Current User" -KeyVaultName $PrimaryKeyVaultName -Scope $PrimaryKeyVaultScope
}

Write-Host "  Granting access to Compliance-Administrators group..."
Grant-KeyVaultRBAC -ObjectId $ComplianceAdministratorsGroupId -ObjectName "Compliance-Administrators" -KeyVaultName $PrimaryKeyVaultName -Scope $PrimaryKeyVaultScope

# Exchange Online service principal
$exoSP = Get-AzADServicePrincipal -ApplicationId $ExchangeServicePrincipalAppId -ErrorAction SilentlyContinue
if ($exoSP) {
    Write-Host "  Granting access to Exchange Online service..."
    $exoRole = "Key Vault Crypto Service Encryption User"
    if (-not (Test-RoleAssignmentExists -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $PrimaryKeyVaultScope)) {
        New-AzRoleAssignment -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $PrimaryKeyVaultScope -ErrorAction SilentlyContinue | Out-Null
        Write-Host "    [ADDED] $exoRole for Exchange Online" -ForegroundColor Green
    } else {
        Write-Host "    [EXISTS] $exoRole for Exchange Online" -ForegroundColor DarkGreen
    }
}

Write-Host "`nStep 5: Configuring RBAC on SECONDARY Key Vault..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null

if ($currentUserObjectId) {
    Grant-KeyVaultRBAC -ObjectId $currentUserObjectId -ObjectName "Current User" -KeyVaultName $SecondaryKeyVaultName -Scope $SecondaryKeyVaultScope
}

Grant-KeyVaultRBAC -ObjectId $ComplianceAdministratorsGroupId -ObjectName "Compliance-Administrators" -KeyVaultName $SecondaryKeyVaultName -Scope $SecondaryKeyVaultScope

if ($exoSP) {
    if (-not (Test-RoleAssignmentExists -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $SecondaryKeyVaultScope)) {
        New-AzRoleAssignment -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $SecondaryKeyVaultScope -ErrorAction SilentlyContinue | Out-Null
        Write-Host "    [ADDED] $exoRole for Exchange Online" -ForegroundColor Green
    } else {
        Write-Host "    [EXISTS] $exoRole for Exchange Online" -ForegroundColor DarkGreen
    }
}

Write-Host "`n  [WAIT] Waiting 30 seconds for RBAC propagation..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# ============================================
# STEP 6: CREATE KEYS
# ============================================

Write-Host "`nStep 6: Creating encryption keys..." -ForegroundColor Yellow

# Primary Key
Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null
$primaryKey = Get-AzKeyVaultKey -VaultName $PrimaryKeyVaultName -Name $KeyName -ErrorAction SilentlyContinue
if ($primaryKey) {
    Write-Host "  [EXISTS] Primary key: $($primaryKey.Id)" -ForegroundColor DarkGreen
} else {
    $primaryKey = Add-AzKeyVaultKey -VaultName $PrimaryKeyVaultName -Name $KeyName `
        -Destination Software -KeyType RSA -Size 2048
    Write-Host "  [CREATED] Primary key: $($primaryKey.Id)" -ForegroundColor Green
}

# Secondary Key
Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null
$secondaryKey = Get-AzKeyVaultKey -VaultName $SecondaryKeyVaultName -Name $KeyName -ErrorAction SilentlyContinue
if ($secondaryKey) {
    Write-Host "  [EXISTS] Secondary key: $($secondaryKey.Id)" -ForegroundColor DarkGreen
} else {
    $secondaryKey = Add-AzKeyVaultKey -VaultName $SecondaryKeyVaultName -Name $KeyName `
        -Destination Software -KeyType RSA -Size 2048
    Write-Host "  [CREATED] Secondary key: $($secondaryKey.Id)" -ForegroundColor Green
}

# ============================================
# SUMMARY
# ============================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nKey URIs for DEP Creation:" -ForegroundColor Yellow
Write-Host "  Primary:   $($primaryKey.Id)" -ForegroundColor White
Write-Host "  Secondary: $($secondaryKey.Id)" -ForegroundColor White
Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "  1. Submit Customer Key enablement request to Microsoft"
Write-Host "  2. Wait for Microsoft confirmation (3-5 business days)"
Write-Host "  3. Create DEP: New-DataEncryptionPolicy -Name '$DEPName' -AzureKeyIDs @(...)"
Write-Host "  4. Apply to users via CMK monitoring runbook"
```

---

## 9. SharePoint/OneDrive CMK Setup

### 9.1 Key Vault Configuration

SharePoint/OneDrive uses separate Key Vaults from Exchange/Teams but follows the same pattern.

```powershell
# ============================================
# SHAREPOINT/ONEDRIVE CMK SETUP
# ============================================

# Key Vault Names
$SpoPrimaryKV = "kv-cmk-spo-pri-1117"
$SpoSecondaryKV = "kv-cmk-spo-sec-1117"

# Key URIs (after creation)
$SpoPrimaryKeyUri = "https://kv-cmk-spo-pri-1117.vault.azure.net/keys/spo-cmk-key/8114590cfda44f22b6cc3581dc004bb7"
$SpoSecondaryKeyUri = "https://kv-cmk-spo-sec-1117.vault.azure.net/keys/spo-cmk-key/ec2682182b854c888d5124b2863e2b71"

# Service Principals for SharePoint
$spoServicePrincipals = @{
    "SharePoint" = "00000003-0000-0ff1-ce00-000000000000"
    "M365DataAtRestEncryption" = "c066d759-24ae-40e7-a56f-027002b5d3e4"
}
```

### 9.2 Register SharePoint CMK

```powershell
# Connect to SharePoint Online
$adminUrl = "https://leonardocompany-admin.sharepoint.com"
Connect-SPOService -Url $adminUrl

# Register the CMK policy
Register-SPODataEncryptionPolicy `
    -PrimaryKeyVaultUri $SpoPrimaryKeyUri `
    -SecondaryKeyVaultUri $SpoSecondaryKeyUri

# Verify registration
Get-SPODataEncryptionPolicy

# Disconnect
Disconnect-SPOService
```

---

## 10. Customer Key Enablement Request

### 10.1 When to Submit

Submit this request when you receive the error:
> "Data Encryption Policies are not enabled for your organization."

### 10.2 Support Request Template

**Subject:** Request to Enable Customer Key for Microsoft 365 - Tenant ID: 80b1ce91-e920-49d4-a52e-4ab189c64592

---

Dear Microsoft Support Team,

We are requesting enablement of the Customer Key for Microsoft 365 feature on our tenant.

**TENANT INFORMATION**
- Organization: Leonardo Canada Inc.
- Tenant ID: 80b1ce91-e920-49d4-a52e-4ab189c64592
- Primary Domain: leonardocompany.ca

**SERVICES REQUIRED**
- Exchange Online
- Microsoft Teams

**BUSINESS JUSTIFICATION**
Leonardo Canada Inc. is a Canadian defense contractor handling Protected B classified materials. We require Customer Key to meet government security compliance requirements. We have already implemented Customer Key for SharePoint/OneDrive and need to extend protection to Exchange and Teams.

**AZURE KEY VAULT CONFIGURATION (COMPLETED)**

Primary Key Vault:
- URI: https://kv-cmk-exo-pri-1117.vault.azure.net
- Key: https://kv-cmk-exo-pri-1117.vault.azure.net/keys/exo-cmk-key/f2de6544a73f4e318fbf88cbc97a1f57
- Location: Canada Central
- Subscription: 6f114bd7-c8d3-4843-b4f8-e30a644bc412

Secondary Key Vault:
- URI: https://kv-cmk-exo-sec-1117.vault.azure.net
- Key: https://kv-cmk-exo-sec-1117.vault.azure.net/keys/exo-cmk-key/aa47ab596f4b4e01a49dbc5f73370e23
- Location: Canada East
- Subscription: 6fe93f46-fb3b-410b-8d22-540b06cbbfbc

Both vaults have:
- Premium SKU
- Soft Delete enabled (90 days)
- Purge Protection enabled
- Exchange Online service principal granted "Key Vault Crypto Service Encryption User" role

**CURRENT ERROR**
When running New-DataEncryptionPolicy, we receive:
"Data Encryption Policies are not enabled for your organization."

**REQUEST**
Please enable Customer Key at the tenant level so we can create Data Encryption Policies for Exchange Online and Microsoft Teams.

**CONTACT**
Frederick Pearson
Power Platform Tenant Administrator
fred.pearson@leonardocompany.ca
Leonardo Canada Inc.

Thank you for your prompt assistance.

---

### 10.3 Submission Methods

| Method | Instructions |
|--------|-------------|
| **Microsoft 365 Admin Center** | admin.microsoft.com → Support → New Service Request |
| **FastTrack Portal** | fasttrack.microsoft.com → Request Assistance |
| **Phone** | 1-800-865-9408 (Canada) |

### 10.4 Expected Timeline

| Stage | Duration |
|-------|----------|
| Ticket submitted | Day 0 |
| Microsoft acknowledgment | 1-2 business days |
| Feature enablement | 3-5 business days |
| Confirmation email | Upon completion |

---

## 11. Create Data Encryption Policy (DEP)

### 11.1 After Microsoft Enables Customer Key

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline

# Create the DEP
New-DataEncryptionPolicy -Name "LCE-CMK-DEP" `
    -Description "Leonardo Company CMK for Exchange Online and Teams" `
    -AzureKeyIDs @(
        "https://kv-cmk-exo-pri-1117.vault.azure.net/keys/exo-cmk-key/f2de6544a73f4e318fbf88cbc97a1f57",
        "https://kv-cmk-exo-sec-1117.vault.azure.net/keys/exo-cmk-key/aa47ab596f4b4e01a49dbc5f73370e23"
    )

# Verify
Get-DataEncryptionPolicy | Format-List Name, State, Enabled, AzureKeyIDs
```

### 11.2 DEP States

| State | Description |
|-------|-------------|
| PendingActivation | Normal - activates when first applied to a mailbox |
| Active | DEP is active and being used |
| PendingDeletion | DEP is being removed |

---

## 12. Apply DEP to Users/Groups

### 12.1 Apply to Single User

```powershell
Set-Mailbox -Identity "user@leonardocompany.ca" -DataEncryptionPolicy "LCE-CMK-DEP"
```

### 12.2 Apply to Security Group Members

```powershell
# Get group members and apply DEP
$groupId = "36ba0617-d0a4-454a-b755-5207e34d275a"  # LCE-CMK-ENABLED-USERS

Connect-MgGraph -Scopes "Group.Read.All"
$members = Get-MgGroupMember -GroupId $groupId -All

Connect-ExchangeOnline

foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id
    try {
        $mailbox = Get-Mailbox -Identity $user.UserPrincipalName -ErrorAction SilentlyContinue
        if ($mailbox) {
            Set-Mailbox -Identity $user.UserPrincipalName -DataEncryptionPolicy "LCE-CMK-DEP"
            Write-Host "[OK] Applied to: $($user.UserPrincipalName)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[SKIP] No mailbox: $($user.UserPrincipalName)" -ForegroundColor Yellow
    }
}
```

---

## 13. Monitoring and Compliance Runbooks

### 13.1 CMK Compliance Runbook Overview

The **Sync-CMKCompliance** runbook provides:
- Automatic DEP application to group members
- Compliance tracking and reporting
- Email notifications with dashboard
- Log Analytics integration

### 13.2 Runbook Configuration

```powershell
# Key configuration values in the runbook
$CMKGroupName = "LCE-CMK-ENABLED-USERS"
$CMKGroupObjectId = "36ba0617-d0a4-454a-b755-5207e34d275a"
$ExchangeDEPName = "LCE-CMK-DEP"
$AutoApplyDEP = $true  # Set to $false for report-only mode

$EmailFrom = "m365reports@leonardocompany.ca"
$EmailTo = "Compliance-Administrators@leonardocompany.ca"
```

### 13.3 Schedule

| Runbook | Schedule | Purpose |
|---------|----------|---------|
| Sync-TeamsPremiumLicenses | Daily 12:00 AM EST | Track Teams Premium licenses |
| Sync-CMKCompliance | Daily 12:30 AM EST | Monitor and auto-apply CMK/DEP |

### 13.4 Managed Identity Permissions

| Resource | Permission | Purpose |
|----------|------------|---------|
| Microsoft Graph | User.Read.All | Read user data |
| Microsoft Graph | GroupMember.Read.All | Read group membership |
| Microsoft Graph | Mail.Send | Send email reports |
| Exchange Online | Exchange.ManageAsApp | Manage mailbox DEP |
| DCR-CMKCompliance | Monitoring Metrics Publisher | Ingest compliance data |

### 13.5 Deploy Runbook

```powershell
# Import required modules to Automation Account
$automationAccount = "AA-TeamsPremiumLicenseSync"
$resourceGroup = "rg-lce-monitoring"

$requiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups",
    "ExchangeOnlineManagement"
)

foreach ($module in $requiredModules) {
    Import-AzAutomationModule -ResourceGroupName $resourceGroup `
        -AutomationAccountName $automationAccount `
        -Name $module `
        -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$module" `
        -RuntimeVersion "7.2"
}

# Create schedule
New-AzAutomationSchedule -ResourceGroupName $resourceGroup `
    -AutomationAccountName $automationAccount `
    -Name "Daily-CMKSync" `
    -StartTime (Get-Date "00:30:00").AddDays(1) `
    -DayInterval 1 `
    -TimeZone "Eastern Standard Time"
```

---

## 14. Key Management Procedures

### 14.1 Key Rotation

```powershell
# Create new key version
Set-AzContext -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
$newPrimaryKey = Add-AzKeyVaultKey -VaultName "kv-cmk-exo-pri-1117" `
    -Name "exo-cmk-key" -Destination Software -KeyType RSA -Size 2048

Set-AzContext -SubscriptionId "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"
$newSecondaryKey = Add-AzKeyVaultKey -VaultName "kv-cmk-exo-sec-1117" `
    -Name "exo-cmk-key" -Destination Software -KeyType RSA -Size 2048

# Update DEP
Connect-ExchangeOnline
Set-DataEncryptionPolicy -Identity "LCE-CMK-DEP" -Refresh `
    -AzureKeyIDs @($newPrimaryKey.Id, $newSecondaryKey.Id)
```

### 14.2 Key Backup

```powershell
$backupPath = "$HOME\CMK-Key-Backups"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Backup primary
Set-AzContext -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
Backup-AzKeyVaultKey -VaultName "kv-cmk-exo-pri-1117" -Name "exo-cmk-key" `
    -OutputFile "$backupPath\exo-cmk-PRIMARY-$timestamp.backup"

# Backup secondary
Set-AzContext -SubscriptionId "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"
Backup-AzKeyVaultKey -VaultName "kv-cmk-exo-sec-1117" -Name "exo-cmk-key" `
    -OutputFile "$backupPath\exo-cmk-SECONDARY-$timestamp.backup"

Write-Host "CRITICAL: Store backup files securely offline!" -ForegroundColor Red
```

---

## 15. Troubleshooting

### 15.1 Common Issues

#### Issue: "Caller is not authorized" (403 Forbidden)

**Cause:** Key Vault uses RBAC authorization but user lacks required role.

**Solution:**
```powershell
$userObjectId = "your-object-id"
$scope = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/kv-cmk-exo-pri-1117"

New-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName "Key Vault Crypto Officer" -Scope $scope
New-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName "Key Vault Secrets Officer" -Scope $scope

# Wait 30 seconds for propagation
Start-Sleep -Seconds 30
```

#### Issue: "Data Encryption Policies are not enabled"

**Cause:** Customer Key feature not enabled by Microsoft.

**Solution:** Submit Customer Key enablement request (see Section 10).

#### Issue: "No such host is known" (DNS error)

**Cause:** Key Vault DNS not propagated after creation.

**Solution:** Wait 5-15 minutes after vault creation, or verify vault exists:
```powershell
Get-AzKeyVault -VaultName "kv-cmk-exo-pri-1117"
nslookup kv-cmk-exo-pri-1117.vault.azure.net
```

#### Issue: AzureAD module not recognized

**Cause:** AzureAD module is deprecated.

**Solution:** Use Microsoft Graph PowerShell instead:
```powershell
# Instead of: Get-AzureADServicePrincipal
Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'"
```

### 15.2 Verification Commands

```powershell
# Verify Key Vault configuration
Get-AzKeyVault -VaultName "kv-cmk-exo-pri-1117" | 
    Select-Object VaultName, EnablePurgeProtection, EnableRbacAuthorization

# Verify DEP status
Connect-ExchangeOnline
Get-DataEncryptionPolicy | Format-List Name, State, Enabled, AzureKeyIDs

# Verify mailbox DEP
Get-Mailbox -Identity "user@leonardocompany.ca" | Select-Object DisplayName, DataEncryptionPolicy

# Verify service principals
Connect-MgGraph -Scopes "Application.Read.All"
Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'" | 
    Select-Object DisplayName, Id
```

---

## Appendix A: Complete Setup Scripts

All scripts are available in the LCE M365 Security repository:

| Script | Purpose |
|--------|---------|
| Setup-ExchangeCMK-Complete.ps1 | Complete Exchange/Teams CMK setup (idempotent) |
| Sync-CMKCompliance.ps1 | CMK compliance monitoring with auto-apply |
| Sync-TeamsPremiumLicenses.ps1 | Teams Premium license tracking |
| Deploy-CMKDEPSyncRunbook.ps1 | Deploy monitoring runbook to Azure Automation |
| Apply-DEPToGroup.ps1 | One-time DEP application to group members |
| Remove-OrphanedDEP.ps1 | Cleanup DEP from users removed from group |

---

## Appendix B: KQL Queries

### CMK Compliance Queries

```kusto
// Current CMK compliance status
CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where InCMKGroup == true
| summarize 
    Total = dcount(UserPrincipalName),
    Compliant = dcountif(UserPrincipalName, ExchangeTeamsCMK == true)
| extend ComplianceRate = round(100.0 * Compliant / Total, 1)

// Users who got DEP applied today
CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where DEPAppliedThisRun == true
| project TimeGenerated, UserPrincipalName, DisplayName

// CMK compliance trend
CMKCompliance_CL
| where InCMKGroup == true
| summarize 
    Total = dcount(UserPrincipalName),
    Compliant = dcountif(UserPrincipalName, ExchangeTeamsCMK == true)
    by bin(TimeGenerated, 1d)
| extend CompliancePercent = round(100.0 * Compliant / Total, 1)
| order by TimeGenerated desc
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 5.0 | December 2025 | LCE M365 Security Team | Added Exchange/Teams CMK, enablement request, monitoring runbooks |
| 4.1 | November 2025 | LCE M365 Security Team | SharePoint/OneDrive CMK, RBAC configuration |
| 4.0 | November 2025 | LCE M365 Security Team | Initial group-based deployment |

---

**END OF DOCUMENT**