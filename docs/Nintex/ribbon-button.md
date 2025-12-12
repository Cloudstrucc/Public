<div style="position: relative; margin-bottom: 40px;">
  <div style="position: absolute; top: 0; right: 0; display: flex; align-items: center; gap: 20px;">
    <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfSAYy3IK4Dz7D9a53L9k_Y8gnC9LjyobBow&s"
         alt="Microsoft Power Platform"
         style="vertical-align: middle;">
    <span style="font-size: 32px; color: #666; font-weight: 300;">+</span>
    <img src="https://pbs.twimg.com/profile_images/1494408594254671874/Z-FoS_Gc_400x400.png"
         alt="Nintex"
         height="115"
         width="115"
         style="vertical-align: middle;">
  </div>
  <div style="height: 100px;"></div> <!-- Spacer to prevent overlap with title -->
</div>

# Nintex E-Sign Office Add-in Build Guide

## Document Information

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Author | LCE M365 Security Team |
| Last Updated | December 2024 |
| Status | Draft |

---

## 1. Overview

This document provides a step-by-step guide for building and deploying a custom Microsoft Office Add-in that adds a ribbon button with dropdown menu items for Nintex AssureSign e-signature functionality in Word and Excel.

### 1.1 What We're Building

- A custom ribbon tab or group containing a "Send with Nintex" button
- Dropdown menu with options such as:
  - Send for Signature
  - Add Signature Fields
  - Check Signature Status
  - View Signed Documents
- Task pane UI for configuration and field placement
- Integration with Nintex AssureSign API

### 1.2 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Microsoft Office                      │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Custom Ribbon Button                │    │
│  │         (Defined in manifest.xml)               │    │
│  └─────────────────────────────────────────────────┘    │
│                         │                                │
│                         ▼                                │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Task Pane / Dialog                  │    │
│  │            (HTML/CSS/JavaScript)                │    │
│  └─────────────────────────────────────────────────┘    │
│                         │                                │
└─────────────────────────│───────────────────────────────┘
                          │ HTTPS
                          ▼
┌─────────────────────────────────────────────────────────┐
│              Your Web Server / Azure                     │
│         (Hosts add-in files and backend logic)          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              Nintex AssureSign API                       │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Prerequisites

### 2.1 Development Environment

- **Node.js** (LTS version 18.x or later)
- **npm** or **yarn** package manager
- **Visual Studio Code** (recommended) with Office Add-in Debugger extension
- **Microsoft 365 Developer Account** or access to a Microsoft 365 tenant for testing
- **Office Desktop Apps** (Word/Excel 2016 or later, or Microsoft 365)

### 2.2 Required Accounts and Access

- Microsoft 365 Admin Center access (for deployment)
- Nintex AssureSign API credentials (Client ID, Client Secret, API endpoint)
- Azure subscription (if hosting on Azure) or alternative web hosting with HTTPS

### 2.3 Install Yeoman Generator

The Office Add-in Yeoman generator scaffolds the project structure:

```bash
npm install -g yo generator-office
```

---

## 3. Project Setup

### 3.1 Generate the Add-in Project

Run the Yeoman generator to create the project scaffold:

```bash
yo office
```

When prompted, select the following options:

| Prompt | Selection |
|--------|-----------|
| Choose a project type | Office Add-in Task Pane project |
| Choose a script type | JavaScript (or TypeScript if preferred) |
| What do you want to name your add-in? | Nintex E-Sign |
| Which Office client application? | Word (repeat process for Excel if needed) |

### 3.2 Project Structure

After generation, your project will have this structure:

```
nintex-esign-addin/
├── manifest.xml              # Add-in manifest (ribbon config, permissions)
├── package.json              # Node.js dependencies
├── webpack.config.js         # Build configuration
├── src/
│   ├── taskpane/
│   │   ├── taskpane.html     # Task pane UI
│   │   ├── taskpane.css      # Task pane styles
│   │   └── taskpane.js       # Task pane logic
│   └── commands/
│       └── commands.js       # Ribbon button command handlers
├── assets/
│   ├── icon-16.png           # Ribbon icons (16x16)
│   ├── icon-32.png           # Ribbon icons (32x32)
│   ├── icon-80.png           # Ribbon icons (80x80)
│   └── logo-filled.png       # Add-in logo
└── dist/                     # Built files (generated)
```

---

## 4. Manifest Configuration

The `manifest.xml` file defines the add-in's identity, permissions, and ribbon customization. Replace the default manifest with the following skeleton.

### 4.1 Complete Manifest Skeleton

```xml
<?xml version="1.0" encoding="UTF-8"?>
<OfficeApp xmlns="http://schemas.microsoft.com/office/appforoffice/1.1"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:bt="http://schemas.microsoft.com/office/officeappbasictypes/1.0"
           xmlns:ov="http://schemas.microsoft.com/office/taskpaneappversionoverrides"
           xsi:type="TaskPaneApp">

  <!-- Basic Identity -->
  <Id>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</Id>
  <Version>1.0.0.0</Version>
  <ProviderName>Leonardo Company Canada</ProviderName>
  <DefaultLocale>en-US</DefaultLocale>
  <DisplayName DefaultValue="Nintex E-Sign"/>
  <Description DefaultValue="Send documents for signature and add signature fields using Nintex AssureSign."/>
  
  <!-- Icon URLs (must be HTTPS) -->
  <IconUrl DefaultValue="https://your-server.com/assets/icon-32.png"/>
  <HighResolutionIconUrl DefaultValue="https://your-server.com/assets/icon-80.png"/>
  
  <!-- Support and App Domain -->
  <SupportUrl DefaultValue="https://support.yourcompany.com"/>
  <AppDomains>
    <AppDomain>https://your-server.com</AppDomain>
    <AppDomain>https://api.nintex.com</AppDomain>
  </AppDomains>
  
  <!-- Supported Office Hosts -->
  <Hosts>
    <Host Name="Document"/>  <!-- Word -->
    <Host Name="Workbook"/>  <!-- Excel -->
  </Hosts>
  
  <!-- Minimum API Requirements -->
  <Requirements>
    <Sets>
      <Set Name="WordApi" MinVersion="1.1"/>
    </Sets>
  </Requirements>
  
  <!-- Default Task Pane Settings -->
  <DefaultSettings>
    <SourceLocation DefaultValue="https://your-server.com/taskpane.html"/>
  </DefaultSettings>
  
  <!-- Permissions -->
  <Permissions>ReadWriteDocument</Permissions>

  <!-- Version Overrides for Ribbon Customization -->
  <VersionOverrides xmlns="http://schemas.microsoft.com/office/taskpaneappversionoverrides" xsi:type="VersionOverridesV1_0">
    <Hosts>
      <Host xsi:type="Document">
        <DesktopFormFactor>
          
          <!-- Function File for Command Handlers -->
          <FunctionFile resid="Commands.Url"/>
          
          <!-- Ribbon Extension Point -->
          <ExtensionPoint xsi:type="PrimaryCommandSurface">
            
            <!-- Custom Tab (or use OfficeTab to add to existing tab) -->
            <CustomTab id="NintexTab">
              <Group id="NintexGroup">
                <Label resid="GroupLabel"/>
                <Icon>
                  <bt:Image size="16" resid="Icon.16x16"/>
                  <bt:Image size="32" resid="Icon.32x32"/>
                  <bt:Image size="80" resid="Icon.80x80"/>
                </Icon>
                
                <!-- Main Dropdown Menu Button -->
                <Control xsi:type="Menu" id="NintexMenu">
                  <Label resid="MenuLabel"/>
                  <Tooltip resid="MenuTooltip"/>
                  <Supertip>
                    <Title resid="MenuLabel"/>
                    <Description resid="MenuTooltip"/>
                  </Supertip>
                  <Icon>
                    <bt:Image size="16" resid="Icon.16x16"/>
                    <bt:Image size="32" resid="Icon.32x32"/>
                    <bt:Image size="80" resid="Icon.80x80"/>
                  </Icon>
                  
                  <!-- Dropdown Menu Items -->
                  <Items>
                    <!-- Item 1: Send for Signature -->
                    <Item id="SendForSignature">
                      <Label resid="SendLabel"/>
                      <Tooltip resid="SendTooltip"/>
                      <Supertip>
                        <Title resid="SendLabel"/>
                        <Description resid="SendTooltip"/>
                      </Supertip>
                      <Icon>
                        <bt:Image size="16" resid="SendIcon.16x16"/>
                        <bt:Image size="32" resid="SendIcon.32x32"/>
                        <bt:Image size="80" resid="SendIcon.80x80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>sendForSignature</FunctionName>
                      </Action>
                    </Item>
                    
                    <!-- Item 2: Add Signature Fields -->
                    <Item id="AddFields">
                      <Label resid="AddFieldsLabel"/>
                      <Tooltip resid="AddFieldsTooltip"/>
                      <Supertip>
                        <Title resid="AddFieldsLabel"/>
                        <Description resid="AddFieldsTooltip"/>
                      </Supertip>
                      <Icon>
                        <bt:Image size="16" resid="FieldsIcon.16x16"/>
                        <bt:Image size="32" resid="FieldsIcon.32x32"/>
                        <bt:Image size="80" resid="FieldsIcon.80x80"/>
                      </Icon>
                      <Action xsi:type="ShowTaskpane">
                        <TaskpaneId>AddFieldsPane</TaskpaneId>
                        <SourceLocation resid="Taskpane.AddFields.Url"/>
                      </Action>
                    </Item>
                    
                    <!-- Item 3: Check Status -->
                    <Item id="CheckStatus">
                      <Label resid="StatusLabel"/>
                      <Tooltip resid="StatusTooltip"/>
                      <Supertip>
                        <Title resid="StatusLabel"/>
                        <Description resid="StatusTooltip"/>
                      </Supertip>
                      <Icon>
                        <bt:Image size="16" resid="StatusIcon.16x16"/>
                        <bt:Image size="32" resid="StatusIcon.32x32"/>
                        <bt:Image size="80" resid="StatusIcon.80x80"/>
                      </Icon>
                      <Action xsi:type="ShowTaskpane">
                        <TaskpaneId>StatusPane</TaskpaneId>
                        <SourceLocation resid="Taskpane.Status.Url"/>
                      </Action>
                    </Item>
                    
                    <!-- Item 4: View Signed Documents -->
                    <Item id="ViewDocuments">
                      <Label resid="ViewDocsLabel"/>
                      <Tooltip resid="ViewDocsTooltip"/>
                      <Supertip>
                        <Title resid="ViewDocsLabel"/>
                        <Description resid="ViewDocsTooltip"/>
                      </Supertip>
                      <Icon>
                        <bt:Image size="16" resid="DocsIcon.16x16"/>
                        <bt:Image size="32" resid="DocsIcon.32x32"/>
                        <bt:Image size="80" resid="DocsIcon.80x80"/>
                      </Icon>
                      <Action xsi:type="ExecuteFunction">
                        <FunctionName>viewSignedDocuments</FunctionName>
                      </Action>
                    </Item>
                  </Items>
                </Control>
                
              </Group>
              <Label resid="TabLabel"/>
            </CustomTab>
            
          </ExtensionPoint>
        </DesktopFormFactor>
      </Host>
    </Hosts>
    
    <!-- String Resources -->
    <Resources>
      <bt:Images>
        <bt:Image id="Icon.16x16" DefaultValue="https://your-server.com/assets/icon-16.png"/>
        <bt:Image id="Icon.32x32" DefaultValue="https://your-server.com/assets/icon-32.png"/>
        <bt:Image id="Icon.80x80" DefaultValue="https://your-server.com/assets/icon-80.png"/>
        <bt:Image id="SendIcon.16x16" DefaultValue="https://your-server.com/assets/send-16.png"/>
        <bt:Image id="SendIcon.32x32" DefaultValue="https://your-server.com/assets/send-32.png"/>
        <bt:Image id="SendIcon.80x80" DefaultValue="https://your-server.com/assets/send-80.png"/>
        <bt:Image id="FieldsIcon.16x16" DefaultValue="https://your-server.com/assets/fields-16.png"/>
        <bt:Image id="FieldsIcon.32x32" DefaultValue="https://your-server.com/assets/fields-32.png"/>
        <bt:Image id="FieldsIcon.80x80" DefaultValue="https://your-server.com/assets/fields-80.png"/>
        <bt:Image id="StatusIcon.16x16" DefaultValue="https://your-server.com/assets/status-16.png"/>
        <bt:Image id="StatusIcon.32x32" DefaultValue="https://your-server.com/assets/status-32.png"/>
        <bt:Image id="StatusIcon.80x80" DefaultValue="https://your-server.com/assets/status-80.png"/>
        <bt:Image id="DocsIcon.16x16" DefaultValue="https://your-server.com/assets/docs-16.png"/>
        <bt:Image id="DocsIcon.32x32" DefaultValue="https://your-server.com/assets/docs-32.png"/>
        <bt:Image id="DocsIcon.80x80" DefaultValue="https://your-server.com/assets/docs-80.png"/>
      </bt:Images>
      
      <bt:Urls>
        <bt:Url id="Commands.Url" DefaultValue="https://your-server.com/commands.html"/>
        <bt:Url id="Taskpane.AddFields.Url" DefaultValue="https://your-server.com/taskpane-fields.html"/>
        <bt:Url id="Taskpane.Status.Url" DefaultValue="https://your-server.com/taskpane-status.html"/>
      </bt:Urls>
      
      <bt:ShortStrings>
        <bt:String id="TabLabel" DefaultValue="Nintex E-Sign"/>
        <bt:String id="GroupLabel" DefaultValue="E-Signature"/>
        <bt:String id="MenuLabel" DefaultValue="Nintex"/>
        <bt:String id="SendLabel" DefaultValue="Send for Signature"/>
        <bt:String id="AddFieldsLabel" DefaultValue="Add Signature Fields"/>
        <bt:String id="StatusLabel" DefaultValue="Check Status"/>
        <bt:String id="ViewDocsLabel" DefaultValue="View Signed Documents"/>
      </bt:ShortStrings>
      
      <bt:LongStrings>
        <bt:String id="MenuTooltip" DefaultValue="Nintex e-signature options"/>
        <bt:String id="SendTooltip" DefaultValue="Send this document for electronic signature via Nintex AssureSign"/>
        <bt:String id="AddFieldsTooltip" DefaultValue="Add signature, date, and other fields to the document"/>
        <bt:String id="StatusTooltip" DefaultValue="Check the signature status of sent documents"/>
        <bt:String id="ViewDocsTooltip" DefaultValue="View all signed documents in Nintex"/>
      </bt:LongStrings>
    </Resources>
    
  </VersionOverrides>
</OfficeApp>
```

### 4.2 Alternative: Add to Existing Office Tab

If you prefer to add the button to an existing Office tab (like the Home tab) instead of creating a custom tab, replace the `<CustomTab>` section with:

```xml
<OfficeTab id="TabHome">
  <Group id="NintexGroup">
    <!-- Same group content as above -->
  </Group>
</OfficeTab>
```

---

## 5. Command Handlers (JavaScript)

### 5.1 Commands File Structure

Create `src/commands/commands.js` to handle ribbon button actions:

```javascript
/*
 * Nintex E-Sign Office Add-in
 * Command Handlers for Ribbon Buttons
 */

// Initialize Office.js
Office.onReady((info) => {
  if (info.host === Office.HostType.Word || info.host === Office.HostType.Excel) {
    console.log("Nintex E-Sign Add-in loaded successfully");
  }
});

/**
 * Send the current document for signature via Nintex AssureSign
 * @param {Office.AddinCommands.Event} event - The add-in command event
 */
async function sendForSignature(event) {
  try {
    // Show loading indicator
    Office.context.ui.displayDialogAsync(
      "https://your-server.com/sending-dialog.html",
      { height: 30, width: 20, displayInIframe: true },
      (asyncResult) => {
        const dialog = asyncResult.value;
        
        // Get document content
        getDocumentAsBase64()
          .then((base64Content) => {
            return sendToNintex(base64Content);
          })
          .then((result) => {
            dialog.close();
            showNotification("Success", `Document sent! Envelope ID: ${result.envelopeId}`);
          })
          .catch((error) => {
            dialog.close();
            showNotification("Error", `Failed to send: ${error.message}`);
          });
      }
    );
  } catch (error) {
    showNotification("Error", error.message);
  }
  
  // Signal completion to Office
  event.completed();
}

/**
 * Open Nintex portal to view signed documents
 * @param {Office.AddinCommands.Event} event - The add-in command event
 */
function viewSignedDocuments(event) {
  // Open Nintex AssureSign portal in a dialog
  Office.context.ui.displayDialogAsync(
    "https://your-nintex-portal.com/documents",
    { height: 80, width: 60 },
    (asyncResult) => {
      if (asyncResult.status === Office.AsyncResultStatus.Failed) {
        showNotification("Error", "Could not open Nintex portal");
      }
    }
  );
  
  event.completed();
}

/**
 * Get the current document content as Base64
 * @returns {Promise<string>} Base64-encoded document content
 */
function getDocumentAsBase64() {
  return new Promise((resolve, reject) => {
    Office.context.document.getFileAsync(
      Office.FileType.Compressed,
      { sliceSize: 65536 },
      (result) => {
        if (result.status === Office.AsyncResultStatus.Succeeded) {
          const file = result.value;
          const sliceCount = file.sliceCount;
          const slices = [];
          
          const getSlice = (index) => {
            file.getSliceAsync(index, (sliceResult) => {
              if (sliceResult.status === Office.AsyncResultStatus.Succeeded) {
                slices.push(sliceResult.value.data);
                
                if (index < sliceCount - 1) {
                  getSlice(index + 1);
                } else {
                  file.closeAsync();
                  const docData = slices.join("");
                  resolve(btoa(docData));
                }
              } else {
                file.closeAsync();
                reject(new Error("Failed to read document slice"));
              }
            });
          };
          
          getSlice(0);
        } else {
          reject(new Error("Failed to access document"));
        }
      }
    );
  });
}

/**
 * Send document to Nintex AssureSign API
 * @param {string} base64Content - Base64-encoded document
 * @returns {Promise<object>} API response with envelope ID
 */
async function sendToNintex(base64Content) {
  const config = await getApiConfig();
  
  const response = await fetch(`${config.apiBaseUrl}/v1/envelopes`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${config.accessToken}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      documents: [{
        name: Office.context.document.url || "Document.docx",
        content: base64Content,
        contentType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      }],
      // Add recipients, workflow settings, etc.
    })
  });
  
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  
  return response.json();
}

/**
 * Retrieve API configuration (token, endpoint)
 * In production, implement proper OAuth flow
 */
async function getApiConfig() {
  // TODO: Implement secure token retrieval
  // Options:
  // 1. Use Office.auth.getAccessToken() with SSO
  // 2. Store tokens in Office.context.roamingSettings
  // 3. Implement OAuth dialog flow
  
  return {
    apiBaseUrl: "https://api.nintex.com/assuresign",
    accessToken: "YOUR_ACCESS_TOKEN"
  };
}

/**
 * Show notification to user
 */
function showNotification(title, message) {
  Office.context.mailbox?.item?.notificationMessages?.addAsync("nintex-notification", {
    type: Office.MailboxEnums?.ItemNotificationMessageType?.InformationalMessage,
    message: message,
    icon: "icon-16",
    persistent: false
  }) || console.log(`${title}: ${message}`);
}

// Register functions globally for Office to call
globalThis.sendForSignature = sendForSignature;
globalThis.viewSignedDocuments = viewSignedDocuments;
```

### 5.2 Commands HTML File

Create `src/commands/commands.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
  <title>Nintex E-Sign Commands</title>
  
  <!-- Office.js library -->
  <script type="text/javascript" 
          src="https://appsforoffice.microsoft.com/lib/1.1/hosted/office.js">
  </script>
  
  <!-- Command handlers -->
  <script type="text/javascript" src="commands.js"></script>
</head>
<body>
  <!-- This page is not displayed; it only loads the command functions -->
</body>
</html>
```

---

## 6. Task Pane UI

### 6.1 Add Signature Fields Task Pane

Create `src/taskpane/taskpane-fields.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Add Signature Fields</title>
  
  <!-- Office UI Fabric for consistent styling -->
  <link rel="stylesheet" 
        href="https://static2.sharepointonline.com/files/fabric/office-ui-fabric-core/11.0.0/css/fabric.min.css"/>
  
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      padding: 20px;
      margin: 0;
    }
    
    .field-button {
      display: flex;
      align-items: center;
      width: 100%;
      padding: 12px 16px;
      margin-bottom: 8px;
      border: 1px solid #edebe9;
      border-radius: 4px;
      background: #fff;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .field-button:hover {
      background: #f3f2f1;
      border-color: #8a8886;
    }
    
    .field-button i {
      margin-right: 12px;
      font-size: 20px;
      color: #0078d4;
    }
    
    .field-button .label {
      font-size: 14px;
      font-weight: 600;
    }
    
    .field-button .description {
      font-size: 12px;
      color: #605e5c;
    }
    
    h2 {
      font-size: 18px;
      margin-bottom: 16px;
      color: #323130;
    }
    
    .section {
      margin-bottom: 24px;
    }
    
    .status-bar {
      padding: 8px 12px;
      background: #deecf9;
      border-radius: 4px;
      font-size: 12px;
      margin-bottom: 16px;
    }
  </style>
  
  <script src="https://appsforoffice.microsoft.com/lib/1.1/hosted/office.js"></script>
</head>
<body>
  <div class="status-bar" id="statusBar">
    Click a field type to insert at cursor position
  </div>
  
  <div class="section">
    <h2>Signature Fields</h2>
    
    <button class="field-button" onclick="insertField('signature')">
      <i class="ms-Icon ms-Icon--EditCreate"></i>
      <div>
        <div class="label">Signature</div>
        <div class="description">Add a signature capture field</div>
      </div>
    </button>
    
    <button class="field-button" onclick="insertField('initials')">
      <i class="ms-Icon ms-Icon--EditNote"></i>
      <div>
        <div class="label">Initials</div>
        <div class="description">Add an initials field</div>
      </div>
    </button>
    
    <button class="field-button" onclick="insertField('date')">
      <i class="ms-Icon ms-Icon--Calendar"></i>
      <div>
        <div class="label">Date Signed</div>
        <div class="description">Auto-populated signing date</div>
      </div>
    </button>
  </div>
  
  <div class="section">
    <h2>Signer Information</h2>
    
    <button class="field-button" onclick="insertField('name')">
      <i class="ms-Icon ms-Icon--Contact"></i>
      <div>
        <div class="label">Full Name</div>
        <div class="description">Signer's full name</div>
      </div>
    </button>
    
    <button class="field-button" onclick="insertField('email')">
      <i class="ms-Icon ms-Icon--Mail"></i>
      <div>
        <div class="label">Email Address</div>
        <div class="description">Signer's email</div>
      </div>
    </button>
    
    <button class="field-button" onclick="insertField('company')">
      <i class="ms-Icon ms-Icon--CityNext"></i>
      <div>
        <div class="label">Company</div>
        <div class="description">Signer's organization</div>
      </div>
    </button>
  </div>
  
  <div class="section">
    <h2>Custom Fields</h2>
    
    <button class="field-button" onclick="insertField('text')">
      <i class="ms-Icon ms-Icon--TextField"></i>
      <div>
        <div class="label">Text Input</div>
        <div class="description">Free-form text entry</div>
      </div>
    </button>
    
    <button class="field-button" onclick="insertField('checkbox')">
      <i class="ms-Icon ms-Icon--CheckboxComposite"></i>
      <div>
        <div class="label">Checkbox</div>
        <div class="description">Yes/No selection</div>
      </div>
    </button>
  </div>

  <script>
    Office.onReady((info) => {
      console.log("Task pane loaded for", info.host);
    });
    
    /**
     * Insert a Nintex field placeholder at cursor position
     * @param {string} fieldType - Type of field to insert
     */
    async function insertField(fieldType) {
      const fieldPlaceholders = {
        signature: "{{sig_es_:signer1:signature}}",
        initials: "{{int_es_:signer1:initials}}",
        date: "{{dte_es_:signer1:date}}",
        name: "{{txt_es_:signer1:fullname}}",
        email: "{{txt_es_:signer1:email}}",
        company: "{{txt_es_:signer1:company}}",
        text: "{{txt_es_:signer1:customtext}}",
        checkbox: "{{chk_es_:signer1:checkbox}}"
      };
      
      const placeholder = fieldPlaceholders[fieldType];
      
      try {
        await Word.run(async (context) => {
          const selection = context.document.getSelection();
          selection.insertText(placeholder, Word.InsertLocation.replace);
          await context.sync();
          
          updateStatus(`Inserted ${fieldType} field`);
        });
      } catch (error) {
        updateStatus(`Error: ${error.message}`, true);
      }
    }
    
    function updateStatus(message, isError = false) {
      const statusBar = document.getElementById("statusBar");
      statusBar.textContent = message;
      statusBar.style.background = isError ? "#fde7e9" : "#dff6dd";
      
      setTimeout(() => {
        statusBar.textContent = "Click a field type to insert at cursor position";
        statusBar.style.background = "#deecf9";
      }, 3000);
    }
  </script>
</body>
</html>
```

---

## 7. Local Development and Testing

### 7.1 Start the Development Server

```bash
cd nintex-esign-addin
npm start
```

This will:
- Start a local webpack dev server (typically on https://localhost:3000)
- Launch Word/Excel with the add-in sideloaded
- Enable hot reloading for development

### 7.2 Sideload for Manual Testing

If automatic sideloading doesn't work:

**Windows:**
1. Open Word or Excel
2. Go to **Insert** > **My Add-ins** > **Manage My Add-ins**
3. Click **Upload My Add-in**
4. Browse to your `manifest.xml` file

**Mac:**
1. Open Word or Excel
2. Go to **Insert** > **Add-ins** > **My Add-ins**
3. Click the **...** menu > **Upload My Add-in**
4. Select your `manifest.xml`

### 7.3 Debug in Browser DevTools

Press **F12** in the task pane to open DevTools (Windows) or use Safari Web Inspector (Mac).

---

## 8. Production Build

### 8.1 Build for Production

```bash
npm run build
```

This generates optimized files in the `dist/` folder.

### 8.2 Hosting Requirements

Your add-in files must be hosted on a web server with:

- **HTTPS** with a valid SSL certificate (required by Office)
- **CORS headers** allowing Office domains
- **Static file serving** for HTML, JS, CSS, and images

Recommended hosting options:

| Option | Pros | Cons |
|--------|------|------|
| Azure Static Web Apps | Easy deployment, free tier, automatic HTTPS | Azure subscription required |
| Azure Blob Storage + CDN | Scalable, cheap | More setup required |
| SharePoint Document Library | Already in M365, familiar | Performance, URL structure |
| AWS S3 + CloudFront | Reliable, global CDN | AWS account required |

### 8.3 Azure Static Web Apps Deployment Example

```bash
# Install Azure Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Login to Azure
az login

# Deploy
swa deploy ./dist --env production
```

---

## 9. Enterprise Deployment

### 9.1 Deployment Options Overview

| Method | Scope | Best For |
|--------|-------|----------|
| Microsoft 365 Admin Center | Tenant-wide | Organization-wide deployment |
| SharePoint App Catalog | Tenant or site | SharePoint-integrated workflows |
| Centralized Deployment | User/Group | Targeted rollout |
| Intune | Device-based | Managed devices |

### 9.2 Microsoft 365 Admin Center Deployment (Recommended)

This is the recommended approach for deploying to all users in your Leonardo Company Canada tenant.

**Step 1: Prepare the Manifest**

Ensure your `manifest.xml` has:
- All URLs pointing to your production HTTPS server
- A unique GUID in the `<Id>` element
- Correct version number

**Step 2: Upload to Admin Center**

1. Sign in to [Microsoft 365 Admin Center](https://admin.microsoft.com) as a Global Admin or Apps Admin
2. Navigate to **Settings** > **Integrated apps**
3. Click **Upload custom apps**
4. Select **Office Add-in** as the app type
5. Choose **Upload manifest file (.xml)** and upload your manifest
6. Click **Next**

**Step 3: Configure User Assignment**

1. Choose deployment scope:
   - **Entire organization** - All users get the add-in
   - **Specific users/groups** - Target specific security groups
   - **Just me** - Test deployment
2. For Protected B compliance, consider:
   - Creating a security group for authorized users
   - Deploying only to users who need e-signature capability
3. Click **Next**

**Step 4: Review Permissions**

1. Review the permissions requested by the add-in:
   - `ReadWriteDocument` - Required to read/send document content
2. Accept permissions on behalf of organization if appropriate
3. Click **Next** and then **Finish deployment**

**Step 5: Verify Deployment**

Deployment typically takes 12-24 hours to propagate. To verify:
1. Open Word or Excel as a test user
2. Check the ribbon for your custom "Nintex E-Sign" tab
3. Test each dropdown menu item

### 9.3 PowerShell Deployment (Alternative)

For automated or scripted deployment:

```powershell
# Connect to Exchange Online (required for add-in management)
Connect-ExchangeOnline -UserPrincipalName admin@leonardocompany.ca

# Deploy add-in to all users
New-OrganizationAddIn -ManifestPath "C:\AddIns\manifest.xml" `
                      -Locale "en-US" `
                      -DefaultStateForUser Enabled

# Deploy to specific users/groups
$users = @("user1@leonardocompany.ca", "user2@leonardocompany.ca")
New-OrganizationAddIn -ManifestPath "C:\AddIns\manifest.xml" `
                      -Locale "en-US" `
                      -AssignToEveryone $false
                      
# Assign to specific users
Set-OrganizationAddInAssignments -ProductId "your-addin-guid" `
                                  -AssignToEveryone $false `
                                  -UsersToAssign $users

# Verify deployment
Get-OrganizationAddIn | Where-Object { $_.DisplayName -eq "Nintex E-Sign" }
```

### 9.4 SharePoint App Catalog Deployment

If you prefer SharePoint-based deployment:

1. **Create App Catalog** (if not exists):
   - SharePoint Admin Center > **More features** > **Apps**
   - **App Catalog** > Create a new app catalog site

2. **Upload Add-in**:
   - Go to App Catalog site > **Apps for Office**
   - Upload your `manifest.xml`

3. **Deploy**:
   - Click on the uploaded add-in
   - Select **Deployment** > **Add to all sites** or specific sites

---

## 10. Security Considerations

### 10.1 Protected B Compliance

For Leonardo Company Canada's Protected B requirements:

- **Data Residency**: Ensure Nintex AssureSign data stays in Canada or approved regions
- **Encryption**: All API calls must use TLS 1.2+
- **Authentication**: Implement proper OAuth 2.0 flow with Azure AD
- **Audit Logging**: Log all signature requests for compliance

### 10.2 Azure AD SSO Integration

For seamless authentication, implement Single Sign-On:

```javascript
// In your commands.js
async function getAccessTokenWithSSO() {
  try {
    const accessToken = await Office.auth.getAccessToken({
      allowSignInPrompt: true,
      allowConsentPrompt: true,
      forMSGraphAccess: false // Set true if calling Graph API
    });
    
    // Exchange Office token for Nintex token via your backend
    return await exchangeTokenForNintex(accessToken);
  } catch (error) {
    if (error.code === 13003) {
      // SSO not supported, fall back to dialog
      return await getTokenViaDialog();
    }
    throw error;
  }
}
```

### 10.3 Content Security Policy

Add CSP headers to your hosting server:

```
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' https://appsforoffice.microsoft.com;
  style-src 'self' https://static2.sharepointonline.com 'unsafe-inline';
  connect-src 'self' https://api.nintex.com;
  frame-ancestors 'self' https://*.office.com https://*.microsoft.com;
```

---

## 11. Troubleshooting

### 11.1 Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Add-in not appearing in ribbon | Manifest not loaded or deployment pending | Wait 24hrs, clear Office cache, re-sideload |
| "We can't open this add-in" | HTTPS certificate issue | Ensure valid SSL cert, check mixed content |
| Buttons don't respond | JavaScript errors | Check DevTools console, verify function registration |
| Task pane blank | Resource loading failed | Check network tab, verify URLs in manifest |
| "Add-in is not registered" | Manifest ID mismatch | Ensure consistent GUID across deployments |

### 11.2 Clear Office Add-in Cache

**Windows:**
```cmd
rd /s /q "%LOCALAPPDATA%\Microsoft\Office\16.0\Wef"
rd /s /q "%userprofile%\AppData\Local\Packages\Microsoft.Win32WebViewHost_cw5n1h2txyewy\AC\#!123\INetCache"
```

**Mac:**
```bash
rm -rf ~/Library/Containers/com.microsoft.Word/Data/Library/Caches/
rm -rf ~/Library/Containers/com.microsoft.Excel/Data/Library/Caches/
```

### 11.3 Enable Add-in Debugging

Add to your manifest for verbose logging:

```xml
<Requirements>
  <Sets DefaultMinVersion="1.1">
    <Set Name="WordApi" MinVersion="1.1"/>
  </Sets>
</Requirements>
```

---

## 12. Appendix

### 12.1 Icon Requirements

Prepare icons in these sizes:

| Size | Usage |
|------|-------|
| 16x16 | Ribbon (small), menu items |
| 32x32 | Ribbon (default) |
| 80x80 | App catalog, store listing |

Format: PNG with transparent background recommended.

### 12.2 Nintex AssureSign API Reference

Key endpoints you'll need:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/authentication/token` | POST | Get access token |
| `/v1/envelopes` | POST | Create and send envelope |
| `/v1/envelopes/{id}` | GET | Get envelope status |
| `/v1/envelopes/{id}/documents` | GET | Download signed documents |

### 12.3 Useful Links

- [Office Add-ins Documentation](https://learn.microsoft.com/en-us/office/dev/add-ins/)
- [Office Add-in Manifest Reference](https://learn.microsoft.com/en-us/office/dev/add-ins/develop/add-in-manifests)
- [Nintex AssureSign API Documentation](https://developer.nintex.com/)
- [Office UI Fabric / Fluent UI](https://developer.microsoft.com/en-us/fluentui)

---

## 13. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | December 2025 | Platform Engineering Team | Initial document |