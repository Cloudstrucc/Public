---
marp: true
theme: default
paginate: true
backgroundColor: #fff
header: '**Government of Canada** | Information Protection Strategy'
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
### Executive Strategy Briefing

**December 2025**

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
- **PIPEDA** compliance mandatory
- **Provincial health acts** add complexity
- Foreign adversary interest in government data at **all-time high**

---

<!-- _backgroundColor: #dc3545 -->
<!-- _color: white -->

# ⚠️ The Microsoft Risk Factor

## What Happens When Your Cloud Provider is Compromised?

### Recent High-Profile Incidents:

- **Storm-0558 (2023):** Chinese hackers accessed US government emails via compromised Microsoft signing key
  
- **Midnight Blizzard (2024):** Russian actors accessed Microsoft executive emails and source code

- **Multiple Zero-Days:** Ongoing discovery of Exchange, SharePoint vulnerabilities

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

## Know Your Data Before You Can Protect It

### Automatic Detection of Canadian Sensitive Information:

| Data Type | Detection Method | Risk Level |
|-----------|-----------------|------------|
| 🆔 Social Insurance Numbers | Pattern + Checksum | **CRITICAL** |
| 🏥 Health Card Numbers | Provincial patterns | **HIGH** |
| 💳 Financial Account Data | Pattern matching | **HIGH** |
| 🛂 Passport Numbers | Format validation | **MEDIUM** |
| 📍 Personal Addresses | Named entity | **MEDIUM** |

### **Result:** Data is automatically tagged as it's created, not after a breach

---

# Pillar 2: Protect

## Encryption That Travels With The Data

### Protection Follows Content Everywhere:

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

<!-- _backgroundColor: #198754 -->
<!-- _color: white -->

# ✅ Why This Matters for Government

## Compliance & Sovereignty Benefits

### **Regulatory Alignment:**
- ✅ PIPEDA compliance
- ✅ Provincial health acts (HIA, PHIPA, PHIA)
- ✅ Treasury Board security directives
- ✅ ITSG-33 controls

### **Data Sovereignty:**
- ✅ Keys stored in Canadian Azure regions
- ✅ No US CLOUD Act exposure for encrypted data
- ✅ Full control over cryptographic material

---

# The Cost of Inaction

## What's At Stake?

### **Financial Impact:**
- Average breach cost: **$4.88M**
- Regulatory fines: **Up to $25M** under proposed CPPA
- Reputation damage: **Incalculable**

### **Operational Impact:**
- Service disruption during incident response
- Loss of public trust
- Parliamentary scrutiny
- Potential legal liability

### **National Security Impact:**
- Adversary access to citizen data
- Intelligence collection opportunities
- Critical infrastructure exposure

---

# Implementation Approach

## Phased Rollout Strategy

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  PHASE 1          PHASE 2          PHASE 3          PHASE 4       │
│  Foundation       Protection       Automation       Optimization  │
│  (30 days)        (60 days)        (90 days)        (Ongoing)     │
│                                                                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    │
│  │ Labels   │───▶│ Policies │───▶│ Auto-    │───▶│ Advanced │    │
│  │ Created  │    │ Deployed │    │ Labeling │    │ DLP      │    │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘    │
│                                                                    │
│  • Define        • Publish to    • OOB Canadian  • Custom rules   │
│    taxonomy        users           templates     • CMK deploy     │
│  • Configure     • Enable        • Simulation    • Full audit     │
│    labels          mandatory     • Enable        • Continuous     │
│  • Test            labeling        policies        monitoring     │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Canadian-Specific Templates

## Out-of-the-Box Protection for Canadian Data

### **Built-in Templates:**

| Category | Templates Available |
|----------|-------------------|
| **Financial** | Canada Financial Data, PCI DSS |
| **Health** | Canada HIA, PHIPA (ON), PHIA (MB) |
| **Privacy** | Canada PIPEDA, PIPA, PII |

### **Detects:**
- Social Insurance Numbers (SIN)
- Provincial Health Card Numbers
- Bank Account Numbers
- Driver's License Numbers
- Passport Numbers

---

# Platform Coverage

## Protection Across the Entire Microsoft Ecosystem

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐             │
│   │ Office  │  │SharePoint│  │  Teams  │  │ Outlook │             │
│   │  Apps   │  │ Online  │  │         │  │         │             │
│   └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘             │
│        │            │            │            │                    │
│        └────────────┴────────────┴────────────┘                    │
│                         │                                          │
│                         ▼                                          │
│              ┌─────────────────────┐                              │
│              │  Microsoft Purview  │                              │
│              │  Unified Protection │                              │
│              └─────────────────────┘                              │
│                         │                                          │
│        ┌────────────────┼────────────────┐                        │
│        │                │                │                        │
│   ┌────┴────┐     ┌────┴────┐     ┌────┴────┐                    │
│   │Power BI │     │Dataverse│     │ Windows │                    │
│   │ Fabric  │     │Power Plat│    │Endpoints│                    │
│   └─────────┘     └─────────┘     └─────────┘                    │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# User Experience

## Security That Doesn't Impede Productivity

### **For End Users:**

```
┌────────────────────────────────────────────────────────────────────┐
│  📄 New Document                                          [Save]  │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ 🔒 Sensitivity: Protected B - Personal Information      ▼   │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ⓘ This document will be encrypted and can only be accessed      │
│    by authorized Government of Canada employees.                  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### **One click. Full protection. Zero friction.**

---

# Intelligent Alerts

## Users Are Guided, Not Blocked

### **Policy Tip Example:**

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  ⚠️ Protected Information Detected                                │
│  ───────────────────────────────────────────────────────────────  │
│                                                                    │
│  This document appears to contain a Social Insurance Number.      │
│                                                                    │
│  This is Protected B information under Government of Canada       │
│  security policy.                                                  │
│                                                                    │
│  RECOMMENDED ACTION:                                               │
│  Apply the "Protected B - Personal Information" label before      │
│  sharing this document.                                            │
│                                                                    │
│                    [Apply Label]  [Learn More]  [Dismiss]         │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

# Return on Investment

## Quantifiable Security Benefits

| Investment Area | Before | After |
|----------------|--------|-------|
| Unclassified sensitive docs | ~60% | **<5%** |
| Mean time to detect breach | 194 days | **<24 hours** |
| Data loss incidents | Reactive | **Proactive prevention** |
| Compliance audit time | Weeks | **Hours** |
| External sharing violations | Unknown | **Real-time visibility** |

### **ROI Drivers:**
- 🛡️ Reduced breach risk = Avoided costs
- ⚡ Faster compliance = Lower audit costs  
- 📊 Better visibility = Informed decisions
- 🔒 Controlled encryption = Data sovereignty

---

# Customer-Managed Keys: Deep Dive

## The Ultimate Control

### **How It Works:**

1. **You create** the encryption key in Azure Key Vault
2. **You control** access to the key via RBAC
3. **You can rotate** keys on your schedule
4. **You can revoke** Microsoft's access instantly

### **The Result:**

> Even with a valid court order, Microsoft **cannot** decrypt your data without your key.

> Even if Microsoft is **breached**, attackers get only encrypted blobs.

> You maintain **full cryptographic sovereignty**.

---

# Key Architecture

## Your Keys, Your Control

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│                    CANADIAN AZURE REGION                           │
│   ┌──────────────────────────────────────────────────────────────┐│
│   │                                                              ││
│   │   ┌─────────────────┐         ┌─────────────────────────┐   ││
│   │   │  Azure Key      │         │   Microsoft 365         │   ││
│   │   │  Vault (HSM)    │◀───────▶│   Services              │   ││
│   │   │                 │  Wrap/  │                         │   ││
│   │   │  🔐 Your Keys   │ Unwrap  │   📄 Your Data          │   ││
│   │   │                 │         │   (Encrypted)           │   ││
│   │   └─────────────────┘         └─────────────────────────┘   ││
│   │          │                                                   ││
│   │          │ Full audit logging                                ││
│   │          ▼                                                   ││
│   │   ┌─────────────────┐                                       ││
│   │   │  Azure Monitor  │                                       ││
│   │   │  + Sentinel     │                                       ││
│   │   └─────────────────┘                                       ││
│   │                                                              ││
│   └──────────────────────────────────────────────────────────────┘│
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

<!-- _backgroundColor: #0d6efd -->
<!-- _color: white -->

# 🎯 Executive Recommendations

## Immediate Actions

### **1. Enable Microsoft Purview Information Protection**
Deploy sensitivity labels across all M365 workloads

### **2. Implement Canadian OOB Templates**
Activate all Financial, Health, and Privacy templates

### **3. Evaluate Customer-Managed Keys**
Assess requirements for Protected B data sovereignty

### **4. Establish Monitoring**
Deploy Activity Explorer and DLP dashboards

---

# Decision Framework

## When to Use Customer-Managed Keys

| Scenario | Microsoft Keys | Customer Keys |
|----------|---------------|---------------|
| General internal docs | ✅ | |
| Protected A data | ✅ | |
| Protected B - standard | ✅ | ✅ Consider |
| Protected B - high sensitivity | | ✅ **Recommended** |
| National security adjacent | | ✅ **Required** |
| Foreign adversary target data | | ✅ **Required** |
| Regulatory mandate | | ✅ **Required** |

---

# Success Metrics

## How We'll Measure Progress

### **Phase 1 (30 days):**
- [ ] 100% of labels published to users
- [ ] Mandatory labeling enabled
- [ ] Baseline Activity Explorer reports

### **Phase 2 (60 days):**
- [ ] >80% of documents labeled
- [ ] Canadian OOB templates active
- [ ] DLP policies in simulation

### **Phase 3 (90 days):**
- [ ] Auto-labeling fully enabled
- [ ] DLP blocking active
- [ ] CMK evaluated/deployed

### **Ongoing:**
- [ ] <5% unlabeled sensitive documents
- [ ] Zero undetected external sharing of Protected B

---

# Resources Required

## Investment Summary

### **Licensing:**
- Microsoft 365 E5 or E5 Compliance add-on
- Azure Key Vault (for CMK)

### **Personnel:**
- Compliance Administrator (configuration)
- Security Analyst (monitoring)
- Change Management (user adoption)

### **Timeline:**
- Full deployment: **90 days**
- Steady state: **Ongoing optimization**

---

# Risk of Delay

## Every Day Without Protection...

### **Unprotected Data Is:**
- 📤 Being emailed externally
- 💾 Being saved to personal devices
- ☁️ Being uploaded to unauthorized cloud services
- 👁️ Potentially being accessed by threat actors

### **The Question Is Not If, But When**

> Organizations that implement data protection **before** a breach save an average of **$1.76M** compared to those that implement **after**.

---

<!-- _backgroundColor: #1a1a2e -->
<!-- _color: white -->

# Summary

## The Path Forward

### **The Threat:**
Cloud data is only as secure as your encryption keys

### **The Solution:**
Microsoft Purview + Customer-Managed Keys

### **The Outcome:**
- ✅ Data protected even if Microsoft is compromised
- ✅ Full compliance with Canadian regulations
- ✅ Complete visibility and control
- ✅ Users enabled, not impeded

---

<!-- _class: lead -->
<!-- _backgroundColor: #1a1a2e -->
<!-- _color: white -->

# 🔐 Take Control of Your Data

## Questions & Discussion

<br>

**Next Steps:**
1. Schedule technical deep-dive session
2. Review licensing requirements
3. Identify pilot group for Phase 1
4. Establish project governance

<br>

**Contact:** Information Protection Team
**Classification:** Protected B

---

# Appendix A: Glossary

| Term | Definition |
|------|------------|
| **CMK** | Customer-Managed Keys - encryption keys controlled by your organization |
| **DLP** | Data Loss Prevention - policies that prevent unauthorized sharing |
| **HSM** | Hardware Security Module - tamper-resistant key storage |
| **PIPEDA** | Personal Information Protection and Electronic Documents Act |
| **Protected B** | Canadian government classification for sensitive information |
| **SIT** | Sensitive Information Type - patterns used to detect sensitive data |
| **Purview** | Microsoft's unified data governance and compliance platform |

---

# Appendix B: Reference Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     COMPLETE SOLUTION ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐              │
│  │   Users     │   │   Admins    │   │  Security   │              │
│  │             │   │             │   │    Team     │              │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘              │
│         │                 │                 │                      │
│         ▼                 ▼                 ▼                      │
│  ┌───────────────────────────────────────────────────────────┐    │
│  │                  Microsoft 365 Services                    │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │    │
│  │  │Exchange │ │SharePt  │ │ Teams   │ │Power BI │         │    │
│  │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘         │    │
│  └───────┼───────────┼───────────┼───────────┼───────────────┘    │
│          └───────────┴───────────┴───────────┘                     │
│                              │                                      │
│                              ▼                                      │
│  ┌───────────────────────────────────────────────────────────┐    │
│  │                   Microsoft Purview                        │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │    │
│  │  │ Labels   │  │   DLP    │  │  Audit   │  │ Data Map │  │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │    │
│  └───────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  ┌───────────────────────────────────────────────────────────┐    │
│  │                   Azure Key Vault (CMK)                    │    │
│  │                   Canada Central Region                    │    │
│  └───────────────────────────────────────────────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

# Appendix C: Compliance Mapping

| Requirement | Purview Capability |
|-------------|-------------------|
| PIPEDA - Safeguards | Encryption, DLP, Access Controls |
| PIPEDA - Accountability | Audit Logs, Activity Explorer |
| ITSG-33 SC-8 | Transmission Confidentiality (Encryption) |
| ITSG-33 SC-28 | Protection of Information at Rest (CMK) |
| ITSG-33 AU-2 | Audit Events (Unified Audit Log) |
| ITSG-33 AC-3 | Access Enforcement (Label-based) |
| TBS Directive | Data Classification (Sensitivity Labels) |
| Provincial Health | HIA/PHIPA/PHIA Templates |