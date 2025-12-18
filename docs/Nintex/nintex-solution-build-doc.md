# Nintex E-Sign Power Pages Portal & Office Add-in
## Elections Canada Platform Engineering Team

---

## Document Information

| Field | Value |
|-------|-------|
| Version | 3.0 |
| Author | Elections Canada - Platform Engineering Team |
| Last Updated | December 2025 |
| Status | Draft |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Power Pages Site Setup](#3-power-pages-site-setup)
4. [GCWeb Theme Implementation](#4-gcweb-theme-implementation)
5. [Page Templates & Web Templates](#5-page-templates--web-templates)
6. [JavaScript Implementation](#6-javascript-implementation)
7. [Dataverse Integration](#7-dataverse-integration)
8. [Office Add-in Integration](#8-office-add-in-integration)
9. [Security & Permissions](#9-security--permissions)
10. [Approval Workflow & Cost Controls](#10-approval-workflow--cost-controls)
11. [Programmatic API Access](#11-programmatic-api-access)
12. [Deployment Guide](#12-deployment-guide)
13. [Appendix](#13-appendix)

---

## 1. Executive Summary

### 1.1 Purpose

This document provides the technical implementation guide for Elections Canada's Nintex AssureSign e-signature solution, built on **Power Pages** with the **GCWeb (Government of Canada)** theme. The solution includes:

- **Power Pages Portal** — Web-based interface for managing e-signatures, viewing status, and approvals
- **Office Add-in** — Ribbon integration for Word/Excel that embeds Power Pages in task panes
- **Dataverse Broker Service** — Centralized gateway with governance controls
- **GCWeb Compliance** — Full Government of Canada Web Experience Toolkit (WET) theming

### 1.2 Why Power Pages?

| Benefit | Description |
|---------|-------------|
| **Native Dataverse** | Direct integration with Dataverse tables, no custom API layer needed |
| **GCWeb Ready** | WET templates available, meets GC accessibility standards |
| **Dual Use** | Same pages work standalone AND embedded in Office Add-in |
| **Authentication** | Azure AD B2C, SAML, or internal authentication built-in |
| **Model-Driven** | Entity forms, entity lists, and web forms for rapid development |

### 1.3 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACES                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────────┐    ┌─────────────────────────────────────────┐   │
│   │   Office Add-in     │    │        Power Pages Portal               │   │
│   │  (Word/Excel/PDF)   │    │     (GCWeb Theme - WET 4.0)            │   │
│   │                     │    │                                         │   │
│   │  ┌───────────────┐  │    │  ┌─────────────────────────────────┐   │   │
│   │  │  Task Pane    │──┼────┼─►│  /esign/send                    │   │   │
│   │  │  (iframe)     │  │    │  │  /esign/status                  │   │   │
│   │  └───────────────┘  │    │  │  /esign/manage                  │   │   │
│   └─────────────────────┘    │  │  /esign/templates               │   │   │
│                              │  │  /esign/approvals               │   │   │
│                              │  └─────────────────────────────────┘   │   │
│                              └─────────────────────────────────────────┘   │
│                                              │                              │
└──────────────────────────────────────────────│──────────────────────────────┘
                                               │
                                               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATAVERSE (Power Platform)                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      Web API / OData                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                │                                            │
│  ┌─────────────┐  ┌───────────┴────────────┐  ┌────────────────────────┐   │
│  │  Plugins    │  │   Custom Actions       │  │    Power Automate      │   │
│  │  (C#)       │◄─┤   ec_CreateEnvelope    │─►│    Approval Flows      │   │
│  └─────────────┘  │   ec_SubmitEnvelope    │  │    Notifications       │   │
│                   └────────────────────────┘  └────────────────────────┘   │
│                                │                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATAVERSE TABLES                                  │   │
│  │  ec_envelopes │ ec_signers │ ec_fields │ ec_approvals │ ec_budget   │   │
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

### 2.1 Component Responsibilities

| Component | Technology | Responsibility |
|-----------|------------|----------------|
| **Power Pages Portal** | Power Pages + GCWeb | Web UI for all e-sign operations |
| **Office Add-in** | Office.js + iframe | Embed Power Pages in Word/Excel task pane |
| **Dataverse** | Power Platform | Data storage, business logic, API |
| **Power Automate** | Cloud Flows | Approval workflows, notifications |
| **Azure Key Vault** | Azure | Nintex API credential storage |
| **Nintex AssureSign** | SaaS | Document processing, signature capture |

### 2.2 URL Structure

| URL | Purpose | Mode |
|-----|---------|------|
| `/esign` | Dashboard / Home | Both |
| `/esign/send` | Send envelope dialog | Both |
| `/esign/status` | View envelope status | Both |
| `/esign/manage` | Manage signature fields | Add-in only |
| `/esign/templates` | Template management | Portal only |
| `/esign/approvals` | Pending approvals | Portal only |
| `/esign/reports` | Usage reports | Portal only |

### 2.3 Mode Detection

The portal pages detect whether they're running inside an Office Add-in or standalone:

```javascript
// Detect if running in Office Add-in
function isAddinMode() {
  return typeof Office !== 'undefined' && 
         Office.context && 
         Office.context.host;
}

// Apply appropriate styles
if (isAddinMode()) {
  document.body.classList.add('addin-mode');
  // Hide portal navigation
  document.querySelector('#wb-sm').style.display = 'none';
}
```

---

## 3. Power Pages Site Setup

### 3.1 Prerequisites

- Power Platform environment (Canadian region - crm3.dynamics.com)
- Power Pages license
- Dataverse with solution imported
- GCWeb/WET theme files

### 3.2 Create Power Pages Site

```powershell
# PowerShell - Create Power Pages site using PAC CLI
pac paportal create `
    --name "EC-ESign-Portal" `
    --website-template "Blank" `
    --custom-hostname "esign.elections.ca" `
    --environment "https://ec-esign.crm3.dynamics.com"
```

### 3.3 Site Settings

Configure these site settings in Power Pages Management:

| Name | Value | Description |
|------|-------|-------------|
| `Site/HeaderTemplate` | `EC-GCWeb-Header` | GCWeb header template |
| `Site/FooterTemplate` | `EC-GCWeb-Footer` | GCWeb footer template |
| `Authentication/Registration/Enabled` | `false` | Disable self-registration |
| `Authentication/OpenIdConnect/OIDC-AAD/Enabled` | `true` | Enable Azure AD |
| `HTTP/X-Frame-Options` | `ALLOW-FROM https://your-tenant.sharepoint.com` | Allow Office embedding |
| `HTTP/Content-Security-Policy` | `frame-ancestors 'self' https://*.office.com https://*.microsoft.com` | CSP for Office |

### 3.4 Content Snippets

Create these content snippets for reusable text:

| Name | Value |
|------|-------|
| `ESign/SiteName` | `Elections Canada E-Sign` |
| `ESign/SupportEmail` | `esign-support@elections.ca` |
| `ESign/PricingBase` | `2.50` |
| `ESign/PricingPerSigner` | `1.00` |
| `ESign/PricingPerDocument` | `0.50` |

---

## 4. GCWeb Theme Implementation

### 4.1 Theme Structure

The GCWeb theme follows the Government of Canada Web Experience Toolkit (WET) 4.0 standards:

```
Portal Custom Files/
├── css/
│   ├── wet-boew.min.css         # WET base styles
│   ├── theme.min.css            # GCWeb theme
│   ├── esign-custom.css         # E-Sign customizations
│   └── esign-addin.css          # Add-in specific overrides
├── js/
│   ├── wet-boew.min.js          # WET JavaScript
│   ├── esign-common.js          # Shared E-Sign functions
│   ├── esign-send.js            # Send envelope logic
│   ├── esign-status.js          # Status tracking
│   └── esign-manage.js          # Field management
├── img/
│   ├── sig-canada.svg           # Canada wordmark
│   └── esign-icons.svg          # Custom icons
└── fonts/
    └── noto-sans/               # GC standard font
```

### 4.2 Base Layout Web Template (EC-GCWeb-Layout)

Create a Web Template named `EC-GCWeb-Layout`:

```html
<!DOCTYPE html>
<html class="no-js" lang="{{ page.language.code }}" dir="ltr">
<head>
  <meta charset="utf-8">
  <title>{{ page.title }} - {{ snippets['ESign/SiteName'] }}</title>
  <meta content="width=device-width, initial-scale=1" name="viewport">
  
  <!-- Load WET/GCWeb theme -->
  <link rel="stylesheet" href="https://wet-boew.github.io/themes-dist/GCWeb/css/theme.min.css">
  <link rel="stylesheet" href="~/css/wet-boew.min.css">
  <link rel="stylesheet" href="~/css/esign-custom.css">
  
  <!-- Noscript fallback -->
  <noscript><link rel="stylesheet" href="~/css/noscript.min.css"></noscript>
  
  <!-- Favicon -->
  <link rel="icon" type="image/x-icon" href="~/img/favicon.ico">
  
  {% if request.params['addin'] == 'true' %}
  <!-- Office.js for Add-in mode -->
  <script src="https://appsforoffice.microsoft.com/lib/1.1/hosted/office.js"></script>
  <link rel="stylesheet" href="~/css/esign-addin.css">
  {% endif %}
</head>
<body vocab="http://schema.org/" typeof="WebPage" class="{% if request.params['addin'] == 'true' %}addin-mode{% endif %}">

  <!-- Skip to main content -->
  <nav>
    <ul id="wb-tphp">
      <li class="wb-slc"><a class="wb-sl" href="#wb-cont">Skip to main content</a></li>
    </ul>
  </nav>

  {% unless request.params['addin'] == 'true' %}
  <!-- GCWeb Header (hidden in add-in mode) -->
  {% include 'EC-GCWeb-Header' %}
  {% endunless %}

  <main property="mainContentOfPage" typeof="WebPageElement" class="container">
    
    <!-- Breadcrumb (hidden in add-in mode) -->
    {% unless request.params['addin'] == 'true' %}
    <nav id="wb-bc" property="breadcrumb">
      <h2>You are here:</h2>
      <div class="container">
        <ol class="breadcrumb">
          <li><a href="/">Home</a></li>
          <li><a href="/esign">E-Sign</a></li>
          {% if page.parent %}
          <li><a href="{{ page.parent.url }}">{{ page.parent.title }}</a></li>
          {% endif %}
        </ol>
      </div>
    </nav>
    {% endunless %}
    
    <!-- Page Content -->
    <div class="row">
      <div class="{% if request.params['addin'] == 'true' %}col-xs-12{% else %}col-md-9 col-md-push-3{% endif %}">
        
        <!-- Page Title -->
        <h1 property="name" id="wb-cont">{{ page.title }}</h1>
        
        <!-- Main Content -->
        {{ page.content }}
        
      </div>
      
      {% unless request.params['addin'] == 'true' %}
      <!-- Sidebar (hidden in add-in mode) -->
      <div class="col-md-3 col-md-pull-9">
        {% include 'EC-ESign-Sidebar' %}
      </div>
      {% endunless %}
    </div>
    
  </main>

  {% unless request.params['addin'] == 'true' %}
  <!-- GCWeb Footer (hidden in add-in mode) -->
  {% include 'EC-GCWeb-Footer' %}
  {% endunless %}

  <!-- Scripts -->
  <script src="https://wet-boew.github.io/themes-dist/GCWeb/js/wet-boew.min.js"></script>
  <script src="~/js/esign-common.js"></script>
  
  {% if request.params['addin'] == 'true' %}
  <script>
    // Initialize Office.js
    Office.onReady(function(info) {
      console.log('Office ready:', info.host);
      document.body.classList.add('office-' + info.host.toLowerCase());
    });
  </script>
  {% endif %}
  
</body>
</html>
```

### 4.3 Header Web Template (EC-GCWeb-Header)

```html
<header>
  <div id="wb-bnr" class="container">
    <div class="row">
      
      <!-- Government of Canada branding -->
      <section id="wb-lng" class="col-xs-3 col-sm-12 pull-right text-right">
        <h2 class="wb-inv">Language selection</h2>
        <ul class="list-inline mrgn-bttm-0">
          <li>
            {% if page.language.code == 'en' %}
            <a lang="fr" hreflang="fr" href="{{ page.url }}?lang=fr">
              <span class="hidden-xs">Français</span>
              <abbr title="Français" class="visible-xs h3 mrgn-tp-sm mrgn-bttm-0 text-uppercase">fr</abbr>
            </a>
            {% else %}
            <a lang="en" hreflang="en" href="{{ page.url }}?lang=en">
              <span class="hidden-xs">English</span>
              <abbr title="English" class="visible-xs h3 mrgn-tp-sm mrgn-bttm-0 text-uppercase">en</abbr>
            </a>
            {% endif %}
          </li>
        </ul>
      </section>
      
      <div class="brand col-xs-9 col-sm-5 col-md-4" property="publisher" typeof="GovernmentOrganization">
        <a href="https://www.canada.ca/en.html" property="url">
          <img src="https://wet-boew.github.io/themes-dist/GCWeb/GCWeb/assets/sig-blk-en.svg" 
               alt="Government of Canada" property="logo">
        </a>
        <meta property="name" content="Government of Canada">
        <meta property="areaServed" typeof="Country" content="Canada">
      </div>
      
      <section id="wb-srch" class="col-lg-offset-4 col-md-offset-4 col-sm-offset-2 col-xs-12 col-sm-5 col-md-4">
        <h2>Search</h2>
        <form action="/search" method="get" role="search">
          <div class="form-group wb-srch-qry">
            <label for="wb-srch-q" class="wb-inv">Search E-Sign</label>
            <input id="wb-srch-q" class="wb-srch-q form-control" name="q" type="search" 
                   value="" size="34" maxlength="170" placeholder="Search E-Sign">
          </div>
          <button type="submit" class="btn btn-primary btn-small" name="wb-srch-sub">
            <span class="glyphicon-search glyphicon"></span>
            <span class="wb-inv">Search</span>
          </button>
        </form>
      </section>
      
    </div>
  </div>
  
  <!-- Site Menu -->
  <nav id="wb-sm" data-trgt="mb-pnl" class="wb-menu visible-md visible-lg" typeof="SiteNavigationElement">
    <div class="container nvbar">
      <h2>Topics menu</h2>
      <div class="row">
        <ul class="list-inline menu" role="menubar">
          <li>
            <a href="/esign" class="item">
              <span class="glyphicon glyphicon-home"></span> Dashboard
            </a>
          </li>
          <li>
            <a href="/esign/send" class="item">
              <span class="glyphicon glyphicon-send"></span> Send
            </a>
          </li>
          <li>
            <a href="/esign/status" class="item">
              <span class="glyphicon glyphicon-list-alt"></span> Status
            </a>
          </li>
          <li>
            <a href="/esign/templates" class="item">
              <span class="glyphicon glyphicon-duplicate"></span> Templates
            </a>
          </li>
          <li>
            <a href="/esign/approvals" class="item">
              <span class="glyphicon glyphicon-ok-circle"></span> Approvals
              {% assign pending_count = entities.ec_approvals | where: 'ec_status', 1 | size %}
              {% if pending_count > 0 %}
              <span class="badge">{{ pending_count }}</span>
              {% endif %}
            </a>
          </li>
          <li>
            <a href="/esign/reports" class="item">
              <span class="glyphicon glyphicon-stats"></span> Reports
            </a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
  
  <!-- User Info Bar -->
  <div class="container">
    <div class="row">
      <div class="col-xs-12">
        <div class="well well-sm mrgn-tp-sm mrgn-bttm-sm">
          <div class="row">
            <div class="col-sm-8">
              <strong>{{ snippets['ESign/SiteName'] }}</strong>
              {% if user %}
              <span class="text-muted"> | Logged in as {{ user.fullname }}</span>
              {% endif %}
            </div>
            <div class="col-sm-4 text-right">
              {% if user %}
              <a href="/SignOut" class="btn btn-default btn-xs">Sign Out</a>
              {% else %}
              <a href="/SignIn" class="btn btn-primary btn-xs">Sign In</a>
              {% endif %}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</header>
```

### 4.4 Footer Web Template (EC-GCWeb-Footer)

```html
<footer id="wb-info">
  <h2 class="wb-inv">About this site</h2>
  
  <div class="gc-main-footer">
    <div class="container">
      <nav>
        <h3>Government of Canada</h3>
        <ul class="list-col-xs-1 list-col-sm-2 list-col-md-3">
          <li><a href="https://www.canada.ca/en/contact.html">Contact us</a></li>
          <li><a href="https://www.canada.ca/en/government/dept.html">Departments and agencies</a></li>
          <li><a href="https://www.canada.ca/en/government/publicservice.html">Public service and military</a></li>
          <li><a href="https://www.canada.ca/en/news.html">News</a></li>
          <li><a href="https://www.canada.ca/en/government/system/laws.html">Treaties, laws and regulations</a></li>
          <li><a href="https://www.canada.ca/en/transparency/reporting.html">Government-wide reporting</a></li>
          <li><a href="https://pm.gc.ca/eng">Prime Minister</a></li>
          <li><a href="https://www.canada.ca/en/government/system.html">About government</a></li>
          <li><a href="https://open.canada.ca/en/">Open government</a></li>
        </ul>
      </nav>
    </div>
  </div>
  
  <div class="gc-sub-footer">
    <div class="container d-flex align-items-center">
      <nav>
        <h3 class="wb-inv">About Elections Canada E-Sign</h3>
        <ul>
          <li><a href="/esign/help">Help</a></li>
          <li><a href="/esign/privacy">Privacy</a></li>
          <li><a href="/esign/terms">Terms and conditions</a></li>
        </ul>
      </nav>
      <div class="wtrmrk align-self-end">
        <img src="https://wet-boew.github.io/themes-dist/GCWeb/GCWeb/assets/wmms-blk.svg" alt="Symbol of the Government of Canada">
      </div>
    </div>
  </div>
</footer>
```

### 4.5 Custom CSS (esign-custom.css)

```css
/* ============================================
   Elections Canada E-Sign Portal
   Custom Styles (GCWeb Extension)
   ============================================ */

/* ============================================
   Signer Colors
   ============================================ */
:root {
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
}

.signer-1 { background: var(--signer-1) !important; border-color: var(--signer-1-dark) !important; }
.signer-2 { background: var(--signer-2) !important; border-color: var(--signer-2-dark) !important; }
.signer-3 { background: var(--signer-3) !important; border-color: var(--signer-3-dark) !important; }
.signer-4 { background: var(--signer-4) !important; border-color: var(--signer-4-dark) !important; }
.signer-5 { background: var(--signer-5) !important; border-color: var(--signer-5-dark) !important; }
.signer-6 { background: var(--signer-6) !important; border-color: var(--signer-6-dark) !important; }
.signer-7 { background: var(--signer-7) !important; border-color: var(--signer-7-dark) !important; }
.signer-8 { background: var(--signer-8) !important; border-color: var(--signer-8-dark) !important; }
.signer-9 { background: var(--signer-9) !important; border-color: var(--signer-9-dark) !important; }
.signer-10 { background: var(--signer-10) !important; border-color: var(--signer-10-dark) !important; }

/* ============================================
   E-Sign Components
   ============================================ */

/* Field Grid */
.esign-field-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 20px;
}

.esign-field-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 15px 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: #fff;
  cursor: pointer;
  transition: all 0.15s ease;
  text-decoration: none;
  color: #333;
}

.esign-field-btn:hover {
  border-color: #2572b4;
  background: #f5f5f5;
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  text-decoration: none;
}

.esign-field-btn:focus {
  outline: 3px solid #ffbf47;
  outline-offset: 0;
}

.esign-field-btn .field-icon {
  font-size: 24px;
  margin-bottom: 5px;
}

.esign-field-btn .field-label {
  font-size: 12px;
  font-weight: 600;
}

/* Summary Card */
.esign-summary-card {
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 20px;
}

.esign-summary-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #eee;
}

.esign-summary-row:last-child {
  border-bottom: none;
}

.esign-summary-label {
  color: #5c5c5c;
  font-size: 14px;
}

.esign-summary-value {
  font-weight: 600;
  font-size: 14px;
}

.esign-cost-highlight {
  font-size: 18px;
  color: #2572b4;
  font-weight: 700;
}

/* Signer Configuration */
.esign-signer-config {
  display: flex;
  align-items: center;
  padding: 10px 15px;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-bottom: 10px;
}

.esign-signer-number {
  width: 32px;
  height: 32px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  margin-right: 15px;
  border: 2px solid;
}

.esign-signer-details {
  flex: 1;
}

.esign-signer-name {
  font-weight: 600;
  font-size: 14px;
}

.esign-signer-email {
  font-size: 12px;
  color: #5c5c5c;
}

.esign-signer-order {
  font-size: 12px;
  color: #5c5c5c;
  padding: 2px 8px;
  background: #f5f5f5;
  border-radius: 10px;
}

/* Radio Cards */
.esign-radio-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.esign-radio-card {
  display: block;
  cursor: pointer;
}

.esign-radio-card input {
  position: absolute;
  opacity: 0;
}

.esign-radio-card-content {
  display: flex;
  align-items: center;
  padding: 15px;
  border: 2px solid #ddd;
  border-radius: 4px;
  transition: all 0.15s ease;
}

.esign-radio-card input:checked + .esign-radio-card-content {
  border-color: #2572b4;
  background: #f0f7fc;
}

.esign-radio-card input:focus + .esign-radio-card-content {
  outline: 3px solid #ffbf47;
  outline-offset: 0;
}

.esign-radio-card-icon {
  font-size: 24px;
  margin-right: 15px;
}

.esign-radio-card-text {
  flex: 1;
}

.esign-radio-card-text strong {
  display: block;
  margin-bottom: 2px;
}

.esign-radio-card-text span {
  font-size: 12px;
  color: #5c5c5c;
}

.esign-radio-indicator {
  width: 20px;
  height: 20px;
  border: 2px solid #ddd;
  border-radius: 50%;
  position: relative;
}

.esign-radio-card input:checked + .esign-radio-card-content .esign-radio-indicator {
  border-color: #2572b4;
}

.esign-radio-card input:checked + .esign-radio-card-content .esign-radio-indicator::after {
  content: '';
  position: absolute;
  top: 3px;
  left: 3px;
  width: 10px;
  height: 10px;
  background: #2572b4;
  border-radius: 50%;
}

/* Status Badges */
.esign-status-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
}

.esign-status-draft { background: #f3f3f3; color: #5c5c5c; }
.esign-status-pending { background: #fff4ce; color: #8a6914; }
.esign-status-sent { background: #d4edfc; color: #2572b4; }
.esign-status-inprogress { background: #e5f2ff; color: #2572b4; }
.esign-status-completed { background: #d8eeca; color: #278400; }
.esign-status-declined { background: #f3e4e5; color: #d3080c; }
.esign-status-expired { background: #f3f3f3; color: #5c5c5c; }

/* Envelope Card */
.esign-envelope-card {
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 15px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.esign-envelope-card:hover {
  border-color: #2572b4;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.esign-envelope-card:focus {
  outline: 3px solid #ffbf47;
  outline-offset: 0;
}

.esign-envelope-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 10px;
}

.esign-envelope-name {
  font-weight: 600;
  font-size: 14px;
  margin-bottom: 4px;
}

.esign-envelope-date {
  font-size: 12px;
  color: #5c5c5c;
}

/* Progress Bar */
.esign-progress {
  display: flex;
  align-items: center;
  gap: 10px;
}

.esign-progress-bar {
  flex: 1;
  height: 6px;
  background: #eee;
  border-radius: 3px;
  overflow: hidden;
}

.esign-progress-bar-fill {
  height: 100%;
  background: #278400;
  transition: width 0.3s;
}

.esign-progress-text {
  font-size: 11px;
  color: #5c5c5c;
  white-space: nowrap;
}

/* Budget Card */
.esign-budget-card {
  background: linear-gradient(135deg, #2572b4 0%, #1a4d7c 100%);
  color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.esign-budget-card h3 {
  font-size: 12px;
  font-weight: 400;
  opacity: 0.9;
  margin: 0 0 5px 0;
}

.esign-budget-amount {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 15px;
}

.esign-budget-details {
  display: flex;
  justify-content: space-between;
  padding-top: 15px;
  border-top: 1px solid rgba(255,255,255,0.2);
  font-size: 12px;
}

/* Success/Error Views */
.esign-result-view {
  text-align: center;
  padding: 40px 20px;
}

.esign-result-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  margin: 0 auto 20px;
}

.esign-result-icon.success {
  background: #278400;
  color: #fff;
}

.esign-result-icon.warning {
  background: #ee7100;
  color: #fff;
}

.esign-result-icon.error {
  background: #d3080c;
  color: #fff;
}

.esign-result-view h2 {
  margin-bottom: 10px;
}

.esign-result-view p {
  color: #5c5c5c;
}

/* Warning Box */
.esign-warning-box {
  background: #f9f4d4;
  border: 1px solid #f2d40d;
  border-left: 4px solid #f2d40d;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 20px;
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.esign-warning-icon {
  font-size: 20px;
  color: #8a6914;
}

.esign-warning-text {
  flex: 1;
}

.esign-warning-text strong {
  display: block;
  margin-bottom: 5px;
  color: #8a6914;
}

/* Modal Adjustments */
.esign-modal .modal-dialog {
  max-width: 400px;
}

.esign-modal .modal-body {
  padding: 20px;
}

/* Spinner */
.esign-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #eee;
  border-top-color: #2572b4;
  border-radius: 50%;
  animation: esign-spin 1s linear infinite;
  margin: 20px auto;
}

@keyframes esign-spin {
  to { transform: rotate(360deg); }
}

/* ============================================
   Responsive Adjustments
   ============================================ */
@media (max-width: 767px) {
  .esign-field-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .esign-envelope-header {
    flex-direction: column;
    gap: 10px;
  }
}
```

### 4.6 Add-in Mode CSS (esign-addin.css)

```css
/* ============================================
   Office Add-in Mode Overrides
   ============================================ */

/* When running in Office Add-in task pane */
.addin-mode {
  /* Remove GCWeb header/footer spacing */
  padding: 0 !important;
  margin: 0 !important;
  min-height: auto !important;
}

/* Hide elements not needed in add-in */
.addin-mode #wb-bnr,
.addin-mode #wb-sm,
.addin-mode #wb-bc,
.addin-mode #wb-info,
.addin-mode .gc-main-footer,
.addin-mode .gc-sub-footer {
  display: none !important;
}

/* Compact container */
.addin-mode .container {
  width: 100% !important;
  max-width: none !important;
  padding: 15px !important;
}

/* Adjust main content */
.addin-mode main {
  padding: 0 !important;
  margin: 0 !important;
}

/* Compact headings */
.addin-mode h1 {
  font-size: 18px !important;
  margin-bottom: 15px !important;
}

.addin-mode h2 {
  font-size: 14px !important;
  margin-bottom: 10px !important;
}

/* Tighter spacing */
.addin-mode .esign-summary-card,
.addin-mode .esign-envelope-card {
  padding: 12px !important;
}

.addin-mode .esign-field-grid {
  gap: 8px !important;
}

.addin-mode .esign-field-btn {
  padding: 12px 8px !important;
}

.addin-mode .esign-field-btn .field-icon {
  font-size: 20px !important;
}

.addin-mode .esign-field-btn .field-label {
  font-size: 11px !important;
}

/* Office host-specific adjustments */
.addin-mode.office-word .esign-manage-section {
  display: block;
}

.addin-mode.office-excel .esign-manage-section {
  display: none; /* Hide field management in Excel */
}

/* Task pane scrolling */
.addin-mode {
  overflow-y: auto;
  max-height: 100vh;
}

/* Button adjustments */
.addin-mode .btn-block {
  margin-bottom: 10px !important;
}
```

---

## 5. Page Templates & Web Templates

### 5.1 Page Structure

| Page | Template | URL | Purpose |
|------|----------|-----|---------|
| E-Sign Dashboard | EC-ESign-Dashboard | `/esign` | Home page with quick actions |
| Send Envelope | EC-ESign-Send | `/esign/send` | Send documents for signature |
| View Status | EC-ESign-Status | `/esign/status` | Track envelope status |
| Manage Fields | EC-ESign-Manage | `/esign/manage` | Configure signature fields |
| Templates | EC-ESign-Templates | `/esign/templates` | Manage reusable templates |
| Pending Approvals | EC-ESign-Approvals | `/esign/approvals` | Approve/reject requests |
| Reports | EC-ESign-Reports | `/esign/reports` | Usage and cost reports |

### 5.2 Send Envelope Page Template (EC-ESign-Send)

Create a Web Template named `EC-ESign-Send`:

```html
{% extends 'EC-GCWeb-Layout' %}

{% block content %}
<div id="esign-send-app">
  
  <!-- Loading State -->
  <div id="loadingState" class="text-center" style="padding: 40px;">
    <div class="esign-spinner"></div>
    <p class="mrgn-tp-md text-muted">Analyzing document...</p>
  </div>
  
  <!-- Main Content -->
  <div id="mainView" style="display: none;">
    
    <!-- Summary Section -->
    <section class="mrgn-bttm-lg">
      <h2><span class="glyphicon glyphicon-list-alt"></span> Summary</h2>
      <div class="esign-summary-card">
        <div class="esign-summary-row">
          <span class="esign-summary-label">Document</span>
          <span class="esign-summary-value" id="docName">-</span>
        </div>
        <div class="esign-summary-row">
          <span class="esign-summary-label">Fields</span>
          <span class="esign-summary-value" id="fieldCount">0</span>
        </div>
        <div class="esign-summary-row">
          <span class="esign-summary-label">Signers</span>
          <span class="esign-summary-value" id="signerCount">0</span>
        </div>
        <div class="esign-summary-row">
          <span class="esign-summary-label">Estimated Cost</span>
          <span class="esign-summary-value esign-cost-highlight" id="estimatedCost">$0.00</span>
        </div>
      </div>
    </section>
    
    <!-- Budget Warning -->
    <div id="budgetWarning" class="esign-warning-box" style="display: none;">
      <span class="esign-warning-icon">⚠️</span>
      <div class="esign-warning-text">
        <strong>Approval Required</strong>
        <span id="budgetWarningText">This request exceeds your auto-approval limit.</span>
        <div class="mrgn-tp-sm">
          <span class="text-muted small">Monthly Budget Used</span>
          <div class="esign-progress-bar mrgn-tp-sm" style="height: 8px;">
            <div class="esign-progress-bar-fill" id="budgetBarFill" style="width: 0%; background: #ee7100;"></div>
          </div>
          <span id="budgetText" class="small text-muted">$0 / $500</span>
        </div>
      </div>
    </div>
    
    <!-- Signing Order Section -->
    <section class="mrgn-bttm-lg">
      <h2><span class="glyphicon glyphicon-sort"></span> Signing Order</h2>
      <div class="esign-radio-group">
        
        <label class="esign-radio-card">
          <input type="radio" name="signingOrder" value="sequential" checked>
          <div class="esign-radio-card-content">
            <span class="esign-radio-card-icon">1️⃣➡️2️⃣</span>
            <div class="esign-radio-card-text">
              <strong>Sequential</strong>
              <span>Signer 1 signs first, then Signer 2, etc.</span>
            </div>
            <div class="esign-radio-indicator"></div>
          </div>
        </label>
        
        <label class="esign-radio-card">
          <input type="radio" name="signingOrder" value="parallel">
          <div class="esign-radio-card-content">
            <span class="esign-radio-card-icon">1️⃣2️⃣3️⃣</span>
            <div class="esign-radio-card-text">
              <strong>Any Order</strong>
              <span>All signers notified at the same time</span>
            </div>
            <div class="esign-radio-indicator"></div>
          </div>
        </label>
        
      </div>
    </section>
    
    <!-- Signers Section -->
    <section class="mrgn-bttm-lg">
      <h2><span class="glyphicon glyphicon-user"></span> Signers</h2>
      <div id="signerList">
        <p class="text-muted">No signers configured</p>
      </div>
      <p class="small text-muted mrgn-tp-sm">
        <span class="glyphicon glyphicon-info-sign"></span>
        Click "Manage Fields" to update signer details
      </p>
    </section>
    
    <!-- Action Buttons -->
    <section>
      <div class="row">
        <div class="col-xs-6">
          <button type="button" class="btn btn-default btn-block" onclick="ESign.cancel()">
            Cancel
          </button>
        </div>
        <div class="col-xs-6">
          <button type="button" class="btn btn-primary btn-block" id="btnSend" onclick="ESign.sendEnvelope()">
            <span class="glyphicon glyphicon-send"></span> Send Envelope
          </button>
        </div>
      </div>
    </section>
    
  </div>
  
  <!-- Sending View -->
  <div id="sendingView" style="display: none;">
    <div class="esign-result-view">
      <div class="esign-spinner"></div>
      <h2>Sending...</h2>
      <p>Please wait while we process your request</p>
    </div>
  </div>
  
  <!-- Success View -->
  <div id="successView" style="display: none;">
    <div class="esign-result-view">
      <div class="esign-result-icon success">✓</div>
      <h2>Envelope Sent!</h2>
      <p>Your document has been sent for signature</p>
      
      <div class="well mrgn-tp-lg mrgn-bttm-lg">
        <div class="row">
          <div class="col-xs-4 text-center">
            <span class="glyphicon glyphicon-user"></span><br>
            <span id="successSigners">0 signers</span>
          </div>
          <div class="col-xs-4 text-center">
            <span class="glyphicon glyphicon-sort"></span><br>
            <span id="successOrder">Sequential</span>
          </div>
          <div class="col-xs-4 text-center">
            <span class="glyphicon glyphicon-usd"></span><br>
            <span id="successCost">$0.00</span>
          </div>
        </div>
      </div>
      
      <p class="small text-muted">
        Recipients will receive email notifications shortly.<br>
        Track status in the E-Sign dashboard.
      </p>
      
      <button type="button" class="btn btn-primary mrgn-tp-lg" onclick="ESign.done()">
        <span class="glyphicon glyphicon-ok"></span> Done
      </button>
    </div>
  </div>
  
  <!-- Pending Approval View -->
  <div id="approvalView" style="display: none;">
    <div class="esign-result-view">
      <div class="esign-result-icon warning">⏳</div>
      <h2>Pending Approval</h2>
      <p>Your request has been submitted for approval</p>
      
      <div class="esign-summary-card mrgn-tp-lg mrgn-bttm-lg" style="text-align: left;">
        <div class="esign-summary-row">
          <span class="esign-summary-label">Estimated Cost</span>
          <span class="esign-summary-value" id="approvalCost">$0.00</span>
        </div>
        <div class="esign-summary-row">
          <span class="esign-summary-label">Approver</span>
          <span class="esign-summary-value" id="approverName">-</span>
        </div>
        <div class="esign-summary-row">
          <span class="esign-summary-label">Request ID</span>
          <span class="esign-summary-value" id="requestId">-</span>
        </div>
      </div>
      
      <p class="small text-muted">
        You'll receive an email when your request is approved or rejected.
      </p>
      
      <button type="button" class="btn btn-default mrgn-tp-lg" onclick="ESign.done()">
        Close
      </button>
    </div>
  </div>
  
  <!-- Error View -->
  <div id="errorView" style="display: none;">
    <div class="esign-result-view">
      <div class="esign-result-icon error">✕</div>
      <h2>Unable to Send</h2>
      <p id="errorMessage">An error occurred</p>
      
      <button type="button" class="btn btn-default mrgn-tp-lg" onclick="location.reload()">
        Try Again
      </button>
    </div>
  </div>
  
</div>

<script src="~/js/esign-send.js"></script>
{% endblock %}
```

### 5.3 Status Page Template (EC-ESign-Status)

```html
{% extends 'EC-GCWeb-Layout' %}

{% block content %}
<div id="esign-status-app">
  
  <!-- Budget Summary -->
  <div class="esign-budget-card">
    <h3>Monthly Usage</h3>
    <div class="esign-budget-amount" id="monthlySpend">$0.00</div>
    <div class="esign-budget-details">
      <span><span id="envelopeCount">0</span> envelopes</span>
      <span>Budget: $<span id="budgetLimit">500</span></span>
    </div>
    <div class="esign-progress-bar mrgn-tp-sm" style="background: rgba(255,255,255,0.3);">
      <div class="esign-progress-bar-fill" id="budgetProgress" style="width: 0%; background: #fff;"></div>
    </div>
  </div>
  
  <!-- Tabs -->
  <ul class="nav nav-tabs mrgn-bttm-lg" role="tablist">
    <li role="presentation" class="active">
      <a href="#envelopes" aria-controls="envelopes" role="tab" data-toggle="tab">
        <span class="glyphicon glyphicon-file"></span> Envelopes
      </a>
    </li>
    <li role="presentation">
      <a href="#activity" aria-controls="activity" role="tab" data-toggle="tab">
        <span class="glyphicon glyphicon-bell"></span> Activity
      </a>
    </li>
  </ul>
  
  <div class="tab-content">
    
    <!-- Envelopes Tab -->
    <div role="tabpanel" class="tab-pane active" id="envelopes">
      
      <!-- Filters -->
      <div class="btn-group mrgn-bttm-md" role="group">
        <button type="button" class="btn btn-default active" onclick="ESign.filterEnvelopes('all', this)">All</button>
        <button type="button" class="btn btn-default" onclick="ESign.filterEnvelopes('pending', this)">
          <span class="glyphicon glyphicon-time"></span> Pending
        </button>
        <button type="button" class="btn btn-default" onclick="ESign.filterEnvelopes('inprogress', this)">
          <span class="glyphicon glyphicon-refresh"></span> In Progress
        </button>
        <button type="button" class="btn btn-default" onclick="ESign.filterEnvelopes('completed', this)">
          <span class="glyphicon glyphicon-ok"></span> Completed
        </button>
      </div>
      
      <!-- Envelope List -->
      <div id="envelopeList">
        <div class="text-center text-muted" style="padding: 40px;">
          <span style="font-size: 48px;">📭</span>
          <p class="mrgn-tp-md">No envelopes yet</p>
        </div>
      </div>
      
    </div>
    
    <!-- Activity Tab -->
    <div role="tabpanel" class="tab-pane" id="activity">
      <div id="notificationList">
        <div class="text-center text-muted" style="padding: 40px;">
          <span style="font-size: 48px;">🔔</span>
          <p class="mrgn-tp-md">No recent activity</p>
        </div>
      </div>
    </div>
    
  </div>
  
  <!-- Refresh Button -->
  <button type="button" class="btn btn-default btn-block mrgn-tp-lg" onclick="ESign.refreshData()">
    <span class="glyphicon glyphicon-refresh"></span> Refresh
  </button>
  
</div>

<!-- Envelope Detail Modal -->
<div class="modal fade esign-modal" id="envelopeModal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        <h4 class="modal-title" id="modalEnvelopeName">Envelope Details</h4>
      </div>
      <div class="modal-body">
        
        <div class="text-center mrgn-bttm-md">
          <span id="modalStatusBadge" class="esign-status-badge esign-status-sent">SENT</span>
        </div>
        
        <div class="esign-summary-card">
          <div class="esign-summary-row">
            <span class="esign-summary-label">Created</span>
            <span class="esign-summary-value" id="modalCreatedDate">-</span>
          </div>
          <div class="esign-summary-row">
            <span class="esign-summary-label">Sent</span>
            <span class="esign-summary-value" id="modalSentDate">-</span>
          </div>
          <div class="esign-summary-row">
            <span class="esign-summary-label">Cost</span>
            <span class="esign-summary-value" id="modalCost">-</span>
          </div>
        </div>
        
        <h5 class="mrgn-tp-md">Signers</h5>
        <div id="modalSignerList"></div>
        
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" id="modalDownloadBtn" onclick="ESign.downloadSignedDoc()">
          <span class="glyphicon glyphicon-download-alt"></span> Download
        </button>
      </div>
    </div>
  </div>
</div>

<script src="~/js/esign-status.js"></script>
{% endblock %}
```

### 5.4 Manage Fields Page Template (EC-ESign-Manage)

```html
{% extends 'EC-GCWeb-Layout' %}

{% block content %}
<div id="esign-manage-app">
  
  <!-- Insert Field Section -->
  <section class="mrgn-bttm-lg">
    <h2><span class="glyphicon glyphicon-plus"></span> Insert Field</h2>
    <p class="text-muted small">Click to insert at cursor position, then configure</p>
    
    <div class="esign-field-grid">
      <button type="button" class="esign-field-btn" onclick="ESign.insertField('signature')">
        <span class="field-icon">✍️</span>
        <span class="field-label">Signature</span>
      </button>
      <button type="button" class="esign-field-btn" onclick="ESign.insertField('initials')">
        <span class="field-icon">🔤</span>
        <span class="field-label">Initials</span>
      </button>
      <button type="button" class="esign-field-btn" onclick="ESign.insertField('date')">
        <span class="field-icon">📅</span>
        <span class="field-label">Date</span>
      </button>
      <button type="button" class="esign-field-btn" onclick="ESign.insertField('name')">
        <span class="field-icon">👤</span>
        <span class="field-label">Name</span>
      </button>
      <button type="button" class="esign-field-btn" onclick="ESign.insertField('checkbox')">
        <span class="field-icon">☑️</span>
        <span class="field-label">Checkbox</span>
      </button>
      <button type="button" class="esign-field-btn" onclick="ESign.insertField('text')">
        <span class="field-icon">📝</span>
        <span class="field-label">Text</span>
      </button>
    </div>
  </section>
  
  <!-- Document Fields Section -->
  <section class="mrgn-bttm-lg">
    <h2>
      <span class="glyphicon glyphicon-file"></span> Document Fields
      <button type="button" class="btn btn-default btn-xs pull-right" onclick="ESign.refreshFields()" title="Refresh">
        <span class="glyphicon glyphicon-refresh"></span>
      </button>
    </h2>
    
    <div id="fieldsContainer" class="panel panel-default">
      <div class="panel-body text-center text-muted">
        <span style="font-size: 32px;">📄</span>
        <p class="mrgn-tp-sm">No fields added yet</p>
        <span class="small">Click a field type above to insert</span>
      </div>
    </div>
  </section>
  
  <!-- Signer Legend -->
  <section id="signerLegend" class="mrgn-bttm-lg" style="display: none;">
    <h2><span class="glyphicon glyphicon-user"></span> Signers</h2>
    <div id="signerList" class="row"></div>
  </section>
  
  <!-- Send Button -->
  <section>
    <button type="button" class="btn btn-primary btn-block btn-lg" onclick="ESign.openSendPane()">
      <span class="glyphicon glyphicon-send"></span> Send for Signature
    </button>
  </section>
  
</div>

<!-- Configure Field Modal -->
<div class="modal fade esign-modal" id="configModal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        <h4 class="modal-title"><span class="glyphicon glyphicon-cog"></span> Configure Field</h4>
      </div>
      <div class="modal-body">
        
        <!-- Signer Assignment -->
        <div class="form-group">
          <label for="signerNumber">Assign to Signer</label>
          <div class="input-group" style="max-width: 150px;">
            <span class="input-group-btn">
              <button type="button" class="btn btn-default" onclick="ESign.decrementSigner()">−</button>
            </span>
            <input type="number" class="form-control text-center" id="signerNumber" value="1" min="1" max="99">
            <span class="input-group-btn">
              <button type="button" class="btn btn-default" onclick="ESign.incrementSigner()">+</button>
            </span>
          </div>
          
          <div class="well well-sm mrgn-tp-sm" id="signerPreview">
            <span class="esign-signer-number" id="signerColorPreview" style="display: inline-flex; width: 24px; height: 24px; font-size: 12px;">1</span>
            <span id="signerLabelPreview">Signer 1</span>
          </div>
        </div>
        
        <!-- Signer Details -->
        <details class="mrgn-bttm-md">
          <summary>Signer Details (optional)</summary>
          <div class="form-group mrgn-tp-md">
            <label for="signerName">Name</label>
            <input type="text" class="form-control" id="signerName" placeholder="e.g., John Smith">
          </div>
          <div class="form-group">
            <label for="signerEmail">Email</label>
            <input type="email" class="form-control" id="signerEmail" placeholder="e.g., john.smith@example.gc.ca">
          </div>
        </details>
        
        <!-- Field Options -->
        <div class="form-group">
          <label for="fieldLabel">Field Label</label>
          <input type="text" class="form-control" id="fieldLabel" placeholder="e.g., Employee Signature">
        </div>
        
        <div class="checkbox">
          <label>
            <input type="checkbox" id="fieldRequired" checked> Required field
          </label>
        </div>
        
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="ESign.applyFieldConfig()">
          <span class="glyphicon glyphicon-ok"></span> Apply
        </button>
      </div>
    </div>
  </div>
</div>

<script src="~/js/esign-manage.js"></script>
{% endblock %}
```

---

## 6. JavaScript Implementation

### 6.1 Common Functions (esign-common.js)

```javascript
// ============================================
// Elections Canada E-Sign Portal
// Common Functions
// ============================================

'use strict';

// Namespace
var ESign = ESign || {};

// Configuration
ESign.CONFIG = {
  portalUrl: '{{ request.url | split: '/' | first }}//{{ request.url | split: '/' | slice: 2 }}',
  apiUrl: '/_api',
  addinMode: false
};

// Signer Colors
ESign.SIGNER_COLORS = [
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

// Field Types
ESign.FIELD_TYPES = {
  signature: { icon: '✍️', label: 'Signature', placeholder: 'sig', width: 180, height: 50 },
  initials: { icon: '🔤', label: 'Initials', placeholder: 'int', width: 60, height: 25 },
  date: { icon: '📅', label: 'Date', placeholder: 'dte', width: 100, height: 25 },
  name: { icon: '👤', label: 'Name', placeholder: 'txt', width: 150, height: 25 },
  checkbox: { icon: '☑️', label: 'Checkbox', placeholder: 'chk', width: 25, height: 25 },
  text: { icon: '📝', label: 'Text', placeholder: 'txt', width: 150, height: 25 }
};

// Status Info
ESign.STATUS_INFO = {
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

// ============================================
// Initialization
// ============================================

ESign.init = function() {
  // Check if running in Office Add-in
  if (typeof Office !== 'undefined') {
    Office.onReady(function(info) {
      ESign.CONFIG.addinMode = true;
      ESign.CONFIG.officeHost = info.host;
      document.body.classList.add('addin-mode');
      document.body.classList.add('office-' + info.host.toLowerCase());
      console.log('E-Sign initialized in Office:', info.host);
    });
  } else {
    console.log('E-Sign initialized in portal mode');
  }
  
  // Store portal user ID from Liquid
  if (typeof portalUserId !== 'undefined') {
    ESign.CONFIG.userId = portalUserId;
  }
};

// ============================================
// API Functions (Power Pages Web API)
// ============================================

ESign.apiGet = function(endpoint) {
  return fetch(ESign.CONFIG.apiUrl + endpoint, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'OData-MaxVersion': '4.0',
      'OData-Version': '4.0'
    },
    credentials: 'same-origin'
  })
  .then(function(response) {
    if (!response.ok) {
      throw new Error('API error: ' + response.status);
    }
    return response.json();
  });
};

ESign.apiPost = function(endpoint, data) {
  return fetch(ESign.CONFIG.apiUrl + endpoint, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'OData-MaxVersion': '4.0',
      'OData-Version': '4.0'
    },
    credentials: 'same-origin',
    body: JSON.stringify(data)
  })
  .then(function(response) {
    if (!response.ok) {
      throw new Error('API error: ' + response.status);
    }
    return response.json();
  });
};

// ============================================
// Helper Functions
// ============================================

ESign.getSignerColor = function(signerNum) {
  var index = ((signerNum - 1) % 10);
  return ESign.SIGNER_COLORS[index];
};

ESign.getStatusInfo = function(statusCode) {
  return ESign.STATUS_INFO[statusCode] || { label: 'Unknown', class: 'draft' };
};

ESign.formatCurrency = function(amount) {
  return '$' + (amount || 0).toFixed(2);
};

ESign.formatDate = function(dateString) {
  if (!dateString) return '-';
  var date = new Date(dateString);
  return date.toLocaleDateString('en-CA', { 
    month: 'short', 
    day: 'numeric',
    year: date.getFullYear() !== new Date().getFullYear() ? 'numeric' : undefined
  });
};

ESign.formatRelativeTime = function(dateString) {
  var date = new Date(dateString);
  var now = new Date();
  var diffMs = now - date;
  var diffMins = Math.floor(diffMs / 60000);
  var diffHours = Math.floor(diffMs / 3600000);
  var diffDays = Math.floor(diffMs / 86400000);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return diffMins + 'm ago';
  if (diffHours < 24) return diffHours + 'h ago';
  if (diffDays < 7) return diffDays + 'd ago';
  return ESign.formatDate(dateString);
};

ESign.escapeHtml = function(text) {
  var div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
};

ESign.isAddinMode = function() {
  return ESign.CONFIG.addinMode;
};

ESign.showLoading = function(show) {
  var loading = document.getElementById('loadingState');
  var main = document.getElementById('mainView');
  
  if (loading) loading.style.display = show ? 'block' : 'none';
  if (main) main.style.display = show ? 'none' : 'block';
};

ESign.showError = function(message) {
  var errorView = document.getElementById('errorView');
  var errorMsg = document.getElementById('errorMessage');
  
  if (errorView) {
    errorView.style.display = 'block';
    if (errorMsg) errorMsg.textContent = message;
  } else {
    alert('Error: ' + message);
  }
};

// ============================================
// Navigation
// ============================================

ESign.openSendPane = function() {
  if (ESign.isAddinMode()) {
    Office.context.ui.displayDialogAsync(
      ESign.CONFIG.portalUrl + '/esign/send?addin=true',
      { height: 80, width: 40 }
    );
  } else {
    window.location.href = '/esign/send';
  }
};

ESign.closePane = function() {
  if (ESign.isAddinMode()) {
    Office.context.ui.closeContainer();
  }
};

ESign.done = function() {
  if (ESign.isAddinMode()) {
    ESign.closePane();
  } else {
    window.location.href = '/esign/status';
  }
};

ESign.cancel = function() {
  if (ESign.isAddinMode()) {
    ESign.closePane();
  } else {
    window.history.back();
  }
};

// Initialize on load
document.addEventListener('DOMContentLoaded', ESign.init);

console.log('E-Sign Common loaded');