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

## Option A: Azure CLI

1. **Login & set subscription**

   ```bash
   az login
   az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
   ```
2. **Create (or verify) a Resource Group**

   ```bash
   az group create \
     --name rg-free-vm \
     --location canadacentral
   ```
3. **Generate SSH key** (if not already done in Prereqs)

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_vm -C "azure-vm"
   ```
4. **Deploy the VM**

   ```bash
   az vm create \
     --resource-group rg-free-vm \
     --name vm-free-linux \
     --image UbuntuLTS \
     --size Standard_B1s \
     --admin-username azureuser \
     --ssh-key-values ~/.ssh/id_ed25519_vm.pub \
     --public-ip-sku Standard \
     --tags Environment=Test Cost=Low
   ```
5. **Open SSH port (22)**

   ```bash
   az vm open-port --port 22 --resource-group rg-free-vm --name vm-free-linux
   ```
6. **Retrieve the public IP**

   ```bash
   az vm show \
     --resource-group rg-free-vm \
     --name vm-free-linux \
     --show-details \
     --query publicIps -o tsv
   ```
7. **SSH into your VM**

   ```bash
   ssh -i ~/.ssh/id_ed25519_vm azureuser@<PUBLIC_IP>
   ```

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

**Now you have three ways**—CLI, Portal UX, or ARM template—to deploy a low-cost/free Linux VM in Azure. Choose whichever best fits your workflow!

---

## Testing the App Service URL: VM vs Public Internet

Once your VM is up and running and your App Service is configured with a Private Endpoint (and its DNS override in place), you can compare responses from inside (private) versus outside (public):

### 1. From the VM (Private Endpoint)

1. **SSH** into the VM:

   ```bash
   ssh -i ~/.ssh/id_ed25519_vm azureuser@<PUBLIC_IP_OF_VM>
   ```
2. **Test HTTP/S**:

   ```bash
   curl -i https://yourapp.azurewebsites.net/api/health
   ```
3. **Expected Result**:

   * **200 OK** (or your app’s healthy response)
   * **Source IP** in App Service logs shows the **private endpoint IP** (10.x.x.x).
   * **Traffic path** stays entirely within your VNet.

### 2. From the Internet (Public Endpoint)

1. From your local machine (no VPN or DNS override):

   ```bash
   curl -i https://yourapp.azurewebsites.net/api/health
   ```
2. **Expected Result**:

   * **200 OK** (same application payload)
   * **Source IP** in App Service logs shows the **public gateway IP** of Azure Front Door or App Service.
   * **Traffic path** traverses the public Internet.

### 3. Key Differences

| Aspect                | Inside VM (Private)                        | Public Internet                                |
| --------------------- | ------------------------------------------ | ---------------------------------------------- |
| DNS Resolution        | Private IP (via Private DNS or hosts file) | Public IP                                      |
| Network Path          | Azure backbone → VNet → Private Endpoint   | Internet → Azure Front Door → App Service      |
| Source IP Seen by App | Private Endpoint IP (10.x.x.x)             | Public Azure Gateway IP                        |
| Security Posture      | Fully private; no exposure to Internet     | Exposed (unless explicitly locked down)        |
| Latency               | Typically lower and more consistent        | Higher variability depending on client network |

---

**Conclusion:**

* Testing from the VM validates your private network path and DNS configuration.
* Testing from the public Internet confirms your public endpoint remains reachable for external clients.
* Reviewing the App Service access logs or Application Insights will clearly show the differing source IPs and help you verify correct network segmentation.

---

## Testing Dataverse (CRM) Endpoints: Private vs Public

With your Dataverse environment injected into the VNet and restricted to that network via NSG/Firewall, you can demonstrate that API calls to your CRM endpoints only succeed from within your infrastructure.

### A. From the VM (Inside VNet)

1. **SSH** into the VM as before.
2. **Install Power Platform CLI or PowerShell modules** if not present:

   ```bash
   # PowerShell (in Cloud Shell or via pwsh on Linux)
   Install-Module -Name Microsoft.PowerPlatform.Cds.Client -Scope CurrentUser -Force
   ```
3. **Run a simple Dataverse Web API call**:

   ```powershell
   # Replace with your Dataverse URL and credentials
   $url    = 'https://<org>.crm3.dynamics.com/api/data/v9.2/WhoAmI'
   $token  = (Get-AzAccessToken -ResourceUrl "https://<org>.crm3.dynamics.com").Token
   Invoke-RestMethod -Uri $url -Headers @{ Authorization = "Bearer $token" }
   ```
4. **Expected Result**:

   * A JSON response with your user ID (WhoAmI) or other metadata.
   * Call completes successfully over the private path.

### B. From the Public Internet (Without VPN/DNS Override)

1. On your laptop or any external system, try the same Web API call:

   ```bash
   curl -i -H "Authorization: Bearer <public-token>" https://<org>.crm3.dynamics.com/api/data/v9.2/WhoAmI
   ```
2. **Expected Result**:

   * **Connection timed out** or **403 Forbidden** if you’ve locked down public access via Conditional Access / IP restrictions.
   * No JSON payload—demonstrates that the endpoint is unreachable from the Internet.

### C. Log Verification

* **Dataverse audit logs** or **Azure Monitor**: Confirm only calls from your VNet’s IP range are allowed.
* **NSG Flow Logs**: Show accepted flows on port 443 only from your subnet.
* **Application Insights** (for custom plug-ins): verify incoming requests’ client IPs.

---

* **Internal-only** access to your Dataverse environment APIs. (200s)
* **Public** requests are blocked, enforcing your private networking policy. (401/403s)
