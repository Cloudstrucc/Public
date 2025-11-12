# Azure Customer Managed Keys (CMK) Configuration Guide v4
## For OneDrive, SharePoint Online, and Teams - User or Group Deployment
## Canadian Deployment with RBAC Configuration

This guide provides detailed configuration steps for implementing Azure Customer Managed Keys (CMK) for users or groups with E5 and Teams Premium licenses, using Azure Key Vault with RBAC method in Canadian regions.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup and Parameters](#initial-setup-and-parameters)
3. [Environment Authentication](#environment-authentication)
4. [Create Azure Subscriptions](#create-azure-subscriptions)
5. [Register Service Principals](#register-service-principals)
6. [Create Resource Groups](#create-resource-groups)
7. [Create Azure Key Vaults](#create-azure-key-vaults)
8. [Configure RBAC Permissions](#configure-rbac-permissions)
9. [Create Encryption Keys](#create-encryption-keys)
10. [Verify and Get Key URIs](#verify-and-get-key-uris)
11. [Onboard to Customer Key](#onboard-to-customer-key)
12. [Configure SharePoint/OneDrive](#configure-sharepointonedrive)
13. [Apply to Users or Groups](#apply-to-users-or-groups)
14. [Troubleshooting](#troubleshooting)
15. [Annex: Complete Automated Script](#annex-complete-automated-script)

---

## Prerequisites

### Required Licenses
- Microsoft 365 E5 or Office 365 E5 license (for all target users)
- Microsoft Teams Premium license (for all target users)
- **Two paid Azure subscriptions** (Free/Trial subscriptions are NOT eligible)

### Required Permissions
- Global Administrator or equivalent role in Microsoft 365
- Owner or User Access Administrator role on Azure subscriptions
- Azure PowerShell v4.4.0 or higher

### Critical Requirements
- **Two separate Azure subscriptions are mandatory** - Customer Key will not work with a single subscription
- Both subscriptions must be under the same Azure AD tenant as your Microsoft 365 organization
- All resources will be deployed in **Canada Central** and **Canada East** regions

---

## Initial Setup and Parameters

### Define Global Parameters
Save these parameters at the beginning of your session. Update the values according to your environment:

```powershell
# CRITICAL: Update these values before running any scripts
$global:CMKParams = @{
    # Tenant Configuration
    TenantId = "YOUR-M365-TENANT-ID"  # Replace with your M365 tenant ID
    
    # Subscription IDs (must be different)
    PrimarySubscriptionId = "YOUR-PRIMARY-SUBSCRIPTION-ID"    # Replace with first subscription ID
    SecondarySubscriptionId = "YOUR-SECONDARY-SUBSCRIPTION-ID" # Replace with second subscription ID
    
    # Regions
    PrimaryLocation = "Canada Central"
    SecondaryLocation = "Canada East"
    
    # Resource Naming Prefix (customize as needed)
    NamingPrefix = "cmk"
    
    # Target Configuration - Choose ONE of the following:
    # Option 1: For a single user
    TargetType = "User"  # Set to "User" or "Group"
    TargetUserEmail = "fred.pearson@leonardocompany.ca"  # Replace with target user email
    
    # Option 2: For an Entra ID group
    # TargetType = "Group"
    # TargetGroupName = "CMK-Enabled-Users"  # Replace with your Entra ID group name
    # TargetGroupId = "GROUP-OBJECT-ID"  # Optional - will be looked up if not provided
    
    # Backup Location
    BackupPath = "$HOME/keybackups"
}

# Validate target configuration
if ($global:CMKParams.TargetType -eq "Group" -and -not $global:CMKParams.ContainsKey("TargetGroupName")) {
    Write-Error "TargetGroupName must be specified when TargetType is 'Group'"
    return
}

# Display parameters for verification
Write-Host "`nCustomer Key Configuration Parameters:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
$global:CMKParams.GetEnumerator() | Where-Object { $_.Value } | Sort-Object Name | Format-Table -AutoSize

# Create backup directory
mkdir -p $global:CMKParams.BackupPath
```

### Initialize Resource Names
```powershell
# Generate consistent resource names
$global:ResourceNames = @{
    # Resource Groups
    PrimaryRGMultiworkload = "rg-$($global:CMKParams.NamingPrefix)-primary-multiworkload"
    PrimaryRGSharePoint = "rg-$($global:CMKParams.NamingPrefix)-primary-sharepoint"
    SecondaryRGMultiworkload = "rg-$($global:CMKParams.NamingPrefix)-secondary-multiworkload"
    SecondaryRGSharePoint = "rg-$($global:CMKParams.NamingPrefix)-secondary-sharepoint"
    
    # Key Vault Names (will append random numbers for uniqueness)
    KVPrefixM365Primary = "kv-$($global:CMKParams.NamingPrefix)-m365-pri"
    KVPrefixSPOPrimary = "kv-$($global:CMKParams.NamingPrefix)-spo-pri"
    KVPrefixM365Secondary = "kv-$($global:CMKParams.NamingPrefix)-m365-sec"
    KVPrefixSPOSecondary = "kv-$($global:CMKParams.NamingPrefix)-spo-sec"
    
    # Key Names
    M365KeyPrimaryName = "m365-customer-key-primary"
    M365KeySecondaryName = "m365-customer-key-secondary"
    SPOKeyPrimaryName = "spo-customer-key-primary"
    SPOKeySecondaryName = "spo-customer-key-secondary"
    
    # DEP Name
    DEPName = "CMK-DEP-$(Get-Date -Format 'yyyyMMdd')"
}
```

---

## Environment Authentication

### Connect to Azure with Correct Tenant
```powershell
# Clear any existing contexts
Clear-AzContext -Force

# Connect to the specified tenant
if ($env:AZURE_HTTP_USER_AGENT -like "*cloud-shell*") {
    # Running in Azure Cloud Shell - use device authentication
    Connect-AzAccount -TenantId $global:CMKParams.TenantId -UseDeviceAuthentication
} else {
    # Running locally
    Connect-AzAccount -TenantId $global:CMKParams.TenantId
}

# Verify connection
$context = Get-AzContext
if ($context.Tenant.Id -ne $global:CMKParams.TenantId) {
    Write-Error "Connected to wrong tenant. Expected: $($global:CMKParams.TenantId), Got: $($context.Tenant.Id)"
    return
}

Write-Host "Successfully connected to tenant: $($context.Tenant.Id)" -ForegroundColor Green
```

---

## Create Azure Subscriptions

### Verify Two Subscriptions Exist
```powershell
# Get subscriptions in the tenant
$subscriptions = Get-AzSubscription | Where-Object State -eq "Enabled"

# Verify primary subscription exists
$primarySub = $subscriptions | Where-Object Id -eq $global:CMKParams.PrimarySubscriptionId
if (-not $primarySub) {
    Write-Error "Primary subscription not found: $($global:CMKParams.PrimarySubscriptionId)"
    Write-Host "Available subscriptions:" -ForegroundColor Yellow
    $subscriptions | Select-Object Name, Id | Format-Table
    return
}

# Verify secondary subscription exists
$secondarySub = $subscriptions | Where-Object Id -eq $global:CMKParams.SecondarySubscriptionId
if (-not $secondarySub) {
    Write-Error "Secondary subscription not found: $($global:CMKParams.SecondarySubscriptionId)"
    Write-Host "Available subscriptions:" -ForegroundColor Yellow
    $subscriptions | Select-Object Name, Id | Format-Table
    return
}

# Verify they are different
if ($global:CMKParams.PrimarySubscriptionId -eq $global:CMKParams.SecondarySubscriptionId) {
    Write-Error "Primary and Secondary subscription IDs must be different!"
    return
}

Write-Host "Subscription verification passed:" -ForegroundColor Green
Write-Host "  Primary: $($primarySub.Name) ($($primarySub.Id))" -ForegroundColor Cyan
Write-Host "  Secondary: $($secondarySub.Name) ($($secondarySub.Id))" -ForegroundColor Cyan
```

---

## Register Service Principals

### Function to Register Service Principals
```powershell
function Register-CMKServicePrincipal {
    param (
        [string]$ApplicationId,
        [string]$DisplayName
    )
    
    $sp = Get-AzADServicePrincipal -ApplicationId $ApplicationId -ErrorAction SilentlyContinue
    if (-not $sp) {
        Write-Host "Registering $DisplayName..." -ForegroundColor Yellow
        New-AzADServicePrincipal -ApplicationId $ApplicationId | Out-Null
        Write-Host "✓ $DisplayName registered successfully" -ForegroundColor Green
    } else {
        Write-Host "✓ $DisplayName already registered" -ForegroundColor Green
    }
}
```

### Register Required Applications
```powershell
# Service principal registration is tenant-wide, only needs to be done once
Write-Host "`nRegistering required service principals..." -ForegroundColor Cyan

# Customer Key Onboarding Application
Register-CMKServicePrincipal -ApplicationId "19f7f505-34aa-44a4-9dcc-6a768854d2ea" -DisplayName "Customer Key Onboarding"

# M365DataAtRestEncryption Application
Register-CMKServicePrincipal -ApplicationId "c066d759-24ae-40e7-a56f-027002b5d3e4" -DisplayName "M365DataAtRestEncryption"

# Office 365 SharePoint Online Application
Register-CMKServicePrincipal -ApplicationId "00000003-0000-0ff1-ce00-000000000000" -DisplayName "Office 365 SharePoint Online"
```

---

## Create Resource Groups

### Create Primary Resource Groups
```powershell
Write-Host "`nCreating resource groups..." -ForegroundColor Cyan

# Select primary subscription
Select-AzSubscription -SubscriptionId $global:CMKParams.PrimarySubscriptionId | Out-Null

# Create primary resource groups
New-AzResourceGroup -Name $global:ResourceNames.PrimaryRGMultiworkload -Location $global:CMKParams.PrimaryLocation -Force | Out-Null
Write-Host "✓ Created: $($global:ResourceNames.PrimaryRGMultiworkload) in $($global:CMKParams.PrimaryLocation)" -ForegroundColor Green

New-AzResourceGroup -Name $global:ResourceNames.PrimaryRGSharePoint -Location $global:CMKParams.PrimaryLocation -Force | Out-Null
Write-Host "✓ Created: $($global:ResourceNames.PrimaryRGSharePoint) in $($global:CMKParams.PrimaryLocation)" -ForegroundColor Green
```

### Create Secondary Resource Groups
```powershell
# Select secondary subscription
Select-AzSubscription -SubscriptionId $global:CMKParams.SecondarySubscriptionId | Out-Null

# Create secondary resource groups
New-AzResourceGroup -Name $global:ResourceNames.SecondaryRGMultiworkload -Location $global:CMKParams.SecondaryLocation -Force | Out-Null
Write-Host "✓ Created: $($global:ResourceNames.SecondaryRGMultiworkload) in $($global:CMKParams.SecondaryLocation)" -ForegroundColor Green

New-AzResourceGroup -Name $global:ResourceNames.SecondaryRGSharePoint -Location $global:CMKParams.SecondaryLocation -Force | Out-Null
Write-Host "✓ Created: $($global:ResourceNames.SecondaryRGSharePoint) in $($global:CMKParams.SecondaryLocation)" -ForegroundColor Green
```

---

## Create Azure Key Vaults

### Initialize Key Vault Names Storage
```powershell
$global:KeyVaultNames = @{}
```

### Create Primary Key Vaults
```powershell
Write-Host "`nCreating Key Vaults..." -ForegroundColor Cyan

# Select primary subscription
Select-AzSubscription -SubscriptionId $global:CMKParams.PrimarySubscriptionId | Out-Null

# Create Key Vault for Multiple Workloads
$kvNameM365Primary = "$($global:ResourceNames.KVPrefixM365Primary)-$(Get-Random -Maximum 9999)"
$kvM365Primary = New-AzKeyVault `
    -Name $kvNameM365Primary `
    -ResourceGroupName $global:ResourceNames.PrimaryRGMultiworkload `
    -Location $global:CMKParams.PrimaryLocation `
    -SKU Premium `
    -EnablePurgeProtection `
    -SoftDeleteRetentionInDays 90

$global:KeyVaultNames.M365Primary = $kvNameM365Primary
Write-Host "✓ Created Key Vault: $kvNameM365Primary" -ForegroundColor Green

# Create Key Vault for SharePoint/OneDrive
$kvNameSPOPrimary = "$($global:ResourceNames.KVPrefixSPOPrimary)-$(Get-Random -Maximum 9999)"
$kvSPOPrimary = New-AzKeyVault `
    -Name $kvNameSPOPrimary `
    -ResourceGroupName $global:ResourceNames.PrimaryRGSharePoint `
    -Location $global:CMKParams.PrimaryLocation `
    -SKU Premium `
    -EnablePurgeProtection `
    -SoftDeleteRetentionInDays 90

$global:KeyVaultNames.SPOPrimary = $kvNameSPOPrimary
Write-Host "✓ Created Key Vault: $kvNameSPOPrimary" -ForegroundColor Green
```

### Create Secondary Key Vaults
```powershell
# Select secondary subscription
Select-AzSubscription -SubscriptionId $global:CMKParams.SecondarySubscriptionId | Out-Null

# Create Key Vault for Multiple Workloads
$kvNameM365Secondary = "$($global:ResourceNames.KVPrefixM365Secondary)-$(Get-Random -Maximum 9999)"
$kvM365Secondary = New-AzKeyVault `
    -Name $kvNameM365Secondary `
    -ResourceGroupName $global:ResourceNames.SecondaryRGMultiworkload `
    -Location $global:CMKParams.SecondaryLocation `
    -SKU Premium `
    -EnablePurgeProtection `
    -SoftDeleteRetentionInDays 90

$global:KeyVaultNames.M365Secondary = $kvNameM365Secondary
Write-Host "✓ Created Key Vault: $kvNameM365Secondary" -ForegroundColor Green

# Create Key Vault for SharePoint/OneDrive
$kvNameSPOSecondary = "$($global:ResourceNames.KVPrefixSPOSecondary)-$(Get-Random -Maximum 9999)"
$kvSPOSecondary = New-AzKeyVault `
    -Name $kvNameSPOSecondary `
    -ResourceGroupName $global:ResourceNames.SecondaryRGSharePoint `
    -Location $global:CMKParams.SecondaryLocation `
    -SKU Premium `
    -EnablePurgeProtection `
    -SoftDeleteRetentionInDays 90

$global:KeyVaultNames.SPOSecondary = $kvNameSPOSecondary
Write-Host "✓ Created Key Vault: $kvNameSPOSecondary" -ForegroundColor Green
```

**Note**: Vault names must be globally unique, so we append random numbers.

---

## Configure RBAC Permissions

### Get Current User Identity
```powershell
Write-Host "`nConfiguring RBAC permissions..." -ForegroundColor Cyan

$currentUser = Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id
$userId = $currentUser.Id
Write-Host "Current user: $($currentUser.UserPrincipalName)" -ForegroundColor Yellow
```

### Assign Key Vault Administrator Role
```powershell
# Function to assign Key Vault Administrator role
function Set-KeyVaultAdminRole {
    param (
        [string]$SubscriptionId,
        [string]$ResourceGroup,
        [string]$VaultName,
        [string]$ObjectId
    )
    
    Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
    
    $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.KeyVault/vaults/$VaultName"
    
    New-AzRoleAssignment `
        -ObjectId $ObjectId `
        -RoleDefinitionName "Key Vault Administrator" `
        -Scope $scope `
        -ErrorAction SilentlyContinue | Out-Null
        
    Write-Host "✓ Key Vault Administrator role assigned on: $VaultName" -ForegroundColor Green
}

# Assign to all vaults
Set-KeyVaultAdminRole -SubscriptionId $global:CMKParams.PrimarySubscriptionId -ResourceGroup $global:ResourceNames.PrimaryRGMultiworkload -VaultName $global:KeyVaultNames.M365Primary -ObjectId $userId
Set-KeyVaultAdminRole -SubscriptionId $global:CMKParams.PrimarySubscriptionId -ResourceGroup $global:ResourceNames.PrimaryRGSharePoint -VaultName $global:KeyVaultNames.SPOPrimary -ObjectId $userId
Set-KeyVaultAdminRole -SubscriptionId $global:CMKParams.SecondarySubscriptionId -ResourceGroup $global:ResourceNames.SecondaryRGMultiworkload -VaultName $global:KeyVaultNames.M365Secondary -ObjectId $userId
Set-KeyVaultAdminRole -SubscriptionId $global:CMKParams.SecondarySubscriptionId -ResourceGroup $global:ResourceNames.SecondaryRGSharePoint -VaultName $global:KeyVaultNames.SPOSecondary -ObjectId $userId

Write-Host "Waiting 60 seconds for role assignments to propagate..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
```

### Assign Service Principal Permissions
```powershell
# Function to assign Crypto Service Encryption User role
function Set-CryptoServiceRole {
    param (
        [string]$SubscriptionId,
        [string]$ResourceGroup,
        [string]$VaultName,
        [string]$ServicePrincipalName
    )
    
    Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
    
    $sp = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
    if ($sp) {
        $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.KeyVault/vaults/$VaultName"
        
        New-AzRoleAssignment `
            -ObjectId $sp.Id `
            -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
            -Scope $scope `
            -ErrorAction SilentlyContinue | Out-Null
            
        Write-Host "✓ Crypto Service Encryption User role assigned to $ServicePrincipalName on: $VaultName" -ForegroundColor Green
    }
}

# Assign M365DataAtRestEncryption permissions
Set-CryptoServiceRole -SubscriptionId $global:CMKParams.PrimarySubscriptionId -ResourceGroup $global:ResourceNames.PrimaryRGMultiworkload -VaultName $global:KeyVaultNames.M365Primary -ServicePrincipalName "M365DataAtRestEncryption"
Set-CryptoServiceRole -SubscriptionId $global:CMKParams.SecondarySubscriptionId -ResourceGroup $global:ResourceNames.SecondaryRGMultiworkload -VaultName $global:KeyVaultNames.M365Secondary -ServicePrincipalName "M365DataAtRestEncryption"

# Assign Office 365 SharePoint Online permissions
Set-CryptoServiceRole -SubscriptionId $global:CMKParams.PrimarySubscriptionId -ResourceGroup $global:ResourceNames.PrimaryRGSharePoint -VaultName $global:KeyVaultNames.SPOPrimary -ServicePrincipalName "Office 365 SharePoint Online"
Set-CryptoServiceRole -SubscriptionId $global:CMKParams.SecondarySubscriptionId -ResourceGroup $global:ResourceNames.SecondaryRGSharePoint -VaultName $global:KeyVaultNames.SPOSecondary -ServicePrincipalName "Office 365 SharePoint Online"
```

---

## Create Encryption Keys

### Initialize Key URIs Storage
```powershell
$global:KeyURIs = @{}
```

### Create Primary Keys
```powershell
Write-Host "`nCreating encryption keys..." -ForegroundColor Cyan

# Select primary subscription
Select-AzSubscription -SubscriptionId $global:CMKParams.PrimarySubscriptionId | Out-Null

# Create M365 primary key
$m365KeyPrimary = Add-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.M365Primary `
    -Name $global:ResourceNames.M365KeyPrimaryName `
    -Destination "HSM" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date)

$global:KeyURIs.M365Primary = $m365KeyPrimary.Id.ToString()
Write-Host "✓ Created M365 primary key" -ForegroundColor Green

# Backup the key
Backup-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.M365Primary `
    -Name $global:ResourceNames.M365KeyPrimaryName `
    -OutputFile "$($global:CMKParams.BackupPath)/m365-key-primary-backup.blob" `
    -Force

# Create SPO primary key
$spoKeyPrimary = Add-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.SPOPrimary `
    -Name $global:ResourceNames.SPOKeyPrimaryName `
    -Destination "HSM" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date)

$global:KeyURIs.SPOPrimary = $spoKeyPrimary.Id.ToString()
Write-Host "✓ Created SPO primary key" -ForegroundColor Green

# Backup the key
Backup-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.SPOPrimary `
    -Name $global:ResourceNames.SPOKeyPrimaryName `
    -OutputFile "$($global:CMKParams.BackupPath)/spo-key-primary-backup.blob" `
    -Force
```

### Create Secondary Keys
```powershell
# Select secondary subscription
Select-AzSubscription -SubscriptionId $global:CMKParams.SecondarySubscriptionId | Out-Null

# Create M365 secondary key
$m365KeySecondary = Add-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.M365Secondary `
    -Name $global:ResourceNames.M365KeySecondaryName `
    -Destination "HSM" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date)

$global:KeyURIs.M365Secondary = $m365KeySecondary.Id.ToString()
Write-Host "✓ Created M365 secondary key" -ForegroundColor Green

# Backup the key
Backup-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.M365Secondary `
    -Name $global:ResourceNames.M365KeySecondaryName `
    -OutputFile "$($global:CMKParams.BackupPath)/m365-key-secondary-backup.blob" `
    -Force

# Create SPO secondary key
$spoKeySecondary = Add-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.SPOSecondary `
    -Name $global:ResourceNames.SPOKeySecondaryName `
    -Destination "HSM" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date)

$global:KeyURIs.SPOSecondary = $spoKeySecondary.Id.ToString()
Write-Host "✓ Created SPO secondary key" -ForegroundColor Green

# Backup the key
Backup-AzKeyVaultKey `
    -VaultName $global:KeyVaultNames.SPOSecondary `
    -Name $global:ResourceNames.SPOKeySecondaryName `
    -OutputFile "$($global:CMKParams.BackupPath)/spo-key-secondary-backup.blob" `
    -Force
```

**Important**: If you need to use Software keys instead of HSM, change `-Destination "HSM"` to `-Destination "Software"`.

---

## Verify and Get Key URIs

### Display Configuration Summary
```powershell
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Customer Key Configuration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nKey Vault Names:" -ForegroundColor Yellow
$global:KeyVaultNames.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize

Write-Host "`nKey URIs:" -ForegroundColor Yellow
$global:KeyURIs.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)" -ForegroundColor Cyan
}

# Save configuration to file
$targetInfo = if ($global:CMKParams.TargetType -eq "User") {
    "TARGET USER: $($global:CMKParams.TargetUserEmail)"
} else {
    "TARGET GROUP: $($global:CMKParams.TargetGroupName)"
}

$configContent = @"
Customer Key Configuration - Generated $(Get-Date)
================================================

TENANT INFORMATION:
Tenant ID: $($global:CMKParams.TenantId)

SUBSCRIPTION IDS:
Primary: $($global:CMKParams.PrimarySubscriptionId)
Secondary: $($global:CMKParams.SecondarySubscriptionId)

KEY VAULT NAMES:
M365 Primary: $($global:KeyVaultNames.M365Primary)
M365 Secondary: $($global:KeyVaultNames.M365Secondary)
SPO Primary: $($global:KeyVaultNames.SPOPrimary)
SPO Secondary: $($global:KeyVaultNames.SPOSecondary)

KEY URIS:
M365 Primary: $($global:KeyURIs.M365Primary)
M365 Secondary: $($global:KeyURIs.M365Secondary)
SPO Primary: $($global:KeyURIs.SPOPrimary)
SPO Secondary: $($global:KeyURIs.SPOSecondary)

TARGET TYPE: $($global:CMKParams.TargetType)
$targetInfo
"@

$configContent | Out-File "$($global:CMKParams.BackupPath)/cmk-configuration.txt"
Write-Host "`nConfiguration saved to: $($global:CMKParams.BackupPath)/cmk-configuration.txt" -ForegroundColor Green
```

---

## Onboard to Customer Key

### Install Onboarding Module
```powershell
Write-Host "`nInstalling Customer Key Onboarding module..." -ForegroundColor Cyan

if (-not (Get-Module -ListAvailable -Name M365CustomerKeyOnboarding)) {
    Install-Module -Name M365CustomerKeyOnboarding -Force -AllowClobber
}

Import-Module M365CustomerKeyOnboarding
Write-Host "✓ Module loaded successfully" -ForegroundColor Green
```

### Grant Reader Access for Validation
```powershell
# Grant Reader role on both subscriptions
Select-AzSubscription -SubscriptionId $global:CMKParams.PrimarySubscriptionId | Out-Null
New-AzRoleAssignment -ObjectId $userId -RoleDefinitionName "Reader" -Scope "/subscriptions/$($global:CMKParams.PrimarySubscriptionId)" -ErrorAction SilentlyContinue | Out-Null

Select-AzSubscription -SubscriptionId $global:CMKParams.SecondarySubscriptionId | Out-Null
New-AzRoleAssignment -ObjectId $userId -RoleDefinitionName "Reader" -Scope "/subscriptions/$($global:CMKParams.SecondarySubscriptionId)" -ErrorAction SilentlyContinue | Out-Null

Write-Host "✓ Reader access granted for validation" -ForegroundColor Green
Start-Sleep -Seconds 30
```

### Validate Configuration
```powershell
Write-Host "`nValidating Customer Key configuration..." -ForegroundColor Cyan

$validationRequest = New-CustomerKeyOnboardingRequest `
    -Organization $global:CMKParams.TenantId `
    -Scenario MDEP `
    -Subscription1 $global:CMKParams.PrimarySubscriptionId `
    -KeyIdentifier1 $global:KeyURIs.M365Primary `
    -Subscription2 $global:CMKParams.SecondarySubscriptionId `
    -KeyIdentifier2 $global:KeyURIs.M365Secondary `
    -OnboardingMode Validate

if ($validationRequest.ValidationResult -eq "Success") {
    Write-Host "✓ Validation passed successfully!" -ForegroundColor Green
} else {
    Write-Host "✗ Validation failed!" -ForegroundColor Red
    $validationRequest.FailedValidations | Format-Table -AutoSize
}
```

### Enable Customer Key
```powershell
if ($validationRequest.ValidationResult -eq "Success") {
    Write-Host "`nEnabling Customer Key..." -ForegroundColor Cyan
    
    $enableRequest = New-CustomerKeyOnboardingRequest `
        -Organization $global:CMKParams.TenantId `
        -Scenario MDEP `
        -Subscription1 $global:CMKParams.PrimarySubscriptionId `
        -KeyIdentifier1 $global:KeyURIs.M365Primary `
        -Subscription2 $global:CMKParams.SecondarySubscriptionId `
        -KeyIdentifier2 $global:KeyURIs.M365Secondary `
        -OnboardingMode Enable
    
    if ($enableRequest.EnablementResult -eq "Success") {
        Write-Host "✓ Customer Key successfully enabled for Multiple Workloads!" -ForegroundColor Green
    } else {
        Write-Host "✗ Enablement failed!" -ForegroundColor Red
    }
}
```

---

## Configure SharePoint/OneDrive

### MRP Enablement Notice
```powershell
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "SharePoint/OneDrive Configuration" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host @"
To enable Customer Key for SharePoint and OneDrive:

1. Contact Microsoft Support
2. Request: "Enable Mandatory Retention Period (MRP) for Customer Key SharePoint onboarding"
3. Provide these subscription IDs:
   - Primary: $($global:CMKParams.PrimarySubscriptionId)
   - Secondary: $($global:CMKParams.SecondarySubscriptionId)
4. Wait 3-6 business days for completion

After MRP is enabled, run the following commands:
"@ -ForegroundColor Cyan

Write-Host @"
`n# Register resource providers after MRP is enabled:
Select-AzSubscription -SubscriptionId "$($global:CMKParams.PrimarySubscriptionId)"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Resources"
Register-AzResourceProvider -ProviderNamespace "Microsoft.KeyVault"

Select-AzSubscription -SubscriptionId "$($global:CMKParams.SecondarySubscriptionId)"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Resources"
Register-AzResourceProvider -ProviderNamespace "Microsoft.KeyVault"
"@ -ForegroundColor White
```

---

## Apply to Users or Groups

### Exchange Online Configuration
```powershell
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "Apply Customer Key to Users or Groups" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# Check if Exchange Online module is installed
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing Exchange Online Management module..." -ForegroundColor Yellow
    Install-Module -Name ExchangeOnlineManagement -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline

# Create Data Encryption Policy
Write-Host "`nCreating Data Encryption Policy..." -ForegroundColor Cyan
New-DataEncryptionPolicy `
    -Name "$($global:ResourceNames.DEPName)" `
    -Description "Customer Key Policy for $($global:CMKParams.TargetType)" `
    -AzureKeyIDs @($global:KeyURIs.M365Primary, $global:KeyURIs.M365Secondary)
```

### Apply to Single User
```powershell
if ($global:CMKParams.TargetType -eq "User") {
    Write-Host "`nApplying Customer Key to user: $($global:CMKParams.TargetUserEmail)" -ForegroundColor Cyan
    
    # Apply DEP to specific user
    Set-Mailbox `
        -Identity $global:CMKParams.TargetUserEmail `
        -DataEncryptionPolicy $global:ResourceNames.DEPName
    
    # Verify assignment
    Get-Mailbox -Identity $global:CMKParams.TargetUserEmail | 
        Select-Object DisplayName, PrimarySmtpAddress, DataEncryptionPolicy | 
        Format-Table -AutoSize
    
    Write-Host "✓ Customer Key DEP applied to user: $($global:CMKParams.TargetUserEmail)" -ForegroundColor Green
}
```

### Apply to Entra ID Group
```powershell
if ($global:CMKParams.TargetType -eq "Group") {
    Write-Host "`nApplying Customer Key to group: $($global:CMKParams.TargetGroupName)" -ForegroundColor Cyan
    
    # Get group members
    if (-not $global:CMKParams.ContainsKey("TargetGroupId")) {
        # Look up group ID if not provided
        $group = Get-AzADGroup -DisplayName $global:CMKParams.TargetGroupName
        if (-not $group) {
            Write-Error "Group not found: $($global:CMKParams.TargetGroupName)"
            return
        }
        $groupId = $group.Id
    } else {
        $groupId = $global:CMKParams.TargetGroupId
    }
    
    # Get group members with mailboxes
    Write-Host "Getting group members..." -ForegroundColor Yellow
    $groupMembers = Get-AzADGroupMember -GroupObjectId $groupId
    
    # Filter for users only (not other groups or service principals)
    $userMembers = $groupMembers | Where-Object { $_.OdataType -eq "#microsoft.graph.user" }
    
    Write-Host "Found $($userMembers.Count) users in group" -ForegroundColor Cyan
    
    # Apply DEP to each group member with a mailbox
    $successCount = 0
    $failureCount = 0
    
    foreach ($member in $userMembers) {
        try {
            # Check if user has a mailbox
            $mailbox = Get-Mailbox -Identity $member.UserPrincipalName -ErrorAction SilentlyContinue
            
            if ($mailbox) {
                Set-Mailbox -Identity $member.UserPrincipalName -DataEncryptionPolicy $global:ResourceNames.DEPName
                Write-Host "✓ Applied to: $($member.DisplayName) ($($member.UserPrincipalName))" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "⚠ Skipped (no mailbox): $($member.DisplayName)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "✗ Failed: $($member.DisplayName) - $_" -ForegroundColor Red
            $failureCount++
        }
    }
    
    # Summary
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Successful: $successCount users" -ForegroundColor Green
    Write-Host "  Failed: $failureCount users" -ForegroundColor Red
    Write-Host "  Total processed: $($userMembers.Count) users" -ForegroundColor Yellow
    
    # Verify a sample of assignments
    Write-Host "`nVerifying assignments (first 5 users):" -ForegroundColor Cyan
    $userMembers | Select-Object -First 5 | ForEach-Object {
        $mailbox = Get-Mailbox -Identity $_.UserPrincipalName -ErrorAction SilentlyContinue
        if ($mailbox) {
            [PSCustomObject]@{
                DisplayName = $mailbox.DisplayName
                Email = $mailbox.PrimarySmtpAddress
                DEPPolicy = $mailbox.DataEncryptionPolicy
            }
        }
    } | Format-Table -AutoSize
}
```

### Alternative: Apply Using Distribution Group or Mail-Enabled Security Group
```powershell
# For mail-enabled groups, you can also use this approach:
# This requires the group to be mail-enabled in Exchange Online

$mailEnabledGroup = "CMK-Users@yourdomain.com"  # Mail-enabled security group

# Get all members of the mail-enabled group
$members = Get-DistributionGroupMember -Identity $mailEnabledGroup

# Apply DEP to all members
$members | ForEach-Object {
    if ($_.RecipientType -like "*Mailbox") {
        Set-Mailbox -Identity $_.PrimarySmtpAddress -DataEncryptionPolicy $global:ResourceNames.DEPName
        Write-Host "✓ Applied to: $($_.DisplayName)" -ForegroundColor Green
    }
}
```

### Bulk Application Script
```powershell
# Script to apply Customer Key DEP to multiple users from CSV
# CSV should have a column named "UserPrincipalName" or "Email"

$csvPath = "$($global:CMKParams.BackupPath)/users-to-enable.csv"

# Example CSV content:
@"
UserPrincipalName
user1@domain.com
user2@domain.com
user3@domain.com
"@ | Out-File $csvPath

# Import and process users
$users = Import-Csv $csvPath
$results = @()

foreach ($user in $users) {
    $email = $user.UserPrincipalName -or $user.Email
    
    try {
        Set-Mailbox -Identity $email -DataEncryptionPolicy $global:ResourceNames.DEPName
        $results += [PSCustomObject]@{
            User = $email
            Status = "Success"
            Error = ""
        }
        Write-Host "✓ $email" -ForegroundColor Green
    } catch {
        $results += [PSCustomObject]@{
            User = $email
            Status = "Failed"
            Error = $_.Exception.Message
        }
        Write-Host "✗ $email - $_" -ForegroundColor Red
    }
}

# Export results
$results | Export-Csv "$($global:CMKParams.BackupPath)/cmk-application-results.csv" -NoTypeInformation
Write-Host "`nResults saved to: $($global:CMKParams.BackupPath)/cmk-application-results.csv" -ForegroundColor Cyan
```

### Important Notes for Group Application

1. **Group Types Supported**:
   - Entra ID Security Groups
   - Microsoft 365 Groups
   - Mail-enabled Security Groups
   - Distribution Groups (if members have mailboxes)

2. **Prerequisites**:
   - All users must have Exchange Online mailboxes
   - Users must have appropriate licenses (E5 or equivalent)
   - Group must be synced to Exchange Online

3. **Performance Considerations**:
   - For large groups (>1000 users), consider batching
   - Use PowerShell jobs for parallel processing
   - Monitor throttling limits

4. **Verification**:
   ```powershell
   # Verify DEP application for a group
   Get-Mailbox -ResultSize Unlimited | 
       Where-Object { $_.DataEncryptionPolicy -eq $global:ResourceNames.DEPName } |
       Select-Object DisplayName, PrimarySmtpAddress, DataEncryptionPolicy |
       Export-Csv "$($global:CMKParams.BackupPath)/cmk-enabled-users.csv" -NoTypeInformation
   ```

---

## Troubleshooting

### Common Issues and Solutions
```powershell
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "Troubleshooting Commands" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

Write-Host @"
# Check current context
Get-AzContext | Format-List

# List Key Vaults
Get-AzKeyVault | Select-Object VaultName, ResourceGroupName, Location

# Check role assignments
Get-AzRoleAssignment -ObjectId "$userId" | Where-Object {`$_.Scope -like "*keyvault*"}

# Check service principals
Get-AzADServicePrincipal | Where-Object {`$_.DisplayName -like "*M365*" -or `$_.DisplayName -like "*SharePoint*"}

# Verify key properties
Get-AzKeyVaultKey -VaultName "$($global:KeyVaultNames.M365Primary)" | Select-Object Name, Enabled, Expires

# Test key access
Get-AzKeyVaultKey -VaultName "$($global:KeyVaultNames.M365Primary)" -Name "$($global:ResourceNames.M365KeyPrimaryName)"
"@ -ForegroundColor White
```

---

## Annex: Complete Automated Script

Save the following script as `Deploy-CustomerKey.ps1` and run in Azure Cloud Shell or locally:

```powershell
#requires -Version 5.1
<#
.SYNOPSIS
    Automated deployment script for Azure Customer Key configuration

.DESCRIPTION
    This script automates the complete setup of Azure Customer Key for Microsoft 365
    including OneDrive, SharePoint Online, and Teams for users or groups.

.PARAMETER TenantId
    Your Microsoft 365 tenant ID

.PARAMETER PrimarySubscriptionId
    Azure subscription ID for primary resources

.PARAMETER SecondarySubscriptionId
    Azure subscription ID for secondary resources

.PARAMETER TargetType
    Target type for Customer Key application: "User" or "Group" (default: "User")

.PARAMETER TargetUserEmail
    Email address of the user to apply Customer Key (required if TargetType is "User")

.PARAMETER TargetGroupName
    Name of the Entra ID group to apply Customer Key (required if TargetType is "Group")

.PARAMETER TargetGroupId
    Object ID of the Entra ID group (optional, will be looked up if not provided)

.EXAMPLE
    # For single user
    .\Deploy-CustomerKey.ps1 -TenantId "12345678-1234-1234-1234-123456789012" `
                            -PrimarySubscriptionId "11111111-1111-1111-1111-111111111111" `
                            -SecondarySubscriptionId "22222222-2222-2222-2222-222222222222" `
                            -TargetUserEmail "user@domain.com"

.EXAMPLE
    # For Entra ID group
    .\Deploy-CustomerKey.ps1 -TenantId "12345678-1234-1234-1234-123456789012" `
                            -PrimarySubscriptionId "11111111-1111-1111-1111-111111111111" `
                            -SecondarySubscriptionId "22222222-2222-2222-2222-222222222222" `
                            -TargetType "Group" `
                            -TargetGroupName "CMK-Enabled-Users"

.NOTES
    Author: Customer Key Deployment Script
    Version: 4.0
    Requirements: Azure PowerShell, Global Admin rights, Two Azure subscriptions
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$TenantId,

    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$PrimarySubscriptionId,

    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$SecondarySubscriptionId,

    [Parameter(Mandatory=$false)]
    [ValidateSet("User", "Group")]
    [string]$TargetType = "User",

    [Parameter(Mandatory=$false)]
    [ValidatePattern('^[^@]+@[^@]+\.[^@]+$')]
    [string]$TargetUserEmail,

    [Parameter(Mandatory=$false)]
    [string]$TargetGroupName,

    [Parameter(Mandatory=$false)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$TargetGroupId,

    [Parameter()]
    [string]$NamingPrefix = "cmk",

    [Parameter()]
    [switch]$SkipConfirmation
)

# Validate parameters based on target type
if ($TargetType -eq "User" -and -not $TargetUserEmail) {
    throw "TargetUserEmail is required when TargetType is 'User'"
}

if ($TargetType -eq "Group" -and -not $TargetGroupName -and -not $TargetGroupId) {
    throw "Either TargetGroupName or TargetGroupId is required when TargetType is 'Group'"
}

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# Colors for output
$colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
    Progress = "Magenta"
}

# Helper Functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    Write-Host $Message -ForegroundColor $Color -NoNewline:$NoNewline
}

function Show-Progress {
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

function Test-Prerequisites {
    Write-ColorOutput "`nChecking prerequisites..." -Color $colors.Info
    
    # Check if running in Azure Cloud Shell
    $isCloudShell = $env:AZURE_HTTP_USER_AGENT -like "*cloud-shell*"
    
    # Check required modules
    $requiredModules = @("Az.Accounts", "Az.Resources", "Az.KeyVault")
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            throw "Required module '$module' is not installed"
        }
    }
    
    Write-ColorOutput "✓ Prerequisites check passed" -Color $colors.Success
    return $isCloudShell
}

function Confirm-Execution {
    param([string]$Message)
    
    if ($SkipConfirmation) { return $true }
    
    Write-ColorOutput "`n$Message" -Color $colors.Warning
    $response = Read-Host "Do you want to continue? (Y/N)"
    return $response -eq 'Y' -or $response -eq 'y'
}

# Main execution
try {
    Clear-Host
    Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════╗
║          Azure Customer Key Automated Deployment             ║
║                        Version 4.0                           ║
╚══════════════════════════════════════════════════════════════╝
"@ -Color $colors.Info

    # Initialize parameters
    $global:CMKParams = @{
        TenantId = $TenantId
        PrimarySubscriptionId = $PrimarySubscriptionId
        SecondarySubscriptionId = $SecondarySubscriptionId
        PrimaryLocation = "Canada Central"
        SecondaryLocation = "Canada East"
        NamingPrefix = $NamingPrefix
        TargetType = $TargetType
        BackupPath = "$HOME/keybackups"
    }

    # Add target-specific parameters
    if ($TargetType -eq "User") {
        $global:CMKParams.TargetUserEmail = $TargetUserEmail
        $global:CMKParams.TargetDisplay = $TargetUserEmail
    } else {
        $global:CMKParams.TargetGroupName = $TargetGroupName
        $global:CMKParams.TargetGroupId = $TargetGroupId
        $global:CMKParams.TargetDisplay = $TargetGroupName
    }

    # Validate subscriptions are different
    if ($PrimarySubscriptionId -eq $SecondarySubscriptionId) {
        throw "Primary and Secondary subscription IDs must be different!"
    }

    # Display configuration
    Write-ColorOutput "`nConfiguration Summary:" -Color $colors.Info
    Write-ColorOutput "=====================" -Color $colors.Info
    $global:CMKParams.GetEnumerator() | Where-Object { $_.Value } | Sort-Object Name | ForEach-Object {
        Write-ColorOutput "$($_.Key): " -Color $colors.Warning -NoNewline
        Write-ColorOutput $_.Value
    }

    if (-not (Confirm-Execution -Message "`nThis script will create Azure resources. Charges may apply.")) {
        Write-ColorOutput "`nDeployment cancelled by user." -Color $colors.Warning
        return
    }

    # Check prerequisites
    Show-Progress -Activity "Customer Key Deployment" -Status "Checking prerequisites..." -PercentComplete 5
    $isCloudShell = Test-Prerequisites

    # Create backup directory
    New-Item -ItemType Directory -Path $global:CMKParams.BackupPath -Force | Out-Null

    # Step 1: Authentication
    Show-Progress -Activity "Customer Key Deployment" -Status "Authenticating to Azure..." -PercentComplete 10
    Write-ColorOutput "`nStep 1: Authenticating to Azure..." -Color $colors.Progress
    
    Clear-AzContext -Force
    if ($isCloudShell) {
        Connect-AzAccount -TenantId $TenantId -UseDeviceAuthentication
    } else {
        Connect-AzAccount -TenantId $TenantId
    }

    $context = Get-AzContext
    if ($context.Tenant.Id -ne $TenantId) {
        throw "Failed to connect to the correct tenant"
    }
    Write-ColorOutput "✓ Connected to tenant: $($context.Tenant.Id)" -Color $colors.Success

    # Step 2: Verify Subscriptions
    Show-Progress -Activity "Customer Key Deployment" -Status "Verifying subscriptions..." -PercentComplete 15
    Write-ColorOutput "`nStep 2: Verifying subscriptions..." -Color $colors.Progress
    
    $subscriptions = Get-AzSubscription | Where-Object State -eq "Enabled"
    $primarySub = $subscriptions | Where-Object Id -eq $PrimarySubscriptionId
    $secondarySub = $subscriptions | Where-Object Id -eq $SecondarySubscriptionId
    
    if (-not $primarySub -or -not $secondarySub) {
        throw "One or both subscriptions not found in tenant"
    }
    
    Write-ColorOutput "✓ Primary subscription verified: $($primarySub.Name)" -Color $colors.Success
    Write-ColorOutput "✓ Secondary subscription verified: $($secondarySub.Name)" -Color $colors.Success

    # Step 3: Register Service Principals
    Show-Progress -Activity "Customer Key Deployment" -Status "Registering service principals..." -PercentComplete 20
    Write-ColorOutput "`nStep 3: Registering service principals..." -Color $colors.Progress
    
    $servicePrincipals = @(
        @{Id = "19f7f505-34aa-44a4-9dcc-6a768854d2ea"; Name = "Customer Key Onboarding"},
        @{Id = "c066d759-24ae-40e7-a56f-027002b5d3e4"; Name = "M365DataAtRestEncryption"},
        @{Id = "00000003-0000-0ff1-ce00-000000000000"; Name = "Office 365 SharePoint Online"}
    )
    
    foreach ($sp in $servicePrincipals) {
        $existing = Get-AzADServicePrincipal -ApplicationId $sp.Id -ErrorAction SilentlyContinue
        if (-not $existing) {
            New-AzADServicePrincipal -ApplicationId $sp.Id | Out-Null
            Write-ColorOutput "✓ Registered: $($sp.Name)" -Color $colors.Success
        } else {
            Write-ColorOutput "✓ Already registered: $($sp.Name)" -Color $colors.Success
        }
    }

    # Step 4: Create Resource Groups
    Show-Progress -Activity "Customer Key Deployment" -Status "Creating resource groups..." -PercentComplete 25
    Write-ColorOutput "`nStep 4: Creating resource groups..." -Color $colors.Progress
    
    # Initialize resource names
    $global:ResourceNames = @{
        PrimaryRGMultiworkload = "rg-$NamingPrefix-primary-multiworkload"
        PrimaryRGSharePoint = "rg-$NamingPrefix-primary-sharepoint"
        SecondaryRGMultiworkload = "rg-$NamingPrefix-secondary-multiworkload"
        SecondaryRGSharePoint = "rg-$NamingPrefix-secondary-sharepoint"
        DEPName = "CMK-DEP-$(Get-Date -Format 'yyyyMMdd')"
    }
    
    # Create primary resource groups
    Select-AzSubscription -SubscriptionId $PrimarySubscriptionId | Out-Null
    New-AzResourceGroup -Name $global:ResourceNames.PrimaryRGMultiworkload -Location $global:CMKParams.PrimaryLocation -Force | Out-Null
    New-AzResourceGroup -Name $global:ResourceNames.PrimaryRGSharePoint -Location $global:CMKParams.PrimaryLocation -Force | Out-Null
    Write-ColorOutput "✓ Created primary resource groups in $($global:CMKParams.PrimaryLocation)" -Color $colors.Success
    
    # Create secondary resource groups
    Select-AzSubscription -SubscriptionId $SecondarySubscriptionId | Out-Null
    New-AzResourceGroup -Name $global:ResourceNames.SecondaryRGMultiworkload -Location $global:CMKParams.SecondaryLocation -Force | Out-Null
    New-AzResourceGroup -Name $global:ResourceNames.SecondaryRGSharePoint -Location $global:CMKParams.SecondaryLocation -Force | Out-Null
    Write-ColorOutput "✓ Created secondary resource groups in $($global:CMKParams.SecondaryLocation)" -Color $colors.Success

    # Step 5: Create Key Vaults
    Show-Progress -Activity "Customer Key Deployment" -Status "Creating Key Vaults..." -PercentComplete 35
    Write-ColorOutput "`nStep 5: Creating Key Vaults..." -Color $colors.Progress
    
    $global:KeyVaultNames = @{}
    
    # Primary Key Vaults
    Select-AzSubscription -SubscriptionId $PrimarySubscriptionId | Out-Null
    
    $kvNameM365Primary = "kv-$NamingPrefix-m365-pri-$(Get-Random -Maximum 9999)"
    $null = New-AzKeyVault -Name $kvNameM365Primary -ResourceGroupName $global:ResourceNames.PrimaryRGMultiworkload `
        -Location $global:CMKParams.PrimaryLocation -SKU Premium -EnablePurgeProtection -SoftDeleteRetentionInDays 90
    $global:KeyVaultNames.M365Primary = $kvNameM365Primary
    Write-ColorOutput "✓ Created Key Vault: $kvNameM365Primary" -Color $colors.Success
    
    $kvNameSPOPrimary = "kv-$NamingPrefix-spo-pri-$(Get-Random -Maximum 9999)"
    $null = New-AzKeyVault -Name $kvNameSPOPrimary -ResourceGroupName $global:ResourceNames.PrimaryRGSharePoint `
        -Location $global:CMKParams.PrimaryLocation -SKU Premium -EnablePurgeProtection -SoftDeleteRetentionInDays 90
    $global:KeyVaultNames.SPOPrimary = $kvNameSPOPrimary
    Write-ColorOutput "✓ Created Key Vault: $kvNameSPOPrimary" -Color $colors.Success
    
    # Secondary Key Vaults
    Select-AzSubscription -SubscriptionId $SecondarySubscriptionId | Out-Null
    
    $kvNameM365Secondary = "kv-$NamingPrefix-m365-sec-$(Get-Random -Maximum 9999)"
    $null = New-AzKeyVault -Name $kvNameM365Secondary -ResourceGroupName $global:ResourceNames.SecondaryRGMultiworkload `
        -Location $global:CMKParams.SecondaryLocation -SKU Premium -EnablePurgeProtection -SoftDeleteRetentionInDays 90
    $global:KeyVaultNames.M365Secondary = $kvNameM365Secondary
    Write-ColorOutput "✓ Created Key Vault: $kvNameM365Secondary" -Color $colors.Success
    
    $kvNameSPOSecondary = "kv-$NamingPrefix-spo-sec-$(Get-Random -Maximum 9999)"
    $null = New-AzKeyVault -Name $kvNameSPOSecondary -ResourceGroupName $global:ResourceNames.SecondaryRGSharePoint `
        -Location $global:CMKParams.SecondaryLocation -SKU Premium -EnablePurgeProtection -SoftDeleteRetentionInDays 90
    $global:KeyVaultNames.SPOSecondary = $kvNameSPOSecondary
    Write-ColorOutput "✓ Created Key Vault: $kvNameSPOSecondary" -Color $colors.Success

    # Step 6: Configure RBAC
    Show-Progress -Activity "Customer Key Deployment" -Status "Configuring RBAC permissions..." -PercentComplete 45
    Write-ColorOutput "`nStep 6: Configuring RBAC permissions..." -Color $colors.Progress
    
    $currentUser = Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id
    $userId = $currentUser.Id
    
    # Function to assign Key Vault Administrator role
    function Set-KeyVaultAdminRole {
        param($SubscriptionId, $ResourceGroup, $VaultName, $ObjectId)
        
        Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
        $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.KeyVault/vaults/$VaultName"
        
        $null = New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName "Key Vault Administrator" `
            -Scope $scope -ErrorAction SilentlyContinue
    }
    
    # Assign to all vaults
    Set-KeyVaultAdminRole -SubscriptionId $PrimarySubscriptionId -ResourceGroup $global:ResourceNames.PrimaryRGMultiworkload `
        -VaultName $global:KeyVaultNames.M365Primary -ObjectId $userId
    Set-KeyVaultAdminRole -SubscriptionId $PrimarySubscriptionId -ResourceGroup $global:ResourceNames.PrimaryRGSharePoint `
        -VaultName $global:KeyVaultNames.SPOPrimary -ObjectId $userId
    Set-KeyVaultAdminRole -SubscriptionId $SecondarySubscriptionId -ResourceGroup $global:ResourceNames.SecondaryRGMultiworkload `
        -VaultName $global:KeyVaultNames.M365Secondary -ObjectId $userId
    Set-KeyVaultAdminRole -SubscriptionId $SecondarySubscriptionId -ResourceGroup $global:ResourceNames.SecondaryRGSharePoint `
        -VaultName $global:KeyVaultNames.SPOSecondary -ObjectId $userId
    
    Write-ColorOutput "✓ Key Vault Administrator role assigned" -Color $colors.Success
    
    # Wait for propagation
    Write-ColorOutput "Waiting 60 seconds for role propagation..." -Color $colors.Warning
    Start-Sleep -Seconds 60

    # Assign Service Principal permissions
    $m365SP = Get-AzADServicePrincipal -DisplayName "M365DataAtRestEncryption"
    $spoSP = Get-AzADServicePrincipal -DisplayName "Office 365 SharePoint Online"
    
    if ($m365SP) {
        # M365 permissions
        Select-AzSubscription -SubscriptionId $PrimarySubscriptionId | Out-Null
        $null = New-AzRoleAssignment -ObjectId $m365SP.Id -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
            -Scope "/subscriptions/$PrimarySubscriptionId/resourceGroups/$($global:ResourceNames.PrimaryRGMultiworkload)/providers/Microsoft.KeyVault/vaults/$($global:KeyVaultNames.M365Primary)" `
            -ErrorAction SilentlyContinue
            
        Select-AzSubscription -SubscriptionId $SecondarySubscriptionId | Out-Null
        $null = New-AzRoleAssignment -ObjectId $m365SP.Id -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
            -Scope "/subscriptions/$SecondarySubscriptionId/resourceGroups/$($global:ResourceNames.SecondaryRGMultiworkload)/providers/Microsoft.KeyVault/vaults/$($global:KeyVaultNames.M365Secondary)" `
            -ErrorAction SilentlyContinue
    }
    
    if ($spoSP) {
        # SPO permissions
        Select-AzSubscription -SubscriptionId $PrimarySubscriptionId | Out-Null
        $null = New-AzRoleAssignment -ObjectId $spoSP.Id -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
            -Scope "/subscriptions/$PrimarySubscriptionId/resourceGroups/$($global:ResourceNames.PrimaryRGSharePoint)/providers/Microsoft.KeyVault/vaults/$($global:KeyVaultNames.SPOPrimary)" `
            -ErrorAction SilentlyContinue
            
        Select-AzSubscription -SubscriptionId $SecondarySubscriptionId | Out-Null
        $null = New-AzRoleAssignment -ObjectId $spoSP.Id -RoleDefinitionName "Key Vault Crypto Service Encryption User" `
            -Scope "/subscriptions/$SecondarySubscriptionId/resourceGroups/$($global:ResourceNames.SecondaryRGSharePoint)/providers/Microsoft.KeyVault/vaults/$($global:KeyVaultNames.SPOSecondary)" `
            -ErrorAction SilentlyContinue
    }
    
    Write-ColorOutput "✓ Service principal permissions configured" -Color $colors.Success

    # Step 7: Create Encryption Keys
    Show-Progress -Activity "Customer Key Deployment" -Status "Creating encryption keys..." -PercentComplete 60
    Write-ColorOutput "`nStep 7: Creating encryption keys..." -Color $colors.Progress
    
    $global:KeyURIs = @{}
    $keyNames = @{
        M365Primary = "m365-customer-key-primary"
        M365Secondary = "m365-customer-key-secondary"
        SPOPrimary = "spo-customer-key-primary"
        SPOSecondary = "spo-customer-key-secondary"
    }
    
    # Primary keys
    Select-AzSubscription -SubscriptionId $PrimarySubscriptionId | Out-Null
    
    $m365KeyPrimary = Add-AzKeyVaultKey -VaultName $global:KeyVaultNames.M365Primary `
        -Name $keyNames.M365Primary -Destination "HSM" -KeyType RSA -Size 2048 `
        -KeyOps wrapKey,unwrapKey -NotBefore (Get-Date)
    $global:KeyURIs.M365Primary = $m365KeyPrimary.Id.ToString()
    $null = Backup-AzKeyVaultKey -VaultName $global:KeyVaultNames.M365Primary `
        -Name $keyNames.M365Primary -OutputFile "$($global:CMKParams.BackupPath)/m365-key-primary.blob" -Force
    Write-ColorOutput "✓ Created M365 primary key" -Color $colors.Success
    
    $spoKeyPrimary = Add-AzKeyVaultKey -VaultName $global:KeyVaultNames.SPOPrimary `
        -Name $keyNames.SPOPrimary -Destination "HSM" -KeyType RSA -Size 2048 `
        -KeyOps wrapKey,unwrapKey -NotBefore (Get-Date)
    $global:KeyURIs.SPOPrimary = $spoKeyPrimary.Id.ToString()
    $null = Backup-AzKeyVaultKey -VaultName $global:KeyVaultNames.SPOPrimary `
        -Name $keyNames.SPOPrimary -OutputFile "$($global:CMKParams.BackupPath)/spo-key-primary.blob" -Force
    Write-ColorOutput "✓ Created SPO primary key" -Color $colors.Success
    
    # Secondary keys
    Select-AzSubscription -SubscriptionId $SecondarySubscriptionId | Out-Null
    
    $m365KeySecondary = Add-AzKeyVaultKey -VaultName $global:KeyVaultNames.M365Secondary `
        -Name $keyNames.M365Secondary -Destination "HSM" -KeyType RSA -Size 2048 `
        -KeyOps wrapKey,unwrapKey -NotBefore (Get-Date)
    $global:KeyURIs.M365Secondary = $m365KeySecondary.Id.ToString()
    $null = Backup-AzKeyVaultKey -VaultName $global:KeyVaultNames.M365Secondary `
        -Name $keyNames.M365Secondary -OutputFile "$($global:CMKParams.BackupPath)/m365-key-secondary.blob" -Force
    Write-ColorOutput "✓ Created M365 secondary key" -Color $colors.Success
    
    $spoKeySecondary = Add-AzKeyVaultKey -VaultName $global:KeyVaultNames.SPOSecondary `
        -Name $keyNames.SPOSecondary -Destination "HSM" -KeyType RSA -Size 2048 `
        -KeyOps wrapKey,unwrapKey -NotBefore (Get-Date)
    $global:KeyURIs.SPOSecondary = $spoKeySecondary.Id.ToString()
    $null = Backup-AzKeyVaultKey -VaultName $global:KeyVaultNames.SPOSecondary `
        -Name $keyNames.SPOSecondary -OutputFile "$($global:CMKParams.BackupPath)/spo-key-secondary.blob" -Force
    Write-ColorOutput "✓ Created SPO secondary key" -Color $colors.Success

    # Step 8: Save Configuration
    Show-Progress -Activity "Customer Key Deployment" -Status "Saving configuration..." -PercentComplete 70
    
    $targetInfo = if ($TargetType -eq "User") {
        "TARGET USER: $($TargetUserEmail)"
    } else {
        "TARGET GROUP: $($TargetGroupName)"
    }
    
    $configContent = @"
Customer Key Configuration - Generated $(Get-Date)
================================================

TENANT INFORMATION:
Tenant ID: $($global:CMKParams.TenantId)

SUBSCRIPTION IDS:
Primary: $($global:CMKParams.PrimarySubscriptionId)
Secondary: $($global:CMKParams.SecondarySubscriptionId)

KEY VAULT NAMES:
M365 Primary: $($global:KeyVaultNames.M365Primary)
M365 Secondary: $($global:KeyVaultNames.M365Secondary)
SPO Primary: $($global:KeyVaultNames.SPOPrimary)
SPO Secondary: $($global:KeyVaultNames.SPOSecondary)

KEY URIS:
M365 Primary: $($global:KeyURIs.M365Primary)
M365 Secondary: $($global:KeyURIs.M365Secondary)
SPO Primary: $($global:KeyURIs.SPOPrimary)
SPO Secondary: $($global:KeyURIs.SPOSecondary)

TARGET TYPE: $($global:CMKParams.TargetType)
$targetInfo
"@

    $configContent | Out-File "$($global:CMKParams.BackupPath)/cmk-configuration.txt"
    Write-ColorOutput "✓ Configuration saved to: $($global:CMKParams.BackupPath)/cmk-configuration.txt" -Color $colors.Success

    # Step 9: Customer Key Onboarding
    Show-Progress -Activity "Customer Key Deployment" -Status "Installing onboarding module..." -PercentComplete 75
    Write-ColorOutput "`nStep 8: Customer Key onboarding..." -Color $colors.Progress
    
    if (-not (Get-Module -ListAvailable -Name M365CustomerKeyOnboarding)) {
        Install-Module -Name M365CustomerKeyOnboarding -Force -AllowClobber
    }
    Import-Module M365CustomerKeyOnboarding
    
    # Grant Reader access
    Select-AzSubscription -SubscriptionId $PrimarySubscriptionId | Out-Null
    $null = New-AzRoleAssignment -ObjectId $userId -RoleDefinitionName "Reader" `
        -Scope "/subscriptions/$PrimarySubscriptionId" -ErrorAction SilentlyContinue
        
    Select-AzSubscription -SubscriptionId $SecondarySubscriptionId | Out-Null
    $null = New-AzRoleAssignment -ObjectId $userId -RoleDefinitionName "Reader" `
        -Scope "/subscriptions/$SecondarySubscriptionId" -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 30

    if (Confirm-Execution -Message "Ready to validate Customer Key configuration. Continue?") {
        Show-Progress -Activity "Customer Key Deployment" -Status "Validating configuration..." -PercentComplete 80
        
        $validationRequest = New-CustomerKeyOnboardingRequest `
            -Organization $TenantId `
            -Scenario MDEP `
            -Subscription1 $PrimarySubscriptionId `
            -KeyIdentifier1 $global:KeyURIs.M365Primary `
            -Subscription2 $SecondarySubscriptionId `
            -KeyIdentifier2 $global:KeyURIs.M365Secondary `
            -OnboardingMode Validate
        
        if ($validationRequest.ValidationResult -eq "Success") {
            Write-ColorOutput "✓ Validation passed!" -Color $colors.Success
            
            if (Confirm-Execution -Message "Validation successful. Enable Customer Key now?") {
                Show-Progress -Activity "Customer Key Deployment" -Status "Enabling Customer Key..." -PercentComplete 90
                
                $enableRequest = New-CustomerKeyOnboardingRequest `
                    -Organization $TenantId `
                    -Scenario MDEP `
                    -Subscription1 $PrimarySubscriptionId `
                    -KeyIdentifier1 $global:KeyURIs.M365Primary `
                    -Subscription2 $SecondarySubscriptionId `
                    -KeyIdentifier2 $global:KeyURIs.M365Secondary `
                    -OnboardingMode Enable
                
                if ($enableRequest.EnablementResult -eq "Success") {
                    Write-ColorOutput "✓ Customer Key successfully enabled!" -Color $colors.Success
                } else {
                    Write-ColorOutput "✗ Enablement failed!" -Color $colors.Error
                }
            }
        } else {
            Write-ColorOutput "✗ Validation failed!" -Color $colors.Error
            $validationRequest.FailedValidations | Format-Table -AutoSize
        }
    }

    # Complete
    Show-Progress -Activity "Customer Key Deployment" -Status "Deployment complete!" -PercentComplete 100
    
    Write-ColorOutput "`n╔══════════════════════════════════════════════════════════════╗" -Color $colors.Success
    Write-ColorOutput   "║                  DEPLOYMENT COMPLETE!                        ║" -Color $colors.Success
    Write-ColorOutput   "╚══════════════════════════════════════════════════════════════╝" -Color $colors.Success
    
    Write-ColorOutput "`nNext Steps:" -Color $colors.Info
    Write-ColorOutput "1. For SharePoint/OneDrive: Contact Microsoft Support to enable MRP" -Color $colors.Warning
    Write-ColorOutput "2. To apply to $TargetType`: Use Exchange Online PowerShell commands" -Color $colors.Warning
    Write-ColorOutput "3. Configuration saved to: $($global:CMKParams.BackupPath)/cmk-configuration.txt" -Color $colors.Warning
    Write-ColorOutput "4. Key backups saved to: $($global:CMKParams.BackupPath)/" -Color $colors.Warning
    
    # Output Exchange commands for reference
    Write-ColorOutput "`nExchange Online Commands:" -Color $colors.Info
    Write-ColorOutput "Connect-ExchangeOnline" -Color White
    Write-ColorOutput "New-DataEncryptionPolicy -Name '$($global:ResourceNames.DEPName)' -AzureKeyIDs @('$($global:KeyURIs.M365Primary)', '$($global:KeyURIs.M365Secondary)')" -Color White
    
    if ($TargetType -eq "User") {
        Write-ColorOutput "Set-Mailbox -Identity '$TargetUserEmail' -DataEncryptionPolicy '$($global:ResourceNames.DEPName)'" -Color White
    } else {
        Write-ColorOutput "# Apply to group members - see guide for group application script" -Color White
    }
    
} catch {
    Write-ColorOutput "`n✗ Deployment failed: $_" -Color $colors.Error
    Write-ColorOutput $_.Exception.StackTrace -Color $colors.Error
} finally {
    Write-Progress -Activity "Customer Key Deployment" -Completed
}
```

### How to Use the Automated Script

1. **Save the script** as `Deploy-CustomerKey.ps1` in Azure Cloud Shell or locally

2. **For single user deployment**:
```powershell
.\Deploy-CustomerKey.ps1 -TenantId "YOUR-TENANT-ID" `
    -PrimarySubscriptionId "YOUR-PRIMARY-SUB-ID" `
    -SecondarySubscriptionId "YOUR-SECONDARY-SUB-ID" `
    -TargetUserEmail "user@domain.com"
```

3. **For Entra ID group deployment**:
```powershell
.\Deploy-CustomerKey.ps1 -TenantId "YOUR-TENANT-ID" `
    -PrimarySubscriptionId "YOUR-PRIMARY-SUB-ID" `
    -SecondarySubscriptionId "YOUR-SECONDARY-SUB-ID" `
    -TargetType "Group" `
    -TargetGroupName "CMK-Enabled-Users"
```

4. **For unattended execution**, add `-SkipConfirmation`:
```powershell
.\Deploy-CustomerKey.ps1 -TenantId "YOUR-TENANT-ID" `
    -PrimarySubscriptionId "YOUR-PRIMARY-SUB-ID" `
    -SecondarySubscriptionId "YOUR-SECONDARY-SUB-ID" `
    -TargetType "Group" `
    -TargetGroupName "CMK-Enabled-Users" `
    -SkipConfirmation
```