---
marp: true
paginate: true
theme: default
size: 16:9
---
![](./image/cloudstrucc_word_template.png)

# Quote: SharePoint, OneDrive & PDF Security Hardening with Purview Sensitivity Labels

## For Leonardo Company - Canada

### Prepared by Cloudstrucc Inc

---

## Executive Summary

Leonardo Company Canada, a leading defence contractor operating within the naval electronics segment, is subject to the stringent requirements of the **Controlled Goods Program (CGP)**, governed by **Public Services and Procurement Canada (PSPC)**, as well as a broad range of government and international compliance frameworks.

Having successfully implemented **Customer Managed Keys (CMK)** for Microsoft 365 encryption at rest, Leonardo Company is now positioned to advance to the next critical milestone: **enterprise-grade hardening of SharePoint Online, OneDrive for Business and Adobe PDF security** across the organization's user base.

The scope encompasses SharePoint Advanced Management configuration, access control policies, external sharing governance for federal government partners, OneDrive desktop sync hardening, Microsoft Purview sensitivity labeling (including PDF support with Adobe Acrobat integration), Data Loss Prevention policies, Conditional Access enforcement, and comprehensive audit and retention configuration.

The end state will deliver a secure, compliant, and operationally efficient SharePoint and OneDrive environment — building upon the existing CMK foundation to provide end-to-end data protection.

---

## Scope of Work

### SharePoint Online Security Hardening

- Configure **SharePoint Advanced Management (SAM)** features including data access governance reports, site access reviews, and inactive site policies
- Implement **Restricted Access Control** for SharePoint sites using security groups and Microsoft 365 groups
- Configure **block download policies** for sensitive SharePoint sites (browser-only access for controlled content)
- Apply **Conditional Access policies** with authentication context to SharePoint sites based on sensitivity classification
- Configure **tenant-level and site-level external sharing controls** — restrict sharing to approved federal government partner domains
- Set sharing link defaults (disable anonymous "Anyone" links; enforce authenticated guest sharing with expiration)
- Implement **site-level permission governance** using role-based access control (RBAC) and security groups (Entra ID)
- Configure **SharePoint access control for unmanaged devices** (block or limit access per site sensitivity)
- Enable and configure **Data Access Governance (DAG) reports** to identify overshared or sensitive content
- Implement **site ownership policies** and **inactive site lifecycle management**

### OneDrive for Business Security Hardening

- Configure **OneDrive Restricted Access Control** by security group — limit access to authorized personnel only
- Apply **Conditional Access and session controls** for OneDrive access (compliant device enforcement)
- Configure **OneDrive sync client policies** — restrict sync to domain-joined / Intune-compliant corporate devices only
- Enforce **Known Folder Move (KFM)** policies for Desktop, Documents, and Pictures with GPO/Intune
- Restrict OneDrive sharing settings to align with SharePoint tenant-level policies
- Block download, print, and sync from untrusted sessions via Defender for Cloud Apps / Purview
- Configure **OneDrive storage limits and retention policies**

### Microsoft Purview — Sensitivity Labels, DLP & PDF Integration

- Design and deploy a **sensitivity label taxonomy** aligned with organizational classification requirements (e.g., Unclassified, Protected A, Protected B, Confidential)
- Enhance **sensitivity labels for Office files in SharePoint and OneDrive** (via Purview portal / `Set-SPOTenant`)
- Enable **PDF sensitivity label support** in SharePoint and OneDrive (`EnableSensitivityLabelforPDF` parameter)
- Configure **default sensitivity labels per document library** for baseline classification
- Configure **auto-labeling policies** for SharePoint, OneDrive, and Exchange targeting sensitive information types (SITs) — including PDF files at rest
- Implement **Extend Protection on Download** for labeled SharePoint document libraries (permissions travel with downloaded files)
- Configure **DLP policies** in Microsoft Purview to prevent unauthorized sharing of Protected B and classified content
- Apply DLP rules to detect and block sensitive information types (SIN, credit card, CUI markings, etc.) across SharePoint, OneDrive, and Exchange
- Configure **sensitivity label content markings** (headers, footers, watermarks) for visual classification indicators
- Validate encrypted PDF rendering in Microsoft Edge and supported applications

### Adobe Acrobat — Native Microsoft Purview Sensitivity Label Integration

- Enable **Microsoft Purview Information Protection (MPIP)** support in Adobe Acrobat Pro/Standard across the organization
- Deploy **Windows registry settings via Intune/GPO** to enable MPIP functionality in Adobe Acrobat:
  - `bShowDMB` — Enable document message bar to display sensitivity label information
  - `bEnableAIP` — Enable Microsoft Purview Information Protection integration
  - `bEnableSensitivityLabelDefaulting` — Enable default and mandatory labeling support
- Configure **mandatory labeling enforcement** in Adobe Acrobat (users must apply a sensitivity label before saving PDFs)
- Configure **default sensitivity label** for PDFs when no label is manually selected
- Enable **content markings** (headers, footers, watermarks) to be applied to PDFs matching the Purview label configuration
- Validate **user-defined permissions (UDP)** labeling experience for bespoke access control on PDF documents
- Document end-user workflow for applying, editing, and removing sensitivity labels directly within Adobe Acrobat
- Validate **Adobe Acrobat Reader** (free) support for viewing protected/labeled PDFs
- Remove any legacy **Microsoft Information Protection (MIP) plug-ins** for Adobe Acrobat (no longer required with native integration)
- Provide IT Administrator documentation on managing MPIP settings in Adobe Acrobat via registry/Intune

### Audit, Compliance & Defender Integration

- Configure **Unified Audit Log** retention policies for SharePoint and OneDrive activities
- Enable **Microsoft Purview audit (Premium)** for enhanced investigation capabilities
- Implement **Defender for Office 365** Safe Links and Safe Attachments policies for SharePoint and OneDrive
- Configure **Defender XDR** dashboards and alert policies for SharePoint-related threat detection
- Enable **Customer Lockbox** for controlled Microsoft engineer access to tenant content
- Configure **eDiscovery** holds and search scopes as required for compliance readiness

### Knowledge Transfer & Training

- Deliver **IT Administrator training sessions** (live walkthroughs) covering all configured policies, management consoles, and operational procedures
- Provide internal **build book documentation** (wiki / reference guide) for ongoing administration

---

## Pre-Requisites and Deployment Approach

To perform the activities outlined in this proposal, the following pre-requisites and operating model must be established:

### Access and Privileged Roles

Cloudstrucc will require:

- A dedicated **privileged administrative account** (e.g., `sp-sec-admin@leonardocompany.com`) or membership in a **privileged role group** within Microsoft Entra ID.
- The following roles or equivalent custom RBAC assignments:

  - **Global Reader** (for assessments and baselining)
  - **Security Administrator** (for configuring Defender, alerts, Purview)
  - **Compliance Administrator** (for DLP, Sensitivity Labels, eDiscovery, auto-labeling)
  - **SharePoint Administrator** (for site policies, access control, sharing settings, SAM features)
  - **Conditional Access Administrator** (for scoped CA policy configuration)
  - **Exchange Administrator** (if DLP policies extend to Exchange Online)
  - **Intune Administrator** (for deploying Adobe Acrobat MPIP registry settings)

Access must be granted by the Leonardo Company Entra administrator prior to production work commencing (initial build and staging will occur in a lab environment as described below).

### Cloudstrucc Build & Staging Subscription Model

To support structured, low-risk implementation:

- Cloudstrucc will use its **own Azure subscription and M365 tenant** for initial **build, configuration, and templating**.
- This isolated tenant will mirror Leonardo Company's compliance needs and baseline.
- Once complete:

  - Configuration will be validated and staged via **PowerShell scripts** and **documented runbooks**.
  - These artifacts will be deployed to a **client-staging environment** (test tenant or sandbox).
  - Following successful review, the solution will be **deployed to the primary Leonardo tenant** using a change-controlled (DevOps/GIT pipeline), and documented process in collaboration with the IT administrators.

**This model ensures:**

- Minimal disruption to existing Leonardo Company services
- Clean separation between development and production
- Reproducible security posture across environments

### Pre-Requisite Licensing

The following licensing must be in place prior to implementation:

- **Microsoft 365 Business Premium** — already in place
- **Microsoft Purview** — already in place (required for DLP, sensitivity labels, auto-labeling, and audit capabilities)
- **Customer Managed Keys (CMK)** — already implemented
- **SharePoint Advanced Management (SAM)** — required for Restricted Access Control, block download policies, data access governance reports, and site lifecycle management (included with M365 Copilot licenses or available standalone)
- **Adobe Acrobat Pro or Standard** — required for native MPIP sensitivity label support; version 22.003.20258 or later (users who only need to view protected PDFs may use Adobe Acrobat Reader)

---

## Duration and Phasing

### Project Duration: 30 to 50 Calendar Days

Commencing the **week of February 16, 2026**.

| Phase   | Duration  | Milestone                                 | Outcome                                                                                        |
| ------- | --------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Phase 1 | Week 1    | Kickoff & Assessment                      | Current posture audit, gap analysis, stakeholder alignment, lab setup                          |
| Phase 2 | Weeks 2–3 | SharePoint Access Control & Sharing       | Tenant/site sharing policies, Restricted Access Control, Conditional Access, SAM features live |
| Phase 3 | Weeks 3–4 | OneDrive Hardening & Desktop Sync         | Sync restrictions, device compliance, OneDrive access controls deployed                        |
| Phase 4 | Weeks 4–5 | Sensitivity Labels, DLP & PDF Integration | Label taxonomy deployed, auto-labeling active, PDF support enabled, DLP policies enforced      |
| Phase 5 | Week 5    | Adobe Acrobat MPIP Integration            | Registry deployment via Intune, mandatory/default labeling configured, end-user validation     |
| Phase 6 | Weeks 5–6 | Audit, Compliance & Defender              | Audit retention configured, Defender alerts live, compliance validation complete               |
| Phase 7 | Week 6    | Testing & Rollout                         | End-to-end testing, policy rollout to all users, post-production validation                 |
| Phase 8 | Week 7    | Documentation & Knowledge Transfer        | Build book delivered, IT admin training sessions conducted                                     |
| Support | 30 days post-handover | Ongoing Support                 | Tuning, questions, issue resolution                                                            |

---

## Implementation Cost Estimate (CAD)

| Item                                         | Description                                                                                                                                                       | Estimated Cost (CAD)  |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| Discovery & Assessment                       | Initial audit, kickoff, stakeholder alignment, lab environment setup, current posture documentation                                                               | $3,500                |
| SharePoint Access Control & Sharing Policies | Tenant and site-level sharing configuration, Restricted Access Control, SAM features, Conditional Access with authentication context, external sharing governance | $5,000                |
| OneDrive Hardening & Desktop Sync            | Sync client restrictions, device compliance enforcement, OneDrive Restricted Access Control, session controls                                                     | $3,500                |
| Sensitivity Labels, DLP & PDF Integration    | Label taxonomy design and deployment, auto-labeling policies, PDF label enablement, DLP policy configuration, content markings, Extend Protection on Download     | $4,500                |
| Adobe Acrobat MPIP Integration               | Registry deployment via Intune/GPO, mandatory and default labeling configuration, end-user workflow validation, legacy plug-in removal                            | $4,000                |
| Audit, Compliance & Defender Integration     | Unified Audit Log retention, Defender for O365 configuration, XDR dashboards, Customer Lockbox                                                                    | $2,500                |
| Testing & Production Rollout                 | End-to-end validation, phased policy rollout to all users, post-production test runs                                                                              | $1,500                |
| Documentation & Knowledge Transfer           | Build book / wiki documentation, live IT administrator training sessions (2 sessions)                                                                             | $2,000                |
| **Subtotal**                                 |                                                                                                                                                                   | **$26,500 CAD**       |
| HST (13%)                                    |                                                                                                                                                                   | **$3,445 CAD**        |
| **Total with HST**                           |                                                                                                                                                                   | **$29,945 CAD**       |

**Resource:** 1 Architect / Principal Consultant (Cloudstrucc Inc.)

**Payment Terms**
The total amount indicated in this proposal, including applicable taxes, shall become payable upon completion of the scope of work as outlined herein. Final payment shall be due within thirty (30) days of the client's written confirmation of acceptance and sign-off of the completed deliverables. For greater certainty, such acceptance shall not be unreasonably withheld. This agreement shall be governed by the laws of the Province of Ontario and the federal laws of Canada applicable therein.

> *Optional extension at $125/hr support block (min. 10 hrs)*

---

## Licensing Requirements (CAD Pricing)

To implement the described security hardening, Leonardo Company Canada will require the following licensing:

### Current Licensing (Already in Place)

| License Tier                   | Status   |
| ------------------------------ | -------- |
| Microsoft 365 Business Premium | In place |
| Microsoft Purview              | In place |
| Customer Managed Keys (CMK)    | In place |

### Additional Licensing Required

| License Tier                   | Features Required                                                                                   | Estimated Monthly Cost (CAD/user)              |
| ------------------------------ | --------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| SharePoint Advanced Management | Restricted Access Control, Block Download Policy, Data Access Governance, Site Lifecycle Management | ~$3 (standalone) or included with M365 Copilot |
| Adobe Acrobat Pro or Standard  | Native Microsoft Purview Information Protection sensitivity label support (apply, edit, remove labels on PDFs) | $16–23/user (Pro) or $13–15/user (Standard) |

### Notes

- SharePoint Advanced Management is required for Restricted Access Control policies, block download, and data access governance reports. It is included automatically if any users hold M365 Copilot licenses; otherwise it is available as a standalone per-user add-on.
- Adobe Acrobat Pro or Standard (version 22.003.20258 or later) is required for native Microsoft Purview Information Protection sensitivity label support. Adobe Acrobat Reader (free) can view protected PDFs but cannot apply or edit labels. Pricing varies based on annual commitment and volume licensing agreements.
- Minimum quantity and enterprise agreements may affect pricing.

---

## Appendices

### Appendix A: SharePoint Online Security Hardening Checklist

- Tenant-level external sharing configuration (Entra ID B2B guest accounts, domain allow-listing for federal partners)
- Site-level sharing overrides for sensitive sites (disable "Anyone" links, enforce expiration)
- SharePoint Advanced Management: Restricted Access Control per site via security groups
- SharePoint Advanced Management: Block download policy for Protected B and classified libraries
- SharePoint Advanced Management: Data Access Governance reports for oversharing detection
- SharePoint Advanced Management: Site ownership and inactive site lifecycle policies
- Conditional Access with authentication context applied to sensitive SharePoint sites
- Unmanaged device access control (block or browser-only per site classification)
- SharePoint site permission audit and RBAC alignment
- Information Barriers configuration (if applicable across business units)

### Appendix B: OneDrive for Business Security Checklist

- OneDrive Restricted Access Control by security group
- OneDrive sync client restricted to domain-joined / Intune-compliant devices
- Known Folder Move (KFM) enforcement via GPO or Intune
- OneDrive sharing settings aligned with SharePoint tenant policy
- Conditional Access: require compliant device for OneDrive access
- Block download from untrusted sessions (Defender for Cloud Apps integration)
- OneDrive retention and storage policies configured

### Appendix C: Purview Sensitivity Labels & PDF Integration Checklist

- Sensitivity label taxonomy defined (Unclassified, Protected A, Protected B, Confidential)
- Labels published to all users in the organization via label policy
- Sensitivity labels enabled for Office files in SharePoint and OneDrive (`EnableAIPIntegration = True`)
- PDF sensitivity label support enabled (`EnableSensitivityLabelforPDF = True`)
- Co-authoring for encrypted files enabled
- Default sensitivity labels configured per document library
- Auto-labeling policies configured for SharePoint, OneDrive, and Exchange (Office + PDF files)
- Extend Protection on Download configured for sensitive libraries
- DLP policies targeting sensitive information types (SIN, CUI markings, credit card, health data)
- Content markings (headers, footers, watermarks) configured per label
- Encrypted PDF rendering validated in Microsoft Edge

### Appendix D: Adobe Acrobat MPIP Integration Checklist

- Adobe Acrobat Pro/Standard version verified (22.003.20258 or later required)
- Legacy Microsoft Information Protection plug-ins removed (no longer required)
- Windows registry settings deployed via Intune or GPO:
  - `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown`
    - `bShowDMB` (DWORD) = 1 — Enable document message bar
    - `bEnableAIP` (DWORD) = 1 — Enable Microsoft Purview Information Protection
    - `bEnableSensitivityLabelDefaulting` (DWORD) = 1 — Enable default/mandatory labeling
- Microsoft Purview mandatory labeling policy configured (enforces label selection before save)
- Microsoft Purview default labeling policy configured (auto-applies baseline label if none selected)
- Content markings (headers, footers, watermarks) validated in Adobe Acrobat
- User-defined permissions (UDP) labeling workflow validated
- End-user documentation provided for applying/editing sensitivity labels in Adobe Acrobat
- Adobe Acrobat Reader tested for viewing protected PDFs (read-only access confirmed)
- Audit logging validated for PDF labeling activities in Microsoft Purview

### Appendix E: Reference Documentation

- [Microsoft Purview Compliance Center](https://compliance.microsoft.com/)
- [SharePoint Advanced Management Overview](https://learn.microsoft.com/en-us/sharepoint/advanced-management)
- [How SharePoint and OneDrive Safeguard Your Data](https://learn.microsoft.com/en-us/sharepoint/safeguarding-your-data)
- [Enable Sensitivity Labels for Files in SharePoint and OneDrive](https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-onedrive-files)
- [Configure Default Sensitivity Label for SharePoint Document Library](https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-default-label)
- [SharePoint Restricted Access Control](https://learn.microsoft.com/en-us/sharepoint/restricted-access-control)
- [Block Download Policy for SharePoint and OneDrive](https://learn.microsoft.com/en-us/sharepoint/block-download-from-sites)
- [Control Access from Unmanaged Devices](https://learn.microsoft.com/en-us/sharepoint/control-access-from-unmanaged-devices)
- [Microsoft Purview Information Protection Support in Adobe Acrobat](https://helpx.adobe.com/enterprise/kb/mpip-support-acrobat.html)
- [Protect PDFs using Microsoft Purview Sensitivity Labels (Adobe)](https://experienceleague.adobe.com/en/docs/document-cloud-learn/acrobat-learning/integrations/microsoftsensitivitylabels)

---

*Prepared by Cloudstrucc inc.*