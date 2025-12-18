# 🛍️ Executive Summary

Leonardo Company Canada, as a defence contractor operating under stringent **Controlled Goods Program (CGP)** requirements and serving both Government of Canada and NATO partners, requires a secure, compliant, and scalable DevSecOps platform that enables:

* Secure application lifecycle management across multiple security boundaries
* Cross-tenant collaboration with government partners and Leonardo Company global entities
* Automated security scanning and compliance validation
* Secure secrets management and infrastructure as code
* Audit trails and attestation for  **ITSG-33** ,  **ISO/IEC 27001** ,  **NIST 800-171** , and **NATO Security Standards**

This proposal outlines how Cloudstrucc will implement a **comprehensive DevSecOps environment using Azure DevOps** that integrates security at every stage of the software development lifecycle while enabling secure cross-tenant collaboration for multi-party defence projects.

The solution will provide:

* **Secure Azure DevOps organization** configured for Protected B workloads
* **Automated CI/CD pipelines** with integrated security gates
* **Cross-tenant access policies** for secure collaboration with external Leonardo entities and government partners
* **Infrastructure as Code (IaC)** with automated compliance scanning
* **Secrets management** using Azure Key Vault with Customer Managed Keys
* **Security scanning integration** (SAST, DAST, SCA, container scanning)
* **Compliance automation** with policy-as-code enforcement
* **Comprehensive audit logging** and security monitoring

The end state will position Leonardo Company Canada with a modern, secure DevSecOps platform that accelerates software delivery while maintaining rigorous security controls required for defence sector operations.

---

## 🔐 Scope of Work

* ✅ Provision and configure secure Azure DevOps organization
* ✅ Implement Azure Active Directory (Entra ID) integration with conditional access
* ✅ Configure cross-tenant B2B collaboration policies for external partners
* ✅ Setup Azure DevOps projects with security-first templates
* ✅ Implement branching strategy and protected branch policies
* ✅ Configure CI/CD pipelines with security gates and approvals
* ✅ Integrate Static Application Security Testing (SAST) tools
* ✅ Integrate Dynamic Application Security Testing (DAST) tools
* ✅ Implement Software Composition Analysis (SCA) for dependency scanning
* ✅ Configure container image scanning and vulnerability assessment
* ✅ Implement Infrastructure as Code (IaC) scanning (Bicep, ARM, Terraform)
* ✅ Setup Azure Key Vault for secrets management with CMK
* ✅ Configure service connections with workload identity federation
* ✅ Implement Azure Policy integration for compliance automation
* ✅ Setup Microsoft Defender for DevOps integration
* ✅ Configure audit logging to Azure Monitor and Log Analytics
* ✅ Implement artifact signing and provenance tracking
* ✅ Setup secure package feeds (Azure Artifacts) with malware scanning
* ✅ Configure build agents (self-hosted and Microsoft-hosted)
* ✅ Implement role-based access control (RBAC) and security groups
* ✅ Create security dashboard and compliance reporting
* ✅ Deliver comprehensive documentation and training
* ✅ 60-day post-implementation support period

---

## 🧰 Pre-Requisites and Deployment Approach

To perform the activities outlined in this proposal, the following pre-requisites and operating model must be established:

### 🔑 Access and Privileged Roles

Cloudstrucc will require:

* A dedicated **service account** (e.g., `devops-admin@leonardocompany.com`) or membership in privileged role groups within Microsoft Entra ID and Azure.
* The following roles or equivalent custom RBAC assignments:
  * **Azure DevOps Organization Administrator**
  * **Global Reader** (Entra ID, for assessments)
  * **Security Administrator** (for conditional access and B2B policies)
  * **Application Administrator** (for service principal configuration)
  * **Azure Subscription Contributor** (for Key Vault, Log Analytics, Defender provisioning)
  * **Azure Policy Contributor** (for compliance policy configuration)
  * **Key Vault Administrator** (for CMK and secrets management)

Access must be granted by the Leonardo Company Entra and Azure administrators prior to work commencing.

### 🏗️ Implementation Model

To support structured, low-risk implementation:

* Cloudstrucc will establish a **pilot Azure DevOps project** within Leonardo Company's organization for initial configuration, security validation, and pipeline templating.
* Once validated:
  * Configuration will be templatized using  **YAML pipelines** ,  **ARM/Bicep templates** , and **Terraform modules** for reproducibility.
  * Security policies and compliance controls will be documented in version-controlled policy-as-code.
  * A **production rollout plan** will be executed in collaboration with Leonardo Company IT and development teams.
  * Templates and documentation will enable future project onboarding with consistent security posture.

**This model ensures:**

* Proven security configuration before broad adoption
* Reproducible security patterns across all projects
* Developer enablement without compromising security
* Clear audit trail for compliance validation

This is reflected in the project schedule.

---

## ⏳ Duration and Phasing

### Project Duration: **60 Calendar Days**

| Phase   | Duration | Milestone                                     | Outcome                                            |
| ------- | -------- | --------------------------------------------- | -------------------------------------------------- |
| Phase 1 | Week 1-2 | Discovery, Requirements & Architecture Design | Security requirements documented, architecture     |
| Phase 2 | Week 2-3 | Azure DevOps Organization & Access Setup      | Organization configured, cross-tenant access       |
| Phase 3 | Week 3-5 | Security Tooling Integration                  | SAST, DAST, SCA, container scanning integrated     |
| Phase 4 | Week 5-7 | CI/CD Pipeline Templates & IaC Configuration  | Secure pipeline templates, IaC scanning            |
| Phase 5 | Week 7-8 | Secrets Management & Compliance Automation    | Key Vault CMK, Policy-as-Code, Defender for DevOps |
| Phase 6 | Week 8-9 | Testing, Documentation & Knowledge Transfer   | Security validation, training delivered            |
| Final   | Day 60   | Production Handover & Support Begins          | All systems operational, 60-day support active     |

---

## 💸 Implementation Cost Estimate (CAD)

*Starting from the week of  **March 3, 2025** , estimated due dates are projected based on a 60-day delivery schedule.*

| Item                                            | Description                                                | Estimated Cost (CAD)  | Estimated Due Date |
| ----------------------------------------------- | ---------------------------------------------------------- | --------------------- | ------------------ |
| Discovery, Requirements & Architecture Design   | Security assessment, architecture documentation            | $2,500                | March 14, 2025     |
| Azure DevOps Organization Configuration         | Organization setup, Entra ID integration, RBAC             | $2,000                | March 21, 2025     |
| Cross-Tenant Access & B2B Collaboration Setup   | External collaboration policies, MFA, conditional access   | $3,000                | March 28, 2025     |
| Security Scanning Integration - SAST/DAST/SCA   | Code scanning, dependency checks, vulnerability assessment | $3,500                | April 11, 2025     |
| Container Security & Image Scanning             | Container registry, Trivy/Defender integration, signing    | $2,000                | April 11, 2025     |
| CI/CD Pipeline Templates & Security Gates       | YAML pipelines, approval gates, branch policies            | $3,000                | April 18, 2025     |
| Infrastructure as Code (IaC) Security           | Bicep/Terraform scanning, policy validation, templates     | $2,000                | April 25, 2025     |
| Secrets Management & Azure Key Vault CMK        | Key Vault setup, CMK encryption, service connections       | $2,500                | April 25, 2025     |
| Compliance Automation & Policy-as-Code          | Azure Policy integration, compliance dashboards            | $1,800                | May 2, 2025        |
| Microsoft Defender for DevOps Integration       | Defender setup, security recommendations, alerts           | $1,200                | May 2, 2025        |
| Audit Logging, Monitoring & Security Dashboards | Log Analytics, Azure Monitor, security metrics             | $1,500                | May 9, 2025        |
| Documentation, Training & Knowledge Transfer    | Admin guides, developer onboarding, live training          | $2,000                | May 16, 2025       |
| Support (60 days)                               | Post-implementation support, optimization, questions       | $3,000                | May 30, 2025       |
| **Subtotal**                              |                                                            | **$25,000 CAD** |                    |
| HST (13%)                                       |                                                            | **$3,250 CAD**  |                    |
| **Total with HST**                        |                                                            | **$28,250 CAD** |                    |

**Payment Terms**
The total amount indicated in this proposal, including applicable taxes, shall become payable upon completion of the scope of work as outlined herein. Final payment shall be due within thirty (30) days of the client's written confirmation of acceptance and sign-off of the completed deliverables. For greater certainty, such acceptance shall not be unreasonably withheld. This agreement shall be governed by the laws of the Province of Ontario and the federal laws of Canada applicable therein.

> *Optional extension at $125/hr support block (min. 10 hrs)*

---

## 📦 Licensing and Tooling Requirements (CAD Pricing)

To implement the described DevSecOps platform, Leonardo Company Canada will require the following licensing and tools:

### Azure DevOps Licensing (CAD)

| License Tier                      | Features Required                                     | Estimated Monthly Cost (CAD/user) |
| --------------------------------- | ----------------------------------------------------- | --------------------------------- |
| Azure DevOps Basic                | Basic pipelines, repos, boards (first 5 users free)   | $0 - $8                           |
| Azure DevOps Basic + Test Plans   | Full testing capabilities, advanced pipeline features | $67                               |
| VIsual Studio Developer Licensing | Full access to all DevOps features                    | $200                              |

### Security Tooling

| Tool/Service                        | Purpose                                   | Estimated Monthly Cost (CAD)     |
| ----------------------------------- | ----------------------------------------- | -------------------------------- |
| Microsoft Defender for DevOps       | Security posture, recommendations, alerts | Included with Azure subscription |
| GitHub Advanced Security (optional) | Alternative SAST/DAST/SCA if using GitHub | ~$64/user                        |
| SonarQube/SonarCloud (optional)     | Code quality and security scanning        | ~$13/user or self-hosted         |
| Snyk (optional)                     | Container and dependency scanning         | ~$64/developer                   |

### Azure Infrastructure

| Resource                       | Purpose                              | Estimated Monthly Cost (CAD) |
| ------------------------------ | ------------------------------------ | ---------------------------- |
| Azure Key Vault                | Secrets management, CMK              | ~$5 + transaction costs      |
| Log Analytics Workspace        | Centralized logging and monitoring   | ~$3/GB ingested              |
| Azure Container Registry       | Container image storage and scanning | ~$7/day (Standard tier)      |
| Self-hosted Build Agents (VMs) | Controlled build environment         | ~$100-300/VM                 |

### Notes

* Microsoft Defender for DevOps is included with Azure subscription and provides SAST, SCA, IaC scanning, and container scanning at no additional cost.
* For enhanced security scanning, third-party tools like SonarQube or Snyk can be integrated (optional, not included in base proposal).
* Self-hosted build agents recommended for sensitive workloads to maintain data sovereignty.
* Azure consumption costs will vary based on pipeline execution frequency and artifact storage.
* Implementation costs do not include ongoing Azure infrastructure or licensing fees.

---

## 📋 Detailed Configuration Deliverables

### Azure DevOps Organization Configuration

**Organization-Level Security**

* Entra ID integration with SSO and MFA enforcement
* Organization-wide security policies (enforce MFA, restrict public projects)
* IP allowlist configuration for restricted access
* Audit logging to Azure Monitor
* Data residency configuration (Canada region)
* Third-party application access policies (restricted)

**Cross-Tenant Collaboration**

* Azure AD B2B guest access policies for external Leonardo entities
* Conditional access policies for cross-tenant scenarios
* MFA enforcement for external users
* External user lifecycle management
* Cross-tenant group synchronization for project access
* Secure collaboration templates for multi-party projects

**Role-Based Access Control (RBAC)**

* Project Administrators (full project control)
* Build Administrators (pipeline management, security gate configuration)
* Developers (code commit, PR creation, limited pipeline execution)
* Security Reviewers (read-only security scan results, audit logs)
* External Contributors (restricted guest access with enhanced monitoring)

### Project Configuration & Templates

**Project Structure**

* Security-first project templates with pre-configured policies
* Branch protection strategies (main/develop/feature)
* Pull request policies (minimum reviewers, linked work items, build validation)
* Required reviewers for sensitive paths (IaC, security configs)
* Work item process template aligned to secure SDLC

**Repository Security**

* Branch policies with automated security checks
* Required code review workflows
* Status checks before merge (security scans pass)
* No direct commits to protected branches
* Commit signing enforcement (optional)
* Secret scanning for credential detection

### CI/CD Pipeline Security

**Pipeline Templates**

* Secure YAML pipeline templates for common scenarios:
  * .NET applications with SAST/DAST
  * Container-based applications with image scanning
  * Infrastructure as Code deployment with policy validation
  * Azure Function deployments with Key Vault integration
* Multi-stage pipelines with security gates between stages
* Approval workflows for production deployments
* Pipeline-as-code with version control

**Security Gates & Checks**

* Automated security scanning gates:
  * SAST: Microsoft Security DevOps (MSDO), optional SonarQube
  * SCA: Dependency scanning for vulnerable packages
  * DAST: Dynamic testing for runtime vulnerabilities
  * Container: Trivy/Defender container image scanning
  * IaC: Checkov, PSRule for infrastructure compliance
* Break-build on high-severity vulnerabilities
* Security approval workflows for policy violations
* Automated compliance attestation

**Build Agent Configuration**

* Microsoft-hosted agents for low-sensitivity workloads
* Self-hosted agents on isolated VMs for Protected B workloads
* Agent pools segmented by security classification
* Network isolation for build environments
* Ephemeral agent configuration for enhanced security

### Security Tooling Integration

**Static Application Security Testing (SAST)**

* Microsoft Security DevOps (MSDO) extension integration
* Code quality and security rule configuration
* Custom security rules for defence-specific requirements
* Results published to Azure DevOps security dashboard
* Integration with Defender for DevOps

**Software Composition Analysis (SCA)**

* Dependency scanning for known vulnerabilities (CVEs)
* License compliance checking
* Automated dependency update recommendations
* Transitive dependency analysis
* Component governance policies

**Container Security**

* Azure Container Registry (ACR) with Defender for Containers
* Image scanning on push and scheduled rescans
* Vulnerability assessment and remediation guidance
* Image signing with Notation/Cosign
* Base image hardening guidance

**Infrastructure as Code (IaC) Security**

* Bicep/ARM template security scanning
* Terraform plan analysis with policy validation
* Azure Policy as Code integration
* Security misconfiguration detection
* Compliance drift detection

**Dynamic Application Security Testing (DAST)**

* OWASP ZAP integration for runtime vulnerability testing
* Automated penetration testing in staging environments
* API security testing
* Authentication and authorization testing
* Results correlation with SAST findings

### Secrets Management & Key Vault Integration

**Azure Key Vault Configuration**

* Dedicated Key Vault for DevOps secrets
* Customer Managed Keys (CMK) for enhanced encryption
* RBAC for secret access (pipeline-specific service principals)
* Key rotation policies and automation
* Audit logging for all secret access operations
* Soft-delete and purge protection enabled

**Service Connections**

* Azure Resource Manager connections with workload identity federation (no secrets)
* GitHub/Git connections with SSH keys stored in Key Vault
* Container registry connections with managed identities
* External API connections with certificate-based authentication
* Automatic secret rotation workflows

**Secrets Scanning**

* Pre-commit hooks for credential detection
* Pipeline-integrated secret scanning (Microsoft Credential Scanner)
* Alerting on exposed secrets with automated rotation
* Historical repository scanning for leaked credentials

### Compliance Automation & Policy-as-Code

**Azure Policy Integration**

* Policy definitions for Azure resource compliance
* Automated compliance scanning in CI/CD pipelines
* Policy violation reporting and remediation workflows
* Initiative assignments for ITSG-33, NIST 800-171 controls
* Compliance attestation artifacts for audit purposes

**Compliance Dashboard**

* Real-time compliance posture visualization
* Security control coverage metrics
* Vulnerability aging and remediation tracking
* Policy violation trends
* Audit-ready compliance reports (PDF/Excel export)

**Artifact Provenance & Supply Chain Security**

* Build artifact signing and verification
* Software Bill of Materials (SBOM) generation
* Artifact lineage tracking (source commit to deployment)
* Tamper-evident artifact storage
* Reproducible build validation

### Audit Logging & Monitoring

**Azure Monitor Integration**

* Centralized logging to Log Analytics workspace
* Diagnostic settings for all Azure DevOps activities
* Pipeline execution logs retention (90+ days)
* Security event correlation and alerting
* Anomaly detection for suspicious activities

**Security Metrics & Dashboards**

* Pipeline security scan results aggregation
* Vulnerability density trends over time
* Mean time to remediation (MTTR) for security issues
* Security gate pass/fail rates
* External collaboration activity monitoring

**Alerting & Incident Response**

* Critical security alerts to Microsoft Teams/Email
* Failed security scans requiring immediate attention
* Unauthorized access attempts
* Pipeline failures due to security violations
* External user suspicious activity

---

## 📚 Documentation Deliverables

### Administrator Documentation

* DevSecOps architecture diagram and design decisions
* Azure DevOps organization configuration guide
* Cross-tenant access configuration and management procedures
* Security tooling configuration and maintenance guide
* Pipeline template library and customization guide
* Secrets management procedures and key rotation workflows
* RBAC matrix and access control policies
* Incident response procedures for security violations
* Disaster recovery and business continuity procedures
* Compliance mapping (ITSG-33, ISO 27001, NIST 800-171)

### Developer Documentation

* Secure coding guidelines for Leonardo Company
* DevSecOps workflow and branching strategy
* Pipeline usage guide (how to use security-enabled templates)
* Local development environment setup with security tools
* Code review checklist with security focus
* Troubleshooting guide for common security scan failures
* Best practices for secrets management
* Container security guidelines

### Runbooks & Standard Operating Procedures (SOPs)

* Onboarding new projects with security baseline
* Adding external collaborators (cross-tenant process)
* Responding to security scan failures
* Managing pipeline approvals and security gates
* Key Vault secret rotation procedures
* Incident response for credential leakage
* Quarterly security posture review process

### Knowledge Transfer Sessions

* 4-hour administrator deep-dive (IT security and DevOps teams)
* 3-hour developer onboarding (development teams)
* 2-hour executive overview (leadership and compliance officers)
* Recorded sessions for future reference and onboarding
* Q&A sessions and office hours (first 30 days)

---

## 🔄 Post-Implementation Support (60 Days)

Following production deployment, Cloudstrucc will provide 60 days of post-implementation support including:

* Security incident response and troubleshooting
* Pipeline optimization and performance tuning
* Developer question response (email/Teams/Slack)
* Security policy refinement based on feedback
* Additional pipeline template development (up to 3 templates)
* Security scan false positive tuning
* Cross-tenant collaboration troubleshooting
* Monthly security posture review meetings
* Compliance reporting assistance

**Support Hours:** Business hours (9:00 AM - 5:00 PM EST, Monday-Friday)

**Response Time:** 2-hour initial response for critical security issues, 8-hour for non-critical

---

## ✅ Success Criteria

The implementation will be considered successful upon achievement of the following criteria:

* ✅ Azure DevOps organization configured with security-first policies
* ✅ Cross-tenant access policies operational for external Leonardo entities and government partners
* ✅ Security scanning integrated (SAST, DAST, SCA, container, IaC) with automated gates
* ✅ At least 3 production pipeline templates operational with security controls
* ✅ Azure Key Vault with CMK deployed and integrated with pipelines
* ✅ Microsoft Defender for DevOps active with security recommendations visible
* ✅ Compliance automation with Azure Policy validated
* ✅ Audit logging to Azure Monitor operational with retention policies
* ✅ Security dashboards accessible to stakeholders
* ✅ Developer and administrator documentation delivered
* ✅ Knowledge transfer sessions completed
* ✅ At least one development team successfully onboarded and executing secure pipelines
* ✅ User acceptance testing signed off by Leonardo Company stakeholders

---

## 📄 Appendices

### Appendix A: Security Tooling Stack

**Microsoft Native Tools (Included)**

* Microsoft Security DevOps (MSDO)
* Microsoft Defender for DevOps
* Microsoft Defender for Containers
* Azure Policy
* Microsoft Credential Scanner
* Azure Monitor & Log Analytics

**Open Source & Third-Party Integration Options**

* **SAST:** SonarQube, Checkmarx, Fortify
* **SCA:** Snyk, WhiteSource, Mend
* **Container:** Trivy, Aqua Security, Twistlock
* **IaC:** Checkov, tfsec, PSRule, Terrascan
* **DAST:** OWASP ZAP, Burp Suite, Acunetix
* **Secrets:** GitGuardian, TruffleHog, detect-secrets

### Appendix B: Cross-Tenant Collaboration Architecture

**Supported Scenarios**

* Leonardo Company Italy ↔ Leonardo Company Canada collaboration
* Government of Canada partner access (PSPC, DND, CSE)
* NATO partner collaboration for joint defence projects
* Subcontractor/vendor limited access

**Security Controls**

* Per-tenant conditional access policies
* MFA enforcement for all external users
* Session lifetime limits for guest users
* Restricted resource access (project-level isolation)
* Enhanced monitoring and alerting for cross-tenant activities
* Regular access reviews and recertification

### Appendix C: Pipeline Security Gate Examples

**Example: .NET Application Pipeline**

```yaml
stages:
- stage: Build
  jobs:
  - job: BuildAndScan
    steps:
    - task: UseDotNet@2
    - task: DotNetCoreCLI@2
      displayName: 'Build Solution'
    - task: MicrosoftSecurityDevOps@1
      displayName: 'Run Security Scans'
    - task: PublishSecurityAnalysisLogs@3
      displayName: 'Publish Security Results'
  
- stage: SecurityReview
  dependsOn: Build
  jobs:
  - job: AwaitApproval
    pool: server
    steps:
    - task: ManualValidation@0
      condition: eq(variables['Build.Reason'], 'PullRequest')
      inputs:
        instructions: 'Review security scan results before proceeding'
    
- stage: Deploy
  dependsOn: SecurityReview
  condition: succeeded()
  jobs:
  - deployment: DeployToStaging
    environment: 'staging-environment'
```

### Appendix D: Compliance Mapping

**ITSG-33 Control Coverage**

* AC-2: Account Management (RBAC, MFA)
* AC-3: Access Enforcement (conditional access, policy gates)
* AU-2: Audit Events (comprehensive logging)
* CA-7: Continuous Monitoring (security dashboards)
* CM-3: Configuration Change Control (IaC, policy-as-code)
* IA-2: Identification and Authentication (Entra ID, MFA)
* RA-5: Vulnerability Scanning (SAST, DAST, SCA)
* SA-11: Developer Security Testing (security gates in CI/CD)
* SC-7: Boundary Protection (network isolation, private endpoints)
* SC-12: Cryptographic Key Establishment (Azure Key Vault, CMK)
* SC-28: Protection of Information at Rest (encryption)
* SI-3: Malicious Code Protection (container scanning, artifact scanning)

**NIST 800-171 Control Coverage**

* 3.1.x: Access Control
* 3.3.x: Audit and Accountability
* 3.4.x: Configuration Management
* 3.5.x: Identification and Authentication
* 3.13.x: System and Communications Protection
* 3.14.x: System and Information Integrity

### Appendix E: Assumptions & Exclusions

**Assumptions**

* Leonardo Company has active Azure subscription with appropriate licensing
* Existing Azure DevOps organization or willingness to create new organization
* Network connectivity from developer workstations to Azure DevOps
* Access to government partner Entra ID tenants for B2B collaboration
* Development teams willing to adopt security-first workflows
* Existing source code repositories available for migration

**Exclusions**

* Source code migration from legacy systems (can be quoted separately)
* Application-specific security remediation (code fixes for vulnerabilities)
* Ongoing managed services beyond 60-day support period (optional)
* Third-party security tool licensing costs (SonarQube, Snyk, etc.)
* Custom tool development or integrations beyond standard DevOps capabilities
* Penetration testing or security audits of applications
* Training beyond the scheduled knowledge transfer sessions
* Azure infrastructure costs (billed separately by Microsoft)
