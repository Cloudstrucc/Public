---
marp: true
paginate: true
header: ''
theme: default
size: 16:9
---

![](./image/cloudstrucc_word_template.png)

# Proposal: Microsoft Dynamics 365 Sales Implementation

## For Leonardo Company - Canada

### Prepared by Cloudstrucc Inc

---

# 🛍️ Executive Summary

Leonardo Company Canada, a leading defence contractor and critical service provider for the naval electronics segment, requires a robust Customer Relationship Management (CRM) platform to enhance sales operations, opportunity tracking, and customer engagement workflows while maintaining compliance with security and data governance requirements. In addition the client seeking the ability to create more comprehensive financial bugetting dashboards that include the end to end process from its clients and products sold.

To support Leonardo Company's strategic growth objectives and operational excellence, Cloudstrucc proposes the implementation of **Microsoft Dynamics 365 Sales** as a comprehensive sales management solution that will:

* Centralize customer and opportunity management
* Streamline sales processes and forecasting
* Provide real-time visibility into pipeline and performance metrics
* Integrate seamlessly with existing Microsoft 365 environment
* Maintain compliance with **ITSG-33**, **Controlled Goods Program (CGP)**, and **ISO/IEC 27001** security frameworks
* Implement **Customer Managed Keys (CMK)** for enhanced data encryption and sovereignty in Power Platform (inherit existing implementation of CMK at Leonardo Canada inc.)
* Satisfy the reporting and BI requirements at Leonardo Canada inc. to ensure synergy and end to end view of forecasts and actual budgets

This proposal outlines a focused implementation approach that delivers a production-ready Dynamics 365 Sales environment with core functionality, security hardening, and knowledge transfer to enable Leonardo Company's sales team to operate effectively within a compliant, scalable platform.

The end state will position Leonardo Company Canada with a modern CRM platform that enhances sales productivity while maintaining the rigorous security posture required for defence sector operations.

---

## 🔐 Scope of Work (deliverables)

* ✅ Provision Microsoft Dynamics 365 Sales licensing for user cohort
* ✅ Apply Customer Managed Keys (CMK) for Dataverse encryption
* ✅ Configure core Dynamics 365 Sales entities (Accounts, Contacts, Leads, Opportunities)
* ✅ Implement business process flows for opportunity management
* ✅ Configure sales dashboards and key performance metrics
* ✅ Setup security roles and team-based access controls
* ✅ Integrate with Microsoft 365 (Teams, Outlook, SharePoint)
* ✅ Apply Microsoft Purview sensitivity labels and DLP policies
* ✅ Configure audit logging and data retention policies
* ✅ Establish duplicate detection and data quality rules
* ✅ Create custom views and forms for sales workflow optimization
* ✅ Deliver administrator documentation and user training materials
* ✅ Conduct knowledge transfer sessions with IT and sales leadership
* ✅ 30-day post-implementation support period

---

## 🧰 Pre-Requisites and Deployment Approach

To perform the activities outlined in this proposal, the following pre-requisites and operating model must be established:

### 🔑 Access and Privileged Roles

Cloudstrucc will require:

* A dedicated **privileged administrative account** (e.g., `d365-admin@leonardocompany.com`) or membership in a **privileged role group** within Microsoft Entra ID. Alternatively, leverage existing Cloudstrucc inc. resource's administrator account.
* The following roles:

  * **Dynamics 365 Administrator** (for environment provisioning and configuration)
  * **Power Platform Administrator** (for Dataverse and security configuration)
  * **Global Reader** (for assessments and baselining)
  * **Security Administrator** (for configuring sensitivity labels, DLP)
  * **Compliance Administrator** (for audit policies and retention)
  * **Azure Key Vault Administrator** (for CMK configuration)

Access must be granted by the Leonardo Company Entra administrator prior to work commencing.

### 🏗️ Implementation Model

To support structured, low-risk implementation:

* Cloudstrucc will provision a **sandbox Dynamics 365 environment** within Leonardo Company's tenant for initial configuration, validation, and user acceptance testing.
* Once configuration is validated:

  * The solution will be **promoted to the production environment** using Microsoft's ALM (Application Lifecycle Management) tools.
  * Configuration documentation and deployment scripts will be provided for future reference.
  * A controlled change management process will be followed in collaboration with Leonardo Company IT administrators.

**This model ensures:**

* Minimal disruption to existing business operations
* Thorough testing before production deployment
* Reproducible configuration patterns for future expansion

This is reflected in the project schedule.

---

## ⏳ Duration and Phasing

### Project Duration: **45 Calendar Days**

| Phase   | Duration  | Milestone                                  | Outcome                                     |
| ------- | --------- | ------------------------------------------ | ------------------------------------------- |
| Phase 1 | Week 1    | Kickoff & Requirements Gathering           | Understand sales processes and requirements |
| Phase 2 | Week 2    | Licensing & Environment Provisioning       | D365 Sales licenses applied, sandbox ready  |
| Phase 3 | Weeks 3-4 | Customer Managed Keys (CMK) Implementation | CMK encryption applied to Dataverse         |
| Phase 4 | Weeks 4-5 | Core Configuration & Customization         | Entities, forms, views, business processes  |
| Phase 5 | Week 6    | Integration, Testing & UAT                 | M365 integration, user testing, refinements |
| Phase 6 | Week 6-7  | Documentation & Knowledge Transfer         | Training delivered, documentation provided  |
| Final   | Day 45    | Production Deployment & Handover           | Live system, 30-day support period begins   |

---

## 💸 Implementation Cost Estimate (CAD)

*Starting from the week of **January 6, 2025**, estimated due dates are projected based on a 45-day delivery schedule.*

| Item                                                  | Description                                            | Estimated Cost (CAD)   | Estimated Due Date |
| ----------------------------------------------------- | ------------------------------------------------------ | ---------------------- | ------------------ |
| Discovery & Requirements Gathering                    | Kickoff, process workshops, requirements documentation | \$1,800                | January 10, 2025   |
| Licensing Provisioning & Environment Setup            | D365 Sales licenses applied, sandbox environment       | \$1,200                | January 17, 2025   |
| Customer Managed Keys (CMK) Implementation (security) | Azure Key Vault setup, CMK encryption for Dataverse    | \$2,500                | January 31, 2025   |
| Core Sales Configuration - Entities & Forms           | Accounts, Contacts, Leads, Opportunities setup         | \$2,000                | February 7, 2025   |
| Business Process Flows & Automation                   | Opportunity management workflows, automation rules     | \$2,000                | February 14, 2025  |
| Security Configuration & Access Controls (security)   | Security roles, teams, field-level security            | \$1,500                | February 14, 2025  |
| Dashboards, Views & Reporting                         | Sales dashboards, custom views, KPI metrics            | \$1,200                | February 18, 2025  |
| Microsoft 365 Integration                             | Teams, Outlook, SharePoint integration                 | \$1,000                | February 18, 2025  |
| Purview DLP & Compliance Configuration (security)     | Sensitivity labels, audit logging, retention policies  | \$800                  | February 21, 2025  |
| User Acceptance Testing & Refinements                 | UAT coordination, issue resolution, optimization       | \$800                  | February 25, 2025  |
| Documentation & Knowledge Transfer                    | Admin guides, user training materials, live sessions   | \$1,200                | February 28, 2025  |
| **Subtotal**                                    |                                                        | **\$15,000 CAD** |                    |
| HST (13%)                                             |                                                        | **\$1,950 CAD**  |                    |
| **Total with HST**                              |                                                        | **\$16,950 CAD** |                    |

**Payment Terms**
The total amount indicated in this proposal, including applicable taxes, shall become payable upon completion of the scope of work as outlined herein. Final payment shall be due within thirty (30) days of the client's written confirmation of acceptance and sign-off of the completed deliverables.

> *Optional post-implementation enhancements / support (after the 30 support period) extension available at \$125/hr.*

---

## 📦 Licensing Requirements (CAD Pricing)

To implement Dynamics 365 Sales, Leonardo Company Canada will require the following licensing:

### Microsoft Dynamics 365 Licensing (CAD)

| License Tier                    | Features Included                                                   | Estimated Monthly Cost (CAD/user)             |
| ------------------------------- | ------------------------------------------------------------------- | --------------------------------------------- |
| Dynamics 365 Sales Professional | Core sales automation, opportunity management, basic customization  | \~\$78 **(NOTE, does not include CMK)** |
| Dynamics 365 Sales Enterprise   | Advanced customization, unlimited custom entities, enhanced reports | \~\$118 **(RECOMMENDED)**               |
| Dynamics 365 Customer Insights  | AI-driven insights, customer segmentation, predictive analytics     | \~\$1,890/tenant (optional)                   |

### Notes

* **Sales Enterprise** is recommended for defence contractors requiring advanced security controls, custom entity configurations, and extensive reporting capabilities.
* Customer Managed Keys (CMK) require **Enterprise** licensing tier.
* Microsoft Purview integration for sensitivity labels requires **Microsoft 365 E5** licensing (if not already in place).
* Minimum quantity requirements and enterprise agreements may affect pricing.
* Implementation costs do not include ongoing licensing fees.

---

## 📋 Detailed Configuration Deliverables

### Core Sales Entities Configuration

**Accounts Management (examples - custom account management will be built based on the requirements of Leonardo Canada inc.)**

* Custom fields for defence sector classifications (CGP status, security clearance levels)
* Account hierarchies for parent-subsidiary relationships
* Integration with Microsoft 365 for document management
* Custom views for active defence contracts, prospects, and partners

**Contact Management (examples - custom contact management will be built based on the requirements of Leonardo Canada inc.)**

* Enhanced contact profiles with role-specific fields
* Security clearance tracking and expiration alerts
* Communication preference management
* LinkedIn Sales Navigator integration (if licensed)

**Lead Management (examples - custom lead management will be built based on the requirements of Leonardo Canada inc.)**

* Lead qualification workflows
* Lead scoring based on defence sector criteria
* Automated lead assignment rules
* Duplicate detection and merge capabilities

**Opportunity Management (examples - custom opportunity management will be built based on the requirements of Leonardo Canada inc.)**

* Opportunity stages aligned to Leonardo Company's sales process
* Budget, timeline, and probability tracking
* Competitor tracking and win/loss analysis
* Custom fields for contract types, classification levels, and compliance requirements

### Business Process Automation

**Sales Process Flows (examples - custom sales process flows will be built based on the requirements of Leonardo Canada inc.)**

* Standardized opportunity progression workflow
* Approval processes for high-value deals
* Automated notifications for milestone achievements
* Stage-gate requirements and checklists

**Automation & Workflows (examples - custom automation & workflows will be built based on the requirements of Leonardo Canada inc.)**

* Email notifications for opportunity updates
* Task assignment based on opportunity stage
* Automated follow-up reminders
* Integration with Outlook for seamless communication

**Implementation of Import Process from JIRA as well as export process to faciliate synergy in budget reporting**

**Assistance with Power BI reporting plugin for Dynamics 365 Sales**

### Security & Compliance Configuration

**Security Roles & Access Controls (OOB security roles to be leveraged but also tailored to meet the meet the requirements of Leonardo Canada inc.)**

* Sales Manager role (full CRUD on all entities)
* Sales Representative role (limited to owned records)
* Sales Operations role (read-only reporting access)
* Executive Dashboard role (view-only KPI access)
* Field-level security for sensitive information (contract values, clearance data)

**Microsoft Purview Integration (application of sensitivity labelling in Dynamics 365 / Power Platform - inherited from Leonardo Canada Inc.'s existing purview configurations)**

* Sensitivity label application to Dataverse records
* DLP policies for Controlled Goods information
* Audit logging for all create, read, update, delete operations
* Data retention policies aligned to CGP requirements

**Customer Managed Keys (CMK)**

* Azure Key Vault provisioning for encryption keys
* CMK application to Dataverse environment
* Key rotation schedule documentation
* Disaster recovery and key backup procedures

### Reporting & Dashboards

**Sales Leadership Dashboard (examples - custom dashboards will be built based on the requirements of Leonardo Canada inc.)**

* Pipeline value by stage
* Win rate trends and forecasting accuracy
* Sales velocity metrics
* Team performance comparison

**Sales Representative Views (examples - custom views will be built based on the requirements of Leonardo Canada inc.)**

* My Active Opportunities
* Overdue Activities
* Recent Customer Interactions
* This Month's Closures

**Custom Reports (TBD - examples). Custom reports will be built based on the requirements of Leonardo Canada inc.**

* Opportunities by Product Line
* Pipeline Analysis
* Competitor Win/Loss Analysis
* Monthly Sales Performance Summary

---

## 📚 Documentation Deliverables

### Administrator Documentation (Solution design document & buildbook)

* Environment configuration guide
* Security role and access control matrix
* CMK management procedures
* Backup and disaster recovery procedures
* Customization change log
* Integration architecture diagram

### User Documentation

* Dynamics 365 Sales user guide (customized for Leonardo Company workflows)
* Quick reference cards for common tasks

### Knowledge Transfer Sessions

* 2-hour end-user training
* 1-hour IT administrator training
* Recorded session for future reference

---

## 🔄 Post-Implementation Support (30 Days)

Following production deployment, Cloudstrucc will provide 30 days of post-implementation support including:

* Issue resolution and troubleshooting
* User question response (email/Teams)
* Minor configuration adjustments
* Performance optimization recommendations
* Usage monitoring and adoption tracking

**Support Hours:** Business hours (9:00 AM - 5:00 PM EST, Monday-Friday)
**Response Time:** 4-hour initial response for critical issues, 24-hour for non-critical

---

## ✅ Success Criteria

The implementation will be considered successful upon achievement of the following criteria:

* ✅ Dynamics 365 Sales production environment deployed and accessible
* ✅ Customer Managed Keys applied and validated
* ✅ All core entities configured with custom fields and business rules
* ✅ Security roles assigned and validated by user role
* ✅ Business process flows operational for opportunity management
* ✅ Microsoft 365 integration functional (Teams, Outlook, SharePoint)
* ✅ Purview sensitivity labels and DLP policies applied
* ✅ Audit logging enabled and retention policies configured
* ✅ Sales dashboards and reports accessible to appropriate users
* ✅ Administrator and user documentation delivered
* ✅ Knowledge transfer sessions completed
* ✅ User acceptance testing signed off by Leonardo Company stakeholders

---

## 📄 Appendices

### Appendix A: Dynamics 365 Sales Core Features

**Lead Management**

* Web-to-lead capture forms
* Lead qualification scoring
* Automated lead distribution
* Lead nurturing campaigns

**Opportunity Management**

* Multi-stage opportunity tracking
* Product and price list configuration
* Quote generation and e-signature integration
* Forecasting and pipeline analytics

**Customer Insights**

* 360-degree customer view
* Interaction timeline
* Document and email tracking
* Activity relationship mapping

**Mobile Capabilities**

* iOS and Android native apps
* Offline access to critical data
* Mobile-optimized forms and views
* Push notifications for key events

### Appendix B: Integration Capabilities

**Microsoft 365 Integration**

* **Outlook:** Email tracking, appointment sync, contact sync
* **Teams:** Embedded D365 app, collaboration on opportunities
* **SharePoint:** Document library integration, contract storage
* **Power BI:** Advanced analytics and custom reporting

**Future Integration Opportunities**

* Marketing automation (Dynamics 365 Marketing)
* Customer service integration (Dynamics 365 Customer Service)
* Field service management (Dynamics 365 Field Service)
* Finance and operations integration (Dynamics 365 Finance)

### Appendix C: Compliance & Security References

* [Government of Canada ITSG-33](https://www.cse-cst.gc.ca/en/itsg-33)
* [Controlled Goods Program (CGP)](https://www.tpsgc-pwgsc.gc.ca/pmc-cgp/index-eng.html)
* [ISO/IEC 27001](https://www.iso.org/isoiec-27001-information-security.html)
* [Microsoft Purview Compliance](https://purview.microsoft.com/)
* [Dynamics 365 Security Documentation](https://learn.microsoft.com/en-us/power-platform/admin/security/)
* [Customer Managed Keys for Dataverse](https://learn.microsoft.com/en-us/power-platform/admin/customer-managed-key)

### Appendix D: Assumptions & Exclusions

**Assumptions**

* Leonardo Company has active Microsoft 365 tenant with appropriate licensing - DONE
* Azure subscription available for Key Vault provisioning (CMK) - DONE
* Stakeholders available for requirements gathering and UAT
* Single production environment (additional environments to be provisioned for development and testing)
* Standard sales process (configuration may require additional budget however the scope of this contract should cover the entirety of the implementation. If the scope is updated, the proejct sponsor can choose to amend the quote or leverage the 30 days support period)

**Exclusions**

* Data migration from legacy CRM systems (can be quoted separately)
* Custom connector development for third-party systems
* Dynamics 365 Marketing implementation
* Advanced AI/ML model configuration
* Ongoing managed services beyond 30-day support period
* End-user training beyond the 3 scheduled sessions

---

### Contact Information

**Cloudstrucc Inc.**
Email: <fpearson@cloudstrucc.com>
Phone: (613) 220-2958

**Project Lead:** [To Be Assigned by Leonardo Canada inc.]
**Technical Lead:** Frederick Pearson

---

![bg right:50%](./image/cloudstrucc_sig_transbg.png)
