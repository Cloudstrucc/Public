# Nintex E-Sign Office Add-in & Dataverse Broker Service

## Elections Canada Platform Engineering Team

---

## Document Information

| Field | Value |
|-------|-------|
| Version | 2.0 |
| Author | Elections Canada - Platform Engineering Team |
| Last Updated | December 2025 |
| Status | Draft |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Dataverse Broker Service](#3-dataverse-broker-service)
4. [Dataverse Schema](#4-dataverse-schema)
5. [Approval Workflow & Cost Controls](#5-approval-workflow--cost-controls)
6. [Office Add-in Implementation](#6-office-add-in-implementation)
7. [Configurable Signature Fields](#7-configurable-signature-fields)
8. [Programmatic API Access & Onboarding](#8-programmatic-api-access--onboarding)
9. [Security & Zero Trust](#9-security--zero-trust)
10. [Deployment Guide](#10-deployment-guide)
11. [Monitoring & Dashboards](#11-monitoring--dashboards)
12. [Appendix](#12-appendix)

---

## 1. Executive Summary

### 1.1 Purpose

This document provides the technical implementation guide for Elections Canada's Nintex AssureSign e-signature solution. The solution provides:

- **Office Add-in** — Ribbon integration for Word, Excel, and PDF documents
- **Dataverse Broker Service** — Centralized gateway for all e-signature requests with governance controls
- **Programmatic API Access** — Bulk/automated signing via Managed Identity authentication
- **Cost & Approval Controls** — Guardrails preventing unauthorized spending
- **Audit & Compliance** — Complete audit trail stored in Canadian Dataverse

### 1.2 Key Principles

| Principle | Implementation |
|-----------|----------------|
| **Zero Trust** | All API access via Managed Identity or Azure AD authentication |
| **Cost Control** | Approval workflows trigger when thresholds exceeded |
| **Data Sovereignty** | All data stored in Canadian Dataverse environment |
| **Single Gateway** | All requests route through Dataverse broker — no direct Nintex access |
| **Audit Trail** | Every envelope, approval, and status change logged |

### 1.3 Solution Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ELECTIONS CANADA CLIENTS                            │
├─────────────────────┬─────────────────────┬─────────────────────────────────┤
│   Office Add-in     │   Power Platform    │    Programmatic API             │
│  (Word/Excel/PDF)   │   (Power Automate)  │    (Managed Identity)           │
└─────────┬───────────┴─────────┬───────────┴──────────────┬──────────────────┘
          │                     │                          │
          └─────────────────────┼──────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     DATAVERSE BROKER SERVICE                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         OData API Layer                              │   │
│  │    POST /api/data/v9.2/ec_CreateEnvelope                            │   │
│  │    POST /api/data/v9.2/ec_SubmitEnvelope                            │   │
│  │    GET  /api/data/v9.2/ec_envelopes                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                │                                            │
│  ┌──────────────┐  ┌──────────┴───────────┐  ┌────────────────────────┐   │
│  │   Approval   │  │   Custom Actions     │  │    Power Automate      │   │
│  │   Workflow   │◄─┤   (Plugins/PCF)      │─►│    Flows               │   │
│  └──────────────┘  └──────────────────────┘  └────────────────────────┘   │
│                                │                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATAVERSE TABLES                                  │   │
│  │  ec_envelopes │ ec_signers │ ec_fields │ ec_approvals │ ec_usage    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     NINTEX ASSURESIGN API v3.7                              │
│                  (Called ONLY by Dataverse Plugins)                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Architecture Overview

### 2.1 Design Principles

1. **All Roads Lead to Dataverse** — Every e-signature request, whether from Office Add-in, Power Automate, or external API, routes through the Dataverse broker
2. **Mirror Nintex API** — The Dataverse OData endpoints accept the same payload structure as Nintex, making migration seamless
3. **Store Everything** — Documents, status updates, webhooks, and audit logs all persist in Dataverse
4. **Approve Before Send** — Cost thresholds trigger approval workflows before any Nintex API calls

### 2.2 Request Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           REQUEST LIFECYCLE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
  │  Draft   │────►│Validating│────►│ Pending  │────►│ Approved │
  │          │     │          │     │ Approval │     │          │
  └──────────┘     └──────────┘     └──────────┘     └──────────┘
                                          │                │
                                          ▼                ▼
                                    ┌──────────┐     ┌──────────┐
                                    │ Rejected │     │ Sending  │
                                    │          │     │          │
                                    └──────────┘     └──────────┘
                                                          │
       ┌──────────────────────────────────────────────────┘
       │
       ▼
  ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
  │   Sent   │────►│InProgress│────►│Completed │     │ Declined │
  │          │     │          │     │          │     │          │
  └──────────┘     └──────────┘     └──────────┘     └──────────┘
                        │                                  ▲
                        └──────────────────────────────────┘
```

### 2.3 Component Responsibilities

| Component | Responsibility |
|-----------|----------------|
| **Office Add-in** | Insert signature fields, configure signers, submit to Dataverse |
| **Dataverse Broker** | Validate requests, enforce quotas, route approvals, call Nintex API |
| **Power Automate** | Approval workflows, email notifications, status webhooks |
| **Nintex AssureSign** | Document processing, signature capture, certificate generation |
| **Azure Key Vault** | Store Nintex API credentials securely |

---

## 3. Dataverse Broker Service

### 3.1 Overview

The Dataverse Broker Service acts as the **sole gateway** between Elections Canada systems and Nintex AssureSign. No client application communicates directly with Nintex.

**Key Benefits:**

- ✅ Centralized cost tracking and budget enforcement
- ✅ Approval workflows for high-volume or high-cost requests
- ✅ Complete audit trail in Canadian data center
- ✅ Credential isolation (API keys never exposed to clients)
- ✅ Consistent error handling and retry logic
- ✅ Usage analytics and reporting

### 3.2 OData API Endpoints

The Dataverse broker exposes custom actions that mirror the Nintex API structure:

| Dataverse Action | Nintex Equivalent | Description |
|------------------|-------------------|-------------|
| `ec_CreateEnvelope` | `POST /submit/prepare` | Create envelope without sending |
| `ec_SubmitEnvelope` | `POST /submit/{id}` | Send prepared envelope |
| `ec_CreateAndSubmit` | `POST /submit` | Create and send in one call |
| `ec_CancelEnvelope` | `POST /envelopes/{id}/cancel` | Cancel pending envelope |
| `ec_GetEnvelopeStatus` | `GET /envelopes/{id}` | Get current status |
| `ec_GetSigningLinks` | `GET /envelopes/{id}/signingLinks` | Get signer URLs |
| `ec_DownloadDocument` | `GET /envelopes/{id}/documents/{docId}` | Download signed document |

### 3.3 Request Payload Structure

The broker accepts payloads identical to Nintex, enabling drop-in replacement:

```json
{
  "request": {
    "content": {
      "envelope": {
        "name": "Employment Agreement - John Smith",
        "workflowType": "custom",
        "expirationDate": "2025-02-15T23:59:59Z"
      },
      "documents": [
        {
          "name": "Employment Agreement",
          "file": {
            "fileToUpload": {
              "data": "BASE64_ENCODED_DOCUMENT_CONTENT",
              "fileName": "EmploymentAgreement.docx"
            },
            "extension": "docx"
          },
          "fields": [
            {
              "fieldType": "signature",
              "inputType": "signatory",
              "signer": "Signer 1",
              "label": "Employee Signature",
              "position": { "x": 0.15, "y": 0.75 },
              "size": { "height": 0.05, "width": 0.25 },
              "required": true,
              "pageNumber": 1
            },
            {
              "fieldType": "date",
              "inputType": "signatory",
              "signer": "Signer 1",
              "label": "Date Signed",
              "position": { "x": 0.55, "y": 0.75 },
              "size": { "height": 0.03, "width": 0.15 },
              "pageNumber": 1
            }
          ]
        }
      ],
      "signers": [
        {
          "label": "Signer 1",
          "name": "John Smith",
          "email": "john.smith@example.gc.ca",
          "signingOrder": 1,
          "authenticationMethod": "email"
        },
        {
          "label": "Signer 2",
          "name": "Jane Manager",
          "email": "jane.manager@elections.ca",
          "signingOrder": 2,
          "authenticationMethod": "email"
        }
      ],
      "steps": [
        { "name": "Employee Signs", "signers": ["Signer 1"] },
        { "name": "Manager Approves", "signers": ["Signer 2"] }
      ]
    },
    "options": {
      "signingOrder": "sequential",
      "sendEmails": true,
      "emailSubject": "Please sign: Employment Agreement",
      "emailMessage": "Please review and sign the attached employment agreement."
    }
  }
}
```

### 3.4 Dataverse Plugin Implementation

The broker is implemented as Dataverse plugins that intercept custom action calls:

```csharp
// Plugin: CreateEnvelopePlugin.cs
public class CreateEnvelopePlugin : IPlugin
{
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var service = ((IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory)))
            .CreateOrganizationService(context.UserId);
        
        // 1. Parse incoming request (Nintex-compatible payload)
        var requestPayload = context.InputParameters["RequestPayload"] as string;
        var envelopeRequest = JsonSerializer.Deserialize<EnvelopeRequest>(requestPayload);
        
        // 2. Calculate estimated cost
        var estimatedCost = CalculateCost(envelopeRequest);
        
        // 3. Check user's monthly budget
        var userBudget = GetUserBudget(service, context.UserId);
        var monthlyUsage = GetMonthlyUsage(service, context.UserId);
        
        // 4. Create envelope record in Dataverse
        var envelope = new Entity("ec_envelope")
        {
            ["ec_name"] = envelopeRequest.Content.Envelope.Name,
            ["ec_requestedby"] = new EntityReference("systemuser", context.UserId),
            ["ec_estimatedcost"] = new Money(estimatedCost),
            ["ec_signercount"] = envelopeRequest.Content.Signers.Count,
            ["ec_documentcount"] = envelopeRequest.Content.Documents.Count,
            ["ec_requestpayload"] = requestPayload,
            ["ec_status"] = new OptionSetValue((int)EnvelopeStatus.Draft)
        };
        
        // 5. Store document content
        foreach (var doc in envelopeRequest.Content.Documents)
        {
            envelope[$"ec_document_{doc.Name}"] = Convert.FromBase64String(doc.File.FileToUpload.Data);
        }
        
        var envelopeId = service.Create(envelope);
        
        // 6. Create signer records
        foreach (var signer in envelopeRequest.Content.Signers)
        {
            var signerEntity = new Entity("ec_signer")
            {
                ["ec_envelopeid"] = new EntityReference("ec_envelope", envelopeId),
                ["ec_name"] = signer.Name,
                ["ec_email"] = signer.Email,
                ["ec_signingorder"] = signer.SigningOrder,
                ["ec_label"] = signer.Label,
                ["ec_status"] = new OptionSetValue((int)SignerStatus.Pending)
            };
            service.Create(signerEntity);
        }
        
        // 7. Determine if approval is needed
        bool requiresApproval = 
            estimatedCost > userBudget.AutoApprovalLimit ||
            (monthlyUsage + estimatedCost) > userBudget.MonthlyLimit ||
            envelopeRequest.Content.Signers.Count > 10;
        
        if (requiresApproval)
        {
            // Trigger approval workflow
            envelope["ec_status"] = new OptionSetValue((int)EnvelopeStatus.PendingApproval);
            service.Update(envelope);
            
            TriggerApprovalWorkflow(service, envelopeId, estimatedCost, userBudget);
        }
        else
        {
            // Auto-approve and proceed
            envelope["ec_status"] = new OptionSetValue((int)EnvelopeStatus.Approved);
            service.Update(envelope);
        }
        
        // 8. Return envelope ID to caller
        context.OutputParameters["EnvelopeId"] = envelopeId.ToString();
        context.OutputParameters["Status"] = requiresApproval ? "PendingApproval" : "Approved";
        context.OutputParameters["EstimatedCost"] = estimatedCost;
    }
    
    private decimal CalculateCost(EnvelopeRequest request)
    {
        // Nintex pricing model (example)
        const decimal BASE_ENVELOPE_COST = 2.50m;
        const decimal PER_SIGNER_COST = 1.00m;
        const decimal PER_DOCUMENT_COST = 0.50m;
        
        return BASE_ENVELOPE_COST +
               (request.Content.Signers.Count * PER_SIGNER_COST) +
               (request.Content.Documents.Count * PER_DOCUMENT_COST);
    }
}
```

### 3.5 Submit Envelope Plugin

Once approved, this plugin sends the actual request to Nintex:

```csharp
// Plugin: SubmitEnvelopePlugin.cs
public class SubmitEnvelopePlugin : IPlugin
{
    public void Execute(IServiceProvider serviceProvider)
    {
        var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
        var service = ((IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory)))
            .CreateOrganizationService(context.UserId);
        
        var envelopeId = Guid.Parse(context.InputParameters["EnvelopeId"] as string);
        
        // 1. Retrieve envelope record
        var envelope = service.Retrieve("ec_envelope", envelopeId, new ColumnSet(true));
        
        // 2. Verify envelope is approved
        var status = ((OptionSetValue)envelope["ec_status"]).Value;
        if (status != (int)EnvelopeStatus.Approved)
        {
            throw new InvalidPluginExecutionException("Envelope must be approved before sending.");
        }
        
        // 3. Get Nintex credentials from Azure Key Vault
        var credentials = GetNintexCredentials();
        
        // 4. Authenticate with Nintex
        var nintexToken = await AuthenticateNintex(credentials);
        
        // 5. Submit to Nintex API
        var requestPayload = envelope["ec_requestpayload"] as string;
        var nintexResponse = await CallNintexApi(nintexToken, "/submit", requestPayload);
        
        // 6. Update envelope with Nintex response
        envelope["ec_nintexenvelopeid"] = nintexResponse.EnvelopeId;
        envelope["ec_status"] = new OptionSetValue((int)EnvelopeStatus.Sent);
        envelope["ec_sentdate"] = DateTime.UtcNow;
        envelope["ec_actualcost"] = new Money(nintexResponse.Cost);
        service.Update(envelope);
        
        // 7. Update usage tracking
        UpdateUsageTracking(service, context.UserId, nintexResponse.Cost);
        
        // 8. Log audit record
        CreateAuditLog(service, envelopeId, "Envelope sent to Nintex", nintexResponse);
        
        // 9. Return Nintex envelope ID
        context.OutputParameters["NintexEnvelopeId"] = nintexResponse.EnvelopeId;
        context.OutputParameters["Status"] = "Sent";
    }
    
    private NintexCredentials GetNintexCredentials()
    {
        // Retrieve from Azure Key Vault via Managed Identity
        var kvClient = new SecretClient(
            new Uri("https://ec-esign-kv.vault.azure.net/"),
            new ManagedIdentityCredential()
        );
        
        return new NintexCredentials
        {
            ApiUsername = kvClient.GetSecret("nintex-api-username").Value.Value,
            ApiKey = kvClient.GetSecret("nintex-api-key").Value.Value,
            Environment = kvClient.GetSecret("nintex-environment").Value.Value
        };
    }
}
```

---

## 4. Dataverse Schema

### 4.1 Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DATAVERSE SCHEMA                                    │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   ec_envelope    │       │    ec_signer     │       │    ec_field      │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ PK ec_envelopeid │◄──────┤ FK ec_envelopeid │       │ FK ec_envelopeid │
│    ec_name       │       │ PK ec_signerid   │◄──────┤ FK ec_signerid   │
│    ec_status     │       │    ec_name       │       │ PK ec_fieldid    │
│ FK ec_requestedby│       │    ec_email      │       │    ec_fieldtype  │
│ FK ec_approvedby │       │    ec_label      │       │    ec_label      │
│    ec_estimatedco│       │    ec_signingorde│       │    ec_position_x │
│    ec_actualcost │       │    ec_status     │       │    ec_position_y │
│    ec_nintexenvid│       │    ec_signeddate │       │    ec_width      │
│    ec_sentdate   │       │    ec_signinglink│       │    ec_height     │
│    ec_completedda│       └──────────────────┘       │    ec_pagenumber │
│    ec_documentcon│                                  │    ec_required   │
│    ec_requestpayl│                                  │    ec_color      │
└──────────────────┘                                  └──────────────────┘
         │
         │
         ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   ec_approval    │       │   ec_usage_log   │       │  ec_budget       │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ FK ec_envelopeid │       │ FK ec_envelopeid │       │ FK ec_userid     │
│ PK ec_approvalid │       │ PK ec_usagelogid │       │ PK ec_budgetid   │
│ FK ec_approver   │       │ FK ec_userid     │       │    ec_monthlylimi│
│    ec_status     │       │    ec_cost       │       │    ec_autoapprlim│
│    ec_decision   │       │    ec_date       │       │    ec_currentusag│
│    ec_comments   │       │    ec_action     │       │    ec_period     │
│    ec_requestedda│       │    ec_details    │       │ FK ec_approver   │
│    ec_decisiondat│       └──────────────────┘       └──────────────────┘
└──────────────────┘

┌──────────────────┐       ┌──────────────────┐
│ ec_notification  │       │   ec_template    │
├──────────────────┤       ├──────────────────┤
│ FK ec_envelopeid │       │ PK ec_templateid │
│ FK ec_signerid   │       │    ec_name       │
│ PK ec_notificatio│       │    ec_description│
│    ec_type       │       │    ec_content    │
│    ec_sentdate   │       │ FK ec_createdby  │
│    ec_status     │       │    ec_fields_json│
│    ec_emailaddres│       │    ec_signers_jso│
└──────────────────┘       └──────────────────┘
```

### 4.2 Table Definitions

#### ec_envelope (Envelope)

| Column | Type | Description |
|--------|------|-------------|
| `ec_envelopeid` | GUID (PK) | Unique identifier |
| `ec_name` | String (200) | Display name |
| `ec_status` | OptionSet | Draft, PendingApproval, Approved, Rejected, Sending, Sent, InProgress, Completed, Declined, Expired, Cancelled |
| `ec_requestedby` | Lookup (systemuser) | User who created request |
| `ec_approvedby` | Lookup (systemuser) | User who approved (if required) |
| `ec_estimatedcost` | Currency | Pre-calculated cost estimate |
| `ec_actualcost` | Currency | Actual cost from Nintex |
| `ec_nintexenvelopeid` | String (100) | Nintex envelope GUID |
| `ec_sentdate` | DateTime | When sent to Nintex |
| `ec_completeddate` | DateTime | When all signatures completed |
| `ec_expirationdate` | DateTime | Envelope expiry |
| `ec_documentcontent` | File | Original document (for audit) |
| `ec_signeddocument` | File | Completed signed document |
| `ec_requestpayload` | Multiline Text | Full JSON request (for debugging) |
| `ec_signingorder` | OptionSet | Sequential, Parallel |
| `ec_signercount` | Integer | Number of signers |
| `ec_documentcount` | Integer | Number of documents |
| `ec_source` | OptionSet | OfficeAddin, PowerAutomate, API, Portal |

#### ec_signer (Signer)

| Column | Type | Description |
|--------|------|-------------|
| `ec_signerid` | GUID (PK) | Unique identifier |
| `ec_envelopeid` | Lookup (ec_envelope) | Parent envelope |
| `ec_name` | String (200) | Signer full name |
| `ec_email` | String (200) | Signer email address |
| `ec_label` | String (50) | Label (e.g., "Signer 1", "Approver") |
| `ec_signingorder` | Integer | Order in sequence |
| `ec_status` | OptionSet | Pending, Sent, Viewed, Signed, Declined |
| `ec_signeddate` | DateTime | When signed |
| `ec_declineddate` | DateTime | When declined |
| `ec_declinereason` | String (500) | Decline reason |
| `ec_signinglink` | String (500) | Nintex signing URL |
| `ec_authmethod` | OptionSet | Email, SMS, KBA |
| `ec_color` | String (7) | Hex color code for field highlighting |

#### ec_field (Signature Field)

| Column | Type | Description |
|--------|------|-------------|
| `ec_fieldid` | GUID (PK) | Unique identifier |
| `ec_envelopeid` | Lookup (ec_envelope) | Parent envelope |
| `ec_signerid` | Lookup (ec_signer) | Assigned signer |
| `ec_fieldtype` | OptionSet | Signature, Initials, Date, Name, Checkbox, Text |
| `ec_label` | String (100) | Field label |
| `ec_position_x` | Decimal | X position (0-1 percentage) |
| `ec_position_y` | Decimal | Y position (0-1 percentage) |
| `ec_width` | Decimal | Width (0-1 percentage) |
| `ec_height` | Decimal | Height (0-1 percentage) |
| `ec_pagenumber` | Integer | Page number (1-based) |
| `ec_required` | Boolean | Is field required |
| `ec_color` | String (7) | Hex color for display |
| `ec_placeholder` | String (100) | Nintex placeholder text |

#### ec_approval (Approval Request)

| Column | Type | Description |
|--------|------|-------------|
| `ec_approvalid` | GUID (PK) | Unique identifier |
| `ec_envelopeid` | Lookup (ec_envelope) | Related envelope |
| `ec_approver` | Lookup (systemuser) | Assigned approver |
| `ec_status` | OptionSet | Pending, Approved, Rejected, Escalated |
| `ec_decision` | OptionSet | Approved, Rejected |
| `ec_comments` | Multiline Text | Approver comments |
| `ec_requesteddate` | DateTime | When approval requested |
| `ec_decisiondate` | DateTime | When decision made |
| `ec_estimatedcost` | Currency | Cost being approved |
| `ec_reason` | String (500) | Why approval required |

#### ec_usage_log (Usage Tracking)

| Column | Type | Description |
|--------|------|-------------|
| `ec_usagelogid` | GUID (PK) | Unique identifier |
| `ec_envelopeid` | Lookup (ec_envelope) | Related envelope |
| `ec_userid` | Lookup (systemuser) | User who sent |
| `ec_cost` | Currency | Cost of this transaction |
| `ec_date` | DateTime | Transaction date |
| `ec_action` | OptionSet | Created, Sent, Completed, Cancelled |
| `ec_details` | Multiline Text | Additional details |

#### ec_budget (User Budget)

| Column | Type | Description |
|--------|------|-------------|
| `ec_budgetid` | GUID (PK) | Unique identifier |
| `ec_userid` | Lookup (systemuser) | User this budget applies to |
| `ec_teamid` | Lookup (team) | Team this budget applies to |
| `ec_monthlylimit` | Currency | Maximum monthly spend |
| `ec_autoapprovalimit` | Currency | Auto-approve up to this amount |
| `ec_currentusage` | Currency | Current month usage |
| `ec_period` | String (7) | Period (YYYY-MM) |
| `ec_approver` | Lookup (systemuser) | Default approver when limit exceeded |
| `ec_envelopelimit` | Integer | Max envelopes per month |
| `ec_signerlimit` | Integer | Max signers per envelope |

### 4.3 Status Option Sets

#### Envelope Status (ec_envelope_status)

| Value | Label | Description |
|-------|-------|-------------|
| 1 | Draft | Created but not submitted |
| 2 | Validating | Being validated by broker |
| 3 | PendingApproval | Awaiting manager approval |
| 4 | Approved | Approved and ready to send |
| 5 | Rejected | Approval denied |
| 6 | Sending | Being sent to Nintex |
| 7 | Sent | Successfully sent to Nintex |
| 8 | InProgress | At least one signer has signed |
| 9 | Completed | All signers have signed |
| 10 | Declined | Signer declined |
| 11 | Expired | Passed expiration date |
| 12 | Cancelled | Cancelled by sender |
| 13 | Error | Error occurred |

#### Signer Status (ec_signer_status)

| Value | Label | Description |
|-------|-------|-------------|
| 1 | Pending | Not yet sent |
| 2 | Sent | Email sent, awaiting action |
| 3 | Viewed | Opened signing link |
| 4 | Signed | Completed signing |
| 5 | Declined | Declined to sign |

---

## 5. Approval Workflow & Cost Controls

### 5.1 Approval Thresholds

The system enforces approval workflows based on configurable thresholds:

| Threshold Type | Default Value | Trigger |
|----------------|---------------|---------|
| Single Envelope Cost | $50.00 | Envelope cost exceeds limit |
| Monthly Budget | $500.00 | Monthly total would exceed limit |
| Signer Count | 10 | Envelope has more than X signers |
| Bulk Send | 25 | Sending more than X envelopes at once |
| External Recipients | 5 | More than X external (non-.gc.ca) signers |

### 5.2 Cost Calculation

```javascript
// Cost calculation formula
function calculateEnvelopeCost(envelope) {
  const PRICING = {
    baseEnvelope: 2.50,      // Base cost per envelope
    perSigner: 1.00,         // Per signer
    perDocument: 0.50,       // Per document
    perPage: 0.10,           // Per page over 10
    smsAuth: 0.25,           // SMS authentication
    kbaAuth: 2.00,           // Knowledge-based auth
    reminder: 0.10,          // Per reminder sent
    inPersonSigning: 5.00    // In-person signing session
  };
  
  let cost = PRICING.baseEnvelope;
  
  // Signer costs
  envelope.signers.forEach(signer => {
    cost += PRICING.perSigner;
    if (signer.authMethod === 'sms') cost += PRICING.smsAuth;
    if (signer.authMethod === 'kba') cost += PRICING.kbaAuth;
  });
  
  // Document costs
  envelope.documents.forEach(doc => {
    cost += PRICING.perDocument;
    if (doc.pageCount > 10) {
      cost += (doc.pageCount - 10) * PRICING.perPage;
    }
  });
  
  return cost;
}
```

### 5.3 Power Automate Approval Flow

```yaml
# Power Automate Flow Definition
name: EC-ESign-Approval-Workflow
trigger:
  type: dataverse
  table: ec_envelope
  event: create
  filter: "ec_status eq 3" # PendingApproval

actions:
  - name: Get Envelope Details
    type: Dataverse.GetRow
    inputs:
      table: ec_envelope
      rowId: "@{triggerOutputs()?['body/ec_envelopeid']}"
      
  - name: Get Requester Details
    type: Dataverse.GetRow
    inputs:
      table: systemuser
      rowId: "@{outputs('Get_Envelope_Details')?['body/_ec_requestedby_value']}"
      
  - name: Get Approver
    type: Dataverse.GetRow
    inputs:
      table: ec_budget
      filter: "_ec_userid_value eq '@{outputs('Get_Requester_Details')?['body/systemuserid']}'"
      
  - name: Calculate Budget Status
    type: Compose
    inputs:
      currentUsage: "@{outputs('Get_Approver')?['body/ec_currentusage']}"
      monthlyLimit: "@{outputs('Get_Approver')?['body/ec_monthlylimit']}"
      percentUsed: "@{mul(div(outputs('Get_Approver')?['body/ec_currentusage'], outputs('Get_Approver')?['body/ec_monthlylimit']), 100)}"
      
  - name: Send Approval Request
    type: Approvals.CreateAndWait
    inputs:
      approvalType: Basic
      title: "E-Sign Approval Required: @{outputs('Get_Envelope_Details')?['body/ec_name']}"
      assignedTo: "@{outputs('Get_Approver')?['body/_ec_approver_value']}"
      details: |
        ## E-Signature Approval Request
        
        **Requester:** @{outputs('Get_Requester_Details')?['body/fullname']}
        **Document:** @{outputs('Get_Envelope_Details')?['body/ec_name']}
        **Signers:** @{outputs('Get_Envelope_Details')?['body/ec_signercount']}
        
        ### Cost Information
        | Item | Value |
        |------|-------|
        | Estimated Cost | $@{outputs('Get_Envelope_Details')?['body/ec_estimatedcost']} |
        | Monthly Budget | $@{outputs('Calculate_Budget_Status')?['monthlyLimit']} |
        | Current Usage | $@{outputs('Calculate_Budget_Status')?['currentUsage']} |
        | Budget Used | @{outputs('Calculate_Budget_Status')?['percentUsed']}% |
        
        ### Approval Reason
        @{outputs('Get_Envelope_Details')?['body/ec_approvalreason']}
      itemLink: "@{concat('https://org.crm3.dynamics.com/main.aspx?etn=ec_envelope&id=', outputs('Get_Envelope_Details')?['body/ec_envelopeid'])}"
      
  - name: Condition - Approved?
    type: Condition
    expression: "@equals(outputs('Send_Approval_Request')?['body/outcome'], 'Approve')"
    ifTrue:
      - name: Update Envelope - Approved
        type: Dataverse.UpdateRow
        inputs:
          table: ec_envelope
          rowId: "@{triggerOutputs()?['body/ec_envelopeid']}"
          ec_status: 4  # Approved
          ec_approvedby: "@{outputs('Send_Approval_Request')?['body/responder/userId']}"
          
      - name: Trigger Submit Envelope
        type: Dataverse.PerformBoundAction
        inputs:
          table: ec_envelope
          rowId: "@{triggerOutputs()?['body/ec_envelopeid']}"
          actionName: ec_SubmitEnvelope
          
    ifFalse:
      - name: Update Envelope - Rejected
        type: Dataverse.UpdateRow
        inputs:
          table: ec_envelope
          rowId: "@{triggerOutputs()?['body/ec_envelopeid']}"
          ec_status: 5  # Rejected
          
      - name: Send Rejection Notification
        type: Office365Outlook.SendEmail
        inputs:
          to: "@{outputs('Get_Requester_Details')?['body/internalemailaddress']}"
          subject: "E-Sign Request Rejected: @{outputs('Get_Envelope_Details')?['body/ec_name']}"
          body: |
            Your e-signature request has been rejected.
            
            **Document:** @{outputs('Get_Envelope_Details')?['body/ec_name']}
            **Rejected By:** @{outputs('Send_Approval_Request')?['body/responder/displayName']}
            **Reason:** @{outputs('Send_Approval_Request')?['body/comments']}
```

### 5.4 Approval Card (Teams/Email)

The approval request appears as an Adaptive Card:

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "Container",
      "style": "emphasis",
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "auto",
              "items": [
                {
                  "type": "Image",
                  "url": "https://elections.ca/icons/esign.png",
                  "size": "Small"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "E-Signature Approval Required",
                  "weight": "Bolder",
                  "size": "Medium"
                },
                {
                  "type": "TextBlock",
                  "text": "Employment Agreement - John Smith",
                  "spacing": "None",
                  "isSubtle": true
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "items": [
        {
          "type": "FactSet",
          "facts": [
            { "title": "Requester", "value": "Jane Doe" },
            { "title": "Recipients", "value": "3 signers" },
            { "title": "Estimated Cost", "value": "$12.50" }
          ]
        }
      ]
    },
    {
      "type": "Container",
      "items": [
        {
          "type": "TextBlock",
          "text": "Budget Status",
          "weight": "Bolder"
        },
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "$487.50 / $500.00",
                  "size": "Small"
                },
                {
                  "type": "ProgressBar",
                  "value": 97,
                  "color": "attention"
                }
              ]
            }
          ]
        },
        {
          "type": "TextBlock",
          "text": "⚠️ This request will exceed monthly budget",
          "color": "Attention",
          "size": "Small"
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "✓ Approve",
      "style": "positive",
      "data": { "action": "approve" }
    },
    {
      "type": "Action.Submit",
      "title": "✕ Reject",
      "style": "destructive",
      "data": { "action": "reject" }
    },
    {
      "type": "Action.OpenUrl",
      "title": "View Details",
      "url": "https://org.crm3.dynamics.com/main.aspx?etn=ec_envelope&id=..."
    }
  ]
}
```

---

## 6. Office Add-in Implementation

### 6.1 Manifest Configuration (UTF-8 Icons)

The manifest uses built-in Office icons and UTF-8 characters instead of hosted images:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<OfficeApp xmlns="http://schemas.microsoft.com/office/appforoffice/1.1"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:bt="http://schemas.microsoft.com/office/officeappbasictypes/1.0"
           xsi:type="TaskPaneApp">

  <Id>ec-nintex-esign-00001</Id>
  <Version>2.0.0.0</Version>
  <ProviderName>Elections Canada</ProviderName>
  <DefaultLocale>en-CA</DefaultLocale>
  <DisplayName DefaultValue="E-Sign"/>
  <Description DefaultValue="Send documents for electronic signature via Elections Canada's secure e-signature service."/>
  
  <!-- Use data URIs for icons (no external hosting needed) -->
  <IconUrl DefaultValue="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0..."/>
  <HighResolutionIconUrl DefaultValue="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFAAAABQCAYAAACOEfKt..."/>
  
  <SupportUrl DefaultValue="https://support.elections.ca"/>
  
  <AppDomains>
    <AppDomain>https://org.crm3.dynamics.com</AppDomain>
    <AppDomain>https://ec-esign.azurewebsites.net</AppDomain>
  </AppDomains>
  
  <Hosts>
    <Host Name="Document"/>
    <Host Name="Workbook"/>
  </Hosts>
  
  <Requirements>
    <Sets>
      <Set Name="WordApi" MinVersion="1.3"/>
    </Sets>
  </Requirements>
  
  <DefaultSettings>
    <SourceLocation DefaultValue="https://ec-esign.azurewebsites.net/taskpane.html"/>
  </DefaultSettings>
  
  <Permissions>ReadWriteDocument</Permissions>

  <VersionOverrides xmlns="http://schemas.microsoft.com/office/taskpaneappversionoverrides" xsi:type="VersionOverridesV1_0">
    <Hosts>
      <Host xsi:type="Document">
        <DesktopFormFactor>
          <FunctionFile resid="Commands.Url"/>
          
          <ExtensionPoint xsi:type="PrimaryCommandSurface">
            <OfficeTab id="TabHome">
              <Group id="ESignGroup" insertAfterMso="GroupEditing">
                <Label resid="GroupLabel"/>
                
                <!-- Main Menu using built-in Office icon -->
                <Control xsi:type="Menu" id="ESignMenu">
                  <Label resid="MenuLabel"/>
                  <Tooltip resid="MenuTooltip"/>
                  <Supertip>
                    <Title resid="MenuLabel"/>
                    <Description resid="MenuTooltip"/>
                  </Supertip>
                  <Icon>
                    <bt:Image size="16" resid="Icon16"/>
                    <bt:Image size="32" resid="Icon32"/>
                    <bt:Image size="80" resid="Icon80"/>
                  </Icon>
                  
                  <Items>
                    <!-- Insert Signature Field -->
                    <Item id="InsertSignature">
                      <Label resid="SignatureLabel"/>
                      <Tooltip resid="SignatureTooltip"/>
                      <Icon>
                        <bt:Image size="16" resid="SigIcon16"/>
                        <bt:Image size="32" resid="SigIcon32"/>
                        <bt:Image size="80" resid="SigIcon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>insertSignatureField</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Insert Initials Field -->
                    <Item id="InsertInitials">
                      <Label resid="InitialsLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="InitIcon16"/>
                        <bt:Image size="32" resid="InitIcon32"/>
                        <bt:Image size="80" resid="InitIcon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>insertInitialsField</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Insert Date Field -->
                    <Item id="InsertDate">
                      <Label resid="DateLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="DateIcon16"/>
                        <bt:Image size="32" resid="DateIcon32"/>
                        <bt:Image size="80" resid="DateIcon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>insertDateField</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Insert Name Field -->
                    <Item id="InsertName">
                      <Label resid="NameLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="NameIcon16"/>
                        <bt:Image size="32" resid="NameIcon32"/>
                        <bt:Image size="80" resid="NameIcon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>insertNameField</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Insert Checkbox Field -->
                    <Item id="InsertCheckbox">
                      <Label resid="CheckboxLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="CheckIcon16"/>
                        <bt:Image size="32" resid="CheckIcon32"/>
                        <bt:Image size="80" resid="CheckIcon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>insertCheckboxField</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Insert Text Field -->
                    <Item id="InsertText">
                      <Label resid="TextLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="TextIcon16"/>
                        <bt:Image size="32" resid="TextIcon32"/>
                        <bt:Image size="80" resid="TextIcon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>insertTextField</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Separator -->
                    <Item id="Sep1">
                      <Label resid="SepLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="Icon16"/>
                        <bt:Image size="32" resid="Icon32"/>
                        <bt:Image size="80" resid="Icon80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>noOp</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Manage Fields -->
                    <Item id="ManageFields">
                      <Label resid="ManageLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="ManageIcon16"/>
                        <bt:Image size="32" resid="ManageIcon32"/>
                        <bt:Image size="80" resid="ManageIcon80"/>
                      </Icon>
                      <Action xsi:type="ShowTaskpane">
                        <TaskpaneId>ManagePane</TaskpaneId>
                        <SourceLocation resid="ManagePane.Url"/>
                      </Action>
                    </Item>
                    
                    <!-- Send for Signature -->
                    <Item id="SendEnvelope">
                      <Label resid="SendLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="SendIcon16"/>
                        <bt:Image size="32" resid="SendIcon32"/>
                        <bt:Image size="80" resid="SendIcon80"/>
                      </Icon>
                      <Action xsi:type="ShowTaskpane">
                        <TaskpaneId>SendPane</TaskpaneId>
                        <SourceLocation resid="SendPane.Url"/>
                      </Action>
                    </Item>
                    
                    <!-- View Status -->
                    <Item id="ViewStatus">
                      <Label resid="StatusLabel"/>
                      <Icon>
                        <bt:Image size="16" resid="StatusIcon16"/>
                        <bt:Image size="32" resid="StatusIcon32"/>
                        <bt:Image size="80" resid="StatusIcon80"/>
                      </Icon>
                      <Action xsi:type="ShowTaskpane">
                        <TaskpaneId>StatusPane</TaskpaneId>
                        <SourceLocation resid="StatusPane.Url"/>
                      </Action>
                    </Item>
                  </Items>
                </Control>
              </Group>
            </OfficeTab>
          </ExtensionPoint>
        </DesktopFormFactor>
      </Host>
    </Hosts>
    
    <Resources>
      <!-- SVG Data URIs for icons (no external hosting) -->
      <bt:Images>
        <!-- Main icon - Signature symbol -->
        <bt:Image id="Icon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBmaWxsPSIjMDA3OGQ0IiBkPSJNMiAxNGgxMnYxSDJ6TTMuNSA5LjVsMi0yIDEgMSAzLTMgMS41IDEuNS0xIDEtLjUuNS0zIDMtMSAxeiIvPjwvc3ZnPg=="/>
        <bt:Image id="Icon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgdmlld0JveD0iMCAwIDMyIDMyIj48cGF0aCBmaWxsPSIjMDA3OGQ0IiBkPSJNNCAyOGgyNHYySDR6TTcgMTlsNC00IDIgMiA2LTYgMyAzLTIgMi0xIDEtNiA2LTIgMnoiLz48L3N2Zz4="/>
        <bt:Image id="Icon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgdmlld0JveD0iMCAwIDgwIDgwIj48cGF0aCBmaWxsPSIjMDA3OGQ0IiBkPSJNMTAgNzBoNjB2NUgxMHpNMTcuNSA0Ny41bDEwLTEwIDUgNSAxNS0xNSA3LjUgNy41LTUgNS0yLjUgMi41LTE1IDE1LTUgNXoiLz48L3N2Zz4="/>
        
        <!-- Signature field icon -->
        <bt:Image id="SigIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBmaWxsPSIjMTA3YzEwIiBkPSJNMiAxNGgxMnYxSDJ6TTMgOS41bDItMiAxIDEgMy0zIDEuNSAxLjUtMSAxLS41LjUtMyAzLTEgMXoiLz48L3N2Zz4="/>
        <bt:Image id="SigIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHBhdGggZmlsbD0iIzEwN2MxMCIgZD0iTTQgMjhoMjR2Mkg0ek03IDE5bDQtNCAyIDIgNi02IDMgMy0yIDItMSAxLTYgNi0yIDJ6Ii8+PC9zdmc+"/>
        <bt:Image id="SigIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHBhdGggZmlsbD0iIzEwN2MxMCIgZD0iTTEwIDcwaDYwdjVIMTB6TTE3LjUgNDcuNWwxMC0xMCA1IDUgMTUtMTUgNy41IDcuNS01IDUtMi41IDIuNS0xNSAxNS01IDV6Ii8+PC9zdmc+"/>
        
        <!-- Other icons follow same pattern... -->
        <bt:Image id="InitIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHRleHQgeD0iNCIgeT0iMTIiIGZvbnQtc2l6ZT0iMTAiIGZpbGw9IiMwMDc4ZDQiPkFCPC90ZXh0Pjwvc3ZnPg=="/>
        <bt:Image id="InitIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHRleHQgeD0iNCIgeT0iMjQiIGZvbnQtc2l6ZT0iMjAiIGZpbGw9IiMwMDc4ZDQiPkFCPC90ZXh0Pjwvc3ZnPg=="/>
        <bt:Image id="InitIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHRleHQgeD0iMTAiIHk9IjYwIiBmb250LXNpemU9IjUwIiBmaWxsPSIjMDA3OGQ0Ij5BQjwvdGV4dD48L3N2Zz4="/>
        
        <bt:Image id="DateIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHJlY3QgeD0iMiIgeT0iMyIgd2lkdGg9IjEyIiBoZWlnaHQ9IjExIiByeD0iMSIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjEuNSIvPjxwYXRoIGQ9Ik0yIDZoMTIiIHN0cm9rZT0iIzAwNzhkNCIvPjx0ZXh0IHg9IjUiIHk9IjEyIiBmb250LXNpemU9IjYiIGZpbGw9IiMwMDc4ZDQiPjE1PC90ZXh0Pjwvc3ZnPg=="/>
        <bt:Image id="DateIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHJlY3QgeD0iNCIgeT0iNiIgd2lkdGg9IjI0IiBoZWlnaHQ9IjIyIiByeD0iMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjIiLz48cGF0aCBkPSJNNCAxMmgyNCIgc3Ryb2tlPSIjMDA3OGQ0Ii8+PHRleHQgeD0iMTAiIHk9IjI0IiBmb250LXNpemU9IjEyIiBmaWxsPSIjMDA3OGQ0Ij4xNTwvdGV4dD48L3N2Zz4="/>
        <bt:Image id="DateIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHJlY3QgeD0iMTAiIHk9IjE1IiB3aWR0aD0iNjAiIGhlaWdodD0iNTUiIHJ4PSI1IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDc4ZDQiIHN0cm9rZS13aWR0aD0iNCIvPjxwYXRoIGQ9Ik0xMCAzMGg2MCIgc3Ryb2tlPSIjMDA3OGQ0Ii8+PHRleHQgeD0iMjUiIHk9IjYwIiBmb250LXNpemU9IjMwIiBmaWxsPSIjMDA3OGQ0Ij4xNTwvdGV4dD48L3N2Zz4="/>
        
        <bt:Image id="NameIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PGNpcmNsZSBjeD0iOCIgY3k9IjUiIHI9IjMiIGZpbGw9IiMwMDc4ZDQiLz48cGF0aCBkPSJNMyAxNGMwLTMgMi01IDUtNXM1IDIgNSA1IiBmaWxsPSIjMDA3OGQ0Ii8+PC9zdmc+"/>
        <bt:Image id="NameIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PGNpcmNsZSBjeD0iMTYiIGN5PSIxMCIgcj0iNiIgZmlsbD0iIzAwNzhkNCIvPjxwYXRoIGQ9Ik02IDI4YzAtNiA0LTEwIDEwLTEwczEwIDQgMTAgMTAiIGZpbGw9IiMwMDc4ZDQiLz48L3N2Zz4="/>
        <bt:Image id="NameIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PGNpcmNsZSBjeD0iNDAiIGN5PSIyNSIgcj0iMTUiIGZpbGw9IiMwMDc4ZDQiLz48cGF0aCBkPSJNMTUgNzBjMC0xNSAxMC0yNSAyNS0yNXMyNSAxMCAyNSAyNSIgZmlsbD0iIzAwNzhkNCIvPjwvc3ZnPg=="/>
        
        <bt:Image id="CheckIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHJlY3QgeD0iMiIgeT0iMiIgd2lkdGg9IjEyIiBoZWlnaHQ9IjEyIiByeD0iMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjEuNSIvPjxwYXRoIGQ9Ik00IDhsMyAzIDUtNiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjEuNSIvPjwvc3ZnPg=="/>
        <bt:Image id="CheckIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHJlY3QgeD0iNCIgeT0iNCIgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiByeD0iNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjIiLz48cGF0aCBkPSJNOCAxNmw2IDYgMTAtMTIiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSIyIi8+PC9zdmc+"/>
        <bt:Image id="CheckIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHJlY3QgeD0iMTAiIHk9IjEwIiB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHJ4PSIxMCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjQiLz48cGF0aCBkPSJNMjAgNDBsMTUgMTUgMjUtMzAiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSI0Ii8+PC9zdmc+"/>
        
        <bt:Image id="TextIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHJlY3QgeD0iMiIgeT0iNCIgd2lkdGg9IjEyIiBoZWlnaHQ9IjgiIHJ4PSIxIiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDc4ZDQiIHN0cm9rZS13aWR0aD0iMS41Ii8+PHBhdGggZD0iTTQgOGg4IiBzdHJva2U9IiMwMDc4ZDQiLz48L3N2Zz4="/>
        <bt:Image id="TextIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHJlY3QgeD0iNCIgeT0iOCIgd2lkdGg9IjI0IiBoZWlnaHQ9IjE2IiByeD0iMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjIiLz48cGF0aCBkPSJNOCAxNmgxNiIgc3Ryb2tlPSIjMDA3OGQ0Ii8+PC9zdmc+"/>
        <bt:Image id="TextIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHJlY3QgeD0iMTAiIHk9IjIwIiB3aWR0aD0iNjAiIGhlaWdodD0iNDAiIHJ4PSI1IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDc4ZDQiIHN0cm9rZS13aWR0aD0iNCIvPjxwYXRoIGQ9Ik0yMCA0MGg0MCIgc3Ryb2tlPSIjMDA3OGQ0Ii8+PC9zdmc+"/>
        
        <bt:Image id="ManageIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHBhdGggZD0iTTggMWw2IDMuNXY3TDggMTUgMiAxMS41di03eiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDA3OGQ0IiBzdHJva2Utd2lkdGg9IjEuNSIvPjxjaXJjbGUgY3g9IjgiIGN5PSI4IiByPSIyIiBmaWxsPSIjMDA3OGQ0Ii8+PC9zdmc+"/>
        <bt:Image id="ManageIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHBhdGggZD0iTTE2IDJsMTIgN3YxNEwxNiAzMCA0IDIzVjl6IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDc4ZDQiIHN0cm9rZS13aWR0aD0iMiIvPjxjaXJjbGUgY3g9IjE2IiBjeT0iMTYiIHI9IjQiIGZpbGw9IiMwMDc4ZDQiLz48L3N2Zz4="/>
        <bt:Image id="ManageIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHBhdGggZD0iTTQwIDVsMzAgMTcuNXYzNUw0MCA3NSAxMCA1Ny41di0zNXoiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSI0Ii8+PGNpcmNsZSBjeD0iNDAiIGN5PSI0MCIgcj0iMTAiIGZpbGw9IiMwMDc4ZDQiLz48L3N2Zz4="/>
        
        <bt:Image id="SendIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHBhdGggZD0iTTIgMmwxMiA2LTEyIDZWOWw4LTEtOC0xeiIgZmlsbD0iIzEwN2MxMCIvPjwvc3ZnPg=="/>
        <bt:Image id="SendIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHBhdGggZD0iTTQgNGwyNCAxMi0yNCAxMlYxOGwxNi0yLTE2LTJ6IiBmaWxsPSIjMTA3YzEwIi8+PC9zdmc+"/>
        <bt:Image id="SendIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PHBhdGggZD0iTTEwIDEwbDYwIDMwLTYwIDMwVjQ1bDQwLTUtNDAtNXoiIGZpbGw9IiMxMDdjMTAiLz48L3N2Zz4="/>
        
        <bt:Image id="StatusIcon16" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PGNpcmNsZSBjeD0iOCIgY3k9IjgiIHI9IjYiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSIxLjUiLz48cGF0aCBkPSJNOCA0djRsMyAyIiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDc4ZDQiIHN0cm9rZS13aWR0aD0iMS41Ii8+PC9zdmc+"/>
        <bt:Image id="StatusIcon32" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PGNpcmNsZSBjeD0iMTYiIGN5PSIxNiIgcj0iMTIiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSIyIi8+PHBhdGggZD0iTTE2IDh2OGw2IDQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSIyIi8+PC9zdmc+"/>
        <bt:Image id="StatusIcon80" DefaultValue="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCI+PGNpcmNsZSBjeD0iNDAiIGN5PSI0MCIgcj0iMzAiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzAwNzhkNCIgc3Ryb2tlLXdpZHRoPSI0Ii8+PHBhdGggZD0iTTQwIDIwdjIwbDE1IDEwIiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDc4ZDQiIHN0cm9rZS13aWR0aD0iNCIvPjwvc3ZnPg=="/>
      </bt:Images>
      
      <bt:Urls>
        <bt:Url id="Commands.Url" DefaultValue="https://ec-esign.azurewebsites.net/commands.html"/>
        <bt:Url id="ManagePane.Url" DefaultValue="https://ec-esign.azurewebsites.net/manage.html"/>
        <bt:Url id="SendPane.Url" DefaultValue="https://ec-esign.azurewebsites.net/send.html"/>
        <bt:Url id="StatusPane.Url" DefaultValue="https://ec-esign.azurewebsites.net/status.html"/>
      </bt:Urls>
      
      <bt:ShortStrings>
        <bt:String id="GroupLabel" DefaultValue="E-Sign"/>
        <bt:String id="MenuLabel" DefaultValue="✍️ E-Sign"/>
        <bt:String id="SignatureLabel" DefaultValue="✍️ Signature"/>
        <bt:String id="InitialsLabel" DefaultValue="🔤 Initials"/>
        <bt:String id="DateLabel" DefaultValue="📅 Date"/>
        <bt:String id="NameLabel" DefaultValue="👤 Name"/>
        <bt:String id="CheckboxLabel" DefaultValue="☑️ Checkbox"/>
        <bt:String id="TextLabel" DefaultValue="📝 Text Input"/>
        <bt:String id="SepLabel" DefaultValue="─────────"/>
        <bt:String id="ManageLabel" DefaultValue="⚙️ Manage Fields"/>
        <bt:String id="SendLabel" DefaultValue="📤 Send for Signature"/>
        <bt:String id="StatusLabel" DefaultValue="📊 View Status"/>
      </bt:ShortStrings>
      
      <bt:LongStrings>
        <bt:String id="MenuTooltip" DefaultValue="Insert signature fields and send documents for electronic signature"/>
        <bt:String id="SignatureTooltip" DefaultValue="Insert a signature capture field"/>
      </bt:LongStrings>
    </Resources>
  </VersionOverrides>
</OfficeApp>
```

### 6.2 Main Task Pane (manage.html)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>E-Sign Field Manager</title>
  <script src="https://appsforoffice.microsoft.com/lib/1.1/hosted/office.js"></script>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="container">
    
    <!-- Header -->
    <header class="header">
      <h1>✍️ E-Sign</h1>
      <p>Manage signature fields</p>
    </header>
    
    <!-- Insert Field Section -->
    <section class="section">
      <h2>📋 Insert Field</h2>
      <p class="hint">Click to insert at cursor position, then configure</p>
      
      <div class="field-grid">
        <button class="field-btn" onclick="insertField('signature')">
          <span class="field-icon">✍️</span>
          <span class="field-label">Signature</span>
        </button>
        <button class="field-btn" onclick="insertField('initials')">
          <span class="field-icon">🔤</span>
          <span class="field-label">Initials</span>
        </button>
        <button class="field-btn" onclick="insertField('date')">
          <span class="field-icon">📅</span>
          <span class="field-label">Date</span>
        </button>
        <button class="field-btn" onclick="insertField('name')">
          <span class="field-icon">👤</span>
          <span class="field-label">Name</span>
        </button>
        <button class="field-btn" onclick="insertField('checkbox')">
          <span class="field-icon">☑️</span>
          <span class="field-label">Checkbox</span>
        </button>
        <button class="field-btn" onclick="insertField('text')">
          <span class="field-icon">📝</span>
          <span class="field-label">Text</span>
        </button>
      </div>
    </section>
    
    <!-- Document Fields Section -->
    <section class="section">
      <h2>
        📄 Document Fields
        <button class="btn-icon" onclick="refreshFields()" title="Refresh">🔄</button>
      </h2>
      
      <div id="fieldsContainer" class="fields-list">
        <div class="empty-state">
          <span class="empty-icon">📄</span>
          <p>No fields added yet</p>
          <span class="empty-hint">Click a field type above to insert</span>
        </div>
      </div>
    </section>
    
    <!-- Signer Legend -->
    <section class="section" id="signerLegend" style="display: none;">
      <h2>👥 Signers</h2>
      <div id="signerList" class="signer-legend"></div>
    </section>
    
    <!-- Actions -->
    <section class="section actions-section">
      <button class="btn btn-primary btn-full" onclick="openSendPane()">
        📤 Send for Signature
      </button>
    </section>
    
  </div>
  
  <!-- Configure Field Modal -->
  <div id="configModal" class="modal" style="display: none;">
    <div class="modal-backdrop" onclick="closeConfigModal()"></div>
    <div class="modal-content">
      <div class="modal-header">
        <h3>⚙️ Configure Field</h3>
        <button class="btn-close" onclick="closeConfigModal()">✕</button>
      </div>
      <div class="modal-body">
        
        <!-- Signer Assignment -->
        <div class="form-group">
          <label>Assign to Signer</label>
          <div class="signer-selector">
            <button class="btn-stepper" onclick="decrementSigner()">−</button>
            <input type="number" id="signerNumber" value="1" min="1" max="99">
            <button class="btn-stepper" onclick="incrementSigner()">+</button>
          </div>
          <div class="signer-preview" id="signerPreview">
            <span class="signer-color" id="signerColorPreview"></span>
            <span id="signerLabelPreview">Signer 1</span>
          </div>
        </div>
        
        <!-- Signer Details (collapsible) -->
        <details class="signer-details">
          <summary>Signer Details (optional)</summary>
          <div class="form-group">
            <label for="signerName">Name</label>
            <input type="text" id="signerName" placeholder="e.g., John Smith">
          </div>
          <div class="form-group">
            <label for="signerEmail">Email</label>
            <input type="email" id="signerEmail" placeholder="e.g., john.smith@example.gc.ca">
          </div>
        </details>
        
        <!-- Field Options -->
        <div class="form-group">
          <label for="fieldLabel">Field Label</label>
          <input type="text" id="fieldLabel" placeholder="e.g., Employee Signature">
        </div>
        
        <div class="form-group">
          <label class="checkbox-label">
            <input type="checkbox" id="fieldRequired" checked>
            Required field
          </label>
        </div>
        
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" onclick="closeConfigModal()">Cancel</button>
        <button class="btn btn-primary" onclick="applyFieldConfig()">✓ Apply</button>
      </div>
    </div>
  </div>
  
  <script src="manage.js"></script>
</body>
</html>
```

### 6.3 Styles (styles.css)

```css
/* ============================================
   Elections Canada E-Sign Add-in Styles
   ============================================ */

:root {
  /* Colors */
  --primary: #0078d4;
  --primary-dark: #005a9e;
  --success: #107c10;
  --warning: #ffb900;
  --danger: #d13438;
  --neutral-10: #faf9f8;
  --neutral-20: #f3f2f1;
  --neutral-30: #edebe9;
  --neutral-60: #8a8886;
  --neutral-90: #323130;
  --neutral-100: #201f1e;
  
  /* Signer Colors */
  --signer-1: #FFE699;
  --signer-1-dark: #BF9000;
  --signer-2: #9BC2E6;
  --signer-2-dark: #2F75B5;
  --signer-3: #A9D08E;
  --signer-3-dark: #548235;
  --signer-4: #F4B084;
  --signer-4-dark: #C65911;
  --signer-5: #BD9EC1;
  --signer-5-dark: #7B4E8C;
  --signer-6: #FFC0CB;
  --signer-6-dark: #C76173;
  --signer-7: #8DDAC1;
  --signer-7-dark: #279178;
  --signer-8: #FFD9B3;
  --signer-8-dark: #C58141;
  --signer-9: #B0C4DE;
  --signer-9-dark: #4F709C;
  --signer-10: #D8BFD8;
  --signer-10-dark: #946794;
  
  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  
  /* Typography */
  --font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-size-sm: 12px;
  --font-size-md: 14px;
  --font-size-lg: 16px;
  --font-size-xl: 20px;
  
  /* Borders */
  --border-radius: 4px;
  --border-radius-lg: 8px;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: var(--font-family);
  font-size: var(--font-size-md);
  color: var(--neutral-90);
  background: var(--neutral-10);
  line-height: 1.5;
}

/* Container */
.container {
  padding: var(--spacing-md);
  max-width: 400px;
  margin: 0 auto;
}

/* Header */
.header {
  text-align: center;
  margin-bottom: var(--spacing-lg);
  padding-bottom: var(--spacing-md);
  border-bottom: 1px solid var(--neutral-30);
}

.header h1 {
  font-size: var(--font-size-xl);
  font-weight: 600;
  color: var(--primary);
  margin-bottom: var(--spacing-xs);
}

.header p {
  font-size: var(--font-size-sm);
  color: var(--neutral-60);
}

/* Sections */
.section {
  margin-bottom: var(--spacing-lg);
}

.section h2 {
  font-size: var(--font-size-lg);
  font-weight: 600;
  margin-bottom: var(--spacing-sm);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.hint {
  font-size: var(--font-size-sm);
  color: var(--neutral-60);
  margin-bottom: var(--spacing-md);
}

/* Field Grid */
.field-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-sm);
}

.field-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-md);
  border: 1px solid var(--neutral-30);
  border-radius: var(--border-radius-lg);
  background: white;
  cursor: pointer;
  transition: all 0.15s ease;
}

.field-btn:hover {
  border-color: var(--primary);
  background: var(--neutral-20);
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.field-btn:active {
  transform: translateY(0);
}

.field-icon {
  font-size: 24px;
  margin-bottom: var(--spacing-xs);
}

.field-label {
  font-size: var(--font-size-sm);
  font-weight: 500;
}

/* Fields List */
.fields-list {
  background: white;
  border: 1px solid var(--neutral-30);
  border-radius: var(--border-radius);
  min-height: 120px;
  max-height: 300px;
  overflow-y: auto;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-xl);
  color: var(--neutral-60);
}

.empty-icon {
  font-size: 32px;
  margin-bottom: var(--spacing-sm);
  opacity: 0.5;
}

.empty-state p {
  font-weight: 500;
}

.empty-hint {
  font-size: var(--font-size-sm);
}

/* Field Item */
.field-item {
  display: flex;
  align-items: center;
  padding: var(--spacing-sm) var(--spacing-md);
  border-bottom: 1px solid var(--neutral-30);
  cursor: pointer;
  transition: background 0.1s ease;
}

.field-item:last-child {
  border-bottom: none;
}

.field-item:hover {
  background: var(--neutral-20);
}

.field-item-color {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: var(--spacing-sm);
  border: 2px solid;
}

.field-item-info {
  flex: 1;
}

.field-item-type {
  font-weight: 500;
  font-size: var(--font-size-sm);
}

.field-item-signer {
  font-size: var(--font-size-sm);
  color: var(--neutral-60);
}

.field-item-actions {
  display: flex;
  gap: var(--spacing-xs);
}

/* Signer Legend */
.signer-legend {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-sm);
}

.signer-badge {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: 20px;
  font-size: var(--font-size-sm);
  font-weight: 500;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  border: none;
  border-radius: var(--border-radius);
  font-family: var(--font-family);
  font-size: var(--font-size-md);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s ease;
}

.btn-primary {
  background: var(--primary);
  color: white;
}

.btn-primary:hover {
  background: var(--primary-dark);
}

.btn-secondary {
  background: var(--neutral-20);
  color: var(--neutral-90);
}

.btn-secondary:hover {
  background: var(--neutral-30);
}

.btn-success {
  background: var(--success);
  color: white;
}

.btn-full {
  width: 100%;
  padding: var(--spacing-md);
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  padding: var(--spacing-xs);
  border-radius: var(--border-radius);
  font-size: 16px;
}

.btn-icon:hover {
  background: var(--neutral-20);
}

.btn-close {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: var(--spacing-xs);
  color: var(--neutral-60);
}

.btn-close:hover {
  color: var(--neutral-90);
}

/* Modal */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
}

.modal-content {
  position: relative;
  background: white;
  border-radius: var(--border-radius-lg);
  width: 90%;
  max-width: 360px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--spacing-md);
  border-bottom: 1px solid var(--neutral-30);
}

.modal-header h3 {
  font-size: var(--font-size-lg);
  font-weight: 600;
}

.modal-body {
  padding: var(--spacing-md);
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  border-top: 1px solid var(--neutral-30);
}

/* Form Elements */
.form-group {
  margin-bottom: var(--spacing-md);
}

.form-group label {
  display: block;
  font-weight: 500;
  margin-bottom: var(--spacing-xs);
  font-size: var(--font-size-sm);
}

.form-group input[type="text"],
.form-group input[type="email"],
.form-group input[type="number"] {
  width: 100%;
  padding: var(--spacing-sm);
  border: 1px solid var(--neutral-30);
  border-radius: var(--border-radius);
  font-family: var(--font-family);
  font-size: var(--font-size-md);
}

.form-group input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(0, 120, 212, 0.2);
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 16px;
  height: 16px;
}

/* Signer Selector */
.signer-selector {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  margin-bottom: var(--spacing-sm);
}

.signer-selector input {
  width: 60px;
  text-align: center;
  font-size: var(--font-size-lg);
  font-weight: 600;
}

.btn-stepper {
  width: 36px;
  height: 36px;
  border: 1px solid var(--neutral-30);
  border-radius: var(--border-radius);
  background: white;
  font-size: 20px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-stepper:hover {
  background: var(--neutral-20);
}

.signer-preview {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-sm);
  background: var(--neutral-20);
  border-radius: var(--border-radius);
}

.signer-color {
  width: 20px;
  height: 20px;
  border-radius: 4px;
  border: 2px solid;
}

/* Details/Summary */
details {
  margin-bottom: var(--spacing-md);
}

details summary {
  cursor: pointer;
  font-weight: 500;
  padding: var(--spacing-sm);
  background: var(--neutral-20);
  border-radius: var(--border-radius);
  margin-bottom: var(--spacing-sm);
}

details[open] summary {
  margin-bottom: var(--spacing-md);
}

/* Success/Error States */
.success-view,
.error-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-xl);
  text-align: center;
  min-height: 300px;
}

.success-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: var(--success);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  margin-bottom: var(--spacing-md);
}

.error-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: var(--danger);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  margin-bottom: var(--spacing-md);
}

/* Spinner */
.spinner {
  width: 24px;
  height: 24px;
  border: 3px solid var(--neutral-30);
  border-top-color: var(--primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Signer Color Classes */
.signer-1 { background: var(--signer-1); border-color: var(--signer-1-dark); color: var(--signer-1-dark); }
.signer-2 { background: var(--signer-2); border-color: var(--signer-2-dark); color: var(--signer-2-dark); }
.signer-3 { background: var(--signer-3); border-color: var(--signer-3-dark); color: var(--signer-3-dark); }
.signer-4 { background: var(--signer-4); border-color: var(--signer-4-dark); color: var(--signer-4-dark); }
.signer-5 { background: var(--signer-5); border-color: var(--signer-5-dark); color: var(--signer-5-dark); }
.signer-6 { background: var(--signer-6); border-color: var(--signer-6-dark); color: var(--signer-6-dark); }
.signer-7 { background: var(--signer-7); border-color: var(--signer-7-dark); color: var(--signer-7-dark); }
.signer-8 { background: var(--signer-8); border-color: var(--signer-8-dark); color: var(--signer-8-dark); }
.signer-9 { background: var(--signer-9); border-color: var(--signer-9-dark); color: var(--signer-9-dark); }
.signer-10 { background: var(--signer-10); border-color: var(--signer-10-dark); color: var(--signer-10-dark); }
```

---

## 7. Configurable Signature Fields

### 7.1 Field Configuration Model

Each field can be configured individually after insertion, just like Nintex:

```javascript
// Field configuration object
const fieldConfig = {
  id: 'field_001',
  type: 'signature',           // signature, initials, date, name, checkbox, text
  signerNumber: 1,             // Which signer this field belongs to
  signerLabel: 'Signer 1',     // Display label
  signerName: 'John Smith',    // Optional: Pre-fill signer name
  signerEmail: 'john@example.gc.ca', // Optional: Pre-fill email
  label: 'Employee Signature', // Field label
  required: true,              // Is field mandatory
  color: '#FFE699',            // Background color (auto-assigned by signer number)
  borderColor: '#BF9000',      // Border color (auto-assigned)
  position: { x: 0.15, y: 0.75 },  // Position on page (0-1 percentage)
  size: { width: 0.25, height: 0.05 }, // Size (0-1 percentage)
  pageNumber: 1                // Page number
};
```

### 7.2 Signer Color Palette

Colors are automatically assigned based on signer number:

```javascript
// manage.js - Color palette
const SIGNER_COLORS = [
  { bg: '#FFE699', border: '#BF9000', name: 'Gold' },      // Signer 1
  { bg: '#9BC2E6', border: '#2F75B5', name: 'Blue' },      // Signer 2
  { bg: '#A9D08E', border: '#548235', name: 'Green' },     // Signer 3
  { bg: '#F4B084', border: '#C65911', name: 'Orange' },    // Signer 4
  { bg: '#BD9EC1', border: '#7B4E8C', name: 'Purple' },    // Signer 5
  { bg: '#FFC0CB', border: '#C76173', name: 'Pink' },      // Signer 6
  { bg: '#8DDAC1', border: '#279178', name: 'Teal' },      // Signer 7
  { bg: '#FFD9B3', border: '#C58141', name: 'Peach' },     // Signer 8
  { bg: '#B0C4DE', border: '#4F709C', name: 'Steel' },     // Signer 9
  { bg: '#D8BFD8', border: '#946794', name: 'Thistle' }    // Signer 10
];

function getSignerColor(signerNumber) {
  const index = ((signerNumber - 1) % 10);
  return SIGNER_COLORS[index];
}
```

### 7.3 Field Manager JavaScript (manage.js)

```javascript
// ============================================
// Elections Canada E-Sign Add-in
// Field Manager
// ============================================

'use strict';

// State
let documentFields = [];
let selectedField = null;
let signers = new Map();

// Signer colors
const SIGNER_COLORS = [
  { bg: '#FFE699', border: '#BF9000' },
  { bg: '#9BC2E6', border: '#2F75B5' },
  { bg: '#A9D08E', border: '#548235' },
  { bg: '#F4B084', border: '#C65911' },
  { bg: '#BD9EC1', border: '#7B4E8C' },
  { bg: '#FFC0CB', border: '#C76173' },
  { bg: '#8DDAC1', border: '#279178' },
  { bg: '#FFD9B3', border: '#C58141' },
  { bg: '#B0C4DE', border: '#4F709C' },
  { bg: '#D8BFD8', border: '#946794' }
];

// Field type configurations
const FIELD_TYPES = {
  signature: { icon: '✍️', label: 'Signature', placeholder: 'sig', width: 180, height: 50 },
  initials: { icon: '🔤', label: 'Initials', placeholder: 'int', width: 60, height: 25 },
  date: { icon: '📅', label: 'Date', placeholder: 'dte', width: 100, height: 25 },
  name: { icon: '👤', label: 'Name', placeholder: 'txt', width: 150, height: 25 },
  checkbox: { icon: '☑️', label: 'Checkbox', placeholder: 'chk', width: 25, height: 25 },
  text: { icon: '📝', label: 'Text', placeholder: 'txt', width: 150, height: 25 }
};

// Initialize
Office.onReady((info) => {
  if (info.host === Office.HostType.Word) {
    console.log('E-Sign Add-in loaded');
    refreshFields();
  }
});

// ============================================
// Field Insertion
// ============================================

async function insertField(fieldType) {
  const config = FIELD_TYPES[fieldType];
  const signerNum = 1; // Default to signer 1
  const colors = getSignerColor(signerNum);
  
  const fieldId = `field_${Date.now()}`;
  const placeholderText = `{{${config.placeholder}_es_:signer${signerNum}:${fieldType}}}`;
  
  try {
    await Word.run(async (context) => {
      const selection = context.document.getSelection();
      
      // Insert a content control (allows styling and tracking)
      const contentControl = selection.insertContentControl();
      contentControl.tag = fieldId;
      contentControl.title = `${config.label} - Signer ${signerNum}`;
      contentControl.appearance = Word.ContentControlAppearance.tags;
      
      // Insert the placeholder text
      contentControl.insertText(placeholderText, Word.InsertLocation.replace);
      
      // Apply styling (background color based on signer)
      const range = contentControl.getRange();
      range.font.highlightColor = colors.bg;
      range.font.color = colors.border;
      range.font.name = 'Consolas';
      range.font.size = 9;
      
      await context.sync();
      
      // Track the field
      const newField = {
        id: fieldId,
        type: fieldType,
        signerNumber: signerNum,
        signerName: '',
        signerEmail: '',
        label: '',
        required: true,
        color: colors.bg,
        borderColor: colors.border
      };
      
      documentFields.push(newField);
      
      // Update UI
      renderFieldsList();
      updateSignerLegend();
      
      // Open configuration modal
      openConfigModal(newField);
    });
  } catch (error) {
    console.error('Error inserting field:', error);
    showNotification('Error', 'Failed to insert field: ' + error.message);
  }
}

// ============================================
// Field Configuration
// ============================================

function openConfigModal(field) {
  selectedField = field;
  
  // Populate modal
  document.getElementById('signerNumber').value = field.signerNumber;
  document.getElementById('signerName').value = field.signerName || '';
  document.getElementById('signerEmail').value = field.signerEmail || '';
  document.getElementById('fieldLabel').value = field.label || '';
  document.getElementById('fieldRequired').checked = field.required;
  
  updateSignerPreview(field.signerNumber);
  
  document.getElementById('configModal').style.display = 'flex';
}

function closeConfigModal() {
  document.getElementById('configModal').style.display = 'none';
  selectedField = null;
}

function updateSignerPreview(signerNum) {
  const colors = getSignerColor(signerNum);
  const preview = document.getElementById('signerColorPreview');
  const label = document.getElementById('signerLabelPreview');
  
  preview.style.backgroundColor = colors.bg;
  preview.style.borderColor = colors.border;
  label.textContent = `Signer ${signerNum}`;
  label.style.color = colors.border;
}

function incrementSigner() {
  const input = document.getElementById('signerNumber');
  input.value = Math.min(99, parseInt(input.value) + 1);
  updateSignerPreview(parseInt(input.value));
}

function decrementSigner() {
  const input = document.getElementById('signerNumber');
  input.value = Math.max(1, parseInt(input.value) - 1);
  updateSignerPreview(parseInt(input.value));
}

async function applyFieldConfig() {
  if (!selectedField) return;
  
  const signerNum = parseInt(document.getElementById('signerNumber').value);
  const signerName = document.getElementById('signerName').value;
  const signerEmail = document.getElementById('signerEmail').value;
  const fieldLabel = document.getElementById('fieldLabel').value;
  const required = document.getElementById('fieldRequired').checked;
  
  const colors = getSignerColor(signerNum);
  const config = FIELD_TYPES[selectedField.type];
  
  try {
    await Word.run(async (context) => {
      // Find the content control by tag
      const contentControls = context.document.contentControls;
      contentControls.load('tag,title');
      await context.sync();
      
      const control = contentControls.items.find(cc => cc.tag === selectedField.id);
      
      if (control) {
        // Update placeholder text with new signer number
        const labelPart = fieldLabel || selectedField.type;
        const placeholderText = `{{${config.placeholder}_es_:signer${signerNum}:${labelPart.toLowerCase().replace(/\s/g, '_')}}}`;
        
        control.title = `${config.label} - Signer ${signerNum}`;
        
        const range = control.getRange();
        range.insertText(placeholderText, Word.InsertLocation.replace);
        range.font.highlightColor = colors.bg;
        range.font.color = colors.border;
        
        await context.sync();
      }
      
      // Update field state
      selectedField.signerNumber = signerNum;
      selectedField.signerName = signerName;
      selectedField.signerEmail = signerEmail;
      selectedField.label = fieldLabel;
      selectedField.required = required;
      selectedField.color = colors.bg;
      selectedField.borderColor = colors.border;
      
      // Update signer registry
      if (signerName || signerEmail) {
        signers.set(signerNum, { name: signerName, email: signerEmail });
      }
      
      // Update UI
      renderFieldsList();
      updateSignerLegend();
      
      closeConfigModal();
    });
  } catch (error) {
    console.error('Error updating field:', error);
    showNotification('Error', 'Failed to update field: ' + error.message);
  }
}

// ============================================
// Field List Rendering
// ============================================

function renderFieldsList() {
  const container = document.getElementById('fieldsContainer');
  
  if (documentFields.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <span class="empty-icon">📄</span>
        <p>No fields added yet</p>
        <span class="empty-hint">Click a field type above to insert</span>
      </div>
    `;
    return;
  }
  
  container.innerHTML = documentFields.map(field => {
    const config = FIELD_TYPES[field.type];
    const signerInfo = signers.get(field.signerNumber);
    const signerDisplay = signerInfo?.name || `Signer ${field.signerNumber}`;
    
    return `
      <div class="field-item" onclick="openConfigModal(documentFields.find(f => f.id === '${field.id}'))">
        <div class="field-item-color signer-${((field.signerNumber - 1) % 10) + 1}"></div>
        <div class="field-item-info">
          <div class="field-item-type">${config.icon} ${field.label || config.label}</div>
          <div class="field-item-signer">${signerDisplay}</div>
        </div>
        <div class="field-item-actions">
          <button class="btn-icon" onclick="event.stopPropagation(); deleteField('${field.id}')" title="Delete">🗑️</button>
        </div>
      </div>
    `;
  }).join('');
}

function updateSignerLegend() {
  const legendSection = document.getElementById('signerLegend');
  const legendList = document.getElementById('signerList');
  
  // Get unique signers from fields
  const uniqueSigners = [...new Set(documentFields.map(f => f.signerNumber))].sort((a, b) => a - b);
  
  if (uniqueSigners.length === 0) {
    legendSection.style.display = 'none';
    return;
  }
  
  legendSection.style.display = 'block';
  
  legendList.innerHTML = uniqueSigners.map(signerNum => {
    const signerInfo = signers.get(signerNum);
    const name = signerInfo?.name || `Signer ${signerNum}`;
    const colorClass = `signer-${((signerNum - 1) % 10) + 1}`;
    
    return `
      <div class="signer-badge ${colorClass}">
        <span>${signerNum}</span>
        <span>${name}</span>
      </div>
    `;
  }).join('');
}

// ============================================
// Helpers
// ============================================

function getSignerColor(signerNum) {
  const index = ((signerNum - 1) % 10);
  return SIGNER_COLORS[index];
}

async function refreshFields() {
  try {
    await Word.run(async (context) => {
      const contentControls = context.document.contentControls;
      contentControls.load('tag,title');
      await context.sync();
      
      // Rebuild fields array from document
      documentFields = [];
      
      contentControls.items.forEach(cc => {
        if (cc.tag && cc.tag.startsWith('field_')) {
          // Parse signer number from title
          const signerMatch = cc.title.match(/Signer (\d+)/);
          const signerNum = signerMatch ? parseInt(signerMatch[1]) : 1;
          
          // Parse field type from title
          const typeMatch = cc.title.match(/^(\w+)/);
          const fieldType = typeMatch ? typeMatch[1].toLowerCase() : 'signature';
          
          documentFields.push({
            id: cc.tag,
            type: fieldType,
            signerNumber: signerNum,
            color: getSignerColor(signerNum).bg,
            borderColor: getSignerColor(signerNum).border,
            required: true
          });
        }
      });
      
      renderFieldsList();
      updateSignerLegend();
    });
  } catch (error) {
    console.error('Error refreshing fields:', error);
  }
}

async function deleteField(fieldId) {
  try {
    await Word.run(async (context) => {
      const contentControls = context.document.contentControls;
      contentControls.load('tag');
      await context.sync();
      
      const control = contentControls.items.find(cc => cc.tag === fieldId);
      if (control) {
        control.delete(false); // false = keep content
        await context.sync();
      }
      
      // Remove from state
      documentFields = documentFields.filter(f => f.id !== fieldId);
      
      renderFieldsList();
      updateSignerLegend();
    });
  } catch (error) {
    console.error('Error deleting field:', error);
  }
}

function openSendPane() {
  Office.context.ui.displayDialogAsync(
    'https://ec-esign.azurewebsites.net/send.html',
    { height: 80, width: 40 }
  );
}

function showNotification(title, message) {
  // Simple alert for now - could enhance with toast
  console.log(`${title}: ${message}`);
}

// Expose functions globally
window.insertField = insertField;
window.openConfigModal = openConfigModal;
window.closeConfigModal = closeConfigModal;
window.incrementSigner = incrementSigner;
window.decrementSigner = decrementSigner;
window.applyFieldConfig = applyFieldConfig;
window.deleteField = deleteField;
window.refreshFields = refreshFields;
window.openSendPane = openSendPane;
```

---

## 8. Programmatic API Access & Onboarding

### 8.1 Overview

For departments or systems that need to send e-signature requests programmatically (bulk operations, automated workflows), Elections Canada provides secure API access through the Dataverse broker using Managed Identity authentication.

### 8.2 Onboarding Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PROGRAMMATIC API ONBOARDING PROCESS                       │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌──────────────────┐
  │ 1. REQUEST       │
  │    Submit intake │
  │    form          │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 2. REVIEW        │
  │    Security team │
  │    assessment    │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 3. PROVISION     │
  │    App Reg +     │
  │    Managed ID    │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 4. CONFIGURE     │
  │    Budget &      │
  │    quotas        │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 5. TEST          │
  │    Sandbox       │
  │    validation    │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 6. PRODUCTION    │
  │    Go-live       │
  └──────────────────┘
```

### 8.3 Onboarding Request Form

| Field | Description | Required |
|-------|-------------|----------|
| Department/Team Name | Requesting organization | ✓ |
| Business Justification | Why API access is needed | ✓ |
| Estimated Monthly Volume | Expected envelopes per month | ✓ |
| Integration Type | Azure Function, Logic App, Custom App | ✓ |
| Environment | Dev, Test, Production | ✓ |
| Technical Contact | Developer responsible | ✓ |
| Business Owner | Budget holder/approver | ✓ |
| Managed Identity Name | Desired identity name | ✓ |
| IP Whitelist | Source IP ranges (if applicable) | |
| Callback URL | Webhook for status updates | |

### 8.4 Azure App Registration

The Platform Engineering Team creates an Azure App Registration for each approved client:

```powershell
# PowerShell - Create App Registration for API Client
$appName = "EC-ESign-Client-HRSystem"
$tenantId = "elections-canada-tenant-id"

# Create App Registration
$app = New-AzADApplication `
    -DisplayName $appName `
    -IdentifierUris "api://ec-esign-client-hrsystem" `
    -Web @{
        RedirectUris = @()
        ImplicitGrantSettings = @{
            EnableAccessTokenIssuance = $false
            EnableIdTokenIssuance = $false
        }
    }

# Create Service Principal
$sp = New-AzADServicePrincipal -ApplicationId $app.AppId

# Assign Dataverse Application User
# This is done in Power Platform Admin Center

Write-Host "App ID: $($app.AppId)"
Write-Host "Object ID: $($sp.Id)"
```

### 8.5 Managed Identity Configuration

For Azure-hosted applications (Functions, Logic Apps, App Services):

```powershell
# Enable System-Assigned Managed Identity
$functionApp = "func-hr-esign-processor"
$resourceGroup = "rg-hr-systems"

# Enable Managed Identity on Function App
Set-AzFunctionApp `
    -Name $functionApp `
    -ResourceGroupName $resourceGroup `
    -IdentityType SystemAssigned

# Get the identity
$identity = (Get-AzFunctionApp -Name $functionApp -ResourceGroupName $resourceGroup).Identity

Write-Host "Managed Identity Object ID: $($identity.PrincipalId)"
```

### 8.6 Dataverse Application User Setup

In Power Platform Admin Center, create an Application User:

1. Navigate to **Environments** → Select environment → **Settings**
2. Go to **Users + permissions** → **Application users**
3. Click **+ New app user**
4. Select the App Registration created above
5. Assign Security Role: **EC E-Sign API User**
6. Configure Business Unit as appropriate

### 8.7 Security Role: EC E-Sign API User

| Entity | Create | Read | Write | Delete | Append | AppendTo |
|--------|--------|------|-------|--------|--------|----------|
| ec_envelope | ✓ (Own) | ✓ (Own) | ✓ (Own) | ✗ | ✓ | ✓ |
| ec_signer | ✓ (Own) | ✓ (Own) | ✓ (Own) | ✓ (Own) | ✓ | ✓ |
| ec_field | ✓ (Own) | ✓ (Own) | ✓ (Own) | ✓ (Own) | ✓ | ✓ |
| ec_usage_log | ✗ | ✓ (Own) | ✗ | ✗ | ✗ | ✗ |
| ec_budget | ✗ | ✓ (Own) | ✗ | ✗ | ✗ | ✗ |

### 8.8 Budget & Quota Configuration

Each API client receives a budget allocation in the `ec_budget` table:

```json
{
  "ec_clientid": "app-registration-guid",
  "ec_clientname": "HR System Integration",
  "ec_monthlylimit": 5000.00,
  "ec_autoapprovalimit": 100.00,
  "ec_envelopelimit": 2000,
  "ec_signerlimit": 10,
  "ec_period": "2025-01",
  "ec_currentusage": 0.00,
  "ec_approver": "platform-team-lead-guid",
  "ec_notifyat": [50, 75, 90, 100]
}
```

### 8.9 API Client Code Example

```python
# Python - Calling Dataverse E-Sign Broker API with Managed Identity
import requests
from azure.identity import ManagedIdentityCredential
import json

class ESignClient:
    def __init__(self, dataverse_url: str):
        self.dataverse_url = dataverse_url
        self.credential = ManagedIdentityCredential()
        
    def _get_token(self) -> str:
        """Get access token for Dataverse using Managed Identity"""
        token = self.credential.get_token(f"{self.dataverse_url}/.default")
        return token.token
    
    def _get_headers(self) -> dict:
        """Get request headers with auth token"""
        return {
            "Authorization": f"Bearer {self._get_token()}",
            "Content-Type": "application/json",
            "OData-MaxVersion": "4.0",
            "OData-Version": "4.0",
            "Prefer": "return=representation"
        }
    
    def create_envelope(self, envelope_request: dict) -> dict:
        """
        Create an envelope in the broker service.
        Payload mirrors Nintex API structure.
        """
        url = f"{self.dataverse_url}/api/data/v9.2/ec_CreateEnvelope"
        
        response = requests.post(
            url,
            headers=self._get_headers(),
            json={"RequestPayload": json.dumps(envelope_request)}
        )
        
        response.raise_for_status()
        return response.json()
    
    def submit_envelope(self, envelope_id: str) -> dict:
        """Submit an approved envelope for sending"""
        url = f"{self.dataverse_url}/api/data/v9.2/ec_SubmitEnvelope"
        
        response = requests.post(
            url,
            headers=self._get_headers(),
            json={"EnvelopeId": envelope_id}
        )
        
        response.raise_for_status()
        return response.json()
    
    def get_envelope_status(self, envelope_id: str) -> dict:
        """Get current status of an envelope"""
        url = f"{self.dataverse_url}/api/data/v9.2/ec_envelopes({envelope_id})"
        
        response = requests.get(
            url,
            headers=self._get_headers()
        )
        
        response.raise_for_status()
        return response.json()
    
    def create_and_submit(self, envelope_request: dict) -> dict:
        """Create and submit envelope in one call (if within auto-approval limits)"""
        url = f"{self.dataverse_url}/api/data/v9.2/ec_CreateAndSubmit"
        
        response = requests.post(
            url,
            headers=self._get_headers(),
            json={"RequestPayload": json.dumps(envelope_request)}
        )
        
        response.raise_for_status()
        return response.json()


# Usage Example
if __name__ == "__main__":
    client = ESignClient("https://ec-esign.crm3.dynamics.com")
    
    # Create envelope request (Nintex-compatible payload)
    envelope_request = {
        "request": {
            "content": {
                "envelope": {
                    "name": "Employee Onboarding - Jane Doe",
                    "workflowType": "custom"
                },
                "documents": [{
                    "name": "Employment Agreement",
                    "file": {
                        "fileToUpload": {
                            "data": "BASE64_DOCUMENT_CONTENT",
                            "fileName": "Employment_Agreement.pdf"
                        },
                        "extension": "pdf"
                    },
                    "fields": [{
                        "fieldType": "signature",
                        "signer": "Signer 1",
                        "position": {"x": 0.15, "y": 0.75},
                        "size": {"height": 0.05, "width": 0.25}
                    }]
                }],
                "signers": [{
                    "label": "Signer 1",
                    "name": "Jane Doe",
                    "email": "jane.doe@example.gc.ca",
                    "signingOrder": 1
                }]
            }
        }
    }
    
    # Create and submit
    result = client.create_and_submit(envelope_request)
    
    if result["Status"] == "Sent":
        print(f"Envelope sent! ID: {result['EnvelopeId']}")
    elif result["Status"] == "PendingApproval":
        print(f"Envelope pending approval. ID: {result['EnvelopeId']}")
        print(f"Estimated cost: ${result['EstimatedCost']}")
```

### 8.10 Bulk Operations

For high-volume operations, clients can use batch requests:

```python
# Batch submission example
def submit_batch(self, envelopes: list) -> list:
    """Submit multiple envelopes in a single batch request"""
    batch_id = f"batch_{uuid.uuid4()}"
    changeset_id = f"changeset_{uuid.uuid4()}"
    
    # Build batch request body
    batch_body = f"--{batch_id}\n"
    batch_body += f"Content-Type: multipart/mixed; boundary={changeset_id}\n\n"
    
    for i, envelope in enumerate(envelopes):
        batch_body += f"--{changeset_id}\n"
        batch_body += "Content-Type: application/http\n"
        batch_body += "Content-Transfer-Encoding: binary\n"
        batch_body += f"Content-ID: {i+1}\n\n"
        batch_body += "POST /api/data/v9.2/ec_CreateAndSubmit HTTP/1.1\n"
        batch_body += "Content-Type: application/json\n\n"
        batch_body += json.dumps({"RequestPayload": json.dumps(envelope)})
        batch_body += "\n"
    
    batch_body += f"--{changeset_id}--\n"
    batch_body += f"--{batch_id}--"
    
    response = requests.post(
        f"{self.dataverse_url}/api/data/v9.2/$batch",
        headers={
            "Authorization": f"Bearer {self._get_token()}",
            "Content-Type": f"multipart/mixed; boundary={batch_id}",
            "OData-MaxVersion": "4.0"
        },
        data=batch_body
    )
    
    return self._parse_batch_response(response)
```

---

## 9. Security & Zero Trust

### 9.1 Zero Trust Principles

| Principle | Implementation |
|-----------|----------------|
| **Verify Explicitly** | All requests authenticated via Azure AD / Managed Identity |
| **Least Privilege** | Role-based access with minimal permissions |
| **Assume Breach** | All traffic encrypted, audit logging enabled |

### 9.2 Authentication Flows

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AUTHENTICATION ARCHITECTURE                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                          INTERACTIVE USERS                                    │
│                                                                              │
│   Office Add-in ──► Office SSO ──► Azure AD ──► Dataverse                   │
│   (Word/Excel)      Token         OIDC          App User                     │
│                                                                              │
│   Power Apps ──────► Azure AD ──────────────► Dataverse                      │
│   Portal            Implicit/Auth Code        Native Auth                    │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                        SERVICE-TO-SERVICE                                     │
│                                                                              │
│   Azure Function ──► Managed Identity ──► Azure AD ──► Dataverse            │
│   Logic App          System-Assigned      Client       App User              │
│   App Service        User-Assigned        Credentials                        │
│                                                                              │
│   External App ──────► App Registration ──► Azure AD ──► Dataverse          │
│   (Approved)           Client Secret/Cert   Client       App User            │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                        DATAVERSE TO NINTEX                                    │
│                                                                              │
│   Dataverse Plugin ──► Azure Key Vault ──► Nintex API                       │
│                        (Managed Identity)   (API Key Auth)                   │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 9.3 Credential Management

All Nintex API credentials are stored in Azure Key Vault:

```powershell
# Create Key Vault (if not exists)
$kvName = "kv-ec-esign-prod"
$resourceGroup = "rg-ec-esign"

New-AzKeyVault `
    -Name $kvName `
    -ResourceGroupName $resourceGroup `
    -Location "Canada Central" `
    -EnableRbacAuthorization

# Store Nintex credentials
Set-AzKeyVaultSecret -VaultName $kvName -Name "nintex-api-username" -SecretValue (ConvertTo-SecureString "api-user" -AsPlainText -Force)
Set-AzKeyVaultSecret -VaultName $kvName -Name "nintex-api-key" -SecretValue (ConvertTo-SecureString "api-key-value" -AsPlainText -Force)
Set-AzKeyVaultSecret -VaultName $kvName -Name "nintex-environment" -SecretValue (ConvertTo-SecureString "ca.assuresign.net" -AsPlainText -Force)

# Grant Dataverse Managed Identity access
$dataverseMI = "dataverse-mi-object-id"
New-AzRoleAssignment `
    -ObjectId $dataverseMI `
    -RoleDefinitionName "Key Vault Secrets User" `
    -Scope "/subscriptions/{sub}/resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$kvName"
```

### 9.4 Network Security

| Control | Implementation |
|---------|----------------|
| TLS | 1.2+ required for all connections |
| IP Restrictions | Nintex calls from known Dataverse IPs only |
| Private Endpoints | Key Vault accessible via private endpoint |
| WAF | Azure Application Gateway with WAF in front of add-in hosting |

### 9.5 Audit & Compliance

Every action is logged to the `ec_audit_log` table:

```json
{
  "ec_auditlogid": "guid",
  "ec_timestamp": "2025-01-15T14:30:00Z",
  "ec_action": "EnvelopeCreated",
  "ec_userid": "user-guid",
  "ec_clientid": "app-registration-guid",
  "ec_envelopeid": "envelope-guid",
  "ec_ipaddress": "10.0.0.50",
  "ec_useragent": "EC-ESign-Client/1.0",
  "ec_details": {
    "signerCount": 2,
    "documentCount": 1,
    "estimatedCost": 4.50,
    "source": "API"
  }
}
```

---

## 10. Deployment Guide

### 10.1 Prerequisites

- [ ] Azure subscription with appropriate permissions
- [ ] Power Platform environment (Canadian region)
- [ ] Nintex AssureSign contract and API credentials
- [ ] M365 Admin Center access for add-in deployment

### 10.2 Deployment Sequence

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEPLOYMENT SEQUENCE                                   │
└─────────────────────────────────────────────────────────────────────────────┘

Week 1: Infrastructure
├── Create Azure resources (Key Vault, App Service)
├── Configure Dataverse environment
├── Import solution with tables and security roles
└── Configure Key Vault with Nintex credentials

Week 2: Broker Service
├── Deploy Dataverse plugins
├── Create custom actions (ec_CreateEnvelope, etc.)
├── Configure webhook endpoints
└── Test broker with Nintex sandbox

Week 3: Add-in Development
├── Build and test Office Add-in locally
├── Deploy to Azure App Service
├── Configure manifest with production URLs
└── Test sideloaded add-in

Week 4: Integration
├── Configure Power Automate approval flows
├── Set up email notifications
├── Configure status update webhooks
└── End-to-end testing

Week 5: Deployment
├── Deploy add-in via M365 Admin Center
├── Pilot with select users
├── Documentation and training
└── Production go-live
```

### 10.3 Solution Import

```powershell
# Import Dataverse solution
pac solution import `
    --path "./solutions/EC_ESign_1_0_0_0.zip" `
    --environment "https://ec-esign.crm3.dynamics.com" `
    --async
```

### 10.4 Add-in Deployment

```powershell
# Deploy via Microsoft 365 Admin PowerShell
Connect-OrganizationAddInService

# Upload manifest
New-OrganizationAddIn `
    -ManifestPath "./dist/manifest.xml" `
    -Locale "en-CA" `
    -DefaultStateForUser Enabled `
    -AssetUrl "https://ec-esign.azurewebsites.net"

# Assign to all users (or specific groups)
Set-OrganizationAddInAssignments `
    -ProductId "ec-nintex-esign-00001" `
    -AssignToEveryone $true
```

---

## 11. Monitoring & Dashboards

### 11.1 Power BI Dashboard

A Power BI dashboard provides real-time visibility into e-signature operations:

**Key Metrics:**

- Total envelopes (daily/weekly/monthly)
- Completion rate
- Average time to completion
- Cost by department
- Pending approvals
- Declined/expired envelopes

### 11.2 Model-Driven App Views

Create views in the Dataverse model-driven app:

| View | Filter | Columns |
|------|--------|---------|
| My Pending Signatures | Status = Sent, Requester = Me | Name, Recipients, Sent Date |
| Pending Approvals | Status = PendingApproval | Name, Requester, Cost, Requested Date |
| Completed This Month | Status = Completed, Completed Date = This Month | Name, Cost, Completed Date |
| All Active Envelopes | Status IN (Sent, InProgress) | Name, Status, Recipients, Progress |

### 11.3 Email Notifications

Power Automate flows send notifications for:

- Envelope sent successfully
- Signer completed signing
- All signatures complete (envelope finished)
- Envelope declined
- Envelope expired
- Approval requested
- Approval decision (approved/rejected)
- Budget threshold warnings (75%, 90%, 100%)

---

## 12. Appendix

### 12.1 Nintex AssureSign API v3.7 Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/authentication/apiUser` | POST | Authenticate and get token |
| `/submit` | POST | Submit envelope (template or ad-hoc) |
| `/submit/prepare` | POST | Prepare envelope without sending |
| `/submit/{preparedEnvelopeID}` | POST | Send prepared envelope |
| `/envelopes/{envelopeID}` | GET | Get envelope status |
| `/envelopes/{envelopeID}/signingLinks` | GET | Get signing URLs |
| `/envelopes/{envelopeID}/cancel` | POST | Cancel envelope |
| `/envelopes/{envelopeID}/documents/{docID}` | GET | Download document |
| `/templates` | GET/POST/PUT/DELETE | Template CRUD |

### 12.2 Field Type Reference

| Field Type | Nintex Placeholder | Description |
|------------|-------------------|-------------|
| Signature | `{{sig_es_:signerN:label}}` | Signature capture area |
| Initials | `{{int_es_:signerN:label}}` | Initials field |
| Date | `{{dte_es_:signerN:label}}` | Auto-populated signing date |
| Text | `{{txt_es_:signerN:label}}` | Free-form text input |
| Checkbox | `{{chk_es_:signerN:label}}` | Yes/No checkbox |
| Radio | `{{rad_es_:signerN:label}}` | Radio button group |

### 12.3 Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| `EC001` | Authentication failed | Check Managed Identity configuration |
| `EC002` | Budget exceeded | Request budget increase or approval |
| `EC003` | Invalid payload | Verify request matches schema |
| `EC004` | Nintex API error | Check Nintex status, retry |
| `EC005` | Approval timeout | Approval not received within SLA |
| `EC006` | Document too large | Split document or compress |

### 12.4 Glossary

| Term | Definition |
|------|------------|
| **Envelope** | A collection of documents and signers for a single signing session |
| **Signer** | A person who needs to sign or take action on an envelope |
| **Field** | A signature, initials, date, or other input placed on a document |
| **Broker** | The Dataverse service that proxies requests to Nintex |
| **Managed Identity** | Azure AD identity for service-to-service authentication |

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Dec 2024 | Platform Engineering | Initial document |
| 2.0 | Dec 2024 | Platform Engineering | Added Dataverse broker, Zero Trust, API onboarding |

---

**Document Classification:** Protected B

**For questions or support:** <platform-engineering@elections.ca>
