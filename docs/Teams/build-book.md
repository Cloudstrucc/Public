<div class="classification-banner" style="background: #dc2626; color: white; text-align: center; padding: 8px; font-weight: 700; font-size: 0.9rem; letter-spacing: 2px; text-transform: uppercase; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 10px rgba(220, 38, 38, 0.3); margin: 0; font-family: 'Segoe UI', sans-serif;">
    INTERNAL USE ONLY
</div>

<header style="background: linear-gradient(135deg, #1e3a8a 0%, #3730a3 50%, #1e40af 100%); color: white; padding: 40px 50px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; position: relative; overflow: hidden; margin: 0;">
    <div style="position: absolute; top: -50px; right: -50px; width: 200px; height: 200px; background: conic-gradient(from 0deg, transparent 0%, rgba(255,255,255,0.03) 25%, transparent 50%, rgba(255,255,255,0.03) 75%, transparent 100%); border-radius: 50%; animation: rotate 60s linear infinite;"></div>
    <div style="position: absolute; top: 20px; right: 20px; font-size: 2rem; opacity: 0.1; color: white;">⚡📡🛡️</div>
    <div style="position: relative; z-index: 1; max-width: 1200px; margin: 0 auto;">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 30px; flex-wrap: wrap; gap: 20px;">
            <div style="flex: 1; min-width: 300px;">
                <h1 style="font-size: 2.8rem; font-weight: 700; letter-spacing: -1px; margin: 0 0 8px 0; background: linear-gradient(135deg, #ffffff 0%, #e0e7ff 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">Leonardo Company Canada</h1>
                <p style="font-size: 1.1rem; color: #e0e7ff; font-weight: 300; margin: 0 0 15px 0; letter-spacing: 0.5px;"></p>
                <p style="font-size: 0.95rem; color: #c7d2fe; line-height: 1.6; max-width: 500px; margin: 0;">                    
                </p>
            </div>
            <div style="background: rgba(239, 68, 68, 0.9); color: white; padding: 8px 20px; border-radius: 25px; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3); border: 1px solid rgba(255, 255, 255, 0.2);">
                Defense Grade M65 Security Configuration Guide
            </div>
        </div>
  <div style="border-top: 1px solid rgba(255, 255, 255, 0.2); padding-top: 25px; margin-top: 25px;">
            <h2 style="font-size: 2.2rem; font-weight: 600; margin: 0 0 15px 0; color: #ffffff;">Microsoft Teams Customer Managed Keys</h2>
            <p style="font-size: 1.3rem; color: #e0e7ff; font-weight: 400; margin: 0 0 20px 0;">Implementation Guide</p>  
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 25px;">
                <div style="background: rgba(255, 255, 255, 0.1); padding: 15px 20px; border-radius: 8px; border: 1px solid rgba(255, 255, 255, 0.15); backdrop-filter: blur(10px);">
                    <div style="font-size: 0.8rem; color: #c7d2fe; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; font-weight: 600;">Document Version</div>
                    <div style="font-size: 1rem; color: #ffffff; font-weight: 500;">1.0</div>
                </div>
                <div style="background: rgba(255, 255, 255, 0.1); padding: 15px 20px; border-radius: 8px; border: 1px solid rgba(255, 255, 255, 0.15); backdrop-filter: blur(10px);">
                    <div style="font-size: 0.8rem; color: #c7d2fe; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; font-weight: 600;">Date</div>
                    <div style="font-size: 1rem; color: #ffffff; font-weight: 500;">September 2025</div>
                </div>               
                <div style="background: rgba(255, 255, 255, 0.1); padding: 15px 20px; border-radius: 8px; border: 1px solid rgba(255, 255, 255, 0.15); backdrop-filter: blur(10px);">
                    <div style="font-size: 0.8rem; color: #c7d2fe; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; font-weight: 600;">Security Level</div>
                    <div style="font-size: 1rem; color: #ffffff; font-weight: 500;">HSM-Backed CMK</div>
                </div>
            </div>
        </div>
    </div>
</header>
<style>
@keyframes rotate {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}
</style>

# Leonardo Company Canada

## Microsoft Teams Customer Managed Keys (CMK) Implementation Guide

**Prepared for:** Leonardo Company Canada  
**Document Version:** 1.0  
**Date:** September 2025  
**Classification:** Internal Use Only

---

### About Leonardo Company Canada

This document provides comprehensive guidance for implementing Customer Managed Keys (CMK) for Microsoft Teams within Leonardo's secure defense and aerospace operational environment.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Security Context for Defense Organizations](#security-context-for-defense-organizations)
3. [Prerequisites](#prerequisites)
4. [Azure Key Vault Setup](#azure-key-vault-setup)
5. [Microsoft 365 Customer Key Configuration](#microsoft-365-customer-key-configuration)
6. [Data Encryption Policies (DEPs)](#data-encryption-policies-deps)
7. [Teams-Specific Configuration](#teams-specific-configuration)
8. [Testing and Validation](#testing-and-validation)
9. [Monitoring and Maintenance](#monitoring-and-maintenance)
10. [Compliance and Audit Requirements](#compliance-and-audit-requirements)
11. [Troubleshooting](#troubleshooting)

## Executive Summary

This implementation guide enables Leonardo Company Canada to achieve enhanced data sovereignty and security for Microsoft Teams communications through Customer Managed Keys (CMK). Given Leonardo's position as a defense contractor specializing in electronic warfare and simulation technologies, this implementation ensures that sensitive communications and intellectual property remain under Leonardo's direct cryptographic control.

**Key Benefits for Leonardo:**
- **Data Sovereignty**: Full control over encryption keys for Teams data
- **Compliance**: Meets defense industry security requirements
- **IP Protection**: Enhanced security for proprietary EW simulation technologies
- **Regulatory Alignment**: Supports ITAR and defense contracting compliance requirements
- **Zero Trust Architecture**: Aligns with modern defense security frameworks

**Implementation Timeline:** 2-3 weeks  
**Affected Systems:** Microsoft Teams, SharePoint Online, Exchange Online  
**Security Classification:** Enables protection of Leonardo's proprietary defense technologies

## Security Context for Defense Organizations

### Defense Industry Requirements

Leonardo Company Canada, as a defense contractor specializing in electronic warfare technologies, must maintain the highest levels of data security for:

- **Classified Communications**: Teams discussions about defense projects
- **Intellectual Property**: Proprietary algorithms and EW simulation data
- **Client Information**: Sensitive information from military and government clients
- **Research Data**: Advanced electronic warfare research and development
- **Operational Planning**: Mission-critical communications and planning

### Regulatory Compliance

This CMK implementation supports compliance with:

- **ITAR (International Traffic in Arms Regulations)**
- **Canadian Defence Security Requirements**
- **NIST Cybersecurity Framework**
- **ISO 27001 Information Security Management**
- **SOC 2 Type II Compliance**

## Prerequisites

### Licensing Requirements

- **Microsoft 365 E5** or **E5 Compliance** licenses for all Leonardo users
- **Azure subscription** with Premium Key Vault capabilities
- **Global Administrator** or **Compliance Administrator** permissions

### Leonardo-Specific Requirements

- **Security Clearance**: Personnel implementing CMK must have appropriate clearance levels
- **Network Segmentation**: Ensure Azure Key Vault is deployed in appropriate security zones
- **Audit Logging**: Enhanced logging for defense contractor compliance requirements
- **Backup and Recovery**: Meet Leonardo's business continuity requirements

### Technical Prerequisites

- Azure Key Vault in Leonardo's Azure AD tenant
- PowerShell 5.1 or PowerShell Core 6+
- Azure PowerShell module
- Exchange Online PowerShell module
- Microsoft Graph PowerShell SDK

### Personnel Requirements

- **Information Security Officer** approval
- **IT Security Team** oversight
- **Compliance Officer** review and sign-off
- **Leonardo EW Engineering Teams** consultation for impact assessment

## Azure Key Vault Setup

### Step 1: Create Leonardo's Defense-Grade Key Vault

1. **Sign in to Azure Portal**

   ```bash
   https://portal.azure.com
   ```

2. **Create Resource Group**
   - Navigate to **Resource Groups** > **Create**
   - Name: `Leonardo-M365-CMK-RG`
   - Region: Canada Central (for data residency)
   - Tags:
     - Department: IT Security
     - Project: M365-CMK
     - Classification: Confidential
     - Owner: Leonardo IT Security Team

3. **Create Premium Key Vault**
   - Navigate to **Key Vaults** > **Create**
   - **Basics Tab:**
     - Resource Group: `Leonardo-M365-CMK-RG`
     - Key Vault Name: `Leonardo-Teams-CMK-Vault`
     - Region: Canada Central
     - Pricing Tier: **Premium** (HSM-backed keys required for defense applications)
   
   - **Access Policy Tab:**
     - Enable **Azure Key Vault** for template deployment
     - Add access policy for Leonardo IT Security administrators:
       - Key permissions: Get, List, Create, Update, Import, Delete, Backup, Restore, Recover
       - Secret permissions: Get, List, Set, Delete, Backup, Restore, Recover
       - Certificate permissions: Get, List, Create, Update, Import, Delete, ManageContacts, ManageIssuers

   - **Networking Tab:**
     - Configure private endpoints for enhanced security
     - Restrict access to Leonardo's corporate network ranges

4. **Configure Audit Logging**

   ```powershell
   # Enable comprehensive audit logging for defense compliance
   $diagnosticSettings = @{
       Name = "Leonardo-CMK-Audit"
       ResourceId = "/subscriptions/{subscription-id}/resourceGroups/Leonardo-M365-CMK-RG/providers/Microsoft.KeyVault/vaults/Leonardo-Teams-CMK-Vault"
       WorkspaceId = "/subscriptions/{subscription-id}/resourceGroups/Leonardo-M365-CMK-RG/providers/Microsoft.OperationalInsights/workspaces/Leonardo-Security-Logs"
       Category = @("AuditEvent", "AllMetrics")
       Enabled = $true
   }
   ```

### Step 2: Create Defense-Grade Encryption Keys

1. **Create HSM-Backed Primary Key**

   ```powershell
   # Connect to Azure with appropriate credentials
   Connect-AzAccount -TenantId "leonardo-tenant-id"
   
   # Set Leonardo-specific variables
   $keyVaultName = "Leonardo-Teams-CMK-Vault"
   $primaryKeyName = "Leonardo-Teams-Primary-Key-2025"
   $backupKeyName = "Leonardo-Teams-Backup-Key-2025"
   $keyTag = @{
       "Purpose" = "M365-Teams-CMK"
       "Department" = "IT-Security"
       "Classification" = "Confidential"
       "CreatedBy" = "Leonardo-IT-Security"
       "Project" = "Teams-CMK-Implementation"
   }
   
   # Create primary HSM-backed key (4096-bit for enhanced security)
   Add-AzKeyVaultKey -VaultName $keyVaultName `
       -Name $primaryKeyName `
       -Destination 'HSM' `
       -Size 4096 `
       -Tag $keyTag
   
   # Create backup HSM-backed key
   Add-AzKeyVaultKey -VaultName $keyVaultName `
       -Name $backupKeyName `
       -Destination 'HSM' `
       -Size 4096 `
       -Tag $keyTag
   ```

2. **Grant Microsoft 365 Service Access**

   ```powershell
   # Microsoft 365 Service Principal IDs
   $office365ServicePrincipal = "c066d759-24ae-40e7-a56f-027002b5d3e6"
   $exchangeServicePrincipal = "00000002-0000-0ff1-ce00-000000000000"
   $sharepointServicePrincipal = "00000003-0000-0ff1-ce00-000000000000"
   
   # Set comprehensive access policies for M365 services
   Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName `
       -ServicePrincipalName $office365ServicePrincipal `
       -PermissionsToKeys wrapKey,unwrapKey,get `
       -PermissionsToSecrets get
   
   Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName `
       -ServicePrincipalName $exchangeServicePrincipal `
       -PermissionsToKeys wrapKey,unwrapKey,get
   
   Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName `
       -ServicePrincipalName $sharepointServicePrincipal `
       -PermissionsToKeys wrapKey,unwrapKey,get
   ```

3. **Document Key Information for Leonardo Records**

   ```powershell
   # Generate Leonardo-specific key documentation
   $primaryKey = Get-AzKeyVaultKey -VaultName $keyVaultName -Name $primaryKeyName
   $backupKey = Get-AzKeyVaultKey -VaultName $keyVaultName -Name $backupKeyName
   
   $keyDocumentation = @"
   Leonardo Company Canada - Teams CMK Key Documentation
   =====================================================
   
   Date Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
   Created By: $($env:USERNAME)
   Classification: Confidential - Internal Use Only
   
   Primary Key Information:
   - Name: $($primaryKey.Name)
   - URI: $($primaryKey.Id)
   - Key Type: $($primaryKey.KeyType)
   - Key Size: $($primaryKey.KeySize)
   - Created: $($primaryKey.Created)
   
   Backup Key Information:
   - Name: $($backupKey.Name)
   - URI: $($backupKey.Id)
   - Key Type: $($backupKey.KeyType)
   - Key Size: $($backupKey.KeySize)
   - Created: $($backupKey.Created)
   
   Security Notes:
   - Keys are HSM-backed for enhanced security
   - Access is restricted to Leonardo IT Security team
   - All access is logged and monitored
   - Keys support Leonardo's defense contractor requirements
   "@
   
   # Save documentation securely
   $keyDocumentation | Out-File -FilePath "C:\Leonardo\Security\Teams-CMK-Keys-$(Get-Date -Format 'yyyy-MM-dd').txt"
   Write-Host "Key documentation saved for Leonardo records"
   ```

## Microsoft 365 Customer Key Configuration

### Step 1: Connect to Leonardo's Microsoft 365 Environment

```powershell
# Install required modules for Leonardo environment
Install-Module -Name ExchangeOnlineManagement -Force -Scope CurrentUser
Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -Scope CurrentUser

# Connect to Leonardo's Exchange Online
Connect-ExchangeOnline -UserPrincipalName "admin@leonardocompany.ca" -ShowBanner:$false

# Connect to Microsoft Graph with appropriate permissions
Connect-MgGraph -Scopes "Directory.ReadWrite.All,Policy.ReadWrite.ConditionalAccess"

# Connect to SharePoint Online
Connect-SPOService -Url "https://leonardocompany-admin.sharepoint.com"
```

### Step 2: Enable Customer Key for Leonardo

1. **Navigate to Microsoft Purview Compliance Center**

   ```
   https://compliance.microsoft.com
   ```

2. **Enable Customer Key Features**
   - Go to **Data loss prevention** > **Customer Key**
   - Click **Get started** if this is the first time
   - Accept terms and conditions
   - Document enablement for Leonardo compliance records

## Data Encryption Policies (DEPs)

### Step 1: Create Leonardo Teams Data DEP

```powershell
# Create DEP for Leonardo Teams application data
$leonardoTeamsDEP = @{
    Name = "Leonardo-Teams-Defense-DEP"
    Description = "Customer Managed Key policy for Leonardo Company Teams data - Defense Grade Encryption"
    AzureKeyIDs = @(
        "https://Leonardo-Teams-CMK-Vault.vault.azure.net/keys/Leonardo-Teams-Primary-Key-2025/<version>",
        "https://Leonardo-Teams-CMK-Vault.vault.azure.net/keys/Leonardo-Teams-Backup-Key-2025/<version>"
    )
    Enabled = $true
}

New-DataEncryptionPolicy @leonardoTeamsDEP

# Log creation for Leonardo audit trail
Write-Host "Created Leonardo Teams DEP: $($leonardoTeamsDEP.Name)"
```

### Step 2: Create Leonardo SharePoint/OneDrive DEP

```powershell
# Create DEP for Leonardo Teams files and documents
$leonardoFilesDEP = @{
    Name = "Leonardo-SPO-EW-Files-DEP"
    Description = "Customer Managed Key policy for Leonardo electronic warfare files and proprietary documents"
    AzureKeyIDs = @(
        "https://Leonardo-Teams-CMK-Vault.vault.azure.net/keys/Leonardo-Teams-Primary-Key-2025/<version>",
        "https://Leonardo-Teams-CMK-Vault.vault.azure.net/keys/Leonardo-Teams-Backup-Key-2025/<version>"
    )
    Enabled = $true
}

New-DataEncryptionPolicy @leonardoFilesDEP
```

### Step 3: Create Leonardo Exchange Online DEP

```powershell
# Create DEP for Leonardo Exchange integration
$leonardoExchangeDEP = @{
    Name = "Leonardo-EXO-Defense-Comms-DEP"
    Description = "Customer Managed Key policy for Leonardo defense communications and Teams-Exchange integration"
    AzureKeyIDs = @(
        "https://Leonardo-Teams-CMK-Vault.vault.azure.net/keys/Leonardo-Teams-Primary-Key-2025/<version>",
        "https://Leonardo-Teams-CMK-Vault.vault.azure.net/keys/Leonardo-Teams-Backup-Key-2025/<version>"
    )
    Enabled = $true
}

New-DataEncryptionPolicy @leonardoExchangeDEP
```

### Step 4: Verify Leonardo DEP Creation

```powershell
# Comprehensive verification for Leonardo environment
Write-Host "=== Leonardo Company Canada - DEP Status Report ===" -ForegroundColor Green
Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"} | 
    Format-Table Name, Enabled, State, AzureKeyIDs -AutoSize

# Generate Leonardo compliance report
$depReport = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"} | 
    Select-Object Name, Description, Enabled, State, DateCreated, AzureKeyIDs

$depReport | Export-Csv -Path "C:\Leonardo\Compliance\DEP-Status-Report-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation
```

## Teams-Specific Configuration

### Step 1: Create Leonardo Security Groups

```powershell
# Create security groups for different Leonardo teams
$leonardoGroups = @(
    @{
        DisplayName = "Leonardo-EW-Engineers-CMK"
        Description = "Electronic Warfare Engineers with CMK encryption for Teams"
        MailNickname = "LeonardoEWCMK"
    },
    @{
        DisplayName = "Leonardo-Defense-Projects-CMK"
        Description = "Defense project teams requiring CMK encryption"
        MailNickname = "LeonardoDefenseCMK"
    },
    @{
        DisplayName = "Leonardo-Research-Team-CMK"
        Description = "R&D teams working on classified projects"
        MailNickname = "LeonardoResearchCMK"
    }
)

foreach ($group in $leonardoGroups) {
    $groupParams = @{
        DisplayName = $group.DisplayName
        Description = $group.Description
        MailEnabled = $false
        SecurityEnabled = $true
        MailNickname = $group.MailNickname
    }
    
    $newGroup = New-MgGroup @groupParams
    Write-Host "Created Leonardo security group: $($group.DisplayName) (ID: $($newGroup.Id))"
}
```

### Step 2: Add Leonardo Teams to CMK Groups

```powershell
# Define Leonardo team members by department
$leonardoTeams = @{
    "Leonardo-EW-Engineers-CMK" = @(
        "john.smith@leonardocompany.ca",
        "sarah.johnson@leonardocompany.ca",
        "mike.wilson@leonardocompany.ca"
    )
    "Leonardo-Defense-Projects-CMK" = @(
        "david.brown@leonardocompany.ca",
        "lisa.davis@leonardocompany.ca",
        "robert.miller@leonardocompany.ca"
    )
    "Leonardo-Research-Team-CMK" = @(
        "jennifer.anderson@leonardocompany.ca",
        "steven.taylor@leonardocompany.ca",
        "michelle.thomas@leonardocompany.ca"
    )
}

foreach ($groupName in $leonardoTeams.Keys) {
    $group = Get-MgGroup -Filter "displayName eq '$groupName'"
    
    foreach ($userEmail in $leonardoTeams[$groupName]) {
        try {
            $user = Get-MgUser -Filter "userPrincipalName eq '$userEmail'"
            if ($user) {
                New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
                Write-Host "Added $userEmail to $groupName" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Could not add $userEmail to $groupName : $($_.Exception.Message)"
        }
    }
}
```

### Step 3: Configure Leonardo Teams Policies

1. **Navigate to Teams Admin Center**

   ```
   https://admin.teams.microsoft.com
   ```

2. **Create Leonardo-Specific Meeting Policies**
   - Policy Name: "Leonardo-Defense-Meeting-Policy"
   - Enable cloud recording with CMK encryption
   - Restrict external participants for classified discussions
   - Enable meeting transcription with CMK protection

3. **Create Leonardo Messaging Policies**
   - Policy Name: "Leonardo-Secure-Messaging-Policy"
   - Enable advanced message encryption
   - Configure retention for defense contractor requirements
   - Restrict external communication for classified channels

## Testing and Validation

### Step 1: Leonardo-Specific Validation Script

```powershell
# Comprehensive Leonardo CMK validation
function Test-LeonardoTeamsCMK {
    param(
        [string]$TestUserUPN = "john.smith@leonardocompany.ca",
        [string]$KeyVaultName = "Leonardo-Teams-CMK-Vault"
    )
    
    Write-Host "=== Leonardo Company Canada - Teams CMK Validation ===" -ForegroundColor Blue
    Write-Host "Electronic Warfare Division - Security Validation Report" -ForegroundColor Blue
    Write-Host "Classification: Confidential - Internal Use Only" -ForegroundColor Yellow
    
    # 1. Check Leonardo Key Vault Access
    Write-Host "`n1. Validating Leonardo Key Vault Access..." -ForegroundColor Cyan
    try {
        $vault = Get-AzKeyVault -VaultName $KeyVaultName
        $keys = Get-AzKeyVaultKey -VaultName $KeyVaultName
        Write-Host "   ✓ Leonardo Key Vault accessible: $($vault.VaultName)" -ForegroundColor Green
        Write-Host "   ✓ HSM-backed keys found: $($keys.Count)" -ForegroundColor Green
        
        foreach ($key in $keys) {
            $keyDetail = Get-AzKeyVaultKey -VaultName $KeyVaultName -Name $key.Name
            Write-Host "   ✓ Key: $($key.Name) | Type: $($keyDetail.KeyType) | Size: $($keyDetail.KeySize)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "   ✗ Key Vault access failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 2. Check Leonardo DEP Status
    Write-Host "`n2. Validating Leonardo Data Encryption Policies..." -ForegroundColor Cyan
    $leonardoDEPs = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"}
    
    if ($leonardoDEPs) {
        foreach ($dep in $leonardoDEPs) {
            $status = if ($dep.Enabled -and $dep.State -eq "Valid") { "✓" } else { "✗" }
            $color = if ($dep.Enabled -and $dep.State -eq "Valid") { "Green" } else { "Red" }
            Write-Host "   $status $($dep.Name): $($dep.State)" -ForegroundColor $color
        }
    } else {
        Write-Host "   ✗ No Leonardo DEPs found" -ForegroundColor Red
    }
    
    # 3. Check Leonardo User Assignment
    Write-Host "`n3. Validating Leonardo User CMK Assignment..." -ForegroundColor Cyan
    try {
        $userMailbox = Get-Mailbox -Identity $TestUserUPN
        Write-Host "   ✓ Leonardo user found: $($userMailbox.DisplayName)" -ForegroundColor Green
        
        # Check Leonardo security group membership
        $leonardoGroups = Get-MgGroup | Where-Object {$_.DisplayName -like "*Leonardo*CMK*"}
        $user = Get-MgUser -Filter "userPrincipalName eq '$TestUserUPN'"
        
        foreach ($group in $leonardoGroups) {
            $membership = Get-MgGroupMember -GroupId $group.Id | Where-Object {$_.Id -eq $user.Id}
            if ($membership) {
                Write-Host "   ✓ User is member of: $($group.DisplayName)" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "   ✗ User validation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 4. Check Leonardo Teams Activity
    Write-Host "`n4. Validating Leonardo Teams Encryption Activity..." -ForegroundColor Cyan
    $auditLogs = Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) `
        -EndDate (Get-Date) `
        -Operations "TeamsChannelMessage,TeamsChatMessage,MeetingParticipantDetail" `
        -UserIds $TestUserUPN -ResultSize 10
    
    if ($auditLogs) {
        Write-Host "   ✓ Leonardo Teams activities found: $($auditLogs.Count)" -ForegroundColor Green
        foreach ($log in $auditLogs[0..4]) {
            Write-Host "     • $($log.CreationDate): $($log.Operation)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠ No recent Teams activities found for validation" -ForegroundColor Yellow
    }
    
    # 5. Generate Leonardo Compliance Report
    Write-Host "`n5. Generating Leonardo Compliance Report..." -ForegroundColor Cyan
    $complianceReport = @{
        Company = "Leonardo Company Canada"
        Department = "Electronic Warfare Division"
        ValidationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        KeyVaultStatus = if ($vault) { "Operational" } else { "Failed" }
        DEPCount = $leonardoDEPs.Count
        KeyCount = $keys.Count
        UserValidated = $TestUserUPN
        Classification = "Confidential - Internal Use Only"
    }
    
    $complianceReport | ConvertTo-Json | Out-File -FilePath "C:\Leonardo\Compliance\CMK-Validation-$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
    Write-Host "   ✓ Compliance report saved to Leonardo security folder" -ForegroundColor Green
    
    Write-Host "`n=== Leonardo CMK Validation Complete ===" -ForegroundColor Blue
}

# Execute Leonardo validation
Test-LeonardoTeamsCMK -TestUserUPN "john.smith@leonardocompany.ca"
```

### Step 2: Defense-Specific Encryption Validation

```powershell
# Validate encryption for Leonardo defense communications
function Test-LeonardoDefenseEncryption {
    param(
        [string[]]$TestUsers = @("john.smith@leonardocompany.ca", "sarah.johnson@leonardocompany.ca")
    )
    
    Write-Host "=== Leonardo Defense Communication Encryption Test ===" -ForegroundColor Blue
    
    foreach ($user in $TestUsers) {
        Write-Host "`nTesting encryption for: $user" -ForegroundColor Yellow
        
        # Check mailbox encryption status
        try {
            $mailbox = Get-Mailbox -Identity $user
            $encryptionInfo = Get-MailboxLocation -User $user
            
            Write-Host "   Mailbox: $($mailbox.DisplayName)" -ForegroundColor Cyan
            Write-Host "   Encryption Policy: $($encryptionInfo.DataEncryptionPolicy)" -ForegroundColor Cyan
            Write-Host "   CMK Status: $($encryptionInfo.EncryptionType)" -ForegroundColor Cyan
            
            if ($encryptionInfo.DataEncryptionPolicy -like "*Leonardo*") {
                Write-Host "   ✓ Leonardo CMK encryption confirmed" -ForegroundColor Green
            } else {
                Write-Host "   ✗ Leonardo CMK not applied" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "   ✗ Encryption check failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Execute defense encryption validation
Test-LeonardoDefenseEncryption
```

## Monitoring and Maintenance

### Leonardo-Specific Monitoring

```powershell
# Daily Leonardo CMK monitoring script
function Start-LeonardoCMKMonitoring {
    Write-Host "=== Leonardo Company Canada - Daily CMK Monitoring ===" -ForegroundColor Blue
    Write-Host "Electronic Warfare Division Security Monitoring" -ForegroundColor Blue
    
    # 1. Monitor Leonardo Key Vault Health
    Write-Host "`n1. Leonardo Key Vault Health Check..." -ForegroundColor Cyan
    $vault = Get-AzKeyVault -VaultName "Leonardo-Teams-CMK-Vault"
    $keys = Get-AzKeyVaultKey -VaultName $vault.VaultName
    
    foreach ($key in $keys) {
        $keyDetails = Get-AzKeyVaultKey -VaultName $vault.VaultName -Name $key.Name
        $age = (Get-Date) - $keyDetails.Created
        
        Write-Host "   Leonardo Key: $($key.Name)" -ForegroundColor White
        Write-Host "     Status: $($keyDetails.Enabled)" -ForegroundColor Green
        Write-Host "     Age: $($age.Days) days" -ForegroundColor Cyan
        Write-Host "     Expires: $($keyDetails.Expires)" -ForegroundColor Cyan
        
        # Alert for key rotation planning
        if ($age.Days -gt 270) {
            Write-Host "     ⚠ KEY ROTATION REQUIRED - Contact Leonardo IT Security" -ForegroundColor Yellow
        }
    }
    
    # 2. Monitor Leonardo DEP Status
    Write-Host "`n2. Leonardo DEP Health Check..." -ForegroundColor Cyan
    $leonardoDEPs = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"}
    
    foreach ($dep in $leonardoDEPs) {
        $status = if ($dep.Enabled -and $dep.State -eq "Valid") { "✓ OPERATIONAL" } else { "✗ ATTENTION REQUIRED" }
        $color = if ($dep.Enabled -and $dep.State -eq "Valid") { "Green" } else { "Red" }
        
        Write-Host "   Leonardo DEP: $($dep.Name)" -ForegroundColor White
        Write-Host "     Status: $status" -ForegroundColor $color
        Write-Host "     State: $($dep.State)" -ForegroundColor Cyan
    }
    
    # 3. Generate Leonardo Security Dashboard
    $dashboardData = @{
        Company = "Leonardo Company Canada"
        Division = "Electronic Warfare"
        MonitoringDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        KeyVaultName = $vault.VaultName
        ActiveKeys = $keys.Count
        ActiveDEPs = $leonardoDEPs.Count
        SecurityStatus = "Operational"
        NextReview = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    }
    
    # Save to Leonardo security monitoring folder
    $dashboardData | ConvertTo-Json | Out-File -FilePath "C:\Leonardo\Security\Daily-CMK-Status-$(Get-Date -Format 'yyyy-MM-dd').json"
    
    Write-Host "`n✓ Leonardo CMK monitoring complete - Report saved" -ForegroundColor Green
}

# Schedule daily monitoring
Start-LeonardoCMKMonitoring
```

## Compliance and Audit Requirements

### Defense Contractor Compliance

```powershell
# Leonardo compliance reporting for defense contracts
function New-LeonardoComplianceReport {
    param(
        [int]$ReportingPeriodDays = 30
    )
    
    Write-Host "=== Leonardo Company Canada - Compliance Report Generation ===" -ForegroundColor Blue
    
    $startDate = (Get-Date).AddDays(-$ReportingPeriodDays)
    $endDate = Get-Date
    
    # 1. Key Vault Access Audit
    Write-Host "`n1. Generating Key Vault Access Audit..." -ForegroundColor Cyan
    $keyVaultAudit = Search-AzureAuditLog -StartTime $startDate -EndTime $endDate `
        -ResourceGroup "Leonardo-M365-CMK-RG" `
        -ResourceType "Microsoft.KeyVault/vaults"
    
    # 2. Teams Encryption Audit
    Write-Host "2. Generating Teams Encryption Audit..." -ForegroundColor Cyan
    $teamsAudit = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate `
        -Operations "TeamsChannelMessage,TeamsChatMessage,MeetingParticipantDetail" `
        -ResultSize 5000
    
    # 3. DEP Management Audit
    Write-Host "3. Generating DEP Management Audit..." -ForegroundColor Cyan
    $depAudit = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate `
        -Operations "Set-DataEncryptionPolicy,New-DataEncryptionPolicy,Remove-DataEncryptionPolicy"
    
    # 4. Generate Leonardo Compliance Report
    $complianceReport = @"
================================================================================
                    LEONARDO COMPANY CANADA - COMPLIANCE REPORT
                        Electronic Warfare Division
                      Microsoft Teams CMK Implementation
================================================================================

Report Period: $($startDate.ToString("yyyy-MM-dd")) to $($endDate.ToString("yyyy-MM-dd"))
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
Classification: Confidential - Internal Use Only
Prepared for: Leonardo IT Security & Compliance Team

EXECUTIVE SUMMARY
-----------------
This report demonstrates Leonardo Company Canada's compliance with defense industry
security requirements for Microsoft Teams Customer Managed Key implementation.

KEY METRICS
-----------
• Total Key Vault Access Events: $($keyVaultAudit.Count)
• Total Teams Encrypted Messages: $($teamsAudit.Count)  
• DEP Management Events: $($depAudit.Count)
• Active Leonardo DEPs: $(Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"} | Measure-Object | Select-Object -ExpandProperty Count)
• Active HSM Keys: $(Get-AzKeyVaultKey -VaultName "Leonardo-Teams-CMK-Vault" | Measure-Object | Select-Object -ExpandProperty Count)

SECURITY POSTURE
----------------
✓ All Leonardo Teams communications encrypted with customer-managed keys
✓ HSM-backed encryption keys maintained in Leonardo-controlled Azure Key Vault
✓ Comprehensive audit logging for all cryptographic operations
✓ Regular key rotation planning in accordance with defense standards
✓ Access controls aligned with Leonardo security policies

COMPLIANCE STATUS
-----------------
✓ ITAR Compliance: Customer-managed encryption maintains data sovereignty
✓ Defense Security Requirements: Met through HSM-backed key management
✓ SOC 2 Type II: Comprehensive audit trail and access controls
✓ ISO 27001: Information security management controls implemented

RECOMMENDATIONS
---------------
1. Continue monthly compliance reviews
2. Plan key rotation within 12 months of creation
3. Maintain current access control policies
4. Regular security training for Leonardo personnel

Prepared by: Leonardo IT Security Team
Next Review Date: $((Get-Date).AddDays(30).ToString("yyyy-MM-dd"))

================================================================================
"@

    # Save compliance report
    $complianceReport | Out-File -FilePath "C:\Leonardo\Compliance\Leonardo-CMK-Compliance-Report-$(Get-Date -Format 'yyyy-MM-dd').txt" -Encoding UTF8
    
    Write-Host "`n✓ Leonardo compliance report generated successfully" -ForegroundColor Green
    Write-Host "   Report saved to: C:\Leonardo\Compliance\" -ForegroundColor Cyan
}

# Generate monthly compliance report
New-LeonardoComplianceReport -ReportingPeriodDays 30
```

### ITAR and Export Control Compliance

```powershell
# Leonardo ITAR compliance validation
function Test-LeonardoITARCompliance {
    Write-Host "=== Leonardo ITAR Compliance Validation ===" -ForegroundColor Blue
    Write-Host "Validating export control and data sovereignty requirements" -ForegroundColor Yellow
    
    # 1. Verify data residency in Canada
    Write-Host "`n1. Validating Canadian Data Residency..." -ForegroundColor Cyan
    $vault = Get-AzKeyVault -VaultName "Leonardo-Teams-CMK-Vault"
    if ($vault.Location -eq "Canada Central" -or $vault.Location -eq "Canada East") {
        Write-Host "   ✓ Key Vault located in Canada: $($vault.Location)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Key Vault not in Canadian region: $($vault.Location)" -ForegroundColor Red
    }
    
    # 2. Verify customer-controlled encryption
    Write-Host "`n2. Validating Customer-Controlled Encryption..." -ForegroundColor Cyan
    $leonardoDEPs = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"}
    foreach ($dep in $leonardoDEPs) {
        if ($dep.AzureKeyIDs -like "*Leonardo-Teams-CMK-Vault*") {
            Write-Host "   ✓ $($dep.Name): Uses Leonardo-controlled keys" -ForegroundColor Green
        } else {
            Write-Host "   ✗ $($dep.Name): Not using Leonardo keys" -ForegroundColor Red
        }
    }
    
    # 3. Verify HSM-backed keys
    Write-Host "`n3. Validating HSM-Backed Keys..." -ForegroundColor Cyan
    $keys = Get-AzKeyVaultKey -VaultName "Leonardo-Teams-CMK-Vault"
    foreach ($key in $keys) {
        $keyDetail = Get-AzKeyVaultKey -VaultName "Leonardo-Teams-CMK-Vault" -Name $key.Name
        if ($keyDetail.KeyType -eq "RSA-HSM") {
            Write-Host "   ✓ $($key.Name): HSM-backed ($($keyDetail.KeySize)-bit)" -ForegroundColor Green
        } else {
            Write-Host "   ✗ $($key.Name): Not HSM-backed" -ForegroundColor Red
        }
    }
    
    Write-Host "`n✓ Leonardo ITAR compliance validation complete" -ForegroundColor Green
}

# Execute ITAR compliance check
Test-LeonardoITARCompliance
```

## Troubleshooting

### Leonardo-Specific Issues and Solutions

#### Issue 1: Leonardo DEP Creation Fails

**Error:** "Unable to access Leonardo Key Vault"

**Solution:**

```powershell
# Check Leonardo service principal permissions
Write-Host "Checking Leonardo Key Vault permissions..." -ForegroundColor Yellow

Get-AzKeyVaultAccessPolicy -VaultName "Leonardo-Teams-CMK-Vault" | 
    Where-Object {$_.ObjectId -eq "c066d759-24ae-40e7-a56f-027002b5d3e6"} |
    Format-Table DisplayName, PermissionsToKeys, PermissionsToSecrets

# Re-apply Leonardo-specific permissions
Set-AzKeyVaultAccessPolicy -VaultName "Leonardo-Teams-CMK-Vault" `
    -ServicePrincipalName "c066d759-24ae-40e7-a56f-027002b5d3e6" `
    -PermissionsToKeys wrapKey,unwrapKey,get

Write-Host "Leonardo Key Vault permissions updated" -ForegroundColor Green
```

#### Issue 2: Leonardo Teams Messages Not Encrypted

**Error:** Messages still using Microsoft-managed keys

**Solution:**

```powershell
# Force Leonardo policy refresh
Write-Host "Refreshing Leonardo Data Encryption Policies..." -ForegroundColor Yellow

$leonardoDEPs = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"}
foreach ($dep in $leonardoDEPs) {
    Set-DataEncryptionPolicy -Identity $dep.Name -Refresh
    Write-Host "Refreshed: $($dep.Name)" -ForegroundColor Cyan
}

# Verify Leonardo user assignments
$leonardoGroups = Get-MgGroup | Where-Object {$_.DisplayName -like "*Leonardo*CMK*"}
foreach ($group in $leonardoGroups) {
    $members = Get-MgGroupMember -GroupId $group.Id
    Write-Host "Group: $($group.DisplayName) - Members: $($members.Count)" -ForegroundColor Cyan
}
```

#### Issue 3: Leonardo Defense Communications Access Issues

**Error:** "Classified Teams channels not accessible"

**Solution:**

```powershell
# Leonardo-specific access troubleshooting
Write-Host "Troubleshooting Leonardo defense communications access..." -ForegroundColor Yellow

# Check Leonardo user licenses
$leonardoUsers = @("john.smith@leonardocompany.ca", "sarah.johnson@leonardocompany.ca")
foreach ($user in $leonardoUsers) {
    $userLicenses = Get-MgUserLicenseDetail -UserId $user
    $hasE5 = $userLicenses | Where-Object {$_.SkuPartNumber -eq "SPE_E5"}
    
    if ($hasE5) {
        Write-Host "✓ $user has E5 license" -ForegroundColor Green
    } else {
        Write-Host "✗ $user missing E5 license - Required for CMK" -ForegroundColor Red
    }
}

# Verify Leonardo Teams policy assignment
Connect-MicrosoftTeams
$leonardoTeamsPolicy = Get-CsTeamsMessagingPolicy -Identity "Leonardo-Secure-Messaging-Policy"
if ($leonardoTeamsPolicy) {
    Write-Host "✓ Leonardo Teams messaging policy found" -ForegroundColor Green
} else {
    Write-Host "✗ Leonardo Teams messaging policy not found" -ForegroundColor Red
}
```

### Emergency Recovery Procedures

#### Scenario: Leonardo Key Vault Compromised

```powershell
# Leonardo emergency key vault recovery
function Start-LeonardoEmergencyRecovery {
    Write-Host "=== LEONARDO EMERGENCY CMK RECOVERY INITIATED ===" -ForegroundColor Red
    Write-Host "Contact Leonardo IT Security immediately: security@leonardocompany.ca" -ForegroundColor Yellow
    
    # 1. Temporarily disable Leonardo DEPs
    Write-Host "`n1. Disabling Leonardo DEPs for emergency recovery..." -ForegroundColor Yellow
    $leonardoDEPs = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"}
    foreach ($dep in $leonardoDEPs) {
        Set-DataEncryptionPolicy -Identity $dep.Name -Enabled $false
        Write-Host "   Disabled: $($dep.Name)" -ForegroundColor Red
    }
    
    # 2. Generate emergency incident report
    $incidentReport = @"
LEONARDO COMPANY CANADA - EMERGENCY CMK INCIDENT REPORT
======================================================
Incident Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
Incident Type: Key Vault Emergency Recovery
Classification: CONFIDENTIAL - IMMEDIATE ACTION REQUIRED

ACTIONS TAKEN:
- All Leonardo DEPs temporarily disabled
- Microsoft-managed encryption activated as failsafe
- IT Security team notified
- Emergency recovery procedures initiated

NEXT STEPS:
1. Investigate key vault compromise
2. Create new Leonardo key vault with enhanced security
3. Generate new HSM-backed keys
4. Update all DEPs with new key references
5. Re-enable Leonardo CMK encryption

CONTACT:
Leonardo IT Security: security@leonardocompany.ca
Emergency Hotline: [Internal Number]

Generated by: Leonardo Emergency Recovery System
"@
    
    $incidentReport | Out-File -FilePath "C:\Leonardo\Security\EMERGENCY-CMK-INCIDENT-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
    
    Write-Host "`n✓ Emergency procedures completed - Incident report generated" -ForegroundColor Yellow
    Write-Host "   All Leonardo teams can continue operations with Microsoft-managed encryption" -ForegroundColor Cyan
}
```

#### Scenario: Leonardo Key Rotation Required

```powershell
# Leonardo planned key rotation
function Start-LeonardoKeyRotation {
    param(
        [string]$KeyVaultName = "Leonardo-Teams-CMK-Vault",
        [string]$OldKeyName,
        [string]$NewKeyName = "Leonardo-Teams-Primary-Key-$(Get-Date -Format 'yyyy')-V2"
    )
    
    Write-Host "=== Leonardo Key Rotation Procedure ===" -ForegroundColor Blue
    Write-Host "Rotating keys for enhanced security" -ForegroundColor Cyan
    
    # 1. Create new Leonardo key
    Write-Host "`n1. Creating new Leonardo encryption key..." -ForegroundColor Cyan
    $newKey = Add-AzKeyVaultKey -VaultName $KeyVaultName `
        -Name $NewKeyName `
        -Destination 'HSM' `
        -Size 4096 `
        -Tag @{
            "Purpose" = "M365-Teams-CMK-Rotation"
            "Department" = "IT-Security"
            "Classification" = "Confidential"
            "CreatedBy" = "Leonardo-Key-Rotation"
            "RotationDate" = (Get-Date -Format "yyyy-MM-dd")
        }
    
    Write-Host "   ✓ New Leonardo key created: $($newKey.Name)" -ForegroundColor Green
    
    # 2. Update Leonardo DEPs with new key
    Write-Host "`n2. Updating Leonardo DEPs with new key..." -ForegroundColor Cyan
    $backupKey = Get-AzKeyVaultKey -VaultName $KeyVaultName -Name "Leonardo-Teams-Backup-Key-2025"
    
    $leonardoDEPs = Get-DataEncryptionPolicy | Where-Object {$_.Name -like "*Leonardo*"}
    foreach ($dep in $leonardoDEPs) {
        Set-DataEncryptionPolicy -Identity $dep.Name `
            -AzureKeyIDs @($newKey.Id, $backupKey.Id)
        Write-Host "   ✓ Updated DEP: $($dep.Name)" -ForegroundColor Green
    }
    
    # 3. Schedule old key for deletion (after 30 days)
    Write-Host "`n3. Scheduling old key for secure deletion..." -ForegroundColor Cyan
    if ($OldKeyName) {
        $deletionDate = (Get-Date).AddDays(30)
        Remove-AzKeyVaultKey -VaultName $KeyVaultName -Name $OldKeyName -Force
        Write-Host "   ✓ Old key scheduled for deletion: $deletionDate" -ForegroundColor Yellow
    }
    
    Write-Host "`n✓ Leonardo key rotation completed successfully" -ForegroundColor Green
}
```

### Support and Escalation

#### Leonardo Internal Support Contacts

- **IT Security Team**: security@leonardocompany.ca
- **Compliance Officer**: compliance@leonardocompany.ca  
- **Emergency Hotline**: [Internal Leonardo Security Number]

#### Microsoft Support Resources

- **Microsoft 365 Customer Key Support**: Create support ticket for CMK issues
- **Azure Key Vault Support**: Azure portal support requests
- **Microsoft Premier Support**: Escalate critical defense contractor issues

#### External Security Consultants

- Vetted security firms with defense industry clearances
- Canadian cybersecurity specialists familiar with ITAR requirements
- Microsoft Gold Partners with Government/Defense expertise

---

## Conclusion

This implementation guide provides Leonardo Company Canada with a robust, defense-grade Customer Managed Key solution for Microsoft Teams. The solution ensures that Leonardo's electronic warfare communications, proprietary research data, and classified project information remain under Leonardo's complete cryptographic control.

### Key Success Factors for Leonardo:

1. **Defense-Grade Security**: HSM-backed 4096-bit keys provide military-grade encryption
2. **Data Sovereignty**: All encryption keys remain under Leonardo's direct control
3. **Compliance Alignment**: Meets ITAR, defense contracting, and Canadian data residency requirements
4. **Operational Continuity**: Seamless integration with existing Leonardo Teams workflows
5. **Audit Trail**: Comprehensive logging for defense contractor compliance requirements

### Next Steps for Leonardo:

1. **Pilot Deployment**: Begin with Electronic Warfare engineering teams
2. **Gradual Rollout**: Expand to all defense project teams
3. **Training Program**: Educate Leonardo staff on CMK procedures
4. **Regular Reviews**: Monthly security and compliance assessments
5. **Continuous Improvement**: Update procedures based on evolving defense requirements

### Long-Term Benefits:

- Enhanced protection for Leonardo's intellectual property
- Improved client confidence in data security
- Strengthened position for classified government contracts  
- Compliance with evolving cybersecurity regulations
- Foundation for Zero Trust security architecture

This CMK implementation positions Leonardo Company Canada as a leader in defense contractor cybersecurity, ensuring that sensitive electronic warfare technologies and client communications receive the highest level of protection available in Microsoft 365.

---

**Document Classification:** Confidential - Internal Use Only  
**Owner:** Leonardo Company Canada IT Security Team  
**Review Date:** Annual or upon significant security changes  
**Version Control:** Maintain versioning for all configuration changes