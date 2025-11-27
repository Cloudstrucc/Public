# LCE Teams Premium Deployment - START HERE

## 📦 What You Have

This package contains everything needed to deploy Teams Premium with automated monitoring for Leonardo Company's LCE M365 Security group.

## 📂 Files Included

### Core Scripts (Run in Order):
1. **01-Create-Sensitivity-Labels.ps1** - Creates Protected B and General labels
2. **02-Configure-Label-Policy-TeamsOnly.ps1** - Publishes labels to Teams ONLY
3. **02B-Emergency-Remove-Outlook-Labels.ps1** - Removes labels from Outlook (if needed)
4. **02C-DELETE-LCE-Meeting-Labels-Policy.ps1** - **FALLBACK** - Deletes policy entirely
5. **03-Remove-Outlook-From-LCE-Meeting-Labels.ps1** - Focused Outlook removal tool
6. **04-Diagnose-Label-Policy-Status.ps1** - Diagnostic tool showing all policies
7. **05-MASTER-Group-Policy-Management-Enhanced.ps1** - Main automation script

### Documentation:
- **Teams-Premium-Build-Book-v9.0-COMPLETE.md** - Full deployment guide (comprehensive)
- **Quick-Start-Guide.md** - 30-minute quickstart (for experienced admins)
- **README.md** - This file

## 🚀 Quick Start (30 Minutes)

**For experienced admins with PowerShell and Microsoft 365 admin experience:**

```powershell
# Step 1: Create distribution group (if not exists)
# Via web: https://admin.exchange.microsoft.com
# Group email: lcem365security@leonardocompany.ca
# Members: Fred, George, Chris, Adrian

# Step 2: Create sensitivity labels
.\01-Create-Sensitivity-Labels.ps1

# Step 3: Configure labels for Teams only
.\02-Configure-Label-Policy-TeamsOnly.ps1

# Step 4: Verify configuration (CRITICAL)
.\04-Diagnose-Label-Policy-Status.ps1
# Look for: Exchange locations = 0

# Step 5: If Exchange locations > 0, fix it
.\02B-Emergency-Remove-Outlook-Labels.ps1

# Step 6: Wait 24-48 hours for propagation

# Step 7: Test and verify
# - Teams: Labels should appear in meeting creation
# - Outlook: Labels should NOT appear in email composition
```

## 📖 Full Deployment (For New Technical Resources)

**If you're new to PowerShell, Microsoft 365 admin, or want detailed step-by-step instructions:**

1. Open **Teams-Premium-Build-Book-v9.0-COMPLETE.md**
2. Follow phases 1-8 sequentially
3. Each phase includes:
   - Why it matters (context)
   - Step-by-step instructions (detailed)
   - What success looks like (verification)
   - Troubleshooting tips (common issues)

**Time estimate:** 8-10 hours spread over 3-5 days (includes waiting for propagation)

## 🎯 What Each Script Does

| Script | Purpose | When to Use | Safe to Re-run? |
|--------|---------|-------------|-----------------|
| **01** | Creates sensitivity labels | Initial setup | ✅ Yes |
| **02** | Publishes labels to Teams ONLY | After script 01 | ✅ Yes |
| **02B** | Emergency Outlook removal | If labels appear in Outlook | ✅ Yes |
| **02C** | Deletes entire policy | Nuclear option - start fresh | ⚠️ Requires reconfiguration |
| **03** | Focused Outlook removal | Alternative to 02B | ✅ Yes |
| **04** | Diagnostic tool | Anytime you need to check status | ✅ Yes (read-only) |
| **05** | Master automation | Daily/scheduled policy management | ✅ Yes |

## ✅ Success Criteria

Your deployment is successful when all of these are true:

**Group Setup:**
- [ ] Distribution group exists: `lcem365security@leonardocompany.ca`
- [ ] Group has 4 members (Fred, George, Chris, Adrian)
- [ ] Test email sent to group reaches all 4 people

**Labels Created:**
- [ ] Two labels exist in Microsoft Purview:
  - Protected B - Secure Meeting (dark red)
  - General - Regular Meeting (green)

**Policy Configuration (CRITICAL):**
- [ ] Diagnostic script shows: **Exchange locations = 0**
- [ ] Diagnostic script shows: **SharePoint locations = 0**
- [ ] Diagnostic script shows: **OneDrive locations = 0**
- [ ] Policy name is exactly: "LCE Meeting Labels"

**User Experience:**
- [ ] Labels appear in Teams when creating a meeting
- [ ] Labels DO NOT appear in Outlook when composing email
- [ ] Labels DO NOT appear in Word, Excel, or PowerPoint

**Automation:**
- [ ] Master script runs without errors
- [ ] Reports generated in C:\LeonardoReports

## 🆘 Emergency Procedures

### Issue: Labels appearing in Outlook email

**Quick fix:**
```powershell
.\02B-Emergency-Remove-Outlook-Labels.ps1
```

**If that doesn't work:**
```powershell
# Check current status
.\04-Diagnose-Label-Policy-Status.ps1

# If Exchange locations still > 0, try alternative
.\03-Remove-Outlook-From-LCE-Meeting-Labels.ps1

# Still not working? Nuclear option
.\02C-DELETE-LCE-Meeting-Labels-Policy.ps1
# Then re-run: .\02-Configure-Label-Policy-TeamsOnly.ps1
```

### Issue: Labels not appearing anywhere

**Possible causes:**
1. Policy not created yet → Run script 02
2. Waiting for propagation → Wait 24-48 hours
3. Policy was deleted → Re-run script 02
4. Labels don't exist → Re-run script 01

**Diagnosis:**
```powershell
.\04-Diagnose-Label-Policy-Status.ps1
# This shows everything - policies, labels, locations
```

### Issue: Script fails with "Access Denied"

**Required roles:**
- Global Administrator (initial setup)
- Compliance Administrator (labels)
- Teams Administrator (policies)
- Exchange Administrator (group management)

**Check your roles:**
1. Go to https://admin.microsoft.com
2. Users → Active users
3. Find yourself → Manage roles
4. Verify you have required roles

## 📋 Prerequisites Checklist

**Before you start, verify you have:**

- [ ] Microsoft 365 E5 license (or E3 + Teams Premium)
- [ ] Administrator permissions (see above)
- [ ] PowerShell 5.1 or later
- [ ] Required modules installed:
  ```powershell
  Install-Module ExchangeOnlineManagement -Force
  Install-Module MicrosoftTeams -Force
  Install-Module Microsoft.Graph -Force
  ```
- [ ] Internet access
- [ ] 8-10 hours of time (spread over several days)

## 🔄 Normal Operations (After Initial Setup)

### Adding a New User to Security Group

**Option 1: Web Interface**
1. Go to https://admin.exchange.microsoft.com
2. Recipients → Groups
3. Find "LCE M365 Security"
4. Add member
5. Wait 5-10 minutes
6. Run master script to assign policies:
   ```powershell
   .\05-MASTER-Group-Policy-Management-Enhanced.ps1
   ```

**Option 2: PowerShell**
```powershell
Connect-ExchangeOnline

Add-DistributionGroupMember `
    -Identity "lcem365security@leonardocompany.ca" `
    -Member "newuser@leonardocompany.ca"

# Then assign policies
.\05-MASTER-Group-Policy-Management-Enhanced.ps1

Disconnect-ExchangeOnline
```

### Removing a User from Security Group

```powershell
Connect-ExchangeOnline

Remove-DistributionGroupMember `
    -Identity "lcem365security@leonardocompany.ca" `
    -Member "olduser@leonardocompany.ca" `
    -Confirm:$false

# Then remove policies
.\05-MASTER-Group-Policy-Management-Enhanced.ps1

Disconnect-ExchangeOnline
```

### Scheduled Automation

**Set up daily policy check:**
1. Open Task Scheduler (Windows)
2. Create Basic Task
3. Name: "LCE Policy Management"
4. Trigger: Daily, 9:00 AM
5. Action: Start a program
   - Program: `powershell.exe`
   - Arguments: `-File "C:\Scripts\05-MASTER-Group-Policy-Management-Enhanced.ps1"`
6. Finish

## 📊 Monitoring and Reports

**All reports are saved to:** `C:\LeonardoReports`

**Report types:**
- `Labels-Created-*.txt` - Label creation summary
- `Label-Policy-Config-*.txt` - Policy configuration
- `Policy-Diagnostic-*.txt` - Full diagnostic output
- `PolicyManagement-*.txt` - Daily automation results
- `Logs\PolicyManagement-*.log` - Detailed execution logs

**Check reports regularly:**
```powershell
# View latest diagnostic
$latest = Get-ChildItem C:\LeonardoReports\Policy-Diagnostic-*.txt | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Get-Content $latest.FullName
```

## 🔍 Verification Commands

**Quick status check:**
```powershell
# Connect
Connect-IPPSSession

# Check labels exist
Get-Label | Where-Object {$_.DisplayName -like "*Meeting*"}

# Check policy configuration
$policy = Get-LabelPolicy -Identity "LCE Meeting Labels"
Write-Host "Exchange locations: $($policy.ExchangeLocation.Count)"
Write-Host "Should be: 0"

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false
```

**Check group members:**
```powershell
Connect-ExchangeOnline

Get-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" | 
    Select-Object DisplayName, PrimarySmtpAddress

Disconnect-ExchangeOnline -Confirm:$false
```

## 📚 Additional Resources

**Microsoft Documentation:**
- Sensitivity Labels: https://docs.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels
- Teams Premium: https://docs.microsoft.com/en-us/microsoftteams/teams-premium
- Label Policies: https://docs.microsoft.com/en-us/microsoft-365/compliance/create-sensitivity-labels

**Internal Documentation:**
- Full Build Book: `Teams-Premium-Build-Book-v9.0-COMPLETE.md`
- Quick Start: `Quick-Start-Guide.md`

## 📞 Support Contacts

**Primary:** george.zarif@leonardocompany.ca  
**Secondary:** fred.pearson@leonardocompany.ca  
**Group Email:** lcem365security@leonardocompany.ca

## 🔒 Security Notes

**These scripts:**
- ✅ Create labels for Teams meetings only
- ✅ Do NOT expose labels in email/documents
- ✅ Maintain audit trails
- ✅ Support Protected B classification
- ✅ Safe to run multiple times

**These scripts do NOT:**
- ❌ Modify existing emails or documents
- ❌ Delete user data
- ❌ Change user accounts
- ❌ Affect non-group members

## 📈 Version History

**v9.0 (Current)** - November 22, 2025
- Complete integrated deployment
- Automated monitoring and alerts
- Triple-layer Outlook prevention
- Comprehensive diagnostics
- Enhanced error handling

## 🎓 Training Notes

**For new team members:**
1. Read this README completely
2. Review Quick-Start-Guide.md
3. For detailed learning, work through Build Book phases
4. Practice on test tenant first if available
5. Shadow experienced admin during first deployment

**Key concepts to understand:**
- Distribution groups vs M365 groups
- Sensitivity labels vs retention labels
- Label policies vs labels themselves
- Exchange locations = Outlook visibility
- Propagation delays (24-48 hours)

## ⚡ Quick Reference

**Most Common Tasks:**

| Task | Command |
|------|---------|
| Check if labels exist | `.\04-Diagnose-Label-Policy-Status.ps1` |
| Fix Outlook labels | `.\02B-Emergency-Remove-Outlook-Labels.ps1` |
| Add user to group | Web: admin.exchange.microsoft.com |
| Assign policies to new user | `.\05-MASTER-Group-Policy-Management-Enhanced.ps1` |
| View latest report | `Get-ChildItem C:\LeonardoReports | Sort LastWriteTime -Desc | Select -First 1` |
| Test group email | Send to: lcem365security@leonardocompany.ca |

## 🚦 Traffic Light Status

**🟢 GREEN (All Good):**
- Exchange locations = 0
- Labels appear in Teams
- Labels don't appear in Outlook
- No errors in reports

**🟡 YELLOW (Needs Attention):**
- SharePoint/OneDrive locations > 0 (minor)
- Warnings in diagnostic
- Old reports (>7 days)

**🔴 RED (Immediate Action):**
- Exchange locations > 0
- Labels appearing in Outlook
- Errors in master script
- No recent automation runs

## 🎯 Next Steps

**After successful deployment:**
1. ✅ Verify with diagnostic script
2. ✅ Test in Teams (create meeting with label)
3. ✅ Test in Outlook (verify NO labels in email)
4. ✅ Schedule automation (Task Scheduler)
5. ✅ Document any customizations
6. ✅ Train other admins
7. ✅ Set up monitoring alerts (Phase 7 of Build Book)

---

**Current Version:** 9.0  
**Last Updated:** November 22, 2025  
**Maintained By:** LCE M365 Security Team

**Ready to begin?** → Start with `.\01-Create-Sensitivity-Labels.ps1`
