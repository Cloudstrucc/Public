# LCE Teams Premium Deployment Package - Complete Summary

**Package Version:** 9.0  
**Created:** November 22, 2025  
**For:** Leonardo Company - LCE M365 Security Team

---

## 📦 Package Contents

This deployment package contains **8 files** organized for easy Teams Premium deployment:

### PowerShell Scripts (7 files)

| # | File Name | Purpose | Run Order | Safe to Re-run |
|---|-----------|---------|-----------|----------------|
| 1 | `01-Create-Sensitivity-Labels.ps1` | Creates Protected B and General meeting labels | First | ✅ Yes |
| 2 | `02-Configure-Label-Policy-TeamsOnly.ps1` | Publishes labels to Teams ONLY (prevents Outlook) | Second | ✅ Yes |
| 3 | `02B-Emergency-Remove-Outlook-Labels.ps1` | Emergency fix if labels appear in Outlook | As needed | ✅ Yes |
| 4 | `02C-DELETE-LCE-Meeting-Labels-Policy.ps1` | Nuclear option - deletes policy to start fresh | Last resort | ⚠️ Requires reconfiguration |
| 5 | `03-Remove-Outlook-From-LCE-Meeting-Labels.ps1` | Focused Outlook removal (alternative to 02B) | As needed | ✅ Yes |
| 6 | `04-Diagnose-Label-Policy-Status.ps1` | Diagnostic tool - shows all policies and status | Anytime | ✅ Yes (read-only) |
| 7 | `05-MASTER-Group-Policy-Management-Enhanced.ps1` | Daily automation - assigns/removes policies | After setup | ✅ Yes |

### Documentation (1 file)

| # | File Name | Purpose | Audience |
|---|-----------|---------|----------|
| 8 | `README.md` | Complete package guide with quick start | Everyone |

---

## 🎯 Deployment Scenarios

### Scenario 1: New Deployment (From Scratch)

**You need to set everything up for the first time.**

**Steps:**
1. Create distribution group (web or PowerShell)
   - Email: lcem365security@leonardocompany.ca
   - Members: Fred, George, Chris, Adrian

2. Run scripts in order:
   ```powershell
   .\01-Create-Sensitivity-Labels.ps1
   .\02-Configure-Label-Policy-TeamsOnly.ps1
   .\04-Diagnose-Label-Policy-Status.ps1  # Verify Exchange = 0
   ```

3. Wait 24-48 hours for propagation

4. Test and verify:
   - Labels in Teams: ✅ Should appear
   - Labels in Outlook: ❌ Should NOT appear

5. Set up daily automation:
   ```powershell
   # Create scheduled task for:
   .\05-MASTER-Group-Policy-Management-Enhanced.ps1
   ```

**Time:** 30-45 minutes active + 24-48 hours waiting

---

### Scenario 2: Labels Appearing in Outlook (Fix)

**Labels are showing up in Outlook email composition and shouldn't be.**

**Quick fix:**
```powershell
.\02B-Emergency-Remove-Outlook-Labels.ps1
```

**If that doesn't work:**
```powershell
.\03-Remove-Outlook-From-LCE-Meeting-Labels.ps1
```

**Still not working? Diagnostic check:**
```powershell
.\04-Diagnose-Label-Policy-Status.ps1
# Look at Exchange locations - should be 0
```

**Nuclear option (last resort):**
```powershell
.\02C-DELETE-LCE-Meeting-Labels-Policy.ps1
# Then recreate:
.\02-Configure-Label-Policy-TeamsOnly.ps1
```

**Time:** 10-15 minutes + wait for propagation

---

### Scenario 3: Policy Configuration Broken (Start Fresh)

**Something is wrong and you want to completely reset the policy.**

**Steps:**
```powershell
# 1. Delete existing policy
.\02C-DELETE-LCE-Meeting-Labels-Policy.ps1

# 2. Verify labels still exist
.\04-Diagnose-Label-Policy-Status.ps1

# 3. If labels are missing, recreate them
.\01-Create-Sensitivity-Labels.ps1

# 4. Recreate policy with correct configuration
.\02-Configure-Label-Policy-TeamsOnly.ps1

# 5. Verify Exchange = 0
.\04-Diagnose-Label-Policy-Status.ps1
```

**Time:** 20-30 minutes + wait for propagation

---

### Scenario 4: Daily Operations (Normal Use)

**System is deployed and working. You need to manage users.**

**Add user to security group:**
```powershell
Connect-ExchangeOnline

Add-DistributionGroupMember `
    -Identity "lcem365security@leonardocompany.ca" `
    -Member "newuser@leonardocompany.ca"

# Assign policies automatically
.\05-MASTER-Group-Policy-Management-Enhanced.ps1

Disconnect-ExchangeOnline -Confirm:$false
```

**Remove user from security group:**
```powershell
Connect-ExchangeOnline

Remove-DistributionGroupMember `
    -Identity "lcem365security@leonardocompany.ca" `
    -Member "olduser@leonardocompany.ca" `
    -Confirm:$false

# Remove policies automatically
.\05-MASTER-Group-Policy-Management-Enhanced.ps1

Disconnect-ExchangeOnline -Confirm:$false
```

**Check system health:**
```powershell
.\04-Diagnose-Label-Policy-Status.ps1
```

**Time:** 5 minutes per user operation

---

### Scenario 5: Troubleshooting Unknown Issue

**Something isn't working and you're not sure what.**

**Diagnostic steps:**

1. **Run full diagnostic:**
   ```powershell
   .\04-Diagnose-Label-Policy-Status.ps1
   ```

2. **Check for:**
   - LCE Meeting Labels policy exists?
   - Exchange locations = 0?
   - SharePoint/OneDrive locations = 0?
   - 2 labels in policy?
   - Any errors or warnings?

3. **Common issues and fixes:**

| Problem Found | Solution |
|---------------|----------|
| Policy not found | Run: `.\02-Configure-Label-Policy-TeamsOnly.ps1` |
| Exchange locations > 0 | Run: `.\02B-Emergency-Remove-Outlook-Labels.ps1` |
| Labels not found | Run: `.\01-Create-Sensitivity-Labels.ps1` |
| Multiple issues | Nuclear option: `.\02C-DELETE-...` then `.\02-Configure-...` |

4. **View reports:**
   ```powershell
   Get-ChildItem C:\LeonardoReports | Sort-Object LastWriteTime -Descending | Select-Object -First 5
   ```

**Time:** 15-20 minutes

---

## 📊 What Each Script Actually Does

### Script 01: Create Sensitivity Labels

**Technical details:**
- Connects to Microsoft Purview (IPPSSession)
- Creates two labels with New-Label cmdlet
- Sets display names, colors, tooltips
- Labels exist but are NOT published yet
- Safe to run multiple times (updates if exists)

**Output:**
- Protected B - Secure Meeting (dark red #A4262C)
- General - Regular Meeting (green #107C10)
- Report: `C:\LeonardoReports\Labels-Created-*.txt`

**What it does NOT do:**
- Does not publish labels anywhere
- Does not make labels visible to users
- Does not configure policies

---

### Script 02: Configure Label Policy for Teams Only

**Technical details:**
- Creates "LCE Meeting Labels" policy with New-LabelPolicy
- Adds both labels to policy
- Sets AdvancedSettings for Teams-only scope
- Explicitly removes Exchange locations (critical!)
- Removes SharePoint and OneDrive locations
- Configures OutlookDefaultLabel = "None"
- Sets DisableMandatoryInOutlook = "True"

**Output:**
- Policy published to Teams
- Exchange locations: 0 (verified)
- Report: `C:\LeonardoReports\Label-Policy-Config-*.txt`

**Critical success criteria:**
- Exchange locations MUST be 0
- SharePoint locations should be 0
- OneDrive locations should be 0

---

### Script 02B: Emergency Remove Outlook Labels

**Technical details:**
- Uses three different methods to remove Exchange:
  1. RemoveExchangeLocation "All"
  2. AddExchangeLocation @() (force empty)
  3. Advanced settings to disable Outlook
- Verifies Exchange = 0 after removal
- More aggressive than script 02

**When to use:**
- Script 02 verification shows Exchange > 0
- Labels appearing in Outlook email
- Need to force Exchange removal

**Output:**
- Exchange locations set to 0
- Report: `C:\LeonardoReports\Emergency-Outlook-Removal-*.txt`

---

### Script 02C: DELETE Policy (Nuclear Option)

**Technical details:**
- Requires double confirmation (safety measure)
- Completely deletes "LCE Meeting Labels" policy
- Verifies labels still exist (they should)
- Does NOT delete the labels themselves

**What gets deleted:**
- ✅ Entire label policy
- ✅ All location assignments
- ✅ All advanced settings

**What does NOT get deleted:**
- ✅ The sensitivity labels
- ✅ Your distribution group
- ✅ Any existing policies

**After running:**
- MUST re-run script 02 to recreate policy
- Labels won't appear anywhere until policy recreated

**Output:**
- Report: `C:\LeonardoReports\Policy-Deletion-*.txt`

---

### Script 03: Remove Outlook (Focused Tool)

**Technical details:**
- Simplified version of script 02B
- Focused only on Exchange/Outlook removal
- Uses same three methods as 02B
- Cleaner output, easier to read

**Difference from 02B:**
- More focused (Outlook only)
- Cleaner console output
- Simpler error handling
- Better for routine maintenance

**When to use:**
- Alternative to 02B
- Routine Exchange cleanup
- Prefer simpler output

**Output:**
- Report: `C:\LeonardoReports\Outlook-Removal-*.txt`

---

### Script 04: Diagnostic Tool

**Technical details:**
- Read-only - makes NO changes
- Gets all label policies in tenant
- Shows detailed configuration for each
- Identifies "LCE Meeting Labels" specifically
- Performs health check on LCE policy
- Color-coded output for easy reading

**Shows for each policy:**
- Name, GUID, creation date
- All labels in policy
- Exchange locations (critical!)
- SharePoint locations
- OneDrive locations
- Advanced settings
- Health status

**When to use:**
- Anytime you need to check status
- Before making changes
- After making changes (verification)
- Troubleshooting
- Regular health checks

**Output:**
- Detailed console output
- Report: `C:\LeonardoReports\Policy-Diagnostic-*.txt`

---

### Script 05: MASTER Automation

**Technical details:**
- Gets distribution group members
- Gets all Teams users
- Compares membership to policy assignments
- Assigns policies to group members
- Removes policies from non-members
- Maintains audit log
- Generates detailed report

**Workflow:**
1. Connect to Exchange, Teams, Purview
2. Get group members from lcem365security@leonardocompany.ca
3. Get all Teams-enabled users
4. For each user:
   - In group + no policy → Assign policy
   - In group + has policy → Skip (already correct)
   - Not in group + has policy → Remove policy
   - Not in group + no policy → Skip
5. Log all changes
6. Generate report
7. Disconnect

**Can be run:**
- Manually (on-demand)
- Scheduled (daily via Task Scheduler)
- After adding/removing group members

**Output:**
- Execution report: `C:\LeonardoReports\PolicyManagement-*.txt`
- Daily log: `C:\LeonardoReports\Logs\PolicyManagement-*.log`

---

## 🔄 Normal Workflow

### Initial Deployment Workflow

```
1. Create Distribution Group
   └→ lcem365security@leonardocompany.ca
   └→ 4 members

2. Run Script 01
   └→ Creates 2 labels
   └→ Labels exist but not published

3. Run Script 02
   └→ Creates policy
   └→ Publishes labels to Teams
   └→ Removes Exchange/Outlook

4. Run Script 04 (Verify)
   └→ Confirm Exchange = 0
   └→ If Exchange > 0:
      └→ Run Script 02B or 03
      └→ Re-verify with Script 04

5. Wait 24-48 hours
   └→ Microsoft propagation

6. Test
   └→ Teams: Labels appear ✅
   └→ Outlook: Labels don't appear ✅

7. Set up automation
   └→ Schedule Script 05 daily
```

### Daily Operations Workflow

```
User added to group:
1. Add to lcem365security@leonardocompany.ca
2. Run Script 05
   └→ Automatically assigns policies
   └→ Generates report

User removed from group:
1. Remove from lcem365security@leonardocompany.ca
2. Run Script 05
   └→ Automatically removes policies
   └→ Generates report

Scheduled automation:
1. Script 05 runs daily at 9 AM
2. Checks all group members
3. Assigns/removes policies as needed
4. Generates daily report
5. Logs to C:\LeonardoReports\Logs
```

### Troubleshooting Workflow

```
Issue detected:
1. Run Script 04 (Diagnostic)
   └→ Identify problem

2. Common fixes:
   ├→ Exchange > 0: Run Script 02B or 03
   ├→ Policy missing: Run Script 02
   ├→ Labels missing: Run Script 01
   └→ Everything broken: Run Script 02C, then 02

3. Verify fix:
   └→ Run Script 04 again
   └→ Confirm issue resolved

4. Wait for propagation (if needed)
   └→ 24-48 hours

5. Test functionality
   └→ Teams and Outlook
```

---

## 📁 File Organization

**Recommended folder structure:**

```
C:\Scripts\LCE-Teams-Premium\
├── 01-Create-Sensitivity-Labels.ps1
├── 02-Configure-Label-Policy-TeamsOnly.ps1
├── 02B-Emergency-Remove-Outlook-Labels.ps1
├── 02C-DELETE-LCE-Meeting-Labels-Policy.ps1
├── 03-Remove-Outlook-From-LCE-Meeting-Labels.ps1
├── 04-Diagnose-Label-Policy-Status.ps1
├── 05-MASTER-Group-Policy-Management-Enhanced.ps1
├── README.md
├── Quick-Start-Guide.md (if you create it)
└── Teams-Premium-Build-Book-v9.0-COMPLETE.md (if you have it)

C:\LeonardoReports\
├── Labels-Created-*.txt
├── Label-Policy-Config-*.txt
├── Emergency-Outlook-Removal-*.txt
├── Policy-Deletion-*.txt
├── Outlook-Removal-*.txt
├── Policy-Diagnostic-*.txt
├── PolicyManagement-*.txt
└── Logs\
    └── PolicyManagement-*.log
```

---

## ✅ Success Metrics

**Your deployment is successful when:**

| Metric | Target | How to Verify |
|--------|--------|---------------|
| Distribution group exists | ✅ Yes | Exchange Admin Center or `Get-DistributionGroup` |
| Group has 4 members | ✅ 4 | `Get-DistributionGroupMember` |
| Labels created | ✅ 2 | Script 04 or Purview portal |
| Policy exists | ✅ Yes | Script 04 |
| Exchange locations | ✅ 0 | Script 04 (CRITICAL) |
| SharePoint locations | ✅ 0 | Script 04 |
| OneDrive locations | ✅ 0 | Script 04 |
| Labels in Teams | ✅ Yes | Manual test - create meeting |
| Labels in Outlook | ❌ No | Manual test - compose email |
| Automation runs | ✅ Yes | Check C:\LeonardoReports\PolicyManagement-*.txt |
| No errors in reports | ✅ 0 | Review latest report files |

---

## 🎓 Key Concepts

**Distribution Group:**
- Simple email distribution list
- NOT a Microsoft 365 group
- Works with `Get-DistributionGroupMember`
- Easy automation
- No SharePoint or Teams team

**Sensitivity Labels:**
- Classification markers (Protected B, General)
- Apply security settings
- Color-coded
- Defined in Microsoft Purview

**Label Policy:**
- Controls WHERE labels appear
- Can publish to Teams, Outlook, SharePoint, etc.
- We publish ONLY to Teams
- Explicitly exclude Outlook

**Exchange Locations:**
- Controls Outlook email visibility
- If > 0, labels appear in Outlook
- MUST be 0 for Teams-only labels
- This is the most critical configuration

**Propagation Time:**
- Microsoft 365 changes take 24-48 hours
- Global distribution across datacenters
- Be patient - don't troubleshoot immediately
- Check diagnostic, then wait

---

## 📞 Support Resources

**Internal:**
- george.zarif@leonardocompany.ca (Primary contact)
- fred.pearson@leonardocompany.ca (Secondary contact)
- lcem365security@leonardocompany.ca (Group email)

**Documentation:**
- This summary file
- README.md (full guide)
- Quick-Start-Guide.md (experienced admins)
- Build Book (comprehensive, if available)

**Microsoft:**
- Sensitivity Labels: https://docs.microsoft.com/compliance/sensitivity-labels
- Teams Premium: https://docs.microsoft.com/microsoftteams/teams-premium
- PowerShell: https://docs.microsoft.com/powershell/exchange/

---

## 🔒 Security & Compliance Notes

**These scripts are safe:**
- ✅ Do not modify user data
- ✅ Do not delete emails or documents
- ✅ Do not change user accounts
- ✅ Maintain full audit trail
- ✅ Can be run multiple times safely
- ✅ Generate reports for compliance

**What they do:**
- Create/modify label policies
- Assign/remove Teams policies
- Configure security settings
- Generate reports

**Data handled:**
- User email addresses
- Group membership
- Policy configurations
- No sensitive/personal data

---

## Version & Maintenance

**Package Version:** 9.0  
**Release Date:** November 22, 2025  
**Maintained By:** LCE M365 Security Team

**Update schedule:**
- Review quarterly
- Update as Microsoft 365 features change
- Incorporate user feedback
- Address new requirements

**Change log:**
- v9.0: Complete integrated package with all scripts
- Future: Will track changes here

---

**Ready to deploy? Start with README.md for full instructions!**
