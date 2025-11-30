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

# Annex B: Platform-Specific Sensitivity Label Implementation Guide

## Microsoft Purview Information Protection Buildbook
### Canadian Federal Government - Sensitivity Labels and Policies

**Document Version:** 2.0  
**Annex Version:** 1.0  
**Effective Date:** December 2025  
**Classification:** Protected B

---

## Table of Contents

- [B.1 Overview](#b1-overview)
- [B.2 Microsoft 365 Office Applications](#b2-microsoft-365-office-applications)
- [B.3 Microsoft Outlook (Email)](#b3-microsoft-outlook-email)
- [B.4 SharePoint Online](#b4-sharepoint-online)
- [B.5 OneDrive for Business](#b5-onedrive-for-business)
- [B.6 Microsoft Teams](#b6-microsoft-teams)
- [B.7 Microsoft 365 Groups](#b7-microsoft-365-groups)
- [B.8 Power BI / Microsoft Fabric](#b8-power-bi--microsoft-fabric)
- [B.9 Power Platform - Dataverse](#b9-power-platform---dataverse)
- [B.10 Power Apps](#b10-power-apps)
- [B.11 Power Automate](#b11-power-automate)
- [B.12 Copilot Studio](#b12-copilot-studio)
- [B.13 Windows Endpoints](#b13-windows-endpoints)
- [B.14 Mobile Devices (iOS/Android)](#b14-mobile-devices-iosandroid)
- [B.15 Verification and Testing](#b15-verification-and-testing)
- [B.16 Troubleshooting Guide](#b16-troubleshooting-guide)

---

## B.1 Overview

### B.1.1 Purpose

This annex provides detailed, step-by-step instructions for implementing sensitivity labels across all Microsoft platforms. Each section covers prerequisites, configuration steps, user experience, and verification procedures.

### B.1.2 Label Scope Requirements

Sensitivity labels must be configured with appropriate scopes to function across different platforms:

| Platform | Required Label Scope |
|----------|---------------------|
| Office Apps (Word, Excel, PowerPoint) | Files & other data assets |
| Outlook | Emails |
| SharePoint/OneDrive | Files & other data assets |
| Teams (Files) | Files & other data assets |
| Teams (Meetings) | Meetings |
| Teams/SharePoint (Sites) | Groups & Sites |
| Microsoft 365 Groups | Groups & Sites |
| Power BI | Files & other data assets |
| Dataverse | Files & other data assets (Data Map) |

### B.1.3 Implementation Order

**Recommended implementation sequence:**

```
Phase 1: Core M365
├── 1.1 Enable labels for SharePoint/OneDrive
├── 1.2 Deploy to Office applications
├── 1.3 Configure Outlook
└── 1.4 Enable Teams integration

Phase 2: Collaboration
├── 2.1 Enable Groups & Sites labels
├── 2.2 Configure SharePoint site labels
├── 2.3 Configure Teams team labels
└── 2.4 Configure meeting labels

Phase 3: Analytics & BI
├── 3.1 Enable Power BI labels
├── 3.2 Configure inheritance settings
└── 3.3 Enable protection metrics

Phase 4: Power Platform
├── 4.1 Register Dataverse in Purview Data Map
├── 4.2 Configure Dataverse scanning
├── 4.3 Enable auto-labeling for Dataverse
└── 4.4 Configure Copilot Studio visibility
```

---

## B.2 Microsoft 365 Office Applications

### B.2.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| Licenses | Microsoft 365 E3/E5, Office 365 E3/E5 |
| Office Version | Microsoft 365 Apps (Version 1910+) |
| Authentication | Users signed in with M365 work account |
| Labels Published | Labels published via label policy |

### B.2.2 Supported Applications

| Application | Windows | Mac | Web | Mobile |
|-------------|---------|-----|-----|--------|
| Word | ✅ | ✅ | ✅ | ✅ |
| Excel | ✅ | ✅ | ✅ | ✅ |
| PowerPoint | ✅ | ✅ | ✅ | ✅ |
| Visio | ✅ | ❌ | ✅ | ❌ |

### B.2.3 Configuration Steps

**Step 1: Verify Label Policy Publication**

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession

# List published label policies
Get-LabelPolicy | Select-Object Name, Mode, Enabled

# Verify labels in policy
Get-LabelPolicy -Identity "GC-Standard-Policy" | Select-Object -ExpandProperty Labels
```

**Step 2: Configure Office Group Policy (Optional)**

For managed environments, use Group Policy to ensure consistent behavior:

| Policy Setting | Path | Recommended Value |
|---------------|------|-------------------|
| Use the Sensitivity feature | User Configuration > Administrative Templates > Microsoft Office > Security Settings | Enabled |
| Disable the Sensitivity bar | (same path) | Not Configured (leave enabled) |

**Step 3: Verify Client Configuration**

1. Open Word/Excel/PowerPoint
2. Sign in with M365 account
3. Navigate to: **Home** > **Sensitivity** button
4. Verify GC labels appear in dropdown

### B.2.4 User Experience

**Applying Labels in Office Apps:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  File    Home    Insert    Design    Layout    References    ...    │
├─────────────────────────────────────────────────────────────────────┤
│  [Sensitivity ▼]                                                    │
│  ┌─────────────────────────────────────┐                           │
│  │ GC - Unclassified                   │                           │
│  │   ├── Public                        │                           │
│  │   └── Internal                      │                           │
│  │ GC - Protected                      │                           │
│  │   ├── Protected A                   │                           │
│  │   └── Protected B              ◄────┼── Select for PII         │
│  │       ├── Personal Information      │                           │
│  │       ├── Financial                 │                           │
│  │       └── Health Information        │                           │
│  └─────────────────────────────────────┘                           │
└─────────────────────────────────────────────────────────────────────┘
```

**Status Bar Display:**

After applying a label, it appears in the status bar:

```
┌─────────────────────────────────────────────────────────────────────┐
│ Page 1 of 3  │  1234 Words  │  🔒 Protected B - Personal Info     │
└─────────────────────────────────────────────────────────────────────┘
```

### B.2.5 Content Markings

When labels with content markings are applied:

| Marking Type | Location | Example |
|--------------|----------|---------|
| Header | Top of each page | `PROTECTED B` |
| Footer | Bottom of each page | `Government of Canada - Protected B - Do Not Distribute Externally` |
| Watermark | Diagonal across page | `PROTECTED B` (light gray) |

### B.2.6 Supported File Types

| Extension | Auto-label | Manual Label | Encryption |
|-----------|------------|--------------|------------|
| .docx, .docm | ✅ | ✅ | ✅ |
| .xlsx, .xlsm | ✅ | ✅ | ✅ |
| .pptx, .pptm | ✅ | ✅ | ✅ |
| .pdf | ✅ | ✅ | ✅ |
| .txt | ❌ | ❌ | ❌ |
| .csv | ❌ | ❌ | ❌ |

---

## B.3 Microsoft Outlook (Email)

### B.3.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| Client | Outlook 2016+, Outlook for Mac, Outlook on the web |
| Labels | Published with "Emails" scope selected |
| License | Microsoft 365 E3/E5 |

### B.3.2 Configuration Steps

**Step 1: Verify Email Scope in Labels**

```powershell
# Check label scope includes email
Get-Label -Identity "GC-Protected-B" | Select-Object Name, ContentType

# Output should include: Email
```

**Step 2: Configure Label Policy for Email**

```powershell
# Set default label for emails
Set-LabelPolicy -Identity "GC-Standard-Policy" `
    -AdvancedSettings @{OutlookDefaultLabel="GC-Unclassified-Internal"}
```

**Step 3: Enable Mandatory Labeling for Email**

In Purview Portal:
1. Navigate to: Information Protection > Label policies
2. Edit policy > Policy settings
3. Enable: **Require users to apply a label to their emails**

### B.3.3 User Experience

**Composing New Email:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  New Email                                                          │
├─────────────────────────────────────────────────────────────────────┤
│  To: [recipient@example.gc.ca                              ]        │
│  Cc: [                                                     ]        │
│  Subject: [Q4 Budget Report                                ]        │
├─────────────────────────────────────────────────────────────────────┤
│  [Sensitivity: Protected B - Financial ▼]  ← Label selector        │
├─────────────────────────────────────────────────────────────────────┤
│  ⚠️ This email is classified as Protected B. External recipients   │
│     will receive encrypted content.                          [X]   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Please find attached the Q4 budget report...                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### B.3.4 Email Encryption Behavior

| Label Setting | Internal Recipients | External Recipients |
|--------------|--------------------|--------------------|
| No encryption | Normal delivery | Normal delivery |
| Encrypt (org only) | Normal delivery | Blocked or OME portal |
| Encrypt (all authenticated) | Normal delivery | OME portal access |

### B.3.5 Outlook-Specific Settings

**PowerShell Advanced Settings:**

```powershell
# Configure Outlook-specific behaviors
Set-LabelPolicy -Identity "GC-Standard-Policy" -AdvancedSettings @{
    # Warn when sending Protected B externally
    OutlookWarnUntrustedCollaborationLabel = "GC-Protected-B,GC-Protected-B-Personal,GC-Protected-B-Financial,GC-Protected-B-Health"
    
    # Block Protected B to external
    OutlookBlockUntrustedCollaborationLabel = "GC-Protected-B,GC-Protected-B-Personal,GC-Protected-B-Financial,GC-Protected-B-Health"
    
    # Justify sending to external
    OutlookJustifyUntrustedCollaborationLabel = "GC-Protected-B"
}
```

---

## B.4 SharePoint Online

### B.4.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| License | SharePoint Online (E3/E5) |
| Admin Role | SharePoint Administrator |
| Feature | Sensitivity labels enabled for SharePoint |

### B.4.2 Enable Sensitivity Labels for SharePoint

**Step 1: Enable via PowerShell**

```powershell
# Connect to SharePoint Online
Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"

# Enable sensitivity labels
Set-SPOTenant -EnableAIPIntegration $true

# Verify
Get-SPOTenant | Select-Object EnableAIPIntegration
```

**Step 2: Enable via Microsoft 365 Admin Center**

1. Navigate to: admin.microsoft.com
2. Go to: Settings > Org settings > Security & privacy
3. Select: **Sensitivity labels**
4. Enable: **Turn on the ability to process content in Office online files**

### B.4.3 Configure Site-Level Labels (Container Labels)

**Enable Container Labels:**

```powershell
# Connect to Azure AD (required for container labels)
Connect-AzureAD

# Get current settings
$Setting = Get-AzureADDirectorySetting | Where-Object {$_.DisplayName -eq "Group.Unified"}

# If no settings exist, create from template
if (!$Setting) {
    $Template = Get-AzureADDirectorySettingTemplate | Where-Object {$_.DisplayName -eq "Group.Unified"}
    $Setting = $Template.CreateDirectorySetting()
}

# Enable MIP Labels for containers
$Setting["EnableMIPLabels"] = "True"

# Save settings
if ($Setting.Id) {
    Set-AzureADDirectorySetting -Id $Setting.Id -DirectorySetting $Setting
} else {
    New-AzureADDirectorySetting -DirectorySetting $Setting
}
```

**Step 3: Sync Labels to Azure AD**

```powershell
# Connect to Security & Compliance
Connect-IPPSSession

# Sync labels (run this after creating/modifying container labels)
Execute-AzureAdLabelSync
```

### B.4.4 Apply Labels to SharePoint Sites

**Via SharePoint Admin Center:**

1. Navigate to: SharePoint Admin Center > Active sites
2. Select site > Edit > Sensitivity
3. Choose appropriate label

**Via PowerShell:**

```powershell
# Apply label to existing site
Set-SPOSite -Identity "https://[tenant].sharepoint.com/sites/HRConfidential" `
    -SensitivityLabel "GC-Protected-B"

# Bulk apply to multiple sites
$sites = @(
    "https://[tenant].sharepoint.com/sites/Finance",
    "https://[tenant].sharepoint.com/sites/HR",
    "https://[tenant].sharepoint.com/sites/Legal"
)

foreach ($site in $sites) {
    Set-SPOSite -Identity $site -SensitivityLabel "GC-Protected-B-Financial"
    Write-Host "Applied label to: $site"
}
```

### B.4.5 Default Labels for Document Libraries

**Configure default label for new documents:**

1. Navigate to SharePoint site > Document library
2. Select: Settings (gear) > Library settings
3. Select: **Default sensitivity labels**
4. Choose: **GC-Protected-B** (or appropriate sublabel)

**Via PowerShell:**

```powershell
# Set default label for document library
# Requires PnP PowerShell
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/HRConfidential" -Interactive

Set-PnPList -Identity "Documents" -DefaultSensitivityLabelForLibrary "GC-Protected-B-Personal"
```

### B.4.6 SharePoint User Experience

**Document Library View:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  HR Documents                                          [+ New ▼]   │
├─────────────────────────────────────────────────────────────────────┤
│  Name                    │ Modified      │ Sensitivity             │
├─────────────────────────────────────────────────────────────────────┤
│  📄 Employee_Records.xlsx │ Dec 1, 2025  │ 🔒 Protected B-Personal │
│  📄 Budget_2025.xlsx      │ Nov 28, 2025 │ 🔒 Protected B-Financial│
│  📄 Meeting_Notes.docx    │ Nov 25, 2025 │ 📋 Internal             │
│  📄 Policy_Draft.docx     │ Nov 20, 2025 │ 🔒 Protected B          │
└─────────────────────────────────────────────────────────────────────┘
```

**Details Pane:**

```
┌─────────────────────────────┐
│  Employee_Records.xlsx      │
├─────────────────────────────┤
│  Sensitivity                │
│  ┌─────────────────────────┐│
│  │ 🔒 Protected B-Personal ││
│  │    [Change ▼]           ││
│  └─────────────────────────┘│
│                             │
│  Modified: Dec 1, 2025      │
│  Modified by: John Smith    │
│  Size: 245 KB               │
└─────────────────────────────┘
```

---

## B.5 OneDrive for Business

### B.5.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| License | OneDrive for Business |
| Sync Client | OneDrive sync app v19.002+ |
| Feature | Same as SharePoint (enabled together) |

### B.5.2 Configuration

OneDrive inherits sensitivity label configuration from SharePoint. When you enable sensitivity labels for SharePoint, they are automatically enabled for OneDrive.

**Verify OneDrive Sync Client:**

```powershell
# Check OneDrive sync client version
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\OneDrive" | Select-Object Version
# Required: 19.002.0121.0008 or later
```

### B.5.3 User Experience

**OneDrive Web Interface:**

Users can apply labels the same way as SharePoint:
1. Select file
2. Open Details pane (i icon)
3. Under Sensitivity, select label

**OneDrive Sync (Desktop):**

When files are synced locally:
1. Right-click file in File Explorer
2. Select: **Sensitivity** > Choose label

**Note:** Labels applied locally sync to cloud within minutes.

### B.5.4 Auto-Labeling for OneDrive

Service-side auto-labeling applies to OneDrive the same as SharePoint:

1. Create auto-labeling policy in Purview
2. Include OneDrive accounts in scope
3. Define SIT-based rules
4. Run in simulation, then enable

---

## B.6 Microsoft Teams

### B.6.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| License | Microsoft Teams (E3/E5) |
| Container Labels | Enabled (see SharePoint section) |
| Meeting Labels | Teams Premium (optional) |

### B.6.2 Teams Files (Channel Files)

Teams channel files are stored in SharePoint. Labels applied in Teams appear in SharePoint and vice versa.

**Apply label to file in Teams:**

1. Navigate to team > Files tab
2. Select file > More options (...) > Details
3. Under Sensitivity, select label

### B.6.3 Teams Team Labels (Container)

**Apply label when creating team:**

1. Create new team
2. In creation wizard, under **Sensitivity**, select label
3. Label controls: Privacy, external sharing, guest access

**Apply label to existing team:**

1. Select team > More options (...) > Edit team
2. Under Sensitivity, select/change label

**Via PowerShell:**

```powershell
# Connect to Microsoft Teams
Connect-MicrosoftTeams

# Apply sensitivity label to team
Set-Team -GroupId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -SensitivityLabel "GC-Protected-B"
```

### B.6.4 Teams Chat Labels

**Note:** Chat labeling requires Teams Premium and specific configuration.

**Enable chat labels:**

1. In Teams Admin Center > Meetings > Meeting policies
2. Enable sensitivity labels for meetings and chats

### B.6.5 Teams Meetings Labels

**Prerequisites:**
- Teams Premium license
- Labels with "Meetings" scope enabled

**Apply label to meeting:**

1. Create new meeting in Outlook or Teams
2. In meeting options, select Sensitivity label
3. Label can control:
   - Who can bypass lobby
   - Who can present
   - Recording permissions
   - Chat permissions

**Meeting Label Settings:**

| Setting | Configurable via Label |
|---------|----------------------|
| Lobby bypass | ✅ |
| Who can present | ✅ |
| Meeting chat | ✅ |
| Record meetings | ✅ |
| Watermarking | ✅ |
| End-to-end encryption | ✅ |

### B.6.6 User Experience in Teams

**Team Creation:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Create a team                                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Team name: [HR Confidential                           ]            │
│                                                                     │
│  Description: [Human Resources confidential team       ]            │
│                                                                     │
│  Sensitivity:                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 🔒 Protected B - Personal Information              ▼        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ⓘ This team will be Private. External sharing disabled.          │
│    Guest access disabled. Only members can access.                  │
│                                                                     │
│                                        [Cancel]  [Create]           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## B.7 Microsoft 365 Groups

### B.7.1 Overview

Microsoft 365 Groups serve as the foundation for:
- Teams (each team is backed by a Group)
- SharePoint team sites
- Shared mailboxes
- Planner plans

### B.7.2 Configuration

Container labels (Groups & Sites scope) automatically apply to M365 Groups.

**Apply label to Group via PowerShell:**

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline

# Apply label to M365 Group
Set-UnifiedGroup -Identity "HR-Confidential" `
    -SensitivityLabel "GC-Protected-B"

# Verify
Get-UnifiedGroup -Identity "HR-Confidential" | Select-Object DisplayName, SensitivityLabel
```

### B.7.3 Label-Controlled Settings

| Setting | Label Configuration |
|---------|-------------------|
| Privacy (Public/Private) | Set at label creation |
| External sharing | Block or allow |
| Guest access | Block or allow |
| Unmanaged device access | Full, limited, or block |

---

## B.8 Power BI / Microsoft Fabric

### B.8.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| License | Power BI Pro or Premium Per User (PPU) |
| Admin Role | Power BI Administrator |
| Labels | Published with appropriate scope |

### B.8.2 Enable Sensitivity Labels in Power BI

**Step 1: Admin Portal Configuration**

1. Navigate to: app.powerbi.com
2. Select: Settings (gear) > Admin portal
3. Navigate to: Tenant settings > Information protection
4. Configure the following settings:

**Setting 1: Allow users to apply sensitivity labels**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Allow users to apply sensitivity labels for content               │
├─────────────────────────────────────────────────────────────────────┤
│  [Enabled]                                                          │
│                                                                     │
│  Apply to:                                                          │
│  ○ The entire organization                                          │
│  ● Specific security groups                                         │
│    [GC-PowerBI-Users                                    ] [+ Add]   │
│                                                                     │
│  Except specific security groups:                                   │
│    [ ] (none)                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

**Setting 2: Apply sensitivity labels from data sources**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Apply sensitivity labels from data sources to their data in       │
│  Power BI                                                           │
├─────────────────────────────────────────────────────────────────────┤
│  [Enabled]                                                          │
│                                                                     │
│  When enabled, sensitivity labels from supported data sources       │
│  (Azure Synapse Analytics, Azure SQL Database, Excel files in       │
│  OneDrive/SharePoint) will automatically be applied to              │
│  corresponding Power BI datasets.                                   │
└─────────────────────────────────────────────────────────────────────┘
```

**Setting 3: Automatically apply sensitivity labels to downstream content**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Automatically apply sensitivity labels to downstream content       │
├─────────────────────────────────────────────────────────────────────┤
│  [Enabled]                                                          │
│                                                                     │
│  When a sensitivity label is applied or changed on a Fabric item,  │
│  the label is also automatically applied to its dependent items.    │
└─────────────────────────────────────────────────────────────────────┘
```

**Setting 4: Allow workspace admins to override labels**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Allow workspace admins to override automatically applied           │
│  sensitivity labels (preview)                                       │
├─────────────────────────────────────────────────────────────────────┤
│  [Enabled]                                                          │
│                                                                     │
│  Workspace admins can change automatically applied labels without   │
│  requiring RMS label issuer permissions.                            │
└─────────────────────────────────────────────────────────────────────┘
```

### B.8.3 Apply Labels in Power BI Service

**To Datasets:**

1. Navigate to workspace
2. Select dataset > More options (...) > Settings
3. Expand: Sensitivity label
4. Select appropriate label

**To Reports:**

1. Open report
2. Select: File > Settings
3. Under Sensitivity label, select label

**To Dashboards:**

1. Open dashboard
2. Select: More options (...) > Settings
3. Under Sensitivity label, select label

### B.8.4 Apply Labels in Power BI Desktop

**When opening .pbix file:**

1. Open Power BI Desktop
2. Sign in with M365 account
3. Select: Home > Sensitivity (or look in status bar)
4. Choose label from dropdown

**On publish:**

When publishing to Power BI service, the .pbix file's label is applied to both the report and dataset created in the service.

### B.8.5 Label Inheritance

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Label Inheritance Flow                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Data Source (Excel in SharePoint)                                  │
│  Label: Protected B - Financial                                     │
│           │                                                         │
│           ▼                                                         │
│  Power BI Dataset                                                   │
│  Label: Protected B - Financial (inherited)                         │
│           │                                                         │
│           ├────────────────┬────────────────┐                      │
│           ▼                ▼                ▼                      │
│       Report 1         Report 2         Dashboard                  │
│    (Protected B)    (Protected B)    (Protected B)                 │
│           │                                                         │
│           ▼                                                         │
│    Export to Excel                                                  │
│    (Protected B encryption applied)                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### B.8.6 Export Protection

When data is exported from Power BI:

| Export Format | Label Applied | Encryption |
|---------------|--------------|------------|
| Excel (.xlsx) | ✅ | ✅ (if configured) |
| PowerPoint (.pptx) | ✅ | ✅ (if configured) |
| PDF | ✅ | ✅ (if configured) |
| .pbix download | ✅ | ✅ (if configured) |
| CSV | ❌ | ❌ |

### B.8.7 Protection Metrics Report

Access the built-in protection metrics:

1. Admin portal > Protection metrics
2. View:
   - Labeled content by label
   - Labeled content by workspace
   - Users applying labels
   - Label changes over time

---

## B.9 Power Platform - Dataverse

### B.9.1 Overview

Microsoft Purview Data Map integration enables:
- Automatic discovery of Dataverse environments
- Classification of sensitive data in tables/columns
- Application of sensitivity labels to column metadata
- Data lineage tracking

### B.9.2 Prerequisites

| Requirement | Details |
|-------------|---------|
| License | Microsoft Purview (E5 or pay-as-you-go) |
| Dataverse | Licensed environment |
| Permissions | Purview Data Source Administrator, Data Reader |
| Azure | Active subscription |

### B.9.3 Register Dataverse in Purview Data Map

**Step 1: Access Purview Data Map**

1. Navigate to: purview.microsoft.com
2. Select: Data Map > Sources

**Step 2: Register Dataverse Source**

1. Select: **Register** > Search for "Dataverse"
2. Select **Dataverse** and click **Continue**
3. Configure registration:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Register sources (Dataverse)                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Name: [GC-Dataverse-Production                        ]            │
│                                                                     │
│  Environment URL:                                                   │
│  [https://org12345.crm3.dynamics.com                   ]            │
│  (Get from Power Platform Admin Center > Environments > Details)    │
│                                                                     │
│  Select a collection:                                               │
│  [Power Platform                                       ▼]           │
│                                                                     │
│                                        [Cancel]  [Register]         │
└─────────────────────────────────────────────────────────────────────┘
```

**Step 3: Get Environment URL**

1. Navigate to: admin.powerplatform.microsoft.com
2. Select: Environments > [Your Environment]
3. Copy the **Environment URL** (e.g., https://org12345.crm3.dynamics.com)

### B.9.4 Configure Authentication

**Option A: System Assigned Managed Identity (Recommended)**

1. In Purview, go to: Data Map > Sources > [Dataverse source]
2. Select: New scan
3. For Credential, select: **Microsoft Purview MSI (system)**
4. Note the **Managed Identity Application ID**

**Create Application User in Dataverse:**

1. Navigate to: Power Platform Admin Center > Environments
2. Select environment > Settings > Users + permissions > Application users
3. Select: **+ New app user**
4. Configure:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Create a new app user                                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  App: [Select from Azure AD - use Managed Identity App ID]          │
│                                                                     │
│  Business unit: [Root business unit                    ▼]           │
│                                                                     │
│  Security roles:                                                    │
│  [x] Service Reader                                                 │
│                                                                     │
│                                        [Create]                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Option B: Service Principal**

1. Register app in Azure AD
2. Create client secret
3. Create credential in Purview
4. Create Application User in Dataverse with app's Client ID

### B.9.5 Configure and Run Scan

**Step 1: Create Scan**

1. In Data Map, select Dataverse source
2. Select: **New scan**
3. Configure:

| Setting | Value |
|---------|-------|
| Name | GC-Dataverse-Scan-Production |
| Credential | Microsoft Purview MSI (system) |

**Step 2: Scope the Scan**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Scope your scan                                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [x] Select all                                                     │
│      ├── [x] account                                               │
│      ├── [x] contact                                               │
│      ├── [x] gc_citizen_application     (custom table)             │
│      ├── [x] gc_employee_record         (custom table)             │
│      └── [x] systemuser                                            │
│                                                                     │
│  Or use pattern matching:                                           │
│  Include: [gc_*                                        ]            │
│  Exclude: [systemuser                                  ]            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Step 3: Select Classification Rules**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Select a scan rule set                                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Scan rule set: [System default                        ▼]           │
│                                                                     │
│  Classifications included:                                          │
│  [x] Canada Social Insurance Number                                 │
│  [x] Canada Personal Health Identification Number                   │
│  [x] Canada Health Service Number                                   │
│  [x] Canada Bank Account Number                                     │
│  [x] Canada Driver's License Number                                 │
│  [x] Canada Passport Number                                         │
│  [x] Credit Card Number                                             │
│  [x] All Physical Addresses                                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Step 4: Set Scan Schedule**

| Setting | Recommended Value |
|---------|-------------------|
| Frequency | Weekly |
| Day | Sunday |
| Time | 02:00 AM (low usage) |
| Time Zone | Eastern Time (ET) |

**Step 5: Run Scan**

1. Save and run scan
2. Monitor progress in: Data Map > Sources > [source] > Scans
3. Initial scan may take 1-4 hours depending on data volume

### B.9.6 View Classification Results

**In Purview Data Catalog:**

1. Navigate to: Data Catalog > Browse
2. Filter by: Source type = Dataverse
3. Select table to view column classifications

**Classification Display:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  gc_citizen_application (Table)                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Columns:                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Column Name      │ Data Type │ Classification              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │ gc_sin           │ nvarchar  │ 🔒 Canada SIN               │   │
│  │ gc_healthcard    │ nvarchar  │ 🔒 Canada PHIN              │   │
│  │ gc_firstname     │ nvarchar  │ Person Name                 │   │
│  │ gc_address       │ nvarchar  │ Canada Physical Address     │   │
│  │ gc_dateofbirth   │ datetime  │ Date of Birth               │   │
│  │ gc_email         │ nvarchar  │ Email Address               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Sensitivity Label: 🔒 Protected B - Personal Information           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### B.9.7 Configure Auto-Labeling for Dataverse

**Create Auto-Labeling Policy for Data Map:**

1. Navigate to: Purview Portal > Information Protection > Auto-labeling
2. Create policy for **non-Microsoft 365 workloads**
3. Select: Dataverse environments
4. Configure rules based on classifications detected

```
┌─────────────────────────────────────────────────────────────────────┐
│  Auto-labeling policy for Dataverse                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Name: GC-AutoLabel-Dataverse-ProtectedB                            │
│                                                                     │
│  Scope: Non-Microsoft 365 workloads                                 │
│         [x] Dataverse                                               │
│                                                                     │
│  Rule: When column contains classification:                         │
│        - Canada Social Insurance Number                             │
│        - Canada Personal Health Identification Number               │
│        - Canada Health Service Number                               │
│        - Canada Bank Account Number                                 │
│                                                                     │
│  Apply label: GC-Protected-B                                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### B.9.8 Data Lineage

Purview tracks data lineage for Dataverse:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Data Lineage                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐        │
│  │   Dataverse  │────▶│  Dataflow    │────▶│   Power BI   │        │
│  │   Table      │     │  (Transform) │     │   Dataset    │        │
│  │ Protected B  │     │              │     │ Protected B  │        │
│  └──────────────┘     └──────────────┘     └──────────────┘        │
│                                                     │               │
│                                                     ▼               │
│                                            ┌──────────────┐        │
│                                            │   Power BI   │        │
│                                            │    Report    │        │
│                                            │ Protected B  │        │
│                                            └──────────────┘        │
│                                                                     │
│  Label "Protected B" follows data through lineage                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## B.10 Power Apps

### B.10.1 Overview

Power Apps can interact with labeled data through:
- Dataverse tables (labeled via Purview)
- SharePoint lists/libraries (with document labels)
- Files with sensitivity labels

### B.10.2 Dataverse Tables with Labels

When Power Apps access Dataverse tables that have been classified in Purview:

1. Labels appear in Purview Data Catalog
2. Labels are metadata - they don't restrict app access
3. Access control via Dataverse security roles

**Best Practice:** Use Dataverse security roles AND sensitivity labels together:
- Security roles: Control who can access data
- Sensitivity labels: Classify sensitivity level for governance

### B.10.3 SharePoint Integration

When Power Apps use SharePoint data sources:

1. Documents in SharePoint retain their labels
2. When users access files via Power Apps, label settings apply
3. Encrypted files require appropriate permissions

### B.10.4 Displaying Sensitivity Information

**Custom display of classification in Power Apps:**

While Power Apps doesn't natively display Purview labels, you can:

1. Query Purview API for classification information
2. Display classification warnings in app UI
3. Implement custom classification indicators

**Example: Warning banner in canvas app:**

```
If(
    ThisItem.gc_contains_sin = true,
    Notify(
        "⚠️ This record contains Protected B information (SIN). Handle according to security policy.",
        NotificationType.Warning
    )
)
```

---

## B.11 Power Automate

### B.11.1 Overview

Power Automate flows can:
- Process files with sensitivity labels
- Trigger based on label changes
- Apply labels to documents programmatically

### B.11.2 Working with Labeled Files

When flows process files from SharePoint/OneDrive:

1. Labels are preserved when copying/moving files
2. Encrypted files require service account with decrypt rights
3. Label can be read via file metadata

### B.11.3 Example: Alert on Protected B Upload

```json
{
    "trigger": {
        "type": "SharePoint - When a file is created",
        "site": "https://[tenant].sharepoint.com/sites/HR",
        "library": "Documents"
    },
    "actions": [
        {
            "type": "Get file properties",
            "outputs": {
                "sensitivityLabel": "@{outputs('Get_file_properties')?['SensitivityLabelId']}"
            }
        },
        {
            "type": "Condition",
            "condition": "@contains(outputs('Get_file_properties')?['SensitivityLabelDisplayName'], 'Protected B')",
            "ifTrue": [
                {
                    "type": "Send email",
                    "to": "security-team@[domain].gc.ca",
                    "subject": "Protected B Document Uploaded",
                    "body": "A Protected B document was uploaded to HR site."
                }
            ]
        }
    ]
}
```

### B.11.4 Applying Labels via Flow

Use the Microsoft Graph API connector to apply labels:

```
POST https://graph.microsoft.com/v1.0/sites/{site-id}/drive/items/{item-id}/assignSensitivityLabel
{
    "sensitivityLabelId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "assignmentMethod": "privileged",
    "justificationText": "Applied via automated governance flow"
}
```

---

## B.12 Copilot Studio

### B.12.1 Overview

Microsoft Copilot Studio can display sensitivity labels when:
- Accessing Dataverse knowledge sources
- Returning responses with labeled content in citations

### B.12.2 Configuration

**Enable via Purview Data Map:**

1. Configure Dataverse scanning in Purview (Section B.9)
2. Enable auto-labeling for Dataverse
3. Labels automatically appear in Copilot Studio

### B.12.3 User Experience

When Copilot returns information from labeled Dataverse columns:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Copilot Response                                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Based on the citizen application records, here is the summary:     │
│                                                                     │
│  Application Status: Approved                                       │
│  Applicant Name: [REDACTED]                                         │
│                                                                     │
│  ⚠️ This response includes data classified as:                      │
│     🔒 Protected B - Personal Information                           │
│                                                                     │
│  [Citation: gc_citizen_application table]                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## B.13 Windows Endpoints

### B.13.1 Prerequisites

| Requirement | Details |
|-------------|---------|
| OS | Windows 10 (1809+) or Windows 11 |
| Enrollment | Microsoft Entra joined or hybrid joined |
| Client | Microsoft 365 Apps installed |

### B.13.2 File Explorer Integration

**Right-click labeling:**

1. Right-click file in File Explorer
2. Select: **Sensitivity** > Choose label

**Requirements:**
- Microsoft 365 Apps installed
- User signed in with M365 account

### B.13.3 Endpoint DLP

For advanced endpoint protection:

1. Enable Endpoint DLP in Purview
2. Onboard devices via Microsoft Defender for Endpoint
3. Configure DLP policies for endpoint locations

**Endpoint DLP Actions:**

| Action | Description |
|--------|-------------|
| Audit | Log activity, no block |
| Warn | Show warning, user can proceed |
| Block | Prevent action |
| Block with override | Block, allow with justification |

---

## B.14 Mobile Devices (iOS/Android)

### B.14.1 Supported Apps

| App | iOS | Android | Labeling Support |
|-----|-----|---------|------------------|
| Outlook | ✅ | ✅ | Apply to emails |
| Word | ✅ | ✅ | Apply to documents |
| Excel | ✅ | ✅ | Apply to spreadsheets |
| PowerPoint | ✅ | ✅ | Apply to presentations |
| OneDrive | ✅ | ✅ | View labels |
| Teams | ✅ | ✅ | View file labels |
| Power BI | ✅ | ✅ | View labels |

### B.14.2 Configuration

Mobile apps use the same label policies as desktop. Ensure:

1. Microsoft 365 mobile apps installed from official store
2. User signed in with M365 work account
3. Intune MAM policies applied (if using)

### B.14.3 User Experience

**Applying label in Word mobile:**

1. Open document
2. Tap: More (...) > Sensitivity
3. Select label from list

---

## B.15 Verification and Testing

### B.15.1 Verification Checklist

**Office Applications:**

- [ ] Labels appear in Sensitivity dropdown
- [ ] Labels can be applied and saved
- [ ] Content markings appear correctly
- [ ] Encryption works as configured
- [ ] Label sync across devices

**SharePoint/OneDrive:**

- [ ] Labels visible in document library
- [ ] Labels can be applied via Details pane
- [ ] Default library labels work
- [ ] Site-level labels applied

**Teams:**

- [ ] Team labels can be applied
- [ ] Privacy settings enforced by label
- [ ] Files inherit appropriate labels

**Power BI:**

- [ ] Labels appear in Power BI service
- [ ] Labels apply to datasets/reports
- [ ] Export protection works
- [ ] Inheritance functions correctly

**Dataverse:**

- [ ] Dataverse registered in Purview
- [ ] Scans complete successfully
- [ ] Classifications detected
- [ ] Labels visible in Data Catalog

### B.15.2 Test Scenarios

**Scenario 1: Protected B Document Flow**

1. Create Word document with SIN
2. Apply "Protected B - Personal" label
3. Save to SharePoint
4. Verify label visible in library
5. Open in Teams
6. Verify label displays
7. Export to PDF
8. Verify encryption applied

**Scenario 2: Power BI Inheritance**

1. Create labeled Excel in SharePoint
2. Connect Power BI to Excel
3. Verify dataset inherits label
4. Create report from dataset
5. Verify report inherits label
6. Export to PowerPoint
7. Verify encryption applied

**Scenario 3: Dataverse Classification**

1. Create Dataverse table with SIN column
2. Add sample data
3. Run Purview scan
4. Verify classification detected
5. Verify label applied
6. Check Data Catalog display

### B.15.3 Troubleshooting Verification

**PowerShell Verification Commands:**

```powershell
# Verify labels exist and are active
Get-Label | Select-Object DisplayName, IsActive, ContentType

# Verify label policy is published
Get-LabelPolicy | Select-Object Name, Mode, Enabled, Labels

# Verify SharePoint integration
Get-SPOTenant | Select-Object EnableAIPIntegration

# Verify user has labels published to them
Get-LabelPolicy -Identity "GC-Standard-Policy" | Select-Object -ExpandProperty Labels
```

---

## B.16 Troubleshooting Guide

### B.16.1 Common Issues

**Issue: Labels not appearing in Office apps**

| Cause | Solution |
|-------|----------|
| Policy not published | Verify policy is enabled and includes user |
| Wrong Office version | Update to supported version (1910+) |
| User not signed in | Sign in with M365 work account |
| Cache issue | Sign out, clear Office cache, sign in again |

**Issue: Labels not appearing in SharePoint**

| Cause | Solution |
|-------|----------|
| Feature not enabled | Run `Set-SPOTenant -EnableAIPIntegration $true` |
| Sync delay | Wait up to 24 hours after enabling |
| Browser cache | Clear browser cache, try incognito |

**Issue: Container labels not available**

| Cause | Solution |
|-------|----------|
| Azure AD settings | Enable MIPLabels in directory settings |
| Label sync | Run `Execute-AzureAdLabelSync` |
| Label scope | Ensure "Groups & Sites" scope selected |

**Issue: Power BI labels not working**

| Cause | Solution |
|-------|----------|
| Tenant setting disabled | Enable in Admin portal > Information protection |
| License missing | Verify Power BI Pro/PPU license |
| Labels not published | Verify label policy published to user |

**Issue: Dataverse scan failing**

| Cause | Solution |
|-------|----------|
| Authentication failed | Verify application user created with Service Reader role |
| Wrong URL | Use Environment URL from Power Platform Admin Center |
| Permissions | Grant Data Source Administrator role in Purview |

### B.16.2 Log Locations

| Platform | Log Location |
|----------|--------------|
| Office Desktop | `%localappdata%\Microsoft\Office\16.0\OfficeFileCache` |
| SharePoint | Unified Audit Log |
| Power BI | Unified Audit Log + Power BI Activity Log |
| Purview | Data Map > Monitoring |

### B.16.3 Support Resources

| Resource | URL |
|----------|-----|
| Sensitivity Labels Docs | learn.microsoft.com/en-us/purview/sensitivity-labels |
| Power BI Labels | learn.microsoft.com/en-us/power-bi/enterprise/service-security-sensitivity-label-overview |
| Dataverse in Purview | learn.microsoft.com/en-us/purview/register-scan-dataverse |
| Troubleshooting Guide | learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#troubleshooting |

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | SSC/TBS Working Group | Initial annex |

**Classification:** Protected B  
**Author:** Frederick Pearson & References to official Microsoft Documentation, Canadian IT regulatory compliance documentation and community documentation (open source) with local LLM summaries and content generation - References outlined in the next section.

---

## B.17 Reference Documentation

### B.17.1 Microsoft Purview - Sensitivity Labels

| Topic | URL |
|-------|-----|
| Learn about sensitivity labels | https://learn.microsoft.com/en-us/purview/sensitivity-labels |
| Create and publish sensitivity labels | https://learn.microsoft.com/en-us/purview/create-sensitivity-labels |
| Get started with sensitivity labels | https://learn.microsoft.com/en-us/purview/get-started-with-sensitivity-labels |
| Default sensitivity labels and policies | https://learn.microsoft.com/en-us/purview/default-sensitivity-labels-policies |
| Sensitivity labels in Data Map FAQ | https://learn.microsoft.com/en-us/purview/sensitivity-labels-frequently-asked-questions |

### B.17.2 Office Applications

| Topic | URL |
|-------|-----|
| Manage sensitivity labels in Office apps | https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps |

### B.17.3 SharePoint and OneDrive

| Topic | URL |
|-------|-----|
| Enable sensitivity labels for SharePoint and OneDrive | https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-onedrive-files |
| Use sensitivity labels with Teams, Groups, and SharePoint sites | https://learn.microsoft.com/en-us/purview/sensitivity-labels-teams-groups-sites |

### B.17.4 Microsoft Teams

| Topic | URL |
|-------|-----|
| Sensitivity labels for Microsoft Teams | https://learn.microsoft.com/en-us/microsoftteams/sensitivity-labels |

### B.17.5 Power BI and Microsoft Fabric

| Topic | URL |
|-------|-----|
| Sensitivity labels in Power BI overview | https://learn.microsoft.com/en-us/fabric/enterprise/powerbi/service-security-sensitivity-label-overview |
| Enable sensitivity labels in Fabric and Power BI | https://learn.microsoft.com/en-us/fabric/enterprise/powerbi/service-security-enable-data-sensitivity-labels |
| How to apply sensitivity labels in Power BI | https://learn.microsoft.com/en-us/power-bi/enterprise/service-security-apply-data-sensitivity-labels |
| Sensitivity label change enforcement in Power BI | https://learn.microsoft.com/en-us/power-bi/enterprise/service-security-sensitivity-label-change-enforcement |
| CISA Power BI Security Baseline | https://www.cisa.gov/resources-tools/services/m365-power-bi |

### B.17.6 Power Platform and Dataverse

| Topic | URL |
|-------|-----|
| Connect to and manage Dataverse in Microsoft Purview | https://learn.microsoft.com/en-us/purview/register-scan-dataverse |
| Data classification recommendations for Power Platform | https://learn.microsoft.com/en-us/power-platform/well-architected/security/data-classification |
| Monitor and protect data with Microsoft Purview (Dataverse) | https://learn.microsoft.com/en-us/power-platform/release-plan/2023wave2/power-platform-governance-administration/monitor-protect-data-purview |
| View sensitivity labels in Copilot Studio | https://learn.microsoft.com/en-us/power-platform/release-plan/2025wave1/power-platform-governance-administration/view-sensitivity-labels-copilot-studio |
| Labeling with Purview Data Map - Dataverse support | https://techcommunity.microsoft.com/blog/microsoft-security-blog/labeling-with-microsoft-purview-data-map-now-supports-dataverse-azure-databricks/4052587 |
| Purview integration with Dataverse (Public Preview) | https://techcommunity.microsoft.com/blog/microsoft-security-blog/now-in-public-preview-microsoft-purview-integration-with-microsoft-dataverse/3985044 |
| Power Platform security features (March 2024) | https://www.microsoft.com/en-us/power-platform/blog/2024/03/20/protect-enterprise-solutions-with-new-microsoft-power-platform-security-features/ |

### B.17.7 Data Loss Prevention (DLP)

| Topic | URL |
|-------|-----|
| Learn about data loss prevention | https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp |
| DLP policy templates | https://learn.microsoft.com/en-us/purview/dlp-policy-templates-include |
| DLP policy reference | https://learn.microsoft.com/en-us/purview/dlp-policy-reference |
| Plan for data loss prevention | https://learn.microsoft.com/en-us/purview/dlp-overview-plan-for-dlp |
| DLP policy tips and notifications | https://learn.microsoft.com/en-us/purview/dlp-use-notifications-and-policy-tips |
| Get started with DLP alerts | https://learn.microsoft.com/en-us/purview/dlp-alerts-get-started |
| DLP alerts dashboard | https://learn.microsoft.com/en-us/purview/dlp-alerts-dashboard-get-started |
| Investigating DLP alerts | https://learn.microsoft.com/en-us/purview/dlp-alert-investigation-learn |

### B.17.8 Sensitive Information Types (Canada)

| Topic | URL |
|-------|-----|
| Sensitive information type entity definitions | https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions |
| Learn about sensitive information types | https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-learn-about |
| Canada Social Insurance Number | https://learn.microsoft.com/en-us/purview/sit-defn-canada-social-insurance-number |
| Canada Health Service Number | https://learn.microsoft.com/en-us/purview/sit-defn-canada-health-service-number |
| Canada Personal Health Identification Number | https://learn.microsoft.com/en-us/purview/sit-defn-canada-personal-health-identification-number |

### B.17.9 Activity Explorer and Reporting

| Topic | URL |
|-------|-----|
| Get started with Activity Explorer | https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer |
| Labeling actions reported in Activity Explorer | https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer-available-events |
| Azure Information Protection analytics and reporting | https://learn.microsoft.com/en-us/azure/information-protection/reports-aip |

### B.17.10 Canadian Government Privacy References

| Topic | URL |
|-------|-----|
| OPC Interpretation Bulletin - Sensitive Information | https://www.priv.gc.ca/en/privacy-topics/privacy-laws-in-canada/the-personal-information-protection-and-electronic-documents-act-pipeda/pipeda-compliance-help/pipeda-interpretation-bulletins/interpretations_10_sensible/ |
| OPC Guidance Update - Sensitive Personal Information | https://www.priv.gc.ca/en/opc-news/news-and-announcements/2021/an_210813/ |

### B.17.11 Community Resources and Guides

| Topic | URL |
|-------|-----|
| Classifications and sensitivity labels in Purview (James Serra) | https://www.jamesserra.com/archive/2024/07/classifications-and-sensitivity-labels-in-microsoft-purview/ |
| Sensitivity Labels Guide (SysKit) | https://www.syskit.com/blog/microsoft-365-sensitivity-labels-guide/ |
| How to rollout Sensitivity Labels company-wide | https://toniontech.com/2024/12/how-to-rollout-sensitivity-labels-company-wide-a-practical-guide/ |
| Using sensitivity labels with SharePoint, Teams, M365 Groups | https://practical365.com/using-sensitivity-labels-with-sharepoint-sites-microsoft-teams-and-m365-groups-part-1/ |
| Enabling Sensitivity Labels for SharePoint and Teams | https://myronhelgering.com/how-to-enable-sensitivity-labels-for-microsoft-365-groups-sharepoint-sites-and-microsoft-teams/ |
| Sensitivity labels analysis with Audit Log | https://office365itpros.com/2022/11/15/sensitivity-labels-analysis/ |
| All About Sensitivity Labels (Practical365) | https://practical365.com/sensitivity-labels-2023/ |
| Using sensitivity labels with Power BI | https://alberthoitingh.com/2021/01/12/using-sensitivity-labels-with-powerbi/ |
| Sensitivity Labels in Power BI (Iteration Insights) | https://iterationinsights.com/article/sensitivity-labels-in-power-bi/ |
| Power BI sensitivity bar announcement | https://powerbi.microsoft.com/en-us/blog/easily-label-your-data-the-new-sensitivity-bar-for-power-bi-and-fabric/ |
| Microsoft Purview Compliance Analytics | https://www.2tolead.com/insights/microsoft-purview-compliance-analytics-reports-dlp-audit |
| Advanced DLP Strategies in Purview | https://www.syskit.com/blog/advanced-data-loss-prevention-dlp-purview/ |
| Microsoft Purview Reports (AdminDroid) | https://blog.admindroid.com/microsoft-purview-reports-that-make-compliance-management-easy-strong/ |
| All Things M365 Compliance Podcast - MPARR | https://nikkichapple.com/atm365cmparr/ |
| Power Platform and Purview (Raphaël Pothin) | https://medium.com/rapha%C3%ABl-pothin/power-platforms-protection-microsoft-purview-the-data-guardian-d7bc34620655