# LCE Teams Premium Monitoring - Quick Reference
## IT Administrator Cheat Sheet

---

## 🚀 Daily Operations (Automated - Just Monitor Inbox!)

**What You'll Receive:**

| Time | Alert Type | Action Required |
|------|------------|-----------------|
| **8:00 AM** | Daily Summary Email | Only if issues detected - review and remediate |
| **Real-time** | Critical Alerts | Immediate action required (Sev 0/1) |
| **5:00 PM** | Alert Digest | Review accumulated alerts from the day |
| **Monday 10:00 AM** | Weekly Compliance Report | Review and verify 95%+ compliance |

---

## 📧 What the Emails Mean

### ✅ All Clear Email
```
Subject: ✅ LCE Daily Summary - All Clear
Action: None required - delete or archive
```

### ⚠️ Issues Detected Email
```
Subject: ⚠️ LCE Daily Summary - X Issues Detected
Action: Review issues and remediate within 24 hours
Common issues:
  • Missing Teams Premium license → Assign license
  • Wrong/no policy → Run sync script
  • New group member → Onboard user
```

### 🚨 Critical Alert Email
```
Subject: 🚨 CRITICAL - LCE Security Alert
Action: Immediate response required (< 15 minutes)
Common causes:
  • Policy change by unauthorized person
  • Key Vault access failure
  • CMK configuration issue
Escalate to: George Zarif + Security Officer
```

---

## 🔧 Quick Fixes

### Issue: User Missing Teams Premium License

**PowerShell Fix:**
```powershell
# Connect
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Assign license
Set-MgUserLicense -UserId "user@leonardocompany.ca" `
    -AddLicenses @{SkuId = "YOUR_TEAMS_PREMIUM_SKU_ID"} `
    -RemoveLicenses @()

# Verify
Get-MgUserLicenseDetail -UserId "user@leonardocompany.ca"
```

### Issue: User Missing Meeting Policy

**PowerShell Fix:**
```powershell
# Connect
Connect-MicrosoftTeams

# Apply default policy (Regular)
Grant-CsTeamsMeetingPolicy -Identity "user@leonardocompany.ca" `
    -PolicyName "Leonardo-Regular-Meeting-Group"

# Verify
Get-CsUserPolicyAssignment -Identity "user@leonardocompany.ca" `
    -PolicyType TeamsMeetingPolicy
```

### Issue: New User Added to Group

**Actions:**
1. Assign Teams Premium license (see above)
2. Apply meeting policy (see above)
3. Schedule onboarding training (30 min session)
4. Send welcome email with quick reference card
5. Add to CMK if required

### Issue: Multiple Users Non-Compliant

**Run Sync Script:**
```powershell
# Location
C:\Scripts\MonthlyGroupSync.ps1

# Or from Azure DevOps
git pull origin main
.\MonthlyGroupSync.ps1
```

---

## 📊 Monitoring Dashboard Access

### Microsoft Purview Compliance Portal
**URL:** https://compliance.microsoft.com

**What to Check:**
1. **Alerts** → View triggered alerts
2. **Audit** → Search for specific activities
3. **DLP** → View policy matches
4. **Content Explorer** → Label usage stats

**Navigation:**
```
Purview → Policies → Alert policies → Filter: "LCE -*"
```

### Power Automate Flows
**URL:** https://make.powerautomate.com

**Your Flows:**
- `LCE Daily Compliance Check` (Daily 8 AM)
- `LCE CMK Compliance Check` (Weekly Monday 9 AM)
- `LCE Meeting Type Usage Report` (Weekly Friday 4 PM)
- `LCE Alert Aggregator` (Real-time webhook)

**To Check Flow Health:**
```
My flows → [Flow name] → 28-day run history
Look for: Green checkmarks (success), Red X (failed)
```

### Azure Monitor / Log Analytics
**URL:** https://portal.azure.com → Monitor

**Quick Queries:**

**1. Key Vault Access Last 24 Hours:**
```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where TimeGenerated > ago(24h)
| summarize count() by OperationName, identity_claim_appid_g
```

**2. Meeting Creations by Type:**
```kusto
AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName == "MeetingCreated"
| extend MeetingType = extract("MeetingType\":\"([^\"]+)", 1, tostring(TargetResources))
| summarize count() by MeetingType
```

---

## 🚨 Escalation Matrix

| Issue Severity | Response Time | First Contact | Escalate To |
|----------------|---------------|---------------|-------------|
| **Sev 0/1** (Critical) | 15 minutes | George Zarif | Security Officer + Management |
| **Sev 2** (High) | 1 hour | George Zarif | Management (if not resolved in 4h) |
| **Sev 3** (Medium) | 4 hours | Handle locally | George Zarif (if patterns emerge) |
| **Informational** | 24 hours | Handle locally | None |

**Critical Issues = Immediate Escalation:**
- Key Vault inaccessible
- CMK policy failing
- Unauthorized policy changes
- Bulk license removals
- Data Encryption Policy errors

**Contact List:**

| Role | Name | Email | Phone | Escalation |
|------|------|-------|-------|------------|
| Primary Admin | George Zarif | george.zarif@leonardocompany.ca | [PHONE] | First contact |
| Power Platform Admin | Fred | fred@leonardocompany.ca | [PHONE] | For flow/automation issues |
| Security Officer | [TBD] | [EMAIL] | [PHONE] | Critical security events |
| Microsoft Support | Premier Support | 1-800-936-3100 | Sev A | Escalate Sev 0/1 |

---

## 🛠️ Common Maintenance Tasks

### Weekly (Every Monday 10 AM)

**Review Weekly Report:**
```
1. Open weekly compliance email
2. Check compliance rate (target: ≥95%)
3. If < 95%: Run remediation actions
4. Note any trends (licensing, policy drift)
5. Reply "Reviewed" to email thread
```

### Monthly (First Monday)

**Group Sync:**
```powershell
# Automatically runs via scheduled task
# Manually check results:
Get-Content "C:\LeonardoLogs\MonthlyGroupSync-$(Get-Date -Format 'yyyy-MM').log"
```

**Certificate Check:**
```powershell
# Check cert expiration
Connect-AzAccount
$kv = Get-AzKeyVault -VaultName "lce-cmk-keyvault-1"
Get-AzKeyVaultCertificate -VaultName $kv.VaultName | 
    Select-Object Name, Expires | 
    Where-Object {$_.Expires -lt (Get-Date).AddDays(90)}

# If < 90 days: Start renewal process (see SOP Section 12)
```

### Quarterly

**Alert Policy Review:**
```powershell
Connect-IPPSSession

# List all LCE alert policies
Get-ActivityAlert | Where-Object {$_.Name -like "LCE -*"} | 
    Select-Object Name, Enabled, Severity, Threshold, TimesTriggered

# Review: Are thresholds appropriate? Too many false positives?
```

**Flow Health Check:**
```
1. Go to Power Automate
2. My flows → Check 90-day success rate
3. If < 95% success: Investigate failures
4. Update flows if APIs changed
```

---

## 📁 File Locations & Scripts

### Scripts Repository
**Azure DevOps:** `[INSERT_YOUR_REPO_URL]`

**Local Copies:** `C:\Scripts\`

| Script | Purpose | Schedule |
|--------|---------|----------|
| `DailyHealthCheck.ps1` | Health monitoring | Now automated via alerts |
| `MonthlyGroupSync.ps1` | Sync group & policies | First Monday 9 AM |
| `LCE-Weekly-Report.ps1` | Weekly compliance report | Monday 10 AM |
| `Certificate-*.ps1` | Cert management | As needed |

### Log Locations

```
C:\LeonardoLogs\
├── DailyHealthCheck-YYYY-MM-DD.json
├── WeeklyCompliance-YYYY-MM-DD.csv
├── MonthlyGroupSync-YYYY-MM.json
└── Incidents\
    └── YYYY-MM-DD-[incident-type].log

C:\LeonardoBackups\
└── YYYY-MM-DD\
    ├── SecurePolicy.json
    ├── RegularPolicy.json
    ├── GroupMembers.csv
    └── PolicyAssignments.csv

C:\LeonardoReports\
├── Daily\
├── Weekly\
└── Monthly\
```

---

## 🔍 Troubleshooting Guide

### Problem: Didn't Receive Daily Summary Email

**Check:**
```
1. Is it 8:00 AM EST? (Email only sent after 8 AM)
2. Check spam/junk folder
3. Verify Power Automate flow ran:
   https://make.powerautomate.com → My flows → LCE Daily Compliance Check
4. Check flow run history for errors
```

**If Flow Failed:**
```
1. Check error message in flow run history
2. Common cause: API throttling or permissions
3. Manually trigger flow to test
4. Contact Fred if consistently failing
```

### Problem: Alert Policy Not Triggering

**Diagnosis:**
```powershell
Connect-IPPSSession

# Check if alert is enabled
Get-ActivityAlert -Identity "LCE - [Alert Name]" | 
    Select-Object Enabled, NotifyUser, Threshold

# Check audit log has data
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-1) `
    -EndDate (Get-Date) -Operations "MeetingCreated" -ResultSize 10
```

**Fix:**
```powershell
# Re-enable alert
Set-ActivityAlert -Identity "LCE - [Alert Name]" -Enabled $true

# Update recipients
Set-ActivityAlert -Identity "LCE - [Alert Name]" `
    -NotifyUser @("fred@leonardocompany.ca", "george.zarif@leonardocompany.ca")
```

### Problem: Power Automate Flow Keeps Failing

**Common Causes:**
1. **Connection expired** → Re-authenticate connector
2. **Permission denied** → Grant admin consent
3. **Null data** → Add null checks in flow
4. **API limit hit** → Add delays between actions

**How to Fix:**
```
1. Open flow in edit mode
2. Expand failed action
3. Read error message
4. Click "..." → Settings → Connection
5. Delete and recreate connection
6. Grant admin consent if prompted
7. Save and retest flow
```

### Problem: Compliance Rate Suddenly Dropped

**Investigate:**
```powershell
# Check recent group changes
Connect-MgGraph
$group = Get-MgGroup -Filter "displayName eq 'LCE M365 Security'"
Get-MgGroupMember -GroupId $group.Id | Measure-Object

# Compare to last week's report
# Look for bulk additions (new hires?) or policy changes
```

**Actions:**
1. If bulk additions: Run onboarding process
2. If policy drift: Re-apply policies
3. If license issues: Check license pool availability
4. Document in monthly report

---

## 📞 Support Contacts

### Internal
- **George Zarif** (Primary Admin): george.zarif@leonardocompany.ca
- **Fred** (Power Platform Admin): fred@leonardocompany.ca
- **IT Helpdesk**: itsupport@leonardocompany.ca | ext. [XXX]

### Microsoft Support
- **Premier Support**: 1-800-936-3100
- **Azure Support Portal**: https://portal.azure.com → Support
- **Your TAM**: [TAM Name] | [TAM Email]

### Emergency After Hours
- **On-Call Admin**: [Phone number via on-call schedule]
- **Break-Glass Account**: emergency-admin@leonardocompany.ca
  - Credentials: [Secure vault location]

---

## 📱 Mobile Quick Actions

### If You Get a Critical Alert on Mobile

**Step 1: Assess (2 min)**
```
Read alert email carefully
Note: What, When, Who, Severity
```

**Step 2: Acknowledge (1 min)**
```
Reply to email: "Alert received. Investigating."
CC: George Zarif + Security Officer
```

**Step 3: Quick Fix if Possible (5 min)**
```
Use Microsoft Teams Admin mobile app:
- View recent policy changes
- Check service health
- Disable user if compromised
```

**Step 4: Escalate if Needed (immediate)**
```
If can't resolve in 15 min or is Key Vault issue:
Call George Zarif immediately
Then call Microsoft Support (Sev A)
```

---

## 🎯 Success Metrics

**You're Doing Great If:**

✅ **Compliance Rate:** ≥95% consistently  
✅ **Daily Email:** Received by 8:30 AM every business day  
✅ **Weekly Report:** Reviewed within 24 hours of receipt  
✅ **Alert Response:** Critical alerts handled in <15 min  
✅ **Remediation:** Non-critical issues resolved within 24h  
✅ **User Training:** New users onboarded within 48h  
✅ **No Escalations:** Most issues resolved without escalation  

**Red Flags:**

🚩 Compliance rate drops below 90%  
🚩 Multiple critical alerts in one day  
🚩 Weekly report shows increasing trends of issues  
🚩 Same user appears in alerts repeatedly  
🚩 Emails stop coming (monitoring system down!)  

---

## 🔐 Security Best Practices

1. **Never disable alerts** without documenting why
2. **Review all policy changes** even if authorized
3. **Investigate unusual patterns** (e.g., 10 meetings at midnight)
4. **Keep audit logs** for 1 year minimum
5. **Test disaster recovery** quarterly
6. **Rotate service principal secrets** annually
7. **Review access** to monitoring systems quarterly

---

## 📚 Additional Resources

**Documentation:**
- Full Build Book: `Teams_Premium_Monitoring_Build_Book.md`
- SOP: `standard-operating-proceedure-SOP.md`
- PowerShell Scripts: Azure DevOps repository

**Microsoft Docs:**
- Alert Policies: https://learn.microsoft.com/en-us/purview/alert-policies
- Audit Log: https://learn.microsoft.com/en-us/purview/audit-log-search
- Teams Admin: https://learn.microsoft.com/en-us/microsoftteams/

**Training:**
- Teams Premium Features: [Internal training link]
- Purview Compliance: Microsoft Learn module
- Power Automate: [Internal training link]

---

## 🆘 When in Doubt

**Golden Rule:** If you're not sure, escalate to George Zarif.

**Better to:**
- ✅ Ask and confirm before acting
- ✅ Document your question and the answer
- ✅ Update this cheat sheet for the next person

**Never:**
- ❌ Disable monitoring "temporarily" and forget
- ❌ Ignore alerts because "they're probably nothing"
- ❌ Make changes without testing in dev first
- ❌ Skip documentation because you're in a rush

---

**Last Updated:** 2025-11-18  
**Version:** 1.0  
**Next Review:** 2026-02-18

**Maintained by:** George Zarif (george.zarif@leonardocompany.ca)

---