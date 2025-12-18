// ============================================
// Elections Canada E-Sign Add-in
// Send Envelope - Dataverse Broker Integration
// ============================================

'use strict';

// Configuration
const CONFIG = {
  dataverseUrl: 'https://ec-esign.crm3.dynamics.com',
  apiVersion: 'v9.2',
  pricing: {
    baseEnvelope: 2.50,
    perSigner: 1.00,
    perDocument: 0.50
  }
};

// State
let documentFields = [];
let signers = new Map();
let documentInfo = null;
let budgetInfo = null;

// Initialize
Office.onReady(async (info) => {
  console.log('Send pane loaded');
  await analyzeDocument();
});

// ============================================
// Document Analysis
// ============================================

async function analyzeDocument() {
  try {
    // Get document info
    documentInfo = await getDocumentInfo();
    
    // Scan for signature fields
    documentFields = await scanDocumentFields();
    
    // Build signer list from fields
    buildSignerList();
    
    // Get budget info
    budgetInfo = await fetchBudgetInfo();
    
    // Calculate cost
    const cost = calculateCost();
    
    // Check if approval needed
    const needsApproval = checkApprovalRequired(cost);
    
    // Update UI
    renderSummary(cost, needsApproval);
    renderSignerList();
    
    // Show content
    document.getElementById('loadingState').style.display = 'none';
    document.getElementById('contentArea').style.display = 'block';
    
    // Enable/disable send button
    document.getElementById('btnSend').disabled = documentFields.length === 0;
    
  } catch (error) {
    console.error('Error analyzing document:', error);
    showError('Failed to analyze document');
  }
}

async function getDocumentInfo() {
  return new Promise((resolve) => {
    if (Office.context.document) {
      resolve({
        name: Office.context.document.url ? 
          Office.context.document.url.split('/').pop() : 
          'Untitled Document',
        type: 'docx'
      });
    } else {
      resolve({ name: 'Document.docx', type: 'docx' });
    }
  });
}

async function scanDocumentFields() {
  const fields = [];
  
  try {
    await Word.run(async (context) => {
      const contentControls = context.document.contentControls;
      contentControls.load('tag,title,text');
      await context.sync();
      
      contentControls.items.forEach(cc => {
        if (cc.tag && cc.tag.startsWith('field_')) {
          // Parse signer number from placeholder text
          const signerMatch = cc.text?.match(/:signer(\d+):/);
          const signerNum = signerMatch ? parseInt(signerMatch[1]) : 1;
          
          // Parse field type
          const typeMatch = cc.text?.match(/\{\{(\w+)_es_/);
          const fieldType = typeMatch ? mapPlaceholderToType(typeMatch[1]) : 'signature';
          
          fields.push({
            id: cc.tag,
            type: fieldType,
            signerNumber: signerNum,
            placeholder: cc.text
          });
        }
      });
    });
  } catch (error) {
    console.log('Error scanning fields, using demo data:', error);
    // Return demo fields for testing
    return [
      { id: 'field_1', type: 'signature', signerNumber: 1, placeholder: '{{sig_es_:signer1:signature}}' },
      { id: 'field_2', type: 'date', signerNumber: 1, placeholder: '{{dte_es_:signer1:date}}' },
      { id: 'field_3', type: 'signature', signerNumber: 2, placeholder: '{{sig_es_:signer2:signature}}' }
    ];
  }
  
  return fields;
}

function mapPlaceholderToType(prefix) {
  const map = {
    'sig': 'signature',
    'int': 'initials',
    'dte': 'date',
    'txt': 'text',
    'chk': 'checkbox'
  };
  return map[prefix] || 'text';
}

function buildSignerList() {
  signers.clear();
  
  documentFields.forEach(field => {
    if (!signers.has(field.signerNumber)) {
      signers.set(field.signerNumber, {
        number: field.signerNumber,
        name: '',
        email: '',
        fields: []
      });
    }
    signers.get(field.signerNumber).fields.push(field);
  });
}

// ============================================
// Cost Calculation
// ============================================

function calculateCost() {
  const signerCount = signers.size;
  const documentCount = 1; // Current document
  
  return CONFIG.pricing.baseEnvelope +
         (signerCount * CONFIG.pricing.perSigner) +
         (documentCount * CONFIG.pricing.perDocument);
}

function checkApprovalRequired(cost) {
  if (!budgetInfo) return false;
  
  const autoApprovalLimit = budgetInfo.ec_autoapprovalimit || 50;
  const monthlyLimit = budgetInfo.ec_monthlylimit || 500;
  const currentUsage = budgetInfo.ec_currentusage || 0;
  
  return cost > autoApprovalLimit || 
         (currentUsage + cost) > monthlyLimit ||
         signers.size > 10;
}

async function fetchBudgetInfo() {
  // For demo, return mock data
  return {
    ec_monthlylimit: 500,
    ec_autoapprovalimit: 50,
    ec_currentusage: 375,
    ec_approver: 'John Manager'
  };
}

// ============================================
// Rendering
// ============================================

function renderSummary(cost, needsApproval) {
  document.getElementById('docName').textContent = documentInfo?.name || 'Document';
  document.getElementById('fieldCount').textContent = documentFields.length;
  document.getElementById('signerCount').textContent = signers.size;
  document.getElementById('estimatedCost').textContent = `$${cost.toFixed(2)}`;
  
  // Show approval warning if needed
  if (needsApproval) {
    const warning = document.getElementById('budgetWarning');
    warning.style.display = 'flex';
    
    const usage = budgetInfo?.ec_currentusage || 0;
    const limit = budgetInfo?.ec_monthlylimit || 500;
    const percentage = (usage / limit) * 100;
    
    document.getElementById('budgetText').textContent = `$${usage.toFixed(0)} / $${limit.toFixed(0)}`;
    document.getElementById('budgetBarFill').style.width = `${Math.min(percentage, 100)}%`;
    document.getElementById('budgetBarFill').className = `budget-bar-fill ${percentage > 90 ? 'danger' : percentage > 75 ? 'warning' : ''}`;
    
    document.getElementById('btnSend').textContent = '📤 Submit for Approval';
  }
}

function renderSignerList() {
  const container = document.getElementById('signerList');
  
  if (signers.size === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 16px; color: var(--neutral-60);">
        <span style="font-size: 24px;">👥</span>
        <p style="margin-top: 8px;">No signers configured</p>
      </div>
    `;
    return;
  }
  
  const signingOrder = document.querySelector('input[name="signingOrder"]:checked')?.value || 'sequential';
  
  container.innerHTML = Array.from(signers.values())
    .sort((a, b) => a.number - b.number)
    .map((signer, index) => {
      const color = getSignerColor(signer.number);
      const fieldCount = signer.fields.length;
      
      return `
        <div class="signer-config-item">
          <div class="signer-config-color" style="background: ${color.bg}; border: 2px solid ${color.border}; color: ${color.border};">
            ${signer.number}
          </div>
          <div class="signer-config-info">
            <div class="signer-config-name">${signer.name || `Signer ${signer.number}`}</div>
            <div class="signer-config-email">${signer.email || 'Email not set'} • ${fieldCount} field${fieldCount !== 1 ? 's' : ''}</div>
          </div>
          ${signingOrder === 'sequential' ? 
            `<div class="signer-config-order">#${index + 1}</div>` : 
            `<div class="signer-config-order">Any</div>`
          }
        </div>
      `;
    }).join('');
}

// ============================================
// Send Envelope
// ============================================

async function sendEnvelope() {
  // Show sending view
  document.getElementById('mainView').style.display = 'none';
  document.getElementById('sendingView').style.display = 'block';
  
  try {
    // Get document content
    const documentContent = await getDocumentAsBase64();
    
    // Build request payload (Nintex-compatible format)
    const payload = buildEnvelopePayload(documentContent);
    
    // Submit to Dataverse broker
    const result = await submitToDataverse(payload);
    
    // Show appropriate result view
    if (result.status === 'PendingApproval') {
      showApprovalView(result);
    } else {
      showSuccessView(result);
    }
    
  } catch (error) {
    console.error('Error sending envelope:', error);
    showErrorView(error.message);
  }
}

function buildEnvelopePayload(documentContent) {
  const signingOrder = document.querySelector('input[name="signingOrder"]:checked')?.value || 'sequential';
  
  // Build fields array
  const fields = documentFields.map(field => ({
    fieldType: field.type,
    inputType: 'signatory',
    signer: `Signer ${field.signerNumber}`,
    label: field.type,
    placeholder: field.placeholder,
    required: true
  }));
  
  // Build signers array
  const signerList = Array.from(signers.values())
    .sort((a, b) => a.number - b.number)
    .map((signer, index) => ({
      label: `Signer ${signer.number}`,
      name: signer.name || `Signer ${signer.number}`,
      email: signer.email || '',
      signingOrder: signingOrder === 'sequential' ? index + 1 : 1,
      authenticationMethod: 'email'
    }));
  
  // Nintex-compatible payload structure
  return {
    request: {
      content: {
        envelope: {
          name: documentInfo?.name || 'Document',
          workflowType: 'custom'
        },
        documents: [{
          name: documentInfo?.name || 'Document',
          file: {
            fileToUpload: {
              data: documentContent,
              fileName: documentInfo?.name || 'Document.docx'
            },
            extension: documentInfo?.type || 'docx'
          },
          fields: fields
        }],
        signers: signerList
      },
      options: {
        signingOrder: signingOrder,
        sendEmails: true
      }
    }
  };
}

async function getDocumentAsBase64() {
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
                  // Convert to base64
                  const docData = slices.join('');
                  resolve(btoa(docData));
                }
              } else {
                file.closeAsync();
                reject(new Error('Failed to read document slice'));
              }
            });
          };
          
          if (sliceCount > 0) {
            getSlice(0);
          } else {
            file.closeAsync();
            reject(new Error('Empty document'));
          }
        } else {
          // For demo, return placeholder
          resolve('DEMO_BASE64_CONTENT');
        }
      }
    );
  });
}

async function submitToDataverse(payload) {
  // Get access token
  let token = null;
  try {
    token = await Office.auth.getAccessToken({ allowSignInPrompt: true });
  } catch (e) {
    console.log('SSO not available');
  }
  
  // For demo, simulate API call
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  const cost = calculateCost();
  const needsApproval = checkApprovalRequired(cost);
  
  if (needsApproval) {
    return {
      status: 'PendingApproval',
      envelopeId: 'ENV-2025-' + Math.random().toString(36).substr(2, 6).toUpperCase(),
      estimatedCost: cost,
      approver: budgetInfo?.ec_approver || 'Manager'
    };
  }
  
  return {
    status: 'Sent',
    envelopeId: 'ENV-2025-' + Math.random().toString(36).substr(2, 6).toUpperCase(),
    cost: cost,
    signerCount: signers.size
  };
  
  /* Production implementation:
  const response = await fetch(`${CONFIG.dataverseUrl}/api/data/${CONFIG.apiVersion}/ec_CreateAndSubmit`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'OData-MaxVersion': '4.0',
      'OData-Version': '4.0'
    },
    body: JSON.stringify({
      RequestPayload: JSON.stringify(payload)
    })
  });
  
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  
  return response.json();
  */
}

// ============================================
// Result Views
// ============================================

function showSuccessView(result) {
  document.getElementById('sendingView').style.display = 'none';
  document.getElementById('successView').style.display = 'block';
  
  const signingOrder = document.querySelector('input[name="signingOrder"]:checked')?.value || 'sequential';
  
  document.getElementById('successSigners').textContent = `${signers.size} signer${signers.size !== 1 ? 's' : ''}`;
  document.getElementById('successOrder').textContent = signingOrder === 'sequential' ? 'Sequential' : 'Any Order';
  document.getElementById('successCost').textContent = `$${result.cost?.toFixed(2) || '0.00'}`;
}

function showApprovalView(result) {
  document.getElementById('sendingView').style.display = 'none';
  document.getElementById('approvalView').style.display = 'block';
  
  document.getElementById('approvalCost').textContent = `$${result.estimatedCost?.toFixed(2) || '0.00'}`;
  document.getElementById('approverName').textContent = result.approver || 'Manager';
  document.getElementById('requestId').textContent = result.envelopeId || 'N/A';
}

function showErrorView(message) {
  document.getElementById('sendingView').style.display = 'none';
  document.getElementById('errorView').style.display = 'block';
  document.getElementById('errorMessage').textContent = message || 'An error occurred';
}

function closePane() {
  Office.context.ui.closeContainer();
}

// ============================================
// Helpers
// ============================================

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

function getSignerColor(signerNum) {
  return SIGNER_COLORS[(signerNum - 1) % 10];
}

// Update signer list when signing order changes
document.querySelectorAll('input[name="signingOrder"]').forEach(radio => {
  radio.addEventListener('change', () => renderSignerList());
});

// Expose functions globally
window.sendEnvelope = sendEnvelope;
window.closePane = closePane;
