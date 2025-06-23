# Microsoft Teams Secure Implementation Build Book

## Introduction

This build book outlines a secure implementation strategy for Microsoft Teams, tailored for organizations with stringent security and compliance needs. The goal is to enhance external collaboration controls, prevent data leakage, ensure encrypted communications, and manage cryptographic keys. The guide includes four key features:

1. **External User MFA Enforcement**
2. **Restriction on External Meeting Participants** (no recording or transcript access)
3. **Private Endpoint Configuration for Teams Traffic**
4. **Customer Managed Keys (CMK) for Microsoft Teams**

Each section includes an overview, security benefits, step-by-step implementation instructions, references to Microsoft documentation, and realistic test cases to verify functionality.

---

## 1. Secure Teams Meetings and External User Access

### Overview

Secure Teams meetings by preventing unauthorized access through forwarded invites and enforce authentication requirements for external participants.

### Security Benefits

* Prevents unauthorized access via forwarded meeting invites
* Controls anonymous meeting participation
* Ensures identity verification of external participants when required
* Provides granular control over meeting access

### Configuration Steps

> **Critical Understanding**: Teams meetings have two types of external participants:
> 1. **Guest Users** - Formally invited to your tenant (subject to Conditional Access)
> 2. **Anonymous Users** - Join via meeting links without tenant access (controlled by Teams policies)
> 
> Forwarded meeting invites typically result in anonymous users, NOT guest users.

1. **Disable Anonymous Meeting Join (Recommended for High Security)**:

   * Go to [Teams Admin Center](https://admin.teams.microsoft.com)
   * Navigate to **Meetings** > **Meeting settings**
   * Under **Participants**, set **Anonymous users can join a meeting** to **Off**
   * This prevents anyone from joining via forwarded links without proper authentication

2. **Alternative: Use Lobby Controls** (If anonymous access needed):

   * Go to **Meetings** > **Meeting policies**
   * Create or edit a policy with these settings:
     * **Anonymous users can join a meeting unverified**: **Off**
     * **Who can bypass the lobby**: **People who were invited**
   * This forces forwarded invite users to wait in lobby for approval

3. **Prevent Meeting Invite Forwarding** (Meeting Organizer Setting):

   * When creating meetings in Outlook, click **Response Options**
   * Uncheck **Allow forwarding**
   * This prevents the meeting invitation itself from being forwarded

4. **For Guest Users Only: Configure Conditional Access**:

   > **Note**: This only applies to users formally invited as guests to your tenant, not anonymous meeting participants.

   * Go to [Microsoft Entra admin center](https://entra.microsoft.com) > **Protection** > **Conditional Access** > **Policies**
   * Create a new policy:
     * **Users or workload identities**: Include "Guest or external users"
     * **Target resources**: Select "Microsoft Teams"
     * **Grant controls**: "Require multifactor authentication"

### Microsoft Docs

* Manage Anonymous Participant Access to Teams Meetings
* Control Who Can Bypass the Meeting Lobby in Microsoft Teams
* Configure the Microsoft Teams Meeting Lobby for Sensitive Meetings
* Prevent Forwarding of a Meeting - Microsoft Support
* Conditional Access for Guest Users (for formal tenant guests only)

### Testing Steps

**Test 1: Anonymous Join Disabled (Recommended)**
* Schedule a Teams meeting with **Anonymous users can join a meeting** set to **Off**
* Forward the meeting invite to a different email address
* **Expected Result**: The forwarded recipient should be blocked from joining and receive an error message

**Test 2: Lobby Controls (If anonymous access needed)**
* Schedule a Teams meeting with lobby controls enabled
* Forward the meeting invite to a different email address
* **Expected Result**: The forwarded recipient should be placed in the lobby and require organizer approval

**Test 3: Meeting Forwarding Prevention**
* Create a meeting with **Allow forwarding** disabled in Response Options
* Attempt to forward the meeting invitation
* **Expected Result**: The invitation cannot be forwarded (depending on email client)

**Test 4: Guest User Authentication (For formal guests only)**
* Invite an external user as a formal guest to your tenant
* **Expected Result**: They should be prompted for MFA when accessing Teams (if Conditional Access is configured)

**Important**: The forwarded invite test in your scenario (where someone could join without MFA) indicates that anonymous meeting join is enabled and needs to be addressed using the Teams Admin Center settings above, not Conditional Access policies.

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

   * Go to **Users** > **Manage users** > filter by "Guest"
   * Apply the "ExternalRestricted" policy to guest users manually or via PowerShell
   * For PowerShell: `Grant-CsTeamsMeetingPolicy -Identity "guestuser@domain.com" -PolicyName "ExternalRestricted"`

3. **Review Org-wide Settings**:

   * Go to **Meetings** > **Meeting settings**
   * Disable "Anonymous users can start a meeting" and other risky permissions

### Microsoft Docs

* Teams Meeting Policies Overview
* [Grant Teams Meeting Policy PowerShell](https://learn.microsoft.com/en-us/powershell/module/teams/grant-csteamsmeetingpolicy)

### Testing Steps

* Schedule a Teams meeting and add a guest user
* Confirm the guest cannot see the "Start Recording" button
* Ensure no transcript is generated for guest participants or they cannot download transcripts

---

## 3. Configure Private Endpoint for Teams

### Overview

While Microsoft Teams itself doesn't support Private Link endpoints, traffic to Microsoft 365 endpoints can be routed securely using Azure Private Network configuration and service tags for Teams endpoints.

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

   * Deploy **Azure Firewall** or a trusted Secure Web Gateway
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
* [Teams Network Requirements](https://learn.microsoft.com/en-us/microsoftteams/prepare-network)

### Testing Steps

* Verify Teams connects and functions from secure endpoints only
* Attempt using Teams in a non-whitelisted location and confirm access fails

---

## 4. Configure Customer Managed Keys (CMK) for Microsoft Teams

### Overview

Use Customer Managed Keys to encrypt Teams chat and files using your own Azure Key Vault-managed keys.

### Security Benefits

* Retain full control of encryption keys
* Revoke access instantly by rotating or disabling keys
* Essential for compliance in high-security environments (e.g., ITSG-33, CJIS)

### Configuration Steps

1. **Prerequisites**:

   * Azure subscription with Azure Key Vault
   * Microsoft 365 E5 license (required for Customer Key)
   * Access to Microsoft Purview compliance portal

2. **Create Azure Key Vault and Keys**:

   * Go to [Azure Portal](https://portal.azure.com)
   * Create a Key Vault with:
     * **Purge protection**: Enabled
     * **Soft-delete**: Enabled
   * Generate RSA keys (2048 or 4096 bit)
   * Create **two separate keys** for redundancy (Customer Key requirement)

3. **Register Required Service Principals**:

   * Ensure the following service principals are registered in your tenant:
     * **Microsoft.Office365.AdvancedThreatProtection**
     * **Microsoft.Office365.CustomerKey**
   
   Use PowerShell to check:
   ```powershell
   Get-MsolServicePrincipal -ServicePrincipalName "Microsoft.Office365.CustomerKey"
   ```

4. **Assign Key Vault Permissions**:

   * Grant the **Microsoft 365 Customer Key** service principal:
     * **Get**, **Wrap Key**, **Unwrap Key** permissions
   * Use Azure RBAC or Key Vault access policies

5. **Create Data Encryption Policy (DEP)**:

   * Connect to Exchange Online PowerShell:
   ```powershell
   Connect-ExchangeOnline
   ```
   
   * Create the DEP for Teams:
   ```powershell
   New-M365DataAtRestEncryptionPolicy -Name "TeamsCustomerKey" `
     -AzureKeyIDs @('https://keyvault1.vault.azure.net/keys/key1', 'https://keyvault2.vault.azure.net/keys/key2') `
     -Description "Customer managed key for Teams"
   ```

6. **Assign DEP to Teams**:

   ```powershell
   Set-M365DataAtRestEncryptionPolicyAssignment -DataEncryptionPolicy "TeamsCustomerKey" `
     -Organization (Get-OrganizationConfig).Identity
   ```

### Microsoft Docs

* Customer Key Overview - Microsoft Purview
* Set up Customer Key - Microsoft Purview
* Manage Customer Key - Microsoft Purview

### Testing Steps

* Verify key usage in Azure Key Vault monitoring logs
* Monitor DEP status: `Get-M365DataAtRestEncryptionPolicy`
* Test key revocation (in non-production): Disable key access and verify Teams content becomes inaccessible
* Confirm encrypted data status in Microsoft Purview compliance portal

---

## Final Notes

* **Change Management**: Ensure policies are documented and shared with your governance team.
* **User Communication**: Inform external participants of new MFA and access expectations.
* **Audit and Compliance**: Use Microsoft Purview, Microsoft Defender for Cloud Apps, and Azure Monitor to track security-related events.
* **Role Requirements**: Remember that Global Administrator role doesn't include permissions for custom security attributes by default.

For additional support, refer to:

* [Microsoft Teams Security Documentation](https://learn.microsoft.com/en-us/microsoftteams/security-compliance-overview)
* [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
* [Microsoft Entra Documentation](https://learn.microsoft.com/en-us/entra/)
* [Current Conditional Access Features](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)