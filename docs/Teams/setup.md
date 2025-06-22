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

1. **Set up Azure AD B2B external collaboration settings**:

   * Go to [Azure AD Portal](https://portal.azure.com) > **Azure Active Directory** > **External Identities** > **External collaboration settings**
   * Set "Guest users permissions are limited" to **Yes**
   * Under "Collaboration restrictions", choose **Allow invitations only to the specified domains** and add trusted domains

2. **Enforce MFA for guests**:

   * Go to **Azure AD** > **Security** > **Conditional Access**
   * Create a new policy:

     * Assignments:

       * **Users**: Include "Guest or external users"
       * **Cloud apps**: Select "Microsoft Teams"
     * Access controls:

       * **Grant**: Require multi-factor authentication

3. **Ensure Teams guests are required to sign in with the invited email**:

   * **Send Teams invitations** from Outlook or Teams calendar only to their intended email
   * **Instruct users not to forward the invite** to others

   #### To Enforce That Forwarded Links Cannot Be Used by Another User:

   a. **Configure Azure AD B2B Cross-Tenant Access Settings**:

   * Go to **Azure AD** > **External Identities** > **Cross-tenant access settings** (Preview)
   * Under **Default settings**, click **Edit outbound access settings**
   * Under **Trust settings**, disable:

     * "Trust multi-factor authentication from external Azure AD organizations"
     * "Trust compliant device claims from external Azure AD organizations"
   * Save the settings

   b. **Use Conditional Access to Require MFA Per Session and Match Invited Identity**:

   * Create a Conditional Access policy:

     * **Users**: Include "Guest or external users"
     * **Cloud apps**: Select "Microsoft Teams"
     * **Conditions**: Add a filter for user attributes (`user.mail` or `user.userPrincipalName`) to match the invited identity
     * **Grant controls**: Require MFA
     * **Session controls**: Enable sign-in frequency (e.g., every 1 hour)

   c. **Enable Continuous Access Evaluation (CAE)**:

   * Go to **Azure AD** > **Security** > **Conditional Access** > **Named locations** and define your corporate IPs
   * In **Azure AD > Security > Conditional Access**, create a policy that uses CAE by enabling token lifetimes and session evaluation

### Microsoft Docs

* [External Collaboration Settings](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/external-collaboration-overview)
* [Conditional Access for Guests](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-guest)
* [Cross-tenant Access Settings](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/cross-tenant-access-overview)
* [Continuous Access Evaluation](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-continuous-access-evaluation)

### Testing Steps

* Invite an external Gmail/Outlook user
* Confirm that login prompts them to use the correct email
* Verify MFA is prompted before entry
* Attempt logging in with a forwarded invite using a different email — access should be denied or re-prompted for MFA against original identity
* Simulate session interruption and observe CAE-triggered re-authentication

---

## 2. Restrict External Meeting Participants from Recording or Downloading Transcripts

### Overview

Prevent users outside the organization from recording meetings or accessing meeting content like transcripts or chat downloads.

### Security Benefits

* Protects sensitive information shared in meetings
* Ensures regulatory compliance by limiting data exfiltration by external parties

### Configuration Steps

1. **Set up Teams Meeting Policies**:

   * Go to [Teams Admin Center](https://admin.teams.microsoft.com)
   * Navigate to **Meetings** > **Meeting policies**
   * Create a custom policy (e.g., "ExternalRestricted"):

     * **Allow cloud recording**: **Off**
     * **Allow transcription**: **Off**
     * **Allow meeting chat**: **On/In-meeting only** (optional)

2. **Assign the policy to guest users**:

   * Go to **Users** > filter by "Guest"
   * Apply the "ExternalRestricted" policy to guest users manually or via PowerShell

3. **Review Org-wide Settings**:

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

1. **Use Microsoft 365 Service Tags**:

   * Go to **Azure Portal** > **Networking** > **Network Security Groups (NSGs)**
   * Select or create an NSG associated with your Azure subnet
   * Under **Outbound security rules**, add a rule:

     * Destination: `Service Tag`
     * Destination service tag: `MicrosoftTeams`
     * Protocol: `Any`
     * Port: `*`
     * Action: `Allow`
     * Priority: `100`
     * Name: `Allow_Teams_Egress`

2. **Use Azure Firewall / Secure Web Gateway**:

   * Deploy **Azure Firewall** or a trusted Secure Web Gateway (e.g., Zscaler, Palo Alto Prisma)
   * Create rules to allow only outbound Microsoft Teams traffic:

     * Reference the [Microsoft 365 URL/IP range feed](https://learn.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges)
     * Allow domains like:

       * `*.teams.microsoft.com`
       * `*.skype.com`
       * `*.lync.com`
     * Allow UDP ports 3478–3481 for media
     * Deny other general outbound internet access as needed

3. **Configure Hybrid Network Routing**:

   * Use **Azure Virtual WAN** or hub-spoke topology to direct outbound flows through inspection
   * For DNS resolution:

     * Use **Private DNS Zones** if integrating with internal resolvers
     * Otherwise configure **Conditional Forwarders** to direct Microsoft 365 queries to external trusted resolvers

4. **Optional – Force Tunnel Internet Egress**:

   * Configure your VPN or ExpressRoute connections to route all internet-bound traffic through a centralized firewall
   * Ensure the firewall permits only Microsoft Teams endpoints

> **Note:** Microsoft Teams endpoints cannot currently be accessed via Azure Private Link. This strategy uses perimeter control via NSGs, Azure Firewall, and secure DNS to restrict and secure traffic rather than provide true private endpoint access.

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

1. **Prerequisites**:

   * Azure subscription with Azure Key Vault
   * Microsoft Purview Advanced Message Encryption
   * Microsoft 365 E5 license

2. **Create an Azure Key Vault and Key**:

   * Go to [Azure Portal](https://portal.azure.com)
   * Create a Key Vault and generate a new RSA 2048 or 3072 key
   * Enable purge protection and soft-delete

3. **Assign Roles and Permissions**:

   * Grant Microsoft 365 apps access to the key (via Key Vault access policies or RBAC)
   * Use Azure AD app: `Microsoft 365 Data Encryption Service`

4. **Enable CMK for Teams**:

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

* **Change Management**: Ensure policies are documented and shared with your governance team.
* **User Communication**: Inform external participants of new MFA and access expectations.
* **Audit and Compliance**: Use Microsoft Purview, Defender for Cloud Apps, and Azure Monitor to track security-related events.

For additional support, refer to:

* [Microsoft Teams Security Documentation](https://learn.microsoft.com/en-us/microsoftteams/security-compliance-overview)
* [Microsoft 365 Compliance Center](https://compliance.microsoft.com)

