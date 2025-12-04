# Teams Premium & CMK Compliance Monitoring

Azure Monitor Workbook and Alert solution for tracking Teams Premium license assignments and Customer Managed Key (CMK) meeting policy compliance across your Microsoft 365 tenant.

## Overview

This solution provides:

- **Dashboard** - Visual compliance tracking showing which users have Teams Premium licenses and CMK-protected meeting policies
- **Alerting** - Automated notifications to administrators when users are found non-compliant
- **Audit Trail** - Historical view of license and policy assignment changes

## Prerequisites

### 1. Log Analytics Workspace with Entra ID Data

Your Log Analytics workspace must be receiving data from Entra ID. Configure this in the Azure Portal:

1. Navigate to **Microsoft Entra ID** > **Diagnostic settings**
2. Click **+ Add diagnostic setting**
3. Enable these log categories:
   - `AuditLogs` (required)
   - `SignInLogs` (required)
   - `NonInteractiveUserSignInLogs` (recommended)
4. Select your Log Analytics workspace as the destination
5. Save the configuration

**Note:** It takes 24-48 hours for initial data to flow after enabling diagnostic settings.

### 2. Required Azure Permissions

The deploying user needs:
- `Log Analytics Contributor` on the workspace
- `Monitoring Contributor` on the resource group (for alert rules)
- `Workbook Contributor` on the resource group

### 3. PowerShell Modules

```powershell
Install-Module Az.OperationalInsights -Force
Install-Module Az.Monitor -Force
Install-Module Az.Resources -Force
```

## Deployment

### Option 1: PowerShell Script (Recommended)

```powershell
# Connect to Azure
Connect-AzAccount

# Deploy the solution
.\Deploy-ComplianceMonitoring.ps1 `
    -SubscriptionId "your-subscription-id" `
    -ResourceGroupName "rg-lce-monitoring" `
    -WorkspaceName "law-lce-sentinel" `
    -AdminEmail "m365security@leonardo.com" `
    -AlertFrequencyHours 24
```

### Option 2: Manual Deployment

#### Deploy Workbook

1. Navigate to **Azure Monitor** > **Workbooks**
2. Click **+ New**
3. Click the **Advanced Editor** button (`</>`)
4. Replace the contents with `workbook-template.json`
5. Click **Apply** then **Done Editing**
6. Click **Save** and choose your resource group

#### Deploy Alert Rule

```powershell
# Deploy using ARM template
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-lce-monitoring" `
    -TemplateFile "alert-rule-template.json" `
    -workspaceName "law-lce-sentinel" `
    -workspaceResourceGroup "rg-lce-monitoring" `
    -actionGroupEmail "m365security@leonardo.com"
```

## Configuration

### Customizing Target Users

The default queries track all active users (those who have signed in within 30 days). To filter to specific groups:

1. Create a security group in Entra ID containing users who should have Teams Premium
2. Modify the KQL queries to filter by group membership:

```kusto
// Add this to filter by group
let TargetGroupId = "your-security-group-object-id";
let TargetUsers = IdentityInfo
| where GroupMembership contains TargetGroupId
| distinct AccountUPN;
```

### Customizing CMK Policy Detection

The workbook looks for meeting policies containing "CMK", "Protected", or "Secure" in the name. Update the query to match your actual policy names:

```kusto
// Replace this line in the queries
| where PolicyName contains "CMK" or PolicyName contains "Protected" or PolicyName contains "Secure"

// With your specific policy names
| where PolicyName == "LCE-CMK-MeetingPolicy" or PolicyName == "Protected-B-Meeting-Policy"
```

### Alert Frequency

The default alert runs daily. Adjust using the `alertFrequencyMinutes` parameter:
- Daily: 1440 minutes
- Every 12 hours: 720 minutes
- Every 6 hours: 360 minutes

## Workbook Sections

| Section | Description |
|---------|-------------|
| **Compliance Overview** | Summary tiles showing total users, compliant count, and compliance rate |
| **User Compliance Details** | Detailed table of each user's Teams Premium and CMK status |
| **Non-Compliant Users** | Filtered view of users requiring remediation action |
| **License Assignment Trends** | Time-series chart of Teams Premium license assignments |
| **Audit Trail** | Recent license and policy change events |

## Alert Behavior

The scheduled query alert:
- Runs at the configured frequency (default: daily)
- Queries for active users missing Teams Premium license OR CMK meeting policy
- Triggers when **any** non-compliant users are found
- Sends email to the configured Action Group
- Includes a summary of affected users in the alert payload

## Troubleshooting

### No Data Appearing

1. Verify Entra ID diagnostic settings are enabled (see Prerequisites)
2. Wait 24-48 hours for initial data ingestion
3. Run this test query in Log Analytics:

```kusto
AuditLogs
| where TimeGenerated > ago(7d)
| take 10
```

### Teams Premium License Detection Issues

The SKU part number `Microsoft_Teams_Premium` may vary. Check your actual SKU:

```kusto
AuditLogs
| where OperationName == "Change user license"
| extend ModifiedProps = tostring(TargetResources[0].modifiedProperties)
| where ModifiedProps contains "Teams"
| project TimeGenerated, ModifiedProps
| take 20
```

### Meeting Policy Detection Issues

Verify meeting policy audit events are being captured:

```kusto
AuditLogs
| where OperationName contains "policy" or OperationName contains "Policy"
| summarize count() by OperationName
| order by count_ desc
```

## Files Included

| File | Purpose |
|------|---------|
| `workbook-template.json` | Azure Monitor Workbook definition |
| `alert-rule-template.json` | ARM template for alert rule and action group |
| `Deploy-ComplianceMonitoring.ps1` | PowerShell deployment script |
| `README.md` | This documentation |

## Support

For issues with this solution, contact the LCE M365 Security Team.
