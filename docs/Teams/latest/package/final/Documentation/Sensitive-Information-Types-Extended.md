# Microsoft Purview Sensitive Information Types (SITs) for Defense Contractors
## Implementation Guide for Leonardo Company Canada

**Version:** 1.0  
**Date:** December 2025  
**Prepared by:** IT Leonardo Canada inc.  
**Classification:** Internal Use Only

---

## Executive Summary

This document provides comprehensive guidance for implementing custom Sensitive Information Types (SITs) in Microsoft Purview to support automated sensitivity labeling for Leonardo Company Canada. As a defense contractor handling NATO-classified materials, Canadian Protected B information, and ITAR-controlled data, Leonardo Company requires sophisticated content classification to ensure compliance with multiple regulatory frameworks.

This implementation enables automatic detection and labeling of sensitive content across Microsoft 365, reducing manual classification errors and ensuring consistent protection of controlled information.

---

## Table of Contents

1. [Purpose and Business Context](#purpose-and-business-context)
2. [Regulatory Requirements](#regulatory-requirements)
3. [Custom SIT Categories](#custom-sit-categories)
4. [Implementation Architecture](#implementation-architecture)
5. [Step-by-Step Implementation](#step-by-step-implementation)
6. [Testing and Validation](#testing-and-validation)
7. [Maintenance and Governance](#maintenance-and-governance)
8. [Appendices](#appendices)

---

## 1. Purpose and Business Context

### Why Custom SITs Matter for Leonardo Company

Leonardo Company Canada operates in a highly regulated environment where information must be protected according to multiple classification systems:

- **NATO Information Sharing:** Documents containing NATO-classified information (COSMIC TOP SECRET through NATO RESTRICTED)
- **Canadian Government Contracts:** Protected A/B/C materials under Treasury Board policies and ITSG-33 requirements
- **US Defense Contracts:** ITAR-controlled technical data requiring strict export controls
- **Proprietary Information:** Competition-sensitive business information, trade secrets, and proposal materials

**The Challenge:** Manual classification is error-prone. Users may:
- Forget to apply sensitivity labels
- Select incorrect classification levels
- Fail to recognize content that requires protection
- Inconsistently apply labels across departments

**The Solution:** Custom Sensitive Information Types automatically detect classification indicators in content and recommend or apply appropriate sensitivity labels, ensuring:
- Consistent classification across all documents
- Reduced risk of data breaches or export violations
- Compliance with customer security requirements
- Automated enforcement of security policies

### Business Impact

Implementing custom SITs delivers:
- **Risk Reduction:** Prevents unauthorized disclosure of classified or controlled information
- **Compliance Assurance:** Demonstrates due diligence to government customers and auditors
- **Operational Efficiency:** Reduces burden on users to manually classify every document
- **Audit Trail:** Provides automatic documentation of why content was classified
- **Contract Eligibility:** Maintains clearance to bid on classified government contracts

---

## 2. Regulatory Requirements

### NATO Information Security Requirements

Leonardo Company handles NATO alliance information requiring protection according to:

**NATO Security Classification Levels:**
- **COSMIC TOP SECRET:** Exceptionally grave damage to NATO
- **NATO SECRET:** Serious damage to NATO
- **NATO CONFIDENTIAL:** Damage to NATO interests
- **NATO RESTRICTED:** Adverse effects on NATO

**Special Handling Markings:**
- **ATOMAL:** Nuclear information
- **NOFORN:** No foreign nationals
- **NATO EYES ONLY:** Limited distribution
- **REL TO NATO:** Releasable to NATO members

**Key Requirements:**
- Encryption at rest and in transit
- Access limited to cleared personnel
- Physical and electronic segregation
- Audit logging of all access
- Destruction certification upon disposal

### Canadian Government Protected Information

Work with Canadian federal government requires handling:

**Protected Information Levels:**
- **Protected A:** Low sensitivity - could cause minor injury to individuals, organizations, or government
- **Protected B:** Medium sensitivity - could cause serious injury (majority of Leonardo's government work)
- **Protected C:** High sensitivity - could cause extremely grave injury

**Key Requirements (ITSG-33 Compliance):**
- Protected B Medium Integrity/Medium Availability (PBMM) cloud profile
- Canadian data residency (data must remain in Canada)
- Customer Managed Keys for encryption
- Multi-factor authentication
- Detailed access logging and monitoring

**Relevant Standards:**
- ITSG-33: IT Security Risk Management
- PBMM: Cloud security profile for Protected B
- Privacy Act: Personal information protection
- Security of Information Act: Classified information handling

### ITAR and Export Control

As a defense contractor, Leonardo must comply with:

**US International Traffic in Arms Regulations (ITAR):**
- Controls export of defense articles and technical data
- Restricts access to "US persons" only
- Requires technology control plans
- Severe penalties for violations (criminal and civil)

**United States Munitions List (USML):**
- Categories I-XXI defining controlled items
- Technical data related to design, development, production
- Defense services provided to foreign persons

**Canadian Controlled Goods Program (CGP):**
- Canadian equivalent to ITAR
- Controlled Goods Directorate registration required
- Restricted to Canadian-registered persons
- Examinations and security clearances

**Key Compliance Requirements:**
- No foreign national access without authorization
- Technology control plans for all ITAR projects
- Segregation of ITAR data from non-ITAR
- Training for all employees handling controlled data
- Regular audits and self-assessments

### Defense Contractor Compliance

Additional requirements include:

**NIST Cybersecurity Standards:**
- NIST 800-171: Protecting Controlled Unclassified Information
- NIST 800-53: Security and Privacy Controls
- CMMC 2.0: Cybersecurity Maturity Model Certification

**Federal Acquisition Regulation (FAR) & DFARS:**
- Cybersecurity incident reporting (DFARS 252.204-7012)
- Supply chain risk management
- Cloud computing restrictions
- Controlled Unclassified Information (CUI) protection

**Contract Security:**
- DD Form 254: Department of Defense Contract Security Classification Specification
- Facility Security Clearance (FCL)
- Personnel Security Clearances
- Security classification guides

---

## 3. Custom SIT Categories

### Category 1: NATO Classification Keywords

**Purpose:** Detect NATO-classified information and alliance-shared defense materials

**Use Cases:**
- Documents received from NATO organizations
- Technical reports shared among alliance members
- Meeting minutes from NATO working groups
- Operational plans and military exercises

**Sample Keywords:**

```
COSMIC TOP SECRET
NATO SECRET
NATO CONFIDENTIAL
NATO RESTRICTED
ATOMAL
NOFORN
REL TO NATO
NATO EYES ONLY
FIVE EYES / FVEY
STANAG
SHAPE
SACEUR
ISAF
KFOR
```

**Recommended Label:** NATO Restricted (parent label) with sub-labels for NATO Confidential and NATO Secret

**Detection Strategy:**
- High confidence on exact matches
- Case-insensitive matching
- Proximity rules: Flag document if keyword appears near terms like "alliance", "partners", "coalition"
- Instance count: Even 1 occurrence should trigger labeling

### Category 2: Canadian Government Classification Keywords

**Purpose:** Identify Canadian federal government protected and classified information

**Use Cases:**
- Contracts with DND, PSPC, CSE
- Technical reports for government programs
- Proposals responding to government RFPs
- Project deliverables under federal contracts

**Sample Keywords:**

```
PROTECTED A
PROTECTED B
PROTECTED C
CLASSIFIED
SECRET
TOP SECRET
CANADIAN EYES ONLY
ITSG-33
PBMM
CSE
CSIS
COMSEC
INFOSEC
SAP
SCI
Privacy Act
PIPEDA
```

**Recommended Label:** Protected B (as primary government label)

**Detection Strategy:**
- Exact phrase matching for "PROTECTED B", "PROTECTED A", etc.
- Must handle variations: "PROTECTED-B", "Protected B", "PROTECTED B//"
- Combine with context: government department names, Canadian standards references
- Instance count: 1+ occurrences for Protected B/C, 2+ for Protected A

### Category 3: ITAR/Export Control Keywords

**Purpose:** Flag content subject to US or Canadian export controls

**Use Cases:**
- Technical data packages for US defense articles
- Engineering drawings for controlled items
- Software source code for defense applications
- Manufacturing processes for USML items

**Sample Keywords:**

```
ITAR
ITAR CONTROLLED
USML
EAR
ECCN
EXPORT CONTROLLED
NO FOREIGN NATIONALS
US PERSONS ONLY
CONTROLLED GOODS
CGP
TECHNICAL DATA
DEFENSE ARTICLE
DUAL USE
DEEMED EXPORT
```

**Recommended Label:** ITAR Controlled

**Detection Strategy:**
- Exact match on "ITAR", "USML"
- Combine "EXPORT" + "CONTROLLED"
- Flag "TECHNICAL DATA" when near defense terms
- Instance count: 1+ occurrence triggers label
- Mandatory encryption and access restrictions

### Category 4: Defense Contractor Keywords

**Purpose:** Identify proprietary business information and competition-sensitive materials

**Use Cases:**
- Bid and proposal materials
- Cost and pricing data
- Proprietary designs and trade secrets
- Source selection information
- Business strategies and competitive analysis

**Sample Keywords:**

```
PROPRIETARY
PROPRIETARY INFORMATION
COMPANY PROPRIETARY
TRADE SECRET
CONFIDENTIAL BUSINESS
BUSINESS SENSITIVE
COMPETITION SENSITIVE
SOURCE SELECTION
PROPOSAL
BID
RFP (Request for Proposal)
RFQ (Request for Quotation)
RFI (Request for Information)
SOW (Statement of Work)
PWS (Performance Work Statement)
```

**Contract and Acquisition Terms:**

```
CDRL (Contract Data Requirements List)
CLIN (Contract Line Item Number)
FAR (Federal Acquisition Regulation)
DFARS (Defense FAR Supplement)
WBS (Work Breakdown Structure)
IMS (Integrated Master Schedule)
IMP (Integrated Master Plan)
EVM (Earned Value Management)
EVMS (Earned Value Management System)
```

**Security and Compliance:**

```
NIST 800-171
NIST 800-53
CMMC / CMMC 2.0
FCI (Federal Contract Information)
CUI (Controlled Unclassified Information)
CDI (Covered Defense Information)
DD254
SF312
FSO (Facility Security Officer)
ISSM (Information System Security Manager)
```

**Program Management:**

```
PDR (Preliminary Design Review)
CDR (Critical Design Review)
TRL (Technology Readiness Level)
IOC (Initial Operational Capability)
FOC (Full Operational Capability)
MDAP (Major Defense Acquisition Program)
ACAT (Acquisition Category)
```

**Recommended Labels:**
- Confidential - Proprietary (for trade secrets, business sensitive)
- Confidential - Source Selection (for bid/proposal materials)
- Internal - Business (for general contract documents)

**Detection Strategy:**
- Keywords in combinations: "PROPRIETARY" + document type
- High weight on "SOURCE SELECTION", "TRADE SECRET"
- Multiple defense acronyms suggest controlled content
- Instance count: 3+ defense terms triggers Confidential label

---

## 4. Implementation Architecture

### Microsoft Purview Information Protection Components

The implementation uses these Purview features:

**1. Sensitive Information Types (SITs)**
- Custom keyword dictionaries for each category
- Confidence levels (High: 85-100%, Medium: 65-84%, Low: <65%)
- Character proximity rules
- Instance count thresholds

**2. Sensitivity Labels**
- Hierarchical label structure
- Encryption, marking, and access controls
- Scoped policies (by user, group, location)
- Label inheritance rules

**3. Auto-Labeling Policies**
- Simulation mode for testing
- Location-based application (Exchange, SharePoint, OneDrive, Teams)
- User override permissions
- Policy priority and conflict resolution

**4. Data Loss Prevention (DLP)**
- Blocks sharing of labeled content
- Alerts on policy violations
- Integration with Microsoft Defender

### Recommended Label Hierarchy for Leonardo Company

```
Public
└── (No protection, marketing materials)

Internal
└── (Default label, general business)

Confidential
├── Confidential - Proprietary
├── Confidential - Business Sensitive
└── Confidential - Source Selection

Protected B
├── Protected B - General
└── Protected B - Personal Information

NATO Restricted
├── NATO Confidential
└── NATO Secret

ITAR Controlled
├── ITAR - Technical Data
└── ITAR - Defense Articles

Highly Confidential
├── Protected C
└── Top Secret
```

### Label Settings and Protections

**Public:**
- No encryption
- Header/footer marking: "Public Information"
- No access restrictions

**Internal:**
- Optional encryption
- Watermark: "Leonardo Company Internal"
- Accessible to all employees

**Confidential (all sub-labels):**
- Mandatory encryption
- Watermark + header/footer
- Access: Restricted to specific groups
- External sharing: Blocked or requires approval
- Forwarding: Restricted

**Protected B:**
- Customer Managed Key encryption
- Canadian data residency required
- Watermark: "PROTECTED B - Government of Canada"
- Access: Cleared personnel only
- Audit logging: All access logged
- Retention: Per contract requirements

**NATO Restricted/Confidential/Secret:**
- Strongest encryption
- Watermark: "NATO [LEVEL]"
- Access: NATO-cleared personnel only
- External sharing: Completely blocked
- Print/copy: Disabled or requires approval
- Audit logging: Mandatory

**ITAR Controlled:**
- Strong encryption
- Watermark: "ITAR CONTROLLED - No Foreign Nationals"
- Access: US Persons and Canadian registered persons only
- External sharing: Completely blocked
- Forwarding: Disabled
- Audit logging: Mandatory
- Retention: Per technology control plan

### Integration Points

The SITs integrate with:

**Microsoft 365 Workloads:**
- Exchange Online (emails and attachments)
- SharePoint Online (documents and lists)
- OneDrive for Business (personal storage)
- Microsoft Teams (chats, files, channels)

**Security and Compliance:**
- Microsoft Defender for Cloud Apps
- Conditional Access policies
- Azure Information Protection scanner (on-premises)
- Customer Managed Keys (Azure Key Vault)

**Monitoring and Reporting:**
- Content Explorer (view labeled content)
- Activity Explorer (label application events)
- DLP alerts and reports
- Azure Monitor / Log Analytics

---

## 5. Step-by-Step Implementation

### Phase 1: Preparation (Week 1)

**Step 1.1: Review Current State**

Audit your existing sensitivity labels:
```powershell
# Connect to Security & Compliance Center
Connect-IPPSSession -UserPrincipalName admin@leonardocompany.ca

# List existing labels
Get-Label | Select-Object DisplayName, Priority, Disabled

# Check auto-labeling policies
Get-AutoSensitivityLabelPolicy | Select-Object Name, Mode, Locations
```

**Step 1.2: Stakeholder Alignment**

Meet with:
- Security team: Validate label protection settings
- Compliance team: Confirm regulatory requirements
- Business units: Understand document workflows
- IT operations: Plan change management

**Step 1.3: Create Project Plan**

Document:
- Implementation timeline
- Testing approach (simulation mode)
- Rollout strategy (pilot groups → full deployment)
- Training materials for end users
- Success metrics (labeling coverage %, false positive rate)

### Phase 2: Create Custom SITs (Week 2)

**Step 2.1: Access Microsoft Purview Portal**

1. Navigate to https://compliance.microsoft.com
2. Go to **Data classification** → **Classifiers** → **Sensitive info types**
3. Click **+ Create sensitive info type**

**Step 2.2: Create NATO Keywords SIT**

1. **Basic settings:**
   - Name: `Leonardo - NATO Classification Keywords`
   - Description: `Detects NATO classification markings and alliance-shared information`

2. **Define pattern:**
   - Primary element: **Keyword dictionary**
   - Upload file: `nato_keywords_purview.txt` (see Appendix A)
   - Or paste keywords directly

3. **Confidence and proximity:**
   - Confidence level: **High (85%)**
   - Character proximity: **300 characters** (allows some context around keywords)
   - Instance count: **1 or more** (even single occurrence is significant for NATO material)

4. **Supporting elements (optional):**
   - Add keyword list: `ALLIANCE, PARTNERS, COALITION` to increase confidence when near primary keywords
   - Add regular expression for NATO document numbering: `(AC|C-M|MC|PO)\(/\d{4}\)`

5. **Review and create**

**Step 2.3: Create Canadian Government Keywords SIT**

Repeat process with:
- Name: `Leonardo - Canadian Government Classification`
- Keywords: Protected A/B/C, ITSG-33, etc. (see Appendix B)
- Confidence level: **High (85%)**
- Proximity: **300 characters**
- Instance count: **1 or more**
- Supporting elements: `CANADA, GOVERNMENT OF CANADA, DND, PSPC, CSE`

**Step 2.4: Create ITAR/Export Control Keywords SIT**

Repeat with:
- Name: `Leonardo - ITAR Export Control`
- Keywords: ITAR, USML, EAR, CGP (see Appendix C)
- Confidence level: **High (90%)** (stricter for export control)
- Proximity: **300 characters**
- Instance count: **1 or more**
- Supporting elements: `TECHNICAL DATA, DEFENSE ARTICLE, MUNITIONS`

**Step 2.5: Create Defense Contractor Keywords SIT**

Repeat with:
- Name: `Leonardo - Defense Contractor Terms`
- Keywords: PROPRIETARY, SOURCE SELECTION, CUI, etc. (see Appendix D)
- Confidence level: **Medium (75%)** (these terms are more common)
- Proximity: **500 characters** (allow more context)
- Instance count: **3 or more** (reduce false positives - multiple acronyms suggest controlled content)
- Supporting elements: `PROPOSAL, ACQUISITION, CONTRACT, GOVERNMENT`

**Step 2.6: Test SITs**

Create test documents:
```
Test Document 1: NATO_test.docx
Content: "This document contains NATO CONFIDENTIAL information regarding STANAG 4569."

Test Document 2: Protected_B_test.docx
Content: "PROTECTED B - This project deliverable for DND follows ITSG-33 requirements."

Test Document 3: ITAR_test.docx
Content: "ITAR CONTROLLED - This technical data package describes defense articles on the USML."

Test Document 4: Contractor_test.docx
Content: "PROPRIETARY - This proposal contains SOURCE SELECTION sensitive information."
```

Upload to SharePoint and verify detection:
```powershell
# Check if SIT is detecting content
$SIT = Get-DlpSensitiveInformationType -Identity "Leonardo - NATO Classification Keywords"
Get-DlpSensitiveInformationTypeRulePackage -Identity $SIT.RulePackageID
```

### Phase 3: Configure Auto-Labeling Policies (Week 3)

**Step 3.1: Create Auto-Labeling Policy for NATO Content**

1. Navigate to **Information protection** → **Auto-labeling**
2. Click **+ Create auto-labeling policy**

3. **Choose information to label:**
   - Select: **Custom**
   - Add condition: **Content contains** → **Sensitive info types**
   - Select: `Leonardo - NATO Classification Keywords`

4. **Define scope:**
   - Name: `Auto-label NATO Classified Content`
   - Locations:
     - ✅ Exchange email
     - ✅ SharePoint sites (select specific sites handling NATO content)
     - ✅ OneDrive accounts (select cleared users)
     - ✅ Teams messages (if NATO discussions occur)

5. **Set up common or advanced rules:**
   - Instance count: **1 or more**
   - Additional conditions (optional):
     - Document contains terms: `ALLIANCE, ALLIED`
     - Document received from: `@nato.int` domains

6. **Choose a label:**
   - Select: **NATO Restricted** (or appropriate sub-label based on confidence)
   - Action: **Recommend label** (initially - switch to auto-apply after testing)
   - User override: **Allow** (users can downgrade if needed)

7. **Policy mode:**
   - **CRITICAL:** Start in **Simulation mode**
   - Run for 7 days minimum to gather data

8. **Review and finish**

**Step 3.2: Create Auto-Labeling Policy for Protected B Content**

Repeat with:
- Condition: `Leonardo - Canadian Government Classification` SIT
- Label: **Protected B**
- Locations: All (this is our primary government work label)
- Mode: **Simulation** initially

**Step 3.3: Create Auto-Labeling Policy for ITAR Content**

Repeat with:
- Condition: `Leonardo - ITAR Export Control` SIT
- Label: **ITAR Controlled**
- Locations: All
- Additional rule: Block external sharing automatically
- Mode: **Simulation** initially

**Step 3.4: Create Auto-Labeling Policy for Proprietary Content**

Repeat with:
- Condition: `Leonardo - Defense Contractor Terms` SIT
- Instance count: **3 or more** (reduce false positives)
- Label: **Confidential - Proprietary**
- Locations: All
- Mode: **Simulation** initially

### Phase 4: Simulation and Tuning (Week 4-5)

**Step 4.1: Monitor Simulation Results**

Access Content Explorer:
```
Microsoft Purview → Data classification → Content explorer
Filter by: Sensitive info type = Leonardo custom SITs
```

Review:
- How many items detected?
- Are they correctly classified?
- False positive rate?
- False negative rate?

**Step 4.2: Analyze Label Matches**

```powershell
# Get policy simulation results
Get-AutoSensitivityLabelPolicy | Where-Object {$_.Mode -eq "Simulate"} | ForEach-Object {
    Get-AutoSensitivityLabelRule -Policy $_.Name | 
    Select-Object Name, @{N='MatchCount';E={$_.MatchInfo.Count}}
}
```

**Step 4.3: Tune SITs Based on Results**

Common adjustments:

**If too many false positives:**
- Increase instance count threshold
- Add excluding keywords (e.g., exclude "RFP" in marketing context)
- Tighten character proximity
- Increase confidence level

**If missing content (false negatives):**
- Add keyword variations
- Reduce instance count threshold
- Expand character proximity
- Add supporting elements for context

**Step 4.4: Iterate**

Make adjustments → Run simulation another 7 days → Review results

Goal: <5% false positive rate, <2% false negative rate

### Phase 5: Pilot Deployment (Week 6)

**Step 5.1: Select Pilot Group**

Choose:
- 20-50 users from different departments
- Mix of heavy document creators and light users
- Include security-conscious champions

**Step 5.2: Enable Auto-Labeling for Pilot**

For each policy:
1. Edit policy
2. Change mode from **Simulate** to **Turn on policy**
3. Set scope to pilot group only (use advanced rule conditions)
4. Save and publish

**Step 5.3: Monitor Pilot**

Track for 2 weeks:
- User feedback (helpdesk tickets, confusion)
- Label accuracy
- Impact on workflows (delays, blocks)
- Security incidents (improved or new issues)

### Phase 6: Full Deployment (Week 7-8)

**Step 6.1: Expand Scope**

Gradually expand each auto-labeling policy:
- Week 7: 50% of users
- Week 8: 100% of users

**Step 6.2: User Communication**

Send organization-wide communications:
- Explain what's changing and why
- Show examples of auto-labeling in action
- Provide instructions for override (when appropriate)
- Link to training resources

**Step 6.3: Training**

Deliver training on:
- How auto-labeling works
- What each label means
- When to manually adjust labels
- Who to contact for issues

### Phase 7: Ongoing Governance (Continuous)

**Step 7.1: Monthly Reviews**

Review monthly:
- Content Explorer: labeling trends
- Activity Explorer: label change events
- DLP reports: policy violations
- User feedback: helpdesk analytics

**Step 7.2: Quarterly Tuning**

Every quarter:
- Review false positive/negative rates
- Add new keywords based on business changes
- Adjust confidence levels
- Update label descriptions

**Step 7.3: Annual Audit**

Annually:
- Full audit of all SITs and labels
- Compliance assessment against regulations
- Security review of label protections
- Update documentation

---

## 6. Testing and Validation

### Test Scenarios

**Test Scenario 1: NATO Document Detection**

Create document with content:
```
STANAG 4569 - Protection Levels for Occupants of Armoured Vehicles

This NATO CONFIDENTIAL document describes ballistic protection levels...
```

Expected result:
- SIT: `Leonardo - NATO Classification Keywords` detected
- Label: `NATO Restricted` recommended/applied
- Confidence: High

**Test Scenario 2: Protected B Government Contract**

Create document with content:
```
Contract Number: W8486-220234/001/HAL
PROTECTED B

This Technical Report describes the system architecture for the Canadian Armed 
Forces communications system in accordance with ITSG-33 security controls.
```

Expected result:
- SIT: `Leonardo - Canadian Government Classification` detected
- Label: `Protected B` applied
- Encryption: Customer Managed Key
- Access: Restricted to government cleared personnel

**Test Scenario 3: ITAR Technical Data**

Create document with content:
```
ITAR CONTROLLED - US PERSONS ONLY

This technical data package describes the design, development, and production
of defense articles classified under USML Category IV(h).
```

Expected result:
- SIT: `Leonardo - ITAR Export Control` detected
- Label: `ITAR Controlled` applied
- Encryption: Mandatory
- External sharing: Blocked
- Access: US Persons only

**Test Scenario 4: Proprietary Proposal**

Create document with content:
```
PROPRIETARY INFORMATION - SOURCE SELECTION SENSITIVE

Leonardo Company Response to RFP FA8726-24-R-0001
This proposal contains COMPANY PROPRIETARY cost and technical data.

CWBS Cost Breakdown:
CLIN 0001: Engineering Services - $2.5M
EVMS reporting per DFARS 252.234-7001
```

Expected result:
- SIT: `Leonardo - Defense Contractor Terms` detected (multiple matches)
- Label: `Confidential - Source Selection` applied
- External sharing: Restricted
- Access: Proposal team only

### False Positive Testing

Test documents that should NOT trigger:

**Document 1: Marketing Material**
```
Leonardo Company is a leading defense contractor serving NATO allies
and government customers worldwide.
```

Expected: Should NOT trigger (no classification keywords, just company description)

**Document 2: Public News**
```
The Government of Canada announced a new defense procurement...
```

Expected: Should NOT trigger (public information, no Protected markings)

### Validation Checklist

Before moving from simulation to production:

- [ ] All test scenarios pass correctly
- [ ] False positive rate < 5%
- [ ] False negative rate < 2%
- [ ] User override works as expected
- [ ] Encryption applies correctly based on label
- [ ] Access restrictions enforced
- [ ] External sharing blocked for sensitive labels
- [ ] Audit logging captures all label events
- [ ] Performance impact acceptable (< 5% delay in document open/save)
- [ ] Mobile devices handle labels correctly (Outlook mobile, Teams mobile)

---

## 7. Maintenance and Governance

### Keyword Dictionary Updates

**When to update:**
- New contract with different classification requirements
- Regulatory changes (new NIST standards, CMMC updates)
- Organizational changes (new programs, new security markings)
- Audit findings (keywords causing confusion or not detected)

**Update process:**
1. Document proposed changes in change request
2. Security team approval required
3. Update SIT in Purview portal
4. Test in simulation mode (7 days minimum)
5. Deploy to production
6. Update user documentation

**Version control:**
- Maintain version history of keyword lists
- Document reason for each change
- Store in secure SharePoint library with access logging

### Performance Monitoring

**Key Metrics:**

| Metric | Target | Review Frequency |
|--------|--------|------------------|
| Labeling coverage | >90% of documents labeled | Weekly |
| False positive rate | <5% | Monthly |
| False negative rate | <2% | Monthly |
| User override rate | <10% | Monthly |
| DLP policy violations | <20/month | Weekly |
| Average labeling delay | <2 seconds | Monthly |

**Monitoring tools:**
- Content Explorer: Labeling trends and coverage
- Activity Explorer: Label application and changes
- DLP Reports: Policy violations and user actions
- Azure Monitor: Performance metrics and errors

### User Training and Support

**Initial training:**
- All employees: 30-minute overview of sensitivity labels
- Document creators: 1-hour deep dive on auto-labeling
- Cleared personnel: Additional training on classification requirements
- Security team: Administrator training on Purview configuration

**Ongoing support:**
- Helpdesk knowledge base articles
- Quarterly refresher communications
- "Label of the Month" awareness campaign
- Annual compliance training (mandatory)

**Measuring effectiveness:**
- Track helpdesk tickets related to labeling
- Monitor user override patterns (frequent overrides suggest poor SIT tuning)
- Survey users quarterly on confidence in classification

### Compliance and Audit

**Audit evidence:**
- SIT configuration exports
- Auto-labeling policy reports
- Content Explorer snapshots (monthly)
- Label change audit logs
- DLP incident reports

**Regulatory reporting:**
- CMMC assessments: Provide labeling metrics as CUI protection evidence
- NATO audits: Demonstrate detection and protection of alliance information
- Government contract reviews: Show Protected B compliance mechanisms
- ITAR compliance: Document technology control plan enforcement

**Internal audits:**
- Quarterly: Random sampling of 100 documents, verify correct labeling
- Annually: Full review of all SITs, labels, and policies
- Ad-hoc: Investigate any security incident involving misclassified data

---

## 8. Appendices

### Appendix A: NATO Keywords (Full List)

See file: `nato_keywords_purview.txt`

Sample keywords (full list of 57 available):
```
COSMIC TOP SECRET
NATO SECRET
NATO CONFIDENTIAL
NATO RESTRICTED
ATOMAL
NOFORN
REL TO NATO
NATO EYES ONLY
FIVE EYES
FVEY
STANAG
SHAPE
SACEUR
ISAF
KFOR
NATO UNCLASSIFIED
ALLIED
ALLIANCE
PfP (Partnership for Peace)
EADRCC
NIAG
```

### Appendix B: Canadian Government Keywords (Full List)

See file: `canadian_gov_keywords_purview.txt`

Sample keywords (full list of 75 available):
```
PROTECTED A
PROTECTED B
PROTECTED C
PROTECTED A//
PROTECTED B//
PROTECTED C//
CLASSIFIED
SECRET
TOP SECRET
CANADIAN EYES ONLY
ITSG-33
PBMM
CSE (Communications Security Establishment)
CSIS (Canadian Security Intelligence Service)
COMSEC
INFOSEC
TEMPEST
EMSEC
SAP (Special Access Program)
SCI (Sensitive Compartmented Information)
Privacy Act
PIPEDA
Treasury Board
RCMP
DND (Department of National Defence)
PSPC (Public Services and Procurement Canada)
```

### Appendix C: ITAR/Export Control Keywords (Full List)

See file: `itar_export_keywords_purview.txt`

Sample keywords (full list of 85 available):
```
ITAR
ITAR CONTROLLED
USML (United States Munitions List)
EAR (Export Administration Regulations)
ECCN (Export Control Classification Number)
EXPORT CONTROLLED
NO FOREIGN NATIONALS
US PERSONS ONLY
CONTROLLED GOODS
CGP (Controlled Goods Program)
TECHNICAL DATA
DEFENSE ARTICLE
DEFENSE SERVICE
DUAL USE
DEEMED EXPORT
DIRECTORATE OF DEFENSE TRADE CONTROLS
DDTC
BIS (Bureau of Industry and Security)
OFAC (Office of Foreign Assets Control)
EMBARGOED COUNTRIES
TCP (Technology Control Plan)
EMPOWERED OFFICIAL
DDTC Registration
CGD (Controlled Goods Directorate)
```

### Appendix D: Defense Contractor Keywords (Full List - 105 Keywords)

See file: `defense_contractor_keywords_purview.txt`

**Proprietary and Business:**
```
PROPRIETARY
PROPRIETARY INFORMATION
COMPANY PROPRIETARY
TRADE SECRET
CONFIDENTIAL BUSINESS
BUSINESS SENSITIVE
COMPETITION SENSITIVE
SOURCE SELECTION
SOURCE SELECTION INFORMATION
```

**Proposal and Contract:**
```
PROPOSAL
BID
RFP (Request for Proposal)
RFQ (Request for Quotation)
RFI (Request for Information)
SOW (Statement of Work)
PWS (Performance Work Statement)
SOO (Statement of Objectives)
CDRL (Contract Data Requirements List)
CLIN (Contract Line Item Number)
WBS (Work Breakdown Structure)
CWBS (Contract Work Breakdown Structure)
```

**Program Management:**
```
IMS (Integrated Master Schedule)
IMP (Integrated Master Plan)
EVM (Earned Value Management)
EVMS (Earned Value Management System)
PDR (Preliminary Design Review)
CDR (Critical Design Review)
SRR (System Requirements Review)
TRR (Test Readiness Review)
TRL (Technology Readiness Level)
MRL (Manufacturing Readiness Level)
IOC (Initial Operational Capability)
FOC (Full Operational Capability)
MS A (Milestone A)
MS B (Milestone B)
MS C (Milestone C)
MDAP (Major Defense Acquisition Program)
ACAT (Acquisition Category)
```

**Security and Compliance:**
```
NIST 800-171
NIST 800-53
CMMC
CMMC 2.0
FCI (Federal Contract Information)
CUI (Controlled Unclassified Information)
CDI (Covered Defense Information)
FAR (Federal Acquisition Regulation)
DFARS (Defense Federal Acquisition Regulation Supplement)
DD254
DD441
SF312
SF86
FSO (Facility Security Officer)
ISSM (Information System Security Manager)
ISSO (Information System Security Officer)
DCSA (Defense Counterintelligence and Security Agency)
DISS (Defense Information System for Security)
```

*Full list available in attached text file.*

### Appendix E: PowerShell Commands Reference

**Connect to Security & Compliance Center:**
```powershell
Install-Module -Name ExchangeOnlineManagement
Connect-IPPSSession -UserPrincipalName admin@leonardocompany.ca
```

**List all custom SITs:**
```powershell
Get-DlpSensitiveInformationType | Where-Object {$_.Publisher -eq "YourOrganization"} | 
    Select-Object Name, Id, RecommendedConfidence
```

**Export SIT configuration:**
```powershell
$SIT = Get-DlpSensitiveInformationType -Identity "Leonardo - NATO Classification Keywords"
$SIT | ConvertTo-Json -Depth 10 | Out-File "SIT_NATO_Export.json"
```

**List auto-labeling policies:**
```powershell
Get-AutoSensitivityLabelPolicy | 
    Select-Object Name, Mode, @{N='Labels';E={$_.ApplyAutoSensitivityLabel}}
```

**Check policy status:**
```powershell
Get-AutoSensitivityLabelPolicy -Identity "Auto-label NATO Classified Content" | 
    Format-List Name, Mode, Enabled, Priority, WhenCreated, WhenChanged
```

**Get labeling statistics from Content Explorer:**
```powershell
# Note: Use Content Explorer UI for detailed statistics
# PowerShell access to Content Explorer is limited
# Access via: https://compliance.microsoft.com/dataclassification
```

### Appendix F: Troubleshooting Guide

**Issue: SIT not detecting expected content**

Possible causes:
1. Keywords not in dictionary (add variations)
2. Confidence threshold too high (reduce to 65%)
3. Instance count threshold too high (reduce to 1)
4. Character proximity too narrow (increase to 500)
5. Supporting elements contradicting primary elements (remove or adjust)

Resolution:
- Export test document text
- Manually search for keywords
- Check if keywords split across lines or formatting
- Adjust SIT pattern settings

**Issue: Too many false positives**

Possible causes:
1. Common business terms triggering SIT (e.g., "FAR" in "far away")
2. Instance count too low
3. No context validation (supporting elements missing)

Resolution:
- Add excluding keywords
- Increase instance count to 2 or 3
- Add supporting elements requiring business context
- Use word boundaries in regular expressions

**Issue: Auto-labeling not applying**

Possible causes:
1. Policy in simulation mode
2. Location not included in policy scope
3. User has manually applied different label (override)
4. Confidence level not met
5. Policy priority conflict (another policy taking precedence)

Resolution:
- Verify policy mode is "On"
- Check policy locations include target content
- Review Activity Explorer for label events
- Adjust confidence levels or policy priority

**Issue: Performance degradation**

Possible causes:
1. Too many SITs running simultaneously
2. Overly complex regular expressions
3. Very large keyword dictionaries
4. Scanning large volumes of content

Resolution:
- Consolidate SITs where possible
- Optimize regular expressions
- Use keyword lists instead of dictionaries for <100 words
- Implement gradual rollout by location

---

## Document Control

**Version History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Dec 2025 | Frederick Pearson | Initial release |

**Review Schedule:**
- Next review: March 2026 (quarterly)
- Owner: IT - Leonardo Canada inc.
- Approver: CSO

**Distribution:**
- LCE M365 Security Team
- Compliance Team
- IT Operations
- All Department Heads

**Classification:** Internal Use Only