# Nintex Assurance Digital Signature Integration - Deployment Guide

## Prerequisites

- Microsoft Dataverse environment with System Administrator privileges
- Visual Studio 2019/2022 with .NET Framework 4.6.2 or higher
- Power Platform CLI installed
- Node.js (version 12.x or higher)
- Nintex Assurance API credentials and access

## Part 1: Setting Up the Custom Entity

### 1.1 Create the Digital Signature Entity

1. **Navigate to Power Apps** (make.powerapps.com)
2. **Select your environment**
3. **Go to Tables** in the left navigation
4. **Click "+ New table"**
5. **Configure the table:**
   - **Display name:** Digital Signature
   - **Plural display name:** Digital Signatures
   - **Name:** new_digitalsignature
   - **Primary column:** Name (new_name)

### 1.2 Add Required Columns

Add the following columns to your Digital Signature table:

| Display Name | Name | Data Type | Description |
|--------------|------|-----------|-------------|
| Recipient Email | new_recipientemail | Single line of text (Email format) | Email of signature recipient |
| Recipient Name | new_recipientname | Single line of text | Full name of recipient |
| Document Content | new_documentcontent | Multiple lines of text | Base64 encoded document to sign |
| Signature Status | new_signaturestatus | Choice | Status of signature request |
| Nintex Request ID | new_nintexrequestid | Single line of text | Unique ID from Nintex |
| Signed Document | new_signaturedocument | Multiple lines of text | Base64 encoded signed document |
| Signature Date | new_signaturedate | Date and time | When document was signed |
| Request Date | new_requestdate | Date and time | When request was sent |
| Expiry Date | new_expirydate | Date and time | When request expires |

### 1.3 Configure Signature Status Choice Values

For the **Signature Status** column, add these choices:

| Label | Value |
|-------|-------|
| Draft | 100000000 |
| Pending Signature | 100000001 |
| Signed | 100000002 |
| Declined | 100000003 |
| Expired | 100000004 |

### 1.4 Create a Model-Driven App

1. **Go to Apps** in Power Apps
2. **Click "+ New app" > Model-driven**
3. **Name:** Digital Signature Management
4. **Add the Digital Signature table**
5. **Configure forms and views as needed**
6. **Save and publish**

## Part 2: C# Plugin Development and Deployment

### 2.1 Create Plugin Project

1. **Open Visual Studio**
2. **Create new Class Library (.NET Framework) project**
3. **Target Framework:** .NET Framework 4.6.2
4. **Install NuGet packages:**
   ```
   Install-Package Microsoft.CrmSdk.CoreAssemblies
   Install-Package Newtonsoft.Json
   ```

### 2.2 Build and Sign the Assembly

1. **Build the solution** in Release mode
2. **Sign the assembly** (recommended for production):
   - Right-click project > Properties > Signing
   - Check "Sign the assembly"
   - Create new strong name key file

### 2.3 Register the Plugin

#### Using Plugin Registration Tool:

1. **Download and install** Plugin Registration Tool from NuGet
2. **Connect to your Dataverse environment**
3. **Register new assembly:**
   - Click "Register" > "Register New Assembly"
   - Browse to your compiled DLL
   - Select "Sandbox" isolation mode
   - Click "Register Selected Plugins"

4. **Register plugin steps:**

   **For Create Message:**
   - **Message:** Create
   - **Primary Entity:** new_digitalsignature
   - **Event Pipeline Stage:** Post-operation
   - **Execution Mode:** Synchronous

   **For Update Message:**
   - **Message:** Update
   - **Primary Entity:** new_digitalsignature
   - **Event Pipeline Stage:** Post-operation
   - **Execution Mode:** Synchronous
   - **Filtering Attributes:** new_signaturestatus, new_nintexrequestid

### 2.4 Configure Secure Configuration

1. **In Plugin Registration Tool**, edit the plugin step
2. **Add secure configuration** with your Nintex API key:
   ```json
   {
     "nintexApiKey": "your-nintex-api-key-here",
     "apiBaseUrl": "https://api.nintex.com/assurance/v1"
   }
   ```

## Part 3: PCF Component Development and Deployment

### 3.1 Initialize PCF Project

```bash
# Create new folder for PCF project
mkdir NintexDigitalSignatureControl
cd NintexDigitalSignatureControl

# Initialize PCF project
pac pcf init --namespace NintexAssuranceControls --name NintexDigitalSignatureControl --template field

# Install dependencies
npm install
npm install @types/react@^16.9.0 @types/react-dom@^16.9.0 react@^16.8.0 react-dom@^16.8.0
```

### 3.2 Replace Generated Files

Replace the generated files with the code provided in the PCF artifact:

- **index.ts** - Main control implementation
- **DigitalSignatureControl.tsx** - React component (create new file)
- **ControlManifest.Input.xml** - Manifest configuration
- **package.json** - Updated dependencies

### 3.3 Build and Package

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

# The solution will be in bin/Release folder as a .zip file
```

### 3.4 Import Solution

1. **Go to Power Apps** (make.powerapps.com)
2. **Navigate to Solutions**
3. **Click "Import solution"**
4. **Upload the .zip file** from the build
5. **Follow the import wizard**
6. **Publish customizations**

## Part 4: Form Configuration

### 4.1 Add PCF Component to Form

1. **Open Digital Signature table**
2. **Go to Forms tab**
3. **Edit the main form**
4. **Add a new section** for the signature control
5. **Add the PCF component:**
   - Drag a field to the form
   - In properties, go to "Controls" tab
   - Click "Add control"
   - Select "Nintex Digital Signature Control"
   - Configure property bindings:
     - **recipientEmail** → new_recipientemail
     - **recipientName** → new_recipientname  
     - **signatureStatus** → new_signaturestatus
     - **nintexRequestId** → new_nintexrequestid
     - **signedDocument** → new_signaturedocument
6. **Save and publish** the form

## Part 5: API Configuration and Security

### 5.1 Nintex API Setup

1. **Obtain API credentials** from Nintex Assurance
2. **Configure API endpoints** in the plugin code:
   - Update `GetNintexSignatureEndpoint()` method
   - Update `GetNintexDocumentEndpoint()` method
   - Verify authentication method (Bearer token, API key, etc.)

### 5.2 Webhook Configuration (Optional)

For real-time signature status updates:

1. **Create a custom API** or Azure Function to handle Nintex webhooks
2. **Configure webhook URL** in Nintex Assurance dashboard
3. **Update the plugin** to handle webhook callbacks
4. **Secure the webhook endpoint** with proper authentication

### 5.3 Environment Variables (Recommended)

Set up environment variables for sensitive configuration:

1. **In Power Platform admin center:**
   - Go to Environment Variables
   - Create new variables:
     - `nintex_api_key`
     - `nintex_base_url`
     - `webhook_secret`

2. **Update plugin code** to use environment variables:
   ```csharp
   private string GetNintexApiKey()
   {
       // Retrieve from environment variable
       var envVar = service.RetrieveMultiple(new QueryExpression("environmentvariablevalue")
       {
           ColumnSet = new ColumnSet("value"),
           Criteria = new FilterExpression
           {
               Conditions = {
                   new ConditionExpression("environmentvariabledefinitionid", 
                       ConditionOperator.Equal, "your-env-var-id")
               }
           }
       });
       
       return envVar.Entities.FirstOrDefault()?.GetAttributeValue<string>("value");
   }
   ```

## Part 6: Testing and Validation

### 6.1 Test Plugin Functionality

1. **Create a new Digital Signature record**
2. **Fill in recipient details**
3. **Verify plugin triggers** and sends API request
4. **Check that Nintex Request ID** is populated
5. **Test status updates** and document retrieval

### 6.2 Test PCF Component

1. **Open a Digital Signature record**
2. **Verify the PCF component loads** correctly
3. **Test sending signature requests**
4. **Test status refresh functionality**
5. **Test document download** (when signed)

### 6.3 Error Handling Verification

1. **Test with invalid recipient emails**
2. **Test API failures** (temporarily break API key)
3. **Verify error messages** are user-friendly
4. **Check plugin traces** in Plugin Registration Tool

## Part 7: Production Deployment Checklist

### 7.1 Security Review

- [ ] API keys stored securely (not in code)
- [ ] Plugin runs in sandbox mode
- [ ] Webhook endpoints are authenticated
- [ ] User permissions configured correctly

### 7.2 Performance Considerations

- [ ] Plugin execution time is optimized
- [ ] API calls are asynchronous where possible
- [ ] Proper error handling and retry logic
- [ ] Logging configured for monitoring

### 7.3 Documentation

- [ ] User training materials created
- [ ] Admin documentation updated
- [ ] API configuration documented
- [ ] Troubleshooting guide prepared

## Troubleshooting Common Issues

### Plugin Issues

**Issue:** Plugin not triggering
- **Solution:** Check plugin registration steps and filtering attributes

**Issue:** API calls failing
- **Solution:** Verify API endpoints, authentication, and network connectivity

**Issue:** Assembly load errors
- **Solution:** Ensure all dependencies are included and compatible

### PCF Component Issues

**Issue:** Component not showing on form
- **Solution:** Verify solution import, form configuration, and property bindings

**Issue:** TypeScript compilation errors
- **Solution:** Check React version compatibility and type definitions

**Issue:** Runtime JavaScript errors
- **Solution:** Check browser console and verify WebAPI permissions

### API Integration Issues

**Issue:** Nintex authentication failing
- **Solution:** Verify API key validity and authentication method

**Issue:** Document not downloading
- **Solution:** Check base64 encoding/decoding and MIME types

**Issue:** Webhook not receiving callbacks
- **Solution:** Verify webhook URL accessibility and payload format

## Support and Maintenance

- **Monitor plugin execution** through Dataverse analytics
- **Review API usage** and rate limiting
- **Update dependencies** regularly for security
- **Test in non-production environments** before updates
- **Maintain API documentation** and keep credentials current