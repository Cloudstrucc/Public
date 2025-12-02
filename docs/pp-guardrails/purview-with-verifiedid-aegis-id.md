<img src="https://www.canada.ca/etc/designs/canada/wet-boew/assets/sig-blk-en.svg"
     alt="Government of Canada Signature"
     style="float: right; width: 300px; margin: 0 0 100px 100px;" />
<br>

# Government of Canada Cloud Security & Identity Modernization
## Microsoft Purview Information Protection + Aegis ID Decentralized Identity

**Document Version:** 3.0  
**Effective Date:** December 2025  
**Authority:** Shared Services Canada (SSC) & Treasury Board Secretariat (TBS)  
**Classification:** Protected B Medium Integrity Medium Availability (PBMM)

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | SSC/TBS Working Group | Initial buildbook |
| 2.0 | December 2025 | SSC/TBS Working Group | Added OOB Canadian templates, Custom Protected B policy |
| 3.0 | December 2025 | SSC/TBS Working Group | Added Executive Summary, HSM cost analysis, Aegis ID decentralized identity, SSC management model, combined ROI analysis |

**Review Schedule:** Quarterly or as required by regulatory changes  
**Next Review Date:** March 2026  
**Approval Authority:** Chief Information Officer

---

## Table of Contents

### Part A: Executive Summary
- [A.1 Strategic Overview](#a1-strategic-overview)
- [A.2 The Threat Landscape](#a2-the-threat-landscape)
- [A.3 Solution Components](#a3-solution-components)
- [A.4 Investment Summary](#a4-investment-summary)
- [A.5 Executive Recommendations](#a5-executive-recommendations)

### Part B: Cost Analysis & HSM Options
- [B.1 Total Cost of Implementation](#b1-total-cost-of-implementation)
- [B.2 Microsoft 365 Licensing Requirements](#b2-microsoft-365-licensing-requirements)
- [B.3 HSM Solutions Comparison](#b3-hsm-solutions-comparison)
- [B.4 SSC Management Model](#b4-ssc-management-model)

### Part C: Aegis ID Decentralized Identity
- [C.1 Current Certificate Authentication Challenges](#c1-current-certificate-authentication-challenges)
- [C.2 Aegis ID Architecture](#c2-Aegis-id-architecture)
- [C.3 Entra Verified ID Integration](#c3-entra-verified-id-integration)
- [C.4 Inter-Agency Mobility](#c4-inter-agency-mobility)
- [C.5 Implementation Costs & Savings](#c5-implementation-costs--savings)

### Part D: Technical Implementation - Microsoft Purview
- [D.1 Prerequisites and Licensing](#d1-prerequisites-and-licensing)
- [D.2 Canadian Government Sensitivity Label Taxonomy](#d2-canadian-government-sensitivity-label-taxonomy)
- [D.3 Creating Sensitivity Labels](#d3-creating-sensitivity-labels)
- [D.4 Sensitive Information Types for Canada](#d4-sensitive-information-types-for-canada)
- [D.5 Label Policies and Publishing](#d5-label-policies-and-publishing)
- [D.6 Auto-Labeling Policies - OOB Canadian Templates](#d6-auto-labeling-policies---oob-canadian-templates)
- [D.7 Data Loss Prevention (DLP) Policies](#d7-data-loss-prevention-dlp-policies)
- [D.8 User Notifications, Banners, and Alerts](#d8-user-notifications-banners-and-alerts)
- [D.9 Power Platform Integration](#d9-power-platform-integration)
- [D.10 Dashboard and Reporting](#d10-dashboard-and-reporting)

### Part E: Platform Implementation Guide
- [E.1 Microsoft 365 Office Applications](#e1-microsoft-365-office-applications)
- [E.2 Microsoft Outlook (Email)](#e2-microsoft-outlook-email)
- [E.3 SharePoint Online](#e3-sharepoint-online)
- [E.4 Microsoft Teams](#e4-microsoft-teams)
- [E.5 Power BI / Microsoft Fabric](#e5-power-bi--microsoft-fabric)
- [E.6 Power Platform - Dataverse](#e6-power-platform---dataverse)

### Part F: Implementation Roadmap
- [F.1 Phased Implementation Timeline](#f1-phased-implementation-timeline)
- [F.2 Implementation Checklist](#f2-implementation-checklist)
- [F.3 Success Metrics](#f3-success-metrics)

### Appendices
- [Appendix A: Reference Documentation](#appendix-a-reference-documentation)
- [Appendix B: Glossary](#appendix-b-glossary)
- [Appendix C: Compliance Mapping](#appendix-c-compliance-mapping)

---

# PART A: EXECUTIVE SUMMARY

## A.1 Strategic Overview

### The Challenge

The Government of Canada faces unprecedented cybersecurity threats targeting cloud-hosted data. Recent high-profile incidents—including the Storm-0558 attack (2023) where Chinese hackers accessed US government emails via a compromised Microsoft signing key, and the Midnight Blizzard attack (2024) where Russian actors accessed Microsoft executive emails—demonstrate that **even the world's largest technology providers can be compromised**.

With standard Microsoft encryption, Microsoft holds the encryption keys. If Microsoft is breached, compelled by foreign courts, or experiences an insider threat, Government of Canada data could be exposed.

### The Solution

This buildbook presents a comprehensive security modernization strategy with two interconnected pillars:

**Pillar 1: Microsoft Purview Information Protection with Customer-Managed Keys**
- Automatic classification and protection of Canadian sensitive information
- Encryption keys controlled by GC, stored in Canadian HSMs
- Data remains protected even if Microsoft infrastructure is compromised

**Pillar 2: Aegis ID Decentralized Identity**
- Replace costly Entrust certificate authentication with verifiable credentials
- Enable seamless inter-agency employee mobility on same devices
- Leverage existing Active Directory and Microsoft Authenticator infrastructure

### Key Benefits

| Benefit | Impact |
|---------|--------|
| **Data Sovereignty** | Encryption keys stored in Canadian HSMs, controlled by SSC |
| **Breach Resilience** | Data remains encrypted even if Microsoft is compromised |
| **Instant Revocation** | Credential revocation in real-time vs. hours/days with certificates |
| **Device Portability** | Same laptop across agency transitions, no reprovisioning |
| **Cost Reduction** | $108M+ net savings over 5 years |
| **Compliance** | PIPEDA, ITSG-33, Provincial Health Acts alignment |

---

## A.2 The Threat Landscape

### Current Risk Profile

| Threat | Current State | Risk Level |
|--------|--------------|------------|
| Nation-state actors targeting GC data | Active campaigns documented | **CRITICAL** |
| Microsoft infrastructure compromise | Demonstrated in 2023-2024 incidents | **HIGH** |
| Certificate-based auth vulnerabilities | Slow revocation, exportable credentials | **MEDIUM** |
| Inter-agency data leakage | Inconsistent access revocation during transfers | **MEDIUM** |
| Compliance gaps | Manual classification, inconsistent enforcement | **MEDIUM** |

### Breach Statistics (2024-2025)

- **$4.88M USD** - Average cost of data breach (↑ 10% YoY)
- **82%** - Breaches involving cloud infrastructure (↑ 15% YoY)
- **194 days** - Average time to identify breach
- **61%** - Breaches involving stolen credentials (↑ 8% YoY)

### The Microsoft Risk Factor

**With Standard Microsoft Encryption:**
```
YOUR DATA → MICROSOFT KEYS → POTENTIAL EXPOSURE
   📄           🔑 Microsoft      ❓ Unknown Actors
               Controlled
```

**With Customer-Managed Keys:**
```
YOUR DATA → YOUR KEYS → YOUR CONTROL
   📄         🔐 Azure        ✅ Only GC
             Key Vault         Decides
             (SSC HSM)
```

**Key Insight:** Even with a valid court order, Microsoft **cannot** decrypt GC data without GC-controlled keys. Even if Microsoft is breached, attackers obtain only encrypted data blobs.

---

## A.3 Solution Components

### Component 1: Microsoft Purview Information Protection

**What It Does:**
- Automatically detects Canadian sensitive information (SIN, PHIN, financial data)
- Applies sensitivity labels with encryption and access controls
- Prevents unauthorized sharing through DLP policies
- Provides complete visibility through Activity Explorer

**Key Features:**
- **9 out-of-the-box Canadian templates** (Financial, Health, Privacy categories)
- **Custom Protected B policy** for comprehensive coverage
- **Real-time user notifications** when sensitive data is detected
- **Encryption that travels with the data** across all platforms

### Component 2: Customer-Managed Keys (CMK)

**What It Does:**
- GC controls encryption keys, not Microsoft
- Keys stored in FIPS 140-2 Level 3 certified HSMs
- Located in Canadian SSC data centres
- Full audit trail of all key operations

**HSM Options Evaluated:**
- **Entrust nShield** - Canadian company, SSC operational experience (Recommended)
- **Thales Luna** - Industry-leading performance
- **Azure Managed HSM** - Cloud-native, lower upfront cost

### Component 3: Aegis ID Decentralized Identity

**What It Does:**
- Replaces Entrust certificate authentication with verifiable credentials
- Provides portable digital identity across all GC agencies
- Enables instant credential revocation when employees transfer
- Uses existing Microsoft Authenticator as credential wallet

**Key Innovation:**
- When an employee moves from ESDC to IRCC:
  - ESDC credential revoked **instantly** (vs. 2-4 weeks with certificates)
  - IRCC credential issued **same day**
  - **Same laptop retained** - no device reprovisioning
  - Previous agency data **automatically inaccessible** (claims-based encryption)

---

## A.4 Investment Summary

### 5-Year Total Cost of Ownership

| Initiative | 5-Year Cost | Annual Savings | 5-Year Savings |
|-----------|-------------|----------------|----------------|
| **Purview Information Protection** | $10,000,000 | — | — |
| **HSM Infrastructure (Entrust)** | $1,000,000 | — | — |
| **Aegis ID** | $11,400,000 | $23,850,000 | $95,400,000 |
| **TOTAL INVESTMENT** | **$22,400,000** | — | — |
| **TOTAL SAVINGS** | — | — | **$131,080,000** |
| **NET 5-YEAR BENEFIT** | — | — | **$108,680,000** |

### Savings Breakdown (Aegis ID)

| Current Cost Eliminated | Annual Savings |
|------------------------|----------------|
| Certificate issuance | $4,500,000 |
| Smart card hardware | $2,000,000 |
| PKI infrastructure (80%) | $2,800,000 |
| Help desk (cert issues) | $4,500,000 |
| Transition processing | $2,850,000 |
| Device reprovisioning | $7,200,000 |
| **TOTAL** | **$23,850,000** |

### Avoided Costs

| Risk Mitigation | Estimated Value |
|-----------------|-----------------|
| Breach cost avoidance (1 prevented) | $4,880,000 |
| Compliance audit efficiency | $2,000,000/year |
| Regulatory fine avoidance | Up to $25M under CPPA |

---

## A.5 Executive Recommendations

### Immediate Actions

1. **Approve Purview + CMK Implementation**
   - Begin Entrust HSM procurement via SSC
   - Allocate M365 E5 Compliance licensing
   - Establish SSC key management team (6 FTEs)

2. **Fund Aegis ID Development**
   - Commission detailed technical design
   - Establish SSC infrastructure allocation
   - Engage Microsoft for Verified ID partnership

3. **Designate Pilot Agencies**
   - Select 3-5 agencies for initial rollout
   - Identify inter-agency mobility use case
   - Establish success metrics

4. **Establish Governance**
   - Cross-departmental steering committee
   - SSC operational ownership
   - TBS policy alignment

### Decision Framework: When to Use Customer-Managed Keys

| Data Classification | Microsoft Keys | Customer Keys |
|--------------------|---------------|---------------|
| Unclassified - Public | ✅ | |
| Unclassified - Internal | ✅ | |
| Protected A | ✅ | Consider |
| Protected B - Standard | ✅ | **Recommended** |
| Protected B - High Sensitivity | | **Required** |
| National Security Adjacent | | **Required** |
| Foreign Adversary Target Data | | **Required** |

### Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1: Foundation | Days 1-60 | HSM procurement, label creation |
| Phase 2: HSM Deployment | Days 61-150 | Entrust installation, Key Vault integration |
| Phase 3: Purview Configuration | Days 151-210 | Labels, auto-labeling, DLP |
| Phase 4: Production | Days 211-240 | Pilot rollout, full deployment |
| Phase 5: Aegis ID | Months 7-18 | Development, integration, agency rollout |

---

# PART B: COST ANALYSIS & HSM OPTIONS

## B.1 Total Cost of Implementation

### Purview Information Protection - 5 Year TCO

**For 10,000 Users (Typical Large Department)**

| Cost Category | Year 1 | Years 2-5 (Annual) | 5-Year Total |
|--------------|--------|-------------------|--------------|
| **Licensing** | | | |
| M365 E5 Compliance Add-on | $1,440,000 | $1,440,000 | $7,200,000 |
| **Infrastructure** | | | |
| Azure Key Vault Premium | $48,000 | $48,000 | $240,000 |
| HSM Solution (Entrust) | $350,000 | $100,000 | $750,000 |
| **Services** | | | |
| Implementation Partner | $500,000 | — | $500,000 |
| SSC Operations (2 FTEs) | $300,000 | $300,000 | $1,500,000 |
| **Training** | $100,000 | $25,000 | $200,000 |
| **TOTAL** | **$2,738,000** | **$1,913,000** | **$10,390,000** |

### Per-User Cost Analysis

| License/Service | Monthly Cost | Annual Cost |
|-----------------|-------------|-------------|
| M365 E5 Compliance Add-on | $12.00 | $144.00 |
| Azure Key Vault (allocated) | $0.40 | $4.80 |
| HSM (allocated) | $0.63 | $7.50 |
| SSC Operations (allocated) | $2.50 | $30.00 |
| **Total Per User** | **$15.53** | **$186.30** |

---

## B.2 Microsoft 365 Licensing Requirements

### Feature Availability by License

| Feature | E3 | E5 | E5 Compliance Add-on |
|---------|----|----|---------------------|
| Manual sensitivity labels | ✅ | ✅ | ✅ |
| Auto-labeling (client-side) | ❌ | ✅ | ✅ |
| Auto-labeling (service-side) | ❌ | ✅ | ✅ |
| DLP for Exchange/SharePoint | ✅ | ✅ | ✅ |
| DLP for Teams chat | ❌ | ✅ | ✅ |
| Endpoint DLP | ❌ | ✅ | ✅ |
| Activity Explorer | ❌ | ✅ | ✅ |
| Advanced auditing | ❌ | ✅ | ✅ |
| Customer-Managed Keys | ❌ | ✅ | ✅ |
| Insider Risk Management | ❌ | ✅ | ✅ |

### Licensing Recommendation

**For departments currently on E3:**
- Add E5 Compliance ($12/user/month)
- Provides all required features
- Most cost-effective path

**For departments considering E5:**
- Full E5 includes compliance features
- Additional benefits: Defender, Analytics, eDiscovery Premium
- Evaluate based on broader security needs

---

## B.3 HSM Solutions Comparison

### Option 1: Entrust nShield (Recommended)

**Why Entrust for GC:**
- **Canadian company** - Ottawa headquarters
- **Existing GC relationship** - SSC has operational experience
- **FIPS 140-2 Level 3** certified
- **ITSG-33 aligned** - Designed for Canadian government requirements
- **On-premises deployment** - Full data sovereignty

**Product Options:**

| Model | Crypto Ops/sec | Use Case | Est. Cost |
|-------|---------------|----------|-----------|
| nShield Connect XC | 20,000 | Enterprise | $75,000 |
| nShield Connect XC High | 60,000 | High-volume | $150,000 |
| nShield as a Service | N/A | Cloud-managed | $3,500/mo |

**5-Year TCO (Enterprise Deployment):**

| Component | Cost |
|-----------|------|
| Primary HSM (nShield Connect XC High) | $150,000 |
| Backup HSM | $75,000 |
| Key Management Server | $50,000 |
| Installation & Configuration | $75,000 |
| Annual Maintenance (4 years) | $100,000 |
| SSC Staff Training | $25,000 |
| **TOTAL** | **$475,000** |

### Option 2: Thales Luna

**Strengths:**
- **Highest performance** - Up to 20,000 ECC ops/sec
- **Azure native integration** - Luna Cloud HSM
- **FIPS 140-2 Level 3** certified
- **Hybrid deployment** - On-prem + cloud options

**Product Options:**

| Model | Crypto Ops/sec | Use Case | Est. Cost |
|-------|---------------|----------|-----------|
| Luna Network HSM 7 | 10,000 | Standard | $60,000 |
| Luna Network HSM 7 (High) | 20,000 | High-volume | $120,000 |
| Luna Cloud HSM | Variable | Cloud-native | $2,800/mo |
| Luna Backup HSM | N/A | Disaster recovery | $25,000 |

### Option 3: Azure Managed HSM

**Strengths:**
- **Native Azure integration** - Seamless Key Vault connectivity
- **Canadian regions** - Canada Central, Canada East
- **FIPS 140-2 Level 3** certified
- **No hardware management** - Fully managed service
- **Lower upfront cost** - Pay-as-you-go model

**Pricing:**

| Component | Monthly Cost | Annual Cost |
|-----------|-------------|-------------|
| Managed HSM Pool (Standard) | $4,032 | $48,384 |
| Key operations (per 10,000) | $0.03 | Variable |
| Premium Key Vault (backup) | $1/key/month | Variable |

**Consideration:** Keys stored on Microsoft infrastructure (managed, but not fully GC-owned)

### HSM Comparison Matrix

| Criteria | Entrust nShield | Thales Luna | Azure Managed HSM |
|----------|----------------|-------------|-------------------|
| **Data Sovereignty** | ✅ Full (on-prem) | ✅ Full (on-prem) | ⚠️ Azure-hosted |
| **GC Experience** | ✅ Extensive | ✅ Moderate | ⚠️ Limited |
| **FIPS 140-2 L3** | ✅ | ✅ | ✅ |
| **Azure Integration** | ✅ BYOK | ✅ BYOK | ✅ Native |
| **Upfront Cost** | $$$$ | $$$ | $ |
| **Operational Cost** | $$ | $$ | $$$ |
| **SSC Ops Complexity** | Medium | Medium | Low |
| **Canadian Company** | ✅ Yes | ❌ No | ❌ No |
| **RECOMMENDATION** | **PRIMARY** | **ALTERNATIVE** | **RAPID DEPLOY** |

### Architecture: Entrust with Azure Key Vault BYOK

```
┌────────────────────────────────────────────────────────────────────┐
│                     SSC DATA CENTRE (CANADA)                       │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                                                            │  │
│   │   ┌──────────────────┐      ┌──────────────────┐          │  │
│   │   │  Entrust nShield │      │  Key Management  │          │  │
│   │   │       HSM        │◀────▶│     Server       │          │  │
│   │   │   (Primary)      │      │                  │          │  │
│   │   └──────────────────┘      └────────┬─────────┘          │  │
│   │            │                         │                     │  │
│   │   ┌──────────────────┐               │ BYOK Export        │  │
│   │   │  Entrust nShield │               │ (Wrapped Keys)     │  │
│   │   │       HSM        │               ▼                     │  │
│   │   │   (Backup)       │      ┌──────────────────┐          │  │
│   │   └──────────────────┘      │  Azure Key Vault │          │  │
│   │                              │  (Canada Central)│          │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                          │                         │
│                                          ▼                         │
│                              ┌──────────────────────┐             │
│                              │  Microsoft 365       │             │
│                              │  Services            │             │
│                              │  (Encrypted Data)    │             │
│                              └──────────────────────┘             │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## B.4 SSC Management Model

### Operational Framework

```
┌────────────────────────────────────────────────────────────────────┐
│                        SSC CLOUD BROKERING                         │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│   ┌──────────────────┐                    ┌──────────────────┐    │
│   │   HSM Operations │                    │  Key Management  │    │
│   │      Team        │                    │      Team        │    │
│   │                  │                    │                  │    │
│   │ • HSM health     │                    │ • Key lifecycle  │    │
│   │ • Firmware       │                    │ • Key rotation   │    │
│   │ • DR/backup      │                    │ • Access control │    │
│   │ • Monitoring     │                    │ • Audit review   │    │
│   └────────┬─────────┘                    └────────┬─────────┘    │
│            │                                       │               │
│            └───────────────┬───────────────────────┘               │
│                            ▼                                       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                 Departmental Self-Service                    │ │
│   │                                                              │ │
│   │  • Request new keys via ServiceNow                          │ │
│   │  • Configure label encryption (delegated)                   │ │
│   │  • View audit logs (own department)                         │ │
│   │  • Revocation requests (emergency)                          │ │
│   │                                                              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### SSC Staffing Requirements

**Dedicated CMK Operations Team:**

| Role | FTEs | Annual Cost | Responsibilities |
|------|------|-------------|-----------------|
| HSM Administrator | 2 | $220,000 | Hardware, firmware, DR |
| Key Manager | 2 | $220,000 | Lifecycle, rotation, access |
| Security Analyst | 1 | $110,000 | Audit, compliance, incidents |
| Team Lead | 1 | $140,000 | Governance, escalations |
| **Total** | **6** | **$690,000** | |

**Service Model:**
- Centralized team serves all departments
- Per-department cost allocation based on usage
- 24/7 on-call rotation for critical incidents
- Integration with SSC ITSM processes (ServiceNow)

---

# PART C: Aegis ID DECENTRALIZED IDENTITY

## C.1 Current Certificate Authentication Challenges

### The Problem with Entrust Certificates

**Current State:**
```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   EMPLOYEE MOVES FROM DEPT A → DEPT B                             │
│                                                                    │
│   ┌──────────┐         ┌──────────┐         ┌──────────┐         │
│   │  Revoke  │────────▶│ Reissue  │────────▶│ Reinstall│         │
│   │   Cert   │         │ New Cert │         │    +     │         │
│   │          │         │          │         │ Reconfig │         │
│   └──────────┘         └──────────┘         └──────────┘         │
│                                                                    │
│   ⏱️ Time: 2-4 weeks        💰 Cost: $150-300 per transition      │
│   📱 New device often required                                     │
│   📂 Previous work data inaccessible (or copied insecurely)       │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Current Annual Costs

| Cost Category | Annual Cost | Notes |
|--------------|-------------|-------|
| Certificate issuance | $4,500,000 | ~300,000 employees × $15 avg |
| Smart card/token hardware | $2,000,000 | Replacements, new hires |
| PKI infrastructure (SSC) | $3,500,000 | Servers, HSMs, operations |
| Help desk (cert issues) | $5,000,000 | ~10% of IT tickets |
| Transition processing | $3,000,000 | ~20,000 agency moves/year |
| Device reprovisioning | $8,000,000 | New laptops for movers |
| **TOTAL** | **$26,000,000** | |

### Pain Points

- 🔄 Inter-agency mobility requires weeks of processing
- 💸 Duplicate device procurement for transferred employees
- ⏰ Reduced productivity during 2-4 week transitions
- 🔐 Data access revocation is inconsistent and slow
- 📱 Smart cards/tokens get lost, damaged, forgotten
- 🔓 Certificate credentials can be exported (security risk)

---

## C.2 Aegis ID Architecture

### What is Aegis ID?

A **custom DID (Decentralized Identifier) service** built on W3C standards, integrated with **Microsoft Entra Verified ID**, providing:

- 🆔 **Portable digital identity** across all GC agencies
- 🔐 **Verifiable credentials** replacing certificates
- 📱 **Microsoft Authenticator** as the credential wallet
- ⚡ **Instant access changes** when employees move
- 🏛️ **Hosted in SSC data centres** for full sovereignty

### Architecture Overview

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│                      Aegis ID ARCHITECTURE                         │
│                                                                    │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                  SSC DATA CENTRE                            │  │
│   │                                                             │  │
│   │   ┌──────────────┐    ┌──────────────┐    ┌────────────┐   │  │
│   │   │   Aegis ID   │    │    DID       │    │ Credential │   │  │
│   │   │   Service    │◀──▶│  Registry    │◀──▶│   Store    │   │  │
│   │   │  (Issuer)    │    │ (Ledger)     │    │ (Verifier) │   │  │
│   │   └──────────────┘    └──────────────┘    └────────────┘   │  │
│   │          │                                       │          │  │
│   └──────────┼───────────────────────────────────────┼──────────┘  │
│              │                                       │              │
│              ▼                                       ▼              │
│   ┌──────────────────┐              ┌──────────────────────────┐   │
│   │ Microsoft Entra  │              │   Agency Applications    │   │
│   │   Verified ID    │              │   (Relying Parties)      │   │
│   │   Integration    │              │                          │   │
│   └────────┬─────────┘              └──────────────────────────┘   │
│            │                                                        │
│            ▼                                                        │
│   ┌──────────────────┐                                             │
│   │  MS Authenticator │ ◀──── Employee's Device                    │
│   │   (DID Wallet)    │       (Phone + Laptop)                     │
│   └──────────────────┘                                             │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Verifiable Credentials Model

Each employee receives a DID with agency-specific claims:

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   🆔 EMPLOYEE DID: did:Aegis:gc:employee:abc123def456             │
│                                                                    │
│   ┌──────────────────────────────────────────────────────────────┐│
│   │                     VERIFIABLE CREDENTIALS                   ││
│   │                                                              ││
│   │   ┌────────────────────────────────────────────────────┐    ││
│   │   │ 🏛️ AGENCY CREDENTIAL: ESDC                         │    ││
│   │   │                                                     │    ││
│   │   │   claim:agency = "ESDC"                            │    ││
│   │   │   claim:classification = "Protected B"              │    ││
│   │   │   claim:role = "Policy Analyst"                    │    ││
│   │   │   claim:office = "140 Promenade du Portage"        │    ││
│   │   │   claim:valid_from = "2024-01-15"                  │    ││
│   │   │   claim:valid_until = "2027-01-15"                 │    ││
│   │   │   issuer: did:Aegis:gc:issuer:esdc                 │    ││
│   │   │                                                     │    ││
│   │   └────────────────────────────────────────────────────┘    ││
│   │                                                              ││
│   └──────────────────────────────────────────────────────────────┘│
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## C.3 Entra Verified ID Integration

### Why Entra Verified ID?

**Key Advantage: GC is Already 95% There!**

| What Already Exists | Change Required |
|--------------------|-----------------|
| ✅ Active Directory synced to Entra ID | None |
| ✅ All employees have M365 accounts | None |
| ✅ Microsoft Authenticator deployed for MFA | None |
| ✅ Conditional Access policies in place | Minor updates |
| ✅ Entra ID P1/P2 licenses | None |

**What Needs to Be Added:**

| New Component | Description |
|--------------|-------------|
| 🆕 Aegis ID service | SSC-hosted DID resolver/issuer |
| 🆕 Verified ID tenant configuration | Enable in Entra admin center |
| 🆕 Agency credential templates | Define claims per department |
| 🆕 OIDC integration | Connect relying party applications |

### Integration Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                    MICROSOFT ENTRA                           │ │
│   │                                                              │ │
│   │   ┌──────────────┐    ┌──────────────┐    ┌────────────┐   │ │
│   │   │   Entra ID   │    │  Verified ID │    │Authenticator│  │ │
│   │   │  (Identity)  │◀──▶│  (VC Engine) │◀──▶│  (Wallet)  │   │ │
│   │   └──────────────┘    └──────┬───────┘    └────────────┘   │ │
│   │                              │                               │ │
│   └──────────────────────────────┼───────────────────────────────┘ │
│                                  │ DID Resolution                  │
│                                  ▼                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                    Aegis ID (SSC-HOSTED)                     │ │
│   │                                                              │ │
│   │   ┌──────────────┐    ┌──────────────┐    ┌────────────┐   │ │
│   │   │  DID Method  │    │  Credential  │    │   Issuer   │   │ │
│   │   │   Resolver   │◀──▶│   Registry   │◀──▶│  Services  │   │ │
│   │   │ (did:Aegis)  │    │              │    │ (per dept) │   │ │
│   │   └──────────────┘    └──────────────┘    └────────────┘   │ │
│   │                                                              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### OIDC Authentication Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   1. USER ACCESSES APPLICATION                                     │
│      ┌─────────┐         ┌─────────────────┐                      │
│      │ Browser │────────▶│ GC Application  │                      │
│      └─────────┘         └────────┬────────┘                      │
│                                   │                                │
│   2. APP REQUESTS VERIFICATION    │                                │
│      ┌─────────────────┐◀─────────┘                               │
│      │ Aegis ID OIDC   │                                          │
│      │ Provider        │                                          │
│      └────────┬────────┘                                          │
│               │                                                    │
│   3. USER PRESENTS CREDENTIAL                                      │
│      ┌─────────────────┐         ┌─────────────────┐              │
│      │ MS Authenticator│◀───────▶│ Aegis ID        │              │
│      │ (Shows prompt)  │         │ Verifier        │              │
│      └─────────────────┘         └────────┬────────┘              │
│                                           │                        │
│   4. CLAIMS RETURNED TO APP               │                        │
│      ┌─────────────────────────────────────┘                      │
│      │                                                             │
│      │  { "agency": "IRCC", "clearance": "Protected B", ... }     │
│      │                                                             │
│      └─────────────────────────────────────────────────────────▶  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## C.4 Inter-Agency Mobility

### The Revolution: Same Device, Different Access

**When Employee Moves from ESDC → IRCC:**

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   STEP 1: ESDC Revokes Credential (Instant)                       │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │ ❌ ESDC credential marked REVOKED in Aegis ID registry     │  │
│   │ 🔒 All ESDC data on device becomes inaccessible            │  │
│   │ ⚡ Happens in real-time, no device collection needed        │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                                                    │
│   STEP 2: IRCC Issues New Credential (Same Day)                   │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │ ✅ IRCC issues new credential via Verified ID             │  │
│   │ 📱 Employee accepts in MS Authenticator                    │  │
│   │ 🔓 IRCC resources now accessible on SAME device            │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                                                    │
│   RESULT:                                                          │
│   ✅ Same laptop retained                                         │
│   ✅ Previous agency data encrypted/inaccessible                  │
│   ✅ New agency access granted instantly                          │
│   ✅ Zero downtime for employee                                   │
│   💰 No new device procurement                                    │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### How Encryption + DID Claims Work Together

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   EMPLOYEE LAPTOP                                                  │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                                                            │  │
│   │   ┌──────────────────────────────────┐                    │  │
│   │   │  📁 ESDC Files (Local Cache)     │                    │  │
│   │   │                                  │                    │  │
│   │   │  🔒 Encrypted with ESDC CMK      │                    │  │
│   │   │  🔑 Requires: claim:agency=ESDC  │ ❌ NO ACCESS       │  │
│   │   │                                  │    (credential     │  │
│   │   └──────────────────────────────────┘     revoked)       │  │
│   │                                                            │  │
│   │   ┌──────────────────────────────────┐                    │  │
│   │   │  📁 IRCC Files (New)             │                    │  │
│   │   │                                  │                    │  │
│   │   │  🔒 Encrypted with IRCC CMK      │                    │  │
│   │   │  🔑 Requires: claim:agency=IRCC  │ ✅ FULL ACCESS     │  │
│   │   │                                  │    (credential     │  │
│   │   └──────────────────────────────────┘     valid)         │  │
│   │                                                            │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### Security Comparison

| Security Aspect | Certificate Auth | Aegis ID (DID) |
|-----------------|-----------------|----------------|
| **Key Storage** | Smart card/TPM | Authenticator secure enclave |
| **Revocation Speed** | Hours to days (CRL/OCSP) | **Instant** (real-time registry) |
| **Credential Theft** | Export possible | **Non-exportable** |
| **Phishing Resistance** | Moderate | **Strong** (device-bound) |
| **Replay Attacks** | Possible | **Prevented** (nonce-based) |
| **Offline Access** | Yes | Configurable |
| **Audit Trail** | Limited | **Complete** (ledger-backed) |
| **Cross-Agency** | Manual trust establishment | **Automatic** (federated DIDs) |

---

## C.5 Implementation Costs & Savings

### Aegis ID 5-Year TCO

**For Government of Canada (~300,000 employees)**

| Cost Category | Year 1 | Years 2-5 (Annual) | 5-Year Total |
|--------------|--------|-------------------|--------------|
| **Infrastructure** | | | |
| SSC server infrastructure | $800,000 | $200,000 | $1,600,000 |
| HSM for DID signing | $200,000 | $50,000 | $400,000 |
| Network/security zones | $300,000 | $75,000 | $600,000 |
| **Software** | | | |
| Aegis ID development | $2,000,000 | — | $2,000,000 |
| Entra Verified ID config | $500,000 | $100,000 | $900,000 |
| **Operations** | | | |
| SSC operations (4 FTEs) | $500,000 | $500,000 | $2,500,000 |
| **Rollout** | | | |
| Agency onboarding | $1,500,000 | $250,000 | $2,500,000 |
| Training | $500,000 | $100,000 | $900,000 |
| **TOTAL** | **$6,300,000** | **$1,275,000** | **$11,400,000** |

### Annual Savings After Full Deployment

| Current Cost | % Eliminated | Annual Savings |
|-------------|-------------|----------------|
| Certificate issuance | 100% | $4,500,000 |
| Smart card hardware | 100% | $2,000,000 |
| PKI infrastructure | 80% | $2,800,000 |
| Help desk (cert issues) | 90% | $4,500,000 |
| Transition processing | 95% | $2,850,000 |
| Device reprovisioning | 90% | $7,200,000 |
| **TOTAL** | | **$23,850,000** |

### Payback Calculation

| Metric | Value |
|--------|-------|
| Total Investment | $11,400,000 |
| Annual Savings | $23,850,000 |
| **Payback Period** | **6 months** (after full deployment) |
| 5-Year Net Savings | $95,400,000 |

### SSC Data Centre Deployment

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   SSC PRIMARY DATA CENTRE (BORDEN)                                │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                                                            │  │
│   │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐  │  │
│   │   │ Aegis ID     │   │ DID Registry │   │ HSM Cluster  │  │  │
│   │   │ API Cluster  │   │ Nodes (3)    │   │ (Signing)    │  │  │
│   │   │ (HA)         │   │              │   │              │  │  │
│   │   └──────────────┘   └──────────────┘   └──────────────┘  │  │
│   │                                                            │  │
│   └────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              │ Real-time replication               │
│                              ▼                                     │
│   SSC SECONDARY DATA CENTRE (BARRIE)                              │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                        (Mirror)                            │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# PART D: TECHNICAL IMPLEMENTATION - MICROSOFT PURVIEW

## D.1 Prerequisites and Licensing

### Required Licenses

| Feature | License Required |
|---------|-----------------|
| Manual sensitivity labeling | Microsoft 365 E3/A3/G3 or higher |
| Auto-labeling (client-side) | Microsoft 365 E5/A5/G5 |
| Auto-labeling (service-side) | Microsoft 365 E5/A5/G5 Compliance |
| DLP policies | Microsoft 365 E5/A5/G5 or E5 Compliance add-on |
| Advanced auditing | Microsoft 365 E5/A5/G5 or E5 Compliance add-on |
| Dataverse labeling | Microsoft 365 E5 + Purview Data Map |

### Required Permissions

| Role | Purpose |
|------|---------|
| Global Administrator | Initial setup and configuration |
| Compliance Administrator | Create and manage labels/policies |
| Sensitivity Label Administrator | Manage sensitivity labels |
| Information Protection Administrator | Full information protection management |
| Security Reader | View-only access to reports |

### Prerequisites Checklist

- [ ] Appropriate Microsoft 365 licenses assigned
- [ ] Microsoft Purview portal access verified
- [ ] Compliance roles assigned to administrators
- [ ] Unified audit logging enabled
- [ ] Microsoft 365 Apps deployed to users (for client-side labeling)

---

## D.2 Canadian Government Sensitivity Label Taxonomy

### Recommended Label Structure

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

### Label Definitions

| Label | Description | Examples |
|-------|-------------|----------|
| **GC-Unclassified-Public** | Information approved for public release | Press releases, public reports, website content |
| **GC-Unclassified-Internal** | Non-sensitive internal information | Meeting notes, general correspondence |
| **GC-Protected-A** | Low sensitivity personal/business information | Business plans, organizational charts |
| **GC-Protected-B** | Sensitive information requiring protection | SIN, health records, financial data, security assessments |
| **GC-Protected-C** | Extremely sensitive information | National security, critical infrastructure |

### Canadian Sensitive Information Categories

| Category | Examples | Purview SIT | OOB Template |
|----------|----------|-------------|--------------|
| **Financial Data** | Bank accounts, credit cards | Canada Bank Account Number, Credit Card | Canada Financial Data |
| **Health Information** | Medical records, health card numbers | Canada Health Service Number, Canada PHIN | Canada HIA/PHIPA/PHIA |
| **Government IDs** | SIN, passport, driver's license | Canada SIN, Canada Passport | Canada PII/PIPEDA |
| **Personal Privacy** | Combined PII elements | Multiple SITs | Canada PIPA/PIPEDA |

---

## D.3 Creating Sensitivity Labels

### Access the Microsoft Purview Portal

1. Navigate to: `https://purview.microsoft.com`
2. Sign in with Compliance Administrator credentials
3. Select **Solutions** > **Information Protection** > **Sensitivity labels**

### Create Parent Label: GC-Protected-B (CRITICAL)

| Field | Value |
|-------|-------|
| Name | `GC-Protected-B` |
| Display Name | `Protected B` |
| Description for users | `Sensitive information that could cause serious injury to an individual, organization, or government if disclosed. Includes personal health information, SIN, financial data.` |
| Color | Orange (#FF6600) |

**Protection Settings (Recommended):**

| Setting | Configuration |
|---------|--------------|
| Encryption | Encrypt with organization key (CMK) |
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

### Protected B Sub-sublabels

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

### Label Priority Order

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

## D.4 Sensitive Information Types for Canada

### Built-in Canadian SITs

| SIT Name | Pattern | Confidence Level | OOB Template |
|----------|---------|------------------|--------------|
| Canada Bank Account Number | 7-12 digits + keywords | Medium-High | Financial |
| Canada Driver's License Number | Province-specific patterns | Medium | Privacy/PII |
| Canada Health Service Number | Province-specific patterns | Medium | Health |
| Canada Passport Number | 8 alphanumeric | Medium-High | Privacy/PII |
| Canada Personal Health Identification Number (PHIN) | Province-specific | Medium | Health |
| Canada Social Insurance Number (SIN) | 9 digits (XXX-XXX-XXX) | High | Privacy/PII |
| Credit Card Number | Standard patterns | High | Financial |

### SIN Detection Details

**High Confidence:**
- Pattern: `\d{3}[- ]\d{3}[- ]\d{3}` (formatted)
- Plus: Keywords from `Keyword_sin` AND `Keyword_sin_collaborative`
- Plus: Valid Luhn checksum

**Medium Confidence:**
- Pattern: `\d{9}` (unformatted)
- Plus: Keyword from `Keyword_sin`
- Plus: Valid Luhn checksum

**Keywords include:** sin, social insurance, numero d'assurance sociale, sins, ssn, ssns, social security, numero d'assurance social, national identification number, national id, sin#, soc ins, social ins

### SIT Mapping to OOB Templates

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

## D.5 Label Policies and Publishing

### Create Label Publishing Policy

**Navigate to:** Microsoft Purview Portal > Information Protection > Label policies > **Publish labels**

### Policy Configuration: GC-Standard-Policy

**Step 1: Choose Labels to Publish**

Select all labels created:
- [x] GC-Unclassified (and sublabels)
- [x] GC-Protected (and sublabels)

**Step 2: Publish to Users and Groups**

| Scope | Selection |
|-------|-----------|
| Users | All users in organization |
| Groups | Specific security groups (if phased rollout) |

**Step 3: Policy Settings**

| Setting | Configuration | Rationale |
|---------|--------------|-----------|
| **Apply default label to documents** | GC-Unclassified-Internal | Ensures all documents have a baseline label |
| **Apply default label to emails** | GC-Unclassified-Internal | Ensures all emails are labeled |
| **Apply default label to meetings** | GC-Unclassified-Internal | If meetings scope enabled |
| **Require users to apply a label** | Yes | Mandatory labeling for compliance |
| **Require justification for label change** | Yes (for downgrade only) | Audit trail for label changes |
| **Provide help link to custom page** | `https://[your-intranet]/data-classification` | User guidance |

---

## D.6 Auto-Labeling Policies - OOB Canadian Templates

### Overview of Canadian OOB Templates

When creating auto-labeling policies in Microsoft Purview, filter by **Canada** to see available templates:

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

### Implementation Strategy

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

### Auto-Labeling Policy Summary

After implementing all policies:

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

### Simulation Mode Best Practices

**Before enabling any policy:**

1. **Run in simulation mode for minimum 7-14 days**
2. Review simulation results:
   - Navigate to: Policy > View simulation
   - Check total items matched
   - Review items by location
   - Examine sample content for false positives

3. **Enable policies in phases:**
   - Week 1: Enable Financial policies
   - Week 2: Enable Health policies
   - Week 3: Enable Privacy policies
   - Week 4: Enable Custom comprehensive policy

---

## D.7 Data Loss Prevention (DLP) Policies

### DLP Policy Strategy

DLP policies complement auto-labeling by providing real-time protection and user notifications. Use the same OOB templates for consistency.

### Create DLP Policies from Canadian Templates

| DLP Policy | Template | Actions |
|------------|----------|---------|
| GC-DLP-Financial-CanadaFinancialData | Canada Financial Data | Notify, Block external (high count) |
| GC-DLP-Financial-PCIDSS | PCI DSS | Notify, Block external (high count) |
| GC-DLP-Health-CanadaHIA | Canada HIA | Notify, Block external (high count) |
| GC-DLP-Privacy-CanadaPIPEDA | Canada PIPEDA | Notify, Block external (high count) |
| GC-DLP-Privacy-CanadaPII | Canada PII | Notify, Block external (high count) |
| GC-DLP-Custom-ProtectedB | Custom | Full protection suite |

### Custom DLP Policy for Protected B

**Rule 1: Protected B - Awareness (Low Volume)**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Protected B - Low Volume Alert` |
| Conditions | Content contains 1-9 instances of ANY Canadian SIT |
| Actions | Display policy tip to user, Send incident report |
| Severity | Low |

**Rule 2: Protected B - Block External (High Volume)**

| Setting | Configuration |
|---------|--------------|
| Rule name | `Protected B - High Volume Block` |
| Conditions | Content contains 10+ instances of ANY Canadian SIT OR content labeled "GC-Protected-B" AND shared externally |
| Actions | Block external sharing, Display blocking policy tip, Send incident report, Generate alert |
| User override | Allow with business justification |
| Severity | High |

**Rule 3: SIN Specific - Critical Protection**

| Setting | Configuration |
|---------|--------------|
| Rule name | `SIN Detection - Immediate Alert` |
| Conditions | Content contains 1+ Canada SIN (High confidence) AND shared externally or to unmanaged device |
| Actions | Block immediately, Display blocking banner, Require manager approval to override, Generate critical alert |
| Severity | Critical |

---

## D.8 User Notifications, Banners, and Alerts

### Policy Tip Messages

| Scenario | Policy Tip Text |
|----------|-----------------|
| SIN Detected | `⚠️ This document appears to contain a Social Insurance Number (SIN). This is Protected B information. Please apply the "Protected B - Personal Information" label before sharing.` |
| Health Info Detected | `⚠️ Health information detected (Health Card/PHIN). This content requires Protected B classification under HIA/PHIPA/PHIA. Please review and apply the "Protected B - Health" label.` |
| Financial Data | `⚠️ Financial account information detected (Credit Card/Bank Account). Apply "Protected B - Financial" label to ensure proper protection.` |
| External Share Attempt | `🚫 You are attempting to share Protected B information externally. This action is blocked. Please remove sensitive content or obtain manager approval.` |

### Justification Dialog

When users attempt to downgrade or remove a label:

```
┌──────────────────────────────────────────────────────────────────────┐
│  Justification Required                                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  You are changing the sensitivity label from:                        │
│  "Protected B - Personal" → "Unclassified - Internal"               │
│                                                                      │
│  Please provide a business justification:                            │
│                                                                      │
│  ○ The previous label was applied incorrectly                       │
│  ○ The content no longer contains sensitive information             │
│  ○ Manager approved this change                                     │
│  ○ Other: ________________                                          │
│                                                                      │
│               [Submit Justification]    [Cancel]                     │
└──────────────────────────────────────────────────────────────────────┘
```

### Alert Configuration for Security Team

| Alert Type | Trigger | Severity | Recipients |
|------------|---------|----------|------------|
| SIN Detected - External Share | Any SIN shared externally | Critical | Security Team, Manager |
| High Volume PII | 10+ PII instances | High | Security Team |
| Label Downgrade | Protected B → lower | Medium | Security Team |
| Label Removed | Any Protected label removed | High | Security Team |
| Policy Override | User overrides block | Medium | Security Team |

---

## D.9 Power Platform Integration

### Register Dataverse in Purview Data Map

**Prerequisites:**
- Microsoft 365 E5 license or Purview pay-as-you-go
- Purview Data Map enabled
- Power Platform admin permissions

**Steps:**

1. Navigate to: Microsoft Purview Portal > Data Map > Sources
2. Select **Register** > **Power Platform** > **Dataverse**
3. Provide connection details:
   - Environment URL (from Power Platform Admin Center)
   - Authentication method (Service Principal recommended)
4. Grant Purview Data Reader access to Dataverse

### Configure Scan

| Setting | Configuration |
|---------|--------------|
| Scan name | `GC-Dataverse-Scan` |
| Tables | All tables or specific selection |
| Credential | Service principal |
| Scan frequency | Weekly |
| Classification | Enable all Canadian SITs |

### Power BI Sensitivity Labels

**Enable labels in Power BI:**

1. Power BI Admin Portal > Tenant Settings > Information protection
2. Enable:
   - Allow users to apply sensitivity labels
   - Apply sensitivity labels from data sources
   - Automatically apply sensitivity labels to downstream content
   - Allow workspace admins to override labels

**Label inheritance:**
- Labels flow from data sources to datasets to reports
- Protected B data in Dataverse → Protected B report in Power BI

---

## D.10 Dashboard and Reporting

### Microsoft Purview Dashboards

**Access:** Microsoft Purview Portal > Solutions > Information Protection > Overview

| Report | Purpose | Key Metrics |
|--------|---------|-------------|
| **Data Overview** | Summary of labeled content | Labels applied, content by location |
| **Activity Explorer** | Detailed activity tracking | Label changes, who/when/what |
| **Content Explorer** | Browse labeled content | Items by label, location, type |
| **Label Analytics** | Label usage trends | Adoption rates, label distribution |

### Key Activities to Monitor

| Activity | What It Shows | Alert Priority |
|----------|---------------|----------------|
| Sensitivity label applied | New labels on content | Low |
| Sensitivity label changed | Upgrades or downgrades | Medium (downgrade) |
| Sensitivity label removed | Labels stripped | High |
| DLP policy matched | Sensitive content detected | Medium-High |
| File shared externally | External sharing events | High |

### Compliance Targets

| Metric | Target | Action if Not Met |
|--------|--------|-------------------|
| Protected B label adoption | >90% of sensitive content | Review auto-labeling policies |
| DLP policy match rate | Declining over time | Indicates improved user behavior |
| External share blocks | Low volume | Effective policy |
| Label downgrade rate | <5% | Review justifications |

---

# PART E: PLATFORM IMPLEMENTATION GUIDE

## E.1 Microsoft 365 Office Applications

### Prerequisites

| Requirement | Details |
|-------------|---------|
| Licenses | Microsoft 365 E3/E5, Office 365 E3/E5 |
| Office Version | Microsoft 365 Apps (Version 1910+) |
| Authentication | Users signed in with M365 work account |

### Supported Applications

| Application | Windows | Mac | Web | Mobile |
|-------------|---------|-----|-----|--------|
| Word | ✅ | ✅ | ✅ | ✅ |
| Excel | ✅ | ✅ | ✅ | ✅ |
| PowerPoint | ✅ | ✅ | ✅ | ✅ |
| Visio | ✅ | ❌ | ✅ | ❌ |

### User Experience

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

### Supported File Types

| Extension | Auto-label | Manual Label | Encryption |
|-----------|------------|--------------|------------|
| .docx, .docm | ✅ | ✅ | ✅ |
| .xlsx, .xlsm | ✅ | ✅ | ✅ |
| .pptx, .pptm | ✅ | ✅ | ✅ |
| .pdf | ✅ | ✅ | ✅ |
| .txt | ❌ | ❌ | ❌ |
| .csv | ❌ | ❌ | ❌ |

---

## E.2 Microsoft Outlook (Email)

### Configuration

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

### Email Encryption Behavior

| Label Setting | Internal Recipients | External Recipients |
|--------------|--------------------|--------------------|
| No encryption | Normal delivery | Normal delivery |
| Encrypt (org only) | Normal delivery | Blocked or OME portal |
| Encrypt (all authenticated) | Normal delivery | OME portal access |

### Outlook-Specific Settings

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

## E.3 SharePoint Online

### Enable Sensitivity Labels

```powershell
# Connect to SharePoint Online
Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"

# Enable sensitivity labels
Set-SPOTenant -EnableAIPIntegration $true

# Verify
Get-SPOTenant | Select-Object EnableAIPIntegration
```

### Enable Container Labels

```powershell
# Connect to Azure AD
Connect-AzureAD

# Enable MIP Labels for containers
$Setting = Get-AzureADDirectorySetting | Where-Object {$_.DisplayName -eq "Group.Unified"}
$Setting["EnableMIPLabels"] = "True"
Set-AzureADDirectorySetting -Id $Setting.Id -DirectorySetting $Setting

# Sync labels
Connect-IPPSSession
Execute-AzureAdLabelSync
```

### Apply Labels to Sites

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

---

## E.4 Microsoft Teams

### Teams Files

Teams channel files are stored in SharePoint. Labels applied in Teams appear in SharePoint and vice versa.

### Teams Team Labels (Container)

**Via PowerShell:**

```powershell
# Connect to Microsoft Teams
Connect-MicrosoftTeams

# Apply sensitivity label to team
Set-Team -GroupId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -SensitivityLabel "GC-Protected-B"
```

### Meeting Labels (Teams Premium)

| Setting | Configurable via Label |
|---------|----------------------|
| Lobby bypass | ✅ |
| Who can present | ✅ |
| Meeting chat | ✅ |
| Record meetings | ✅ |
| Watermarking | ✅ |
| End-to-end encryption | ✅ |

---

## E.5 Power BI / Microsoft Fabric

### Enable in Admin Portal

1. Navigate to: app.powerbi.com
2. Select: Settings > Admin portal > Tenant settings > Information protection
3. Enable:
   - Allow users to apply sensitivity labels
   - Apply sensitivity labels from data sources
   - Automatically apply sensitivity labels to downstream content
   - Allow workspace admins to override labels

### Label Inheritance Flow

```
Data Source (Excel in SharePoint)
Label: Protected B - Financial
         │
         ▼
Power BI Dataset
Label: Protected B - Financial (inherited)
         │
         ├────────────────┬────────────────┐
         ▼                ▼                ▼
     Report 1         Report 2         Dashboard
  (Protected B)    (Protected B)    (Protected B)
         │
         ▼
  Export to Excel
  (Protected B encryption applied)
```

### Export Protection

| Export Format | Label Applied | Encryption |
|---------------|--------------|------------|
| Excel (.xlsx) | ✅ | ✅ (if configured) |
| PowerPoint (.pptx) | ✅ | ✅ (if configured) |
| PDF | ✅ | ✅ (if configured) |
| .pbix download | ✅ | ✅ (if configured) |
| CSV | ❌ | ❌ |

---

## E.6 Power Platform - Dataverse

### Register in Purview Data Map

1. Navigate to: purview.microsoft.com > Data Map > Sources
2. Select: **Register** > **Dataverse**
3. Configure:
   - Name: `GC-Dataverse-Production`
   - Environment URL: `https://org12345.crm3.dynamics.com`
   - Collection: Power Platform

### Configure Authentication (SAMI)

1. Create scan, select **Microsoft Purview MSI (system)**
2. Note the Managed Identity Application ID
3. Create Application User in Dataverse:
   - Power Platform Admin Center > Environments > Settings > Application users
   - Add Purview MSI with **Service Reader** role

### Configure Scan

| Setting | Recommended Value |
|---------|-------------------|
| Frequency | Weekly |
| Day | Sunday |
| Time | 02:00 AM |
| Classifications | All Canadian SITs enabled |

### View Results in Data Catalog

```
┌─────────────────────────────────────────────────────────────────────┐
│  gc_citizen_application (Table)                                     │
├─────────────────────────────────────────────────────────────────────┤
│  Columns:                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Column Name      │ Data Type │ Classification              │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │ gc_sin           │ nvarchar  │ 🔒 Canada SIN               │   │
│  │ gc_healthcard    │ nvarchar  │ 🔒 Canada PHIN              │   │
│  │ gc_firstname     │ nvarchar  │ Person Name                 │   │
│  │ gc_address       │ nvarchar  │ Canada Physical Address     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Sensitivity Label: 🔒 Protected B - Personal Information           │
└─────────────────────────────────────────────────────────────────────┘
```

---

# PART F: IMPLEMENTATION ROADMAP

## F.1 Phased Implementation Timeline

### Combined 18-Month Roadmap

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  YEAR 1                                           YEAR 2           │
│  Q1       Q2       Q3       Q4       Q1       Q2                  │
│  ────────────────────────────────────────────────────────────     │
│                                                                    │
│  ┌─────────────────────────────────────┐                          │
│  │ PURVIEW + HSM DEPLOYMENT            │                          │
│  │ • Entrust HSM procurement           │                          │
│  │ • Azure Key Vault BYOK              │                          │
│  │ • Label creation & testing          │                          │
│  │ • Auto-labeling policies            │                          │
│  │ • DLP deployment                    │                          │
│  └─────────────────────────────────────┘                          │
│                                                                    │     
│           ┌─────────────────────────────────────┐                 │
│           │ Aegis ID DEVELOPMENT                │                 │
│           │ • Core platform build               │                 │
│           │ • SSC data centre deployment        │                 │
│           │ • Entra Verified ID integration     │                 │
│           │ • DID method implementation         │                 │
│           └─────────────────────────────────────┘                 │
│                                                                    │
│                    ┌───────────────────────────────────────────┐  │
│                    │ AGENCY ROLLOUT                            │  │
│                    │ • Pilot agencies (5)                      │  │
│                    │ • Full rollout (100+ departments)         │  │
│                    │ • Certificate phase-out                   │  │
│                    └───────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## F.2 Implementation Checklist

### Phase 1: Foundation (Days 1-7)

- [ ] Verify licensing requirements (E5 for auto-labeling)
- [ ] Assign compliance administrator roles
- [ ] Enable unified audit logging
- [ ] Access Microsoft Purview portal
- [ ] Begin Entrust HSM procurement

### Phase 2: Label Creation (Days 8-14)

- [ ] Create GC-Unclassified labels (Public, Internal)
- [ ] Create GC-Protected-A label
- [ ] Create GC-Protected-B label
- [ ] Create Protected B sublabels (Personal, Financial, Health)
- [ ] Configure label protection settings with CMK
- [ ] Set label priority order
- [ ] Test labels in pilot group

### Phase 3: HSM Deployment (Days 15-90)

- [ ] Install Entrust nShield HSMs in SSC data centres
- [ ] Configure Key Management Server
- [ ] Establish BYOK connection to Azure Key Vault
- [ ] Configure CMK for Microsoft 365 services
- [ ] Test encryption/decryption operations
- [ ] Establish backup and DR procedures

### Phase 4: Auto-Labeling - Financial (Days 91-97)

- [ ] Create Canada Financial Data policy (simulation)
- [ ] Create PCI DSS policy (simulation)
- [ ] Run simulation for 7 days
- [ ] Review results and adjust
- [ ] Enable policies

### Phase 5: Auto-Labeling - Health (Days 98-104)

- [ ] Create Canada HIA policy (simulation)
- [ ] Create Canada PHIPA policy (simulation)
- [ ] Create Canada PHIA policy (simulation)
- [ ] Run simulation for 7 days
- [ ] Enable policies

### Phase 6: Auto-Labeling - Privacy (Days 105-111)

- [ ] Create Canada PIPA policy (simulation)
- [ ] Create Canada PIPEDA policy (simulation)
- [ ] Create Canada PII policy (simulation)
- [ ] Run simulation for 7 days
- [ ] Enable policies

### Phase 7: DLP Policies (Days 112-125)

- [ ] Create DLP policies from OOB templates
- [ ] Create custom Protected B DLP policy
- [ ] Configure policy tips and notifications
- [ ] Run in simulation mode
- [ ] Enable blocking rules

### Phase 8: Power Platform Integration (Days 126-140)

- [ ] Register Dataverse in Purview Data Map
- [ ] Configure Dataverse scan
- [ ] Enable sensitivity labels in Power BI
- [ ] Test label inheritance

### Phase 9: Aegis ID Development (Months 5-12)

- [ ] Complete technical design
- [ ] Deploy infrastructure to SSC data centres
- [ ] Develop DID resolver and issuer services
- [ ] Integrate with Entra Verified ID
- [ ] Create agency credential templates
- [ ] Develop OIDC provider

### Phase 10: Agency Rollout (Months 13-18)

- [ ] Select 5 pilot agencies
- [ ] Deploy Aegis ID to pilots
- [ ] Test inter-agency mobility
- [ ] Refine based on feedback
- [ ] Full rollout to all departments
- [ ] Begin certificate phase-out

---

## F.3 Success Metrics

### Phase 1 (30 days)

- [ ] 100% of labels published to users
- [ ] Mandatory labeling enabled
- [ ] Baseline Activity Explorer reports established

### Phase 2 (60 days)

- [ ] >80% of documents labeled
- [ ] Canadian OOB templates active (simulation)
- [ ] DLP policies in simulation mode

### Phase 3 (90 days)

- [ ] Auto-labeling fully enabled
- [ ] DLP blocking active
- [ ] CMK deployed and operational

### Ongoing Targets

| Metric | Target |
|--------|--------|
| Sensitive documents labeled | >95% |
| Unlabeled sensitive documents | <5% |
| External sharing violations detected | 100% |
| Mean time to revoke access (Aegis ID) | <1 hour |
| Device reprovisioning for transfers | <10% of current |
| Certificate-related help desk tickets | -90% |

---

# APPENDICES

## Appendix A: Reference Documentation

### Microsoft Purview - Sensitivity Labels

| Topic | URL |
|-------|-----|
| Learn about sensitivity labels | https://learn.microsoft.com/en-us/purview/sensitivity-labels |
| Create and publish sensitivity labels | https://learn.microsoft.com/en-us/purview/create-sensitivity-labels |
| Get started with sensitivity labels | https://learn.microsoft.com/en-us/purview/get-started-with-sensitivity-labels |
| Auto-labeling policies | https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically |

### Data Loss Prevention

| Topic | URL |
|-------|-----|
| Learn about DLP | https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp |
| DLP policy templates | https://learn.microsoft.com/en-us/purview/dlp-policy-templates-include |
| DLP policy tips | https://learn.microsoft.com/en-us/purview/dlp-use-notifications-and-policy-tips |

### Power Platform

| Topic | URL |
|-------|-----|
| Dataverse in Purview | https://learn.microsoft.com/en-us/purview/register-scan-dataverse |
| Power BI sensitivity labels | https://learn.microsoft.com/en-us/power-bi/enterprise/service-security-sensitivity-label-overview |

### Canadian Privacy

| Topic | URL |
|-------|-----|
| OPC Sensitive Information Guidance | https://www.priv.gc.ca/en/privacy-topics/privacy-laws-in-canada/pipeda-interpretation-bulletins/interpretations_10_sensible/ |
| Canada SIN SIT | https://learn.microsoft.com/en-us/purview/sit-defn-canada-social-insurance-number |

### W3C DID Standards

| Standard | URL |
|----------|-----|
| DID Core | https://www.w3.org/TR/did-core |
| VC Data Model | https://www.w3.org/TR/vc-data-model |

### HSM Vendors

| Vendor | Contact |
|--------|---------|
| Entrust | gc-sales@entrust.com |
| Thales | canada.sales@thalesgroup.com |
| Azure Managed HSM | docs.microsoft.com/azure/key-vault/managed-hsm |

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Aegis ID** | Custom GC decentralized identity service |
| **BYOK** | Bring Your Own Key - import customer keys to Azure |
| **CMK** | Customer-Managed Keys - encryption keys you control |
| **DID** | Decentralized Identifier - W3C standard for digital identity |
| **DLP** | Data Loss Prevention - policies that prevent unauthorized sharing |
| **HSM** | Hardware Security Module - tamper-resistant key storage |
| **OIDC** | OpenID Connect - authentication protocol |
| **PHIN** | Personal Health Identification Number |
| **PIPEDA** | Personal Information Protection and Electronic Documents Act |
| **Protected B** | Canadian government classification for sensitive information |
| **Purview** | Microsoft's unified data governance and compliance platform |
| **SIN** | Social Insurance Number |
| **SIT** | Sensitive Information Type - patterns used to detect sensitive data |
| **VC** | Verifiable Credential - cryptographically signed claim |
| **Verified ID** | Microsoft Entra's verifiable credentials service |

---

## Appendix C: Compliance Mapping

| Requirement | Purview | CMK | Aegis ID |
|-------------|---------|-----|----------|
| PIPEDA - Safeguards | ✅ | ✅ | ✅ |
| PIPEDA - Accountability | ✅ | ✅ | ✅ |
| ITSG-33 IA-2 (MFA) | | | ✅ |
| ITSG-33 IA-5 (Authenticator Mgmt) | | | ✅ |
| ITSG-33 SC-8 (Transmission) | ✅ | ✅ | |
| ITSG-33 SC-12 (Crypto Key Mgmt) | | ✅ | ✅ |
| ITSG-33 SC-28 (Data at Rest) | ✅ | ✅ | |
| ITSG-33 AU-2 (Audit) | ✅ | ✅ | ✅ |
| TBS Identity Directive | | | ✅ |
| Provincial Health Acts (HIA/PHIPA/PHIA) | ✅ | ✅ | |
| CPPA (proposed) | ✅ | ✅ | ✅ |

---

## Appendix D: Quick Reference Cards

### OOB Template Selection Guide

| If You Need To Protect... | Use Template | Category |
|---------------------------|--------------|----------|
| Credit cards, bank accounts | Canada Financial Data | Financial |
| Payment card data (PCI) | PCI DSS | Financial |
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

### Contact Information

 contact@vanguardcs.ca 