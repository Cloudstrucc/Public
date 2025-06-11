# Elections Canada – Power Platform CoE Implementation Project Plan

This document outlines the remaining activities required to complete the Power Platform Center of Excellence (CoE) implementation at Elections Canada. The CoE has been provisioned in a development environment (`coe-dev`) and will later be deployed in production (`COE`). A Power Pages site will serve as the central internal web portal for agency users to request new environments, download solution templates, submit DLP exemptions, and more.

The project is divided into two phases:

* **Finalizing Development Work** in `coe-dev`
* **Executing Production Launch** in the `COE` environment

> ⚠️ *Note: ATOs and associated governance steps are outside the scope of this plan but are considered a prerequisite for publishing the agency-facing Power Pages portal.*

---

## 🛠 Development Finalization Tasks (`coe-dev`)

| Task                              | Description                                                                                                                      | Due Date | Resource |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------- | -------- |
| Configure service accounts        | Create email-enabled service accounts for both `coe-dev`and `COE`with appropriate licenses (Power Apps + Case Management)    |          |          |
| Replace Power Automate Flow owner | Configure flows to run under the CoE service account instead of the FP user account                                              |          |          |
| Install sample data               | Complete installation of sample CoE kit data in `coe-dev`                                                                      |          |          |
| Develop CoE webapp template       | Build internal-facing CSS/HTML/JS web template for Power Pages using EC branding                                                 |          |          |
| Provision Power Pages site        | Deploy Power Pages site in `coe-dev`using the developed webapp template                                                        |          |          |
| Build web pages and navigation    | Develop forms, navigation, and IP-restricted access configuration based on the CoE SharePoint example site                       |          |          |
| Select MS templates               | Decide which out-of-the-box model-driven or canvas templates will be made available in the Innovation Hub                        |          |          |
| Customize DLP/env request apps    | Add EC-specific fields and a checklist section for production environment requests (including iATO/ATO uploads)                  |          |          |
| Determine publication scope       | Finalize what content will be made available on the Power Pages site (e.g., templates, documentation, DLP, environment requests) |          |          |
| Finalize guardrail configurations | Ensure all Power Platform environments meet a 90%+ governance score                                                              |          |          |
| Define Power Pages functionality  | Implement and expose agency-facing functions: env requests, DLP, templates, docs, etc.                                           |          |          |
| QA of MVP                         | Conduct end-to-end QA testing of the MVP                                                                                         |          |          |
| Present final MVP                 | Review MVP with stakeholders before production deployment                                                                        |          |          |
| RFC/ticketing process             | Design the process for logging and managing support tickets via the CoE service desk app                                         |          |          |
| Training & KB                     | Develop training and knowledge base for requesting environments, templates, and the production readiness process                 |          |          |
| Confirm MS Flow / Power BI access | Ensure agency-wide availability of Power Automate and Power BI                                                                   |          |          |
| Disable flows pre-prod            | Turn off all flows in `coe-dev`before cloning to production                                                                    |          |          |

---

## 🚀 Production Deployment Tasks (`COE`)

| Task                            | Description                                                                                                            | Due Date | Resource |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------- | -------- |
| Clone sandbox to production     | Copy solution from `coe-dev`to `COE`(excluding sample data) and rebind all flows to the production service account |          |          |
| Configure DNS                   | Set up CNAME for internal-facing agency-wide CoE Power Pages URL                                                       |          |          |
| Run inventory and core flows    | Trigger Power Automate flows to inventory current Power Platform environment and populate CoE dashboards               |          |          |
| Set PEPP team roles             | Ensure PEPP makers are in the Maker group and other PEPP users are in the Power Platform Users group                   |          |          |
| Review flow triggers            | Preemptively review and mitigate any risky email triggers before enabling email notifications                          |          |          |
| Publicize CoE link              | Share agency-wide access to CoE via IM/IT and the RFC SharePoint app                                                   |          |          |
| Communications activities       | Launch internal comms campaign to introduce the CoE and self-serve Power Platform access                               |          |          |
| Support SA&A process            | Support any SA&A (Security Assessment & Authorization) requirements for production readiness                           |          |          |
| Power Pages search optimization | Implement fuzzy search indexing for documentation pages                                                                |          |          |
| QA of final MVP                 | Perform QA testing of the production configuration prior to public launch                                              |          |          |

# Annex – Power Platform CoE Toolkit Modules, Apps, and Flows

This annex provides a detailed breakdown of all components included in the Microsoft Power Platform Center of Excellence (CoE) Starter Kit. It includes descriptions of all apps, flows, and capabilities across the various modules, based on official Microsoft documentation.

> 📚  **Sources** :
>
> * [Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/core-components)
> * [Business Value Toolkit](https://learn.microsoft.com/en-us/power-platform/guidance/coe/business-value-toolkit)
> * [Governance Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/governance-components)
> * [Nurture Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/nurture-components)
> * [Theming Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/theming-components)
> * [Innovation Backlog Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/innovationbacklog-components)

---

## 👥 CoE Toolkit Components by Persona

### 👨‍💼 For IT Administrators / CoE Governance Team

* Admin – Command Center (Core)
* Admin – Sync Template (Core)
* Admin – Archive and Clean-Up (Core)
* Compliance Admin App (Governance)
* Developer Compliance Center (Governance)
* Environment Request App (Innovation)
* Service Desk Admin App (Support)
* Power BI Dashboards (Reporting)
* Audit Dashboard & Review Interface (Audit)

### 👩‍💻 For Makers / Business Users

* Maker Persona & Feedback App (Maker Enablement)
* Welcome Email Generator (Maker Enablement)
* Template Catalog (Nurture)
* App Catalog (Nurture)
* Video Hub (Nurture)
* Theme Editor / Gallery (Theming)
* Innovation Backlog (Submitter App)
* Power App & Flow ROI Calculator (Business Value)

---

## 📋 Quick Reference Table – Apps and Flows

| Module               | Component                                   | Type    | Purpose / Use                                       |
| -------------------- | ------------------------------------------- | ------- | --------------------------------------------------- |
| Core Components      | Admin – Command Center                     | App     | Navigation hub for CoE tools                        |
|                      | Sync Template                               | App     | Data synchronization trigger                        |
|                      | Archive and Clean-Up                        | App     | Flag and remove stale assets                        |
|                      | Sync Template – Admin                      | Flow    | Collects data from all environments                 |
|                      | Audit Logs Sync                             | Flow    | Pulls audit logs from Microsoft 365                 |
| Business Value       | ROI Calculator                              | App     | Estimate business value per app/flow                |
|                      | Org-Wide ROI Overview                       | App     | Summarizes total impact                             |
| Governance           | Developer Compliance Center                 | App     | Maker-led compliance self-attestation               |
|                      | Compliance Admin                            | App     | Admin view of compliance posture                    |
|                      | DLP Exemption                               | Flow    | Request/review exceptions                           |
| Nurture              | Template Catalog                            | App     | Share reusable templates                            |
|                      | App Catalog                                 | App     | Promote discoverable apps                           |
|                      | Video Hub                                   | App     | Share training and onboarding content               |
| Theming              | Theme Editor                                | App     | Build and export custom canvas themes               |
|                      | Theme Gallery                               | App     | Browse and reuse consistent app styles              |
| Innovation Backlog   | Innovation Backlog (Admin & Submitter)      | App     | Manage and submit innovation ideas                  |
|                      | Idea Notification / Review / Completion     | Flows   | Automate lifecycle of submitted ideas               |
| Maker Enablement     | Welcome Email Generator                     | App     | Sends intro + guidance to new makers                |
|                      | Maker Persona & Feedback                    | App     | Capture maker experience and intent                 |
| Audit and Monitoring | Audit Dashboard / Review Interface          | App     | View change logs and perform app reviews            |
|                      | Audit Log Puller / Maker Ownership Reminder | Flow    | Retrieve telemetry, flag ownership gaps             |
| Support Operations   | Service Desk Admin                          | App     | Manage incoming issues and tickets                  |
|                      | End User Ticketing Portal                   | App     | User-facing ticket entry                            |
|                      | Ticket Routing / Escalation Handler         | Flows   | Automate support case processing                    |
| Reporting            | Power BI Dashboards                         | Reports | Visualize adoption, usage, ROI, and compliance KPIs |
