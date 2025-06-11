# Microsoft Teams Secure Implementation Build Book

## Introduction

This build book outlines a secure implementation strategy for Microsoft Teams, tailored for organizations with stringent security and compliance needs. The goal is to enhance external collaboration controls, prevent data leakage, ensure encrypted communications, and manage cryptographic keys. The guide includes four key features:

1. **External User MFA Enforcement**
2. **Restriction on External Meeting Participants** (no recording or transcript access)
3. **Private Endpoint Configuration for Teams Traffic**
4. **Customer Managed Keys (CMK) for Microsoft Teams**

Each section includes an overview, security benefits, step-by-step implementation instructions, references to Microsoft documentation, and realistic test cases to verify functionality.

---

## 1. External User MFA Enforcement

### Overview

Mandate that all external participants join Teams using the email address they were invited with, and enforce Multi-Factor Authentication (MFA).

### Security Benefits

* Prevents session hijacking or unauthorized access
* Ensures identity verification of external users

### Configuration Steps

1. **Set up Azure AD B2B external collaboration settings** :

* Go to [Azure AD Portal](https://portal.azure.com) > **Azure Active Directory** > **External Identities** > **External collaboration settings**
* Set "Guest users permissions are limited" to **Yes**
* Under "Collaboration restrictions", choose **Allow invitations only to the specified domains** and add trusted domains

1. **Enforce MFA for guests** :

* Go to **Azure AD** > **Security** > **Conditional Access**
* Create a new policy:
  * Assignments:
    * **Users** : Include "Guest or external users"
    * **Cloud apps** : Select "Microsoft Teams"
  * Access controls:
    * **Grant** : Require multi-factor authentication

1. **Ensure Teams guests are required to sign in with the invited email** :

* Send Teams invitations from Outlook or Teams calendar only to their intended email
* Instruct users not to forward the invite

### Microsoft Docs

* [External Collaboration Settings](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/external-collaboration-overview)
* [Conditional Access for Guests](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-guest)

### Testing Steps

* Invite an external Gmail/Outlook user
* Confirm that login prompts them to use the correct email
* Verify MFA is prompted before entry
* Attempt logging in with a different browser or forwarded invite to test denial

---

## 2. Restrict External Meeting Participants from Recording or Downloading Transcripts

### Overview

Prevent users outside the organization from recording meetings or accessing meeting content like transcripts or chat downloads.

### Security Benefits

* Protects sensitive information shared in meetings
* Ensures regulatory compliance by limiting data exfiltration by external parties

### Configuration Steps

1. **Set up Teams Meeting Policies** :

* Go to [Teams Admin Center](https://admin.teams.microsoft.com)
* Navigate to **Meetings** > **Meeting policies**
* Create a custom policy (e.g., "ExternalRestricted"):
  * **Allow cloud recording** : **Off**
  * **Allow transcription** : **Off**
  * **Allow meeting chat** : **On/In-meeting only** (optional)

1. **Assign the policy to guest users** :

* Go to **Users** > filter by "Guest"
* Apply the "ExternalRestricted" policy to guest users manually or via PowerShell

1. **Review Org-wide Settings** :

* Go to **Meetings > Meeting settings**
* Disable "Anonymous users can start a meeting" and other risky permissions

### Microsoft Docs

* [Teams Meeting Policies](https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-in-teams)
* [Apply Meeting Policy to Users](https://learn.microsoft.com/en-us/powershell/module/skype/grant-csteamsmeetingpolicy)

### Testing Steps

* Schedule a Teams meeting and add a guest user
* Confirm the guest cannot see the "Start Recording" button
* Ensure no transcript is generated for guest participants

---

## 3. Configure Private Endpoint for Teams

### Overview

While Microsoft Teams itself doesn’t support Private Link endpoints, traffic to Microsoft 365 endpoints can be routed securely using Azure Private Network configuration and service tags for Teams endpoints.

### Security Benefits

* Enhances network-level security
* Prevents Teams traffic from traversing public internet where unnecessary

### Configuration Steps

1. **Use Microsoft 365 Service Tags** :

* Configure NSGs (Network Security Groups) to allow outbound access to `MicrosoftTeams` service tag

1. **Use Azure Firewall / Secure Web Gateway** :

* Define rules to allow access only to required Microsoft 365 endpoints
* Reference: [Office 365 URL/IP Ranges](https://learn.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges)

1. **Configure Hybrid Network Routing** :

* Use Azure Virtual WAN with secured routing
* Ensure private DNS zones resolve Teams endpoints correctly (via trusted proxy if needed)

> **Note:** Teams does not natively support Private Endpoint, but Teams-related traffic can be secured by forcing outbound traffic via private secure perimeter

### Microsoft Docs

* [Microsoft 365 Connectivity Principles](https://learn.microsoft.com/en-us/microsoft-365/enterprise/microsoft-365-network-connectivity-principles)
* [Teams Network Requirements](https://learn.microsoft.com/en-us/microsoftteams/hardware-requirements-for-the-teams-app)

### Testing Steps

* Verify Teams connects and functions from secure endpoints only
* Attempt using Teams in a non-whitelisted location and confirm access fails

---

## 4. Configure Customer Managed Keys (CMK) for Microsoft Teams

### Overview

Use CMK to encrypt Teams chat and files using your own Azure Key Vault-managed keys.

### Security Benefits

* Retain full control of encryption keys
* Revoke access instantly by rotating or disabling keys
* Essential for compliance in high-security environments (e.g., ITSG-33, CJIS)

### Configuration Steps

1. **Prerequisites** :

* Azure subscription with Azure Key Vault
* Microsoft Purview Advanced Message Encryption
* Microsoft 365 E5 license

1. **Create an Azure Key Vault and Key** :

* Go to [Azure Portal](https://portal.azure.com)
* Create a Key Vault and generate a new RSA 2048 or 3072 key
* Enable purge protection and soft-delete

1. **Assign Roles and Permissions** :

* Grant Microsoft 365 apps access to the key (via Key Vault access policies or RBAC)
* Use Azure AD app: `Microsoft 365 Data Encryption Service`

1. **Enable CMK for Teams** :

* Use PowerShell to configure CMK via Microsoft Purview:

```powershell
   Connect-IPPSSession
   Set-InformationProtectionKey -KeyId "<your-key-id>" -KeyVaultUrl "<your-keyvault-url>"
   Set-TeamsCustomerKeyConfiguration -KeyId "<your-key-id>" -Enabled $true
```

### Microsoft Docs

* [Customer Key for Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/compliance/customer-key-overview)
* [Customer Key for Teams Chat](https://learn.microsoft.com/en-us/microsoft-365/compliance/customer-key-teams)

### Testing Steps

* Verify key usage in Azure Key Vault monitoring logs
* Revoke the key and verify Teams chat content becomes inaccessible (test with dummy content)
* Confirm encrypted data at rest in compliance reports (Microsoft Purview)

---

## Final Notes

* **Change Management** : Ensure policies are documented and shared with your governance team.
* **User Communication** : Inform external participants of new MFA and access expectations.
* **Audit and Compliance** : Use Microsoft Purview, Defender for Cloud Apps, and Azure Monitor to track security-related events.

For additional support, refer to:

* [Microsoft Teams Security Documentation](https://learn.microsoft.com/en-us/microsoftteams/security-compliance-overview)
* [Microsoft 365 Compliance Center](https://compliance.microsoft.com)

---

*This build book was designed to be operationally prescriptive to allow a security-conscious tenant to immediately implement and validate critical features that secure Microsoft Teams for enterprise use.*
