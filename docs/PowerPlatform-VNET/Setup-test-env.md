## Prerequisites for Spinning Up a Free/Low-Cost Linux VM on Azure

Before you start, make sure you have:

* **Azure Subscription**: Either a pay-as-you-go or free trial subscription (with access to B1s or similar VM sku).
* **Azure CLI** installed locally (or use Azure Cloud Shell in the portal).
* **SSH key pair** for secure Linux access:

  ```bash
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_vm -C "azure-vm"
  ```
* **Checked quotas**: Ensure your subscription has at least one vCPU and 1 GB RAM free in your target region (e.g. `canadacentral`).
* **Resource Group**: Decide on or create a RG to contain your VM, e.g. `rg-free-vm`.

---

## Option A: Azure CLI (Reference)

*(Already covered before; see above for CLI steps.)*

---

## Option B: Azure Portal UX

1. Sign in to the [Azure Portal](https://portal.azure.com).
2. Click **+ Create a resource** → **Compute** → **Ubuntu Server 20.04 LTS** (or desired distro).
3. **Basics tab**:

   * **Subscription**: Select your subscription.
   * **Resource group**: Select **Create new** and enter `rg-free-vm`.
   * **Virtual machine name**: `vm-free-linux`.
   * **Region**: `Canada Central`.
   * **Availability options**: No infrastructure redundancy required.
   * **Image**: Ubuntu Server 20.04 LTS.
   * **Size**: Click **Change size**, choose **B1s** (Free tier eligible).
   * **Authentication type**: **SSH public key**.

     * **Username**: `azureuser`.
     * **SSH public key source**: **Use existing key** and paste `~/.ssh/id_ed25519_vm.pub`.
4. **Disks tab**: Leave **OS disk type** as **Standard SSD** (default).
5. **Networking tab**:

   * **Virtual network**: Create new or use existing VNet.
   * **Subnet**: Default.
   * **Public IP**: Leave **Create new**.
   * **NIC network security group**: Basic → **Allow selected ports** → SSH (22).
6. **Management, Monitoring, Tags**: accept defaults or tag as `Environment=Test`.
7. Review + Create → **Create**.
8. When deployment finishes, go to the VM resource, note **Public IP address**, and SSH in:

   ```bash
   ssh azureuser@<PUBLIC_IP>
   ```

---

## Option C: ARM Template Automation

1. **Save** the following JSON as `free-linux-vm.json`:

   ```json
   {
     "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
     "contentVersion": "1.0.0.0",
     "parameters": {
       "vmName": { "type": "string", "defaultValue": "vm-free-linux" },
       "adminUsername": { "type": "string", "defaultValue": "azureuser" },
       "sshKeyData": { "type": "string" },
       "vmSize": { "type": "string", "defaultValue": "Standard_B1s" },
       "location": { "type": "string", "defaultValue": "canadacentral" }
     },
     "resources": [
       {
         "type": "Microsoft.Compute/virtualMachines",
         "apiVersion": "2021-07-01",
         "name": "[parameters('vmName')]",
         "location": "[parameters('location')]",
         "properties": {
           "hardwareProfile": { "vmSize": "[parameters('vmSize')]" },
           "osProfile": {
             "computerName": "[parameters('vmName')]",
             "adminUsername": "[parameters('adminUsername')]",
             "linuxConfiguration": {
               "disablePasswordAuthentication": true,
               "ssh": {
                 "publicKeys": [
                   { "path": "/home/[parameters('adminUsername')]/.ssh/authorized_keys", "keyData": "[parameters('sshKeyData')]" }
                 ]
               }
             }
           },
           "storageProfile": {
             "imageReference": { "publisher": "Canonical", "offer": "0001-com-ubuntu-server-focal", "sku": "20_04-lts", "version": "latest" },
             "osDisk": { "createOption": "FromImage" }
           },
           "networkProfile": {
             "networkInterfaces": [
               {
                 "id": "[resourceId('Microsoft.Network/networkInterfaces', concat(parameters('vmName'), '-nic'))]"
               }
             ]
           }
         }
       },
       {
         "type": "Microsoft.Network/networkInterfaces",
         "apiVersion": "2021-08-01",
         "name": "[concat(parameters('vmName'), '-nic')]",
         "location": "[parameters('location')]",
         "properties": {
           "ipConfigurations": [
             {
               "name": "ipconfig1",
               "properties": {
                 "subnet": { "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', 'myVNet', 'default')]" },
                 "privateIPAllocationMethod": "Dynamic",
                 "publicIPAddress": { "id": "[resourceId('Microsoft.Network/publicIPAddresses', concat(parameters('vmName'), '-pip'))]" }
               }
             }
           ]
         }
       },
       {
         "type": "Microsoft.Network/publicIPAddresses",
         "apiVersion": "2021-08-01",
         "name": "[concat(parameters('vmName'), '-pip')]",
         "location": "[parameters('location')]",
         "properties": { "publicIPAllocationMethod": "Dynamic" }
       }
     ]
   }
   ```
2. **Deploy** via Azure CLI:

   ```bash
   az deployment group create \
     --resource-group rg-free-vm \
     --template-file free-linux-vm.json \
     --parameters sshKeyData="$(cat ~/.ssh/id_ed25519_vm.pub)"
   ```
3. **SSH** into your VM with its public IP as shown in the deployment output.

---

## Cleanup (Optional)

To avoid charges:

```bash
az group delete --name rg-free-vm --yes --no-wait
```

---
