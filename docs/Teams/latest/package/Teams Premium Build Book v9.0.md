# Teams Premium Build Book v9.0
## Complete Deployment Guide with Automated Monitoring
### Leonardo Company - LCE M365 Security Group

---

**Document Control**

| Field | Value |
|-------|-------|
| **Version** | 9.0 - Complete Integrated Guide |
| **Last Updated** | November 22, 2025 |
| **Owner** | Fred Pearson & George Zarif |
| **Email** | fred.pearson@leonardocompany.ca |
| **Target Group** | LCE M365 Security (lcem365security@leonardocompany.ca) |
| **Classification** | Internal Use Only |
| **Audience** | Technical staff (all skill levels) |
| **Total Phases** | 8 (Setup through Testing) |
| **Estimated Time** | 8-10 hours (spread over several days) |

---

## 📋 Executive Summary

### What This Guide Does

This comprehensive guide walks you through deploying Microsoft Teams Premium with enhanced security features for the LCE M365 Security group. By completing all phases, you will have:

✅ **Secure meeting capabilities** with watermarks and encryption  
✅ **Labels that ONLY appear in Teams** (never in Outlook/Word/Excel)  
✅ **Automated policy management** (no manual daily work)  
✅ **Automated monitoring and alerts** (catch issues before they become problems)  
✅ **Customer Managed Keys (CMK)** for complete data encryption control  
✅ **Comprehensive audit trail** showing who created what and when

### Key Features

**Distribution Group (NOT M365 Group):**
- ✅ Group email: `lcem365security@leonardocompany.ca`
- ✅ Easy management - add/remove members, policies update automatically
- ✅ Works with Exchange cmdlets for monitoring

**Sensitivity Labels (Teams Meetings ONLY - GUARANTEED):**
- ✅ Protected B - Secure Meeting (watermarks, restricted lobby, ALL settings LOCKED)
- ✅ General - Regular Meeting (open collaboration)
- ✅ Labels appear ONLY in Teams meeting creation
- ✅ **CRITICAL:** Labels do NOT appear in Outlook, Word, Excel, or PowerPoint
- ✅ **TRIPLE-PROTECTED:** Three levels of scripts ensure Outlook prevention

**Customer Managed Keys (CMK):**
- ✅ YOU control encryption keys in Azure Key Vault
- ✅ Meeting recordings, transcripts, chat, files all encrypted with YOUR key
- ✅ You can revoke access at any time

**Automated Everything:**
- ✅ User added to group → Policies assigned automatically
- ✅ User removed from group → Policies removed automatically
- ✅ Daily compliance checks with email alerts
- ✅ Weekly comprehensive reports
- ✅ Real-time alerts for security issues

---

## 🎯 Quick Navigation

### For Beginners (Start Here):
1. Read [Section 1: Prerequisites](#1-prerequisites)
2. Follow phases sequentially 1→2→3→4→5→6→7→8
3. Don't skip any checkpoints

### For Experienced Admins (Fast Track):
- Already have a group? Skip to [Phase 2](#3-phase-2-create-meeting-labels)
- Labels created? Jump to [Phase 3](#4-phase-3-configure-labels-for-teams-only)
- Need emergency Outlook removal? See [Phase 3B](#43-phase-3b-emergency-outlook-label-removal)

### For Troubleshooting:
- Labels in Outlook? → [Phase 3B](#43-phase-3b-emergency-outlook-label-removal)
- Something broken? → [Phase 3C](#44-phase-3c-fallback-delete-policy)
- Want to see all policies? → [Diagnostic Script](#diagnostic-tool)

---

## Table of Contents

1. [Prerequisites - What You Need](#1-prerequisites)
2. [Phase 1: Create Security Group](#2-phase-1-create-security-group)
3. [Phase 2: Create Meeting Labels](#3-phase-2-create-meeting-labels)
4. [Phase 3: Configure Labels for Teams ONLY](#4-phase-3-configure-labels-for-teams-only)
5. [Phase 4: Create Meeting Policies](#5-phase-4-create-meeting-policies)
6. [Phase 5: Set Up Customer Managed Keys](#6-phase-5-set-up-customer-managed-keys)
7. [Phase 6: Automate Policy Management](#7-phase-6-automate-policy-management)
8. [Phase 7: Set Up Monitoring & Alerts](#8-phase-7-set-up-monitoring--alerts)
9. [Phase 8: Testing Everything](#9-phase-8-testing-everything)
10. [Daily Operations & Maintenance](#10-daily-operations--maintenance)
11. [Emergency Procedures & Troubleshooting](#11-emergency-procedures--troubleshooting)
12. [Appendices & Quick Reference](#12-appendices--quick-reference)

---

## 1. Prerequisites

### 1.1 What You Need Before Starting

**Licenses Required (Per User):**
- Microsoft 365 E5 (or E3 + Teams Premium add-on)
- Teams Premium license
- Microsoft Purview Compliance (for monitoring)
- Azure AD Premium P1 (usually included with E5)

**Your Administrator Permissions:**

You need these roles assigned in Microsoft 365 Admin Center:

| Role | Purpose | Required For |
|------|---------|--------------|
| Global Administrator | Initial setup only | Phases 1-3 |
| Teams Administrator | Teams policies | Phases 4, 6 |
| Compliance Administrator | Labels & policies | Phases 2-3, 7 |
| Exchange Administrator | Distribution group | Phases 1, 6 |
| Azure Key Vault Administrator | CMK setup | Phase 5 |

**How to check your roles:**
1. Go to: https://admin.microsoft.com
2. Click **Users** → **Active users**
3. Find yourself in the list
4. Click on your name
5. Click **Manage roles**
6. Verify you have the roles above

**PowerShell Modules:**

Install these before starting. Open PowerShell **as Administrator** and run:

```powershell
# Install all required modules at once
Install-Module -Name ExchangeOnlineManagement -Force -Scope CurrentUser
Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser  
Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
Install-Module -Name Az.KeyVault -Force -Scope CurrentUser

# Verify installation
Get-Module -ListAvailable | Where-Object {
    $_.Name -in @('ExchangeOnlineManagement', 'MicrosoftTeams', 'Microsoft.Graph', 'Az.KeyVault')
} | Select-Object Name, Version
```

**What "CurrentUser" means:** Installs just for you, not system-wide. Doesn't require PC admin rights.

### 1.2 Azure Key Vault Prerequisites (For Phase 5)

**Before starting Phase 5, you need:**

✅ Azure subscription (active)  
✅ Resource group created in Azure  
✅ Azure Key Vault created  
✅ Customer Managed Key (CMK) generated in Key Vault  
✅ Permissions granted to Microsoft 365 service principals  
✅ M365 Data-at-Rest Encryption Policy created  

**Important:** CMK provisioning can take 24-72 hours. Start Phase 5 early!

Reference: https://docs.microsoft.com/en-us/purview/customer-key-overview

### 1.3 Time Estimates Per Phase

| Phase | Time Required | Can Run Unattended? |
|-------|---------------|---------------------|
| Phase 1: Group Setup | 15-20 minutes | No |
| Phase 2: Create Labels | 10-15 minutes | No |
| Phase 3: Teams-Only Config | 20-30 minutes | Yes (mostly) |
| Phase 4: Meeting Policies | 30-45 minutes | Yes |
| Phase 5: CMK Setup | 1-2 hours + waiting | No |
| Phase 6: Automation | 30-45 minutes | Yes |
| Phase 7: Monitoring | 2-3 hours | Yes |
| Phase 8: Testing | 30-60 minutes | No |
| **Total** | **6-9 hours active + 24-72 hours waiting** | |

**Tip:** Spread this over 3-5 days to account for propagation times.

---

## 2. Phase 1: Create Security Group

### 2.1 Why This Phase Matters

**The Big Picture:**
We're creating a special email group for your security team. This group is the foundation of everything:

- When someone joins this group → They automatically get secure meeting features
- When they leave → Features are automatically removed
- No manual work needed after initial setup

**Critical Decision: Distribution Group vs M365 Group**

You MUST create a **Distribution Group** (also called Distribution List), NOT a Microsoft 365 Group.

| Feature | Distribution Group ✅ | M365 Group ❌ |
|---------|----------------------|---------------|
| Works with Get-DistributionGroupMember | ✅ Yes | ❌ No |
| Simple email distribution | ✅ Yes | ✅ Yes |
| Has SharePoint site | ❌ No | ✅ Yes (we don't need) |
| Has Teams team | ❌ No | ✅ Yes (we don't need) |
| Easy automation | ✅ Yes | ❌ Complex |

**Why Distribution Group?**
- Simpler
- Works perfectly with our automation scripts
- No unnecessary features (SharePoint sites, Teams teams)
- Supported by all our PowerShell commands

### 2.2 Method 1: Using Web Interface (Recommended for Beginners)

**Step-by-step with screenshots references:**

**Step 1: Access Exchange Admin Center**

1. Open your web browser (Chrome, Edge, Firefox)
2. Go to: https://admin.exchange.microsoft.com
3. Sign in with your Leonardo Company email
   - Example: fred.pearson@leonardocompany.ca
   - Use your normal password
4. Wait for the page to load (may take 10-20 seconds)

**Step 2: Navigate to Groups**

1. Look at the left sidebar (vertical menu)
2. Click **Recipients** (has a person icon)
3. Click **Groups** underneath it
4. You'll see a list of existing groups

**Step 3: Start Creating New Group**

1. Look at the top toolbar
2. Click the **+ Add a group** button
3. A wizard will appear with different group types

**Step 4: Select Group Type**

⚠️ **CRITICAL STEP - Choose the Right Type**

You'll see several options:
- Distribution (or Distribution list) ← **CHOOSE THIS ONE**
- Mail-enabled security ← **This also works**
- Microsoft 365 ← **DO NOT choose this**
- Security ← **DO NOT choose this**

Click on **Distribution** or **Distribution list**  
Click **Next**

**Step 5: Fill In Group Details**

You'll see a form with several fields:

**Name field:**
- Type exactly: `LCE M365 Security`
- This is the friendly name people see
- Used in Outlook address book

**Email address field:**
- Type exactly: `lcem365security`
- The system will add: @leonardocompany.ca automatically
- Full email will be: lcem365security@leonardocompany.ca

**Description field:**
- Type: `Security team for M365 monitoring, alerts, and Teams Premium policies`
- This helps others understand the group's purpose

**Group owner:**
- Add: fred.pearson@leonardocompany.ca
- This person can manage the group later

Click **Next**

**Step 6: Add Members**

1. Click the **Add members** button
2. A search box appears
3. Type the first person's name or email
4. Add all four people:
   - fred.pearson@leonardocompany.ca
   - george.zarif@leonardocompany.ca
   - chris.helm@leonardocompany.ca
   - adrian.darjan@leonardocompany.ca

5. After adding each person, they appear in a list
6. Verify all 4 names are there
7. Click **Next**

**Step 7: Settings (Optional)**

You may see additional settings:
- **Allow people outside your organization to send to this group:** Leave as No
- **Membership approval:** Leave as "Owner approval required"
- **Privacy:** Leave as default

Click **Next**

**Step 8: Review and Create**

1. Review everything:
   - Name: LCE M365 Security ✓
   - Email: lcem365security@leonardocompany.ca ✓
   - Members: 4 people ✓

2. If everything looks good, click **Create group**
3. Wait 10-30 seconds for creation
4. You'll see a success message

Click **Close**

**Step 9: Verify It Worked**

1. Still in Exchange Admin Center
2. Go to **Recipients** → **Groups**
3. Find "LCE M365 Security" in the list
4. Click on it to see details
5. Verify:
   - Email shows: lcem365security@leonardocompany.ca
   - Members shows: 4
   - Type shows: Distribution group (or Mail-enabled security)

### 2.3 Method 2: Using PowerShell (For Advanced Users)

If you prefer command line or web interface isn't working:

```powershell
<#
What this script does:
- Connects to Exchange Online
- Creates the distribution group
- Adds all 4 members
- Sets Fred as the owner
- Shows you the results
#>

# Step 1: Connect to Exchange Online
# You'll be asked to sign in - use your admin account
Connect-ExchangeOnline

Write-Host "Connected to Exchange Online" -ForegroundColor Green

# Step 2: Create the distribution group
Write-Host "`nCreating distribution group..." -ForegroundColor Cyan

New-DistributionGroup `
    -Name "LCE M365 Security" `
    -Alias "LCEM365Security" `
    -Type "Security" `
    -PrimarySmtpAddress "lcem365security@leonardocompany.ca" `
    -MemberJoinRestriction "Closed" `
    -MemberDepartRestriction "Closed"

Write-Host "✓ Group created" -ForegroundColor Green

# Step 3: Add members one by one
Write-Host "`nAdding members..." -ForegroundColor Cyan

Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "fred.pearson@leonardocompany.ca"
Write-Host "  ✓ Added Fred" -ForegroundColor Green

Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "george.zarif@leonardocompany.ca"
Write-Host "  ✓ Added George" -ForegroundColor Green

Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "chris.helm@leonardocompany.ca"
Write-Host "  ✓ Added Chris" -ForegroundColor Green

Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "adrian.darjan@leonardocompany.ca"
Write-Host "  ✓ Added Adrian" -ForegroundColor Green

# Step 4: Set Fred as the owner
Write-Host "`nSetting owner..." -ForegroundColor Cyan

Set-DistributionGroup -Identity "lcem365security@leonardocompany.ca" -ManagedBy "fred.pearson@leonardocompany.ca"

Write-Host "✓ Fred set as owner" -ForegroundColor Green

# Step 5: Verify everything worked
Write-Host "`nVerifying..." -ForegroundColor Cyan

Get-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" | 
    Select-Object Name, PrimarySmtpAddress | 
    Format-Table -AutoSize

Write-Host "`n✅ Group creation complete!" -ForegroundColor Green

# Step 6: Disconnect
Disconnect-ExchangeOnline -Confirm:$false
```

**What each command does:**

| Command | What It Does | Why We Need It |
|---------|--------------|----------------|
| `Connect-ExchangeOnline` | Logs you into Exchange | Need access to create groups |
| `New-DistributionGroup` | Creates the group | Main creation command |
| `-Type "Security"` | Makes it mail-enabled security | Allows Exchange commands |
| `Add-DistributionGroupMember` | Adds each person | Populates the group |
| `Set-DistributionGroup` | Sets the owner | Fred can manage it |
| `Get-DistributionGroupMember` | Shows members | Verifies it worked |
| `Disconnect-ExchangeOnline` | Logs you out | Clean disconnect |

### 2.4 Test the Group (IMPORTANT)

**Test 1: Send an Email**

1. Open Outlook (web or desktop)
2. Click **New message**
3. In the **To:** field, type: lcem365security@leonardocompany.ca
4. Subject: Test - Distribution Group
5. Body: Testing if everyone receives this
6. Click **Send**
7. Wait 1-2 minutes
8. All 4 people should receive the email

**Test 2: Verify in PowerShell** (Optional)

```powershell
# Quick verification script
Connect-ExchangeOnline

$group = Get-DistributionGroup -Identity "lcem365security@leonardocompany.ca"
$members = Get-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca"

Write-Host "`nGroup Details:" -ForegroundColor Cyan
Write-Host "  Name: $($group.DisplayName)"
Write-Host "  Email: $($group.PrimarySmtpAddress)"
Write-Host "  Type: $($group.GroupType)"
Write-Host "  Members: $($members.Count)"

Write-Host "`nMembers:" -ForegroundColor Cyan
$members | ForEach-Object {
    Write-Host "  ✓ $($_.DisplayName) - $($_.PrimarySmtpAddress)" -ForegroundColor Green
}

Disconnect-ExchangeOnline -Confirm:$false
```

### 2.5 Checkpoint: Did It Work?

✅ **Success looks like:**
- [ ] Group exists in Exchange Admin Center
- [ ] Group email is: lcem365security@leonardocompany.ca
- [ ] All 4 people are members
- [ ] Fred is listed as owner
- [ ] Test email reached all 4 people
- [ ] Group type shows: Distribution (or Mail-enabled security)

❌ **Common Problems & Solutions:**

**Problem:** "You don't have permission to create groups"
- **Solution:** Ask your Global Admin to grant you Exchange Administrator role

**Problem:** "Email address already in use"
- **Solution:** The group already exists. Go to Recipients → Groups and find it

**Problem:** "Cannot add member [name]"
- **Solution:** Check the email address spelling. Make sure the person exists in your tenant.

**Problem:** Test email didn't arrive
- **Solution:** 
  1. Wait 5 minutes (sometimes delayed)
  2. Check spam/junk folders
  3. Verify email address: `Get-DistributionGroup -Identity lcem365security@leonardocompany.ca | Select PrimarySmtpAddress`

### 2.6 What's Next?

✅ **Phase 1 Complete!** You now have a distribution group.

**What this enables:**
- Foundation for all automation
- Email distribution for alerts
- Group-based policy assignment
- Easy member management (add/remove people later)

**Next Step:** Proceed to Phase 2 to create the meeting sensitivity labels.

**Time until next phase:** Can proceed immediately (no waiting required)

---

## 3. Phase 2: Create Meeting Labels

### 3.1 Why This Phase Matters

**What Are Sensitivity Labels?**

Think of sensitivity labels like security stickers you put on meetings:
- **Protected B - Secure Meeting** = Red sticker = Maximum security
- **General - Regular Meeting** = Green sticker = Normal collaboration

**What They Do:**
- Automatically apply security settings
- Users can't bypass the security
- Color-coded for easy recognition
- Enforced by Microsoft 365

**Where They'll Appear:**
- Teams meeting creation (good ✅)
- Teams meeting scheduler (good ✅)
- Nowhere else after Phase 3 (good ✅)

### 3.2 The Two Labels We're Creating

**Label 1: Protected B - Secure Meeting**

- **Color:** Dark red (#A4262C)
- **Purpose:** Classified/sensitive government meetings
- **Security:** Maximum (watermarks, restricted lobby, all LOCKED)
- **When to use:** Protected B content, classified discussions, sensitive data

**Label 2: General - Regular Meeting**

- **Color:** Green (#107C10)
- **Purpose:** Regular, non-classified meetings
- **Security:** Standard (open collaboration)
- **When to use:** Normal team meetings, standups, general discussions

### 3.3 The Script

**Save this as:** `C:\Scripts\01-Create-Sensitivity-Labels.ps1`

**Before running:**
1. Create the folder: `C:\Scripts` (if it doesn't exist)
2. Save the script there
3. Right-click on PowerShell → Run as Administrator
4. Navigate: `cd C:\Scripts`
5. Run: `.\01-Create-Sensitivity-Labels.ps1`

```powershell
<#
.SYNOPSIS
    Create Meeting Sensitivity Labels for LCE
.DESCRIPTION
    Creates two sensitivity labels for Teams meetings:
    - Protected B - Secure Meeting (dark red, maximum security)
    - General - Regular Meeting (green, standard collaboration)
    
    IMPORTANT: These labels will ONLY appear in Teams after Phase 3.
    
    Safe to run multiple times - will update labels if they already exist.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Run this ONCE during initial setup
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 2: CREATE SENSITIVITY LABELS                             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nWhat this script does:" -ForegroundColor Yellow
Write-Host "  1. Connects to Microsoft Purview (Security & Compliance)" -ForegroundColor White
Write-Host "  2. Creates 'Protected B - Secure Meeting' label (dark red)" -ForegroundColor White
Write-Host "  3. Creates 'General - Regular Meeting' label (green)" -ForegroundColor White
Write-Host "  4. Verifies both labels exist" -ForegroundColor White
Write-Host "`n  These labels won't appear anywhere yet - Phase 3 publishes them." -ForegroundColor Gray

# Connect to Microsoft Purview
Write-Host "`n[Step 1/4] Connecting to Microsoft Purview..." -ForegroundColor Cyan
Write-Host "  → A sign-in window will appear" -ForegroundColor Gray
Write-Host "  → Use your admin account" -ForegroundColor Gray

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "  ✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Connection failed" -ForegroundColor Red
    Write-Host "`n  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`n  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "    1. Make sure you're a Global Admin or Compliance Admin" -ForegroundColor White
    Write-Host "    2. Check your internet connection" -ForegroundColor White
    Write-Host "    3. Try running: Install-Module ExchangeOnlineManagement -Force" -ForegroundColor White
    Write-Host "    4. Close PowerShell and try again" -ForegroundColor White
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Create Protected B label
Write-Host "`n[Step 2/4] Creating 'Protected B - Secure Meeting' label..." -ForegroundColor Cyan
Write-Host "  → Color: Dark red (#A4262C)" -ForegroundColor Gray
Write-Host "  → Purpose: Classified/sensitive meetings" -ForegroundColor Gray

try {
    # Check if it already exists
    $existingProtectedB = Get-Label -Identity "Protected B - Secure Meeting" -ErrorAction SilentlyContinue
    
    if ($existingProtectedB) {
        Write-Host "  ℹ️  Label already exists - updating it" -ForegroundColor Yellow
        
        Set-Label -Identity "Protected B - Secure Meeting" `
            -DisplayName "Protected B - Secure Meeting" `
            -Tooltip "Use for classified/sensitive government meetings (Protected B)" `
            -Comment "Protected B classification - Watermarks, restricted lobby, CMK encryption, ALL SETTINGS LOCKED" `
            -AdvancedSettings @{
                color = "#A4262C"
            }
        
        Write-Host "  ✓ Updated existing label" -ForegroundColor Green
    } else {
        Write-Host "  → Creating new label..." -ForegroundColor Gray
        
        New-Label `
            -DisplayName "Protected B - Secure Meeting" `
            -Name "ProtectedB-SecureMeeting" `
            -Tooltip "Use for classified/sensitive government meetings (Protected B)" `
            -Comment "Protected B classification - Watermarks, restricted lobby, CMK encryption, ALL SETTINGS LOCKED" `
            -AdvancedSettings @{
                color = "#A4262C"
            }
        
        Write-Host "  ✓ Created new label" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to create Protected B label" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Create General label
Write-Host "`n[Step 3/4] Creating 'General - Regular Meeting' label..." -ForegroundColor Cyan
Write-Host "  → Color: Green (#107C10)" -ForegroundColor Gray
Write-Host "  → Purpose: Regular, non-classified meetings" -ForegroundColor Gray

try {
    # Check if it already exists
    $existingGeneral = Get-Label -Identity "General - Regular Meeting" -ErrorAction SilentlyContinue
    
    if ($existingGeneral) {
        Write-Host "  ℹ️  Label already exists - updating it" -ForegroundColor Yellow
        
        Set-Label -Identity "General - Regular Meeting" `
            -DisplayName "General - Regular Meeting" `
            -Tooltip "Use for regular, non-classified meetings" `
            -Comment "General/Unclassified - Open collaboration, standard security" `
            -AdvancedSettings @{
                color = "#107C10"
            }
        
        Write-Host "  ✓ Updated existing label" -ForegroundColor Green
    } else {
        Write-Host "  → Creating new label..." -ForegroundColor Gray
        
        New-Label `
            -DisplayName "General - Regular Meeting" `
            -Name "General-RegularMeeting" `
            -Tooltip "Use for regular, non-classified meetings" `
            -Comment "General/Unclassified - Open collaboration, standard security" `
            -AdvancedSettings @{
                color = "#107C10"
            }
        
        Write-Host "  ✓ Created new label" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to create General label" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Verify labels were created
Write-Host "`n[Step 4/4] Verifying labels..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

$allLabels = Get-Label | Where-Object {$_.DisplayName -like "*Meeting"}

if ($allLabels.Count -ge 2) {
    Write-Host "  ✓ Verification successful!" -ForegroundColor Green
    Write-Host "`n  Labels found:" -ForegroundColor White
    foreach ($label in $allLabels) {
        $color = $label.AdvancedSettings.color
        Write-Host "    • $($label.DisplayName)" -ForegroundColor Green
        Write-Host "      Color: $color | Created: $($label.WhenCreated)" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠️  Warning: Expected 2 labels, found $($allLabels.Count)" -ForegroundColor Yellow
}

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Save a simple report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Labels-Created-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
Sensitivity Labels Created
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Labels Created:
$(($allLabels | ForEach-Object { "  • $($_.DisplayName) (Color: $($_.AdvancedSettings.color))" }) -join "`n")

Next Steps:
1. These labels are created but NOT published yet
2. Run Phase 3 script to publish them to Teams
3. After Phase 3, labels will appear ONLY in Teams meeting creation
4. Labels will NOT appear in Outlook, Word, Excel, or PowerPoint
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ PHASE 2 COMPLETE - LABELS CREATED                           ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nWhat just happened:" -ForegroundColor Cyan
Write-Host "  • Two sensitivity labels were created" -ForegroundColor White
Write-Host "  • They exist in Microsoft Purview but aren't published yet" -ForegroundColor White
Write-Host "  • Users cannot see them anywhere (Teams, Outlook, etc.)" -ForegroundColor White

Write-Host "`nWhat happens next:" -ForegroundColor Cyan
Write-Host "  • Run Phase 3 to publish these labels" -ForegroundColor White
Write-Host "  • Phase 3 ensures labels ONLY appear in Teams" -ForegroundColor White
Write-Host "  • After Phase 3, wait 24-48 hours for propagation" -ForegroundColor White

Write-Host "`nNext: Run Phase 3 script (02-Configure-Label-Policy-TeamsOnly.ps1)`n" -ForegroundColor Cyan

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
```

### 3.4 Understanding the Labels

**What Gets Created:**

Both labels are created in Microsoft Purview but are NOT published yet (invisible to users).

**Label Properties:**

| Property | Protected B | General |
|----------|-------------|---------|
| Display Name | Protected B - Secure Meeting | General - Regular Meeting |
| Internal Name | ProtectedB-SecureMeeting | General-RegularMeeting |
| Color Code | #A4262C (dark red) | #107C10 (green) |
| Tooltip | For classified/sensitive meetings | For regular meetings |
| Encryption | CMK (added in Phase 5) | CMK (added in Phase 5) |

**Where They Are Now:**
- ✅ Created in Microsoft Purview
- ❌ NOT published to any apps yet
- ❌ Users cannot see them
- ❌ Cannot be applied to meetings yet

**What Phase 3 Will Do:**
- ✅ Publish labels to policy
- ✅ Make them available ONLY in Teams
- ✅ Remove from Outlook/Word/Excel
- ✅ Users will see them in Teams meeting creation

### 3.5 Checkpoint: Did It Work?

✅ **Success looks like:**
- [ ] Script shows "Phase 2 Complete"
- [ ] Both labels are listed
- [ ] No red error messages
- [ ] Report file created in C:\LeonardoReports
- [ ] PowerShell didn't crash

**To manually verify:**
1. Go to: https://compliance.microsoft.com
2. Sign in with your admin account
3. Click **Information protection** (left sidebar)
4. Click **Labels**
5. You should see both labels:
   - Protected B - Secure Meeting
   - General - Regular Meeting

**What you should see:**
- Both labels exist
- Status shows "Published" = No (that's correct!)
- Type shows "Sensitivity label"

❌ **Common Problems & Solutions:**

**Problem:** "Connect-IPPSSession not recognized"
- **Solution:** Run: `Install-Module ExchangeOnlineManagement -Force`

**Problem:** "Access denied" or "Forbidden"
- **Solution:** You need Compliance Administrator role. Ask Global Admin to assign it.

**Problem:** "Label already exists" (not an error, just a message)
- **Solution:** This is fine! Script updates existing labels. Not a problem.

**Problem:** Script found 0 labels at the end
- **Solution:**
  1. Wait 2-3 minutes (labels take time to appear)
  2. Run this quick check:
     ```powershell
     Connect-IPPSSession
     Get-Label | Where-Object {$_.DisplayName -like "*Meeting"}
     ```
  3. If still shows 0, re-run the creation script

### 3.6 What's Next?

✅ **Phase 2 Complete!** You now have two meeting sensitivity labels.

**Current state:**
- Labels exist in Purview
- Not visible to users yet
- Not published to any apps
- Ready for Phase 3

**Next Step:** Phase 3 - Configure labels to appear ONLY in Teams (this is the critical phase!)

**Time until next phase:** Can proceed immediately (no waiting)

---

## 4. Phase 3: Configure Labels for Teams ONLY

### 4.1 ⚠️ WHY THIS IS THE MOST CRITICAL PHASE

**The Problem We're Solving:**

By default, when you create sensitivity labels in Microsoft 365, they get published EVERYWHERE:
- ✅ Teams (where we WANT them)
- ❌ Outlook email (we DON'T want this)
- ❌ Word (we DON'T want this)
- ❌ Excel (we DON'T want this)
- ❌ PowerPoint (we DON'T want this)
- ❌ SharePoint (we DON'T want this)

**Why This Matters:**

Imagine your users opening Outlook to write an email and seeing:
- Protected B - Secure Meeting
- General - Regular Meeting

They'd be confused! These are MEETING labels, not EMAIL labels.

**What We're Doing:**

This phase creates a "label policy" (think of it as a publishing rule) that:
1. Takes the labels we created in Phase 2
2. Publishes them ONLY to Teams
3. Explicitly removes them from Outlook, Word, Excel, PowerPoint
4. Triple-checks they're not in email

**Three Levels of Protection:**

We have THREE scripts to ensure labels never appear in Outlook:

| Script | When to Use | Safety Level |
|--------|-------------|--------------|
| **Phase 3 Main Script** | Always (normal setup) | ✅✅✅ |
| **Phase 3B Emergency Script** | If Phase 3 verification shows locations > 0 | ✅✅ |
| **Phase 3C Delete Script** | Nuclear option - start over | ✅ |