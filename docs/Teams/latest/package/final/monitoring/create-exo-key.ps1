<#
.SYNOPSIS
    Complete Exchange/Teams CMK Setup - Key Vaults, Keys, RBAC, and DEP
.DESCRIPTION
    This script creates everything needed for Exchange/Teams CMK:
    1. Resource Groups (if not exist)
    2. Key Vaults with Premium SKU and Purge Protection (if not exist)
    3. RBAC role assignments for current user AND Compliance-Administrators group (if not exist)
    4. RSA 2048 keys in both vaults (if not exist)
    5. Exchange Online service principal access (if not exist)
    6. Data Encryption Policy in Exchange Online (if not exist)
    7. Optional key backups
    
    All operations check for existing resources first - safe to run multiple times.
.REQUIREMENTS
    - Az.Accounts, Az.KeyVault, Az.Resources modules
    - ExchangeOnlineManagement module
    - Global Admin or Owner + Exchange Admin permissions
.NOTES
    Author: LCE M365 Security Team
    Version: 2.0
    
    CHANGE LOG:
    v2.0 - Added RBAC support, idempotent checks, Compliance-Administrators group
    v1.0 - Initial script
#>

# ============================================
# CONFIGURATION - UPDATE IF NEEDED
# ============================================

# Tenant Configuration
$TenantId = "80b1ce91-e920-49d4-a52e-4ab189c64592"

# Subscription Configuration
$PrimarySubscriptionId = "6f114bd7-c8d3-4843-b4f8-e30a644bc412"
$SecondarySubscriptionId = "6fe93f46-fb3b-410b-8d22-540b06cbbfbc"

# Resource Groups
$PrimaryResourceGroup = "rg-cmk-exo-primary"
$SecondaryResourceGroup = "rg-cmk-exo-secondary"

# Key Vault Names
$PrimaryKeyVaultName = "kv-cmk-exo-pri-1117"
$SecondaryKeyVaultName = "kv-cmk-exo-sec-1117"

# Regions
$PrimaryLocation = "Canada Central"
$SecondaryLocation = "Canada East"

# Key Configuration
$KeyName = "exo-cmk-key"

# DEP Configuration
$DEPName = "LCE-CMK-DEP"
$DEPDescription = "Leonardo Company CMK for Exchange Online and Teams"

# Exchange Online Organization
$ExchangeOrganization = "leonardocompany.ca"

# RBAC Configuration - Groups/Users to grant Key Vault access
$ComplianceAdministratorsGroupId = "55ee252d-9a4c-4159-828f-a4e8fe98d3c5"

# Exchange Online Service Principal (Microsoft's - DO NOT CHANGE)
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
# INITIALIZATION
# ============================================

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   EXCHANGE/TEAMS CMK COMPLETE SETUP" -ForegroundColor Cyan
Write-Host "   Leonardo Company - LCE M365 Security" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Primary Key Vault:   $PrimaryKeyVaultName ($PrimaryLocation)"
Write-Host "  Secondary Key Vault: $SecondaryKeyVaultName ($SecondaryLocation)"
Write-Host "  Key Name:            $KeyName"
Write-Host "  DEP Name:            $DEPName"
Write-Host ""

# ============================================
# STEP 1: CONNECT TO AZURE
# ============================================

Write-Host "Step 1: Connecting to Azure..." -ForegroundColor Yellow

$context = Get-AzContext
if (-not $context -or $context.Tenant.Id -ne $TenantId) {
    Connect-AzAccount -TenantId $TenantId
}

# Get current user's Object ID
$currentUser = Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id -ErrorAction SilentlyContinue
if ($currentUser) {
    $currentUserObjectId = $currentUser.Id
    Write-Host "  [OK] Connected as: $($currentUser.DisplayName) ($currentUserObjectId)" -ForegroundColor Green
}
else {
    # Try to get from context
    $currentUserObjectId = (Get-AzADUser -SignedIn -ErrorAction SilentlyContinue).Id
    Write-Host "  [OK] Connected to Azure" -ForegroundColor Green
}

Write-Host ""

# ============================================
# STEP 2: CREATE/VERIFY PRIMARY RESOURCES
# ============================================

Write-Host "Step 2: Setting up PRIMARY resources ($PrimaryLocation)..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null
Write-Host "  Subscription: $PrimarySubscriptionId"

# Resource Group
$rg = Get-AzResourceGroup -Name $PrimaryResourceGroup -ErrorAction SilentlyContinue
if ($rg) {
    Write-Host "  [EXISTS] Resource Group: $PrimaryResourceGroup" -ForegroundColor DarkGreen
}
else {
    Write-Host "  [CREATING] Resource Group: $PrimaryResourceGroup..."
    New-AzResourceGroup -Name $PrimaryResourceGroup -Location $PrimaryLocation | Out-Null
    Write-Host "  [OK] Resource Group created" -ForegroundColor Green
}

# Key Vault
$primaryKv = Get-AzKeyVault -VaultName $PrimaryKeyVaultName -ResourceGroupName $PrimaryResourceGroup -ErrorAction SilentlyContinue
if ($primaryKv) {
    Write-Host "  [EXISTS] Key Vault: $PrimaryKeyVaultName" -ForegroundColor DarkGreen
    
    # Ensure purge protection is enabled
    if (-not $primaryKv.EnablePurgeProtection) {
        Write-Host "  [UPDATING] Enabling purge protection..."
        Update-AzKeyVault -VaultName $PrimaryKeyVaultName -ResourceGroupName $PrimaryResourceGroup -EnablePurgeProtection | Out-Null
        Write-Host "  [OK] Purge protection enabled" -ForegroundColor Green
    }
}
else {
    Write-Host "  [CREATING] Key Vault: $PrimaryKeyVaultName..."
    $primaryKv = New-AzKeyVault `
        -Name $PrimaryKeyVaultName `
        -ResourceGroupName $PrimaryResourceGroup `
        -Location $PrimaryLocation `
        -Sku Premium `
        -EnablePurgeProtection
    
    Write-Host "  [OK] Key Vault created" -ForegroundColor Green
    Write-Host "  [WAIT] Waiting 60 seconds for DNS propagation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
}

$PrimaryKeyVaultScope = "/subscriptions/$PrimarySubscriptionId/resourceGroups/$PrimaryResourceGroup/providers/Microsoft.KeyVault/vaults/$PrimaryKeyVaultName"

Write-Host ""

# ============================================
# STEP 3: CREATE/VERIFY SECONDARY RESOURCES
# ============================================

Write-Host "Step 3: Setting up SECONDARY resources ($SecondaryLocation)..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null
Write-Host "  Subscription: $SecondarySubscriptionId"

# Resource Group
$rg = Get-AzResourceGroup -Name $SecondaryResourceGroup -ErrorAction SilentlyContinue
if ($rg) {
    Write-Host "  [EXISTS] Resource Group: $SecondaryResourceGroup" -ForegroundColor DarkGreen
}
else {
    Write-Host "  [CREATING] Resource Group: $SecondaryResourceGroup..."
    New-AzResourceGroup -Name $SecondaryResourceGroup -Location $SecondaryLocation | Out-Null
    Write-Host "  [OK] Resource Group created" -ForegroundColor Green
}

# Key Vault
$secondaryKv = Get-AzKeyVault -VaultName $SecondaryKeyVaultName -ResourceGroupName $SecondaryResourceGroup -ErrorAction SilentlyContinue
if ($secondaryKv) {
    Write-Host "  [EXISTS] Key Vault: $SecondaryKeyVaultName" -ForegroundColor DarkGreen
    
    # Ensure purge protection is enabled
    if (-not $secondaryKv.EnablePurgeProtection) {
        Write-Host "  [UPDATING] Enabling purge protection..."
        Update-AzKeyVault -VaultName $SecondaryKeyVaultName -ResourceGroupName $SecondaryResourceGroup -EnablePurgeProtection | Out-Null
        Write-Host "  [OK] Purge protection enabled" -ForegroundColor Green
    }
}
else {
    Write-Host "  [CREATING] Key Vault: $SecondaryKeyVaultName..."
    $secondaryKv = New-AzKeyVault `
        -Name $SecondaryKeyVaultName `
        -ResourceGroupName $SecondaryResourceGroup `
        -Location $SecondaryLocation `
        -Sku Premium `
        -EnablePurgeProtection
    
    Write-Host "  [OK] Key Vault created" -ForegroundColor Green
    Write-Host "  [WAIT] Waiting 60 seconds for DNS propagation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
}

$SecondaryKeyVaultScope = "/subscriptions/$SecondarySubscriptionId/resourceGroups/$SecondaryResourceGroup/providers/Microsoft.KeyVault/vaults/$SecondaryKeyVaultName"

Write-Host ""

# ============================================
# STEP 4: CONFIGURE RBAC ON PRIMARY KEY VAULT
# ============================================

Write-Host "Step 4: Configuring RBAC on PRIMARY Key Vault..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null

# Grant to current user
if ($currentUserObjectId) {
    Write-Host "  Granting access to current user..."
    Grant-KeyVaultRBAC -ObjectId $currentUserObjectId -ObjectName "Current User" -KeyVaultName $PrimaryKeyVaultName -Scope $PrimaryKeyVaultScope
}

# Grant to Compliance-Administrators group
Write-Host "  Granting access to Compliance-Administrators group..."
Grant-KeyVaultRBAC -ObjectId $ComplianceAdministratorsGroupId -ObjectName "Compliance-Administrators" -KeyVaultName $PrimaryKeyVaultName -Scope $PrimaryKeyVaultScope

# Grant Exchange Online service principal access (Key Vault Crypto Service Encryption User)
Write-Host "  Granting access to Exchange Online service..."
$exoSP = Get-AzADServicePrincipal -ApplicationId $ExchangeServicePrincipalAppId -ErrorAction SilentlyContinue
if ($exoSP) {
    $exoRole = "Key Vault Crypto Service Encryption User"
    if (Test-RoleAssignmentExists -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $PrimaryKeyVaultScope) {
        Write-Host "    [EXISTS] $exoRole for Exchange Online" -ForegroundColor DarkGreen
    }
    else {
        try {
            New-AzRoleAssignment -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $PrimaryKeyVaultScope -ErrorAction Stop | Out-Null
            Write-Host "    [ADDED] $exoRole for Exchange Online" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*Conflict*" -or $_.Exception.Message -like "*already exists*") {
                Write-Host "    [EXISTS] $exoRole for Exchange Online" -ForegroundColor DarkGreen
            }
            else {
                Write-Host "    [WARN] Could not assign Exchange access: $_" -ForegroundColor Yellow
            }
        }
    }
}
else {
    Write-Host "    [WARN] Exchange Online service principal not found" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# STEP 5: CONFIGURE RBAC ON SECONDARY KEY VAULT
# ============================================

Write-Host "Step 5: Configuring RBAC on SECONDARY Key Vault..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null

# Grant to current user
if ($currentUserObjectId) {
    Write-Host "  Granting access to current user..."
    Grant-KeyVaultRBAC -ObjectId $currentUserObjectId -ObjectName "Current User" -KeyVaultName $SecondaryKeyVaultName -Scope $SecondaryKeyVaultScope
}

# Grant to Compliance-Administrators group
Write-Host "  Granting access to Compliance-Administrators group..."
Grant-KeyVaultRBAC -ObjectId $ComplianceAdministratorsGroupId -ObjectName "Compliance-Administrators" -KeyVaultName $SecondaryKeyVaultName -Scope $SecondaryKeyVaultScope

# Grant Exchange Online service principal access
Write-Host "  Granting access to Exchange Online service..."
if ($exoSP) {
    $exoRole = "Key Vault Crypto Service Encryption User"
    if (Test-RoleAssignmentExists -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $SecondaryKeyVaultScope) {
        Write-Host "    [EXISTS] $exoRole for Exchange Online" -ForegroundColor DarkGreen
    }
    else {
        try {
            New-AzRoleAssignment -ObjectId $exoSP.Id -RoleDefinitionName $exoRole -Scope $SecondaryKeyVaultScope -ErrorAction Stop | Out-Null
            Write-Host "    [ADDED] $exoRole for Exchange Online" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*Conflict*" -or $_.Exception.Message -like "*already exists*") {
                Write-Host "    [EXISTS] $exoRole for Exchange Online" -ForegroundColor DarkGreen
            }
            else {
                Write-Host "    [WARN] Could not assign Exchange access: $_" -ForegroundColor Yellow
            }
        }
    }
}

# Wait for RBAC propagation if roles were just assigned
Write-Host ""
Write-Host "  [WAIT] Waiting 30 seconds for RBAC propagation..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""

# ============================================
# STEP 6: CREATE KEYS
# ============================================

Write-Host "Step 6: Creating encryption keys..." -ForegroundColor Yellow

# Primary Key
Write-Host "  Creating PRIMARY key..."
Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null

$primaryKey = Get-AzKeyVaultKey -VaultName $PrimaryKeyVaultName -Name $KeyName -ErrorAction SilentlyContinue
if ($primaryKey) {
    Write-Host "    [EXISTS] Key: $($primaryKey.Id)" -ForegroundColor DarkGreen
}
else {
    $maxRetries = 3
    $retryCount = 0
    $success = $false
    
    while (-not $success -and $retryCount -lt $maxRetries) {
        $retryCount++
        try {
            $primaryKey = Add-AzKeyVaultKey `
                -VaultName $PrimaryKeyVaultName `
                -Name $KeyName `
                -Destination Software `
                -KeyType RSA `
                -Size 2048 `
                -ErrorAction Stop
            
            $success = $true
            Write-Host "    [OK] Key created: $($primaryKey.Id)" -ForegroundColor Green
        }
        catch {
            Write-Host "    [RETRY] Attempt $retryCount failed, waiting 30 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
    
    if (-not $success) {
        Write-Host "    [ERROR] Failed to create primary key after $maxRetries attempts" -ForegroundColor Red
        Write-Host "    Please create the key manually in Azure Portal" -ForegroundColor Yellow
    }
}

$PrimaryKeyUri = $primaryKey.Id

# Secondary Key
Write-Host "  Creating SECONDARY key..."
Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null

$secondaryKey = Get-AzKeyVaultKey -VaultName $SecondaryKeyVaultName -Name $KeyName -ErrorAction SilentlyContinue
if ($secondaryKey) {
    Write-Host "    [EXISTS] Key: $($secondaryKey.Id)" -ForegroundColor DarkGreen
}
else {
    $maxRetries = 3
    $retryCount = 0
    $success = $false
    
    while (-not $success -and $retryCount -lt $maxRetries) {
        $retryCount++
        try {
            $secondaryKey = Add-AzKeyVaultKey `
                -VaultName $SecondaryKeyVaultName `
                -Name $KeyName `
                -Destination Software `
                -KeyType RSA `
                -Size 2048 `
                -ErrorAction Stop
            
            $success = $true
            Write-Host "    [OK] Key created: $($secondaryKey.Id)" -ForegroundColor Green
        }
        catch {
            Write-Host "    [RETRY] Attempt $retryCount failed, waiting 30 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
    
    if (-not $success) {
        Write-Host "    [ERROR] Failed to create secondary key after $maxRetries attempts" -ForegroundColor Red
        Write-Host "    Please create the key manually in Azure Portal" -ForegroundColor Yellow
    }
}

$SecondaryKeyUri = $secondaryKey.Id

Write-Host ""
Write-Host "  Key URIs:" -ForegroundColor Cyan
Write-Host "    Primary:   $PrimaryKeyUri"
Write-Host "    Secondary: $SecondaryKeyUri"
Write-Host ""

# ============================================
# STEP 7: CREATE DEP IN EXCHANGE ONLINE
# ============================================

Write-Host "Step 7: Creating Data Encryption Policy (DEP)..." -ForegroundColor Yellow

# Validate we have key URIs
if (-not $PrimaryKeyUri -or -not $SecondaryKeyUri) {
    Write-Host "  [ERROR] Cannot create DEP - missing key URIs" -ForegroundColor Red
    Write-Host "  Please ensure keys were created successfully and run again" -ForegroundColor Yellow
}
else {
    # Connect to Exchange Online
    Write-Host "  Connecting to Exchange Online..."
    try {
        Get-OrganizationConfig -ErrorAction Stop | Out-Null
        Write-Host "    [OK] Already connected" -ForegroundColor DarkGreen
    }
    catch {
        try {
            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
            Write-Host "    [OK] Connected to Exchange Online" -ForegroundColor Green
        }
        catch {
            Write-Host "    [ERROR] Failed to connect to Exchange Online: $_" -ForegroundColor Red
            Write-Host "    Please connect manually and create the DEP" -ForegroundColor Yellow
        }
    }
    
    # Check if DEP exists
    $existingDEP = Get-DataEncryptionPolicy -Identity $DEPName -ErrorAction SilentlyContinue
    
    if ($existingDEP) {
        Write-Host "  [EXISTS] DEP: $DEPName" -ForegroundColor DarkGreen
        Write-Host "    State:   $($existingDEP.State)"
        Write-Host "    Enabled: $($existingDEP.Enabled)"
        Write-Host "    Keys:    $($existingDEP.AzureKeyIDs -join ', ')"
    }
    else {
        Write-Host "  [CREATING] DEP: $DEPName..."
        
        try {
            New-DataEncryptionPolicy `
                -Name $DEPName `
                -Description $DEPDescription `
                -AzureKeyIDs @($PrimaryKeyUri, $SecondaryKeyUri) `
                -ErrorAction Stop
            
            Write-Host "  [OK] DEP CREATED SUCCESSFULLY!" -ForegroundColor Green
            
            # Verify
            Start-Sleep -Seconds 3
            $newDEP = Get-DataEncryptionPolicy -Identity $DEPName -ErrorAction SilentlyContinue
            if ($newDEP) {
                Write-Host ""
                Write-Host "  DEP Details:" -ForegroundColor Cyan
                Write-Host "    Name:    $($newDEP.Name)"
                Write-Host "    State:   $($newDEP.State)"
                Write-Host "    Enabled: $($newDEP.Enabled)"
            }
        }
        catch {
            Write-Host "  [ERROR] Failed to create DEP: $_" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Manual command to create DEP:" -ForegroundColor Yellow
            Write-Host @"

New-DataEncryptionPolicy -Name "$DEPName" ``
    -Description "$DEPDescription" ``
    -AzureKeyIDs @(
        "$PrimaryKeyUri",
        "$SecondaryKeyUri"
    )
"@ -ForegroundColor Gray
        }
    }
}

Write-Host ""

# ============================================
# STEP 8: BACKUP KEYS
# ============================================

Write-Host "Step 8: Key backup..." -ForegroundColor Yellow

$backupKeys = Read-Host "  Backup keys now? (RECOMMENDED for disaster recovery) (y/n)"

if ($backupKeys -eq "y") {
    $backupPath = "$HOME\CMK-Key-Backups"
    
    if (-not (Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    
    try {
        # Backup primary key
        Set-AzContext -SubscriptionId $PrimarySubscriptionId | Out-Null
        $primaryBackupFile = Join-Path $backupPath "exo-cmk-PRIMARY-$timestamp.backup"
        Backup-AzKeyVaultKey -VaultName $PrimaryKeyVaultName -Name $KeyName -OutputFile $primaryBackupFile -ErrorAction Stop | Out-Null
        Write-Host "    [OK] Primary key backed up: $primaryBackupFile" -ForegroundColor Green
        
        # Backup secondary key
        Set-AzContext -SubscriptionId $SecondarySubscriptionId | Out-Null
        $secondaryBackupFile = Join-Path $backupPath "exo-cmk-SECONDARY-$timestamp.backup"
        Backup-AzKeyVaultKey -VaultName $SecondaryKeyVaultName -Name $KeyName -OutputFile $secondaryBackupFile -ErrorAction Stop | Out-Null
        Write-Host "    [OK] Secondary key backed up: $secondaryBackupFile" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "  IMPORTANT: Store these backup files securely!" -ForegroundColor Red
        Write-Host "  Location: $backupPath" -ForegroundColor Yellow
    }
    catch {
        Write-Host "    [WARN] Backup failed: $_" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  [SKIP] Key backup skipped" -ForegroundColor Gray
    Write-Host "  WARNING: Without backups, key loss = data loss!" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# SUMMARY
# ============================================

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "RESOURCES CREATED/VERIFIED:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Key Vaults:" -ForegroundColor White
Write-Host "    Primary:   $PrimaryKeyVaultName ($PrimaryLocation)"
Write-Host "    Secondary: $SecondaryKeyVaultName ($SecondaryLocation)"
Write-Host ""
Write-Host "  Keys:" -ForegroundColor White
Write-Host "    Primary:   $PrimaryKeyUri"
Write-Host "    Secondary: $SecondaryKeyUri"
Write-Host ""
Write-Host "  RBAC Assignments:" -ForegroundColor White
Write-Host "    - Current User: Key Vault Crypto Officer, Key Vault Secrets Officer"
Write-Host "    - Compliance-Administrators ($ComplianceAdministratorsGroupId):"
Write-Host "      Key Vault Crypto Officer, Key Vault Secrets Officer"
Write-Host "    - Exchange Online: Key Vault Crypto Service Encryption User"
Write-Host ""
Write-Host "  DEP Policy:" -ForegroundColor White
Write-Host "    Name: $DEPName"
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Green
Write-Host "  1. Verify DEP: Get-DataEncryptionPolicy -Identity '$DEPName'"
Write-Host "  2. Update CMK runbook: `$ExchangeDEPName = '$DEPName'"
Write-Host "  3. Run CMK compliance runbook to auto-apply DEP to group members"
Write-Host "  4. Or manually apply: Set-Mailbox -Identity <user> -DataEncryptionPolicy '$DEPName'"
Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green