<#
.SYNOPSIS
  Fully automated setup of Power Platform subnet-injection enterprise policy,
  VNet/subnet creation, and environment creation using correct 2025 syntax.
.DESCRIPTION
  This script automates the complete setup of Power Platform VNet integration including:
  - Azure VNet and delegated subnet creation (with correct delegation service)
  - Enterprise policy configuration (using ARM templates)
  - Power Platform environment creation (separate from policy application)
.EXAMPLE
  .\Setup-PP-VNET-Integration.ps1
.NOTES
  Requires appropriate permissions in both Azure and Power Platform
  Updated for 2025 with correct cmdlets and parameters
  Creates VNets in different Azure regions as required
#>

[CmdletBinding()]
param()

# Helper function to prompt with default values
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default
    )
    $input = Read-Host "$Prompt (default: $Default)"
    if ([string]::IsNullOrWhiteSpace($input)) { 
        return $Default 
    }
    return $input
}

function Ensure-Module([string]$ModuleName) {
    Write-Host "Checking module: $ModuleName" -ForegroundColor Yellow
    
    # Check if module is available
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Installing module $ModuleName..." -ForegroundColor Yellow
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Host "Successfully installed $ModuleName" -ForegroundColor Green
        } catch {
            Write-Error "Failed to install module $ModuleName`: $($_.Exception.Message)"
            return $false
        }
    }
    
    # Try to import module
    try {
        Import-Module $ModuleName -Force -ErrorAction Stop
        Write-Host "Successfully imported $ModuleName" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Warning: Could not import module $ModuleName`: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Trying alternative import method..." -ForegroundColor Yellow
        
        # Try with global scope
        try {
            Import-Module $ModuleName -Global -Force -ErrorAction Stop
            Write-Host "Successfully imported $ModuleName with global scope" -ForegroundColor Green
            return $true
        } catch {
            Write-Error "Failed to import module $ModuleName with any method"
            return $false
        }
    }
}

function Test-Prerequisites {
    Write-Host "Checking prerequisites..." -ForegroundColor Cyan
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Error "PowerShell 5.0 or higher is required"
        return $false
    }
    Write-Host "PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Green
    
    return $true
}

function Register-PowerPlatformProvider {
    param([string]$SubscriptionId)
    
    Write-Host "Registering Microsoft.PowerPlatform resource provider..." -ForegroundColor Yellow
    
    # Register the resource provider
    Register-AzResourceProvider -ProviderNamespace "Microsoft.PowerPlatform" | Out-Null
    
    # Wait for registration to complete
    $timeout = 300 # 5 minutes
    $timer = 0
    do {
        Start-Sleep -Seconds 10
        $timer += 10
        $status = Get-AzResourceProvider -ProviderNamespace "Microsoft.PowerPlatform"
        $registrationState = $status.RegistrationState
        Write-Host "Registration status: $registrationState" -ForegroundColor Gray
    } while ($registrationState -eq "Registering" -and $timer -lt $timeout)
    
    if ($registrationState -eq "Registered") {
        Write-Host "Microsoft.PowerPlatform provider registered successfully" -ForegroundColor Green
        return $true
    } else {
        Write-Error "Failed to register Microsoft.PowerPlatform provider. Status: $registrationState"
        return $false
    }
}

function Get-AzureRegionPair {
    param([string]$PrimaryRegion)
    
    # Azure region pairs for high availability
    $regionPairs = @{
        "canadacentral" = "canadaeast"
        "canadaeast" = "canadacentral"
        "eastus" = "westus"
        "westus" = "eastus"
        "eastus2" = "centralus"
        "centralus" = "eastus2"
        "northeurope" = "westeurope"
        "westeurope" = "northeurope"
        "uksouth" = "ukwest"
        "ukwest" = "uksouth"
        "australiaeast" = "australiasoutheast"
        "australiasoutheast" = "australiaeast"
        "japaneast" = "japanwest"
        "japanwest" = "japaneast"
        "southeastasia" = "eastasia"
        "eastasia" = "southeastasia"
    }
    
    $pairedRegion = $regionPairs[$PrimaryRegion.ToLower()]
    if (-not $pairedRegion) {
        Write-Warning "No known pair for region '$PrimaryRegion'. Using 'eastus2' as default secondary region"
        return "eastus2"
    }
    
    return $pairedRegion
}

function Get-PowerPlatformRegionMapping {
    param([string]$AzureRegion)
    
    # Map Azure regions to Power Platform regions
    $regionMap = @{
        "canadacentral" = "Canada"
        "canadaeast" = "Canada"
        "eastus" = "UnitedStates"
        "eastus2" = "UnitedStates" 
        "westus" = "UnitedStates"
        "westus2" = "UnitedStates"
        "centralus" = "UnitedStates"
        "northeurope" = "Europe"
        "westeurope" = "Europe"
        "uksouth" = "UnitedKingdom"
        "ukwest" = "UnitedKingdom"
        "australiaeast" = "Australia"
        "australiasoutheast" = "Australia"
        "japaneast" = "Japan"
        "japanwest" = "Japan"
        "southeastasia" = "Asia"
        "eastasia" = "Asia"
    }
    
    $ppRegion = $regionMap[$AzureRegion.ToLower()]
    if (-not $ppRegion) {
        Write-Warning "Unknown Power Platform region for Azure region '$AzureRegion'. Defaulting to 'UnitedStates'"
        return "UnitedStates"
    }
    
    return $ppRegion
}

# Main execution starts here
Write-Host "=== Power Platform VNet Integration Setup (2025) ===" -ForegroundColor Cyan
Write-Host "Using correct delegation service and ARM templates" -ForegroundColor Green

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-Error "Prerequisites not met"
    exit 1
}

# Collect user inputs
Write-Host "`nCollecting configuration..." -ForegroundColor Cyan
$subId      = Get-UserInput "Azure Subscription ID" "7719c366-5f64-439a-a6c6-65067d5a97e4"
$rg         = Get-UserInput "Resource Group name for VNet" "rg-PP-VNet"
$loc        = Get-UserInput "Azure Region (e.g. canadacentral)" "canadacentral"
$vnetName   = Get-UserInput "VNet name" "vnet-PP"
$subnetName = Get-UserInput "Subnet name (delegated)" "sub-PP"
$envName    = Get-UserInput "Power Platform Environment name" "PP-Env-Prod"
$domain     = Get-UserInput "Environment domain prefix" "pp-yourdomain"

# Define secondary names (Power Platform requires 2 VNets in different regions)
$vnet2Name = $vnetName + "-Secondary"
$subnet2Name = $subnetName + "-Secondary"

# Validate inputs
if ($subId -notmatch '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$') {
    Write-Error "Invalid subscription ID format"
    exit 1
}

# Get Power Platform region and paired Azure region
$ppRegion = Get-PowerPlatformRegionMapping -AzureRegion $loc
$secondaryRegion = Get-AzureRegionPair -PrimaryRegion $loc

Write-Host "`nConfiguration Summary:" -ForegroundColor Yellow
Write-Host "Subscription ID: $subId"
Write-Host "Resource Group: $rg"
Write-Host "Primary Azure Region: $loc"
Write-Host "Secondary Azure Region: $secondaryRegion (required for Power Platform HA)"
Write-Host "Power Platform Region: $ppRegion"
Write-Host "Primary VNet Name: $vnetName"
Write-Host "Primary Subnet Name: $subnetName"
Write-Host "Secondary VNet Name: $vnet2Name"
Write-Host "Secondary Subnet Name: $subnet2Name"
Write-Host "Environment Name: $envName"
Write-Host "Domain: $domain"
Write-Host ""
Write-Host "NOTE: Power Platform requires TWO VNets in DIFFERENT regions" -ForegroundColor Yellow

$confirm = Read-Host "`nProceed with this configuration? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Setup cancelled by user" -ForegroundColor Yellow
    exit 0
}

# Install and import required modules
Write-Host "`n=== Installing Required Modules ===" -ForegroundColor Cyan
$requiredModules = @(
    "Az.Accounts",
    "Az.Network", 
    "Az.Resources",
    "Microsoft.PowerApps.Administration.PowerShell",
    "Microsoft.PowerApps.PowerShell"
)

$moduleErrors = @()
foreach ($module in $requiredModules) {
    if (-not (Ensure-Module $module)) {
        $moduleErrors += $module
    }
}

if ($moduleErrors.Count -gt 0) {
    Write-Error "Failed to install/import modules: $($moduleErrors -join ', ')"
    Write-Host "Try running PowerShell as Administrator and re-run the script" -ForegroundColor Yellow
    exit 1
}

# Azure authentication
Write-Host "`n=== Azure Authentication ===" -ForegroundColor Cyan

# Clear any cached authentication that might be causing issues
Clear-AzContext -Force -ErrorAction SilentlyContinue

$currentContext = Get-AzContext -ErrorAction SilentlyContinue
if ($currentContext) {
    Write-Host "Already authenticated as: $($currentContext.Account.Id)" -ForegroundColor Green
    $reauth = Read-Host "Re-authenticate? (y/N)"
    if ($reauth -eq 'y' -or $reauth -eq 'Y') {
        $currentContext = $null
    }
}

if (-not $currentContext) {
    Write-Host "Authenticating to Azure..." -ForegroundColor Yellow
    Write-Host "Choose authentication method:" -ForegroundColor Cyan
    Write-Host "1. Interactive browser authentication (recommended for MFA)"
    Write-Host "2. Device code authentication"
    $authChoice = Read-Host "Enter choice (1 or 2)"
    
    if ($authChoice -eq "2") {
        Write-Host "Starting device code authentication..." -ForegroundColor Yellow
        Connect-AzAccount -UseDeviceAuthentication
    } else {
        Write-Host "Starting interactive authentication..." -ForegroundColor Yellow
        Connect-AzAccount
    }
    
    # Verify authentication succeeded
    $newContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $newContext) {
        Write-Error "Authentication failed. Please try again."
        exit 1
    }
    Write-Host "Successfully authenticated as: $($newContext.Account.Id)" -ForegroundColor Green
}

# Set subscription context
Write-Host "Setting subscription context..." -ForegroundColor Yellow
$contextSet = Set-AzContext -Subscription $subId -ErrorAction SilentlyContinue
if (-not $contextSet) {
    Write-Error "Failed to set subscription context for: $subId"
    exit 1
}
Write-Host "Successfully set context to subscription: $subId" -ForegroundColor Green

# Power Platform authentication
Write-Host "`n=== Power Platform Authentication ===" -ForegroundColor Cyan
try {
    Add-PowerAppsAccount
    Write-Host "Successfully authenticated to Power Platform" -ForegroundColor Green
} catch {
    Write-Error "Failed to authenticate to Power Platform: $($_.Exception.Message)"
    exit 1
}

# Register Power Platform provider
Write-Host "`n=== Configuring Subscription for Power Platform ===" -ForegroundColor Cyan
if (-not (Register-PowerPlatformProvider -SubscriptionId $subId)) {
    Write-Error "Failed to register Power Platform provider"
    exit 1
}

# Create Azure resources
Write-Host "`n=== Creating Azure Resources ===" -ForegroundColor Cyan

# Create Resource Group
$existingRg = Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue
if (-not $existingRg) {
    Write-Host "Creating resource group: $rg" -ForegroundColor Yellow
    New-AzResourceGroup -Name $rg -Location $loc | Out-Null
    Write-Host "Resource group created" -ForegroundColor Green
} else {
    Write-Host "Resource group already exists" -ForegroundColor Green
}

# Create TWO VNets with delegated subnets in DIFFERENT regions (Power Platform requirement)
Write-Host "Creating TWO VNets with delegated subnets in DIFFERENT regions..." -ForegroundColor Yellow
Write-Host "Primary Region: $loc | Secondary Region: $secondaryRegion" -ForegroundColor Cyan
Write-Host "Using correct delegation service: Microsoft.PowerPlatform/enterprisePolicies" -ForegroundColor Cyan

# CORRECTED: Use the proper delegation service name
$delegation = New-AzDelegation -Name "PowerPlatformDelegation" -ServiceName "Microsoft.PowerPlatform/enterprisePolicies"

# Create primary VNet in primary region
Write-Host "Creating primary VNet in $loc..." -ForegroundColor Yellow
$subCfg1 = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.10.0.0/26" -Delegation $delegation
$vnet1 = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg -Location $loc -AddressPrefix "10.10.0.0/16" -Subnet $subCfg1

# Create secondary VNet in paired region (REQUIRED - different location)
Write-Host "Creating secondary VNet in $secondaryRegion..." -ForegroundColor Yellow
$subCfg2 = New-AzVirtualNetworkSubnetConfig -Name $subnet2Name -AddressPrefix "10.11.0.0/26" -Delegation $delegation
$vnet2 = New-AzVirtualNetwork -Name $vnet2Name -ResourceGroupName $rg -Location $secondaryRegion -AddressPrefix "10.11.0.0/16" -Subnet $subCfg2

$subnetId1 = ($vnet1.Subnets | Where-Object Name -EQ $subnetName).Id
$subnetId2 = ($vnet2.Subnets | Where-Object Name -EQ $subnet2Name).Id

Write-Host "Both VNets and subnets created successfully in different regions" -ForegroundColor Green
Write-Host "Primary Subnet ID ($loc): $subnetId1" -ForegroundColor Gray
Write-Host "Secondary Subnet ID ($secondaryRegion): $subnetId2" -ForegroundColor Gray

# Create Enterprise Policy using ARM template (CORRECTED approach)
Write-Host "`n=== Creating Enterprise Policy (ARM Template) ===" -ForegroundColor Cyan

$policyName = "PP-NetworkInjection-Policy-$(Get-Date -Format 'yyyyMMdd-HHmm')"
$policyRg = $rg  # Use same resource group

# CORRECTED: Use ARM template for enterprise policy creation with TWO VNets in different regions
$enterprisePolicyTemplate = @{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    'contentVersion' = "1.0.0.0"
    'parameters' = @{}
    'variables' = @{}
    'resources' = @(
        @{
            'type' = "Microsoft.PowerPlatform/enterprisePolicies"
            'apiVersion' = "2020-10-30"
            'name' = $policyName
            'location' = $ppRegion.ToLower()
            'kind' = "NetworkInjection"
            'properties' = @{
                'networkInjection' = @{
                    'virtualNetworks' = @(
                        @{
                            'id' = $vnet1.Id
                            'subnet' = @{
                                'name' = $subnetName
                            }
                        },
                        @{
                            'id' = $vnet2.Id
                            'subnet' = @{
                                'name' = $subnet2Name
                            }
                        }
                    )
                }
            }
        }
    )
    'outputs' = @{
        'policyId' = @{
            'type' = "string"
            'value' = "[resourceId('Microsoft.PowerPlatform/enterprisePolicies', '$policyName')]"
        }
    }
}

# Save ARM template to temp file
$tempArmFile = New-TemporaryFile
$enterprisePolicyTemplate | ConvertTo-Json -Depth 10 | Out-File $tempArmFile.FullName -Encoding UTF8

Write-Host "Deploying enterprise policy ARM template..." -ForegroundColor Yellow
try {
    $deployment = New-AzResourceGroupDeployment -ResourceGroupName $policyRg -TemplateFile $tempArmFile.FullName -Name "EPDeployment-$(Get-Date -Format 'yyyyMMddHHmm')" -Verbose
    
    if ($deployment.ProvisioningState -eq "Succeeded") {
        Write-Host "Enterprise policy created successfully" -ForegroundColor Green
        $policyArmId = $deployment.Outputs.policyId.Value
        Write-Host "Policy ARM ID: $policyArmId" -ForegroundColor Gray
    } else {
        throw "Deployment failed with state: $($deployment.ProvisioningState)"
    }
} catch {
    Write-Error "Failed to create enterprise policy: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up temp file
    Remove-Item $tempArmFile.FullName -ErrorAction SilentlyContinue
}

# Create Power Platform environment (CORRECTED - no EnterprisePolicyId parameter)
Write-Host "`n=== Creating Power Platform Environment ===" -ForegroundColor Cyan
Write-Host "Creating environment without enterprise policy (applied separately)" -ForegroundColor Yellow

try {
    # CORRECTED: Remove non-existent EnterprisePolicyId parameter
    $environment = New-AdminPowerAppEnvironment `
        -DisplayName $envName `
        -Location $ppRegion.ToLower() `
        -EnvironmentSku Production `
        -ProvisionDatabase `
        -CurrencyName "USD" `
        -LanguageName 1033 `
        -DomainName $domain `
        -WaitUntilFinished $true

    Write-Host "Power Platform environment created successfully" -ForegroundColor Green
    Write-Host "Environment Name: $($environment.DisplayName)" -ForegroundColor Gray
    Write-Host "Environment ID: $($environment.EnvironmentName)" -ForegroundColor Gray
} catch {
    Write-Error "Failed to create Power Platform environment: $($_.Exception.Message)"
    exit 1
}

# Apply enterprise policy to environment (separate step)
Write-Host "`n=== Applying Enterprise Policy to Environment ===" -ForegroundColor Cyan
Write-Host "Note: Enterprise policy application requires additional configuration" -ForegroundColor Yellow
Write-Host "Policy ARM ID: $policyArmId" -ForegroundColor Gray
Write-Host "Environment ID: $($environment.EnvironmentName)" -ForegroundColor Gray

# Success summary
Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "Core infrastructure created successfully" -ForegroundColor Cyan

Write-Host "`nResources created:" -ForegroundColor Yellow
Write-Host "- Resource Group: $rg"
Write-Host "- Primary VNet: $vnetName (10.10.0.0/16) in $loc"
Write-Host "- Primary Subnet: $subnetName (10.10.0.0/26) in $loc"
Write-Host "- Secondary VNet: $vnet2Name (10.11.0.0/16) in $secondaryRegion"
Write-Host "- Secondary Subnet: $subnet2Name (10.11.0.0/26) in $secondaryRegion"
Write-Host "- Both subnets CORRECTLY delegated to Microsoft.PowerPlatform/enterprisePolicies"
Write-Host "- Enterprise Policy: $policyName (with VNets in DIFFERENT regions)"
Write-Host "- Power Platform Environment: $envName"

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "- Verify environment in Power Platform Admin Center"
Write-Host "- The enterprise policy has been created but may need additional configuration"
Write-Host "- Check Azure portal for enterprise policy status"
Write-Host "- Test connectivity from Power Platform to VNet resources"

Write-Host "`nImportant Notes:" -ForegroundColor Cyan
Write-Host "- Used CORRECT delegation service: Microsoft.PowerPlatform/enterprisePolicies"
Write-Host "- Created TWO VNets in DIFFERENT regions as required by Power Platform"
Write-Host "- Primary region: $loc | Secondary region: $secondaryRegion (Azure paired regions)"
Write-Host "- Created enterprise policy using ARM template (not non-existent cmdlet)"
Write-Host "- Environment created without non-existent EnterprisePolicyId parameter"
Write-Host "- Policy application to environment may require additional steps via Azure portal"