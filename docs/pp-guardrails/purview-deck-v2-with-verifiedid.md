---
marp: true
theme: default
paginate: true
backgroundColor: #fff
header: '**Government of Canada** | Information Protection & Identity Strategy'
footer: 'PROTECTED B | December 2025'
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
  }
  h1 {
    color: #1a1a2e;
  }
  h2 {
    color: #16213e;
  }
  .highlight {
    background: linear-gradient(120deg, #ffd700 0%, #ffd700 100%);
    background-repeat: no-repeat;
    background-size: 100% 40%;
    background-position: 0 90%;
  }
---

<!-- _class: lead -->
<!-- _backgroundColor: #1a1a2e -->
<!-- _color: white -->

# 🛡️ Protecting Government Data in the Cloud Era

## Microsoft Purview Information Protection
## + Aegis ID Decentralized Identity

### Executive Strategy Briefing

**December 2025**

---

# Agenda

## What We'll Cover Today

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  PART 1: THE THREAT LANDSCAPE                                     │
│  └─ Why data protection is urgent                                 │
│                                                                    │
│  PART 2: MICROSOFT PURVIEW INFORMATION PROTECTION                 │
│  └─ Classification, encryption, monitoring                        │
│                                                                    │
│  PART 3: IMPLEMENTATION COSTS & HSM OPTIONS                       │
│  └─ Detailed cost analysis, Entrust & alternatives, SSC mgmt      │
│                                                                    │
│  PART 4: Aegis ID - DECENTRALIZED IDENTITY FOR GOC                │
│  └─ Replacing certificate auth, cross-agency mobility             │
│                                                                    │
│  PART 5: COMBINED ROI & RECOMMENDATIONS                           │
│  └─ Total savings, implementation roadmap                         │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

<!-- _class: lead -->
<!-- _backgroundColor: #dc3545 -->
<!-- _color: white -->

# PART 1
# The Threat Landscape

---

# The Challenge We Face

## Today's Threat Landscape is Unprecedented

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   🎯 Nation-State Actors      💰 Ransomware Gangs              │
│                                                                 │
│   🔓 Supply Chain Attacks     👤 Insider Threats               │
│                                                                 │
│   ☁️ Cloud Misconfigurations  🤖 AI-Powered Attacks            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

> **Key Insight:** The perimeter is gone. Data itself must be the security boundary.

---

# By The Numbers

## 2024-2025 Breach Statistics

| Metric | Value | Trend |
|--------|-------|-------|
| Average cost of data breach | **$4.88M USD** | ↑ 10% |
| Breaches involving cloud | **82%** | ↑ 15% |
| Time to identify breach | **194 days** | — |
| Breaches with stolen credentials | **61%** | ↑ 8% |

<br>

### 🇨🇦 **Canadian Federal Context**
- **Protected B** data spans 100+ departments
- **300,000+** federal employees across agencies
- **PIPEDA** compliance mandatory
- Foreign adversary interest at **all-time high**

---

<!-- _backgroundColor: #dc3545 -->
<!-- _color: white -->

# ⚠️ The Microsoft Risk Factor

## What Happens When Your Cloud Provider is Compromised?

### Recent High-Profile Incidents:

- **Storm-0558 (2023):** Chinese hackers accessed US government emails via compromised Microsoft signing key
  
- **Midnight Blizzard (2024):** Russian actors accessed Microsoft executive emails and source code

- **Multiple Zero-Days:** Ongoing discovery of Exchange, SharePoint vulnerabilities

### **The Reality:** Microsoft is a high-value target. GC data must remain secure even if Microsoft is breached.

---

# The Uncomfortable Truth

## With Standard Microsoft Encryption...

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│    YOUR DATA          MICROSOFT KEYS         POTENTIAL ACCESS   │
│                                                                 │
│    ┌─────────┐        ┌─────────────┐        ┌─────────────┐   │
│    │ 📄 📊 📧 │───────▶│ 🔑 Microsoft │───────▶│ ❓ Unknown  │   │
│    │  Data   │        │   Managed   │        │   Actors    │   │
│    └─────────┘        └─────────────┘        └─────────────┘   │
│                                                                 │
│    ⚠️ If Microsoft keys are compromised, your data is at risk  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Microsoft holds the keys. Microsoft can be compelled. Microsoft can be breached.

---

<!-- _class: lead -->
<!-- _backgroundColor: #0d6efd -->
<!-- _color: white -->

# PART 2
# Microsoft Purview Information Protection

---

# The Solution: You Control The Keys

## Customer-Managed Encryption + Sensitivity Labels

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│    YOUR DATA          YOUR KEYS              YOUR CONTROL       │
│                                                                 │
│    ┌─────────┐        ┌─────────────┐        ┌─────────────┐   │
│    │ 📄 📊 📧 │───────▶│ 🔐 Azure    │───────▶│ ✅ Only You │   │
│    │  Data   │        │  Key Vault  │        │   Decide    │   │
│    └─────────┘        │  (Your HSM) │        └─────────────┘   │
│                       └─────────────┘                           │
│                                                                 │
│    ✅ Even if Microsoft is breached, data remains encrypted    │
│    ✅ You can revoke access instantly                          │
│    ✅ Full audit trail of key usage                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

# Microsoft Purview: The Strategy

## Three Pillars of Data Protection

```
        ┌─────────────────────────────────────────────┐
        │                                             │
        │           INFORMATION PROTECTION            │
        │                                             │
        └─────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
   │  CLASSIFY   │   │   PROTECT   │   │   MONITOR   │
   │             │   │             │   │             │
   │ Sensitivity │   │ Encryption  │   │   DLP &     │
   │   Labels    │   │ & Controls  │   │  Auditing   │
   └─────────────┘   └─────────────┘   └─────────────┘
```

---

# Pillar 1: Classify

## Automatic Detection of Canadian Sensitive Information

| Data Type | Detection Method | Risk Level |
|-----------|-----------------|------------|
| 🆔 Social Insurance Numbers | Pattern + Checksum | **CRITICAL** |
| 🏥 Health Card Numbers | Provincial patterns | **HIGH** |
| 💳 Financial Account Data | Pattern matching | **HIGH** |
| 🛂 Passport Numbers | Format validation | **MEDIUM** |
| 📍 Personal Addresses | Named entity | **MEDIUM** |

### **Canadian OOB Templates:**
- Financial: Canada Financial Data, PCI DSS
- Health: Canada HIA, PHIPA (Ontario), PHIA (Manitoba)
- Privacy: Canada PIPEDA, PIPA, PII

---

# Pillar 2: Protect

## Encryption That Travels With The Data

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   📄 Protected B Document                                        │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │  🔒 ENCRYPTED + LABELED                                   │  │
│   │                                                           │  │
│   │  ✅ Email attachment → Still encrypted                    │  │
│   │  ✅ Downloaded to USB → Still encrypted                   │  │
│   │  ✅ Shared externally → Still encrypted                   │  │
│   │  ✅ Uploaded elsewhere → Still encrypted                  │  │
│   │  ✅ Printed → Watermarked                                 │  │
│   │                                                           │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

# Pillar 3: Monitor

## Complete Visibility Into Data Access

### Real-Time Dashboards Show:

- 📊 **Who** accessed sensitive documents
- 📍 **Where** data is being accessed from
- ⏰ **When** access occurred
- 🔄 **What** actions were taken
- ⚠️ **Alerts** for policy violations

### Integration Points:
- Microsoft Defender XDR
- Microsoft Sentinel SIEM
- Unified Audit Log (7+ year retention)

---

<!-- _class: lead -->
<!-- _backgroundColor: #198754 -->
<!-- _color: white -->

# PART 3
# Implementation Costs & HSM Options

---

# Total Cost of Implementation

## Purview Information Protection - 5 Year TCO

### **For 10,000 Users (Typical Large Department)**

| Cost Category | Year 1 | Years 2-5 (Annual) | 5-Year Total |
|--------------|--------|-------------------|--------------|
| **Licensing** | | | |
| M365 E5 Compliance Add-on | $1,440,000 | $1,440,000 | $7,200,000 |
| **Infrastructure** | | | |
| Azure Key Vault Premium | $48,000 | $48,000 | $240,000 |
| HSM Solution (see options) | $150,000-500,000 | $50,000-150,000 | $350,000-1,100,000 |
| **Services** | | | |
| Implementation Partner | $500,000 | — | $500,000 |
| SSC Operations (2 FTEs) | $300,000 | $300,000 | $1,500,000 |
| **Training** | $100,000 | $25,000 | $200,000 |
| | | | |
| **TOTAL** | **$2.5M-$2.9M** | **$1.9M-$2.0M** | **$10M-$10.7M** |

---

# Microsoft 365 Licensing Breakdown

## Purview Requirements by License Tier

| Feature | E3 | E5 | E5 Compliance |
|---------|----|----|---------------|
| Manual sensitivity labels | ✅ | ✅ | ✅ |
| Auto-labeling (client) | ❌ | ✅ | ✅ |
| Auto-labeling (service) | ❌ | ✅ | ✅ |
| DLP for Exchange/SharePoint | ✅ | ✅ | ✅ |
| DLP for Teams chat | ❌ | ✅ | ✅ |
| Endpoint DLP | ❌ | ✅ | ✅ |
| Activity Explorer | ❌ | ✅ | ✅ |
| Advanced auditing | ❌ | ✅ | ✅ |
| Customer-Managed Keys | ❌ | ✅ | ✅ |

### **Recommendation:** E5 Compliance Add-on ($12/user/month) for E3 customers

---

# HSM Solutions Comparison

## Hardware Security Module Options for CMK

### **Evaluation Criteria:**
- FIPS 140-2 Level 3 certification (minimum for GC)
- Canadian data residency
- Azure Key Vault integration
- SSC operational compatibility

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐          │
│   │   Entrust    │   │    Thales    │   │Azure Managed │          │
│   │   nShield    │   │    Luna      │   │     HSM      │          │
│   └──────────────┘   └──────────────┘   └──────────────┘          │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Option 1: Entrust nShield

## SSC-Preferred Government Solution

### **Strengths:**
- ✅ **Existing GC relationship** - SSC has operational experience
- ✅ **Canadian company** - Ottawa headquarters
- ✅ **FIPS 140-2 Level 3** certified
- ✅ **ITSG-33 aligned** - Designed for Canadian government
- ✅ **On-premises deployment** - Full data sovereignty

### **Product Options:**

| Model | Crypto Ops/sec | Use Case | Est. Cost |
|-------|---------------|----------|-----------|
| nShield Connect XC | 20,000 | Enterprise | $75,000 |
| nShield Connect XC High | 60,000 | High-volume | $150,000 |
| nShield as a Service | N/A | Cloud-managed | $3,500/mo |

---

# Entrust Architecture with Azure

## On-Premises HSM + Azure Key Vault BYOK

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
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Option 2: Thales Luna

## Industry-Leading HSM Platform

### **Strengths:**
- ✅ **Highest performance** - Up to 20,000 ECC ops/sec
- ✅ **Azure native integration** - Luna Cloud HSM
- ✅ **FIPS 140-2 Level 3** certified
- ✅ **Hybrid deployment** - On-prem + cloud

### **Product Options:**

| Model | Crypto Ops/sec | Use Case | Est. Cost |
|-------|---------------|----------|-----------|
| Luna Network HSM 7 | 10,000 | Standard | $60,000 |
| Luna Network HSM 7 (High) | 20,000 | High-volume | $120,000 |
| Luna Cloud HSM | Variable | Cloud-native | $2,800/mo |
| Luna Backup HSM | N/A | Disaster recovery | $25,000 |

---

# Option 3: Azure Managed HSM

## Cloud-Native Microsoft Solution

### **Strengths:**
- ✅ **Native Azure integration** - Seamless Key Vault connectivity
- ✅ **Canadian regions available** - Canada Central, Canada East
- ✅ **FIPS 140-2 Level 3** certified
- ✅ **No hardware management** - Fully managed service
- ✅ **Lower upfront cost** - Pay-as-you-go

### **Pricing:**

| Component | Monthly Cost | Annual Cost |
|-----------|-------------|-------------|
| Managed HSM Pool (Standard) | $4,032 | $48,384 |
| Key operations (per 10,000) | $0.03 | Variable |
| Premium Key Vault (backup) | $1/key/month | Variable |

### **Consideration:** Keys stored on Microsoft infrastructure (managed, not owned)

---

# HSM Comparison Matrix

## Decision Framework for SSC

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

### **Recommendation:** Entrust nShield for maximum sovereignty, Azure Managed HSM for rapid deployment

---

# SSC Management Model

## Operational Framework for HSM & CMK

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

---

# SSC Staffing Requirements

## Dedicated CMK Operations Team

### **Permanent Positions (CS-03/CS-04 Level):**

| Role | FTEs | Annual Cost | Responsibilities |
|------|------|-------------|-----------------|
| HSM Administrator | 2 | $220,000 | Hardware, firmware, DR |
| Key Manager | 2 | $220,000 | Lifecycle, rotation, access |
| Security Analyst | 1 | $110,000 | Audit, compliance, incidents |
| Team Lead | 1 | $140,000 | Governance, escalations |
| **Total** | **6** | **$690,000** | |

### **Shared Services Model:**
- Centralized team serves all departments
- Per-department cost allocation
- 24/7 on-call rotation for critical incidents
- Integration with SSC ITSM processes

---

# Implementation Timeline

## Phased Rollout with SSC Coordination

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  PHASE 1          PHASE 2          PHASE 3          PHASE 4       │
│  Foundation       HSM Deploy       Purview Config   Production    │
│  (60 days)        (90 days)        (60 days)        (30 days)     │
│                                                                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    │
│  │Procurement│───▶│HSM Install│───▶│Key Vault │───▶│Labels +  │    │
│  │+ Planning│    │+ Config  │    │+ CMK     │    │Go-Live   │    │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘    │
│                                                                    │
│  • RFP/Contract  • Rack/stack    • BYOK setup   • Pilot group    │
│  • SSC alignment • Network       • Label config • Training       │
│  • DR planning   • Security zone • DLP policies • Full rollout   │
│                  • Backup HSM    • Testing      • Monitoring     │
│                                                                    │
│                        TOTAL: 240 DAYS (8 MONTHS)                  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

<!-- _class: lead -->
<!-- _backgroundColor: #6f42c1 -->
<!-- _color: white -->

# PART 4
# Aegis ID: Decentralized Identity for GC

---

# The Current Identity Challenge

## Certificate-Based Authentication is Costly & Inflexible

### **Today's Reality with Entrust Certificates:**

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

---

# Current Costs of Certificate Auth

## Annual Expenditure Across GC

### **Entrust Certificate Costs (Estimated):**

| Cost Category | Annual Cost | Notes |
|--------------|-------------|-------|
| Certificate issuance | $4,500,000 | ~300,000 employees × $15 avg |
| Smart card/token hardware | $2,000,000 | Replacements, new hires |
| PKI infrastructure (SSC) | $3,500,000 | Servers, HSMs, operations |
| Help desk (cert issues) | $5,000,000 | ~10% of tickets |
| Transition processing | $3,000,000 | ~20,000 moves/year |
| Device reprovisioning | $8,000,000 | New laptops for movers |
| **Total Annual Cost** | **$26,000,000** | |

### **Pain Points:**
- 🔄 Inter-agency mobility is friction-heavy
- 💸 Duplicate devices for transferred employees
- ⏰ Weeks of reduced productivity during transitions
- 🔐 Data access revocation is inconsistent

---

# Introducing Aegis ID

## Decentralized Identity for the Government of Canada

### **What is Aegis ID?**

A **custom DID (Decentralized Identifier) service** built on W3C standards, integrated with **Microsoft Entra Verified ID**, providing:

- 🆔 **Portable digital identity** across all GC agencies
- 🔐 **Verifiable credentials** replacing certificates
- 📱 **Microsoft Authenticator** as the credential wallet
- ⚡ **Instant access changes** when employees move
- 🏛️ **Hosted in SSC data centres** for full sovereignty

---

# How Aegis ID Works

## Decentralized Identity Architecture

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
│   │   │  (Issuer)    │    │ (Blockchain) │    │ (Verifier) │   │  │
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
│   │  MS Authenticator │ ◀──── Employee's Personal Device           │
│   │   (DID Wallet)    │                                            │
│   └──────────────────┘                                             │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Verifiable Credentials Model

## Claims-Based Access Control

### **Each Employee Gets a DID with Agency-Specific Claims:**

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

# Inter-Agency Mobility Revolution

## Same Device, Different Access

### **When Employee Moves from ESDC → IRCC:**

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

---

# Data Protection on Device Transition

## Previous Work Becomes Inaccessible

### **How Encryption + DID Claims Work Together:**

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   EMPLOYEE LAPTOP                                                  │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                                                            │  │
│   │   ┌──────────────────────────────────┐                    │  │
│   │   │  📁 ESDC Files (Local Cache)     │                    │  │
│   │   │                                  │                    │  │
│   │   │  🔒 Encrypted with ESDC key      │                    │  │
│   │   │  🔑 Requires: claim:agency=ESDC  │ ❌ NO ACCESS       │  │
│   │   │                                  │    (credential     │  │
│   │   └──────────────────────────────────┘     revoked)       │  │
│   │                                                            │  │
│   │   ┌──────────────────────────────────┐                    │  │
│   │   │  📁 IRCC Files (New)             │                    │  │
│   │   │                                  │                    │  │
│   │   │  🔒 Encrypted with IRCC key      │                    │  │
│   │   │  🔑 Requires: claim:agency=IRCC  │ ✅ FULL ACCESS     │  │
│   │   │                                  │    (credential     │  │
│   │   └──────────────────────────────────┘     valid)         │  │
│   │                                                            │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Integration with Existing Infrastructure

## Frictionless Adoption Path

### **Key Advantage: Already 95% There!**

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   WHAT ALREADY EXISTS (NO CHANGE REQUIRED):                        │
│                                                                    │
│   ✅ Active Directory → Synced to Entra ID (Azure AD)             │
│   ✅ All employees have M365 accounts                              │
│   ✅ Microsoft Authenticator already deployed for MFA              │
│   ✅ Conditional Access policies in place                          │
│   ✅ Entra ID P1/P2 licenses                                       │
│                                                                    │
│   WHAT NEEDS TO BE ADDED:                                          │
│                                                                    │
│   🆕 Aegis ID service (SSC-hosted DID resolver/issuer)            │
│   🆕 Verified ID tenant configuration                              │
│   🆕 Agency credential templates                                   │
│   🆕 OIDC integration with relying party apps                      │
│                                                                    │
│   EMPLOYEE EXPERIENCE:                                             │
│                                                                    │
│   📱 One-time: Accept credential in Authenticator                  │
│   🔄 Ongoing: Business as usual (transparent authentication)       │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Entra Verified ID Integration

## Microsoft's DID Platform + Aegis ID Custom Service

### **Architecture Components:**

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

---

# OIDC Integration for Applications

## Standards-Based Authentication Flow

### **How Apps Verify Credentials:**

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

# Security Enhancements

## Why DID is More Secure Than Certificates

| Security Aspect | Certificate Auth | Aegis ID (DID) |
|-----------------|-----------------|----------------|
| **Key Storage** | Smart card/TPM | Authenticator (secure enclave) |
| **Revocation Speed** | Hours to days (CRL/OCSP) | **Instant** (real-time registry) |
| **Credential Theft** | Export possible | **Non-exportable** |
| **Phishing Resistance** | Moderate | **Strong** (bound to device) |
| **Replay Attacks** | Possible | **Prevented** (nonce-based) |
| **Offline Access** | Yes | Configurable |
| **Audit Trail** | Limited | **Complete** (blockchain-backed) |
| **Cross-Agency** | Manual trust | **Automatic** (federated DIDs) |

---

# SSC Data Centre Deployment

## Aegis ID Infrastructure Requirements

### **Deployment Architecture:**

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

# Aegis ID Implementation Costs

## 5-Year Total Cost of Ownership

### **For Government of Canada (~300,000 employees)**

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
| | | | |
| **TOTAL** | **$6.3M** | **$1.3M** | **$11.4M** |

---

# Savings from Aegis ID

## Eliminating Certificate Auth Costs

### **Annual Savings After Full Deployment:**

| Current Cost | Eliminated | Annual Savings |
|-------------|-----------|----------------|
| Certificate issuance | 100% | $4,500,000 |
| Smart card hardware | 100% | $2,000,000 |
| PKI infrastructure | 80% | $2,800,000 |
| Help desk (cert issues) | 90% | $4,500,000 |
| Transition processing | 95% | $2,850,000 |
| Device reprovisioning | 90% | $7,200,000 |
| | | |
| **Total Annual Savings** | | **$23,850,000** |

### **Payback Period: 6 months after full deployment**

---

<!-- _class: lead -->
<!-- _backgroundColor: #198754 -->
<!-- _color: white -->

# PART 5
# Combined ROI & Recommendations

---

# Combined Solution Architecture

## Purview + CMK + Aegis ID

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│                    UNIFIED GC DATA PROTECTION                      │
│                                                                    │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                      IDENTITY LAYER                         │  │
│   │                                                             │  │
│   │   Aegis ID ──▶ Entra Verified ID ──▶ MS Authenticator      │  │
│   │   (SSC)         (Microsoft)          (Employee)             │  │
│   │                                                             │  │
│   └─────────────────────────┬───────────────────────────────────┘  │
│                             │ Claims-based access                   │
│                             ▼                                       │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                    PROTECTION LAYER                         │  │
│   │                                                             │  │
│   │   Purview Labels ──▶ CMK Encryption ──▶ DLP Policies       │  │
│   │   (Classification)   (Entrust HSM)     (Enforcement)        │  │
│   │                                                             │  │
│   └─────────────────────────┬───────────────────────────────────┘  │
│                             │ Encrypted + labeled data              │
│                             ▼                                       │
│   ┌────────────────────────────────────────────────────────────┐  │
│   │                      DATA LAYER                             │  │
│   │                                                             │  │
│   │   M365 ──▶ SharePoint ──▶ Teams ──▶ Power Platform         │  │
│   │                                                             │  │
│   └────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# 5-Year Financial Summary

## Total Investment & Returns

### **Costs:**

| Initiative | 5-Year Cost |
|-----------|-------------|
| Purview Information Protection | $10,000,000 |
| HSM Infrastructure (Entrust) | $1,000,000 |
| Aegis ID | $11,400,000 |
| **Total Investment** | **$22,400,000** |

### **Savings & Avoided Costs:**

| Category | 5-Year Value |
|---------|--------------|
| Certificate auth elimination | $95,400,000 |
| Reduced device procurement | $28,800,000 |
| Breach cost avoidance (1 prevented) | $4,880,000 |
| Compliance audit efficiency | $2,000,000 |
| **Total Savings** | **$131,080,000** |

### **Net 5-Year Benefit: $108,680,000**

---

# Risk Mitigation Value

## What You're Really Buying

### **Security Outcomes:**

| Risk | Current State | With Solution |
|------|--------------|---------------|
| Microsoft compromise exposes data | **HIGH** | **MITIGATED** (CMK) |
| Credential theft | **MEDIUM** | **LOW** (DID non-exportable) |
| Cross-agency data leakage | **MEDIUM** | **LOW** (claims-based) |
| Delayed revocation | **HIGH** | **ELIMINATED** (instant) |
| Compliance gaps | **MEDIUM** | **LOW** (automated) |
| Nation-state targeting | **HIGH** | **MITIGATED** (sovereignty) |

### **Compliance Achieved:**
- ✅ PIPEDA / CPPA ready
- ✅ ITSG-33 controls
- ✅ TBS security directives
- ✅ Provincial health acts

---

# Implementation Roadmap

## 18-Month Execution Plan

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  YEAR 1                                           YEAR 2           │
│  Q1       Q2       Q3       Q4       Q1       Q2                  │
│  ────────────────────────────────────────────────────────────     │
│                                                                    │
│  ┌─────────────────────────────┐                                  │
│  │ PURVIEW + HSM DEPLOYMENT    │                                  │
│  │ • Entrust HSM procurement   │                                  │
│  │ • CMK configuration         │                                  │
│  │ • Label rollout             │                                  │
│  └─────────────────────────────┘                                  │
│                                                                    │
│           ┌─────────────────────────────┐                         │
│           │ Aegis ID DEVELOPMENT        │                         │
│           │ • Core platform build       │                         │
│           │ • SSC deployment            │                         │
│           │ • Entra integration         │                         │
│           └─────────────────────────────┘                         │
│                                                                    │
│                    ┌─────────────────────────────────────────┐    │
│                    │ AGENCY ROLLOUT                          │    │
│                    │ • Pilot agencies (5)                    │    │
│                    │ • Full rollout (100+)                   │    │
│                    └─────────────────────────────────────────┘    │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Executive Recommendations

## Immediate Actions

### **1. Approve Purview + CMK Implementation**
- Begin Entrust HSM procurement via SSC
- Allocate M365 E5 Compliance licensing
- Establish SSC key management team

### **2. Fund Aegis ID Development**
- Commission detailed technical design
- Establish SSC infrastructure allocation
- Engage Microsoft for Verified ID partnership

### **3. Designate Pilot Agencies**
- Select 3-5 agencies for initial rollout
- Identify inter-agency mobility use case
- Establish success metrics

### **4. Establish Governance**
- Cross-departmental steering committee
- SSC operational ownership
- TBS policy alignment

---

# Decision Points

## What We Need From Leadership

| Decision | Owner | Timeline |
|----------|-------|----------|
| Approve $22.4M 5-year investment | CIO Council | Q1 2026 |
| Designate SSC as operational lead | DM-level | Q1 2026 |
| Approve Entrust HSM procurement | SSC CIO | Q1 2026 |
| Fund Aegis ID development | TBS | Q1 2026 |
| Select pilot agencies | CIO Council | Q1 2026 |
| Mandate Verified ID for new apps | TBS | Q2 2026 |

---

<!-- _backgroundColor: #1a1a2e -->
<!-- _color: white -->

# Summary

## The Complete Picture

### **The Threats:**
- Cloud provider compromise risk
- Certificate-based auth is costly and inflexible
- Inter-agency mobility is a security gap

### **The Solution:**
- Microsoft Purview with Customer-Managed Keys (Entrust HSM)
- Aegis ID decentralized identity with Entra Verified ID
- SSC-hosted, fully sovereign infrastructure

### **The Outcome:**
- ✅ Data protected even if Microsoft is breached
- ✅ Instant credential revocation
- ✅ Same device across agency transitions
- ✅ $108M net savings over 5 years

---

<!-- _class: lead -->
<!-- _backgroundColor: #1a1a2e -->
<!-- _color: white -->

# 🔐 Sovereign Identity
# 🛡️ Sovereign Encryption
# 🇨🇦 Canadian Data Protection

## Questions & Discussion

---

# Appendix A: Glossary

| Term | Definition |
|------|------------|
| **Aegis ID** | Custom GC decentralized identity service |
| **BYOK** | Bring Your Own Key - import customer keys to Azure |
| **CMK** | Customer-Managed Keys - encryption keys you control |
| **DID** | Decentralized Identifier - W3C standard for digital identity |
| **HSM** | Hardware Security Module - tamper-resistant key storage |
| **OIDC** | OpenID Connect - authentication protocol |
| **Verified ID** | Microsoft Entra's verifiable credentials service |
| **VC** | Verifiable Credential - cryptographically signed claim |

---

# Appendix B: HSM Vendor Contacts

### **Entrust**
- Website: entrust.com
- GC Account Team: gc-sales@entrust.com
- Ottawa Office: 1000 Innovation Drive

### **Thales**
- Website: cpl.thalesgroup.com
- Canadian Sales: canada.sales@thalesgroup.com

### **Microsoft Azure Managed HSM**
- Documentation: docs.microsoft.com/azure/key-vault/managed-hsm
- SSC Azure Team: (internal)

---

# Appendix C: W3C DID Standards

### **Relevant Specifications:**

| Standard | URL | Purpose |
|----------|-----|---------|
| DID Core | w3.org/TR/did-core | DID syntax and resolution |
| VC Data Model | w3.org/TR/vc-data-model | Credential format |
| DID Resolution | w3c-ccg.github.io/did-resolution | Resolver spec |
| Presentation Exchange | identity.foundation/presentation-exchange | Proof requests |

### **Aegis ID Method:**
- Method name: `did:Aegis`
- Registry: SSC-hosted (permissioned)
- Resolution: HTTPS + DID Universal Resolver

---

# Appendix D: Compliance Mapping

| Requirement | Purview | CMK | Aegis ID |
|-------------|---------|-----|----------|
| PIPEDA - Safeguards | ✅ | ✅ | ✅ |
| PIPEDA - Accountability | ✅ | ✅ | ✅ |
| ITSG-33 IA-2 (MFA) | | | ✅ |
| ITSG-33 IA-5 (Authenticator Mgmt) | | | ✅ |
| ITSG-33 SC-8 (Transmission) | ✅ | ✅ | |
| ITSG-33 SC-28 (Data at Rest) | ✅ | ✅ | |
| ITSG-33 AU-2 (Audit) | ✅ | ✅ | ✅ |
| TBS Identity Directive | | | ✅ |
| CATS (future) | | | ✅ |

---

<!-- _class: lead -->
<!-- _backgroundColor: #198754 -->
<!-- _color: white -->

# ✅ Ready to Transform GC Security

## Data sovereignty through encryption.
## Identity sovereignty through decentralization.
## Operational savings through modernization.

**Let's make it happen.**
