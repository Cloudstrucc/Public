# FINTRAC Power Platform VNet Integration Build Book

## Introduction

As a financial intelligence agency operating under strict security standards, FINTRAC requires all cloud-hosted services to minimize surface exposure to the public internet. Microsoft Power Platform now supports **Virtual Network (VNet) Integration** for **Managed Environments**, allowing the Dataverse APIs and services to operate exclusively within a customer-managed Azure Virtual Network via **Private Endpoints**.

This ensures secure, internal-only communication for applications such as Power Apps, Power Automate, and external integrations consuming Dataverse. This build book provides step-by-step guidance to configure this feature using either a **new or existing VNet**, with options for **manual configuration or PowerShell automation**, aligned with FINTRAC's Protected B security requirements.

---

## Pre-requisites Checklist

Ensure the following items are ready before proceeding:

- [ ] Azure subscription with **Owner** or **Contributor** access
- [ ] Power Platform Managed Environment created in **Canada Central** or **Canada East**
- [ ] Azure region of VNet matches the Dataverse environment region
- [ ] `Network Contributor` and `Private Endpoint Contributor` roles assigned
- [ ] An Azure VNet and subnet with **no NSG blocking outbound access**
- [ ] Ability to create or link a **Private DNS Zone** for `privatelink.crm3.dynamics.com`
- [ ] PowerShell 7.x installed with Azure modules
- [ ] Power Platform CLI (`pac`) installed

---

## Step 1: Create or Identify an Azure Virtual Network (VNet)

### Option A: Create a New VNet (Manual)

1. Go to [Azure Portal](https://portal.azure.com).
2. Navigate to: **Virtual Networks** > **+ Create**.
3. Set the following:
   - **Subscription**: [Your Azure subscription]
   - **Resource Group**: `fintrac-prod-rg`
   - **Region**: `Canada Central` or `Canada East`
   - **Name**: `fintrac-vnet`
4. Under **IP Addresses**:
   - Address space: `10.10.0.0/16`
   - Subnet: `dataverse-subnet` (`10.10.1.0/24`)
5. Click **Review + Create**.

---

## Step 2: Enable VNet Integration on Dataverse Environment (Manual)

1. Open [Power Platform Admin Center](https://admin.powerplatform.microsoft.com).
2. Navigate to your **FINTRAC** environment.
3. Go to **Settings** > **Product** > **Features**.
4. Under **Network configuration**:
   - Enable **Restrict access to Dataverse**
   - Choose **Connect to a virtual network**
   - Select:
     - **Subscription**
     - **Virtual Network**: `fintrac-vnet`
     - **Subnet**: `dataverse-subnet`
5. Save and wait for provisioning to complete (5–10 minutes).

---

## Step 3: Configure DNS (Manual)

1. In **Azure Portal**, go to **Private DNS Zones** > **+ Create**.
2. Name: `privatelink.crm3.dynamics.com`
3. Resource Group: `fintrac-prod-rg`
4. After creation, go to:
   - **Virtual network links** > **+ Add**
   - Name: `fintrac-dns-link`
   - Select `fintrac-vnet`, and disable auto-registration
5. Validate A record is created (Azure will auto-create it)

Use `nslookup` from a VM inside the subnet to confirm resolution.

---

## Step 4: Validate Private Endpoint Connectivity

1. Deploy a test **Windows VM** in the same VNet.
2. Run from PowerShell inside the VM:
```powershell
   nslookup yourenv.crm3.dynamics.com
   Invoke-RestMethod -Uri https://yourenv.crm3.dynamics.com/api/data/v9.2/WhoAmI -Headers @{Authorization = "Bearer <access_token>"}
```

3. Expected: Private IP response and valid WhoAmI result.

---

## Step 5: Restrict Public Access (Manual)

1. In Admin Center:

   * Go to **Settings** > **Features**
   * Under **Network**, select:

     * **Restrict access to only the selected virtual network**
2. Save changes.

---

## Step 6: Optional – Infrastructure as Code

You may use **Azure Bicep**, **Terraform**, or **PowerShell** for automated provisioning.

---

## Step 7: PowerShell Automation (Alternative Method)

Microsoft provides PowerShell-based automation via downloadable scripts.

### Download and Inspect the Scripts

1. Go to Microsoft Docs:

   * [Script Reference](https://learn.microsoft.com/en-us/power-platform/admin/vnet-support-setup-configure?tabs=new#using-powershell-to-configure-vnet-integration)
2. Download the following:

   * `Create-VNetAndSubnet.ps1`
   * `Create-PrivateDnsZone.ps1`
   * `Link-VNetAndDnsZone.ps1`
   * `Configure-DataverseVNetIntegration.ps1`

> **Tip**: Always open the script in a code editor to inspect for hardcoded names and ensure region-specific values (e.g., `Canada Central`, `privatelink.crm3.dynamics.com`).

---

### A. Create a VNet and Subnet

**Script**: `Create-VNetAndSubnet.ps1`

**What it does**:

* Creates a new resource group, VNet, and subnet.

**Edit Required**:

* Replace values for:

  * `$resourceGroupName`
  * `$vnetName`
  * `$subnetName`
  * `$region` = `"canadacentral"` or `"canadaeast"`

**Run**:

```powershell
.\Create-VNetAndSubnet.ps1
```

---

### B. Create Private DNS Zone

**Script**: `Create-PrivateDnsZone.ps1`

**What it does**:

* Creates a private DNS zone for Power Platform.
* Zone name: `privatelink.crm3.dynamics.com`

**Edit Required**:

* Set correct `$resourceGroupName` and `$zoneName`

**Run**:

```powershell
.\Create-PrivateDnsZone.ps1
```

---

### C. Link DNS Zone to VNet

**Script**: `Link-VNetAndDnsZone.ps1`

**What it does**:

* Links DNS zone to the specified VNet.
* Enables name resolution from inside the VNet.

**Edit Required**:

* `$dnsZoneName` = `"privatelink.crm3.dynamics.com"`
* `$vnetName`, `$linkName`

**Run**:

```powershell
.\Link-VNetAndDnsZone.ps1
```

---

### D. Configure Dataverse VNet Integration

**Script**: `Configure-DataverseVNetIntegration.ps1`

**What it does**:

* Connects a Dataverse environment to the specified subnet.

**Pre-Req**:

* Install `Microsoft.PowerApps.Administration.PowerShell` and `Microsoft.PowerApps.PowerShell` modules
* Authenticate with:

  ```powershell
  Add-PowerAppsAccount
  ```

**Edit Required**:

* `$environmentName`
* `$subnetId` (use Azure Portal or script to retrieve this)

**Run**:

```powershell
.\Configure-DataverseVNetIntegration.ps1
```

---

## Troubleshooting Tips

| Issue                              | Resolution                                               |
| ---------------------------------- | -------------------------------------------------------- |
| No DNS resolution                  | Check VNet DNS link and zone records                     |
| 403 Access Denied                  | Public access may still be active or not yet disabled    |
| Endpoint not working               | Validate provisioning status and correct subnet IP usage |
| Cannot resolve `crm3.dynamics.com` | Use VM in same subnet and `nslookup` to confirm          |

---

## References

* [Configure Power Platform VNet Integration](https://learn.microsoft.com/en-us/power-platform/admin/vnet-support-setup-configure?tabs=new)
* [PowerShell Script Downloads](https://learn.microsoft.com/en-us/power-platform/admin/vnet-support-setup-configure?tabs=new#using-powershell-to-configure-vnet-integration)
* [Azure Private Link DNS Overview](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
* [Azure DNS Zones](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
* [PAC CLI Reference](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)

*Document prepared for FINTRAC — Managed Power Platform Configuration | Last updated: May 2025*

---
