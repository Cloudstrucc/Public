# LCE Teams Security - Sensitivity Labels & Meeting Policies

Complete deployment package for Teams Premium sensitivity labels and secure meeting policies at Leonardo Canada Inc.

## Overview

This solution implements:

- **Sensitivity Labels** for Teams meetings (Protected B, Unclassified)
- **Meeting Policies** with maximum security settings for classified meetings
- **Group-Based Policy Assignment** for automated user management
- **Optional Conditional Access** for mobile app protection

## Prerequisites

- Microsoft 365 E5 or Teams Premium licenses
- Exchange Online Management PowerShell module (v3.0.0+)
- Microsoft Teams PowerShell module
- Global Admin or Compliance Admin + Teams Admin permissions
- Security & Compliance PowerShell access

```powershell
Install-Module ExchangeOnlineManagement -Force
Install-Module MicrosoftTeams -Force
Install-Module Microsoft.Graph -Force
```

## Deployment Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│  INITIAL SETUP (Run Once - Phases 1-5)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: 01-Create-Sensitivity-Labels.ps1                      │
│     ↓     Creates labels in Microsoft Purview                   │
│                                                                 │
│  Phase 2: 02-Configure-Label-Policy-TeamsOnly.ps1               │
│     ↓     Publishes labels to Teams ONLY (not Outlook)          │
│                                                                 │
│  Phase 3: 03-Configure-Label-Meeting-Enforcement.ps1            │
│     ↓     Configures meeting enforcement settings               │
│     ↓     MANUAL STEP: Complete configuration in Purview portal │
│                                                                 │
│  Phase 4: 04-Create-ProtectedB-Meeting-Policy.ps1               │
│     ↓     Creates Teams meeting policy with secure defaults     │
│                                                                 │
│  Phase 5: 05-Assign-Policy-To-Group-Members.ps1                 │
│           Assigns policy to security group members              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  ONGOING MAINTENANCE                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  • Re-run Phase 5 when group membership changes                 │
│  • Run 06-Diagnose-Label-Policy-Status.ps1 to verify config     │
│  • Wait 24-48 hours for full policy propagation                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Files Reference

### Documentation

| File | Purpose |
|------|---------|
| `00-README.md` | This documentation |
| `00-Azure-CMK-Configuration-Guide.md` | Complete CMK implementation guide |

### Main Workflow (Run in Order)

| # | File | Purpose | Run When |
|---|------|---------|----------|
| 1 | `01-Create-Sensitivity-Labels.ps1` | Creates Protected B and Unclassified labels | Initial setup |
| 2 | `02-Configure-Label-Policy-TeamsOnly.ps1` | Publishes labels to Teams only | Initial setup |
| 3 | `03-Configure-Label-Meeting-Enforcement.ps1` | Configures meeting enforcement | Initial setup |
| 4 | `04-Create-ProtectedB-Meeting-Policy.ps1` | Creates secure Teams meeting policy | Initial setup |
| 5 | `05-Assign-Policy-To-Group-Members.ps1` | Assigns policy to group members | Initial + membership changes |

### Diagnostics & Utilities

| File | Purpose | Run When |
|------|---------|----------|
| `06-Diagnose-Label-Policy-Status.ps1` | Checks label policy configuration | Troubleshooting |
| `07-Apply-Meeting-Enforcement-Settings.ps1` | Applies enforcement settings via PowerShell | Advanced configuration |

### Optional & Design Scripts

| File | Purpose | Run When |
|------|---------|----------|
| `08-Optional-Conditional-Access-App-Protection.ps1` | Creates CA policy for mobile app protection | Optional enhancement |
| `09A-Design-HeaderFont-ProtectedB.ps1` | Configures header font for Protected B emails | Design customization |
| `09B-Design-HeaderFont-Unclassified.ps1` | Configures header font for Unclassified emails | Design customization |

### Emergency Scripts (`_Emergency/`)

| File | Purpose | Run When |
|------|---------|----------|
| `90-Emergency-Remove-Outlook-Labels.ps1` | Removes labels from Outlook if they appear | If Phase 2 fails |
| `91-Emergency-DELETE-Label-Policy.ps1` | Deletes the entire label policy | Last resort only |

## Quick Start

```powershell
# Connect to required services
Connect-ExchangeOnline
Connect-IPPSSession
Connect-MicrosoftTeams

# Run deployment phases in order
.\01-Create-Sensitivity-Labels.ps1
.\02-Configure-Label-Policy-TeamsOnly.ps1
.\03-Configure-Label-Meeting-Enforcement.ps1
.\04-Create-ProtectedB-Meeting-Policy.ps1
.\05-Assign-Policy-To-Group-Members.ps1

# Verify configuration
.\06-Diagnose-Label-Policy-Status.ps1
```

## Troubleshooting

### Labels Appearing in Outlook

If sensitivity labels appear in Outlook (they should only be in Teams):

1. Run `06-Diagnose-Label-Policy-Status.ps1` to check Exchange locations
2. If ExchangeLocation > 0, run `_Emergency\90-Emergency-Remove-Outlook-Labels.ps1`
3. Wait 24-48 hours for propagation

### Labels Not Appearing in Teams

1. Verify label policy is published: `Get-LabelPolicy | Where-Object {$_.Name -like "*Meeting*"}`
2. Check user is in the target group
3. Wait 24-48 hours for propagation
4. Have user sign out and back into Teams

### Policy Not Applied to Users

1. Verify group membership in Exchange Online
2. Re-run `05-Assign-Policy-To-Group-Members.ps1`
3. Check policy assignment: `Get-CsUserPolicyAssignment -Identity user@domain.com`

## Configuration Details

### Labels Created

| Label | Color | Purpose |
|-------|-------|---------|
| Protected B - Official Sensitive - NATO | Dark Red (#A80000) | Classified meetings |
| Unclassified | Green (#107C10) | Regular meetings |

### Meeting Policy Settings

The `Leonardo-Secure-Meeting-Group` policy enforces:

- Lobby bypass: Organizer only
- Who can present: Organizers only
- Recording: Disabled for attendees
- Watermarks: Enabled for video and screen share
- E2E Encryption: Required
- Copy chat: Disabled

## Support

For issues with this solution, contact the LCE M365 Security Team.