// ============================================
// Elections Canada E-Sign Add-in
// Status Tracking - Dataverse Integration
// ============================================

'use strict';

// Configuration
const CONFIG = {
  dataverseUrl: 'https://ec-esign.crm3.dynamics.com',
  apiVersion: 'v9.2'
};

// State
let envelopes = [];
let notifications = [];
let currentFilter = 'all';
let selectedEnvelope = null;

// Initialize
Office.onReady(async (info) => {
  console.log('Status pane loaded');
  await refreshData();
});

// ============================================
// Data Fetching from Dataverse
// ============================================

async function refreshData() {
  showLoading(true);
  
  try {
    // Get access token
    const token = await getAccessToken();
    
    // Fetch envelopes
    envelopes = await fetchEnvelopes(token);
    
    // Fetch notifications
    notifications = await fetchNotifications(token);
    
    // Fetch budget info
    const budget = await fetchBudgetInfo(token);
    
    // Update UI
    renderBudgetSummary(budget);
    renderEnvelopeList();
    renderNotificationList();
    
  } catch (error) {
    console.error('Error refreshing data:', error);
    showError('Failed to load data. Please try again.');
  }
  
  showLoading(false);
}

async function getAccessToken() {
  try {
    // Try Office SSO first
    const token = await Office.auth.getAccessToken({
      allowSignInPrompt: true,
      allowConsentPrompt: true
    });
    return token;
  } catch (error) {
    console.log('SSO not available, using fallback');
    // Fallback - would implement dialog-based auth
    return null;
  }
}

async function fetchEnvelopes(token) {
  const url = `${CONFIG.dataverseUrl}/api/data/${CONFIG.apiVersion}/ec_envelopes?` +
    `$select=ec_envelopeid,ec_name,ec_status,ec_estimatedcost,ec_actualcost,ec_sentdate,ec_completeddate,ec_signercount,createdon&` +
    `$orderby=createdon desc&` +
    `$top=50&` +
    `$expand=ec_signer_envelope($select=ec_name,ec_email,ec_status,ec_signeddate)`;
  
  // For demo, return mock data if no token
  if (!token) {
    return getMockEnvelopes();
  }
  
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'OData-MaxVersion': '4.0',
      'OData-Version': '4.0',
      'Accept': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  
  const data = await response.json();
  return data.value;
}

async function fetchNotifications(token) {
  const url = `${CONFIG.dataverseUrl}/api/data/${CONFIG.apiVersion}/ec_notifications?` +
    `$select=ec_type,ec_title,ec_message,createdon&` +
    `$orderby=createdon desc&` +
    `$top=20`;
  
  if (!token) {
    return getMockNotifications();
  }
  
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'OData-MaxVersion': '4.0',
      'OData-Version': '4.0',
      'Accept': 'application/json'
    }
  });
  
  if (!response.ok) {
    return getMockNotifications();
  }
  
  const data = await response.json();
  return data.value;
}

async function fetchBudgetInfo(token) {
  if (!token) {
    return getMockBudget();
  }
  
  const url = `${CONFIG.dataverseUrl}/api/data/${CONFIG.apiVersion}/ec_budgets?` +
    `$filter=ec_period eq '${getCurrentPeriod()}'&` +
    `$select=ec_monthlylimit,ec_currentusage`;
  
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'OData-MaxVersion': '4.0',
      'OData-Version': '4.0',
      'Accept': 'application/json'
    }
  });
  
  if (!response.ok) {
    return getMockBudget();
  }
  
  const data = await response.json();
  return data.value[0] || getMockBudget();
}

// ============================================
// Mock Data (for demo/development)
// ============================================

function getMockEnvelopes() {
  return [
    {
      ec_envelopeid: '001',
      ec_name: 'Employment Agreement - John Smith',
      ec_status: 9, // Completed
      ec_estimatedcost: 4.50,
      ec_actualcost: 4.50,
      ec_sentdate: new Date(Date.now() - 86400000 * 3).toISOString(),
      ec_completeddate: new Date(Date.now() - 86400000 * 1).toISOString(),
      ec_signercount: 2,
      createdon: new Date(Date.now() - 86400000 * 3).toISOString(),
      ec_signer_envelope: [
        { ec_name: 'John Smith', ec_email: 'john@example.gc.ca', ec_status: 4, ec_signeddate: new Date(Date.now() - 86400000 * 2).toISOString() },
        { ec_name: 'Jane Manager', ec_email: 'jane@elections.ca', ec_status: 4, ec_signeddate: new Date(Date.now() - 86400000 * 1).toISOString() }
      ]
    },
    {
      ec_envelopeid: '002',
      ec_name: 'NDA - Vendor Agreement',
      ec_status: 8, // InProgress
      ec_estimatedcost: 3.50,
      ec_actualcost: 3.50,
      ec_sentdate: new Date(Date.now() - 86400000 * 1).toISOString(),
      ec_completeddate: null,
      ec_signercount: 2,
      createdon: new Date(Date.now() - 86400000 * 1).toISOString(),
      ec_signer_envelope: [
        { ec_name: 'Bob Vendor', ec_email: 'bob@vendor.com', ec_status: 4, ec_signeddate: new Date().toISOString() },
        { ec_name: 'Alice Procurement', ec_email: 'alice@elections.ca', ec_status: 2, ec_signeddate: null }
      ]
    },
    {
      ec_envelopeid: '003',
      ec_name: 'Consulting Contract - Q1 2025',
      ec_status: 7, // Sent
      ec_estimatedcost: 5.50,
      ec_actualcost: 5.50,
      ec_sentdate: new Date().toISOString(),
      ec_completeddate: null,
      ec_signercount: 3,
      createdon: new Date().toISOString(),
      ec_signer_envelope: [
        { ec_name: 'Consultant A', ec_email: 'a@consulting.com', ec_status: 2, ec_signeddate: null },
        { ec_name: 'Consultant B', ec_email: 'b@consulting.com', ec_status: 2, ec_signeddate: null },
        { ec_name: 'EC Manager', ec_email: 'manager@elections.ca', ec_status: 1, ec_signeddate: null }
      ]
    },
    {
      ec_envelopeid: '004',
      ec_name: 'Software License Agreement',
      ec_status: 3, // PendingApproval
      ec_estimatedcost: 156.00,
      ec_actualcost: null,
      ec_sentdate: null,
      ec_completeddate: null,
      ec_signercount: 50,
      createdon: new Date().toISOString(),
      ec_signer_envelope: []
    }
  ];
}

function getMockNotifications() {
  return [
    {
      ec_type: 'signed',
      ec_title: 'Document Signed',
      ec_message: 'John Smith signed "Employment Agreement"',
      createdon: new Date(Date.now() - 3600000).toISOString()
    },
    {
      ec_type: 'sent',
      ec_title: 'Envelope Sent',
      ec_message: 'NDA - Vendor Agreement sent to 2 recipients',
      createdon: new Date(Date.now() - 86400000).toISOString()
    },
    {
      ec_type: 'completed',
      ec_title: 'All Signatures Complete',
      ec_message: 'Employment Agreement is fully signed',
      createdon: new Date(Date.now() - 86400000 * 2).toISOString()
    },
    {
      ec_type: 'approval',
      ec_title: 'Approval Required',
      ec_message: 'Software License Agreement requires approval ($156.00)',
      createdon: new Date(Date.now() - 7200000).toISOString()
    }
  ];
}

function getMockBudget() {
  return {
    ec_monthlylimit: 500.00,
    ec_currentusage: 169.00
  };
}

// ============================================
// Rendering Functions
// ============================================

function renderBudgetSummary(budget) {
  const spent = budget.ec_currentusage || 0;
  const limit = budget.ec_monthlylimit || 500;
  const percentage = Math.min((spent / limit) * 100, 100);
  
  document.getElementById('monthlySpend').textContent = `$${spent.toFixed(2)}`;
  document.getElementById('budgetLimit').textContent = limit.toFixed(0);
  document.getElementById('envelopeCount').textContent = envelopes.length;
  document.getElementById('budgetProgress').style.width = `${percentage}%`;
}

function renderEnvelopeList() {
  const container = document.getElementById('envelopeList');
  
  const filtered = filterEnvelopesByStatus(envelopes, currentFilter);
  
  if (filtered.length === 0) {
    container.innerHTML = `
      <div class="empty-state-small">
        <span>📭</span>
        <p>No envelopes found</p>
      </div>
    `;
    return;
  }
  
  container.innerHTML = filtered.map(env => {
    const status = getStatusInfo(env.ec_status);
    const signedCount = (env.ec_signer_envelope || []).filter(s => s.ec_status === 4).length;
    const totalSigners = env.ec_signercount || 0;
    const progress = totalSigners > 0 ? (signedCount / totalSigners) * 100 : 0;
    
    return `
      <div class="envelope-card" onclick="openEnvelopeModal('${env.ec_envelopeid}')">
        <div class="envelope-header">
          <div>
            <div class="envelope-name">${escapeHtml(env.ec_name)}</div>
            <div class="envelope-date">${formatDate(env.createdon)}</div>
          </div>
          <span class="status-badge status-${status.class}">${status.label}</span>
        </div>
        
        <div class="envelope-signers">
          ${renderSignerChips(env.ec_signer_envelope || [])}
        </div>
        
        <div class="envelope-progress">
          <div class="progress-bar">
            <div class="progress-bar-fill" style="width: ${progress}%"></div>
          </div>
          <span class="progress-text">${signedCount}/${totalSigners} signed</span>
        </div>
      </div>
    `;
  }).join('');
}

function renderSignerChips(signers) {
  if (signers.length === 0) return '<span style="font-size: 12px; color: var(--neutral-60);">No signers assigned</span>';
  
  return signers.slice(0, 3).map(signer => {
    const isSigned = signer.ec_status === 4;
    return `
      <div class="signer-chip ${isSigned ? 'signed' : 'pending'}">
        <span class="signer-status-icon">${isSigned ? '✓' : '⏳'}</span>
        <span>${escapeHtml(signer.ec_name.split(' ')[0])}</span>
      </div>
    `;
  }).join('') + (signers.length > 3 ? `<div class="signer-chip">+${signers.length - 3} more</div>` : '');
}

function renderNotificationList() {
  const container = document.getElementById('notificationList');
  
  if (notifications.length === 0) {
    container.innerHTML = `
      <div class="empty-state-small">
        <span>🔔</span>
        <p>No recent activity</p>
      </div>
    `;
    return;
  }
  
  container.innerHTML = notifications.map(notif => {
    const icon = getNotificationIcon(notif.ec_type);
    return `
      <div class="notification-item">
        <span class="notification-icon">${icon}</span>
        <div class="notification-content">
          <div class="notification-title">${escapeHtml(notif.ec_title)}</div>
          <div class="notification-time">${formatRelativeTime(notif.createdon)}</div>
        </div>
      </div>
    `;
  }).join('');
}

// ============================================
// UI Interactions
// ============================================

function switchTab(tabName) {
  // Update tab buttons
  document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
  event.target.classList.add('active');
  
  // Update tab content
  document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
  document.getElementById(`${tabName}Tab`).classList.add('active');
}

function filterEnvelopes(filter) {
  currentFilter = filter;
  
  // Update filter buttons
  document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
  event.target.classList.add('active');
  
  renderEnvelopeList();
}

function filterEnvelopesByStatus(envelopes, filter) {
  if (filter === 'all') return envelopes;
  
  const statusMap = {
    'pending': [3, 7], // PendingApproval, Sent
    'inprogress': [8], // InProgress
    'completed': [9]   // Completed
  };
  
  return envelopes.filter(env => statusMap[filter]?.includes(env.ec_status));
}

function openEnvelopeModal(envelopeId) {
  selectedEnvelope = envelopes.find(e => e.ec_envelopeid === envelopeId);
  if (!selectedEnvelope) return;
  
  const status = getStatusInfo(selectedEnvelope.ec_status);
  
  document.getElementById('modalEnvelopeName').textContent = selectedEnvelope.ec_name;
  document.getElementById('modalStatusBadge').textContent = status.label;
  document.getElementById('modalStatusBadge').className = `status-badge status-${status.class}`;
  
  document.getElementById('modalCreatedDate').textContent = formatDate(selectedEnvelope.createdon);
  document.getElementById('modalSentDate').textContent = selectedEnvelope.ec_sentdate ? formatDate(selectedEnvelope.ec_sentdate) : '-';
  document.getElementById('modalCost').textContent = selectedEnvelope.ec_actualcost ? `$${selectedEnvelope.ec_actualcost.toFixed(2)}` : '-';
  
  // Render signers
  const signerList = document.getElementById('modalSignerList');
  signerList.innerHTML = (selectedEnvelope.ec_signer_envelope || []).map(signer => {
    const isSigned = signer.ec_status === 4;
    return `
      <div class="signer-chip ${isSigned ? 'signed' : 'pending'}" style="margin-bottom: 8px; width: 100%; justify-content: flex-start;">
        <span class="signer-status-icon">${isSigned ? '✓' : '⏳'}</span>
        <div style="flex: 1;">
          <div style="font-weight: 500;">${escapeHtml(signer.ec_name)}</div>
          <div style="font-size: 11px; color: var(--neutral-60);">${escapeHtml(signer.ec_email)}</div>
        </div>
        ${isSigned ? `<span style="font-size: 11px; color: var(--neutral-60);">${formatDate(signer.ec_signeddate)}</span>` : ''}
      </div>
    `;
  }).join('') || '<p style="color: var(--neutral-60); font-size: 12px;">No signers</p>';
  
  // Show/hide download button
  document.getElementById('modalDownloadBtn').style.display = selectedEnvelope.ec_status === 9 ? 'block' : 'none';
  
  document.getElementById('envelopeModal').style.display = 'flex';
}

function closeEnvelopeModal() {
  document.getElementById('envelopeModal').style.display = 'none';
  selectedEnvelope = null;
}

async function downloadSignedDoc() {
  if (!selectedEnvelope) return;
  
  // Would call Dataverse to get signed document
  alert(`Downloading signed document for: ${selectedEnvelope.ec_name}`);
}

// ============================================
// Helpers
// ============================================

function getStatusInfo(statusCode) {
  const statuses = {
    1: { label: 'Draft', class: 'draft' },
    2: { label: 'Validating', class: 'pending' },
    3: { label: 'Pending Approval', class: 'pending' },
    4: { label: 'Approved', class: 'sent' },
    5: { label: 'Rejected', class: 'declined' },
    6: { label: 'Sending', class: 'sent' },
    7: { label: 'Sent', class: 'sent' },
    8: { label: 'In Progress', class: 'inprogress' },
    9: { label: 'Completed', class: 'completed' },
    10: { label: 'Declined', class: 'declined' },
    11: { label: 'Expired', class: 'expired' },
    12: { label: 'Cancelled', class: 'expired' }
  };
  return statuses[statusCode] || { label: 'Unknown', class: 'draft' };
}

function getNotificationIcon(type) {
  const icons = {
    'signed': '✍️',
    'sent': '📤',
    'completed': '✅',
    'declined': '❌',
    'approval': '⏳',
    'reminder': '🔔'
  };
  return icons[type] || '📋';
}

function formatDate(dateString) {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleDateString('en-CA', { 
    month: 'short', 
    day: 'numeric',
    year: date.getFullYear() !== new Date().getFullYear() ? 'numeric' : undefined
  });
}

function formatRelativeTime(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now - date;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  return formatDate(dateString);
}

function getCurrentPeriod() {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function showLoading(show) {
  // Could implement loading overlay
}

function showError(message) {
  console.error(message);
}

// Expose functions globally
window.refreshData = refreshData;
window.switchTab = switchTab;
window.filterEnvelopes = filterEnvelopes;
window.openEnvelopeModal = openEnvelopeModal;
window.closeEnvelopeModal = closeEnvelopeModal;
window.downloadSignedDoc = downloadSignedDoc;
