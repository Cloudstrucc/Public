# Standard Operating Procedure (SOP)
# Microsoft 365 Security Compliance Monitoring

**Document ID:** LCE-SOP-M365-SEC-001  
**Version:** 1.0  
**Classification:** Internal Use Only  
**Author:** LCE M365 Security Team  
**Effective Date:** December 2025  
**Review Date:** December 2026

---

## Table of Contents

1. [Purpose and Scope](#1-purpose-and-scope)
2. [Architecture Overview](#2-architecture-overview)
3. [Component Inventory](#3-component-inventory)
4. [Security Groups and Access Control](#4-security-groups-and-access-control)
5. [Monitoring Operations](#5-monitoring-operations)
6. [Daily Operations Checklist](#6-daily-operations-checklist)
7. [CMK Key Management Procedures](#7-cmk-key-management-procedures)
8. [User Management Procedures](#8-user-management-procedures)
9. [Troubleshooting Guide](#9-troubleshooting-guide)
10. [Escalation Procedures](#10-escalation-procedures)
11. [Appendix A: Buildbook - Initial Setup](#appendix-a-buildbook---initial-setup)
12. [Appendix B: KQL Query Reference](#appendix-b-kql-query-reference)
13. [Appendix C: Customer Key Enablement Request](#appendix-c-customer-key-enablement-request)
14. [Document Control](#document-control)

---

## 1. Purpose and Scope

### 1.1 Purpose

This Standard Operating Procedure defines the operational processes for monitoring and maintaining Microsoft 365 security compliance at Leonardo Canada Inc., specifically covering:

- **Customer Managed Keys (CMK)** for data-at-rest encryption
- **Teams Premium License** compliance tracking
- **Automated remediation** of non-compliant users

### 1.2 Scope

This SOP applies to the following M365 services:

| Service | CMK Type | Application Method |
|---------|----------|-------------------|
| Exchange Online | Data Encryption Policy (DEP) | Per-user via mailbox |
| Microsoft Teams (Chat/Meetings) | Data Encryption Policy (DEP) | Per-user via mailbox |
| Teams Voicemail | Data Encryption Policy (DEP) | Per-user via mailbox |
| SharePoint Online | SPO DEP | Tenant-wide |
| OneDrive for Business | SPO DEP | Tenant-wide |
| Teams Files | SPO DEP (via SharePoint) | Tenant-wide |

### 1.3 Compliance Requirements

Leonardo Canada Inc. handles Protected B classified materials and must maintain CMK encryption to meet Canadian government security requirements.

---

## 2. Architecture Overview

### 2.1 Solution Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AZURE AUTOMATION                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              AA-TeamsPremiumLicenseSync                              │    │
│  │  ┌───────────────────────┐  ┌───────────────────────┐               │    │
│  │  │ Sync-TeamsPremium     │  │ Sync-CMKCompliance    │               │    │
│  │  │ Licenses (Daily)      │  │ (Daily + Auto-Apply)  │               │    │
│  │  └───────────┬───────────┘  └───────────┬───────────┘               │    │
│  └──────────────┼──────────────────────────┼───────────────────────────┘    │
│                 │                          │                                 │
│                 │    Managed Identity      │                                 │
│                 │    (88b19c56-4a06...)    │                                 │
└─────────────────┼──────────────────────────┼─────────────────────────────────┘
                  │                          │
    ┌─────────────┴─────────────┐  ┌────────┴────────────────┐
    │                           │  │                          │
    ▼                           ▼  ▼                          ▼
┌────────────────┐  ┌────────────────┐  ┌────────────────────────────────┐
│ Microsoft Graph│  │ Exchange Online │  │     Azure Key Vault            │
│      API       │  │                 │  │ ┌────────────┬────────────┐   │
│                │  │ - Get-Mailbox   │  │ │ PRIMARY    │ SECONDARY  │   │
│ - User data    │  │ - Set-Mailbox   │  │ │ Canada Cen │ Canada East│   │
│ - Groups       │  │ - DEP policies  │  │ │ kv-cmk-exo │ kv-cmk-exo │   │
│ - Licenses     │  │                 │  │ │ -pri-1117  │ -sec-1117  │   │
└────────┬───────┘  └────────┬────────┘  └──────┬─────────────┬───────┘
         │                   │                   │             │
         └─────────┬─────────┴───────────────────┴─────────────┘
                   │
                   ▼
         ┌─────────────────────────────────────┐
         │  Data Collection Endpoint (DCE)     │
         │  DCE-TeamsPremiumLicenses           │
         └──────────────────┬──────────────────┘
                            │
                            ▼
         ┌─────────────────────────────────────┐
         │  Log Analytics Workspace            │
         │  rg-lce-m365-security-group-monitor │
         │                                     │
         │  Tables:                            │
         │  - TeamsPremiumLicenses_CL          │
         │  - CMKCompliance_CL                 │
         └──────────────────┬──────────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
    ┌──────────────────┐        ┌──────────────────┐
    │  Azure Workbook  │        │  Email Reports   │
    │  (Dashboard)     │        │  (Daily)         │
    └──────────────────┘        └──────────────────┘
```

### 2.2 Data Flow

1. **Scheduled Trigger**: Azure Automation runs runbooks daily at midnight EST
2. **Data Collection**: Runbooks query Microsoft Graph and Exchange Online
3. **Auto-Remediation**: CMK runbook applies DEP to non-compliant group members
4. **Ingestion**: Data sent to Log Analytics via Data Collection Rules (DCR)
5. **Reporting**: Email reports sent to Compliance-Administrators group
6. **Visualization**: Azure Workbook provides real-time dashboard

---

## 3. Component Inventory

### 3.1 Azure Resources

| Resource | Name | Resource Group | Subscription |
|----------|------|----------------|--------------|
| Automation Account | AA-TeamsPremiumLicenseSync | rg-lce-monitoring | LCE M365 Security (6f114bd7...) |
| Log Analytics Workspace | rg-lce-m365-security-group-monitor | rg-lce-monitoring | LCE M365 Security (6f114bd7...) |
| Data Collection Endpoint | DCE-TeamsPremiumLicenses | rg-lce-monitoring | LCE M365 Security (6f114bd7...) |
| Data Collection Rule (Licenses) | DCR-TeamsPremiumLicenses | rg-lce-monitoring | LCE M365 Security (6f114bd7...) |
| Data Collection Rule (CMK) | DCR-CMKCompliance | rg-lce-monitoring | LCE M365 Security (6f114bd7...) |

### 3.2 Key Vaults

#### Exchange/Teams CMK Key Vaults

| Property | Primary | Secondary |
|----------|---------|-----------|
| **Name** | kv-cmk-exo-pri-1117 | kv-cmk-exo-sec-1117 |
| **Location** | Canada Central | Canada East |
| **Subscription** | 6f114bd7-c8d3-4843-b4f8-e30a644bc412 | 6fe93f46-fb3b-410b-8d22-540b06cbbfbc |
| **Resource Group** | rg-cmk-exo-primary | rg-cmk-exo-secondary |
| **Key Name** | exo-cmk-key | exo-cmk-key |
| **Key URI** | https://kv-cmk-exo-pri-1117.vault.azure.net/keys/exo-cmk-key/f2de6544a73f4e318fbf88cbc97a1f57 | https://kv-cmk-exo-sec-1117.vault.azure.net/keys/exo-cmk-key/aa47ab596f4b4e01a49dbc5f73370e23 |
| **SKU** | Premium | Premium |
| **Purge Protection** | Enabled | Enabled |
| **Soft Delete** | 90 days | 90 days |

#### SharePoint/OneDrive CMK Key Vaults

| Property | Primary | Secondary |
|----------|---------|-----------|
| **Name** | kv-cmk-spo-pri-1117 | kv-cmk-spo-sec-1117 |
| **Location** | Canada Central | Canada East |
| **Key Name** | spo-cmk-key | spo-cmk-key |

### 3.3 Runbooks

| Runbook | Schedule | Purpose |
|---------|----------|---------|
| Sync-TeamsPremiumLicenses | Daily 12:00 AM EST | Track Teams Premium license assignments |
| Sync-CMKCompliance | Daily 12:30 AM EST | Monitor and auto-apply CMK/DEP |

### 3.4 Data Encryption Policies

| Policy Name | Services | Status |
|-------------|----------|--------|
| LCE-CMK-DEP | Exchange Online, Teams | Pending Microsoft enablement |
| SPO CMK | SharePoint, OneDrive | Registered |

---

## 4. Security Groups and Access Control

### 4.1 Security Groups

| Group Name | Object ID | Purpose |
|------------|-----------|---------|
| **LCE-CMK-ENABLED-USERS** | `36ba0617-d0a4-454a-b755-5207e34d275a` | Users who should have CMK/DEP applied |
| **Compliance-Administrators** | `55ee252d-9a4c-4159-828f-a4e8fe98d3c5` | Admins with Key Vault access + report recipients |
| **LCE M365 Security** | `ffde4f56-194f-4c76-9916-31375e6d7fe5` | Security team members |

### 4.2 Managed Identity

| Property | Value |
|----------|-------|
| **Name** | AA-TeamsPremiumLicenseSync (System-Assigned) |
| **Object ID** | `88b19c56-4a06-4e35-9a8d-129e30d1398c` |
| **Type** | System-Assigned Managed Identity |

#### Managed Identity Permissions

| Resource | Permission | Purpose |
|----------|------------|---------|
| Microsoft Graph | User.Read.All | Read user data |
| Microsoft Graph | GroupMember.Read.All | Read group membership |
| Microsoft Graph | Mail.Send | Send email reports |
| Exchange Online | Exchange.ManageAsApp | Manage mailbox DEP settings |
| DCR-TeamsPremiumLicenses | Monitoring Metrics Publisher | Ingest license data |
| DCR-CMKCompliance | Monitoring Metrics Publisher | Ingest CMK data |

### 4.3 Key Vault RBAC Assignments

| Principal | Role | Scope |
|-----------|------|-------|
| Current Admin User | Key Vault Crypto Officer | Both Key Vaults |
| Current Admin User | Key Vault Secrets Officer | Both Key Vaults |
| Compliance-Administrators | Key Vault Crypto Officer | Both Key Vaults |
| Compliance-Administrators | Key Vault Secrets Officer | Both Key Vaults |
| Exchange Online Service (00000002-0000-0ff1-ce00-000000000000) | Key Vault Crypto Service Encryption User | Both Key Vaults |

---

## 5. Monitoring Operations

### 5.1 Teams Premium License Monitoring

**Objective:** Track which users have Teams Premium licenses assigned

**Runbook:** `Sync-TeamsPremiumLicenses`

**Schedule:** Daily at 12:00 AM EST

**Data Collected:**

| Field | Description |
|-------|-------------|
| UserPrincipalName | User's email/UPN |
| DisplayName | User's display name |
| HasTeamsPremium | Boolean - license assigned |
| LastSignIn | Last Azure AD sign-in |
| AccountEnabled | Is account active |

**Email Report:** Sent to `Compliance-Administrators@leonardocompany.ca`

### 5.2 CMK Compliance Monitoring

**Objective:** Ensure all users in LCE-CMK-ENABLED-USERS group have DEP applied

**Runbook:** `Sync-CMKCompliance`

**Schedule:** Daily at 12:30 AM EST

**Features:**
- Auto-applies DEP to group members who don't have it
- Reports newly applied DEP assignments
- Shows organization delta (users not in CMK group)
- Tracks SharePoint/OneDrive CMK status (tenant-wide)

**Data Collected:**

| Field | Description |
|-------|-------------|
| UserPrincipalName | User's email/UPN |
| InCMKGroup | Is user in LCE-CMK-ENABLED-USERS |
| ExchangeTeamsCMK | Does user have DEP applied |
| DataEncryptionPolicy | Name of applied DEP |
| SharePointOneDriveCMK | Is tenant SPO CMK enabled |
| DEPAppliedThisRun | Was DEP applied in this sync |
| ComplianceStatus | Compliant/NonCompliant/NotInScope |

### 5.3 SharePoint/OneDrive CMK Status

**Type:** Tenant-wide (not per-user)

**Status:** Registered

**Key URIs:**
- Primary: `https://kv-cmk-spo-pri-1117.vault.azure.net/keys/spo-cmk-key`
- Secondary: `https://kv-cmk-spo-sec-1117.vault.azure.net/keys/spo-cmk-key`

**Verification Command:**
```powershell
Connect-SPOService -Url "https://leonardocompany-admin.sharepoint.com"
Get-SPODataEncryptionPolicy
```

---

## 6. Daily Operations Checklist

### 6.1 Morning Review (Within 1 hour of start of business)

- [ ] Check email inbox for overnight compliance reports
- [ ] Review CMK Compliance Report for any failed DEP applications
- [ ] Review Teams Premium License Report for unlicensed active users
- [ ] Check Azure Automation job history for failed runs

### 6.2 Verification Commands

```powershell
# Check recent Automation jobs
Get-AzAutomationJob -ResourceGroupName "rg-lce-monitoring" `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" |
    Where-Object { $_.EndTime -gt (Get-Date).AddDays(-1) } |
    Select-Object RunbookName, Status, StartTime, EndTime

# Quick CMK compliance check (Exchange Online)
Connect-ExchangeOnline
$total = (Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox).Count
$withDEP = (Get-Mailbox -ResultSize Unlimited | Where-Object { $_.DataEncryptionPolicy -eq "LCE-CMK-DEP" }).Count
Write-Host "CMK Compliance: $withDEP / $total ($([math]::Round($withDEP/$total*100,1))%)"
```

### 6.3 Weekly Tasks

- [ ] Review Log Analytics data retention and ingestion costs
- [ ] Verify Key Vault access logs for any unauthorized attempts
- [ ] Review Compliance-Administrators group membership
- [ ] Check for any new users added to LCE-CMK-ENABLED-USERS

### 6.4 Monthly Tasks

- [ ] Review and update runbook configurations if needed
- [ ] Audit Key Vault RBAC assignments
- [ ] Verify key backup files are stored securely
- [ ] Review email report distribution list

---

## 7. CMK Key Management Procedures

### 7.1 Key Rotation Procedure

**Frequency:** Annually or as required by security policy

**CRITICAL:** Key rotation for Customer Key requires Microsoft support engagement. Do NOT delete old keys without proper coordination.

#### Step 1: Create New Key Version

```powershell
# Connect to Azure
Connect-AzAccount -TenantId "80b1ce91-e920-49d4-a52e-4ab189c64592"

# Create new version in PRIMARY vault
Set-AzContext -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
$newPrimaryKey = Add-AzKeyVaultKey `
    -VaultName "kv-cmk-exo-pri-1117" `
    -Name "exo-cmk-key" `
    -Destination Software `
    -KeyType RSA `
    -Size 2048

Write-Host "New Primary Key Version: $($newPrimaryKey.Version)"

# Create new version in SECONDARY vault
Set-AzContext -SubscriptionId "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"
$newSecondaryKey = Add-AzKeyVaultKey `
    -VaultName "kv-cmk-exo-sec-1117" `
    -Name "exo-cmk-key" `
    -Destination Software `
    -KeyType RSA `
    -Size 2048

Write-Host "New Secondary Key Version: $($newSecondaryKey.Version)"
```

#### Step 2: Update DEP with New Keys

```powershell
Connect-ExchangeOnline

# Update the DEP to use new key versions
Set-DataEncryptionPolicy -Identity "LCE-CMK-DEP" `
    -Refresh `
    -AzureKeyIDs @($newPrimaryKey.Id, $newSecondaryKey.Id)

# Verify
Get-DataEncryptionPolicy -Identity "LCE-CMK-DEP" | Format-List Name, State, AzureKeyIDs
```

#### Step 3: Backup New Keys

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
```

### 7.2 Key Backup Procedure

**Frequency:** After every key creation/rotation

**Storage:** Secure offline storage (separate from Key Vault)

```powershell
# Full backup script
$backupPath = "C:\SecureBackups\CMK-Keys"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Exchange/Teams keys
Set-AzContext -SubscriptionId "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
Backup-AzKeyVaultKey -VaultName "kv-cmk-exo-pri-1117" -Name "exo-cmk-key" `
    -OutputFile "$backupPath\EXO-PRIMARY-$timestamp.backup"

Set-AzContext -SubscriptionId "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"
Backup-AzKeyVaultKey -VaultName "kv-cmk-exo-sec-1117" -Name "exo-cmk-key" `
    -OutputFile "$backupPath\EXO-SECONDARY-$timestamp.backup"

# SharePoint/OneDrive keys (if applicable)
# Backup-AzKeyVaultKey -VaultName "kv-cmk-spo-pri-1117" -Name "spo-cmk-key" ...

Write-Host "Backups saved to: $backupPath"
Write-Host "STORE THESE FILES SECURELY OFFLINE!"
```

### 7.3 Key Recovery Procedure

**WARNING:** Only perform key recovery in emergency situations with proper authorization.

```powershell
# Restore from backup
Restore-AzKeyVaultKey -VaultName "kv-cmk-exo-pri-1117" `
    -InputFile "C:\SecureBackups\CMK-Keys\EXO-PRIMARY-20251206.backup"
```

---

## 8. User Management Procedures

### 8.1 Adding Users to CMK Group

When a user needs CMK protection, add them to the **LCE-CMK-ENABLED-USERS** group:

#### Option A: Azure Portal

1. Go to **portal.azure.com**
2. Navigate to **Microsoft Entra ID** → **Groups**
3. Search for **LCE-CMK-ENABLED-USERS**
4. Click **Members** → **+ Add members**
5. Search and select the user(s)
6. Click **Select**

#### Option B: PowerShell

```powershell
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All"

$groupId = "36ba0617-d0a4-454a-b755-5207e34d275a"
$userId = (Get-MgUser -UserId "user@leonardocompany.ca").Id

New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId

Write-Host "User added to LCE-CMK-ENABLED-USERS. DEP will be applied overnight."
```

**Note:** The CMK runbook will automatically apply DEP to new group members during the next scheduled run (12:30 AM EST).

#### Immediate DEP Application

To apply DEP immediately without waiting for the scheduled run:

```powershell
Connect-ExchangeOnline
Set-Mailbox -Identity "user@leonardocompany.ca" -DataEncryptionPolicy "LCE-CMK-DEP"
```

### 8.2 Removing Users from CMK Group

**Note:** Removing a user from the group does NOT automatically remove DEP from their mailbox.

#### Remove from Group

```powershell
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All"

$groupId = "36ba0617-d0a4-454a-b755-5207e34d275a"
$userId = (Get-MgUser -UserId "user@leonardocompany.ca").Id

Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $userId
```

#### Remove DEP from Mailbox (if required)

```powershell
Connect-ExchangeOnline
Set-Mailbox -Identity "user@leonardocompany.ca" -DataEncryptionPolicy $null
```

### 8.3 Adding Users to Compliance-Administrators Group

The **Compliance-Administrators** group provides:
- Key Vault access (Crypto Officer, Secrets Officer roles)
- Email report recipients
- Administrative access to monitoring resources

#### Azure Portal Method

1. Go to **portal.azure.com**
2. Navigate to **Microsoft Entra ID** → **Groups**
3. Search for **Compliance-Administrators** (ID: `55ee252d-9a4c-4159-828f-a4e8fe98d3c5`)
4. Click **Members** → **+ Add members**
5. Search and select the user(s)
6. Click **Select**

#### PowerShell Method

```powershell
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All"

$groupId = "55ee252d-9a4c-4159-828f-a4e8fe98d3c5"
$userId = (Get-MgUser -UserId "newadmin@leonardocompany.ca").Id

New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId

Write-Host "User added to Compliance-Administrators."
Write-Host "They now have Key Vault access and will receive daily reports."
```

---

## 9. Troubleshooting Guide

### 9.1 Common Issues

#### Issue: Runbook Fails with "Authentication Error"

**Symptoms:** Runbook shows "Failed to authenticate" error

**Resolution:**
1. Verify Managed Identity is enabled on Automation Account
2. Check that required Graph permissions are assigned
3. Verify Exchange.ManageAsApp permission

```powershell
# Check Managed Identity permissions
$miObjectId = "88b19c56-4a06-4e35-9a8d-129e30d1398c"
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $miObjectId |
    Select-Object AppRoleId, ResourceDisplayName
```

#### Issue: DEP Not Being Applied

**Symptoms:** Users in group but DEP not applied

**Resolution:**
1. Verify DEP policy exists: `Get-DataEncryptionPolicy`
2. Check user has a mailbox: `Get-Mailbox -Identity user@domain.com`
3. Verify group membership
4. Check runbook logs for errors

```powershell
# Manual DEP application
Connect-ExchangeOnline
Set-Mailbox -Identity "user@leonardocompany.ca" -DataEncryptionPolicy "LCE-CMK-DEP"
```

#### Issue: "Data Encryption Policies are not enabled for your organization"

**Symptoms:** Cannot create DEP policy

**Resolution:** Customer Key must be enabled by Microsoft. See [Appendix C](#appendix-c-customer-key-enablement-request) for the support request template.

#### Issue: Key Vault Access Denied (403 Forbidden)

**Symptoms:** Cannot create keys, "Caller is not authorized"

**Resolution:** Key Vault uses RBAC authorization. Assign required roles:

```powershell
$userObjectId = "your-object-id"
$scope = "/subscriptions/6f114bd7.../resourceGroups/rg-cmk-exo-primary/providers/Microsoft.KeyVault/vaults/kv-cmk-exo-pri-1117"

New-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName "Key Vault Crypto Officer" -Scope $scope
New-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName "Key Vault Secrets Officer" -Scope $scope
```

#### Issue: Log Analytics Data Not Appearing

**Symptoms:** Tables empty, no data in workbook

**Resolution:**
1. Check DCR configuration
2. Verify Managed Identity has "Monitoring Metrics Publisher" on DCR
3. Check runbook output for ingestion errors

```kusto
// Check last ingestion time
TeamsPremiumLicenses_CL
| summarize LastIngestion = max(TimeGenerated)

CMKCompliance_CL
| summarize LastIngestion = max(TimeGenerated)
```

### 9.2 Verification Commands

```powershell
# Verify Automation Account modules
Get-AzAutomationModule -ResourceGroupName "rg-lce-monitoring" `
    -AutomationAccountName "AA-TeamsPremiumLicenseSync" `
    -RuntimeVersion "7.2" |
    Select-Object Name, ProvisioningState |
    Format-Table

# Verify Key Vault health
Get-AzKeyVault -VaultName "kv-cmk-exo-pri-1117" | 
    Select-Object VaultName, EnablePurgeProtection, EnableRbacAuthorization

# Verify DEP status
Connect-ExchangeOnline
Get-DataEncryptionPolicy | Format-List Name, State, Enabled, AzureKeyIDs

# Verify service principals exist
Connect-MgGraph -Scopes "Application.Read.All"
Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'" | 
    Select-Object DisplayName, Id
```

---

## 10. Escalation Procedures

### 10.1 Escalation Matrix

| Issue | Severity | First Contact | Escalation |
|-------|----------|---------------|------------|
| Runbook failure (single) | Low | LCE M365 Security Team | - |
| Runbook failure (repeated) | Medium | LCE M365 Security Team | Azure Support |
| Key Vault inaccessible | High | LCE M365 Security Team | Azure Support (Immediate) |
| CMK key compromised | Critical | Security Officer | CISO, Microsoft Support |
| Customer Key enablement | Medium | Microsoft Support | FastTrack |

### 10.2 Contact Information

| Role | Email/Contact |
|------|---------------|
| LCE M365 Security Team | Compliance-Administrators@leonardocompany.ca |
| Azure Support | portal.azure.com → Support |
| Microsoft 365 Support | admin.microsoft.com → Support |
| FastTrack | fasttrack.microsoft.com |

---

## Appendix A: Buildbook - Initial Setup

### A.1 Prerequisites

- Azure Subscription with Contributor access
- Global Administrator or Exchange Administrator role
- PowerShell 7.2+ with required modules:
  - Az.Accounts, Az.KeyVault, Az.Resources, Az.Automation
  - Microsoft.Graph
  - ExchangeOnlineManagement

### A.2 Complete CMK Setup Script

Use the **Setup-ExchangeCMK-Complete.ps1** script which:
- Creates Key Vaults (idempotent)
- Creates encryption keys (idempotent)
- Assigns RBAC roles (idempotent)
- Creates DEP policy (requires Customer Key enabled)

See uploaded file: `create-exo-key.ps1`

### A.3 Automation Account Setup

See uploaded file: `LCE-M365-MONITORING.md` for complete deployment steps.

### A.4 Register Service Principals

```powershell
Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Office 365 Exchange Online
$exoAppId = "00000002-0000-0ff1-ce00-000000000000"
$exoSP = Get-MgServicePrincipal -Filter "AppId eq '$exoAppId'" -ErrorAction SilentlyContinue

if ($exoSP) {
    Write-Host "[EXISTS] Office 365 Exchange Online: $($exoSP.DisplayName)"
} else {
    $exoSP = New-MgServicePrincipal -AppId $exoAppId
    Write-Host "[CREATED] Office 365 Exchange Online"
}

# Microsoft Exchange Online Protection
$eopAppId = "00000007-0000-0ff1-ce00-000000000000"
$eopSP = Get-MgServicePrincipal -Filter "AppId eq '$eopAppId'" -ErrorAction SilentlyContinue

if ($eopSP) {
    Write-Host "[EXISTS] Exchange Online Protection: $($eopSP.DisplayName)"
} else {
    $eopSP = New-MgServicePrincipal -AppId $eopAppId
    Write-Host "[CREATED] Exchange Online Protection"
}
```

---

## Appendix B: KQL Query Reference

### B.1 CMK Compliance Queries

```kusto
// Current CMK compliance status
CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where InCMKGroup == true
| summarize 
    Total = dcount(UserPrincipalName),
    Compliant = dcountif(UserPrincipalName, ExchangeTeamsCMK == true),
    NonCompliant = dcountif(UserPrincipalName, ExchangeTeamsCMK == false)
| extend ComplianceRate = round(100.0 * Compliant / Total, 1)

// Users who got DEP applied today
CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where DEPAppliedThisRun == true
| project TimeGenerated, UserPrincipalName, DisplayName

// CMK group members still missing DEP
CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where InCMKGroup == true and ExchangeTeamsCMK == false
| distinct UserPrincipalName, DisplayName

// Compliance trend over time
CMKCompliance_CL
| where InCMKGroup == true
| summarize 
    Total = dcount(UserPrincipalName),
    Compliant = dcountif(UserPrincipalName, ExchangeTeamsCMK == true)
    by bin(TimeGenerated, 1d)
| extend CompliancePercent = round(100.0 * Compliant / Total, 1)
| order by TimeGenerated desc

// Organization delta (users not in CMK group)
CMKCompliance_CL
| where TimeGenerated > ago(1d)
| where InCMKGroup == false
| distinct UserPrincipalName, DisplayName
```

### B.2 Teams Premium License Queries

```kusto
// Current license status
TeamsPremiumLicenses_CL
| where TimeGenerated > ago(1d)
| summarize 
    Total = dcount(UserPrincipalName),
    Licensed = dcountif(UserPrincipalName, HasTeamsPremium == true),
    Unlicensed = dcountif(UserPrincipalName, HasTeamsPremium == false)
| extend LicenseRate = round(100.0 * Licensed / Total, 1)

// Active users without Teams Premium
TeamsPremiumLicenses_CL
| where TimeGenerated > ago(1d)
| where HasTeamsPremium == false and AccountEnabled == true
| where LastSignIn > ago(30d)
| project UserPrincipalName, DisplayName, LastSignIn

// License assignment trend
TeamsPremiumLicenses_CL
| summarize 
    Licensed = dcountif(UserPrincipalName, HasTeamsPremium == true)
    by bin(TimeGenerated, 1d)
| order by TimeGenerated desc
```

### B.3 Sync Health Check

```kusto
// Last successful sync times
union
    (CMKCompliance_CL | summarize LastSync = max(TimeGenerated) | extend Table = "CMKCompliance_CL"),
    (TeamsPremiumLicenses_CL | summarize LastSync = max(TimeGenerated) | extend Table = "TeamsPremiumLicenses_CL")
| project Table, LastSync, HoursAgo = datetime_diff('hour', now(), LastSync)
```

---

## Appendix C: Customer Key Enablement Request

### C.1 When to Use

Use this template when you receive the error:
> "Data Encryption Policies are not enabled for your organization."

### C.2 Support Request Template

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

### C.3 Submission Methods

1. **Microsoft 365 Admin Center:** admin.microsoft.com → Support → New Service Request
2. **FastTrack Portal:** fasttrack.microsoft.com → Request Assistance
3. **Phone:** 1-800-865-9408 (Canada)

### C.4 Expected Timeline

| Stage | Duration |
|-------|----------|
| Ticket submitted | Day 0 |
| Microsoft acknowledgment | 1-2 business days |
| Feature enablement | 3-5 business days |
| Confirmation email | Upon completion |

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | LCE M365 Security Team | Initial release |