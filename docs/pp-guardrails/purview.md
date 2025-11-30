<img src="https://www.canada.ca/etc/designs/canada/wet-boew/assets/sig-blk-en.svg"
     alt="Government of Canada Signature"
     style="float: right; width: 300px; margin: 0 0 100px 100px;" />
<br>

# Microsoft Purview Information Protection Buildbook
## Canadian Federal Government - Sensitivity Labels and Policies

**Document Version:** 2.0  
**Effective Date:** December 2025  
**Authority:** Shared Services Canada (SSC) & Treasury Board Secretariat (TBS)  
**Classification:** Protected B Medium Integrity Medium Availability (PBMM)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Prerequisites and Licensing](#2-prerequisites-and-licensing)
3. [Canadian Government Sensitivity Label Taxonomy](#3-canadian-government-sensitivity-label-taxonomy)
4. [Creating Sensitivity Labels](#4-creating-sensitivity-labels)
5. [Sensitive Information Types for Canada](#5-sensitive-information-types-for-canada)
6. [Label Policies and Publishing](#6-label-policies-and-publishing)
7. [Auto-Labeling Policies - OOB Canadian Templates](#7-auto-labeling-policies---oob-canadian-templates)
8. [Data Loss Prevention (DLP) Policies](#8-data-loss-prevention-dlp-policies)
9. [User Notifications, Banners, and Alerts](#9-user-notifications-banners-and-alerts)
10. [Power Platform Integration](#10-power-platform-integration)
11. [Dashboard and Reporting](#11-dashboard-and-reporting)
12. [Implementation Checklist](#12-implementation-checklist)
13. [Reference Documentation](#13-reference-documentation)

---

## 1. Executive Summary

This buildbook provides step-by-step guidance for implementing Microsoft Purview Information Protection to classify and protect Canadian government sensitive information. It covers sensitivity label creation, policy configuration using **out-of-the-box (OOB) Canadian templates**, user notifications, and integration with Power Platform and Dataverse.

**Key Objectives:**

- Implement sensitivity labels aligned with Canadian government classification standards
- **Deploy all three OOB Canadian policy template categories: Financial, Medical/Health, and Privacy**
- Configure a **custom policy for Protected B classification** to complement OOB templates
- Enable user notifications and policy tips when sensitive information is detected
- Integrate with Power Platform/Dataverse for comprehensive data protection
- Establish monitoring and reporting dashboards

**Alignment with Canadian Standards:**

This implementation aligns with:

- Government of Canada Security Classification Levels
- PIPEDA Sensitive Personal Information requirements
- Office of the Privacy Commissioner (OPC) guidance on sensitive information
- ITSG-33 Information Classification controls
- Provincial Health Information Acts (HIA, PHIPA, PHIA)

---

## 2. Prerequisites and Licensing

### 2.1 Required Licenses

| Feature | License Required |
|---------|-----------------|
| Manual sensitivity labeling | Microsoft 365 E3/A3/G3 or higher |
| Auto-labeling (client-side) | Microsoft 365 E5/A5/G5 |
| Auto-labeling (service-side) | Microsoft 365 E5/A5/G5 Compliance |
| DLP policies | Microsoft 365 E5/A5/G5 or E5 Compliance add-on |
| Advanced auditing | Microsoft 365 E5/A5/G5 or E5 Compliance add-on |
| Dataverse labeling | Microsoft 365 E5 + Purview Data Map |

### 2.2 Required Permissions

| Role | Purpose |
|------|---------|
| Global Administrator | Initial setup and configuration |
| Compliance Administrator | Create and manage labels/policies |
| Sensitivity Label Administrator | Manage sensitivity labels |
| Information Protection Administrator | Full information protection management |
| Security Reader | View-only access to reports |

### 2.3 Prerequisites Checklist

- [ ] Appropriate Microsoft 365 licenses assigned
- [ ] Microsoft Purview portal access verified
- [ ] Compliance roles assigned to administrators
- [ ] Unified audit logging enabled
- [ ] Microsoft 365 Apps deployed to users (for client-side labeling)

---

## 3. Canadian Government Sensitivity Label Taxonomy

### 3.1 Recommended Label Structure

The following label taxonomy aligns with Government of Canada security classification levels:

```
GC-Unclassified
├── GC-Unclassified-Public
└── GC-Unclassified-Internal

GC-Protected
├── GC-Protected-A
│   └── GC-Protected-A-Personal
├── GC-Protected-B
│   ├── GC-Protected-B-Personal
│   ├── GC-Protected-B-Financial
│   ├── GC-Protected-B-Health
│   └── GC-Protected-B-Security
└── GC-Protected-C (if required)

GC-Classified (if applicable)
├── GC-Confidential
├── GC-Secret
└── GC-Top-Secret
```

### 3.2 Label Definitions

| Label | Description | Examples |
|-------|-------------|----------|
| **GC-Unclassified-Public** | Information approved for public release | Press releases, public reports, website content |
| **GC-Unclassified-Internal** | Non-sensitive internal information | Meeting notes, general correspondence |
| **GC-Protected-A** | Low sensitivity personal/business information | Business plans, organizational charts |
| **GC-Protected-B** | Sensitive information requiring protection | SIN, health records, financial data, security assessments |
| **GC-Protected-C** | Extremely sensitive information | National security, critical infrastructure |

### 3.3 Canadian Sensitive Information Categories

Based on OPC guidance, the following categories are generally considered sensitive in Canada:

| Category | Examples | Purview SIT | OOB Template |
|----------|----------|-------------|--------------|
| **Financial Data** | Bank accounts, credit cards | Canada Bank Account Number, Credit Card | Canada Financial Data |
| **Health Information** | Medical records, health card numbers | Canada Health Service Number, Canada PHIN | Canada HIA/PHIPA/PHIA |
| **Government IDs** | SIN, passport, driver's license | Canada SIN, Canada Passport | Canada PII/PIPEDA |
| **Personal Privacy** | Combined PII elements | Multiple SITs | Canada PIPA/PIPEDA |

---

## 4. Creating Sensitivity Labels

### 4.1 Access the Microsoft Purview Portal

1. Navigate to: `https://purview.microsoft.com`
2. Sign in with Compliance Administrator credentials
3. Select **Solutions** > **Information Protection** > **Sensitivity labels**

### 4.2 Create Parent Label: GC-Unclassified

**Step 1: Create Label**

1. Select **+ Create a label**
2. Enter label details:

| Field | Value |
|-------|-------|
| Name | `GC-Unclassified` |
| Display Name | `GC - Unclassified` |
| Description for users | `Information that does not require security classification. May be shared within government or publicly as appropriate.` |
| Description for admins | `Parent label for unclassified government information. Child labels define sharing scope.` |

**Step 2: Define Scope**

Select the following scopes:

- [x] Files & other data assets
- [x] Emails
- [x] Meetings (if licensed)
- [x] Groups & Sites

**Step 3: Protection Settings**

For GC-Unclassified parent:

- Encryption: None
- Content Marking: None (or light footer)

**Step 4: Auto-labeling**

- Skip for parent label

### 4.3 Create Sublabel: GC-Unclassified-Public

1. Select **GC-Unclassified** > **Create sublabel**
2. Enter details:

| Field | Value |
|-------|-------|
| Name | `GC-Unclassified-Public` |
| Display Name | `Public` |
| Description for users | `Information approved for public release. No restrictions on sharing.` |
| Color | Green (#00B050) |

**Protection Settings:**

- Encryption: None
- Content Marking: Optional footer "UNCLASSIFIED - PUBLIC"

### 4.4 Create Sublabel: GC-Unclassified-Internal

| Field | Value |
|-------|-------|
| Name | `GC-Unclassified-Internal` |
| Display Name | `Internal` |
| Description for users | `Non-sensitive internal government information. Share within your organization only.` |
| Color | Blue (#0070C0) |

**Protection Settings:**

- Encryption: None (or organization-only if required)
- Content Marking: Footer "UNCLASSIFIED - INTERNAL USE ONLY"

### 4.5 Create Parent Label: GC-Protected

| Field | Value |
|-------|-------|
| Name | `GC-Protected` |
| Display Name | `GC - Protected` |
| Description for users | `Information that requires protection from unauthorized disclosure. Apply appropriate sublabel based on sensitivity level.` |
| Description for admins | `Parent label for Protected information. Sublabels A, B, C define sensitivity levels.` |

### 4.6 Create Sublabel: GC-Protected-A

| Field | Value |
|-------|-------|
| Name | `GC-Protected-A` |
| Display Name | `Protected A` |
| Description for users | `Low-sensitivity protected information. Could cause limited injury to an individual, organization, or government if disclosed.` |
| Color | Yellow (#FFC000) |

**Protection Settings:**

| Setting | Configuration |
|---------|--------------|
| Encryption | None or Co-Author for organization |
| Content Marking - Header | `PROTECTED A` |
| Content Marking - Footer | `Government of Canada - Protected A` |
| Content Marking - Watermark | None |

### 4.7 Create Sublabel: GC-Protected-B (CRITICAL)

| Field | Value |
|-------|-------|
| Name | `GC-Protected-B` |
| Display Name | `Protected B` |
| Description for users | `Sensitive information that could cause serious injury to an individual, organization, or government if disclosed. Includes personal health information, SIN, financial data.` |
| Color | Orange (#FF6600) |

**Protection Settings (Recommended):**

| Setting | Configuration |
|---------|--------------|
| Encryption | Encrypt with organization key |
| Permissions | Co-Author for organization members |
| Allow offline access | 7 days |
| Content Marking - Header | `PROTECTED B` (Red, 12pt, Bold) |
| Content Marking - Footer | `Government of Canada - Protected B - Do Not Distribute Externally` |
| Content Marking - Watermark | `PROTECTED B` (diagonal, light gray) |

**Encryption Configuration:**

```
Assign permissions now:
- All authenticated users in organization: Co-Author
- Specific groups (if needed): Viewer

User permissions:
- Users can assign permissions when they apply the label: No
```

### 4.8 Create Protected B Sub-sublabels (Recommended)

Create sub-sublabels to align with OOB template categories:

**GC-Protected-B-Personal:**

| Field | Value |
|-------|-------|
| Name | `GC-Protected-B-Personal` |
| Display Name | `Protected B - Personal Information` |
| Description | `Personal information including SIN, passport, driver's license and other identifiable data requiring Protected B handling.` |

**GC-Protected-B-Financial:**

| Field | Value |
|-------|-------|
| Name | `GC-Protected-B-Financial` |
| Display Name | `Protected B - Financial` |
| Description | `Sensitive financial information including banking details, credit card information, and related financial records.` |

**GC-Protected-B-Health:**

| Field | Value |
|-------|-------|
| Name | `GC-Protected-B-Health` |
| Display Name | `Protected B - Health Information` |
| Description | `Protected health information including health service numbers, PHIN, medical records subject to HIA/PHIPA/PHIA.` |

### 4.9 Label Priority Order

Configure priority from lowest to highest sensitivity:

| Priority | Label |
|----------|-------|
| 0 | GC-Unclassified-Public |
| 1 | GC-Unclassified-Internal |
| 2 | GC-Protected-A |
| 3 | GC-Protected-B |
| 4 | GC-Protected-B-Personal |
| 5 | GC-Protected-B-Financial |
| 6 | GC-Protected-B-Health |
| 7 | GC-Protected-C (if used) |

---

## 5. Sensitive Information Types for Canada

### 5.1 Built-in Canadian SITs

Microsoft Purview includes the following Canadian-specific sensitive information types:

| SIT Name | Pattern | Confidence Level | OOB Template |
|----------|---------|------------------|--------------|
| Canada Bank Account Number | 7-12 digits + keywords | Medium-High | Financial |
| Canada Driver's License Number | Province-specific patterns | Medium | Privacy/PII |
| Canada Health Service Number | Province-specific patterns | Medium | Health |
| Canada Passport Number | 8 alphanumeric | Medium-High | Privacy/PII |
| Canada Personal Health Identification Number (PHIN) | Province-specific | Medium | Health |
| Canada Social Insurance Number (SIN) | 9 digits (XXX-XXX-XXX) | High | Privacy/PII |
| Credit Card Number | Standard patterns | High | Financial |

### 5.2 SIN Detection Details

The Canada Social Insurance Number SIT detects:

**High Confidence:**

- Pattern: `\d{3}[- ]\d{3}[- ]\d{3}` (formatted)
- Plus: Keywords from `Keyword_sin` AND `Keyword_sin_collaborative`
- Plus: Valid Luhn checksum

**Medium Confidence:**

- Pattern: `\d{9}` (unformatted)
- Plus: Keyword from `Keyword_sin`
- Plus: Valid Luhn checksum

**Keywords include:** sin, social insurance, numero d'assurance sociale, sins, ssn, ssns, social security, numero d'assurance social, national identification number, national id, sin#, soc ins, social ins

### 5.3 Health Number Detection

**Canada Personal Health Identification Number (PHIN):**

- Province-specific patterns
- Keywords: health identification number, hin, health card, health insurance, provincial health, etc.

**Canada Health Service Number:**

- Province-specific formats
- Keywords: msp, master services plan, medicare, health card number

### 5.4 SIT Mapping to OOB Templates

| OOB Template | Sensitive Information Types Included |
|--------------|-------------------------------------|
| **Canada Financial Data** | Credit Card Number, Canada Bank Account Number |
| **Canada HIA** | Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Canada PHIPA (Ontario)** | Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Canada PHIA (Manitoba)** | Canada SIN, Canada Health Service Number, Canada PHIN |
| **Canada PIPA** | Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Canada PIPEDA** | Canada Driver's License, Canada Bank Account, Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Canada PII** | Canada Driver's License, Canada Bank Account, Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **PCI DSS** | Credit Card Number |

---

## 6. Label Policies and Publishing

### 6.1 Create Label Publishing Policy

**Navigate to:** Microsoft Purview Portal > Information Protection > Label policies > **Publish labels**

### 6.2 Policy Configuration: GC-Standard-Policy

**Step 1: Choose Labels to Publish**

Select all labels created:

- [x] GC-Unclassified (and sublabels)
- [x] GC-Protected (and sublabels)

**Step 2: Assign Admin Units**

- Select: All (or specific organizational units)

**Step 3: Publish to Users and Groups**

| Scope | Selection |
|-------|-----------|
| Users | All users in organization |
| Groups | Specific security groups (if phased rollout) |

**Step 4: Policy Settings**

| Setting | Configuration | Rationale |
|---------|--------------|-----------|
| **Apply default label to documents** | GC-Unclassified-Internal | Ensures all documents have a baseline label |
| **Apply default label to emails** | GC-Unclassified-Internal | Ensures all emails are labeled |
| **Apply default label to meetings** | GC-Unclassified-Internal | If meetings scope enabled |
| **Require users to apply a label** | Yes | Mandatory labeling for compliance |
| **Require justification for label change** | Yes (for downgrade only) | Audit trail for label changes |
| **Provide help link to custom page** | `https://[your-intranet]/data-classification` | User guidance |
| **Display label in Outlook toolbar** | Yes | Visibility for users |

**Step 5: Default Labels Configuration**

```
Documents: GC-Unclassified-Internal
Emails: GC-Unclassified-Internal  
Meetings: GC-Unclassified-Internal
Power BI: GC-Unclassified-Internal
```

**Step 6: Mandatory Labeling**

Enable: **Users must provide justification to remove a label or lower its classification**

This creates an audit trail when users attempt to:

- Remove a sensitivity label
- Change from Protected B to Protected A
- Change from Protected to Unclassified

---

## 7. Auto-Labeling Policies - OOB Canadian Templates

> **IMPORTANT:** Microsoft Purview provides out-of-the-box (OOB) Canadian policy templates that should be implemented. You must create policies from **all three categories** (Financial, Medical/Health, Privacy) **plus a Custom policy** for comprehensive Protected B coverage.

### 7.1 Overview of Canadian OOB Templates

When creating auto-labeling policies in Microsoft Purview, filter by **Canada** to see available templates:

**Categories and Regulations Available:**

| Category | Regulation/Template | SITs Included |
|----------|---------------------|---------------|
| **Financial** | Canada Financial Data | Credit Card Number, Canada Bank Account Number |
| **Financial** | PCI Data Security Standard (PCI DSS) | Credit Card Number |
| **Medical and Health** | Canada Health Information Act (HIA) | Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Medical and Health** | Canada Personal Health Act (PHIPA) - Ontario | Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Medical and Health** | Canada Personal Health Information Act (PHIA) - Manitoba | Canada SIN, Canada Health Service Number, Canada PHIN |
| **Privacy** | Canada Personal Information Protection Act (PIPA) | Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Privacy** | Canada PIPEDA | Canada Driver's License, Canada Bank Account, Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Privacy** | Canada Personally Identifiable Information (PII) | Canada Driver's License, Canada Bank Account, Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN |
| **Custom** | (User-defined) | Any combination of SITs |

### 7.2 Implementation Strategy

**MANDATORY: Implement ALL THREE categories plus Custom for complete coverage:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REQUIRED POLICY DEPLOYMENT                        │
├─────────────────────────────────────────────────────────────────────┤
│  1. FINANCIAL CATEGORY                                               │
│     ├── Canada Financial Data               → Protected B-Financial  │
│     └── PCI DSS                            → Protected B-Financial  │
│                                                                      │
│  2. MEDICAL AND HEALTH CATEGORY                                      │
│     ├── Canada HIA                         → Protected B-Health     │
│     ├── Canada PHIPA (Ontario)             → Protected B-Health     │
│     └── Canada PHIA (Manitoba)             → Protected B-Health     │
│                                                                      │
│  3. PRIVACY CATEGORY                                                 │
│     ├── Canada PIPA                        → Protected B-Personal   │
│     ├── Canada PIPEDA                      → Protected B-Personal   │
│     └── Canada PII                         → Protected B-Personal   │
│                                                                      │
│  4. CUSTOM CATEGORY                                                  │
│     └── GC-Protected-B-Comprehensive       → Protected B            │
│         (Combines all SITs with GC-specific rules)                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 7.3 POLICY 1: Financial Category - Canada Financial Data

**Navigate to:** Microsoft Purview Portal > Information Protection > Auto-labeling

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. On "Choose info you want this label applied to":
   - Select region filter: **Canada**
   - Category: **Financial**
   - Regulation: **Canada Financial Data**
3. Click **Next**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Financial-CanadaFinancialData` |
| Description | `Automatically detects and labels Canadian financial data including credit card numbers and bank account numbers as Protected B - Financial` |

**Step 3: Choose Locations**

Select all applicable locations:

- [x] Exchange email
- [x] SharePoint sites (All sites or specific)
- [x] OneDrive accounts (All users or specific)
- [x] Teams chat and channel messages
- [x] Devices (if endpoint DLP enabled)

**Step 4: Review Policy Rules (OOB)**

The template includes two pre-configured rules:

**Rule 1: Canada Financial Data - Low Count (1-9 instances)**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Credit Card Number (Min 1, Max 9) |
| | Canada Bank Account Number (Min 1, Max 9) |
| Content shared with | People outside my organization |
| Actions | Send notification |

**Rule 2: Canada Financial Data - High Count (10+ instances)**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Credit Card Number (Min 10, Max 500) |
| | Canada Bank Account Number (Min 10, Max 500) |
| Content shared with | People outside my organization |
| Actions | Block access, Send notification, Allow override with justification, Send incident report |

**Step 5: Choose Label to Apply**

- Select: **GC-Protected-B-Financial**

**Step 6: Policy Mode**

1. Start in **Simulation mode** (MANDATORY)
2. Run for minimum 7 days
3. Review simulation results
4. Enable policy after validation

---

### 7.4 POLICY 2: Financial Category - PCI DSS

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Financial** → Regulation: **PCI Data Security Standard (PCI DSS)**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Financial-PCIDSS` |
| Description | `Detects credit card numbers for PCI DSS compliance and applies Protected B - Financial label` |

**Step 3: Choose Locations**

- [x] All locations (Exchange, SharePoint, OneDrive, Teams, Devices)

**Step 4: Review Policy Rules (OOB)**

**Rule 1: PCI DSS - Low Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Credit Card Number (Min 1, Max 9) |
| Content shared with | People outside my organization |
| Actions | Send notification |

**Rule 2: PCI DSS - High Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Credit Card Number (Min 10, Max 500) |
| Content shared with | People outside my organization |
| Actions | Block access, Send notification, Allow override, Send incident report |

**Step 5: Choose Label**

- Select: **GC-Protected-B-Financial**

**Step 6: Policy Mode**

- Start in **Simulation mode**

---

### 7.5 POLICY 3: Medical/Health Category - Canada HIA

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Medical and health** → Regulation: **Canada Health Information Act (HIA)**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Health-CanadaHIA` |
| Description | `Detects health information subject to Canada Health Information Act and applies Protected B - Health label` |

**Step 3: Choose Locations**

- [x] All locations

**Step 4: Review Policy Rules (OOB)**

**Rule 1: Canada HIA - Low Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Canada Passport Number (Min 1, Max 9) |
| | Canada Social Insurance Number (Min 1, Max 9) |
| | Canada Health Service Number (Min 1, Max 9) |
| | Canada Personal Health Identification Number (Min 1, Max 9) |
| Content shared with | People outside my organization |
| Actions | Send notification |

**Rule 2: Canada HIA - High Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | All above (Min 10, Max 500 each) |
| Content shared with | People outside my organization |
| Actions | Block access, Send notification, Allow override with justification, Send incident report |

**Step 5: Choose Label**

- Select: **GC-Protected-B-Health**

**Step 6: Policy Mode**

- Start in **Simulation mode**

---

### 7.6 POLICY 4: Medical/Health Category - Canada PHIPA (Ontario)

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Medical and health** → Regulation: **Canada Personal Health Act (PHIPA) - Ontario**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Health-CanadaPHIPA-Ontario` |
| Description | `Detects personal health information subject to Ontario PHIPA and applies Protected B - Health label` |

**Step 3-6:** Same as HIA above

**SITs Included:** Canada Passport, Canada SIN, Canada Health Service Number, Canada PHIN

**Label:** GC-Protected-B-Health

---

### 7.7 POLICY 5: Medical/Health Category - Canada PHIA (Manitoba)

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Medical and health** → Regulation: **Canada Personal Health Information Act (PHIA) - Manitoba**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Health-CanadaPHIA-Manitoba` |
| Description | `Detects personal health information subject to Manitoba PHIA and applies Protected B - Health label` |

**SITs Included:** Canada SIN, Canada Health Service Number, Canada PHIN

**Label:** GC-Protected-B-Health

---

### 7.8 POLICY 6: Privacy Category - Canada PIPA

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Privacy** → Regulation: **Canada Personal Information Protection Act (PIPA)**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Privacy-CanadaPIPA` |
| Description | `Detects personal information subject to PIPA (Alberta/BC) and applies Protected B - Personal label` |

**Step 3: Choose Locations**

- [x] All locations

**Step 4: Review Policy Rules (OOB)**

**Rule 1: Canada PIPA - Low Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Canada Passport Number (Min 1, Max 9) |
| | Canada Social Insurance Number (Min 1, Max 9) |
| | Canada Health Service Number (Min 1, Max 9) |
| | Canada Personal Health Identification Number (Min 1, Max 9) |
| Content shared with | People outside my organization |
| Actions | Send notification |

**Rule 2: Canada PIPA - High Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | All above (Min 10, Max 500 each) |
| Actions | Block access, Send notification, Allow override, Send incident report |

**Step 5: Choose Label**

- Select: **GC-Protected-B-Personal**

---

### 7.9 POLICY 7: Privacy Category - Canada PIPEDA

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Privacy** → Regulation: **Canada Personal Information Protection and Electronic Documents Act (PIPEDA)**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Privacy-CanadaPIPEDA` |
| Description | `Detects personal information subject to PIPEDA and applies Protected B - Personal label. This is the primary federal privacy legislation template.` |

**Step 3: Choose Locations**

- [x] All locations

**Step 4: Review Policy Rules (OOB)**

**PIPEDA is the most comprehensive Canadian privacy template, including:**

**Rule 1: Canada PIPEDA - Low Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | Canada Driver's License Number (Min 1, Max 9) |
| | Canada Bank Account Number (Min 1, Max 9) |
| | Canada Passport Number (Min 1, Max 9) |
| | Canada Social Insurance Number (Min 1, Max 9) |
| | Canada Health Service Number (Min 1, Max 9) |
| | Canada Personal Health Identification Number (Min 1, Max 9) |
| Content shared with | People outside my organization |
| Actions | Send notification |

**Rule 2: Canada PIPEDA - High Count**

| Condition | Configuration |
|-----------|--------------|
| Sensitive info types | All above (Min 10, Max 500 each) |
| Actions | Block access, Send notification, Allow override with justification, Send incident report |

**Step 5: Choose Label**

- Select: **GC-Protected-B-Personal**

> **NOTE:** PIPEDA template provides the broadest coverage of Canadian PII and should be prioritized as the primary privacy template.

---

### 7.10 POLICY 8: Privacy Category - Canada PII

**Step 1: Create Policy from Template**

1. Click **+ Create auto-labeling policy**
2. Filter: **Canada** → Category: **Privacy** → Regulation: **Canada Personally Identifiable Information (PII) Data**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Privacy-CanadaPII` |
| Description | `Detects Canadian PII data and applies Protected B - Personal label` |

**SITs Included:** Same as PIPEDA (Driver's License, Bank Account, Passport, SIN, Health Service Number, PHIN)

**Label:** GC-Protected-B-Personal

---

### 7.11 POLICY 9: Custom Category - GC Protected B Comprehensive

> **CRITICAL:** Create this custom policy to ensure comprehensive Protected B detection that complements the OOB templates. This policy adds organization-specific rules and catches scenarios not covered by individual templates.

**Step 1: Create Custom Policy**

1. Click **+ Create auto-labeling policy**
2. Category: **Custom**
3. Regulation: **Custom policy**

**Step 2: Name Your Policy**

| Field | Value |
|-------|-------|
| Name | `GC-AutoLabel-Custom-ProtectedB-Comprehensive` |
| Description | `Custom policy combining all Canadian sensitive information types for comprehensive Protected B detection. Complements OOB templates with organization-specific rules.` |

**Step 3: Choose Locations**

- [x] Exchange email
- [x] SharePoint sites
- [x] OneDrive accounts
- [x] Teams chat and channel messages
- [x] Devices

**Step 4: Define Custom Policy Rules**

**Create the following custom rules:**

---

**Rule 1: SIN Detection - Any Instance**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Canada SIN - Any Detection` |
| Conditions | Content contains sensitive info types |
| | Canada Social Insurance Number (High confidence, Min 1) |
| Actions | Apply label automatically |
| | Send policy tip to user |
| | Generate alert |

---

**Rule 2: Combined Canadian PII - Multiple Elements**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Combined Canadian PII` |
| Conditions | Content contains ANY of: |
| | - Canada SIN (Min 1) |
| | - Canada PHIN (Min 1) |
| | - Canada Health Service Number (Min 1) |
| | - Canada Driver's License (Min 1) |
| | - Canada Passport (Min 1) |
| | - Canada Bank Account (Min 1) |
| | - Credit Card Number (Min 1) |
| Actions | Apply label automatically |
| | Send notification to user |

---

**Rule 3: High Volume Detection - Critical Alert**

| Setting | Configuration |
|---------|--------------|
| Rule name | `High Volume PII - Critical` |
| Conditions | Content contains 5+ instances of ANY Canadian SIT |
| Actions | Apply label automatically |
| | Block external sharing |
| | Generate high-severity alert |
| | Require justification to override |

---

**Rule 4: Internal Sharing with PII**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Internal PII Sharing` |
| Conditions | Content contains ANY Canadian PII SIT |
| | AND content shared with people inside organization |
| Actions | Apply label automatically |
| | Send policy tip (awareness only) |

---

**Step 5: Choose Label to Apply**

- Select: **GC-Protected-B** (parent label)
- This ensures content gets the base Protected B label if no more specific sublabel applies

**Step 6: Additional Settings**

| Setting | Value |
|---------|-------|
| If existing label | Don't override if higher priority |
| Priority | Set higher than OOB templates (they apply sublabels) |

**Step 7: Policy Mode**

1. **Simulation mode** for 14 days
2. Review all matched items
3. Adjust rules based on false positives
4. Enable when validated

---

### 7.12 Auto-Labeling Policy Summary

After implementing all policies, you should have:

| # | Policy Name | Category | Label Applied |
|---|-------------|----------|---------------|
| 1 | GC-AutoLabel-Financial-CanadaFinancialData | Financial | GC-Protected-B-Financial |
| 2 | GC-AutoLabel-Financial-PCIDSS | Financial | GC-Protected-B-Financial |
| 3 | GC-AutoLabel-Health-CanadaHIA | Medical/Health | GC-Protected-B-Health |
| 4 | GC-AutoLabel-Health-CanadaPHIPA-Ontario | Medical/Health | GC-Protected-B-Health |
| 5 | GC-AutoLabel-Health-CanadaPHIA-Manitoba | Medical/Health | GC-Protected-B-Health |
| 6 | GC-AutoLabel-Privacy-CanadaPIPA | Privacy | GC-Protected-B-Personal |
| 7 | GC-AutoLabel-Privacy-CanadaPIPEDA | Privacy | GC-Protected-B-Personal |
| 8 | GC-AutoLabel-Privacy-CanadaPII | Privacy | GC-Protected-B-Personal |
| 9 | GC-AutoLabel-Custom-ProtectedB-Comprehensive | Custom | GC-Protected-B |

**Total: 9 Policies covering all Canadian regulatory requirements**

---

### 7.13 Simulation Mode Best Practices

**Before enabling any policy:**

1. **Run in simulation mode for minimum 7-14 days**
2. Review simulation results:
   - Navigate to: Policy > View simulation
   - Check total items matched
   - Review items by location
   - Examine sample content for false positives

3. **Analyze results:**
   - If >10% false positives: Adjust confidence levels or add exclusions
   - If low match rate: Verify SITs are configured correctly
   - Document findings for compliance records

4. **Enable policies in phases:**
   - Week 1: Enable Financial policies
   - Week 2: Enable Health policies
   - Week 3: Enable Privacy policies
   - Week 4: Enable Custom comprehensive policy

---

## 8. Data Loss Prevention (DLP) Policies

### 8.1 DLP Policy Strategy

DLP policies complement auto-labeling by providing real-time protection and user notifications. Use the same OOB templates for consistency.

### 8.2 Create DLP Policies from Canadian Templates

**Navigate to:** Microsoft Purview Portal > Data Loss Prevention > Policies > **Create policy**

**Implement DLP policies for each category:**

| DLP Policy | Template | Actions |
|------------|----------|---------|
| GC-DLP-Financial-CanadaFinancialData | Canada Financial Data | Notify, Block external (high count) |
| GC-DLP-Financial-PCIDSS | PCI DSS | Notify, Block external (high count) |
| GC-DLP-Health-CanadaHIA | Canada HIA | Notify, Block external (high count) |
| GC-DLP-Privacy-CanadaPIPEDA | Canada PIPEDA | Notify, Block external (high count) |
| GC-DLP-Privacy-CanadaPII | Canada PII | Notify, Block external (high count) |
| GC-DLP-Custom-ProtectedB | Custom | Full protection suite |

### 8.3 Custom DLP Policy for Protected B

**Create comprehensive custom DLP policy:**

**Step 1: Policy Details**

| Field | Value |
|-------|-------|
| Name | `GC-DLP-Custom-ProtectedB-Protection` |
| Description | `Comprehensive DLP policy for Protected B information with user notifications, alerts, and blocking` |

**Step 2: Locations**

| Location | Enable |
|----------|--------|
| Exchange email | Yes |
| SharePoint sites | Yes |
| OneDrive accounts | Yes |
| Teams chat and channels | Yes |
| Devices | Yes |
| Power BI | Yes |

**Step 3: Define Rules**

**Rule 1: Protected B - Awareness (Low Volume)**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Protected B - Low Volume Alert` |
| Conditions | Content contains 1-9 instances of ANY: |
| | - Canada SIN (High confidence) |
| | - Canada PHIN |
| | - Canada Health Service Number |
| | - Credit Card Number |
| | - Canada Bank Account Number |
| Actions | **User notifications enabled** |
| | Display policy tip to user |
| | Send incident report to admins |
| Severity | Low |

**Rule 2: Protected B - Block External (High Volume)**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Protected B - High Volume Block` |
| Conditions | Content contains 10+ instances of ANY Canadian SIT |
| | OR content labeled "GC-Protected-B" (any sublabel) |
| | AND shared with people outside organization |
| Actions | **Block external sharing** |
| | Display blocking policy tip |
| | Notify user with justification option |
| | Send incident report |
| | Generate alert |
| User override | Allow with business justification |
| Severity | High |

**Rule 3: SIN Specific - Critical Protection**

| Setting | Configuration |
|---------|--------------|
| Rule name | `SIN Detection - Immediate Alert` |
| Conditions | Content contains 1+ Canada SIN (High confidence) |
| | AND shared externally or to unmanaged device |
| Actions | **Block immediately** |
| | Display blocking banner |
| | Require manager approval to override |
| | Generate critical alert |
| User override | Only with manager approval |
| Severity | Critical |

**Rule 4: Label-Based Protection**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Protected B Label - External Block` |
| Conditions | Content has sensitivity label: GC-Protected-B (or any sublabel) |
| | AND content shared with people outside organization |
| Actions | Block sharing |
| | Display policy tip |
| | Require justification |
| | Generate alert |

---

## 9. User Notifications, Banners, and Alerts

### 9.1 Policy Tip Configuration

**Purpose:** Show users real-time banners/tips when sensitive content is detected, prompting them to apply the appropriate label.

**Configuring Policy Tips in DLP:**

1. Navigate to DLP Policy > Edit rule
2. Under **User notifications**, enable:
   - [x] **Notify users in Office 365 service with a policy tip**
3. Configure policy tip text:

**Example Policy Tip Messages:**

| Scenario | Policy Tip Text |
|----------|-----------------|
| SIN Detected | `⚠️ This document appears to contain a Social Insurance Number (SIN). This is Protected B information. Please apply the "Protected B - Personal Information" label before sharing.` |
| Health Info Detected | `⚠️ Health information detected (Health Card/PHIN). This content requires Protected B classification under HIA/PHIPA/PHIA. Please review and apply the "Protected B - Health" label.` |
| Financial Data | `⚠️ Financial account information detected (Credit Card/Bank Account). Apply "Protected B - Financial" label to ensure proper protection.` |
| External Share Attempt | `🚫 You are attempting to share Protected B information externally. This action is blocked. Please remove sensitive content or obtain manager approval.` |
| General PII | `⚠️ Canadian personal information detected. Please review the content and apply the appropriate Protected B label (Personal, Financial, or Health).` |

### 9.2 Custom Policy Tip HTML

For enhanced policy tips with actionable guidance:

```html
<div style="border-left: 4px solid #FF6600; padding: 10px; background: #FFF3E0;">
  <p style="color: #FF6600; font-weight: bold; margin: 0;">
    ⚠️ Protected B Information Detected
  </p>
  <p style="margin: 10px 0;">
    This document contains sensitive Canadian personal information that requires 
    protection under PIPEDA and government security policies.
  </p>
  <p style="font-weight: bold; margin: 10px 0 5px 0;">Required Actions:</p>
  <ul style="margin: 0; padding-left: 20px;">
    <li>Apply the appropriate <strong>Protected B</strong> sensitivity label</li>
    <li>Review recipients before sharing</li>
    <li>Do not forward to external parties without approval</li>
  </ul>
  <p style="margin-top: 10px;">
    <a href="https://[intranet]/data-classification" style="color: #0070C0;">
      Learn more about data classification →
    </a>
  </p>
</div>
```

### 9.3 Email Notifications to Users

**Configure email notifications when DLP policy triggers:**

1. In DLP rule, enable: **Notify users with email**
2. Select notification recipients:
   - [x] The person who sent, shared, or last modified the content
   - [x] Owner of the SharePoint site or OneDrive account
   - [ ] Specific people (security team)

**Email Template:**

```
Subject: Action Required: Protected B Information Detected - [FileName]

Dear [UserName],

Our data protection system has detected that the following document may contain 
Protected B information that requires classification:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Document: [FileName]
Location: [Location]
Detection Type: [SensitiveInfoType]
Detection Time: [DateTime]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQUIRED ACTIONS:
1. Review the document content for sensitive information
2. Apply the appropriate sensitivity label:
   • Protected B - Personal (SIN, passport, driver's license)
   • Protected B - Financial (credit cards, bank accounts)
   • Protected B - Health (health cards, medical records)
3. Ensure the document is not shared with unauthorized recipients

If you believe this detection is incorrect, you may:
• Override with documented business justification
• Contact the Security Team at security@[domain].gc.ca

For guidance on data classification:
https://[intranet]/data-classification

Thank you for helping protect Government of Canada sensitive information.

Information Protection Team
Government of Canada
```

### 9.4 In-App Banners (Office Applications)

**Banner Behavior in Office Apps:**

| Application | Banner Location | Trigger | User Action Required |
|-------------|-----------------|---------|---------------------|
| Word/Excel/PowerPoint | Information bar below ribbon | Sensitive content detected | Apply label or dismiss with reason |
| Outlook | Message bar above email body | Before sending | Apply label or remove sensitive content |
| Teams | Chat warning | Before posting | Acknowledge warning |
| SharePoint | Document card warning | On hover/open | Apply label |

**Mandatory Labeling Banner:**

When mandatory labeling is enabled, Office apps show:

```
┌──────────────────────────────────────────────────────────────────────┐
│ ⚠️ A sensitivity label is required for this document.                │
│    Select a label from the Sensitivity menu before saving or sharing.│
│                                                 [Select Label ▼]     │
└──────────────────────────────────────────────────────────────────────┘
```

**Sensitive Content Detection Banner:**

```
┌──────────────────────────────────────────────────────────────────────┐
│ ⚠️ Protected B content detected: Social Insurance Number found       │
│    This document should be labeled "Protected B - Personal"          │
│                                                                      │
│    [Apply Label]  [More Info]  [Dismiss]                            │
└──────────────────────────────────────────────────────────────────────┘
```

### 9.5 Justification Dialog

When users attempt to downgrade or remove a label:

**Dialog Configuration:**

```
┌──────────────────────────────────────────────────────────────────────┐
│  Justification Required                                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  You are changing the sensitivity label from:                        │
│  "Protected B - Personal" → "Unclassified - Internal"               │
│                                                                      │
│  This action may reduce the protection on this content.              │
│                                                                      │
│  Please provide a business justification:                            │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                                                                 │ │
│  │                                                                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Reason:                                                             │
│  ○ The previous label was applied incorrectly                       │
│  ○ The content no longer contains sensitive information             │
│  ○ Manager approved this change                                     │
│  ○ Other: ________________                                          │
│                                                                      │
│               [Submit Justification]    [Cancel]                     │
└──────────────────────────────────────────────────────────────────────┘
```

### 9.6 Alert Configuration for Security Team

**Configure alerts in Microsoft Defender portal:**

| Alert Type | Trigger | Severity | Recipients |
|------------|---------|----------|------------|
| SIN Detected - External Share | Any SIN shared externally | Critical | Security Team, Manager |
| High Volume PII | 10+ PII instances | High | Security Team |
| Label Downgrade | Protected B → lower | Medium | Security Team |
| Label Removed | Any Protected label removed | High | Security Team |
| Policy Override | User overrides block | Medium | Security Team |

**Alert Dashboard Location:** Microsoft Defender Portal > Alerts

---

## 10. Power Platform Integration

### 10.1 Overview

Microsoft Purview integrates with Power Platform to:

- Apply sensitivity labels to Dataverse data
- Enforce DLP policies in Power Apps
- Monitor data access and usage
- Classify columns based on content

### 10.2 Register Dataverse in Purview Data Map

**Prerequisites:**

- Microsoft 365 E5 license or Purview pay-as-you-go
- Purview Data Map enabled
- Power Platform admin permissions

**Steps:**

1. Navigate to: Microsoft Purview Portal > Data Map > Sources
2. Select **Register** > **Power Platform** > **Dataverse**
3. Provide connection details:
   - Environment URL
   - Authentication method (Service Principal recommended)
4. Grant Purview Data Reader access to Dataverse

### 10.3 Scan Dataverse for Sensitive Information

**Configure Scan:**

1. Select registered Dataverse source
2. Create new scan
3. Configure scan settings:

| Setting | Configuration |
|---------|--------------|
| Scan name | `GC-Dataverse-Scan` |
| Tables | All tables or specific selection |
| Credential | Service principal |
| Scan frequency | Weekly |
| Classification | Enable all Canadian SITs |

**Scan Results:**

- Classifications applied to columns
- Sensitivity labels assigned based on auto-labeling policy
- View in Purview Data Catalog

### 10.4 Power BI Sensitivity Labels

**Enable labels in Power BI:**

1. Power BI Admin Portal > Tenant Settings
2. Enable: **Information protection**
3. Configure:
   - Allow users to apply sensitivity labels
   - Apply default label to new content
   - Restrict users from changing labels

**Label inheritance:**

- Labels flow from data sources to reports
- Protected B data in Dataverse → Protected B report in Power BI

---

## 11. Dashboard and Reporting

### 11.1 Microsoft Purview Dashboards

**Access:** Microsoft Purview Portal > Solutions > Information Protection > Overview

**Available Reports:**

| Report | Purpose | Key Metrics |
|--------|---------|-------------|
| **Data Overview** | Summary of labeled content | Labels applied, content by location |
| **Activity Explorer** | Detailed activity tracking | Label changes, who/when/what |
| **Content Explorer** | Browse labeled content | Items by label, location, type |
| **Label Analytics** | Label usage trends | Adoption rates, label distribution |

### 11.2 Activity Explorer

**Purpose:** Monitor sensitivity label activities across your organization.

**Access:** Data Classification > Activity Explorer

**Key Filters for Canadian Compliance:**

| Filter | Use Case |
|--------|----------|
| Sensitivity label | Filter by GC-Protected-B labels |
| Sensitive info type | Filter by Canada SIN, PHIN, etc. |
| Activity type | Label applied, changed, removed |
| Location | SharePoint, OneDrive, Exchange |
| User | Track individual user activity |

**Key Activities to Monitor:**

| Activity | What It Shows | Alert Priority |
|----------|---------------|----------------|
| Sensitivity label applied | New labels on content | Low |
| Sensitivity label changed | Upgrades or downgrades | Medium (downgrade) |
| Sensitivity label removed | Labels stripped | High |
| DLP policy matched | Sensitive content detected | Medium-High |
| File shared externally | External sharing events | High |

### 11.3 DLP Reports

**Access:** Data Loss Prevention > Reports

**Key Reports for Canadian Compliance:**

| Report | Content |
|--------|---------|
| **DLP policy matches by template** | Canada Financial, HIA, PIPEDA matches |
| **DLP incidents by SIT** | Canada SIN, PHIN detections |
| **User override summary** | Justifications provided |
| **False positive rate** | Policy tuning metrics |

### 11.4 Interpreting Dashboard Metrics

**Compliance Targets:**

| Metric | Target | Action if Not Met |
|--------|--------|-------------------|
| Protected B label adoption | >90% of sensitive content | Review auto-labeling policies |
| DLP policy match rate | Declining over time | Indicates improved user behavior |
| External share blocks | Low volume | Effective policy |
| Label downgrade rate | <5% | Review justifications |

---

## 12. Implementation Checklist

### Phase 1: Foundation (Days 1-7)

- [ ] Verify licensing requirements (E5 for auto-labeling)
- [ ] Assign compliance administrator roles
- [ ] Enable unified audit logging
- [ ] Access Microsoft Purview portal

### Phase 2: Label Creation (Days 8-14)

- [ ] Create GC-Unclassified labels (Public, Internal)
- [ ] Create GC-Protected-A label
- [ ] Create GC-Protected-B label
- [ ] Create Protected B sublabels (Personal, Financial, Health)
- [ ] Configure label protection settings
- [ ] Set label priority order
- [ ] Test labels in pilot group

### Phase 3: Label Policy Deployment (Days 15-21)

- [ ] Create label publishing policy
- [ ] Configure mandatory labeling
- [ ] Enable justification requirements
- [ ] Deploy to pilot group
- [ ] Collect feedback

### Phase 4: OOB Auto-Labeling - Financial (Days 22-28)

- [ ] Create Canada Financial Data policy (simulation mode)
- [ ] Create PCI DSS policy (simulation mode)
- [ ] Run simulation for 7 days
- [ ] Review results and adjust
- [ ] Enable policies

### Phase 5: OOB Auto-Labeling - Health (Days 29-35)

- [ ] Create Canada HIA policy (simulation mode)
- [ ] Create Canada PHIPA policy (simulation mode)
- [ ] Create Canada PHIA policy (simulation mode)
- [ ] Run simulation for 7 days
- [ ] Review results and adjust
- [ ] Enable policies

### Phase 6: OOB Auto-Labeling - Privacy (Days 36-42)

- [ ] Create Canada PIPA policy (simulation mode)
- [ ] Create Canada PIPEDA policy (simulation mode)
- [ ] Create Canada PII policy (simulation mode)
- [ ] Run simulation for 7 days
- [ ] Review results and adjust
- [ ] Enable policies

### Phase 7: Custom Protected B Policy (Days 43-49)

- [ ] Create custom comprehensive Protected B policy
- [ ] Define all custom rules
- [ ] Run simulation for 14 days
- [ ] Review for false positives
- [ ] Adjust rules as needed
- [ ] Enable policy

### Phase 8: DLP Policies (Days 50-56)

- [ ] Create DLP policies from OOB templates
- [ ] Create custom Protected B DLP policy
- [ ] Configure policy tips and notifications
- [ ] Run in simulation mode
- [ ] Enable blocking rules

### Phase 9: Power Platform Integration (Days 57-63)

- [ ] Register Dataverse in Purview Data Map
- [ ] Configure Dataverse scan
- [ ] Enable sensitivity labels in Power BI
- [ ] Test label inheritance

### Phase 10: Monitoring and Optimization (Ongoing)

- [ ] Configure Activity Explorer dashboards
- [ ] Set up executive reporting
- [ ] Create alert rules for security team
- [ ] Establish weekly review cadence
- [ ] Plan quarterly policy reviews

---

## 13. Reference Documentation

### Microsoft Documentation

| Topic | URL |
|-------|-----|
| Sensitivity Labels Overview | `learn.microsoft.com/en-us/purview/sensitivity-labels` |
| Create Sensitivity Labels | `learn.microsoft.com/en-us/purview/create-sensitivity-labels` |
| DLP Policy Templates | `learn.microsoft.com/en-us/purview/dlp-policy-templates-include` |
| Auto-labeling Policies | `learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically` |
| DLP Policy Tips | `learn.microsoft.com/en-us/purview/dlp-use-notifications-and-policy-tips` |
| Activity Explorer | `learn.microsoft.com/en-us/purview/data-classification-activity-explorer` |
| Canada SIN SIT | `learn.microsoft.com/en-us/purview/sit-defn-canada-social-insurance-number` |
| Canada Health Number SIT | `learn.microsoft.com/en-us/purview/sit-defn-canada-health-service-number` |
| Canada PHIN SIT | `learn.microsoft.com/en-us/purview/sit-defn-canada-personal-health-identification-number` |

### Canadian Government References

| Topic | Source |
|-------|--------|
| OPC Sensitive Information Guidance | `priv.gc.ca/en/privacy-topics/privacy-laws-in-canada/pipeda-interpretation-bulletins/interpretations_10_sensible/` |
| Government Security Classifications | Treasury Board Secretariat |
| PIPEDA Requirements | Office of the Privacy Commissioner |
| Provincial Health Acts | HIA, PHIPA, PHIA |

### PowerShell Quick Reference

```powershell
# Connect to Purview/Compliance PowerShell
Install-Module -Name ExchangeOnlineManagement
Connect-IPPSSession

# List sensitivity labels
Get-Label | Select-Object DisplayName, Priority, IsActive

# List auto-labeling policies
Get-AutoSensitivityLabelPolicy | Select-Object Name, Mode, Enabled

# List DLP policies
Get-DlpCompliancePolicy | Select-Object Name, Mode, Enabled

# Export activity data
Export-ActivityExplorerData -StartTime (Get-Date).AddDays(-30) -EndTime (Get-Date) -OutputFormat JSON
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | SSC/TBS Working Group | Initial buildbook |
| 2.0 | December 2025 | SSC/TBS Working Group | Added OOB Canadian templates (Financial, Health, Privacy), Custom Protected B policy, enhanced implementation checklist |

**Review Schedule:** Quarterly or as required by regulatory changes  
**Next Review Date:** March 2026  
**Approval Authority:** Chief Information Officer

**Document Classification:** Protected B  
**Authority:** Shared Services Canada (SSC) & Treasury Board Secretariat (TBS)

---

## Appendix A: Quick Reference Card

### OOB Template Selection Guide

| If You Need To Protect... | Use Template | Category |
|---------------------------|--------------|----------|
| Credit cards, bank accounts | Canada Financial Data | Financial |
| Payment card data (PCI compliance) | PCI DSS | Financial |
| Health information (federal) | Canada HIA | Medical/Health |
| Health information (Ontario) | Canada PHIPA | Medical/Health |
| Health information (Manitoba) | Canada PHIA | Medical/Health |
| Personal information (Alberta/BC) | Canada PIPA | Privacy |
| Personal information (federal) | Canada PIPEDA | Privacy |
| General Canadian PII | Canada PII | Privacy |
| Comprehensive Protected B | Custom policy | Custom |

### Label Selection Guide

| Content Type | Recommended Label |
|-------------|-------------------|
| Press release, public website | GC-Unclassified-Public |
| Internal meeting notes | GC-Unclassified-Internal |
| Business plans, org charts | GC-Protected-A |
| Documents with SIN, passport, DL | GC-Protected-B-Personal |
| Credit cards, bank accounts | GC-Protected-B-Financial |
| Health cards, medical records | GC-Protected-B-Health |
| Security assessments | GC-Protected-B |

### Policy Tip Quick Actions

| When You See | Do This |
|--------------|---------|
| "SIN detected" | Apply Protected B - Personal label |
| "Health information detected" | Apply Protected B - Health label |
| "Financial data detected" | Apply Protected B - Financial label |
| "Label required" | Select appropriate label from menu |
| "External sharing blocked" | Get approval or remove sensitive content |

### Contact Information

| Issue | Contact |
|-------|---------|
| Technical support | IT Help Desk |
| Policy questions | Information Protection Team |
| Security incidents | security@[domain].gc.ca |
| Training requests | training@[domain].gc.ca |