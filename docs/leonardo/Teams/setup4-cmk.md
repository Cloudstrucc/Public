# Azure Customer Managed Keys (CMK) Configuration Guide
## For OneDrive, SharePoint Online, and Teams - Single User Setup

This guide provides detailed configuration steps for implementing Azure Customer Managed Keys (CMK) for a single user with E5 and Teams Premium licenses, using Azure Key Vault with RBAC method.

---

## Prerequisites

### Required Licenses
- Microsoft 365 E5 or Office 365 E5 license
- Microsoft Teams Premium license
- Two paid Azure subscriptions (Free/Trial subscriptions are not eligible)

### Required Permissions
- Global Administrator or equivalent role in Microsoft 365
- Owner or Contributor role on Azure subscriptions
- Azure PowerShell v4.4.0 or higher installed

### Important Notes
- CMK requires two separate Azure subscriptions for key redundancy
- Both subscriptions must be under the same Azure AD tenant as your Microsoft 365 organization
- Once enabled, CMK cannot be easily disabled without potential data loss

---

## Step 1: Create Two Azure Subscriptions

### 1.1 Sign in to Azure Portal
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Sign in with your work account that has Global Administrator privileges

### 1.2 Create First Subscription
1. Click **+ Create a resource**
2. Search for **Subscription**
3. Click **Create**
4. Fill in details:
   - **Subscription Name**: `CMK-Subscription-Primary`
   - **Management Group**: Select your organization's management group
   - **Billing Account**: Select appropriate billing account
5. Click **Review + Create** → **Create**

### 1.3 Create Second Subscription
1. Repeat the process above
2. Name it: `CMK-Subscription-Secondary`

**Best Practice**: Have different administrators manage keys in each subscription to prevent single points of failure.

---

## Step 2: Register Required Service Principals

### 2.1 Connect to Azure PowerShell
```powershell
# Install Azure PowerShell if not already installed
Install-Module -Name Az -AllowClobber -Force

# Connect to Azure
Connect-AzAccount

# Select the first subscription
Select-AzSubscription -SubscriptionName "CMK-Subscription-Primary"
```

### 2.2 Register Customer Key Onboarding Application
```powershell
# Check if already registered
Get-AzADServicePrincipal -ServicePrincipalName 19f7f505-34aa-44a4-9dcc-6a768854d2ea

# If not found, register it
New-AzADServicePrincipal -ApplicationId 19f7f505-34aa-44a4-9dcc-6a768854d2ea
```

### 2.3 Register M365DataAtRestEncryption Application
```powershell
# Check if already registered
Get-AzADServicePrincipal -ServicePrincipalName c066d759-24ae-40e7-a56f-027002b5d3e4

# If not found, register it
New-AzADServicePrincipal -ApplicationId c066d759-24ae-40e7-a56f-027002b5d3e4
```

### 2.4 Register Office 365 SharePoint Online Application
```powershell
# Check if already registered
Get-AzADServicePrincipal -ServicePrincipalName 00000003-0000-0ff1-ce00-000000000000

# If not found, register it
New-AzADServicePrincipal -ApplicationId 00000003-0000-0ff1-ce00-000000000000
```

**Note**: Exchange registration is not needed as per your requirements.

---

## Step 3: Create Resource Groups

### 3.1 Create Resource Groups in First Subscription
```powershell
# Select first subscription
Select-AzSubscription -SubscriptionName "CMK-Subscription-Primary"

# Create resource groups
New-AzResourceGroup -Name "rg-cmk-primary-multiworkload" -Location "East US"
New-AzResourceGroup -Name "rg-cmk-primary-sharepoint" -Location "East US"
```

### 3.2 Create Resource Groups in Second Subscription
```powershell
# Select second subscription
Select-AzSubscription -SubscriptionName "CMK-Subscription-Secondary"

# Create resource groups
New-AzResourceGroup -Name "rg-cmk-secondary-multiworkload" -Location "West US"
New-AzResourceGroup -Name "rg-cmk-secondary-sharepoint" -Location "West US"
```

---

## Step 4: Create Azure Key Vaults

### 4.1 Create Key Vaults in First Subscription

#### For Multiple Workloads (Teams)
```powershell
Select-AzSubscription -SubscriptionName "CMK-Subscription-Primary"

New-AzKeyVault `
    -Name "kv-cmk-m365-primary" `
    -ResourceGroupName "rg-cmk-primary-multiworkload" `
    -Location "East US" `
    -SKU Premium `
    -EnabledForDeployment $false `
    -EnabledForTemplateDeployment $false `
    -EnabledForDiskEncryption $false `
    -EnablePurgeProtection `
    -EnableRbacAuthorization `
    -SoftDeleteRetentionInDays 90
```

#### For SharePoint/OneDrive
```powershell
New-AzKeyVault `
    -Name "kv-cmk-spo-primary" `
    -ResourceGroupName "rg-cmk-primary-sharepoint" `
    -Location "East US" `
    -SKU Premium `
    -EnabledForDeployment $false `
    -EnabledForTemplateDeployment $false `
    -EnabledForDiskEncryption $false `
    -EnablePurgeProtection `
    -EnableRbacAuthorization `
    -SoftDeleteRetentionInDays 90
```

### 4.2 Create Key Vaults in Second Subscription
```powershell
Select-AzSubscription -SubscriptionName "CMK-Subscription-Secondary"

# For Multiple Workloads (Teams)
New-AzKeyVault `
    -Name "kv-cmk-m365-secondary" `
    -ResourceGroupName "rg-cmk-secondary-multiworkload" `
    -Location "West US" `
    -SKU Premium `
    -EnabledForDeployment $false `
    -EnabledForTemplateDeployment $false `
    -EnabledForDiskEncryption $false `
    -EnablePurgeProtection `
    -EnableRbacAuthorization `
    -SoftDeleteRetentionInDays 90

# For SharePoint/OneDrive
New-AzKeyVault `
    -Name "kv-cmk-spo-secondary" `
    -ResourceGroupName "rg-cmk-secondary-sharepoint" `
    -Location "West US" `
    -SKU Premium `
    -EnabledForDeployment $false `
    -EnabledForTemplateDeployment $false `
    -EnabledForDiskEncryption $false `
    -EnablePurgeProtection `
    -EnableRbacAuthorization `
    -SoftDeleteRetentionInDays 90
```

**Critical Settings**:
- **SKU Premium**: Required for HSM-backed keys (recommended for production)
- **EnablePurgeProtection**: Prevents permanent deletion of keys
- **EnableRbacAuthorization**: Uses Azure RBAC instead of access policies
- **SoftDeleteRetentionInDays 90**: Mandatory 90-day retention

---

## Step 5: Configure RBAC Permissions

### 5.1 Assign Permissions for Multiple Workloads (Teams)

#### In Azure Portal - First Subscription:
1. Navigate to **kv-cmk-m365-primary** key vault
2. Click **Access control (IAM)** → **Add role assignment**
3. Select **Key Vault Crypto Service Encryption User** role
4. Click **Next**
5. Select **User, group, or service principal**
6. Search for: `M365DataAtRestEncryption`
7. Select it and click **Next** → **Review + assign**

#### Repeat for Second Subscription:
- Perform same steps for **kv-cmk-m365-secondary**

### 5.2 Assign Permissions for SharePoint/OneDrive

#### In Azure Portal - First Subscription:
1. Navigate to **kv-cmk-spo-primary** key vault
2. Click **Access control (IAM)** → **Add role assignment**
3. Select **Key Vault Crypto Service Encryption User** role
4. Click **Next**
5. Select **User, group, or service principal**
6. Search for: `Office 365 SharePoint Online`
7. Select it and click **Next** → **Review + assign**

#### Repeat for Second Subscription:
- Perform same steps for **kv-cmk-spo-secondary**

### 5.3 Assign User Management Roles

For each key vault, assign the following roles to appropriate administrators:

#### Key Vault Administrator Role:
1. In each key vault, go to **Access control (IAM)**
2. Add role assignment → **Key Vault Administrator**
3. Assign to users who will manage daily operations

#### Key Vault Contributor Role:
1. In each key vault, go to **Access control (IAM)**
2. Add role assignment → **Key Vault Contributor**
3. Assign to users who need to manage permissions

---

## Step 6: Create Encryption Keys

### 6.1 Create Keys in First Subscription

#### For Multiple Workloads (Teams):
```powershell
Select-AzSubscription -SubscriptionName "CMK-Subscription-Primary"

Add-AzKeyVaultKey `
    -VaultName "kv-cmk-m365-primary" `
    -Name "m365-customer-key-primary" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date) `
    -KeyBackupFile "C:\KeyBackups\m365-key-primary-backup.blob"
```

#### For SharePoint/OneDrive:
```powershell
Add-AzKeyVaultKey `
    -VaultName "kv-cmk-spo-primary" `
    -Name "spo-customer-key-primary" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date) `
    -KeyBackupFile "C:\KeyBackups\spo-key-primary-backup.blob"
```

### 6.2 Create Keys in Second Subscription
```powershell
Select-AzSubscription -SubscriptionName "CMK-Subscription-Secondary"

# For Multiple Workloads (Teams)
Add-AzKeyVaultKey `
    -VaultName "kv-cmk-m365-secondary" `
    -Name "m365-customer-key-secondary" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date) `
    -KeyBackupFile "C:\KeyBackups\m365-key-secondary-backup.blob"

# For SharePoint/OneDrive
Add-AzKeyVaultKey `
    -VaultName "kv-cmk-spo-secondary" `
    -Name "spo-customer-key-secondary" `
    -KeyType RSA `
    -Size 2048 `
    -KeyOps wrapKey,unwrapKey `
    -NotBefore (Get-Date) `
    -KeyBackupFile "C:\KeyBackups\spo-key-secondary-backup.blob"
```

**Important**: 
- Store backup files in secure, separate locations
- Never set expiration dates on these keys
- Use RSA 2048 or higher for production

---

## Step 7: Verify Key Configuration and Get URIs

### 7.1 Verify No Expiration Dates
```powershell
# Check all keys
Get-AzKeyVaultKey -VaultName "kv-cmk-m365-primary" | Select-Object Name, Expires
Get-AzKeyVaultKey -VaultName "kv-cmk-m365-secondary" | Select-Object Name, Expires
Get-AzKeyVaultKey -VaultName "kv-cmk-spo-primary" | Select-Object Name, Expires
Get-AzKeyVaultKey -VaultName "kv-cmk-spo-secondary" | Select-Object Name, Expires
```

### 7.2 Get Key URIs
```powershell
# Multiple Workloads URIs
$m365KeyUri1 = (Get-AzKeyVaultKey -VaultName "kv-cmk-m365-primary" -Name "m365-customer-key-primary").Id
$m365KeyUri2 = (Get-AzKeyVaultKey -VaultName "kv-cmk-m365-secondary" -Name "m365-customer-key-secondary").Id

# SharePoint/OneDrive URIs
$spoKeyUri1 = (Get-AzKeyVaultKey -VaultName "kv-cmk-spo-primary" -Name "spo-customer-key-primary").Id
$spoKeyUri2 = (Get-AzKeyVaultKey -VaultName "kv-cmk-spo-secondary" -Name "spo-customer-key-secondary").Id

# Display URIs
Write-Host "M365 Key URI 1: $m365KeyUri1"
Write-Host "M365 Key URI 2: $m365KeyUri2"
Write-Host "SPO Key URI 1: $spoKeyUri1"
Write-Host "SPO Key URI 2: $spoKeyUri2"
```

**Save these URIs** - You'll need them for onboarding.

---

## Step 8: Onboard to Customer Key

### 8.1 Install Customer Key Onboarding Module
```powershell
# Install the module
Install-Module -Name M365CustomerKeyOnboarding -Force

# Import the module
Import-Module M365CustomerKeyOnboarding
```

### 8.2 Validate Configuration for Multiple Workloads (Teams)
```powershell
# Get your tenant ID
$tenantId = (Get-AzTenant).Id

# Get subscription IDs
$sub1Id = (Get-AzSubscription -SubscriptionName "CMK-Subscription-Primary").Id
$sub2Id = (Get-AzSubscription -SubscriptionName "CMK-Subscription-Secondary").Id

# Validate configuration
$validation = New-CustomerKeyOnboardingRequest `
    -Organization $tenantId `
    -Scenario MDEP `
    -Subscription1 $sub1Id `
    -KeyIdentifier1 $m365KeyUri1 `
    -Subscription2 $sub2Id `
    -KeyIdentifier2 $m365KeyUri2 `
    -OnboardingMode Validate

# Check validation results
$validation
```

### 8.3 Enable Customer Key for Multiple Workloads
```powershell
# If validation passed, enable
$enablement = New-CustomerKeyOnboardingRequest `
    -Organization $tenantId `
    -Scenario MDEP `
    -Subscription1 $sub1Id `
    -KeyIdentifier1 $m365KeyUri1 `
    -Subscription2 $sub2Id `
    -KeyIdentifier2 $m365KeyUri2 `
    -OnboardingMode Enable

# Check enablement results
$enablement
```

---

## Step 9: Configure SharePoint/OneDrive (Special Process)

### 9.1 Enable MRP on Subscriptions
Contact Microsoft Support and request:
- "Enable Mandatory Retention Period (MRP) for Customer Key SharePoint onboarding"
- Provide both subscription IDs
- Wait 3-6 business days for completion

### 9.2 Register Resource Providers
After MRP is enabled:
```powershell
# For both subscriptions
Select-AzSubscription -SubscriptionName "CMK-Subscription-Primary"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Resources"
Register-AzResourceProvider -ProviderNamespace "Microsoft.KeyVault"

Select-AzSubscription -SubscriptionName "CMK-Subscription-Secondary"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Resources"
Register-AzResourceProvider -ProviderNamespace "Microsoft.KeyVault"
```

### 9.3 Create SharePoint DEP
After MRP enablement is confirmed, you'll need to create a Data Encryption Policy (DEP) for SharePoint/OneDrive following Microsoft's DEP creation process.

---

## Step 10: Apply to Single User

### 10.1 Connect to Exchange Online PowerShell
```powershell
Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline
```

### 10.2 Create Data Encryption Policy for Single User
```powershell
# Create DEP for the specific user
$userEmail = "user@yourdomain.com"

# This creates a policy scoped to a single mailbox
New-DataEncryptionPolicy -Name "SingleUserDEP" `
    -Description "CMK Policy for $userEmail" `
    -AzureKeyIDs $m365KeyUri1,$m365KeyUri2
```

### 10.3 Assign DEP to User
```powershell
# Apply the DEP to the specific user's mailbox
Set-Mailbox -Identity $userEmail `
    -DataEncryptionPolicy "SingleUserDEP"

# Verify assignment
Get-Mailbox -Identity $userEmail | Select-Object DataEncryptionPolicy
```

---

## Post-Configuration Tasks

### 1. Document Everything
- Save all key URIs
- Document key vault names and resource groups
- Keep backup files in secure locations
- Document user assignments

### 2. Set Up Monitoring
- Enable Azure Monitor for key vaults
- Configure alerts for key usage
- Set up audit log collection

### 3. Regular Maintenance
- Review key vault access monthly
- Rotate keys according to your security policy
- Test key recovery procedures quarterly

### 4. User Communication
- Inform the user about the encryption
- Provide guidance on data access
- Explain any performance implications

---

## Troubleshooting

### Common Issues:

1. **Validation Failures**
   - Check service principal registrations
   - Verify RBAC permissions
   - Ensure no expiration dates on keys

2. **MRP Not Enabled**
   - Contact Microsoft Support
   - Wait full 3-6 business days
   - Re-run resource provider registration

3. **Permission Errors**
   - Verify Key Vault Crypto Service Encryption User role
   - Check subscription ownership
   - Ensure correct service principals

### Support Contacts:
- Microsoft 365 Support: https://support.microsoft.com/microsoft-365
- Azure Support: Via Azure Portal
- Customer Key Documentation: https://docs.microsoft.com/purview/customer-key-overview

---

## Security Best Practices

1. **Key Management**
   - Never share key backups electronically
   - Use separate administrators for each subscription
   - Implement break-glass procedures

2. **Access Control**
   - Use Privileged Identity Management (PIM)
   - Enable MFA for all administrators
   - Regular access reviews

3. **Monitoring**
   - Enable all audit logs
   - Set up security alerts
   - Regular compliance reviews

---

## Important Considerations

1. **Performance Impact**
   - Slight latency increase for encrypted operations
   - May affect third-party tools accessing data

2. **Limitations**
   - Cannot be easily disabled once enabled
   - Affects data recovery scenarios
   - Requires careful key management

3. **Compliance**
   - Helps meet regulatory requirements
   - Provides encryption-at-rest control
   - Enables data sovereignty