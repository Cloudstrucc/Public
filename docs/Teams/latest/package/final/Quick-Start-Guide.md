# LCE Teams Premium - Quick Start Guide

**For experienced Microsoft 365 administrators**  
**Estimated time: 30-45 minutes (plus 24-48 hour propagation)**

---

## Prerequisites Check (5 minutes)

✅ **Roles:** Global Admin or Compliance Admin + Teams Admin + Exchange Admin  
✅ **Licenses:** M365 E5 or E3 + Teams Premium per user  
✅ **PowerShell:** Version 5.1 or later  
✅ **Modules installed:**

```powershell
Install-Module ExchangeOnlineManagement -Force
Install-Module MicrosoftTeams -Force
Install-Module Microsoft.Graph -Force
```

---

## Step 1: Create Distribution Group (5 minutes)

**Web method (recommended):**
1. Navigate to: https://admin.exchange.microsoft.com
2. Recipients → Groups → **Add a group**
3. Type: **Distribution** (NOT Microsoft 365 group)
4. Name: `LCE M365 Security`
5. Email: `lcem365security@leonardocompany.ca`
6. Members: Add Fred, George, Chris, Adrian
7. Owner: fred.pearson@leonardocompany.ca

**PowerShell method:**
```powershell
Connect-ExchangeOnline

New-DistributionGroup `
    -Name "LCE M365 Security" `
    -Type "Security" `
    -PrimarySmtpAddress "lcem365security@leonardocompany.ca"

Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "fred.pearson@leonardocompany.ca"
Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "george.zarif@leonardocompany.ca"
Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "chris.helm@leonardocompany.ca"
Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "adrian.darjan@leonardocompany.ca"

Disconnect-ExchangeOnline -Confirm:$false
```

**Verify:** Send test email to `lcem365security@leonardocompany.ca` - all 4 should receive it

---

## Step 2: Create Sensitivity Labels (5 minutes)

```powershell
.\01-Create-Sensitivity-Labels.ps1
```

**What it creates:**
- **Protected B - Secure Meeting** (dark red #A4262C)
- **General - Regular Meeting** (green #107C10)

**Verify in portal:**
- https://compliance.microsoft.com → Information protection → Labels
- Both labels should exist but show "Published: No"

---

## Step 3: Configure Labels for Teams ONLY (10 minutes)

**CRITICAL STEP** - This prevents labels from appearing in Outlook.

```powershell
.\02-Configure-Label-Policy-TeamsOnly.ps1
```

**What it does:**
- Creates "LCE Meeting Labels" policy
- Publishes labels with **Teams-only** scope
- Sets Exchange locations to **0** (this is critical)
- Configures advanced settings to disable Outlook

**Expected output:**
```
Exchange (Outlook): 0 locations ✓
SharePoint: 0 locations ✓
OneDrive: 0 locations ✓
```

---

## Step 4: Verify Configuration (5 minutes)

**Run diagnostic:**
```powershell
.\04-Diagnose-Label-Policy-Status.ps1
```

**Check for:**
- ✅ "LCE Meeting Labels" policy found
- ✅ Exchange locations: **0** (MUST be zero!)
- ✅ SharePoint locations: 0
- ✅ OneDrive locations: 0
- ✅ 2 labels in policy

**If Exchange locations > 0:**
```powershell
.\02B-Emergency-Remove-Outlook-Labels.ps1
# Then re-run diagnostic to verify Exchange = 0
```

---

## Step 5: Wait for Propagation (24-48 hours)

Microsoft needs time to propagate label policies across the tenant.

**During this time:**
- Labels won't appear in Teams yet (normal)
- Don't make additional changes
- Don't panic if nothing shows up immediately

**Optional monitoring:**
```powershell
# Check policy status
Connect-IPPSSession
Get-LabelPolicy -Identity "LCE Meeting Labels" | Select-Object Name, ExchangeLocation, WhenChanged
Disconnect-ExchangeOnline -Confirm:$false
```

---

## Step 6: Test Label Visibility (Day 2-3)

**After 24-48 hours:**

### Test 1: Teams (labels SHOULD appear)
1. Open Microsoft Teams
2. Calendar → New meeting
3. Look for sensitivity dropdown
4. Should see:
   - Protected B - Secure Meeting ✓
   - General - Regular Meeting ✓

### Test 2: Outlook (labels should NOT appear)
1. Open Outlook (web or desktop)
2. New email
3. Look for sensitivity button/dropdown
4. Should NOT see meeting labels ✓
5. (Other labels may appear if you have them)

### Test 3: Verification
```powershell
.\04-Diagnose-Label-Policy-Status.ps1
```

Confirm:
- LCE Policy health: **HEALTHY**
- Exchange locations: **0**
- No errors or warnings

---

## Step 7: Set Up Automation (10 minutes)

**Create scheduled task for daily policy management:**

```powershell
# Option 1: PowerShell Task Creation
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-File C:\Scripts\05-MASTER-Group-Policy-Management-Enhanced.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "LCE Policy Management" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Daily Teams policy management for LCE M365 Security group"
```

**Option 2: Task Scheduler GUI**
1. Open Task Scheduler
2. Create Basic Task: "LCE Policy Management"
3. Trigger: Daily, 9:00 AM
4. Action: `powershell.exe -File "C:\Scripts\05-MASTER-Group-Policy-Management-Enhanced.ps1"`
5. Run whether user is logged on or not

**Test automation manually:**
```powershell
.\05-MASTER-Group-Policy-Management-Enhanced.ps1
```

Check report in: `C:\LeonardoReports\PolicyManagement-*.txt`

---

## Success Checklist

After completing all steps, verify:

- [x] Distribution group `lcem365security@leonardocompany.ca` exists
- [x] Group has 4 members
- [x] Two sensitivity labels created (Protected B, General)
- [x] Label policy "LCE Meeting Labels" exists
- [x] Diagnostic shows: Exchange locations = **0**
- [x] Labels appear in Teams meeting creation
- [x] Labels do NOT appear in Outlook email
- [x] Master automation script runs successfully
- [x] Reports generated in C:\LeonardoReports
- [x] Scheduled task created for daily automation

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Labels in Outlook | Run: `.\02B-Emergency-Remove-Outlook-Labels.ps1` |
| Labels not in Teams | Wait 24-48 hours, check propagation |
| Exchange locations > 0 | Run: `.\03-Remove-Outlook-From-LCE-Meeting-Labels.ps1` |
| Policy not found | Run: `.\02-Configure-Label-Policy-TeamsOnly.ps1` |
| Script errors | Verify admin roles and module installation |
| Group not found | Re-create in Exchange Admin Center |

**Nuclear option (start fresh):**
```powershell
.\02C-DELETE-LCE-Meeting-Labels-Policy.ps1
# Then re-run: .\02-Configure-Label-Policy-TeamsOnly.ps1
```

---

## Daily Operations

**Add new user to security group:**
```powershell
Connect-ExchangeOnline
Add-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "newuser@leonardocompany.ca"
.\05-MASTER-Group-Policy-Management-Enhanced.ps1
Disconnect-ExchangeOnline -Confirm:$false
```

**Remove user from security group:**
```powershell
Connect-ExchangeOnline
Remove-DistributionGroupMember -Identity "lcem365security@leonardocompany.ca" -Member "olduser@leonardocompany.ca" -Confirm:$false
.\05-MASTER-Group-Policy-Management-Enhanced.ps1
Disconnect-ExchangeOnline -Confirm:$false
```

**Check status:**
```powershell
.\04-Diagnose-Label-Policy-Status.ps1
```

**View latest report:**
```powershell
Get-ChildItem C:\LeonardoReports | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

---

## Expected Timeline

| Day | Activity | Status |
|-----|----------|--------|
| **Day 1 AM** | Create group, labels, policy | Scripts complete successfully |
| **Day 1 PM** | Verify configuration | Diagnostic shows Exchange = 0 |
| **Day 2** | Wait for propagation | No action needed |
| **Day 3** | Test label visibility | Labels in Teams, not in Outlook |
| **Day 3** | Set up automation | Daily task scheduled |
| **Ongoing** | Daily automation runs | Check reports periodically |

---

## Key Technical Details

**Why Exchange locations MUST be 0:**
- Exchange locations = labels appear in Outlook
- We want labels ONLY in Teams meetings
- If Exchange > 0, users see meeting labels in email (confusing)

**Distribution Group vs M365 Group:**
- Distribution: Simple email list, works with Get-DistributionGroupMember
- M365: Has Teams, SharePoint, more complex, harder to automate
- We use Distribution for simplicity

**Label Policy Scopes:**
- Labels = the actual security classifications
- Policy = controls WHERE labels appear (Teams, Outlook, etc.)
- One policy can publish to multiple locations
- We publish to Teams, explicitly exclude Outlook

**Propagation Time:**
- Microsoft 365 changes take 24-48 hours globally
- Some users may see changes sooner
- Don't troubleshoot within first 48 hours unless diagnostic shows errors

---

## Next Steps After Deployment

1. **Document customizations** - Note any changes made to scripts
2. **Train other admins** - Share this guide with team
3. **Set up monitoring** - Review reports weekly
4. **Plan Customer Managed Keys** - See Build Book Phase 5
5. **Configure meeting policies** - Add watermarks, lobby settings
6. **Test extensively** - Create meetings with both labels
7. **Gather user feedback** - Ensure labels are clear and useful

---

## Advanced Configurations (Optional)

**Custom label colors:**
Edit script 01, change:
```powershell
color = "#A4262C"  # Dark red for Protected B
color = "#107C10"  # Green for General
```

**Additional labels:**
Add more labels in script 01, update policy in script 02

**Custom meeting policies:**
Create additional policies in Teams Admin Center, assign via master script

**Email notifications:**
Modify master script to send email on completion:
```powershell
Send-MailMessage -To "lcem365security@leonardocompany.ca" -Subject "Policy Update" -Body $report
```

---

## Support

**Documentation:**
- Full Build Book: `Teams-Premium-Build-Book-v9.0-COMPLETE.md`
- This guide: `Quick-Start-Guide.md`
- README: `README.md`

**Contacts:**
- george.zarif@leonardocompany.ca (Primary)
- fred.pearson@leonardocompany.ca (Secondary)
- lcem365security@leonardocompany.ca (Group)

**Microsoft Resources:**
- Sensitivity Labels: https://docs.microsoft.com/compliance/sensitivity-labels
- Teams Premium: https://docs.microsoft.com/microsoftteams/teams-premium
- Label Policies: https://docs.microsoft.com/compliance/create-sensitivity-labels

---

## Version Information

**Quick Start Guide Version:** 9.0  
**Last Updated:** November 22, 2025  
**Deployment Package Version:** 9.0  
**Compatible with:** Microsoft 365 E5, E3 + Teams Premium

---

**Ready? Start with Step 1 above!**

**Estimated total time:** 30-45 minutes active work + 24-48 hours propagation
