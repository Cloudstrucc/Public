---
marp: true
paginate: true
theme: default
size: 16:9
---
![](./image/cloudstrucc_word_template.png)

# Proposal: Azure DevOps Security Implementation Quote

## For Leonardo Company - Canada

### Prepared by Cloudstrucc Inc

---

# Executive Summary

This quote outlines the scope and investment required to secure Azure DevOps for Leonardo Company Canada Inc. As a defense contractor with subsidiaries across multiple jurisdictions—including Leonardo Italy and Leonardo UK—the organization requires a robust DevSecOps security framework that enables secure collaboration between developers working across international boundaries while protecting sensitive intellectual property and controlled goods.

Currently, development teams in Canada, Italy, and the United Kingdom share code and artifacts through various mechanisms including file share services and manual transfer methods. Leonardo Canada seeks to modernize this approach by adopting a structured Software Development Lifecycle (SDLC) and Application Lifecycle Management (ALM) methodology using Azure DevOps and Git-based source control. As code begins flowing through centralized repositories across national borders, a Zero Trust security architecture becomes essential—one that enforces strong identity controls, leverages managed identities for service authentication, and provides comprehensive audit capabilities. This security hardening initiative will establish the governance framework necessary to enable this transition: implementing managed identities and workload identity federation for secure authentication, configuring branch protection policies for controlled Git collaboration, deploying pipeline security controls for CI/CD processes, and enabling monitoring capabilities that provide visibility into cross-border development activities. Additionally, this engagement includes integration with a first-party project management tool such as Microsoft Planner to connect SDLC workflows with day-to-day project tracking, along with agile process design and staff training to ensure Leonardo teams can effectively adopt the new ALM methodology—all while protecting Leonardo's security interests and supporting productive international teamwork.

---

## 1. Business Context

### 1.1 Background

Leonardo Company Canada currently relies on file share services and other ad-hoc mechanisms to exchange code and development artifacts with sister companies Leonardo Italy and Leonardo UK. They also leverage JIRA for SLDC and other tools (desktop/web based). To improve development efficiency, traceability, and security posture, Leonardo Canada is adopting Azure DevOps as its central DevOps / DevSecOps platform, enabling a structured SDLC/ALM approach across the organization. This modernization initiative will establish:

- Centralized Git repositories replacing fragmented file-sharing methods for cross-border code collaboration
- CI/CD pipelines introducing automated, secure build and deployment processes for defense-related code
- Artifact management providing controlled versioning and distribution of software components
- Work item tracking enabling visibility and coordination across international development teams
- Project management integration connecting SDLC activities to organizational planning tools such as Microsoft Planner

### 1.2 Business Drivers

| Driver                         | Description                                                                                                                |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| International Collaboration    | Transition from file shares to secure, Git-based development workflows between Canada, Italy, and UK teams (if applicable) |
| Zero Trust Architecture        | Eliminate implicit trust inherent in file-sharing; verify every access request regardless of origin                        |
| Data Sovereignty               | Protect data flowing to and from Canada with appropriate controls as code moves to centralized repositories                |
| Managed Identity Adoption      | Remove stored credentials; use managed identities for all service authentication                                           |
| Supply Chain Security          | Protect against software supply chain attacks across the distributed development model                                     |
| Audit Readiness                | Maintain comprehensive audit trails for cross-border compliance reviews                                                    |
| Project Management Integration | Connect SDLC workflows to project planning tools for end-to-end visibility across development and delivery                 |

### 1.3 Stakeholders

| Stakeholder                                      | Role       | Interest                              |
| ------------------------------------------------ | ---------- | ------------------------------------- |
| Leonardo Canada Development Teams                | End Users  | Secure collaboration workflows        |
| Leonardo Italy Development Teams (if applicable) | End Users  | Cross-tenant repository access        |
| Leonardo UK Development Teams (if applicable)    | End Users  | Cross-tenant repository access        |
| IT Security (All Regions)                        | Oversight  | Policy enforcement, risk assessment   |
| Compliance Office                                | Governance | Regulatory adherence, export controls |

---

## 2. Security Requirements

### 2.1 Zero Trust Identity and Access Management

| Req ID  | Requirement                                                                       | Priority | Rationale                                   |
| ------- | --------------------------------------------------------------------------------- | -------- | ------------------------------------------- |
| IAM-001 | All Azure DevOps access must use Microsoft Entra ID authentication                | Critical | Centralized identity for all regions        |
| IAM-002 | Multi-factor authentication (MFA) must be enforced for all users                  | Critical | Defense-in-depth for international access   |
| IAM-003 | Conditional Access policies must enforce device compliance and location context   | Critical | Zero Trust access verification              |
| IAM-004 | Managed identities must be used for all service-to-service authentication         | Critical | Eliminate stored credentials                |
| IAM-005 | Workload identity federation must replace service principal secrets               | Critical | Secure cross-tenant pipeline authentication |
| IAM-006 | Cross-tenant access policies must explicitly define allowed Leonardo subsidiaries | Critical | Control inter-company collaboration         |
| IAM-007 | Personal Access Tokens (PATs) must have maximum 90-day expiration                 | High     | Reduce credential exposure window           |
| IAM-008 | Guest access from non-Leonardo tenants must be prohibited                         | Critical | Prevent unauthorized external access        |

### 2.2 Git Repository Security

| Req ID  | Requirement                                                                      | Priority | Rationale                                 |
| ------- | -------------------------------------------------------------------------------- | -------- | ----------------------------------------- |
| GIT-001 | Branch policies must enforce pull request reviews for all shared repositories    | Critical | Code review before merge                  |
| GIT-002 | Production branches must require minimum 2 reviewers from appropriate regions    | Critical | Separation of duties across teams         |
| GIT-003 | Secret scanning must be enabled on all repositories                              | Critical | Prevent credential leakage across borders |
| GIT-004 | Push protection must block commits containing secrets                            | Critical | Real-time secret detection                |
| GIT-005 | Fork policies must restrict forking to within Leonardo organization              | High     | Prevent code exfiltration                 |
| GIT-006 | Commit signing must be enforced for production branches                          | High     | Code integrity and non-repudiation        |
| GIT-007 | Repository permissions must follow least privilege across all contributing teams | Critical | Minimize access scope                     |

### 2.3 Pipeline and Build Security

| Req ID   | Requirement                                                            | Priority | Rationale                                 |
| -------- | ---------------------------------------------------------------------- | -------- | ----------------------------------------- |
| PIPE-001 | YAML pipelines must be used exclusively (Classic pipelines deprecated) | High     | Pipeline-as-code, version controlled      |
| PIPE-002 | Pipeline approval gates must be implemented for production deployments | Critical | Change control for releases               |
| PIPE-003 | Service connections must use workload identity federation              | Critical | No stored secrets for cross-tenant access |
| PIPE-004 | Variable groups containing secrets must integrate with Azure Key Vault | Critical | Centralized secret management             |
| PIPE-005 | Self-hosted agents must be isolated and hardened                       | High     | Secure build infrastructure               |
| PIPE-006 | Pipeline templates must enforce security scanning stages               | High     | Consistent security controls              |
| PIPE-007 | Marketplace extensions must be reviewed and approved before use        | High     | Supply chain security                     |

### 2.4 Cross-Border Data Protection

| Req ID   | Requirement                                                                | Priority | Rationale                                   |
| -------- | -------------------------------------------------------------------------- | -------- | ------------------------------------------- |
| DATA-001 | Audit logging must capture all cross-tenant access and activities          | Critical | Visibility into international collaboration |
| DATA-002 | Data residency for Canadian projects must remain in Canadian Azure regions | Critical | Data sovereignty compliance                 |
| DATA-003 | Encryption in transit must use TLS 1.2+ for all Git operations             | Critical | Protect data crossing borders               |
| DATA-004 | Artifact feeds must be private with explicit cross-tenant access grants    | High     | Control package distribution                |

### 2.5 Compliance and Audit

| Req ID  | Requirement                                                             | Priority | Rationale                 |
| ------- | ----------------------------------------------------------------------- | -------- | ------------------------- |
| AUD-001 | Audit logs must be retained for minimum 7 years                         | Critical | Regulatory compliance     |
| AUD-002 | Security alerts must integrate with SOC tooling                         | High     | Incident response         |
| AUD-003 | Access reviews must be conducted quarterly for cross-tenant permissions | High     | Continuous compliance     |
| AUD-004 | Compliance reports must document cross-border data flows                | Critical | Export control compliance |

---

## 3. Zero Trust Security Framework

### 3.1 Managed Identity Strategy

Eliminating stored credentials is essential when development activities span multiple countries. The following managed identity approach ensures secure authentication without credential exposure:

| Authentication Scenario      | Solution                              |
| ---------------------------- | ------------------------------------- |
| Pipeline to Azure Resources  | System-assigned managed identity      |
| Cross-tenant Pipeline Access | Workload identity federation          |
| Service Connections          | Managed identity with RBAC            |
| Agent Authentication         | Managed identity on VM/container      |
| Key Vault Access             | Managed identity with access policies |

### 3.2 Cross-Tenant Collaboration Model

**Allowed Leonardo Tenants:**

| Tenant         | Direction     | Use Case                        |
| -------------- | ------------- | ------------------------------- |
| Leonardo Italy | Bidirectional | Shared repository collaboration |
| Leonardo UK    | Bidirectional | Shared repository collaboration |
| All Others     | Blocked       | No external collaboration       |

**Zero Trust Controls for Cross-Tenant Access:**

- Explicit tenant allowlisting via Cross-Tenant Access Policies
- Conditional Access requiring compliant devices from partner tenants
- MFA enforcement for all cross-tenant authentication
- Session controls limiting token lifetime
- Continuous access evaluation for real-time policy enforcement

### 3.3 ITSG-33 Alignment

| ITSG-33 Control                        | Azure DevOps Implementation             |
| -------------------------------------- | --------------------------------------- |
| AC-2 Account Management                | Entra ID integration, access reviews    |
| AC-3 Access Enforcement                | RBAC, repository permissions            |
| AC-4 Information Flow                  | Cross-tenant policies, data residency   |
| AC-6 Least Privilege                   | Managed identities, minimal permissions |
| AU-2 Audit Events                      | Audit streaming, activity logs          |
| IA-2 Identification and Authentication | MFA, Conditional Access                 |
| IA-8 Identification (Non-Org Users)    | Cross-tenant access policies            |
| SC-7 Boundary Protection               | Network restrictions, private endpoints |
| SC-8 Transmission Confidentiality      | TLS encryption                          |

---

## 4. Project Plan

### 4.1 Timeline Overview

**Target Completion:** March 31, 2026

```
Phase 1: Assessment & Planning           Dec 16 - Dec 27
Phase 2: Zero Trust Identity             Jan 6 - Jan 24
Phase 3: Cross-Tenant Configuration      Jan 27 - Feb 7
Phase 4: Git Repository Security         Feb 10 - Feb 21
Phase 5: Pipeline Security               Feb 24 - Mar 7
Phase 6: Integration Services            Mar 3 - Mar 21
Phase 7: Monitoring & Compliance         Mar 10 - Mar 21
Phase 8: Documentation & Handover        Mar 24 - Mar 31
```

### 4.2 Detailed Work Breakdown

#### Phase 1: Assessment & Planning (Dec 16 - Dec 27)

| Task                          | Deliverable                  |
| ----------------------------- | ---------------------------- |
| Current state assessment      | Security assessment report   |
| Cross-tenant access inventory | Collaboration mapping        |
| Gap analysis                  | Gap analysis document        |
| Remediation planning          | Approved implementation plan |

#### Phase 2: Zero Trust Identity Configuration (Jan 6 - Jan 24)

| Task                                              | Deliverable                     |
| ------------------------------------------------- | ------------------------------- |
| Configure Entra ID-only authentication            | Configuration documentation     |
| Implement Conditional Access policies             | CA policy set                   |
| Deploy managed identities for service connections | Managed identity configurations |
| Configure workload identity federation            | Federation trust relationships  |
| PAT policy enforcement                            | Token governance                |

#### Phase 3: Cross-Tenant Configuration (Jan 27 - Feb 7)

| Task                                                | Deliverable                 |
| --------------------------------------------------- | --------------------------- |
| Cross-tenant access policy design                   | Policy framework            |
| Leonardo Italy tenant configuration (if applicable) | Italy collaboration enabled |
| Leonardo UK tenant configuration (if applicable)    | UK collaboration enabled    |
| Cross-tenant Conditional Access                     | Partner tenant controls     |
| Testing and validation                              | Test results                |

#### Phase 4: Git Repository Security (Feb 10 - Feb 21)

| Task                          | Deliverable              |
| ----------------------------- | ------------------------ |
| Branch policy implementation  | Branch policies deployed |
| Secret scanning enablement    | Scanning active          |
| Push protection configuration | Protection rules         |
| Repository permission review  | Least privilege applied  |
| Commit signing policy         | Signing requirements     |

#### Phase 5: Pipeline Security (Feb 24 - Mar 7)

| Task                                 | Deliverable             |
| ------------------------------------ | ----------------------- |
| Secure pipeline template development | Template library        |
| Environment approval workflows       | Approval gates          |
| Key Vault integration                | Secret management       |
| Extension governance                 | Approved extension list |

#### Phase 6: Integration Services (Mar 3 - Mar 21)

| Task                                                                   | Deliverable                                                                                 |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| MS Planner (or similar) first-party integration with Azure DevOps SDLC | Configured integration between project management tool and DevOps work items                |
| Agile process design and integration with project management tool      | Documented agile workflows, board configurations, and process mappings                      |
| SDLC/ALM training for Leonardo staff                                   | Training sessions delivered covering agile methodology, DevOps workflows, and PM tool usage |

#### Phase 7: Monitoring & Compliance (Mar 10 - Mar 21)

| Task                                  | Deliverable               |
| ------------------------------------- | ------------------------- |
| Audit streaming configuration         | Log Analytics integration |
| Security monitoring dashboard         | Azure Workbook            |
| Alert rules for cross-tenant activity | Alert policies            |
| Compliance reporting                  | Report templates          |

#### Phase 8: Documentation & Handover (Mar 24 - Mar 31)

| Task                        | Deliverable          |
| --------------------------- | -------------------- |
| Build book finalization     | Complete build book  |
| SOP documentation           | Operating procedures |
| Knowledge transfer sessions | Training delivered   |
| Project closeout            | Final acceptance     |

### 4.3 Milestones

| Milestone                      | Target Date       | Success Criteria                                           |
| ------------------------------ | ----------------- | ---------------------------------------------------------- |
| M1: Assessment Complete        | December 27, 2025 | Approved implementation plan                               |
| M2: Zero Trust Identity Active | January 24, 2026  | Managed identities deployed                                |
| M3: Cross-Tenant Configured    | February 7, 2026  | Italy/UK collaboration enabled                             |
| M4: Repositories Secured       | February 21, 2026 | Branch policies active                                     |
| M5: Pipelines Hardened         | March 7, 2026     | Secure templates deployed                                  |
| M6: PM Integration Complete    | March 21, 2026    | Planner integrated, agile processes defined, staff trained |
| M7: Monitoring Operational     | March 21, 2026    | Dashboards live                                            |
| M8: Project Complete           | March 31, 2026    | Documentation delivered                                    |

---

## 5. Investment Summary

### 5.1 Professional Services

| Resource                          | Description                                                                                                                     |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Frederick Pearson, Lead Architect | Security architecture, Zero Trust design, managed identity implementation, cross-tenant configuration, and technical leadership |
| Support Engineer                  | Implementation support, testing, documentation, and knowledge transfer                                                          |

**Professional Services Total: $22,500**

### 5.2 Infrastructure and Licensing

| Item                        | Description                                                   | Cost        |
| --------------------------- | ------------------------------------------------------------- | ----------- |
| Implementation              | Initial setup, configuration, and deployment activities       | $1,000      |
| Azure DevOps Licensing      | Client responsibility - existing or new licenses              | Client Cost |
| Azure Log Analytics         | Client responsibility - ingestion and retention               | Client Cost |
| Azure Key Vault             | Client responsibility - Premium tier for managed identities   | Client Cost |
| Microsoft Entra ID P2       | Client responsibility - Conditional Access, PIM               | Client Cost |
| MS Planner (or PM tool TBD) | Client responsibility - Microsoft 365 or standalone licensing | Client Cost |

**Infrastructure Total (Cloudstrucc): $1,000**

### 5.3 Training and Knowledge Transfer

| Item                        | Description                                                                                                | Cost   |
| --------------------------- | ---------------------------------------------------------------------------------------------------------- | ------ |
| Knowledge Transfer Sessions | Two half-day sessions covering security controls, managed identity operations, and cross-tenant management | $2,500 |
| Documentation Package       | Build book, SOPs, runbooks, and quick reference guides                                                     | $1,000 |

**Training Total: $3,500**

### 5.4 Integration Services

| Item                                                      | Description                                                                                                                                                                                                               | Cost   |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| MS Planner (or similar) First-Party Integration with SDLC | Configuration and integration of Microsoft Planner or equivalent project management tool with Azure DevOps work items, boards, and SDLC workflows to provide end-to-end visibility from project planning through delivery | $5,000 |
| Design of Agile Process & Integration with PM Tool        | Design of agile development processes including sprint planning, backlog management, and workflow mappings between Azure DevOps and the project management tool                                                           | $2,000 |
| SDLC/ALM Training for Leonardo Staff                      | Hands-on training sessions for Leonardo development and project management staff covering agile methodology, Azure DevOps SDLC workflows, Git collaboration practices, and project management tool usage                  | $2,500 |

**Integration Services Total: $9,500**

### 5.5 Quote Summary

| Category                      | Cost (CAD)        |
| ----------------------------- | ----------------- |
| Professional Services         | $22,500           |
| Infrastructure (Cloudstrucc)  | $1,000            |
| Training & Knowledge Transfer | $3,500            |
| Integration Services          | $9,500            |
| **Subtotal**            | **$36,500** |
| HST (13%)                     | $4,745            |
| **Total Investment**    | **$41,245** |

---

## 6. Post-Implementation Support

Cloudstrucc Inc. offers ongoing support options following project completion:

### 6.1 Support Rates

| Resource                          | Hourly Rate (CAD) |
| --------------------------------- | ----------------- |
| Frederick Pearson, Lead Architect | $125/hour         |
| Support Engineer                  | $90/hour          |

### 6.2 Support Services Available

- Security configuration adjustments
- New managed identity deployments
- Cross-tenant access modifications
- Incident response assistance
- Quarterly access reviews
- Compliance audit support
- Pipeline security enhancements
- Project management tool configuration updates
- Agile process refinement and coaching

Support engagements are available on an as-needed basis with a minimum 2-hour engagement.

---

## 7. Risk Considerations

| Risk                                      | Likelihood | Impact | Mitigation                                       |
| ----------------------------------------- | ---------- | ------ | ------------------------------------------------ |
| Cross-tenant configuration complexity     | Medium     | High   | Phased rollout, thorough testing                 |
| Resistance to managed identity adoption   | Medium     | Medium | Clear documentation, training                    |
| Pipeline disruption during migration      | Medium     | High   | Non-production testing, rollback plans           |
| Coordination across Leonardo subsidiaries | Medium     | Medium | Early stakeholder engagement                     |
| Timeline dependencies on partner tenants  | Medium     | Medium | Parallel workstreams where possible              |
| PM tool selection delays integration work | Low        | Medium | Early decision on tooling; MS Planner as default |

---

## 8. Assumptions and Dependencies

### 8.1 Assumptions

- Leonardo Canada has Azure DevOps Organization Administrator access
- Leonardo Italy and UK subsidiaries will participate in cross-tenant configuration
- Microsoft Entra ID P2 licensing is available or will be procured
- Azure subscription is available for Log Analytics and Key Vault
- Client will provide timely access and approvals
- Microsoft Planner (or equivalent PM tool) licensing is available or will be procured by the client

### 8.2 Dependencies

- Cross-tenant access requires coordination with Leonardo Italy and UK IT teams (if applicable)
- Conditional Access policies may require Entra ID P2 activation
- Managed identity deployment requires Azure resource permissions
- Selection of project management tool (MS Planner or alternative) to be confirmed by Leonardo Canada prior to integration phase

---

![bg right:50%](./image/cloudstrucc_sig_transbg.png)
