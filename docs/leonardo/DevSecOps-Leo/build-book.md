# Build Book - Azure DevOps Security Implementation

## A.1 Pre-Implementation Checklist

- [ ] Azure DevOps Organization Administrator access confirmed
- [ ] Microsoft Entra ID Global Administrator or Privileged Role Administrator access
- [ ] Azure subscription with Contributor access
- [ ] Coordination confirmed with Leonardo Italy IT team (if applicable)
- [ ] Coordination confirmed with Leonardo UK IT team (if applicable)
- [ ] Current configuration backup completed
- [ ] 

## A.2 Zero Trust Identity Configuration

### A.2.1 Enable Microsoft Entra ID Authentication Only

**Azure DevOps Organization Settings:**

1. Navigate to `Organization Settings > Policies`
2. Configure the following:

```

Third-party application access via OAuth: OFF

SSH authentication: OFF

Allow public projects: OFF

External guest access: OFF

```

3. Navigate to `Organization Settings > Microsoft Entra`
4. Verify organization is connected to Leonardo Canada Entra ID tenant
5. Set "Restrict organization creation" to specific security groups

### A.2.2 Conditional Access Policy for Azure DevOps

**Policy Name:** CA-AzureDevOps-ZeroTrust

```json

{

"displayName": "CA-AzureDevOps-ZeroTrust",

"state": "enabled",

"conditions": {

"applications": {

"includeApplications": ["499b84ac-1321-427f-aa17-267ca6975798"]

    },

"users": {

"includeUsers": ["All"],

"excludeGroups": ["BreakGlass-EmergencyAccess"]

    },

"locations": {

"includeLocations": ["All"]

    },

"platforms": {

"includePlatforms": ["all"]

    },

"clientAppTypes": ["all"]

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

"type": "hours",

"isEnabled": true

    },

"persistentBrowser": {

"mode": "never",

"isEnabled": true

    },

"continuousAccessEvaluation": {

"mode": "strictEnforcement"

    }

  }

}

```

**PowerShell Implementation:**

```powershell

Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"


$params = @{

DisplayName = "CA-AzureDevOps-ZeroTrust"

State = "enabled"

Conditions = @{

Applications = @{

IncludeApplications = @("499b84ac-1321-427f-aa17-267ca6975798")

        }

Users = @{

IncludeUsers = @("All")

ExcludeGroups = @("<BreakGlassGroupId>")

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

PersistentBrowser = @{

Mode = "never"

IsEnabled = $true

        }

    }

}


New-MgIdentityConditionalAccessPolicy -BodyParameter $params

```

### A.2.3 Managed Identity for Service Connections

**Create Managed Identity for Pipeline Authentication:**

```powershell

# Create user-assigned managed identity

$resourceGroup = "rg-devops-security"

$identityName = "mi-azuredevops-pipeline"

$location = "canadacentral"


az identity create `

    --resource-group $resourceGroup `

    --name $identityName `

    --location $location


# Get identity details

$identity = az identity show `

    --resource-group $resourceGroup `

    --name $identityName `

    --query "{clientId:clientId, principalId:principalId}" `

    --output json | ConvertFrom-Json


# Assign RBAC roles as needed

az role assignment create `

    --assignee $identity.principalId `

    --role "Contributor" `

    --scope "/subscriptions/<subscription-id>/resourceGroups/<target-rg>"

```

### A.2.4 Workload Identity Federation for Cross-Tenant Pipelines

**Configure Federation for Leonardo Italy:**

```powershell

# Create app registration for federated identity

$appName = "AzureDevOps-CrossTenant-Italy"

$app = New-MgApplication -DisplayName $appName


# Create federated identity credential

$federatedCredential = @{

name = "AzureDevOps-Italy-Federation"

issuer = "https://vstoken.dev.azure.com/<LeonardoCanada-OrgId>"

subject = "sc://LeonardoCanada/SharedProject/Italy-ServiceConnection"

audiences = @("api://AzureADTokenExchange")

}


New-MgApplicationFederatedIdentityCredential `

    -ApplicationId $app.Id `

    -BodyParameter $federatedCredential

```

**Configure Federation for Leonardo UK:**

```powershell

$appNameUK = "AzureDevOps-CrossTenant-UK"

$appUK = New-MgApplication -DisplayName $appNameUK


$federatedCredentialUK = @{

name = "AzureDevOps-UK-Federation"

issuer = "https://vstoken.dev.azure.com/<LeonardoCanada-OrgId>"

subject = "sc://LeonardoCanada/SharedProject/UK-ServiceConnection"

audiences = @("api://AzureADTokenExchange")

}


New-MgApplicationFederatedIdentityCredential `

    -ApplicationId $appUK.Id `

    -BodyParameter $federatedCredentialUK

```

## A.3 Cross-Tenant Access Configuration

### A.3.1 Cross-Tenant Access Policy for Leonardo Italy

**Entra ID Admin Center Configuration:**

```powershell

Connect-MgGraph -Scopes "Policy.ReadWrite.CrossTenantAccess"


# Leonardo Italy Tenant ID

$italyTenantId = "<Leonardo-Italy-Tenant-ID>"


$italyPolicy = @{

tenantId = $italyTenantId

b2bCollaborationInbound = @{

usersAndGroups = @{

accessType = "allowed"

targets = @(

@{

target = "AllUsers"

targetType = "user"

                }

            )

        }

applications = @{

accessType = "allowed"

targets = @(

@{

target = "499b84ac-1321-427f-aa17-267ca6975798"# Azure DevOps

targetType = "application"

                }

            )

        }

    }

b2bCollaborationOutbound = @{

usersAndGroups = @{

accessType = "allowed"

targets = @(

@{

target = "<Italy-Collaboration-Group-ID>"

targetType = "group"

                }

            )

        }

applications = @{

accessType = "allowed"

targets = @(

@{

target = "499b84ac-1321-427f-aa17-267ca6975798"

targetType = "application"

                }

            )

        }

    }

inboundTrust = @{

isMfaAccepted = $true

isCompliantDeviceAccepted = $true

isHybridAzureADJoinedDeviceAccepted = $true

    }

}


New-MgPolicyCrossTenantAccessPolicyPartner -BodyParameter $italyPolicy

```

### A.3.2 Cross-Tenant Access Policy for Leonardo UK

```powershell

$ukTenantId = "<Leonardo-UK-Tenant-ID>"


$ukPolicy = @{

tenantId = $ukTenantId

b2bCollaborationInbound = @{

usersAndGroups = @{

accessType = "allowed"

targets = @(

@{

target = "AllUsers"

targetType = "user"

                }

            )

        }

applications = @{

accessType = "allowed"

targets = @(

@{

target = "499b84ac-1321-427f-aa17-267ca6975798"

targetType = "application"

                }

            )

        }

    }

b2bCollaborationOutbound = @{

usersAndGroups = @{

accessType = "allowed"

targets = @(

@{

target = "<UK-Collaboration-Group-ID>"

targetType = "group"

                }

            )

        }

applications = @{

accessType = "allowed"

targets = @(

@{

target = "499b84ac-1321-427f-aa17-267ca6975798"

targetType = "application"

                }

            )

        }

    }

inboundTrust = @{

isMfaAccepted = $true

isCompliantDeviceAccepted = $true

isHybridAzureADJoinedDeviceAccepted = $true

    }

}


New-MgPolicyCrossTenantAccessPolicyPartner -BodyParameter $ukPolicy

```

## A.4 Git Repository Security Configuration

### A.4.1 Branch Policy for Shared Repositories

**Production Branch Policy (main):**

```powershell

# Install Azure DevOps CLI extension

az extension add --name azure-devops


# Configure defaults

az devops configure --defaults organization=https://dev.azure.com/LeonardoCanada project=SharedDevelopment


# Create minimum reviewer policy (2 reviewers for cross-regional work)

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

    --build-definition-id <security-scan-build-id> `

    --enabled true `

    --blocking true `

    --queue-on-source-update-only true `

    --display-name "Security Scan Validation"


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

### A.4.2 Secret Scanning and Push Protection

**Enable Microsoft Defender for DevOps:**

1. Navigate to Azure Portal > Microsoft Defender for Cloud
2. Select Environment Settings > Azure DevOps
3. Connect Azure DevOps organization
4. Enable:

- Secret scanning
- Push protection
- Dependency scanning

**Push Protection Settings:**

```

Repository Settings > Security > Advanced Security


GitHub Advanced Security for Azure DevOps: Enabled

Secret Scanning: Enabled

Push Protection: Enabled

Block pushes containing secrets: Yes

```

### A.4.3 Repository Permissions for Cross-Regional Teams

| Security Group | Canada | Italy | UK | Permission Level |

|----------------|--------|-------|-----|------------------|

| LCC-Developers | ✓ | | | Contribute |

| LCC-Italy-Developers | | ✓ | | Contribute |

| LCC-UK-Developers | | | ✓ | Contribute |

| LCC-Tech-Leads | ✓ | ✓ | ✓ | Contribute + Manage Permissions |

| LCC-Repo-Admins | ✓ | | | Full Control |

## A.5 Pipeline Security Configuration

### A.5.1 Secure Pipeline Template with Managed Identity

```yaml

# templates/secure-cross-regional-pipeline.yml

parameters:

  - name: environment

type: string

values:

      - dev

      - test

      - prod

  - name: region

type: string

values:

      - canada

      - italy

      - uk


stages:

  - stage: SecurityScan

displayName: 'Security Scanning'

jobs:

      - job: ScanJob

pool:

vmImage: 'ubuntu-latest'

steps:

          - task: CredScan@3

displayName: 'Credential Scanner'

inputs:

toolMajorVersion: 'V2'

outputFormat: 'sarif'


          - task: ComponentGovernanceComponentDetection@0

displayName: 'Dependency Scan'


          - task: PublishSecurityAnalysisLogs@3

displayName: 'Publish Security Logs'


  - stage: Build

displayName: 'Build'

dependsOn: SecurityScan

jobs:

      - job: BuildJob

pool:

vmImage: 'ubuntu-latest'

steps:

          - task: AzureCLI@2

displayName: 'Build with Managed Identity'

inputs:

azureSubscription: 'ManagedIdentity-ServiceConnection'

scriptType: 'bash'

scriptLocation: 'inlineScript'

inlineScript: |

                echo "Building for ${{ parameters.region }}"

                # Build commands here


  - stage: Deploy_${{ parameters.environment }}

displayName: 'Deploy to ${{ parameters.environment }}'

dependsOn: Build

condition: succeeded()

jobs:

      - deployment: DeployJob

environment: ${{ parameters.environment }}-${{ parameters.region }}

pool:

vmImage: 'ubuntu-latest'

strategy:

runOnce:

deploy:

steps:

                - task: AzureKeyVault@2

displayName: 'Get Secrets'

inputs:

azureSubscription: 'ManagedIdentity-ServiceConnection'

KeyVaultName: 'kv-devops-${{ parameters.region }}'

SecretsFilter: '*'

RunAsPreJob: true


                - script: |

                    echo "Deploying to ${{ parameters.environment }} in ${{ parameters.region }}"

displayName: 'Deploy'

```

### A.5.2 Environment Protection Rules

**Production Environment Configuration:**

```yaml

# Environment: prod-canada

approvals:

  - type: required

reviewers:

      - "LCC-Release-Managers"

      - "LCC-Security-Team"

minimum_required: 2

timeout_in_minutes: 1440


checks:

  - type: business_hours

settings:

time_zone: "America/Toronto"

start_time: "09:00"

end_time: "17:00"

days: [Monday, Tuesday, Wednesday, Thursday, Friday]


  - type: exclusive_lock

settings:

timeout_in_minutes: 60


  - type: required_template

settings:

template_path: "templates/secure-cross-regional-pipeline.yml"

```

### A.5.3 Service Connection with Workload Identity

**Azure DevOps Service Connection Configuration:**

```

Service Connection Type: Azure Resource Manager

Authentication: Workload Identity Federation


Subscription: <Target-Subscription>

Resource Group: <Target-Resource-Group>

Service Connection Name: ManagedIdentity-ServiceConnection


Workload Identity Federation:

  Issuer: https://vstoken.dev.azure.com/<org-id>

  Subject: sc://LeonardoCanada/SharedProject/ManagedIdentity-ServiceConnection

```

## A.6 Monitoring and Audit Configuration

### A.6.1 Audit Log Streaming to Log Analytics

**Configure Audit Streaming:**

1. Navigate to `Organization Settings > Auditing`
2. Click "Create stream"
3. Select "Azure Monitor Log Analytics"
4. Configure workspace connection

### A.6.2 KQL Queries for Cross-Tenant Monitoring

```kusto

// Cross-tenant access attempts

AzureDevOpsAuditing

| where OperationName contains "Login" or OperationName contains "Auth"

| extend UserTenant = tostring(parse_json(Data).UserTenantId)

| where UserTenant != "<LeonardoCanada-TenantId>"

| summarize AccessCount = count() by UserPrincipalName, UserTenant, bin(TimeGenerated, 1h)

| order by TimeGenerated desc


// Repository access from external tenants

AzureDevOpsAuditing

| where OperationName contains "Git" or OperationName contains "Repo"

| extend UserTenant = tostring(parse_json(Data).UserTenantId)

| where UserTenant in ("<Italy-TenantId>", "<UK-TenantId>")

| project TimeGenerated, UserPrincipalName, OperationName, UserTenant

| order by TimeGenerated desc


// Service connection usage

AzureDevOpsAuditing

| where OperationName contains "ServiceEndpoint"

| project TimeGenerated, OperationName, ActorDisplayName, Data

| order by TimeGenerated desc


// Failed authentication from partner tenants

AzureDevOpsAuditing

| where OperationName == "Login.Failed"

| extend UserTenant = tostring(parse_json(Data).UserTenantId)

| summarize FailureCount = count() by UserPrincipalName, UserTenant, bin(TimeGenerated, 1h)

| where FailureCount > 3

```

### A.6.3 Alert Rules

```json

{

"alertRules": [

    {

"name": "DevOps-UnauthorizedTenantAccess",

"description": "Alert on access attempts from non-Leonardo tenants",

"query": "AzureDevOpsAuditing | extend UserTenant = tostring(parse_json(Data).UserTenantId) | where UserTenant !in ('<Canada-TenantId>', '<Italy-TenantId>', '<UK-TenantId>') and UserTenant != ''",

"severity": "High",

"frequency": "5m"

    },

    {

"name": "DevOps-ManagedIdentityFailure",

"description": "Alert on managed identity authentication failures",

"query": "AzureDevOpsAuditing | where OperationName contains 'ServiceEndpoint' and Data contains 'Failed'",

"severity": "High",

"frequency": "5m"

    },

    {

"name": "DevOps-BranchPolicyBypass",

"description": "Alert on branch policy bypass attempts",

"query": "AzureDevOpsAuditing | where OperationName contains 'Policy' and Data contains 'bypass'",

"severity": "Medium",

"frequency": "5m"

    }

  ]

}

```

## A.7 Validation Checklist

| Control | Test Method | Expected Result |

|---------|-------------|-----------------|

| MFA Enforcement | Login without MFA | Access denied |

| Device Compliance | Login from non-compliant device | Access denied |

| Cross-Tenant - Italy | Italy user accesses shared repo | Access granted |

| Cross-Tenant - UK | UK user accesses shared repo | Access granted |

| Cross-Tenant - Other | External user attempts access | Access denied |

| Branch Protection | Direct push to main | Push rejected |

| Secret Scanning | Commit with test secret | Commit blocked |

| Managed Identity | Pipeline authenticates to Azure | Success without credentials |

| Workload Federation | Cross-tenant pipeline runs | Success without stored secrets |

---

# ANNEX B: Standard Operating Procedures

## B.1 Cross-Tenant User Access Request

1. Request submitted via ServiceNow from partner subsidiary
2. Manager approval from requesting region
3. Leonardo Canada security review
4. Guest invitation sent via Entra ID
5. User added to appropriate security group
6. Access logged and documented
7. Quarterly review scheduled

## B.2 Managed Identity Provisioning

1. Request submitted for new managed identity
2. Security review of required permissions
3. Identity created in designated resource group
4. RBAC roles assigned per least privilege
5. Service connection configured in Azure DevOps
6. Documentation updated
7. Testing completed

## B.3 Security Incident Response - Cross-Tenant

1. Alert received from monitoring
2. Initial triage - identify affected tenants
3. Coordinate with partner subsidiary security teams
4. Containment actions (revoke access if needed)
5. Investigation across affected regions
6. Remediation
7. Joint post-incident review

---

# ANNEX C: References

## C.1 Microsoft Documentation

| Resource | URL |

|----------|-----|

| Azure DevOps Security Best Practices | https://learn.microsoft.com/en-us/azure/devops/organizations/security/security-best-practices |

| Managed Identities Overview | https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview |

| Workload Identity Federation | https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation |

| Cross-Tenant Access Settings | https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration |

| Conditional Access for Azure DevOps | https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/change-application-access-policies |

| GitHub Advanced Security for Azure DevOps | https://learn.microsoft.com/en-us/azure/devops/repos/security/configure-github-advanced-security-features |

## C.2 Government of Canada Standards

| Standard | Description |

|----------|-------------|

| ITSG-33 | IT Security Risk Management: A Lifecycle Approach |

| CCCS Zero Trust | Canadian Centre for Cyber Security Zero Trust Guidance |

## C.3 Industry Standards

| Standard | Application |

|----------|-------------|

| NIST SP 800-207 | Zero Trust Architecture |

| NIST SP 800-53 | Security and Privacy Controls |

| CIS Controls | Center for Internet Security Controls |

---

**Document Control**

| Version | Date | Author | Changes |

|---------|------|--------|---------|

| 1.0 | December 16, 2025 | Frederick Pearson, Cloudstrucc Inc. | Initial release |

---
