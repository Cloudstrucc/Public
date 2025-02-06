# ✅ Power BI Cloud Security Guardrails & Governance Framework

## 📌 Introduction

This document outlines the necessary **security guardrails, governance policies, and automation scripts** to enforce best practices in **Power BI Cloud** for organizations with **E5-licensed users**.

---

## ✅ **Licensing Considerations**

- **Power BI Pro is included** in Microsoft 365 E5, allowing for report sharing and collaboration.
- **Power BI Premium Capacity** (optional) is needed for:
  - Large datasets exceeding **1GB per dataset**.
  - Advanced AI capabilities.
  - Deployment pipelines with **managed storage**.

---

## 🚀 **Step-by-Step Implementation Process**

### **🔐 1. Data Protection & Compliance**

1. **Enable Microsoft Purview Sensitivity Labels:**

   - Navigate to **Microsoft Purview Compliance Portal** → **Information Protection** → **Labels**.
   - Create labels such as **Confidential, Internal Only**.
   - Publish labels and enable **Power BI integration**.
2. **Enable Customer Managed Keys (CMK) for Encryption (if needed):**

   - Power BI encrypts **data at rest and in transit** by default.
   - If higher compliance is needed, enable **CMK with Azure Key Vault**.

---

### **📤 2. External Sharing Controls**

1. **Restrict External Sharing:**

   - **Power BI Admin Portal** → **Tenant Settings** → **Export and Sharing Settings**.
   - Disable **“Share content with external users”** unless business justification exists.
2. **Disable “Publish to Web” (if not needed):**

   - Navigate to **Tenant Settings** → **Disable Publish to Web**.
   - This prevents **public URL exposure** of reports.

---

### **🔎 3. Data Security Policies**

1. **Implement Row-Level Security (RLS):**

   - In **Power BI Desktop**, navigate to **Modeling** → **Manage Roles**.
   - Define **DAX filters** to restrict access based on user roles.
2. **Implement Object-Level Security (OLS) (if needed):**

   - In **Power BI Desktop**, define **table-level visibility restrictions**.

---

### **📊 4. Monitoring & Auditing Setup**

1. **Enable Audit Logs (Microsoft Purview):**

   - Navigate to **Microsoft 365 Compliance Center** → **Audit**.
   - Track **data exports, report access, and sharing activity**.
2. **Monitor Usage Metrics:**

   - In **Power BI Admin Portal**, review **Usage Metrics** for:
     - **Dataset refresh failures**
     - **User access patterns**
     - **Workspace activities**

---

### **🔄 5. Dataflow & Dataset Governance**

1. **Promote Certified Datasets:**

   - **Power BI Service** → **Datasets** → Mark **Trusted** datasets as **Certified**.
2. **Standardize Dataflows:**

   - Implement **scheduled refreshes** to ensure **data consistency**.

---

### **🚀 6. Deployment Pipelines**

1. **Create Deployment Pipelines in Power BI Service:**

   - Navigate to **Deployment Pipelines**.
   - Define stages: **Development → Test → Production**.
2. **Automate Deployments using DevOps (Optional):**

   - Use **Azure DevOps Pipelines** for Power BI deployments.

---

## 🔐 **Security Guardrails Overview**

| Feature                     | Recommended Setting            |
| --------------------------- | ------------------------------ |
| Sensitivity Labels          | ✅ Enabled (Microsoft Purview) |
| External Sharing            | ❌ Disabled (unless required)  |
| Publish to Web              | ❌ Disabled (by default)       |
| Row-Level Security (RLS)    | ✅ Implemented                 |
| Object-Level Security (OLS) | ✅ Enabled (if needed)         |
| Audit Logs                  | ✅ Enabled (Microsoft Purview) |
| Dataset Certifications      | ✅ Enforced                    |

---

## ⚠️ **Access Control Note**

Access control is **inherited from Entra ID**:

- **Use Conditional Access Policies** for MFA enforcement.
- **Power BI respects Entra ID authentication and role assignments**.

---

# ⚙️ **Build - Scripts (DevSecOps Automation)**

## 📌 **1️⃣ PowerShell Script for Security Configuration**

```powershell
# Authenticate to Azure
Connect-AzAccount

# Set Power BI Tenant Security Settings
$settings = @{
    "disableExportData" = $true
    "disablePublishToWeb" = $true
    "enableAuditLogs" = $true
}

foreach ($setting in $settings.GetEnumerator()) {
    Write-Output "Applying $($setting.Key)..."
    Set-PowerBIServiceTenantSetting -Name $setting.Key -Value $setting.Value
}
```

---

## 📌 **2️⃣ Bicep Template for Power BI Governance**

```bicep
param tenantId string
param environmentUrl string
param auditEnabled bool = true
param externalSharing bool = false

resource powerBI 'Microsoft.PowerPlatform/powerbi@2022-03-01' = {
  name: 'powerbi-settings'
  location: 'global'
  properties: {
    tenantId: tenantId
    environmentUrl: environmentUrl
    security: {
      externalSharing: externalSharing
      auditLogging: auditEnabled
    }
  }
}
```

---

## 📌 **3️⃣ Azure DevOps Pipeline YAML for Deployment**

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: AzureCLI@2
  inputs:
    azureSubscription: 'Your-Service-Connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az login --service-principal -u $(clientId) -p $(clientSecret) --tenant $(tenantId)
      az deployment sub create \
        --location eastus \
        --template-file ./powerbi-governance.bicep \
        --parameters tenantId=$(tenantId) environmentUrl=$(environmentUrl)
```

---

## 🔍 **Governance Checklist**

- [ ] Sensitivity Labels Configured
- [ ] External Sharing Disabled (unless required)
- [ ] Audit Logs Enabled
- [ ] Certified Datasets Defined
- [ ] Deployment Pipelines Set Up
- [ ] Governance Committee Established

---

# 🎯 **Conclusion**

This guide provides a **secure and governed approach** to Power BI Cloud for E5-licensed users, incorporating **security policies, governance strategies, and DevSecOps automation**.
