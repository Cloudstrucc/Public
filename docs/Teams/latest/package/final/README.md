# LCE Teams Security Scripts - Complete Analysis & Recommendations

## Executive Summary

You have **8 scripts**. After review, I recommend **keeping 6** and **archiving 2**.

---

## Scripts to KEEP (Production Ready)

| # | Filename | Purpose | Run Order | Status |
|---|----------|---------|-----------|--------|
| 1 | `01-Create-Sensitivity-Labels.ps1` | Create the two sensitivity labels | **Phase 1** (one-time) | ✅ Good |
| 2 | `02-Configure-Label-Policy-TeamsOnly.ps1` | Publish labels to Teams ONLY | **Phase 2** (one-time) | ✅ Good |
| 3 | `03B-configure-label-meeting-enforcement.ps1` | Configure label meeting settings (guidance) | **Phase 3** (one-time) | ✅ Good |
| 4 | `04-create-protectedb-meeting-policy-maximum.ps1` | Create/update Teams meeting policy | **Phase 4** (one-time) | ⚠️ Minor issue |
| 5 | `05-MASTER-Group-Policy-Management-Enhanced.ps1` | Assign policy to group members | **Phase 5** (repeatable) | ✅ Good |
| 6 | `04-Diagnose-Label-Policy-Status.ps1` | Diagnostic/troubleshooting | **As needed** | ✅ Good |

---

## Scripts to ARCHIVE (Emergency/Utility Only)

| Filename | Purpose | Why Archive |
|----------|---------|-------------|
| `02B-Emergency-Remove-Outlook-Labels.ps1` | Fix if labels appear in Outlook | Only needed if Phase 2 fails |
| `02C-DELETE-LCE-Meeting-Labels-Policy.ps1` | Nuclear option - delete policy | Last resort only |

**Recommendation**: Move these to a subfolder called `_Emergency` so they're available but not confused with production scripts.

---

## Correct Run Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│  INITIAL SETUP (Run Once)                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: 01-Create-Sensitivity-Labels.ps1                      │
│     ↓     Creates labels in Purview                             │
│                                                                 │
│  Phase 2: 02-Configure-Label-Policy-TeamsOnly.ps1               │
│     ↓     Publishes labels to Teams ONLY                        │
│                                                                 │
│  Phase 3: 03B-configure-label-meeting-enforcement.ps1           │
│     ↓     Shows instructions to configure meeting enforcement   │
│     ↓     MANUAL STEP: Configure in Purview portal              │
│                                                                 │
│  Phase 4: 04-create-protectedb-meeting-policy-maximum.ps1       │
│     ↓     Creates meeting policy with secure defaults           │
│                                                                 │
│  Phase 5: 05-MASTER-Group-Policy-Management-Enhanced.ps1        │
│           Assigns policy to distribution group members          │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  ONGOING MAINTENANCE                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  • Re-run Phase 5 when group membership changes                 │
│  • Run Diagnostic script to verify configuration                │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  TROUBLESHOOTING (If Issues)                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Diagnostic: 04-Diagnose-Label-Policy-Status.ps1                │
│     ↓        Check current state                                │
│                                                                 │
│  If labels in Outlook: 02B-Emergency-Remove-Outlook-Labels.ps1  │
│     ↓                                                           │
│                                                                 │
│  Nuclear option: 02C-DELETE-LCE-Meeting-Labels-Policy.ps1       │
│                  Then re-run Phase 2                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Detailed Script Reviews

### ✅ 01-Create-Sensitivity-Labels.ps1
**Version**: 9.0  
**Status**: GOOD - No changes needed

**What it does**:
- Creates "Protected B - Secure Meeting" label (dark red)
- Creates "General - Regular Meeting" label (green)
- Sets colors via AdvancedSettings
- Idempotent (safe to re-run)

**Accuracy**: ✅ Correct


---

### ✅ 02-Configure-Label-Policy-TeamsOnly.ps1
**Version**: 9.0  
**Status**: GOOD - No changes needed

**What it does**:
- Creates "LCE Meeting Labels" policy
- Uses ModernGroupLocation (not Exchange) to target Teams
- Multiple fallback strategies
- Verifies Exchange locations = 0

**Accuracy**: ✅ Correct

**Key feature**: Does NOT use `-ExchangeLocation "All"` which was causing labels to appear in Outlook.


---

### ✅ 03B-configure-label-meeting-enforcement.ps1
**Version**: 1.0  
**Status**: GOOD - No changes needed

**What it does**:
- Checks current label configuration
- Sets label colors via PowerShell
- Provides detailed instructions for Purview portal configuration

**Accuracy**: ✅ Correct

**Important**: This script cannot fully configure meeting enforcement via PowerShell - it provides guidance for manual configuration in the Purview portal. This is correct because Microsoft requires portal configuration for meeting settings.


---

### ⚠️ 04-create-protectedb-meeting-policy-maximum.ps1
**Version**: 10.1  
**Status**: MINOR ISSUE - Policy name mismatch

**What it does**:
- Creates/updates Teams meeting policy with maximum security settings
- Validates parameters
- Verifies settings after application

**Issue Found**:
```powershell
$CONFIG = @{
    PolicyName = "LCE-Protected-B-Policy"           # ← Primary name
    AlternativeNames = @("Leonardo-Secure-Meeting-Group")  # ← Your actual policy
}
```

Your actual policy is named `Leonardo-Secure-Meeting-Group`, which the script handles as an "alternative" - so it works, but the naming is confusing.

**Recommended Fix**: Change to:
```powershell
$CONFIG = @{
    PolicyName = "Leonardo-Secure-Meeting-Group"
    AlternativeNames = @()
}
```

**Other Accuracy**: ✅ Policy parameters are correct and validated


---

### ✅ 05-MASTER-Group-Policy-Management-Enhanced.ps1
**Version**: 10.1  
**Status**: GOOD - No changes needed

**What it does**:
- Reads distribution group membership from Exchange
- Assigns Teams meeting policy to each member
- Handles "Tag:" prefix correctly
- Reports on assignments

**Accuracy**: ✅ Correct

**Configuration is correct**:
```powershell
$CONFIG = @{
    GroupEmail = "lcem365security@leonardocompany.ca"
    MeetingPolicy = "Leonardo-Secure-Meeting-Group"  # ✅ Correct policy name
}
```


---

### ✅ 04-Diagnose-Label-Policy-Status.ps1
**Version**: 9.0  
**Status**: GOOD - No changes needed

**What it does**:
- Shows all label policies in tenant
- Identifies LCE Meeting Labels policy
- Checks Exchange/SharePoint/OneDrive locations
- Provides health check and recommendations

**Accuracy**: ✅ Correct


---

### 🔶 02B-Emergency-Remove-Outlook-Labels.ps1 (ARCHIVE)
**Version**: 9.0  
**Status**: UTILITY - Move to _Emergency folder

**What it does**:
- Removes Exchange locations from policy
- Sets Outlook disable flags
- Emergency fix if labels appear in Outlook

**Accuracy**: ✅ Correct

**Note**: Only needed if Phase 2 script fails to remove Exchange locations.


---

### 🔶 02C-DELETE-LCE-Meeting-Labels-Policy.ps1 (ARCHIVE)
**Version**: 9.0  
**Status**: UTILITY - Move to _Emergency folder

**What it does**:
- Completely deletes the label policy
- Requires two confirmations (DELETE, YES DELETE IT)
- Labels are preserved, only policy is deleted

**Accuracy**: ✅ Correct

**Note**: Nuclear option - only use if all else fails.


---

## Recommended File Organization

```
C:\Scripts\LCE-Teams-Security\
├── 01-Create-Sensitivity-Labels.ps1
├── 02-Configure-Label-Policy-TeamsOnly.ps1
├── 03B-configure-label-meeting-enforcement.ps1
├── 04-create-protectedb-meeting-policy-maximum.ps1
├── 04-Diagnose-Label-Policy-Status.ps1
├── 05-MASTER-Group-Policy-Management-Enhanced.ps1
├── README.md
└── _Emergency\
    ├── 02B-Emergency-Remove-Outlook-Labels.ps1
    └── 02C-DELETE-LCE-Meeting-Labels-Policy.ps1
```

---

## Quick Reference Table

| Phase | Script | Run When | Duration |
|-------|--------|----------|----------|
| 1 | `01-Create-Sensitivity-Labels.ps1` | Initial setup | ~1 min |
| 2 | `02-Configure-Label-Policy-TeamsOnly.ps1` | Initial setup | ~2 min |
| 3 | `03B-configure-label-meeting-enforcement.ps1` | Initial setup | ~1 min + manual portal work |
| 4 | `04-create-protectedb-meeting-policy-maximum.ps1` | Initial setup | ~2 min |
| 5 | `05-MASTER-Group-Policy-Management-Enhanced.ps1` | Initial + when membership changes | ~1 min |
| - | `04-Diagnose-Label-Policy-Status.ps1` | Troubleshooting | ~30 sec |

---

## Current Status (Based on Our Session)

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1 | ✅ Complete | Labels exist |
| Phase 2 | ✅ Complete | ExchangeLocation = 0 |
| Phase 3 | ⚠️ Needs Portal Config | Run script for instructions, then configure in Purview |
| Phase 4 | ✅ Complete | Policy configured (Leonardo-Secure-Meeting-Group) |
| Phase 5 | ✅ Complete | 4 users assigned |

**Remaining Action**: Configure meeting enforcement settings in Purview portal (Phase 3 manual step).

---

## Summary

1. **Keep 6 scripts** for production use
2. **Archive 2 scripts** to _Emergency folder
3. **Fix policy name** in script 04 (optional - works as-is)
4. **Complete Phase 3** manual configuration in Purview portal
5. **Wait 24-48 hours** for full propagation
6. **Test** by creating a Protected B meeting and verifying locked settings