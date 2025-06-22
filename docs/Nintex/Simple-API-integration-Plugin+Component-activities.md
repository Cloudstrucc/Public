# Nintex Assurance Digital Signature Activity Integration - Deployment Guide

## Overview

This solution creates a **custom activity** for digital signature requests using Nintex Assurance API. Unlike the previous version that used a custom table, this activity-based approach allows **any entity** that supports activities to initiate digital signature requests. The signature activities will automatically appear in timeline controls across your organization.

## Prerequisites

- Microsoft Dataverse environment with System Administrator privileges
- Visual Studio 2019/2022 with .NET Framework 4.6.2 or higher
- Power Platform CLI installed
- Node.js (version 12.x or higher)
- Nintex Assurance API credentials and access

## Part 1: Understanding Activities in Dataverse

### 1.1 Activity Benefits

**Why use activities for digital signatures:**
- ✅ **Universal Usage**: Can be used with ANY entity (Accounts, Contacts, Cases, custom entities, etc.)
- ✅ **Timeline Integration**: Automatically appears in timeline controls
- ✅ **Built-in Fields**: Leverages standard activity fields (Subject, Description, Regarding)
- ✅ **Activity Management**: Standard activity lifecycle (Open, Completed, Cancelled)
- ✅ **User Familiarity**: Users already understand how activities work

### 1.2 Activity Architecture

Activities inherit from `ActivityPointer` and include:
- **Subject**: Title of the signature request
- **Description**: Details about the signature request
- **RegardingObjectId**: The record this signature relates to
- **StateCode**: Open (0), Completed (1), Cancelled (2)
- **StatusCode**: Custom status values within each state

## Part 2: Creating the Digital Signature Activity

### 2.1 Create the Activity Table

1. **Navigate to Power Apps** (make.powerapps.com)
2. **Select your environment**
3. **Go to Tables** in the left navigation
4. **Click "+ New table"**
5. **Configure the table:**
   - **Display name:** Digital Signature Activity
   - **Plural display name:** Digital Signature Activities
   - **Name:** new_digitalsignatureactivity
   - **Primary column:** Subject (inherited from ActivityPointer)
   - **Type:** Activity table ⚠️ **IMPORTANT: Select "Activity table" option**

### 2.2 Add Custom Columns

Add the following columns to your Digital Signature Activity:

| Display Name | Name | Data Type | Description |
|--------------|------|-----------|-------------|
| Recipient Email | new_recipientemail | Single line of text (Email format) | Email of signature recipient |
| Recipient Name | new_recipientname | Single line of text | Full name of recipient |
| Document Content | new_documentcontent | Multiple lines of text | Base64 encoded document to sign |
| Document Name | new_documentname | Single line of text | Name of document to be signed |
| Nintex Request ID | new_nintexrequestid | Single line of text | Unique ID from Nintex |
| Signed Document | new_signaturedocument | Multiple lines of text | Base64 encoded signed document |
| Signature Date | new_signaturedate | Date and time | When document was signed |
| Request Date | new_requestdate | Date and time | When request was sent |
| Expiry Date | new_expirydate | Date and time | When request expires |
| Callback URL | new_callbackurl | Single line of text | Webhook URL for status updates |

### 2.3 Configure Status Reason (StatusCode) Values

Activities use **Status Reason** instead of custom choice fields. Configure these values:

**For State = Open (0):**
| Label | Value |
|-------|-------|
| Draft | 1 |
| Pending Signature | 2 |
| Failed to Send | 3 |

**For State = Completed (1):**
| Label | Value |
|-------|-------|
| Signed | 4 |

**For State = Cancelled (2):**
| Label | Value |
|-------|-------|
| Declined | 5 |
| Expired | 6 |

### 2.4 Enable Activities on Target Entities

For each entity where you want to use digital signatures:

1. **Navigate to the target table** (e.g., Account, Contact, Case, custom entity)
2. **Go to table settings**
3. **Enable "Activities"** if not already enabled
4. **Save and publish**

Examples of entities to enable:
- **Account**: For contract signatures
- **Contact**: For personal document signatures  
- **Opportunity**: For sales agreement signatures
- **Case**: For resolution confirmation signatures
- **Custom entities**: For any business-specific signatures

## Part 3: C# Activity Plugin Development and Deployment

### 3.1 Create Activity Plugin Project

1. **Open Visual Studio**
2. **Create new Class Library (.NET Framework) project**
3. **Name:** NintexDigitalSignatureActivityPlugin
4. **Target Framework:** .NET Framework 4.6.2
5. **Install NuGet packages:**
   ```
   Install-Package Microsoft.CrmSdk.CoreAssemblies
   Install-Package Newtonsoft.Json
   ```

### 3.2 Key Activity Plugin Differences

**Important changes for activity-based plugins:**

- **Entity Name**: `new_digitalsignatureactivity` (not regular table)
- **Activity Fields**: Use `subject`, `description`, `regardingobjectid`
- **Status Management**: Use `statecode` and `statuscode` instead of custom fields
- **Activity Lifecycle**: Respect Open → Completed/Cancelled progression

### 3.3 Build and Sign the Assembly

1. **Build the solution** in Release mode
2. **Sign the assembly** (recommended for production)

### 3.4 Register the Activity Plugin

#### Using Plugin Registration Tool:

1. **Download and install** Plugin Registration Tool
2. **Connect to your Dataverse environment**
3. **Register new assembly:**
   - Click "Register" > "Register New Assembly"
   - Browse to your compiled DLL
   - Select "Sandbox" isolation mode
   - Click "Register Selected Plugins"

4. **Register plugin steps:**

   **For Create Message:**
   - **Message:** Create
   - **Primary Entity:** `new_digitalsignatureactivity`
   - **Event Pipeline Stage:** Post-operation
   - **Execution Mode:** Synchronous

   **For Update Message:**
   - **Message:** Update
   - **Primary Entity:** `new_digitalsignatureactivity`
   - **Event Pipeline Stage:** Post-operation
   - **Execution Mode:** Synchronous
   - **Filtering Attributes:** `statuscode`, `new_nintexrequestid`

### 3.5 Configure Secure Configuration

```json
{
  "nintexApiKey": "your-nintex-api-key-here",
  "apiBaseUrl": "https://api.nintex.com/assurance/v1",
  "webhookSecret": "your-webhook-secret"
}
```

## Part 4: Timeline Integration (Automatic)

### 4.1 Timeline Benefits

Activities automatically appear in timeline controls with:
- ✅ **Visual Icons**: Custom activity icon
- ✅ **Status Indicators**: Color-coded status
- ✅ **Quick Actions**: Built-in activity actions
- ✅ **Contextual Information**: Shows regarding relationship

### 4.2 Timeline Configuration

**Timeline controls automatically include your activity when:**
1. Activities are enabled on the entity
2. The activity table is created and published
3. Users have appropriate security roles

**No additional configuration needed!**

## Part 5: PCF Component for Enhanced UX

### 5.1 Initialize Activity PCF Project

```bash
# Create new folder for PCF project
mkdir NintexDigitalSignatureActivityControl
cd NintexDigitalSignatureActivityControl

# Initialize PCF project
pac pcf init --namespace NintexAssuranceControls --name NintexDigitalSignatureActivityControl --template field

# Install dependencies
npm install
npm install @types/react@^16.9.0 @types/react-dom@^16.9.0 react@^16.8.0 react-dom@^16.8.0
```

### 5.2 Build and Package Activity PCF

```bash
# Build the control
npm run build

# Create solution folder
mkdir Solutions
cd Solutions

# Initialize solution
pac solution init --publisher-name "YourCompany" --publisher-prefix "yourprefix"

# Add PCF component reference
pac solution add-reference --path "../"

# Build solution
msbuild /p:configuration=Release
```

### 5.3 Import Activity Solution

1. **Go to Power Apps** (make.powerapps.com)
2. **Navigate to Solutions**
3. **Click "Import solution"**
4. **Upload the .zip file**
5. **Follow the import wizard**
6. **Publish customizations**

## Part 6: Activity Form Configuration

### 6.1 Create Activity Quick Create Form

1. **Open Digital Signature Activity table**
2. **Go to Forms tab**
3. **Create "Quick Create" form:**
   - **Form Type:** Quick Create
   - **Add fields:**
     - Subject (required)
     - Recipient Email
     - Recipient Name
     - Document Name
     - Description

### 6.2 Configure Main Activity Form

1. **Edit the main activity form**
2. **Add PCF component section:**
   - Create new section: "Signature Management"
   - Add PCF control with bindings:
     - **recipientEmail** → new_recipientemail
     - **recipientName** → new_recipientname
     - **statusCode** → statuscode
     - **stateCode** → statecode
     - **nintexRequestId** → new_nintexrequestid
     - **signedDocument** → new_signaturedocument
     - **regardingObjectId** → regardingobjectid (text)
     - **regardingObjectType** → regardingobjecttypecode (text)
     - **subject** → subject

3. **Configure Activity-Specific Layout:**
   - **Header**: Subject, Owner, Status Reason
   - **General Tab**: Recipient details, PCF component
   - **Notes Tab**: Description, additional details

## Part 7: Using Digital Signature Activities

### 7.1 Creating Signature Requests

**From any activity-enabled entity:**

1. **Open any record** (Account, Contact, Case, etc.)
2. **Go to Timeline** 
3. **Click "+" to add activity**
4. **Select "Digital Signature Activity"**
5. **Fill in quick create form:**
   - Subject: "Contract Signature Request"
   - Recipient Email: customer@example.com
   - Recipient Name: John Doe
   - Document Name: Service Agreement
6. **Save** - Plugin automatically sends signature request

### 7.2 Timeline Workflow

**Complete workflow in timeline:**
1. **Draft** → Activity created
2. **Pending Signature** → Request sent via Nintex
3. **Signed** → Document signed and downloaded
4. **Activity completed** with signed document attached

### 7.3 Activity Management

**Activities support standard operations:**
- **Assign**: Transfer ownership
- **Close**: Mark as completed/cancelled
- **Reactivate**: Reopen if needed
- **Delete**: Remove if permitted

## Part 8: Multi-Entity Configuration Examples

### 8.1 Account Entity Usage

**Sales Contract Signatures:**
```
Account: Contoso Corporation
├── Timeline
    ├── Digital Signature Activity: "Service Agreement"
    ├── Digital Signature Activity: "NDA Signature"
    └── Digital Signature Activity: "Payment Terms"
```

### 8.2 Case Entity Usage

**Support Resolution Signatures:**
```
Case: Support Ticket #12345
├── Timeline
    ├── Phone Call: "Initial Contact"
    ├── Task: "Investigate Issue"
    ├── Digital Signature Activity: "Resolution Confirmation"
    └── Email: "Case Closed Notification"
```

### 8.3 Custom Entity Usage

**HR Document Signatures:**
```
Employee Record: Jane Smith
├── Timeline
    ├── Digital Signature Activity: "Employment Contract"
    ├── Digital Signature Activity: "Handbook Acknowledgment"
    └── Digital Signature Activity: "Performance Review"
```

## Part 9: Advanced Configuration

### 9.1 Business Process Flows

**Create signature workflow:**
1. **New Business Process Flow**
2. **Include signature activity stage**
3. **Configure required fields**
4. **Add approval gates**

### 9.2 Power Automate Integration

**Automated signature workflows:**
```
Trigger: Account record created
↓
Action: Create Digital Signature Activity
↓
Condition: Signature completed?
↓
Action: Send notification email
```

### 9.3 Security Roles

**Configure activity permissions:**
- **Create**: Who can initiate signatures
- **Read**: Who can view signature status
- **Update**: Who can modify requests
- **Delete**: Who can remove activities

### 9.4 Activity Views

**Create custom activity views:**
- **My Pending Signatures**: Current user's pending requests
- **All Signature Activities**: Organization-wide view
- **Completed Signatures**: Historical signed documents
- **Failed Requests**: Troubleshooting view

## Part 10: Testing and Validation

### 10.1 Multi-Entity Testing

**Test across different entities:**
1. **Account**: Create signature from account timeline
2. **Contact**: Create signature from contact timeline  
3. **Case**: Create signature from case timeline
4. **Custom Entity**: Create signature from custom entity timeline

### 10.2 Activity Lifecycle Testing

**Test complete workflow:**
1. **Create** activity from timeline
2. **Send** signature request via plugin
3. **Monitor** status changes
4. **Complete** when signed
5. **Download** signed document

### 10.3 Timeline Integration Testing

**Verify timeline functionality:**
- Activities appear in chronological order
- Status updates reflect in timeline
- Activity icons display correctly
- Regarding relationships maintained

## Part 11: Production Deployment Checklist

### 11.1 Activity-Specific Considerations

- [ ] Activities enabled on all target entities
- [ ] Timeline controls configured properly
- [ ] Activity security roles assigned
- [ ] Quick create forms deployed
- [ ] Activity views created and shared

### 11.2 Performance Monitoring

- [ ] Activity plugin execution monitored
- [ ] Timeline loading performance verified
- [ ] Activity queries optimized
- [ ] Bulk signature operations tested

### 11.3 User Training

- [ ] Timeline-based signature process documented
- [ ] Activity management training provided
- [ ] Multi-entity usage examples created
- [ ] Troubleshooting guide prepared

## Troubleshooting Activity-Specific Issues

### Activity Creation Issues

**Issue:** Activity not appearing in timeline
- **Solution:** Verify activities enabled on target entity, check security roles

**Issue:** Quick create form not working
- **Solution:** Verify form published and assigned to users

### Timeline Integration Issues

**Issue:** Activities not showing proper icons
- **Solution:** Check activity table configuration and web resources

**Issue:** Activity status not updating in timeline
- **Solution:** Verify plugin registration and status code configuration

### Plugin Issues for Activities

**Issue:** Plugin not triggering on activity creation
- **Solution:** Verify registration on correct activity entity name

**Issue:** Regarding object not accessible
- **Solution:** Check regardingobjectid field permissions and plugin context

## Benefits of Activity-Based Approach

### ✅ **Universal Applicability**
- Works with **any entity** that supports activities
- **Single solution** serves entire organization
- **Consistent experience** across all record types

### ✅ **Native Integration** 
- **Timeline controls** automatically include signature activities
- **Standard activity behavior** familiar to users
- **Built-in activity management** capabilities

### ✅ **Scalability**
- **One activity type** supports unlimited entity types
- **Centralized management** of signature processes
- **Unified reporting** across all signatures

### ✅ **User Experience**
- **Contextual signatures** directly related to records
- **Visual timeline** shows signature history
- **Standard Dataverse** activity patterns