# Azure DevOps Security Business Requirements Document

**Document Information**
| Field | Value |
|-------|-------|
| Organization | Leonardo Company Canada Inc. |
| Department | LCE M365 Security Team |
| Classification | Protected B |
| Version | 1.0 |
| Date | December 16, 2025 |
| Author | Power Platform Tenant Administrator |
| Target Completion | March 31, 2026 |

---

## Executive Summary

This document outlines the business requirements for securing Azure DevOps within Leonardo Company Canada Inc.'s environment. As a defense contractor specializing in electronic warfare technologies, LCC must implement security controls that meet Protected B classification requirements, align with ITSG-33 guidelines, and support NATO interoperability standards.

The security hardening initiative will address identity and access management, pipeline security, repository protection, artifact management, and audit compliance across all Azure DevOps projects and organizations.

---

## 1. Business Context

### 1.1 Background

Azure DevOps serves as the primary DevOps platform for Leonardo Company Canada, supporting:
- Power Platform solution development and deployment pipelines
- Dataverse solution promotion across environments
- Source code management for defense-related applications
- CI/CD automation for Protected B workloads

### 1.2 Business Drivers

| Driver | Description |
|--------|-------------|
| Regulatory Compliance | Meet ITSG-33, Protected B, and NATO security requirements |
| Risk Mitigation | Prevent unauthorized access to defense-related intellectual property |
| Operational Excellence | Ensure secure and reliable DevOps practices |
| Audit Readiness | Maintain comprehensive audit trails for compliance reviews |
| Supply Chain Security | Protect against software supply chain attacks |

### 1.3 Stakeholders

| Stakeholder | Role | Interest |
|-------------|------|----------|
| LCE M365 Security Team | Implementation | Security controls, monitoring, compliance |
| Development Teams | End Users | Secure development workflows |
| IT Security | Oversight | Policy enforcement, risk assessment |
| Compliance Office | Governance | Regulatory adherence verification |
| Executive Leadership | Sponsor | Risk acceptance, resource allocation |

---

## 2. Business Requirements

### 2.1 Identity and Access Management

| Req ID | Requirement | Priority | Rationale |
|--------|-------------|----------|-----------|
| IAM-001 | All Azure DevOps access must use Microsoft Entra ID authentication | Critical | Centralized identity management |
| IAM-002 | Multi-factor authentication (MFA) must be enforced for all users | Critical | Defense-in-depth for account protection |
| IAM-003 | Conditional Access policies must restrict access to compliant devices only | High | Prevent access from unmanaged endpoints |
| IAM-004 | Just-In-Time (JIT) access must be implemented for administrative roles | High | Minimize standing privileges |
| IAM-005 | Service connections must use managed identities where possible | High | Eliminate credential management overhead |
| IAM-006 | Personal Access Tokens (PATs) must have maximum 90-day expiration | Medium | Reduce risk of credential compromise |
| IAM-007 | Guest access must be disabled or strictly controlled | Critical | Prevent unauthorized external access |
| IAM-008 | Privileged Identity Management (PIM) must govern elevated access | High | Time-bound administrative access |

### 2.2 Organization and Project Security

| Req ID | Requirement | Priority | Rationale |
|--------|-------------|----------|-----------|
| ORG-001 | Organization-level security policies must be centrally managed | Critical | Consistent security posture |
| ORG-002 | Project creation must be restricted to authorized personnel | High | Prevent shadow IT |
| ORG-003 | Public projects must be prohibited | Critical | Prevent data exposure |
| ORG-004 | External collaboration settings must default to restrictive | High | Control information sharing |
| ORG-005 | Audit streaming must be enabled to Azure Monitor/Sentinel | Critical | Security monitoring and alerting |
| ORG-006 | IP allowlisting must restrict access to corporate networks | Medium | Network-level access control |

### 2.3 Repository Security

| Req ID | Requirement | Priority | Rationale |
|--------|-------------|----------|-----------|
| REPO-001 | Branch policies must enforce pull request reviews | Critical | Code quality and security review |
| REPO-002 | Main/production branches must require minimum 2 reviewers | High | Separation of duties |
| REPO-003 | Secret scanning must be enabled on all repositories | Critical | Prevent credential leakage |
| REPO-004 | Commit signing must be required for production branches | Medium | Code integrity verification |
| REPO-005 | Fork policies must restrict forking to within organization | High | Prevent code exfiltration |
| REPO-006 | Repository permissions must follow least privilege principle | Critical | Minimize access scope |

### 2.4 Pipeline Security

| Req ID | Requirement | Priority | Rationale |
|--------|-------------|----------|-----------|
| PIPE-001 | YAML pipelines must be used (Classic pipelines deprecated) | High | Pipeline-as-code, version control |
| PIPE-002 | Pipeline approval gates must be implemented for production | Critical | Change control compliance |
| PIPE-003 | Service connections must use workload identity federation | High | Eliminate stored credentials |
| PIPE-004 | Variable groups containing secrets must use Azure Key Vault | Critical | Centralized secret management |
| PIPE-005 | Pipeline templates must be used for standardization | Medium | Consistent security controls |
| PIPE-006 | Self-hosted agents must be hardened and regularly patched | High | Secure build infrastructure |
| PIPE-007 | Pipeline runs must be audited and logged | Critical | Compliance and forensics |
| PIPE-008 | Marketplace extensions must be reviewed and approved | High | Supply chain security |

### 2.5 Artifact Security

| Req ID | Requirement | Priority | Rationale |
|--------|-------------|----------|-----------|
| ART-001 | Azure Artifacts must use private feeds only | High | Prevent public package exposure |
| ART-002 | Upstream sources must be controlled and approved | High | Supply chain security |
| ART-003 | Package vulnerability scanning must be enabled | Critical | Identify vulnerable dependencies |
| ART-004 | Feed permissions must follow least privilege | Medium | Access control |

### 2.6 Compliance and Audit

| Req ID | Requirement | Priority | Rationale |
|--------|-------------|----------|-----------|
| AUD-001 | Audit logs must be retained for minimum 7 years | Critical | Regulatory compliance |
| AUD-002 | Security alerts must integrate with SOC tooling | High | Incident response |
| AUD-003 | Compliance reports must be generated monthly | Medium | Governance oversight |
| AUD-004 | Access reviews must be conducted quarterly | High | Continuous compliance |

---

## 3. Security Best Practices

### 3.1 Microsoft Recommended Security Controls

Based on Microsoft's Azure DevOps security best practices:

**Identity Security**
- Enable Microsoft Entra ID-only authentication
- Disable alternate authentication methods (Basic Auth, SSH keys for external users)
- Implement Conditional Access with device compliance requirements
- Use Privileged Identity Management for administrative access
- Configure session policies for web access

**Organization Security**
- Disable "Allow public projects"
- Set external guest access policy to "No access" or limited
- Enable audit streaming to Log Analytics
- Configure organization policies centrally
- Restrict organization owner and project collection administrator roles

**Repository Security**
- Enable branch protection policies
- Require pull request reviews before merging
- Enable status checks and build validation
- Configure secret scanning and push protection
- Implement CODEOWNERS for critical paths

**Pipeline Security**
- Use YAML pipelines exclusively
- Implement environment approvals and gates
- Use protected resources (environments, service connections)
- Configure pipeline permissions explicitly
- Enable pipeline isolation for security

### 3.2 ITSG-33 Alignment

| ITSG-33 Control | Azure DevOps Implementation |
|-----------------|----------------------------|
| AC-2 Account Management | Entra ID integration, access reviews |
| AC-3 Access Enforcement | RBAC, project permissions |
| AC-6 Least Privilege | Minimal permission assignments |
| AU-2 Audit Events | Audit streaming, activity logs |
| AU-6 Audit Review | Log Analytics queries, alerts |
| CM-3 Configuration Change Control | Branch policies, PR reviews |
| IA-2 Identification and Authentication | MFA, Conditional Access |
| SC-8 Transmission Confidentiality | TLS encryption, private endpoints |

### 3.3 Defense Contractor Specific Controls

| Control Area | Implementation |
|--------------|----------------|
| ITAR/Controlled Goods | Restrict access to Canadian/NATO cleared personnel only |
| Data Residency | Ensure Azure DevOps data remains in Canadian region |
| Classified Handling | No classified data in Azure DevOps; Protected B maximum |
| Supply Chain | Approved extensions only; review third-party dependencies |

---

## 4. Project Plan

### 4.1 Timeline Overview

**Project Duration:** December 16, 2025 – March 31, 2026 (15 weeks)

```
Phase 1: Assessment & Planning     [Week 1-3]     Dec 16 - Jan 3
Phase 2: Identity & Access         [Week 4-6]     Jan 6 - Jan 24
Phase 3: Organization Security     [Week 7-8]     Jan 27 - Feb 7
Phase 4: Repository Security       [Week 9-10]    Feb 10 - Feb 21
Phase 5: Pipeline Security         [Week 11-12]   Feb 24 - Mar 7
Phase 6: Monitoring & Compliance   [Week 13-14]   Mar 10 - Mar 21
Phase 7: Documentation & Handover  [Week 15]      Mar 24 - Mar 31
```

### 4.2 Detailed Work Breakdown

#### Phase 1: Assessment & Planning (Weeks 1-3)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Current state assessment | 5 days | Security assessment report |
| Gap analysis against requirements | 3 days | Gap analysis document |
| Risk assessment | 2 days | Risk register |
| Remediation planning | 3 days | Remediation roadmap |
| Stakeholder approval | 2 days | Approved project plan |

#### Phase 2: Identity & Access Management (Weeks 4-6)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Configure Entra ID-only authentication | 2 days | Configuration documentation |
| Implement Conditional Access policies | 3 days | CA policy set |
| Configure PIM for DevOps roles | 3 days | PIM configuration |
| PAT policy implementation | 2 days | Token policies |
| Service connection review/remediation | 3 days | Updated service connections |
| JIT access implementation | 2 days | JIT procedures |

#### Phase 3: Organization Security (Weeks 7-8)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Organization policy configuration | 3 days | Policy settings |
| External collaboration lockdown | 2 days | Guest access controls |
| Audit streaming setup | 2 days | Log Analytics integration |
| IP restriction configuration | 2 days | Network policies |
| Project creation governance | 1 day | Procedures |

#### Phase 4: Repository Security (Weeks 9-10)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Branch policy implementation | 3 days | Branch policies |
| Secret scanning enablement | 2 days | Scanning configuration |
| Repository permission review | 3 days | Updated permissions |
| Fork policy configuration | 1 day | Fork restrictions |
| CODEOWNERS implementation | 1 day | CODEOWNERS files |

#### Phase 5: Pipeline Security (Weeks 11-12)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Pipeline template development | 4 days | Secure templates |
| Environment approval configuration | 2 days | Approval workflows |
| Key Vault integration | 2 days | Secret management |
| Agent security hardening | 2 days | Hardened agents |
| Extension review/approval | 2 days | Approved extension list |

#### Phase 6: Monitoring & Compliance (Weeks 13-14)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Security monitoring dashboard | 3 days | Azure Workbook |
| Alert rules configuration | 2 days | Alert policies |
| Compliance reporting automation | 3 days | Automated reports |
| Access review procedures | 2 days | Review procedures |

#### Phase 7: Documentation & Handover (Week 15)

| Task | Duration | Deliverable |
|------|----------|-------------|
| Build book finalization | 2 days | Complete build book |
| SOP documentation | 2 days | Operating procedures |
| Training delivery | 1 day | Training materials |

### 4.3 Milestones

| Milestone | Target Date | Success Criteria |
|-----------|-------------|------------------|
| M1: Assessment Complete | January 3, 2026 | Approved remediation plan |
| M2: IAM Hardened | January 24, 2026 | All IAM controls implemented |
| M3: Organization Secured | February 7, 2026 | Org policies configured |
| M4: Repositories Protected | February 21, 2026 | Branch policies active |
| M5: Pipelines Secured | March 7, 2026 | Secure templates deployed |
| M6: Monitoring Active | March 21, 2026 | Dashboards operational |
| M7: Project Complete | March 31, 2026 | All documentation delivered |

---

## 5. Cost Estimates

### 5.1 Labor Costs

| Role | Hours | Rate (CAD) | Total |
|------|-------|------------|-------|
| Security Architect | 80 | $175/hr | $14,000 |
| DevOps Engineer | 160 | $150/hr | $24,000 |
| M365 Security Administrator | 120 | $140/hr | $16,800 |
| Project Manager | 60 | $125/hr | $7,500 |
| Technical Writer | 40 | $100/hr | $4,000 |
| **Labor Subtotal** | **460** | | **$66,300** |

### 5.2 Licensing and Infrastructure Costs

| Item | Quantity | Monthly Cost | Duration | Total |
|------|----------|--------------|----------|-------|
| Azure DevOps Basic + Test Plans (if needed) | 10 users | $52/user | 4 months | $2,080 |
| Microsoft Defender for DevOps | Included | - | - | $0 |
| Azure Log Analytics (additional ingestion) | 10 GB/day | $2.76/GB | 4 months | $3,312 |
| Azure Key Vault (Premium) | 2 vaults | $1/10K operations | 4 months | $200 |
| Self-hosted agents (Azure VMs) | 2 VMs | $150/VM | 4 months | $1,200 |
| **Infrastructure Subtotal** | | | | **$6,792** |

### 5.3 Training and Consulting

| Item | Description | Cost |
|------|-------------|------|
| Microsoft Security Workshop | Azure DevOps security deep-dive | $5,000 |
| Staff Training | 8 hours × 10 staff | $3,000 |
| Third-party Security Assessment | Validation of controls | $8,000 |
| **Training Subtotal** | | **$16,000** |

### 5.4 Contingency

| Category | Amount |
|----------|--------|
| 15% Contingency Reserve | $13,364 |

### 5.5 Total Project Cost

| Category | Cost (CAD) |
|----------|------------|
| Labor | $66,300 |
| Infrastructure | $6,792 |
| Training & Consulting | $16,000 |
| Contingency (15%) | $13,364 |
| **Grand Total** | **$102,456** |

---

## 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Resource availability constraints | Medium | High | Early resource booking, backup assignments |
| Resistance to security controls | Medium | Medium | Stakeholder communication, change management |
| Integration issues with existing pipelines | Medium | High | Thorough testing, staged rollout |
| Timeline slippage | Medium | Medium | Buffer time, scope management |
| Vendor support delays | Low | Medium | Microsoft Premier support engagement |

---

## 7. Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Sponsor | | | |
| Security Manager | | | |
| IT Director | | | |
| Compliance Officer | | | |

---

# ANNEX A: Build Book - Azure DevOps Security Implementation

## A.1 Pre-Implementation Checklist

- [ ] Azure DevOps organization administrator access confirmed
- [ ] Microsoft Entra ID Global Administrator or Privileged Role Administrator access
- [ ] Azure subscription with Log Analytics workspace
- [ ] Azure Key Vault Premium deployed
- [ ] Network connectivity verified
- [ ] Backup of current configurations

## A.2 Identity and Access Management Configuration

### A.2.1 Enable Microsoft Entra ID Authentication Only

**Azure DevOps Organization Settings:**

1. Navigate to `Organization Settings > Policies`
2. Configure the following:

```
Third-party application access via OAuth: OFF
SSH authentication: OFF (unless required for Git operations)
Allow public projects: OFF
External guest access: OFF or Limited
```

3. Navigate to `Organization Settings > Microsoft Entra`
4. Ensure organization is connected to Microsoft Entra ID
5. Set "Restrict organization creation" to specific security groups

### A.2.2 Conditional Access Policy - Azure DevOps

**Policy Name:** CA-AzureDevOps-SecureAccess

```json
{
  "displayName": "CA-AzureDevOps-SecureAccess",
  "state": "enabled",
  "conditions": {
    "applications": {
      "includeApplications": ["499b84ac-1321-427f-aa17-267ca6975798"]
    },
    "users": {
      "includeUsers": ["All"]
    },
    "locations": {
      "includeLocations": ["All"],
      "excludeLocations": ["AllTrusted"]
    },
    "platforms": {
      "includePlatforms": ["all"]
    }
  },
  "grantControls": {
    "operator": "AND",
    "builtInControls": [
      "mfa",
      "compliantDevice"
    ]
  },
  "sessionControls": {
    "signInFrequency": {
      "value": 8,
      "type": "hours"
    }
  }
}
```

**PowerShell Implementation:**

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"

# Create Conditional Access Policy
$params = @{
    DisplayName = "CA-AzureDevOps-SecureAccess"
    State = "enabled"
    Conditions = @{
        Applications = @{
            IncludeApplications = @("499b84ac-1321-427f-aa17-267ca6975798")
        }
        Users = @{
            IncludeUsers = @("All")
            ExcludeGroups = @("<BreakGlassGroupId>")
        }
        Locations = @{
            IncludeLocations = @("All")
            ExcludeLocations = @("AllTrusted")
        }
    }
    GrantControls = @{
        Operator = "AND"
        BuiltInControls = @("mfa", "compliantDevice")
    }
    SessionControls = @{
        SignInFrequency = @{
            Value = 8
            Type = "hours"
            IsEnabled = $true
        }
    }
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $params
```

### A.2.3 Privileged Identity Management Configuration

**PIM Role Assignments for Azure DevOps:**

| Role | Assignment Type | Duration | Justification Required |
|------|-----------------|----------|------------------------|
| Project Collection Administrator | Eligible | 8 hours | Yes |
| Organization Owner | Eligible | 4 hours | Yes |
| Project Administrator | Eligible | 8 hours | Yes |

**PowerShell for PIM Role Assignment:**

```powershell
# Get the Azure DevOps service principal
$servicePrincipal = Get-MgServicePrincipal -Filter "appId eq '499b84ac-1321-427f-aa17-267ca6975798'"

# Create eligible role assignment
$params = @{
    Action = "AdminAssign"
    RoleDefinitionId = "<RoleDefinitionId>"
    PrincipalId = "<UserOrGroupId>"
    DirectoryScopeId = "/"
    Justification = "Azure DevOps administration"
    ScheduleInfo = @{
        StartDateTime = (Get-Date)
        Expiration = @{
            Type = "afterDuration"
            Duration = "PT8H"
        }
    }
}

New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params
```

### A.2.4 Personal Access Token Policy

**Organization Policy Configuration:**

```
Maximum PAT Lifetime: 90 days
Restrict PAT scope: Enabled
Require approval for full-scope tokens: Enabled
Audit PAT creation: Enabled
```

**Azure CLI Implementation:**

```bash
# Set PAT policy
az devops admin policy set \
    --organization https://dev.azure.com/LeonardoCanada \
    --policy-name "maximum-pat-lifetime" \
    --value 90

az devops admin policy set \
    --organization https://dev.azure.com/LeonardoCanada \
    --policy-name "restrict-pat-scope" \
    --value true
```

## A.3 Organization Security Configuration

### A.3.1 Organization Policies

Navigate to `Organization Settings > Policies` and configure:

| Policy | Setting | Rationale |
|--------|---------|-----------|
| Third-party application access via OAuth | Off | Prevent unauthorized integrations |
| SSH authentication | Off | Enforce Entra ID authentication |
| Allow public projects | Off | Prevent data exposure |
| Additional protections when using public package managers | On | Supply chain security |
| Enable Azure Active Directory Conditional Access Policy Validation | On | Enforce CA policies |

### A.3.2 Audit Streaming Configuration

**Setup Log Analytics Workspace Integration:**

1. Navigate to `Organization Settings > Auditing`
2. Click "Create stream"
3. Select "Azure Monitor Log Analytics"
4. Configure:

```
Workspace ID: <Your-Log-Analytics-Workspace-ID>
Shared Key: <Primary-Key>
```

**KQL Queries for Security Monitoring:**

```kusto
// Failed authentication attempts
AzureDevOpsAuditing
| where OperationName == "Login.Failed"
| summarize FailedAttempts = count() by UserPrincipalName, bin(TimeGenerated, 1h)
| where FailedAttempts > 5

// Permission changes
AzureDevOpsAuditing
| where OperationName contains "Permission" or OperationName contains "Security"
| project TimeGenerated, OperationName, ActorDisplayName, Data
| order by TimeGenerated desc

// Service connection modifications
AzureDevOpsAuditing
| where OperationName contains "ServiceEndpoint"
| project TimeGenerated, OperationName, ActorDisplayName, Data

// PAT operations
AzureDevOpsAuditing
| where OperationName contains "Token"
| project TimeGenerated, OperationName, ActorDisplayName, Data
```

### A.3.3 IP Restrictions

**Configure IP Allow List:**

```
Organization Settings > Security > Policies > IP Conditional Access

Enabled: Yes
IP Addresses:
  - 10.0.0.0/8 (Corporate network)
  - 172.16.0.0/12 (VPN range)
  - <Specific-Public-IPs>
```

## A.4 Repository Security Configuration

### A.4.1 Branch Policy Template

**Production Branch Policy (main/master):**

```yaml
# azure-pipelines-branch-policy.yml
branch_policies:
  - pattern: "refs/heads/main"
    settings:
      require_pull_request:
        enabled: true
        minimum_approvers: 2
        creator_vote_counts: false
        reset_on_source_push: true
        allow_completion_with_rejection: false
      require_builds:
        enabled: true
        required_builds:
          - build_definition_name: "CI-Build"
            display_name: "CI Build Validation"
      require_linked_work_items: true
      require_comment_resolution: true
      require_merge_strategy:
        enabled: true
        allowed_strategies:
          - squash
      block_direct_push: true
```

**PowerShell to Apply Branch Policies:**

```powershell
# Install Azure DevOps CLI extension
az extension add --name azure-devops

# Set default organization and project
az devops configure --defaults organization=https://dev.azure.com/LeonardoCanada project=MainProject

# Create branch policy for minimum reviewers
az repos policy approver-count create `
    --repository-id <repo-id> `
    --branch main `
    --enabled true `
    --minimum-approver-count 2 `
    --creator-vote-counts false `
    --reset-on-source-push true `
    --blocking true

# Create build validation policy
az repos policy build create `
    --repository-id <repo-id> `
    --branch main `
    --build-definition-id <build-id> `
    --enabled true `
    --blocking true `
    --queue-on-source-update-only true `
    --valid-duration 720

# Require work item linking
az repos policy work-item-linking create `
    --repository-id <repo-id> `
    --branch main `
    --enabled true `
    --blocking true

# Require comment resolution
az repos policy comment-required create `
    --repository-id <repo-id> `
    --branch main `
    --enabled true `
    --blocking true
```

### A.4.2 Secret Scanning Configuration

**Enable Microsoft Defender for DevOps:**

1. Navigate to Azure Portal > Microsoft Defender for Cloud
2. Select Environment Settings > Azure DevOps
3. Connect Azure DevOps organization
4. Enable:
   - Code scanning
   - Secret scanning
   - Dependency scanning
   - Infrastructure as Code scanning

**Push Protection Configuration:**

```
Repository Settings > Security > Push Protection

Enabled: Yes
Block pushes containing secrets: Yes
Notify security team: Yes
Allow bypass with justification: Yes (for emergencies only)
```

### A.4.3 Repository Permissions Matrix

| Security Group | Read | Contribute | Manage Permissions | Delete |
|----------------|------|------------|-------------------|--------|
| Developers | ✓ | ✓ | | |
| Senior Developers | ✓ | ✓ | | |
| Tech Leads | ✓ | ✓ | ✓ | |
| Repo Administrators | ✓ | ✓ | ✓ | ✓ |

**PowerShell for Permission Assignment:**

```powershell
# Set repository permissions
$orgUrl = "https://dev.azure.com/LeonardoCanada"
$projectName = "MainProject"
$repoId = "<repository-id>"

# Get security namespace for Git repositories
$namespaceId = "2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87"

# Create permission token
$token = "repoV2/$projectName/$repoId"

# Set permissions for a group (example: deny delete for developers)
az devops security permission update `
    --namespace-id $namespaceId `
    --subject "<group-descriptor>" `
    --token $token `
    --allow-bit 2 `  # Read
    --deny-bit 8192  # Delete
```

## A.5 Pipeline Security Configuration

### A.5.1 Secure Pipeline Template

```yaml
# templates/secure-pipeline-template.yml
parameters:
  - name: environment
    type: string
    values:
      - dev
      - test
      - prod
  - name: serviceConnection
    type: string

stages:
  - stage: Build
    jobs:
      - job: BuildJob
        pool:
          name: 'SecureAgentPool'
        steps:
          - task: CredScan@3
            displayName: 'Run Credential Scanner'
            inputs:
              toolMajorVersion: 'V2'

          - task: ComponentGovernanceComponentDetection@0
            displayName: 'Component Governance Detection'

          - task: SdtReport@2
            displayName: 'Security Analysis Report'
            inputs:
              GdnExportAllTools: true

  - stage: Deploy_${{ parameters.environment }}
    dependsOn: Build
    condition: succeeded()
    jobs:
      - deployment: DeployJob
        environment: ${{ parameters.environment }}
        pool:
          name: 'SecureAgentPool'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureKeyVault@2
                  inputs:
                    azureSubscription: ${{ parameters.serviceConnection }}
                    KeyVaultName: 'kv-devops-secrets'
                    SecretsFilter: '*'
                    RunAsPreJob: true

                - script: |
                    echo "Deploying to ${{ parameters.environment }}"
                  displayName: 'Deploy Application'
```

### A.5.2 Environment Protection Rules

**Production Environment Configuration:**

```yaml
# Environment: Production
approvals:
  - type: required
    reviewers:
      - "LCE Security Team"
      - "Release Managers"
    minimum_required: 2
    timeout_in_minutes: 1440  # 24 hours

checks:
  - type: business_hours
    settings:
      time_zone: "America/Toronto"
      start_time: "09:00"
      end_time: "17:00"
      days:
        - Monday
        - Tuesday
        - Wednesday
        - Thursday
        - Friday

  - type: invoke_azure_function
    settings:
      function: "https://func-deployment-checks.azurewebsites.net/api/ValidateDeployment"
      key: "$(FunctionKey)"

  - type: required_template
    settings:
      template_path: "templates/secure-pipeline-template.yml"
```

### A.5.3 Service Connection Security

**Workload Identity Federation Setup:**

```bash
# Create Azure AD Application
az ad app create --display-name "AzureDevOps-ServiceConnection-Prod"

# Create federated identity credential
az ad app federated-credential create \
    --id <app-object-id> \
    --parameters @federated-credential.json
```

**federated-credential.json:**

```json
{
  "name": "AzureDevOps-MainProject-Prod",
  "issuer": "https://vstoken.dev.azure.com/<org-id>",
  "subject": "sc://LeonardoCanada/MainProject/Prod-ServiceConnection",
  "audiences": ["api://AzureADTokenExchange"]
}
```

### A.5.4 Variable Groups with Key Vault

```yaml
# azure-pipelines.yml
variables:
  - group: 'Production-Secrets'  # Linked to Azure Key Vault

# Variable group linked to Key Vault
# Configure in Azure DevOps:
# 1. Library > Variable Groups > New
# 2. Enable "Link secrets from Azure Key Vault"
# 3. Select subscription and Key Vault
# 4. Add variables to authorize
```

## A.6 Agent Security Hardening

### A.6.1 Self-Hosted Agent Hardening Checklist

- [ ] Use dedicated VMs for build agents
- [ ] Apply latest OS security patches
- [ ] Enable Windows Defender or equivalent
- [ ] Configure host-based firewall
- [ ] Disable unnecessary services
- [ ] Use managed identities for Azure access
- [ ] Enable boot diagnostics
- [ ] Configure disk encryption
- [ ] Implement network security groups
- [ ] Regular agent software updates

### A.6.2 Agent Pool Configuration

```powershell
# Create secure agent pool
$poolSettings = @{
    Name = "SecureAgentPool"
    IsHosted = $false
    PoolType = "automation"
}

# Configure pool security
az pipelines pool create `
    --name "SecureAgentPool" `
    --authorize-all-pipelines false

# Set pool permissions
az devops security permission update `
    --namespace-id "83d4c2e6-e57d-4d6e-892b-b87222b7ad20" `
    --subject "<group-descriptor>" `
    --token "AgentPools/<pool-id>" `
    --allow-bit 1  # View only
```

## A.7 Monitoring and Alerting

### A.7.1 Azure Monitor Alert Rules

```json
{
  "alertRules": [
    {
      "name": "DevOps-HighPrivilegeChange",
      "description": "Alert on high privilege permission changes",
      "query": "AzureDevOpsAuditing | where OperationName contains 'Permission' and Data contains 'Administrator'",
      "severity": "High",
      "frequency": "5m",
      "threshold": 1
    },
    {
      "name": "DevOps-ServiceConnectionModified",
      "description": "Alert on service connection changes",
      "query": "AzureDevOpsAuditing | where OperationName contains 'ServiceEndpoint'",
      "severity": "Medium",
      "frequency": "5m",
      "threshold": 1
    },
    {
      "name": "DevOps-FailedAuthentication",
      "description": "Alert on multiple failed login attempts",
      "query": "AzureDevOpsAuditing | where OperationName == 'Login.Failed' | summarize count() by UserPrincipalName | where count_ > 5",
      "severity": "High",
      "frequency": "15m",
      "threshold": 1
    }
  ]
}
```

### A.7.2 Compliance Dashboard Workbook

```json
{
  "workbook": {
    "name": "Azure DevOps Security Compliance",
    "sections": [
      {
        "title": "Authentication Security",
        "queries": [
          "MFA enforcement status",
          "Conditional Access policy hits",
          "Failed authentication trends"
        ]
      },
      {
        "title": "Access Management",
        "queries": [
          "Privileged role assignments",
          "PAT inventory and expiration",
          "Service connection inventory"
        ]
      },
      {
        "title": "Repository Security",
        "queries": [
          "Branch policy compliance",
          "Secret scanning findings",
          "Code review metrics"
        ]
      },
      {
        "title": "Pipeline Security",
        "queries": [
          "Pipeline approval compliance",
          "Agent pool utilization",
          "Failed deployments"
        ]
      }
    ]
  }
}
```

## A.8 Validation and Testing

### A.8.1 Security Control Validation Checklist

| Control | Test Method | Expected Result |
|---------|-------------|-----------------|
| MFA Enforcement | Attempt login without MFA | Access denied |
| Conditional Access | Login from non-compliant device | Access denied |
| Branch Protection | Direct push to main | Push rejected |
| Secret Scanning | Commit with test secret | Commit blocked |
| Pipeline Approval | Deploy without approval | Deployment blocked |
| PAT Expiration | Create PAT > 90 days | Creation blocked |

### A.8.2 Penetration Testing Scope

```
In Scope:
- Azure DevOps organization configuration
- Authentication and authorization mechanisms
- API security
- Pipeline execution security
- Repository access controls

Out of Scope:
- Microsoft-managed infrastructure
- Third-party integrations (separate assessment)
- Physical security
```

---

# ANNEX B: Standard Operating Procedures

## B.1 Access Request Procedure

1. User submits access request through ServiceNow
2. Manager approval required
3. Security team validates clearance status
4. PIM eligible role assigned
5. User completes security acknowledgment
6. Access provisioned and logged

## B.2 Service Connection Creation Procedure

1. DevOps engineer submits service connection request
2. Security review of scope and permissions
3. Workload identity federation configured
4. Connection created with minimal permissions
5. Connection documented in CMDB
6. Quarterly review scheduled

## B.3 Security Incident Response

1. Alert received from monitoring system
2. Initial triage by on-call team
3. Severity classification
4. Containment actions (disable access, revoke tokens)
5. Investigation and root cause analysis
6. Remediation and recovery
7. Post-incident review

---

# ANNEX C: References

## C.1 Microsoft Documentation

| Resource | URL |
|----------|-----|
| Azure DevOps Security Best Practices | https://learn.microsoft.com/en-us/azure/devops/organizations/security/security-best-practices |
| Azure DevOps Security Overview | https://learn.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity |
| Conditional Access for Azure DevOps | https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/change-application-access-policies |
| Pipeline Security | https://learn.microsoft.com/en-us/azure/devops/pipelines/security/overview |
| Repository Security | https://learn.microsoft.com/en-us/azure/devops/repos/git/security-overview |
| Microsoft Defender for DevOps | https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-devops-introduction |

## C.2 Government of Canada Standards

| Standard | Description |
|----------|-------------|
| ITSG-33 | IT Security Risk Management: A Lifecycle Approach |
| ITSG-22 | Baseline Security Requirements for Network Security Zones |
| PBMM | Protected B, Medium Integrity, Medium Availability |

## C.3 Industry Standards

| Standard | Application |
|----------|-------------|
| NIST SP 800-53 | Security and Privacy Controls |
| CIS Controls | Center for Internet Security Controls |
| OWASP | Secure DevOps Guidelines |
| SLSA | Supply-chain Levels for Software Artifacts |

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 16, 2025 | LCE M365 Security Team | Initial release |

---

*End of Document*