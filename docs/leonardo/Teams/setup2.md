# 🛡️ Microsoft Teams Security Hardening Guide for Sensitive Organizations

---

## 🌟 Objectives

Ensure that:

* ✅ Only **authenticated, invited users** (with MFA) can access meetings.
* ❌ Forwarded invites do not allow unintended access.
* 🔐 All content is **protected with strong encryption**, including optional **Customer-Managed Keys (CMK)**.
* 🌐 Teams traffic is controlled via **Private Endpoints**.
* 🛡️ All Microsoft Teams security features are appropriately configured.

---

## 1. 🔑 Enforce MFA for Guests and External Users

### ✅ Setup with Conditional Access (Entra ID)

Enforce MFA for all guests and external users using Conditional Access:

1. Go to **Microsoft Entra admin center** → **Protection** → **Conditional Access** → `+ New policy`
2. **Assignments**:

   * **Users**: Select *All guest and external users*
   * **Cloud apps or actions**: Select *Microsoft Teams* and *Exchange Online*
3. **Access Controls**:

   * Grant access: ✅ *Require multi-factor authentication*
4. Enable policy: ✅ On

📘 [Docs](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-all-users-mfa)

---

## 2. ❌ Block Forwarded Meeting Invites

### Option A: Per-Meeting Settings

1. In Teams or Outlook, open the **Meeting Options**.
2. Set:

   * `Who can bypass the lobby`: **Only people I invite**
   * `Always let callers bypass the lobby`: **No**

> *Note: Forwarding of the invite email can’t be blocked directly, but the above setting ensures only invited users can bypass the lobby.*

### Option B: Org-Wide PowerShell Settings

```powershell
Connect-MicrosoftTeams

Set-CsTeamsMeetingPolicy -Identity Global `
  -AllowAnonymousUsersToJoinMeeting $false `
  -AutoAdmittedUsers "EveryoneInCompany"
```

📘 [Meeting policies](https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-in-teams)

---

## 3. 🧱 Restrict Join Access to Invited Emails

### ✅ Entra External Collaboration Settings

1. Go to **Microsoft Entra admin center** → **External Identities** → **External collaboration settings**
2. Set:

   * ✅ *Guest users must sign in with the same account they were invited with*
   * ✅ *Enforce MFA for guests*
   * ❌ *Guests can invite others*

📘 [External collaboration docs](https://learn.microsoft.com/en-us/entra/external-id/)

---

## 4. 🔑 Microsoft Teams + Customer Key (CMK)

### 🔐 What is Customer Key?

Customer Key lets you use **your own encryption keys** (stored in Azure Key Vault) to protect Teams data-at-rest:

* Teams messages and call records
* Files in SharePoint and OneDrive (used by Teams)

### 🧹 Requirements

* Microsoft 365 E5 + Microsoft Purview Advanced Compliance add-on
* Azure Key Vault with:

  * Soft delete and purge protection
  * Your own RSA 2048+ keys

### 🛠️ Setup

1. Create a Key Vault and import or generate your key.
2. Assign Microsoft 365 access to your vault (via Azure roles).
3. Go to **Microsoft Purview** → **Customer Key**
4. Configure keys for:

   * Exchange Online
   * SharePoint Online (includes Teams file storage)
   * Teams chat encryption

📘 [Customer Key overview](https://learn.microsoft.com/en-us/microsoft-365/compliance/customer-key-overview)

---

## 5. 🌐 Microsoft Teams + Private Endpoints

### 🔐 What are Private Endpoints?

Private Endpoints allow Microsoft 365 traffic (e.g., Teams, SharePoint, Graph API) to stay **within your Azure VNet** — never over the public internet.

### 🛠️ Setup Overview

1. Create **Private DNS Zones** for:

   * `privatelink.sharepoint.com`
   * `privatelink.microsoft.com`
   * `privatelink.teams.microsoft.com` *(if required)*

2. Set up **Private Endpoints** in your Azure VNet for:

   * SharePoint (used by Teams)
   * Microsoft Graph APIs
   * Office 365 services

3. **Link** DNS zones to your VNet.

4. Enforce traffic routing via **Azure Firewall or Proxy**.

📘 [Office 365 Private Endpoint](https://learn.microsoft.com/en-us/microsoft-365/enterprise/microsoft-365-private-endpoints)

---

## 6. 🔐 Microsoft Teams Security Features: Setup Guide

This section details how to configure Teams’ advanced security features.

---

### 6.1 🧱 Information Barriers

**Block communication or file sharing between defined groups.**

#### Setup:

1. Go to [https://compliance.microsoft.com](https://compliance.microsoft.com)
2. Enable IB v2 via PowerShell:

   ```powershell
   Set-InformationBarrierPolicyApplicationStatus -Identity "<tenantId>" -State Enabled
   ```
3. Create **segments** (e.g., HR, Finance).
4. Create and assign **policies** between segments.
5. Map users to segments via Azure AD groups or user attributes.

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/compliance/information-barriers)

---

### 6.2 🛡️ Data Loss Prevention (DLP)

**Prevent users from sending sensitive information.**

#### Setup:

1. Go to Microsoft Purview > **Data loss prevention**
2. Create a DLP policy:

   * Location: Microsoft Teams
   * Rules: Built-in or custom patterns (e.g., credit cards, SIN)
   * Actions: Warn/block/notify
3. Test in simulation mode
4. Publish and enforce

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/compliance/dlp-microsoft-teams)

---

### 6.3 🎼 Sensitivity Labels

**Encrypt chats and files, control access and privacy.**

#### Setup:

1. Microsoft Purview > Information protection > **Labels**
2. Create a label with:

   * **Encryption** (rights, expiry)
   * **Team settings**: Private/Public, allow guests
3. Publish using Label Policies to Teams and M365 Groups

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels-teams-groups-sites)

---

### 6.4 📎 Safe Attachments

**Scan uploaded files for malware.**

#### Setup:

1. Microsoft Defender Portal > Policies > Safe Attachments
2. Create a policy for Teams and SharePoint
3. Configure: Block, monitor, or replace

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/atp-safe-attachments)

---

### 6.5 🔗 Safe Links

**Protect users from malicious URLs in Teams messages.**

#### Setup:

1. Microsoft Defender Portal > Policies > Safe Links
2. Create a policy scoped to Teams
3. Enable URL rewriting and click tracking
4. Block known malicious domains

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/atp-safe-links)

---

### 6.6 🗂️ Retention Policies

**Define how long chats and files are stored.**

#### Setup:

1. Microsoft Purview > Data lifecycle management > Retention Policies
2. Create new policy
3. Choose Teams chat/channel messages
4. Set retention duration (retain or delete)
5. Assign to users/groups

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/compliance/retention-policies)

---

### 6.7 📜 Audit Logging

**Track activity in Teams for security review.**

#### Setup:

1. Go to [https://compliance.microsoft.com/auditlogsearch](https://compliance.microsoft.com/auditlogsearch)
2. Enable audit logging if needed
3. Filter by user, action, date, or Teams-specific events

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/compliance/search-the-audit-log)

---

### 6.8 🔍 eDiscovery

**Find Teams data for legal investigations.**

#### Setup:

1. Microsoft Purview > eDiscovery > New case
2. Add custodians (users, teams)
3. Create search query (e.g., chats with keywords)
4. Apply legal hold
5. Export results for review

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/compliance/ediscovery-teams)

---

### 6.9 👥 Access Reviews

**Review and clean up guest user access regularly.**

#### Setup:

1. Microsoft Entra > Identity Governance > Access Reviews
2. Create review:

   * Scope: Guest users
   * Reviewers: Group owners/admins
   * Frequency: Monthly/quarterly
   * Actions: Auto-remove stale users

📘 [Docs](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview)

---

### 6.10 🧠 Microsoft Defender XDR

**Detect threats and abnormal behavior in Teams.**

#### Setup:

1. Enable Defender for Office 365
2. Go to [https://security.microsoft.com](https://security.microsoft.com)
3. Use:

   * Incidents dashboard
   * Safe Links & Attachments reports
   * **Advanced Hunting** queries:

     ```kql
     DeviceEvents
     | where ActionType contains "Teams"
     ```

📘 [Docs](https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-365-defender)

---

## ✅ Summary Checklist

| Security Goal                       | Solution                              |
| ----------------------------------- | ------------------------------------- |
| Require MFA for guests              | Conditional Access policy             |
| Block invite forwarding             | Lobby + Meeting policy restrictions   |
| Restrict join to invited users      | Entra External Collaboration settings |
| Use customer-owned encryption keys  | Microsoft 365 Customer Key (CMK)      |
| Ensure private access to Teams data | Azure Private Endpoints + DNS         |
| Prevent data leaks in chat/files    | DLP + Sensitivity Labels              |
| Block malware & malicious links     | Safe Attachments + Safe Links         |
| Define content retention            | Microsoft Purview Retention Policies  |
| Investigate incidents & activity    | Audit logs, eDiscovery, Defender XDR  |
| Periodically review guest access    | Entra Access Reviews                  |

---
