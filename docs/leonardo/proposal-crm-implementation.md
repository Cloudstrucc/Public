---
marp: true
paginate: true
theme: default
size: 16:9
----------

![bg](./image/cloudstrucc_word_template.png)

# Proposal: Microsoft Power Platform & Dynamics 365 Sales Professional Implementation Project

## For [Client Name] - Federal Government Entity

### Prepared by Cloudstrucc Inc.
--- 
# 🛍️ Executive Summary

[Client Name], operating under the stringent requirements of the **Protected B classification** and governed by **Treasury Board of Canada Secretariat (TBS)** cybersecurity directives, requires a comprehensive Customer Relationship Management (CRM) solution that aligns with federal government security standards and operational requirements.

To deliver secure, compliant, and mission-critical CRM capabilities, the implementation must ensure alignment with:

* **Government of Canada Directive on Security Management** (Protected B requirements)
* **Treasury Board Cyber Security Event Management Plan**
* **ITSG-33** IT Security Risk Management framework
* **ISO/IEC 27001** and **NIST 800-171** international standards
* **Controlled Unclassified Information (CUI)** handling guidelines
* **PIPEDA** privacy protection requirements
* **Cloud Security Assessment and Authorization (CSAA)** framework

This proposal outlines how Cloudstrucc will implement a **Microsoft Dynamics 365 Sales Professional and Power Platform solution** that creates a **fully secure, Protected B-compliant CRM environment** with advanced threat protection, data loss prevention, customer-managed encryption keys, and **network isolation using Azure Private Endpoints and Virtual Network (VNET) integration**.

These enhancements ensure data sovereignty, prevent unauthorized access, and provide granular control over Microsoft 365 and Power Platform traffic through approved network pathways — critical requirements for federal government compliance.

The end state will position [Client Name] with a secure, modern, and scalable CRM platform that maximizes existing Microsoft 365 E5 investments while ensuring comprehensive compliance with federal security regulations and seamless integration with existing JIRA on-premise infrastructure, including project/task mapping and budget module connectivity for enhanced financial visibility from lead generation through project completion.

**Important Note**: This proposal is based on high-level requirements gathered to date. Final scope and implementation details will be refined during the discovery phase to ensure all specific organizational needs are addressed.

---

## 🔐 Scope of Work

### Core Dynamics 365 Sales Professional Implementation

* ✅ Deploy and configure Dynamics 365 Sales Professional with Protected B compliance
* ✅ Implement comprehensive contact management and opportunity tracking
* ✅ Configure sales pipeline automation and opportunity management
* ✅ Setup advanced analytics and reporting with Power BI integration
* ✅ Enable custom entity creation and workflow automation

### Power Platform Security Hardening

* ✅ Configure Power Platform environments with Protected B security controls
* ✅ Implement Azure Private Endpoints for Power Platform services
* ✅ Enable VNET integration for secure network isolation
* ✅ Apply Microsoft Purview policies (DLP, auto-labeling, encryption)
* ✅ Configure Customer Managed Keys (CMK) for data encryption
* ✅ Setup Conditional Access and session controls
* ✅ Enforce managed device compliance for platform access

### JIRA Integration & Workflow Automation

* ✅ Design and implement bi-directional JIRA on-premise integration via On-Premises Data Gateway
* ✅ Configure Power Automate flows for real-time data synchronization
* ✅ Setup budget module connectivity and financial workflow automation
* ✅ Implement project and task mapping between JIRA and Dynamics Sales pipeline
* ✅ Enable automated case escalation and status updates
* ✅ Implement custom field mapping and data transformation

### Advanced Security & Compliance

* ✅ Configure Sensitivity Labels (client-provided or default Protected B classifications)
* ✅ Implement Data Loss Prevention (DLP) policies
* ✅ Enable Microsoft Defender for Office 365 and Power Platform
* ✅ Configure comprehensive audit logging and retention policies
* ✅ Implement Protected B data classification and handling
* ✅ Setup security monitoring with recommendations for SIEM integration (client responsibility)

### Training & Documentation

* ✅ Deliver comprehensive user training and administrator guides
* ✅ Provide security best practices documentation
* ✅ Conduct knowledge transfer sessions
* ✅ 90-day support period with optional extension

---

## 🧰 Pre-Requisites and Deployment Approach

To perform the activities outlined in this proposal, the following pre-requisites and operating model must be established:

### 🔑 Access and Privileged Roles

Cloudstrucc will require:

* A dedicated **privileged administrative account** or membership in a **privileged role group** within Microsoft Entra ID.
* The following roles or equivalent custom RBAC assignments:

  * **Global Reader** (for assessments and baselining)
  * **Security Administrator** (for configuring Defender, alerts, Purview)
  * **Compliance Administrator** (for DLP, Sensitivity Labels, eDiscovery)
  * **Dynamics 365 Administrator**
  * **Power Platform Administrator**
  * **SharePoint Administrator** (for integrated document management)
  * **Privileged Role Administrator** (for conditional access configuration)
  * **Azure Network Contributor** (for private endpoint and VNET provisioning)
  * **Application Administrator** (for JIRA integration setup)

Access must be granted by the [Client Name] Entra administrator prior to production deployment.

### 🏗️ Cloudstrucc Build & Staging Environment Model

To support structured, low-risk implementation aligned with federal change management requirements:

* Cloudstrucc will use its **own Azure subscription and Microsoft 365 tenant** for initial **build, configuration, and templating**.
* This isolated tenant will mirror [Client Name]'s Protected B compliance requirements and baseline.
* Implementation phases:

  * **Development Environment**: Initial configuration and testing in Cloudstrucc tenant
  * **Client Staging Environment**: Validation in client test tenant or sandbox
  * **Production Deployment**: Controlled rollout using Infrastructure as Code (IaC) templates

**Configuration artifacts will include:**

* **ARM/Bicep templates** for Azure resource provisioning
* **PowerShell scripts** for Power Platform configuration
* **Power Automate solutions** for JIRA integration
* **Compliance policy templates** for Protected B requirements

**This model ensures:**

* Minimal disruption to existing [Client Name] services
* Compliance with federal change management protocols
* Reproducible security posture across environments
* Audit trail for all configuration changes

### 🔐 Protected B Security Requirements

The implementation will address specific Protected B requirements:

* **Data Sovereignty**: All data remains within Canadian geographic boundaries
* **Encryption Standards**: AES-256 encryption at rest and TLS 1.3 in transit
* **Access Controls**: Multi-factor authentication and conditional access policies
* **Network Isolation**: Private endpoints and VNET integration
* **Audit Compliance**: Comprehensive logging and retention policies
* **Incident Response**: Integration with government security operations centers

---

## ⏳ Duration and Phasing

### Project Duration: **45 to 90 Calendar Days**

| Phase   | Duration   | Milestone                                    | Outcome                                       |
| ------- | ---------- | -------------------------------------------- | --------------------------------------------- |
| Phase 1 | Week 1-2   | Discovery & Protected B Assessment           | Gap analysis and compliance baseline         |
| Phase 2 | Week 3-4   | Core D365 Sales Professional Deployment     | CRM foundation with basic security controls   |
| Phase 3 | Week 5-7   | Power Platform Security Hardening           | Protected B compliance and network isolation  |
| Phase 4 | Week 8-10  | JIRA Integration & Workflow Automation      | Bi-directional sync and automated workflows  |
| Phase 5 | Week 11-12 | Advanced Security & Compliance              | Full DLP, labeling, and monitoring active    |
| Phase 6 | Week 13    | Testing, Training & Documentation           | User training, documentation, handover       |
| Final   | Day 90     | Go-Live & Support Transition                | Production ready, support period begins      |

---

## 💸 Implementation Cost Estimate (CAD)

*Implementation timeline and costs to be finalized based on detailed requirements gathering.*

| Item                                          | Description                                           | Estimated Cost (CAD) | Estimated Due Date |
| --------------------------------------------- | ----------------------------------------------------- | -------------------- | ------------------ |
| Discovery & Protected B Compliance Assessment | Security audit, gap analysis, compliance mapping     | $[TBD]               | [TBD]              |
| Dynamics 365 Sales Professional Setup        | Core CRM deployment, configuration, customization    | $[TBD]               | [TBD]              |
| Power Platform Security Hardening            | Private endpoints, VNET integration, CMK setup       | $[TBD]               | [TBD]              |
| JIRA Integration Development                  | Bi-directional sync, budget module connectivity      | $[TBD]               | [TBD]              |
| Advanced Security Configuration              | DLP, labels, monitoring, incident response setup     | $[TBD]               | [TBD]              |
| Data Migration & Legacy System Integration   | Data import, cleansing, legacy system connectivity   | $[TBD]               | [TBD]              |
| User Training & Change Management            | End-user training, admin training, adoption support  | $[TBD]               | [TBD]              |
| Documentation & Knowledge Transfer           | Admin guides, user manuals, security procedures      | $[TBD]               | [TBD]              |
| Support (90 days)                            | Post-implementation support, tuning, optimization    | $[TBD]               | [TBD]              |
| **Subtotal**                                  |                                                       | **$[TBD] CAD**       |                    |
| HST (13%)                                     |                                                       | **$[TBD] CAD**       |                    |
| **Total with HST**                           |                                                       | **$[TBD] CAD**       |                    |

**Payment Terms**
The total amount indicated in this proposal, including applicable taxes, shall become payable upon completion of the scope of work as outlined herein. Payment schedule will align with federal government procurement policies and milestone-based deliverables. Final payment shall be due within thirty (30) days of the client's written confirmation of acceptance and sign-off of the completed deliverables. This agreement shall be governed by the laws of the Province of Ontario and the federal laws of Canada applicable therein.

> *Optional extended support available at negotiated hourly rates*

---

## 📦 Licensing Requirements (CAD Pricing)

### Microsoft 365 & Dynamics 365 Licensing (CAD)

**Pre-requisite**: All users must have Microsoft 365 E5 licensing as the foundation for this implementation.

| License Component                    | Features Required                                          | Estimated Monthly Cost (CAD/user) |
| ------------------------------------ | ---------------------------------------------------------- | ---------------------------------- |
| Microsoft 365 E5 (Required)         | Base platform, advanced security, Power Platform included | ~$57                               |
| Dynamics 365 Sales Professional     | Core CRM functionality, sales automation                  | ~$25 (additional to E5)            |
| Power Platform Premium               | Advanced connectors, extended compute                      | ~$30                               |
| Microsoft Defender for Business Apps | Advanced threat protection for Dynamics 365               | ~$4                                |

### Power Platform Security Add-ons

| Security Component                   | Purpose                                         | Estimated Monthly Cost |
| ------------------------------------ | ----------------------------------------------- | ---------------------- |
| Customer Managed Keys (CMK)         | Enhanced encryption control for Protected B    | ~$500/month            |
| Private Endpoint Connectivity       | Network isolation and VNET integration         | ~$200/month            |
| Power Platform DLP Premium          | Advanced data loss prevention policies         | Included in E5         |
| Microsoft Purview Information Protection | Sensitivity labeling and classification    | Included in E5         |

### Notes on Federal Government Pricing

* Government pricing may be available through **Microsoft Enterprise Agreement** or **MPSA programs**
* **Volume licensing discounts** may apply based on organization size
* **GCdocs integration** may require additional licensing considerations
* All costs subject to federal procurement policies and approval processes

---

## 🔄 JIRA Integration Architecture

### Integration Overview

The JIRA on-premise integration will leverage Power Platform's enterprise-grade connectivity to establish secure, bi-directional data synchronization between Dynamics 365 and your existing JIRA infrastructure. This integration will provide complete visibility from lead generation through project completion by mapping sales opportunities to JIRA projects, tasks, and budget modules.

**Key Integration Capabilities:**

* **Sales Pipeline to JIRA Project Mapping**: Automatic creation of JIRA projects when sales opportunities reach specific stages
* **Task-Level Integration**: Detailed task mapping between Dynamics sales activities and JIRA work items
* **Budget Module Connectivity**: Real-time synchronization of financial data and budget tracking
* **Project Financial Visibility**: Management dashboards showing complete financial journey from lead to project delivery

### Technical Implementation

#### **On-Premises Data Gateway Architecture**

* **Secure DMZ Deployment**: On-Premises Data Gateway installed in your DMZ network for secure connectivity
* **Encrypted Communication**: All data transfer encrypted using TLS 1.3 between gateway and Microsoft cloud services
* **Network Isolation**: No direct internet connectivity to JIRA systems, all communication through gateway
* **High Availability**: Clustered gateway configuration for redundancy and load balancing

#### **Project and Task Mapping Framework**

* **Opportunity-to-Project Lifecycle**: Automated project creation in JIRA when opportunities advance to specific sales stages
* **Task Synchronization**: Bi-directional sync of sales activities (calls, meetings, proposals) with JIRA tasks
* **Work Item Tracking**: Real-time status updates between Dynamics sales activities and JIRA work items
* **Resource Allocation**: Integration of team assignments and time tracking across both platforms

#### **Budget Module Connectivity**

* **Financial Workflow Integration**: Link CRM opportunities to JIRA budget line items with real-time updates
* **Automated Budget Creation**: Generate budget entries in JIRA when opportunities reach qualified stages
* **Cost Center Mapping**: Automatic assignment of opportunities to appropriate budget categories and cost centers
* **Approval Process Integration**: Streamlined budget approval workflows triggered from sales pipeline events

#### **Data Mapping & Transformation**

* **Custom Field Mapping**: Flexible configuration mapping D365 opportunity fields to JIRA project/task fields
* **Business Rule Engine**: Configurable rules for data transformation and validation
* **Master Data Synchronization**: Consistent customer, product, and project data across both systems
* **Audit Trail Maintenance**: Complete tracking of all data synchronization activities with tamper-evident logging

### Sales-to-Project Management Benefits

#### **Enhanced Financial Visibility**

* **End-to-End Tracking**: Complete visibility from initial lead through project completion and billing
* **Budget vs. Actual Reporting**: Real-time comparison of sales projections with actual project costs
* **Resource Planning**: Improved capacity planning based on sales pipeline and project commitments
* **Revenue Recognition**: Automated revenue tracking aligned with project milestones and deliverables

#### **Operational Efficiency**

* **Reduced Manual Data Entry**: Automated synchronization eliminates duplicate data entry across systems
* **Consistent Project Naming**: Standardized project creation based on sales opportunity templates
* **Streamlined Handoffs**: Seamless transition from sales team to project delivery teams
* **Unified Reporting**: Consolidated dashboards showing sales and project metrics in single view

### Security Considerations

#### **Network Security**

* **DMZ Gateway Deployment**: Secure placement of data gateway in network demilitarized zone
* **Certificate-Based Authentication**: X.509 certificates for gateway authentication and API security
* **Data Encryption**: End-to-end encryption for all data transfers between systems
* **Network Segmentation**: Isolated network paths for integration traffic with firewall controls

#### **Compliance Alignment**

* **Protected B Data Handling**: Appropriate classification and handling of sensitive financial and project data
* **Comprehensive Audit Logging**: Full audit trail of all integration activities and data modifications
* **Role-Based Access Controls**: Granular permissions for integration management and data access
* **Data Residency**: Ensuring Canadian data sovereignty requirements for all synchronized data

---

## 🔒 Power Platform Security Best Practices

### Protected B Compliance Framework

#### **Data Classification & Handling**

* **Automatic Data Classification**: Automated identification of Protected B content
* **Sensitivity Labels**: Client-provided sensitivity label taxonomy or default Protected B classifications will be implemented
* **Retention Policies**: Automated data lifecycle management
* **Legal Hold Capabilities**: eDiscovery and litigation support

#### **Network Security Architecture**

* **Azure Private Endpoints**: Elimination of public internet data traversal
* **VNET Integration**: Secure virtual network connectivity
* **Network Security Groups**: Granular traffic control and filtering
* **On-Premises Data Gateway**: Secure connectivity for JIRA integration through DMZ deployment

#### **Identity & Access Management**

* **Conditional Access Policies**: Risk-based access controls
* **Privileged Identity Management**: Just-in-time administrative access
* **Multi-Factor Authentication**: Government-approved authentication methods
* **Zero Trust Architecture**: Verify every access request

#### **Threat Protection & Monitoring**

* **Microsoft Defender Integration**: Advanced threat detection and response
* **Behavioral Analytics**: Automated anomaly detection
* **Incident Response Automation**: Automated threat response workflows
* **SIEM Integration Readiness**: Platform configured to support client's existing SIEM solutions (client responsibility)

### Federal Government Security Standards

#### **Treasury Board Directive Compliance**

* **Directive on Security Management**: Comprehensive security management framework
* **Privacy Impact Assessment**: PIPEDA compliance and privacy protection
* **Security Control Assessment**: ITSG-33 security control implementation
* **Continuous Monitoring**: Ongoing security posture assessment

#### **Canadian Government Cloud Framework**

* **Cloud Security Assessment**: Formal security assessment and authorization
* **Data Sovereignty**: Canadian data residency requirements
* **Supplier Security Requirements**: Vendor security compliance verification
* **Security Incident Reporting**: Government security incident procedures

---

## 📋 Detailed Security Checklist

### Infrastructure Security

* [ ] Azure Private Endpoints configured for all Power Platform services
* [ ] VNET integration enabled with government-approved network architecture
* [ ] Customer Managed Keys (CMK) implemented for data encryption
* [ ] Network Security Groups configured with least-privilege access
* [ ] On-Premises Data Gateway deployed in DMZ for secure JIRA connectivity

### Identity & Access Security

* [ ] Conditional Access policies aligned with Protected B requirements
* [ ] Multi-Factor Authentication enforced for all users
* [ ] Privileged Identity Management implemented for administrative access
* [ ] Guest access controls configured per government standards
* [ ] Regular access reviews and certification processes established

### Data Protection & Classification

* [ ] Microsoft Purview Information Protection deployed
* [ ] Sensitivity labels configured (client-provided taxonomy or default Protected B classifications)
* [ ] Data Loss Prevention (DLP) policies implemented
* [ ] Automatic data classification enabled
* [ ] Data retention and deletion policies configured

### Monitoring & Compliance

* [ ] Microsoft Defender for Office 365 and Power Platform enabled
* [ ] Platform configured for SIEM integration (recommended - client responsibility)
* [ ] Comprehensive audit logging implemented
* [ ] Compliance dashboard and reporting established
* [ ] Incident response procedures documented and tested

---

## 📄 Appendices

### Appendix A: Power Platform Security Architecture Diagram

* Detailed network architecture showing private endpoints and VNET integration

```mermaid

graph TB
    subgraph "Client On-Premises Network"
        subgraph "DMZ"
            OPDG[On-Premises Data Gateway<br/>- TLS 1.3 Encryption<br/>- Certificate Auth<br/>- High Availability]
        end
        
        subgraph "Internal Network"
            JIRA[JIRA Server<br/>- Projects & Tasks<br/>- Budget Modules<br/>- API Endpoints]
            AD[Active Directory<br/>- User Authentication<br/>- Group Management]
            FW[Corporate Firewall<br/>- Network Segmentation<br/>- Traffic Filtering]
        end
    end

    subgraph "Azure Government Cloud (Canada)"
        subgraph "Client VNET"
            subgraph "Private Endpoint Subnet"
                PE1[Private Endpoint<br/>Power Platform]
                PE2[Private Endpoint<br/>Dynamics 365]
                PE3[Private Endpoint<br/>Microsoft Graph]
                PE4[Private Endpoint<br/>Key Vault]
            end
            
            subgraph "Application Subnet"
                NSG[Network Security Groups<br/>- Least Privilege Access<br/>- Protected B Controls]
            end
        end
        
        subgraph "Microsoft 365 Services"
            subgraph "Power Platform"
                PP[Power Platform<br/>- Custom Connectors<br/>- Power Automate<br/>- Data Integration]
            end
            
            subgraph "Dynamics 365"
                D365[Dynamics 365 Sales<br/>- CRM Functionality<br/>- Sales Pipeline<br/>- Customer Data]
            end
            
            subgraph "Security Services"
                KV[Azure Key Vault<br/>- Customer Managed Keys<br/>- Certificate Storage<br/>- Secret Management]
                AAD[Azure AD Premium<br/>- Conditional Access<br/>- MFA Enforcement<br/>- Identity Protection]
            end
        end
    end

    subgraph "Microsoft Global Network"
        subgraph "Compliance & Security"
            PURVIEW[Microsoft Purview<br/>- Data Classification<br/>- DLP Policies<br/>- Audit Logging]
            DEFENDER[Microsoft Defender<br/>- Threat Protection<br/>- Security Monitoring<br/>- Incident Response]
        end
    end

    %% Network Connections
    OPDG -.->|Encrypted Tunnel| PE1
    OPDG -.->|Encrypted Tunnel| PE2
    JIRA <--> OPDG
    AD <--> OPDG
    FW <--> OPDG
    
    PE1 <--> PP
    PE2 <--> D365
    PE3 <--> AAD
    PE4 <--> KV
    
    PP <--> PURVIEW
    D365 <--> PURVIEW
    PP <--> DEFENDER
    D365 <--> DEFENDER
    
    NSG -.->|Traffic Control| PE1
    NSG -.->|Traffic Control| PE2
    NSG -.->|Traffic Control| PE3
    NSG -.->|Traffic Control| PE4

    %% Styling
    classDef onPrem fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef azure fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef security fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef microsoft fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    
    class OPDG,JIRA,AD,FW onPrem
    class PE1,PE2,PE3,PE4,NSG,PP,D365,KV,AAD azure
    class PURVIEW,DEFENDER security

```

* Data flow diagrams for Protected B information handling

```mermaid

flowchart TD
    subgraph "Data Classification & Ingestion"
        USER[End User<br/>Creates/Accesses Data]
        CLASSIFY[Auto-Classification<br/>- Protected B Detection<br/>- Sensitivity Labels<br/>- Content Scanning]
    end

    subgraph "Data Processing Layer"
        DLP[Data Loss Prevention<br/>- Policy Enforcement<br/>- Content Inspection<br/>- Action Blocking]
        ENCRYPT[Encryption Engine<br/>- Customer Managed Keys<br/>- AES-256 at Rest<br/>- TLS 1.3 in Transit]
    end

    subgraph "Storage & Retention"
        subgraph "Dynamics 365"
            D365_STORE[Customer Records<br/>- Contact Information<br/>- Sales Opportunities<br/>- Protected B Classified]
        end
        
        subgraph "Power Platform"
            PP_STORE[Integration Data<br/>- JIRA Mappings<br/>- Workflow States<br/>- Audit Logs]
        end
        
        subgraph "Compliance Storage"
            AUDIT_STORE[Audit Repository<br/>- Access Logs<br/>- Data Modifications<br/>- Compliance Records]
        end
    end

    subgraph "Data Access & Controls"
        CONDITIONAL[Conditional Access<br/>- Device Compliance<br/>- Location Verification<br/>- Risk Assessment]
        MFA[Multi-Factor Auth<br/>- Government Approved<br/>- Hardware Tokens<br/>- Biometric Options]
    end

    subgraph "External Integration"
        JIRA_INT[JIRA Integration<br/>- Budget Data<br/>- Project Information<br/>- Task Assignments]
        DATA_GATEWAY[On-Premises Gateway<br/>- Encrypted Channel<br/>- Certificate Auth<br/>- DMZ Deployment]
    end

    subgraph "Monitoring & Compliance"
        MONITOR[Real-time Monitoring<br/>- Data Access Tracking<br/>- Anomaly Detection<br/>- Incident Alerting]
        RETENTION[Retention Policies<br/>- Automated Deletion<br/>- Legal Hold<br/>- Archive Management]
        PURVIEW_AUDIT[Microsoft Purview<br/>- Compliance Dashboard<br/>- Risk Assessment<br/>- Regulatory Reporting]
    end

    %% Data Flow Connections
    USER --> CLASSIFY
    CLASSIFY --> DLP
    DLP --> ENCRYPT
    
    ENCRYPT --> D365_STORE
    ENCRYPT --> PP_STORE
    
    USER --> CONDITIONAL
    CONDITIONAL --> MFA
    MFA --> D365_STORE
    MFA --> PP_STORE
    
    PP_STORE <--> DATA_GATEWAY
    DATA_GATEWAY <--> JIRA_INT
    
    D365_STORE --> AUDIT_STORE
    PP_STORE --> AUDIT_STORE
    JIRA_INT --> AUDIT_STORE
    
    AUDIT_STORE --> MONITOR
    AUDIT_STORE --> RETENTION
    MONITOR --> PURVIEW_AUDIT
    RETENTION --> PURVIEW_AUDIT

    %% Data Classification Labels
    CLASSIFY -.->|Protected B Label| D365_STORE
    CLASSIFY -.->|Protected B Label| PP_STORE
    CLASSIFY -.->|Protected B Label| JIRA_INT

    %% Styling
    classDef dataClass fill:#e3f2fd,stroke:#0277bd,stroke-width:2px
    classDef security fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef storage fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef integration fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef compliance fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    
    class USER,CLASSIFY,DLP dataClass
    class CONDITIONAL,MFA,ENCRYPT security
    class D365_STORE,PP_STORE,AUDIT_STORE storage
    class JIRA_INT,DATA_GATEWAY integration
    class MONITOR,RETENTION,PURVIEW_AUDIT compliance

```

* Identity and access management architecture

```mermaid

graph TB
    subgraph "Identity Sources"
        USER_FED[Federal Employee<br/>- Government ID<br/>- Security Clearance<br/>- Device Registered]
        USER_CONT[Contractor<br/>- Sponsored Account<br/>- Limited Access<br/>- Temporary Credentials]
        USER_EXT[External User<br/>- Guest Account<br/>- Restricted Access<br/>- Time-Limited]
    end

    subgraph "Authentication Layer"
        subgraph "Primary Authentication"
            AAD[Azure AD Premium P2<br/>- Primary Identity Store<br/>- Hybrid Sync<br/>- Password Policies]
            ADFS[AD FS Integration<br/>- On-Premises Auth<br/>- Claims-Based<br/>- Federation Trust]
        end
        
        subgraph "Multi-Factor Authentication"
            MFA_HW[Hardware Tokens<br/>- FIDO2 Keys<br/>- Smart Cards<br/>- Government Approved]
            MFA_APP[Authenticator Apps<br/>- Microsoft Authenticator<br/>- Push Notifications<br/>- Time-based Codes]
            MFA_BIO[Biometric Auth<br/>- Windows Hello<br/>- Fingerprint<br/>- Face Recognition]
        end
    end

    subgraph "Authorization & Access Control"
        subgraph "Conditional Access"
            CA_DEVICE[Device Compliance<br/>- Managed Devices<br/>- Encryption Required<br/>- Health Attestation]
            CA_LOCATION[Location-Based<br/>- Trusted Networks<br/>- Geographic Restrictions<br/>- VPN Requirements]
            CA_RISK[Risk-Based Access<br/>- Sign-in Risk<br/>- User Risk<br/>- Behavioral Analysis]
        end
        
        subgraph "Role-Based Access"
            RBAC_ADMIN[Administrative Roles<br/>- Global Admin<br/>- Security Admin<br/>- Compliance Admin]
            RBAC_USER[User Roles<br/>- Sales Professional<br/>- Project Manager<br/>- Read-Only Access]
            RBAC_CUSTOM[Custom Roles<br/>- Dynamics Permissions<br/>- Power Platform Access<br/>- JIRA Integration Rights]
        end
    end

    subgraph "Privileged Access Management"
        PIM[Privileged Identity Management<br/>- Just-in-Time Access<br/>- Approval Workflows<br/>- Time-Limited Elevation]
        PAM[Privileged Access Workstation<br/>- Secure Admin Access<br/>- Isolated Environment<br/>- Enhanced Monitoring]
        BREAK_GLASS[Emergency Access<br/>- Break-Glass Accounts<br/>- Audit Trail<br/>- Executive Approval]
    end

    subgraph "Application Access"
        subgraph "Microsoft 365 Services"
            D365_ACCESS[Dynamics 365<br/>- Sales Professional<br/>- Customer Data<br/>- Pipeline Management]
            PP_ACCESS[Power Platform<br/>- Custom Apps<br/>- Workflow Automation<br/>- Data Integration]
            M365_ACCESS[Microsoft 365<br/>- Email & Calendar<br/>- SharePoint<br/>- Teams Integration]
        end
        
        subgraph "Integrated Systems"
            JIRA_ACCESS[JIRA Access<br/>- Project Management<br/>- Budget Modules<br/>- Task Tracking]
            REPORTING[Reporting Access<br/>- Power BI<br/>- Compliance Dashboards<br/>- Audit Reports]
        end
    end

    subgraph "Session Management"
        SESSION[Session Controls<br/>- Persistent Access<br/>- Idle Timeout<br/>- Device Registration]
        MONITOR_ACCESS[Access Monitoring<br/>- Real-time Alerts<br/>- Anomaly Detection<br/>- Risk Scoring]
        REVIEW[Access Reviews<br/>- Quarterly Certification<br/>- Manager Approval<br/>- Automated Cleanup]
    end

    %% Authentication Flow
    USER_FED --> AAD
    USER_CONT --> AAD
    USER_EXT --> AAD
    
    AAD <--> ADFS
    AAD --> MFA_HW
    AAD --> MFA_APP
    AAD --> MFA_BIO

    %% Authorization Flow
    MFA_HW --> CA_DEVICE
    MFA_APP --> CA_LOCATION
    MFA_BIO --> CA_RISK
    
    CA_DEVICE --> RBAC_ADMIN
    CA_LOCATION --> RBAC_USER
    CA_RISK --> RBAC_CUSTOM

    %% Privileged Access Flow
    RBAC_ADMIN --> PIM
    PIM --> PAM
    PIM --> BREAK_GLASS

    %% Application Access Flow
    RBAC_USER --> D365_ACCESS
    RBAC_USER --> PP_ACCESS
    RBAC_USER --> M365_ACCESS
    RBAC_CUSTOM --> JIRA_ACCESS
    RBAC_ADMIN --> REPORTING

    %% Session Management Flow
    D365_ACCESS --> SESSION
    PP_ACCESS --> SESSION
    JIRA_ACCESS --> SESSION
    
    SESSION --> MONITOR_ACCESS
    MONITOR_ACCESS --> REVIEW
    REVIEW --> AAD

    %% Styling
    classDef identity fill:#e8eaf6,stroke:#3f51b5,stroke-width:2px
    classDef auth fill:#e0f2f1,stroke:#00695c,stroke-width:2px
    classDef access fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef privileged fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef apps fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef session fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    
    class USER_FED,USER_CONT,USER_EXT identity
    class AAD,ADFS,MFA_HW,MFA_APP,MFA_BIO auth
    class CA_DEVICE,CA_LOCATION,CA_RISK,RBAC_ADMIN,RBAC_USER,RBAC_CUSTOM access
    class PIM,PAM,BREAK_GLASS privileged
    class D365_ACCESS,PP_ACCESS,M365_ACCESS,JIRA_ACCESS,REPORTING apps
    class SESSION,MONITOR_ACCESS,REVIEW session

```

* Integration security model with JIRA on-premise (EXAMPLE)

```mermaid

sequenceDiagram
    participant User as Sales User
    participant D365 as Dynamics 365 Sales
    participant PP as Power Platform
    participant Gateway as On-Premises Gateway
    participant JIRA as JIRA Server
    participant Budget as Budget Module
    participant Audit as Audit System

    Note over User,Audit: Sales Opportunity to JIRA Project Integration Flow

    %% Authentication & Authorization
    User->>D365: Create Sales Opportunity
    D365->>PP: Trigger Integration Workflow
    
    Note over PP,Gateway: Secure Authentication Process
    PP->>Gateway: Request Connection (Certificate Auth)
    Gateway->>Gateway: Validate Certificate & Permissions
    Gateway->>JIRA: Authenticate (Service Account)
    JIRA-->>Gateway: Authentication Success
    Gateway-->>PP: Secure Channel Established

    %% Data Synchronization Process
    Note over D365,JIRA: Bi-Directional Data Sync
    PP->>Gateway: Send Opportunity Data (Encrypted)
    Gateway->>Gateway: Decrypt & Validate Data
    Gateway->>JIRA: Create/Update Project
    JIRA->>Budget: Link to Budget Module
    Budget-->>JIRA: Budget Line Item Created
    JIRA-->>Gateway: Project Created Successfully
    Gateway-->>PP: Success Response (Encrypted)
    PP-->>D365: Update Opportunity Status

    %% Task Mapping Process
    Note over User,Budget: Task-Level Integration
    User->>D365: Create Sales Activity
    D365->>PP: Trigger Task Sync
    PP->>Gateway: Send Task Data
    Gateway->>JIRA: Create Work Item
    JIRA->>JIRA: Map to Project Structure
    JIRA-->>Gateway: Task Created
    Gateway-->>PP: Task Reference
    PP-->>D365: Link Task Reference

    %% Financial Integration
    Note over PP,Audit: Budget & Financial Sync
    JIRA->>Budget: Update Budget Status
    Budget->>Gateway: Financial Data Update
    Gateway->>PP: Budget Information
    PP->>D365: Update Opportunity Value
    D365->>Audit: Log Financial Changes

    %% Security & Compliance Monitoring
    Note over Gateway,Audit: Continuous Security Monitoring
    par Security Monitoring
        Gateway->>Audit: Log All Transactions
        PP->>Audit: Log Integration Activities
        D365->>Audit: Log Data Modifications
        JIRA->>Audit: Log Project Changes
    and Data Validation
        Gateway->>Gateway: Validate Data Integrity
        PP->>PP: Apply DLP Policies
        D365->>D365: Check Sensitivity Labels
    and Compliance Checking
        Audit->>Audit: Protected B Classification Check
        Audit->>Audit: Access Permission Validation
        Audit->>Audit: Data Residency Verification
    end

    %% Error Handling & Recovery
    Note over PP,JIRA: Error Handling Process
    alt Integration Failure
        Gateway->>PP: Connection Error
        PP->>PP: Initiate Retry Logic
        PP->>Audit: Log Error Details
        PP->>User: Notification of Failure
    else Data Validation Failure
        Gateway->>Gateway: Data Validation Failed
        Gateway->>PP: Validation Error
        PP->>D365: Mark for Manual Review
        D365->>User: Request Data Correction
    else Security Violation
        Gateway->>Audit: Security Alert
        Audit->>Audit: Incident Response
        Audit->>User: Access Suspended
    end

    %% Real-time Status Updates
    Note over JIRA,D365: Status Synchronization
    loop Every 15 Minutes
        JIRA->>Gateway: Send Status Updates
        Gateway->>PP: Process Updates
        PP->>D365: Update Opportunity Status
        D365->>User: Refresh Dashboard
    end

    %% Styling Notes
    Note over User,Audit: All communications use TLS 1.3 encryption
    Note over Gateway,JIRA: Certificate-based authentication required
    Note over PP,Audit: All activities logged for compliance audit

```

### Appendix B: JIRA Integration Technical Specifications

* On-Premises Data Gateway configuration and DMZ deployment guidelines
* Project and task mapping specifications between Dynamics Sales and JIRA
* Budget module integration technical architecture and data flows
* API endpoint configurations and authentication methods
* Workflow automation sequences and business logic
* Error handling and recovery procedures

### Appendix C: Compliance Mapping Matrix

* Protected B requirements mapped to Power Platform security controls
* ITSG-33 security control implementation details
* Privacy protection measures and PIPEDA compliance
* Sensitivity label requirements (client-provided or default classifications)
* Audit and reporting capabilities for government oversight

### Appendix D: Assumptions and Caveats

* **High-Level Requirements**: This proposal is based on preliminary requirements gathering; detailed specifications will be refined during discovery phase
* **JIRA Integration Scope**: Integration assumes standard JIRA project/task structure and budget module configuration
* **Network Infrastructure**: Assumes client has appropriate DMZ network infrastructure for On-Premises Data Gateway deployment
* **Sensitivity Labels**: Implementation will use client-provided sensitivity label taxonomy or implement default Protected B classifications
* **SIEM Integration**: Platform will be configured to support SIEM integration as a recommended best practice (client responsibility)
* **Change Management**: Assumes standard federal government change management and approval processes will be followed

### Appendix D: Federal Government Compliance References

* [Treasury Board Directive on Security Management](https://www.tbs-sct.gc.ca/pol/doc-eng.aspx?id=16578)
* [Government of Canada ITSG-33](https://www.cse-cst.gc.ca/en/itsg-33)
* [Protected B Information Handling Guidelines](https://www.tpsgc-pwgsc.gc.ca/esc-src/protection-protection/niveaux-levels-eng.html)
* [Cloud Security Assessment Framework](https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/cloud-services/cloud-security.html)
* [Microsoft Power Platform Security Documentation](https://docs.microsoft.com/en-us/power-platform/admin/security)

---
![bg right:50%](./image/cloudstrucc_sig_transbg.png)
