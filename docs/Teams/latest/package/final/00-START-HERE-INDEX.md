# 🗂️ LCE Teams Premium Deployment - File Index

**Package Version:** 9.0  
**Total Files:** 10  
**Last Updated:** November 22, 2025

---

## 🚀 START HERE

**New to this deployment?**  
→ Open **README.md** first

**Experienced admin, want quick deployment?**  
→ Open **Quick-Start-Guide.md**

**Need to understand everything?**  
→ Open **DEPLOYMENT-PACKAGE-SUMMARY.md**

---

## 📁 All Files in This Package

### 📘 Documentation Files (3)

| File | Purpose | When to Read |
|------|---------|--------------|
| **README.md** | Complete deployment guide with troubleshooting | Start here (everyone) |
| **Quick-Start-Guide.md** | Fast deployment for experienced admins | Experienced users |
| **DEPLOYMENT-PACKAGE-SUMMARY.md** | Technical deep-dive and scenarios | Understanding internals |

---

### 💻 PowerShell Scripts (7)

**Core Deployment Scripts** (run in order):

| # | File | Purpose | Run When |
|---|------|---------|----------|
| **01** | `01-Create-Sensitivity-Labels.ps1` | Creates Protected B and General labels | Initial setup |
| **02** | `02-Configure-Label-Policy-TeamsOnly.ps1` | Publishes labels to Teams ONLY | After script 01 |
| **04** | `04-Diagnose-Label-Policy-Status.ps1` | Verifies configuration | After script 02, anytime |

**Emergency/Troubleshooting Scripts:**

| # | File | Purpose | Run When |
|---|------|---------|----------|
| **02B** | `02B-Emergency-Remove-Outlook-Labels.ps1` | Removes labels from Outlook | Labels appearing in Outlook |
| **02C** | `02C-DELETE-LCE-Meeting-Labels-Policy.ps1` | Deletes entire policy (nuclear) | Everything broken, start fresh |
| **03** | `03-Remove-Outlook-From-LCE-Meeting-Labels.ps1` | Focused Outlook removal | Alternative to 02B |

**Automation Script:**

| # | File | Purpose | Run When |
|---|------|---------|----------|
| **05** | `05-MASTER-Group-Policy-Management-Enhanced.ps1` | Daily policy management | After deployment, scheduled |

---

## 🎯 Quick Decision Tree

### "What file do I need?"

**I'm starting a new deployment:**
1. Read: **README.md**
2. Run: **01-Create-Sensitivity-Labels.ps1**
3. Run: **02-Configure-Label-Policy-TeamsOnly.ps1**
4. Verify: **04-Diagnose-Label-Policy-Status.ps1**

**Labels are showing in Outlook:**
1. Run: **02B-Emergency-Remove-Outlook-Labels.ps1**
2. OR Run: **03-Remove-Outlook-From-LCE-Meeting-Labels.ps1**
3. Verify: **04-Diagnose-Label-Policy-Status.ps1**

**Everything is broken:**
1. Run: **02C-DELETE-LCE-Meeting-Labels-Policy.ps1**
2. Then: **02-Configure-Label-Policy-TeamsOnly.ps1**
3. Verify: **04-Diagnose-Label-Policy-Status.ps1**

**I need to check status:**
- Run: **04-Diagnose-Label-Policy-Status.ps1**

**I need to add/remove users:**
- Run: **05-MASTER-Group-Policy-Management-Enhanced.ps1**

**I want to understand everything first:**
- Read: **DEPLOYMENT-PACKAGE-SUMMARY.md**

**I'm experienced and want quick deployment:**
- Read: **Quick-Start-Guide.md**

---

## 📊 File Sizes Reference

| File | Size | Type |
|------|------|------|
| 01-Create-Sensitivity-Labels.ps1 | 9.4 KB | Script |
| 02-Configure-Label-Policy-TeamsOnly.ps1 | 12 KB | Script |
| 02B-Emergency-Remove-Outlook-Labels.ps1 | 9.0 KB | Script |
| 02C-DELETE-LCE-Meeting-Labels-Policy.ps1 | 12 KB | Script |
| 03-Remove-Outlook-From-LCE-Meeting-Labels.ps1 | 5.4 KB | Script |
| 04-Diagnose-Label-Policy-Status.ps1 | 14 KB | Script |
| 05-MASTER-Group-Policy-Management-Enhanced.ps1 | 15 KB | Script |
| README.md | 12 KB | Documentation |
| Quick-Start-Guide.md | 11 KB | Documentation |
| DEPLOYMENT-PACKAGE-SUMMARY.md | 16 KB | Documentation |

**Total Package Size:** ~115 KB

---

## 🔄 Typical Usage Order

### First-Time Deployment

```
Day 1:
1. README.md (read)
2. 01-Create-Sensitivity-Labels.ps1 (run)
3. 02-Configure-Label-Policy-TeamsOnly.ps1 (run)
4. 04-Diagnose-Label-Policy-Status.ps1 (verify)

Day 1-3:
- Wait for Microsoft propagation (24-48 hours)

Day 3:
1. Test labels in Teams (should appear)
2. Test labels in Outlook (should NOT appear)
3. 04-Diagnose-Label-Policy-Status.ps1 (final verify)
4. 05-MASTER-Group-Policy-Management-Enhanced.ps1 (setup automation)
```

### Daily Operations

```
As needed:
- Add user → 05-MASTER-Group-Policy-Management-Enhanced.ps1
- Remove user → 05-MASTER-Group-Policy-Management-Enhanced.ps1
- Check status → 04-Diagnose-Label-Policy-Status.ps1

Automated:
- Daily 9 AM → 05-MASTER-Group-Policy-Management-Enhanced.ps1 (scheduled)
```

### Troubleshooting

```
1. Check status:
   → 04-Diagnose-Label-Policy-Status.ps1

2. Fix issues:
   → If Exchange > 0: 02B-Emergency-Remove-Outlook-Labels.ps1
   → If policy broken: 02C-DELETE... then 02-Configure...
   → If labels missing: 01-Create-Sensitivity-Labels.ps1

3. Verify fix:
   → 04-Diagnose-Label-Policy-Status.ps1
```

---

## 🎓 Learning Path

### Beginner (New to M365 Admin)

**Day 1:**
1. Read: README.md (full read, 30-45 min)
2. Understand: Distribution groups vs M365 groups
3. Understand: Sensitivity labels vs label policies
4. Understand: Why Exchange locations must be 0

**Day 2:**
1. Practice: Create test distribution group
2. Practice: Run script 01 in test environment
3. Verify: Check Purview portal for labels

**Day 3:**
1. Run: Script 02 in production
2. Run: Script 04 to verify
3. Fix: Any issues with 02B if needed

**Week 2:**
1. Test: Label visibility in Teams and Outlook
2. Setup: Automation with script 05
3. Document: Any customizations made

---

### Intermediate (Familiar with M365)

**30 minutes:**
1. Skim: Quick-Start-Guide.md
2. Run: Scripts 01, 02, 04 in sequence
3. Verify: Exchange = 0

**Day 2-3:**
- Wait for propagation
- Test functionality

**Day 3:**
1. Setup: Automation
2. Document: Configuration

---

### Advanced (M365 Expert)

**15 minutes:**
1. Run: Scripts 01, 02
2. Verify: Script 04 shows Exchange = 0
3. Setup: Automation immediately

**Optional:**
- Read: DEPLOYMENT-PACKAGE-SUMMARY.md for technical details
- Customize: Scripts for your environment
- Extend: Add additional labels/policies

---

## 📞 Quick Reference

**Support Contacts:**
- george.zarif@leonardocompany.ca (Primary)
- fred.pearson@leonardocompany.ca (Secondary)
- lcem365security@leonardocompany.ca (Group)

**Key Locations:**
- Scripts: `C:\Scripts\LCE-Teams-Premium\`
- Reports: `C:\LeonardoReports\`
- Logs: `C:\LeonardoReports\Logs\`

**Key Configurations:**
- Group: lcem365security@leonardocompany.ca
- Policy: LCE Meeting Labels
- Labels: Protected B, General
- Critical: Exchange locations MUST be 0

**Most Used Commands:**
```powershell
# Check status
.\04-Diagnose-Label-Policy-Status.ps1

# Fix Outlook
.\02B-Emergency-Remove-Outlook-Labels.ps1

# Manage users
.\05-MASTER-Group-Policy-Management-Enhanced.ps1

# View reports
Get-ChildItem C:\LeonardoReports | Sort LastWriteTime -Desc | Select -First 1
```

---

## ✅ Deployment Checklist

Print this or save as separate checklist:

**Pre-Deployment:**
- [ ] Have required admin roles
- [ ] PowerShell modules installed
- [ ] Distribution group created
- [ ] Test email to group works
- [ ] Read README.md completely

**Phase 1 - Labels:**
- [ ] Run: 01-Create-Sensitivity-Labels.ps1
- [ ] Verify: 2 labels exist in Purview
- [ ] Report generated successfully

**Phase 2 - Policy:**
- [ ] Run: 02-Configure-Label-Policy-TeamsOnly.ps1
- [ ] Verify: Policy created
- [ ] Report shows Exchange = 0

**Phase 3 - Verification:**
- [ ] Run: 04-Diagnose-Label-Policy-Status.ps1
- [ ] Exchange locations = 0 confirmed
- [ ] SharePoint locations = 0
- [ ] OneDrive locations = 0
- [ ] 2 labels in policy

**Phase 4 - Troubleshooting (if needed):**
- [ ] If Exchange > 0: Run 02B or 03
- [ ] Re-verify with script 04
- [ ] All locations = 0 confirmed

**Phase 5 - Wait:**
- [ ] Note date/time of deployment
- [ ] Wait 24-48 hours
- [ ] Don't make changes during wait

**Phase 6 - Testing:**
- [ ] Labels appear in Teams meetings
- [ ] Labels do NOT appear in Outlook
- [ ] Both labels selectable
- [ ] Correct colors displayed

**Phase 7 - Automation:**
- [ ] Run script 05 manually (test)
- [ ] Review generated report
- [ ] Schedule daily task
- [ ] Verify scheduled task runs

**Phase 8 - Documentation:**
- [ ] Document deployment date
- [ ] Note any customizations
- [ ] Save all reports
- [ ] Update team documentation

---

## 🔐 Security & Compliance

**These scripts:**
- ✅ Are safe to run multiple times
- ✅ Generate audit trails
- ✅ Do not modify user data
- ✅ Do not access sensitive information
- ✅ Follow Microsoft best practices

**Required permissions:**
- Global Administrator OR
- Compliance Administrator + Teams Administrator + Exchange Administrator

**Data handled:**
- User email addresses (non-sensitive)
- Group membership (non-sensitive)
- Policy configurations (non-sensitive)
- No passwords or authentication tokens stored

---

## 📦 Package Information

**Version:** 9.0  
**Release Date:** November 22, 2025  
**Maintained By:** LCE M365 Security Team  
**Purpose:** Teams Premium deployment with automated policy management

**Compatible with:**
- Microsoft 365 E5
- Microsoft 365 E3 + Teams Premium add-on
- PowerShell 5.1 or later
- Windows 10/11, Windows Server 2016+

**Not tested with:**
- Microsoft 365 Business plans
- GCC/GCC High environments (may require modifications)
- PowerShell Core (may work but not tested)

---

## 🚀 Next Steps

**You've opened this index. Now what?**

1. **If this is your first time:**
   - Open **README.md**
   - Read completely
   - Follow step-by-step

2. **If you're experienced:**
   - Open **Quick-Start-Guide.md**
   - Deploy in 30 minutes
   - Verify with script 04

3. **If you're troubleshooting:**
   - Run **04-Diagnose-Label-Policy-Status.ps1**
   - Read the output
   - Follow recommended actions

4. **If you want to understand internals:**
   - Read **DEPLOYMENT-PACKAGE-SUMMARY.md**
   - Study the technical details
   - Review workflow diagrams

---

**Happy deploying! 🎉**

*For support, contact the LCE M365 Security team at lcem365security@leonardocompany.ca*
