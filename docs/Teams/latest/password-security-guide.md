# Meeting Passcode Security Guide
## Leonardo Company - LCE M365 Security Group

---

**Document Control**

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Last Updated** | November 2025 |
| **Owner** | George Zarif |
| **Classification** | Internal Use Only |

---

## Table of Contents

1. [Overview](#overview)
2. [When to Use Passcodes](#when-to-use-passcodes)
3. [Setting Meeting Passcodes](#setting-meeting-passcodes)
4. [Passcode Best Practices](#passcode-best-practices)
5. [External User Instructions](#external-user-instructions)
6. [Troubleshooting](#troubleshooting)

---

## Overview

### What is a Meeting Passcode?

A meeting passcode is a security code that participants must enter to join a Teams meeting. It provides an additional layer of authentication beyond the meeting link.

### Why Use Passcodes?

```
SECURITY BENEFITS:
✅ Prevents unauthorized access (even if link is leaked)
✅ No Microsoft account required for external users
✅ Simple for participants to use
✅ Trackable via audit logs
✅ Can be changed per meeting
```

### Passcode vs Microsoft Authentication

| Feature | Passcode | Microsoft Auth |
|---------|----------|----------------|
| External users need account | ❌ No | ✅ Yes |
| Easy to share | ✅ Yes | ❌ No |
| Can be changed | ✅ Yes | ❌ No |
| Audit trail | ✅ Yes | ✅ Yes |
| Best for | External guests | Internal + authenticated external |

---

## When to Use Passcodes

### ✅ ALWAYS Use Passcode For:

```
□ Meetings with external participants
□ Meetings with sensitive/classified content
□ Client meetings under NDA
□ Financial discussions
□ Legal matters
□ Personnel/HR discussions
□ Executive briefings
□ Any meeting labeled "SECURE"
```

### ⚪ Optional Passcode For:

```
□ Internal-only team meetings (org users bypass lobby anyway)
□ Public webinars (if you want to track attendance)
□ Training sessions
□ All-hands meetings
```

### ❌ Don't Need Passcode For:

```
□ Internal 1-on-1s
□ Casual team syncs (internal only)
□ Open office hours
□ Public events you want anyone to join
```

---

## Setting Meeting Passcodes

### Method 1: When Creating Meeting (Recommended)

**Step-by-Step:**

```
1. Open Teams Calendar
2. Click "New meeting"
3. Fill in meeting details:
   ├─ Title: "[SECURE] Client Review" 
   ├─ Date/Time
   ├─ Attendees (include external)
   └─ Description
4. Click "Meeting options" button
5. Scroll to "Security" section
6. Toggle ON: "Require a passcode to join"
7. Passcode auto-generates (e.g., "AB3X7K")
8. (Optional) Click "Change passcode" to customize
9. Click "Save"
10. Send meeting invite
```

**Visual Guide:**

```
┌─────────────────────────────────────────────┐
│ Meeting options                             │
├─────────────────────────────────────────────┤
│                                             │
│ Security                                    │
│ ┌─────────────────────────────────────────┐ │
│ │ [✓] Require a passcode to join          │ │
│ │                                         │ │
│ │ Passcode: AB3X7K                        │ │
│ │ [Change passcode]                       │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ [Save]                                      │
└─────────────────────────────────────────────┘
```

### Method 2: After Meeting Created

```
1. Open the meeting in Teams Calendar
2. Click "Edit"
3. Click "Meeting options"
4. Toggle ON: "Require a passcode to join"
5. Set/customize passcode
6. Click "Save"
7. Passcode automatically added to existing invite
```

---

## Passcode Best Practices

### ✅ Strong Passcode Guidelines

```
LENGTH:
Minimum: 6 characters
Recommended: 8-10 characters
Maximum: 16 characters

COMPLEXITY:
✅ Mix uppercase and lowercase
✅ Include numbers
✅ Include special characters (!@#$%^&*)
✅ Avoid dictionary words
✅ Avoid sequential patterns (123456, ABCDEF)

EXAMPLES:
❌ Bad:  "123456"
❌ Bad:  "meeting"
❌ Bad:  "password"
⚠️  OK:   "Meet2024"
✅ Good: "Sec@re84"
✅ Good: "Kp4#mNx9"
✅ Best: "Z9$mK!p3Qr"
```

### 🔐 Passcode Distribution Strategy

**For Maximum Security:**

```
Step 1: Send meeting invite (contains passcode)
Step 2: Call external attendee to VERIFY passcode
Step 3: During call, ask a security question
Step 4: Confirm they have correct passcode

Example:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You: "Hi John, confirming our meeting tomorrow 
      at 2pm. For security, can you confirm the 
      passcode you received?"

John: "Yes, it's AB3X7K"

You: "Perfect. Also, what project is this regarding?"

John: "The Q4 budget review for Project Atlas"

You: "Great, see you tomorrow."
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Alternative: Separate Channel Distribution**

```
Channel 1 (Email): Meeting invite with link
Channel 2 (SMS):   Passcode only
Channel 3 (Phone): Verbal confirmation

This ensures even if email is compromised, 
attacker doesn't have passcode.
```

### 🔄 When to Change Passcode

```
CHANGE PASSCODE IF:
□ Attendee list changes (someone removed)
□ Meeting rescheduled
□ Concern about link being shared
□ After a similar meeting ends (reusing link)
□ Every 30 days for recurring meetings

DON'T REUSE:
□ Same passcode across multiple meetings
□ Predictable patterns (Meeting1, Meeting2, etc.)
□ Company-wide known codes
```

---

## External User Instructions

### Email Template to Send External Participants

```
Subject: Meeting Tomorrow - Passcode Required

Hi [Name],

You're invited to our secure Teams meeting tomorrow.

MEETING DETAILS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date:     [Date]
Time:     [Time] [Timezone]
Topic:    [Topic]
Duration: [Duration]

HOW TO JOIN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Click the meeting link (sent in separate calendar invite)
2. When prompted, enter passcode: [PASSCODE]
3. Enter your name when asked
4. Wait in lobby - I'll admit you when the meeting starts

IMPORTANT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  You do NOT need a Microsoft account
✓  Just the passcode and the meeting link
✓  Please join 5 minutes early to test your connection
✓  Keep this passcode confidential

TROUBLESHOOTING:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
If you have issues joining, call/text: [Your Phone]

See you tomorrow!

[Your Name]
[Your Title]
Leonardo Company
```

### Quick Reference Card for External Users

```
╔══════════════════════════════════════════════════════════════════╗
║  JOINING A LEONARDO COMPANY SECURE MEETING                      ║
╚══════════════════════════════════════════════════════════════════╝

STEP 1: Click Meeting Link
   └─ From email invite or calendar

STEP 2: Enter Passcode
   ┌────────────────────────────────┐
   │ Enter meeting passcode:        │
   │ [_________]                    │
   │                                │
   │ [Join]                         │
   └────────────────────────────────┘
   
STEP 3: Enter Your Name
   ┌────────────────────────────────┐
   │ Enter your name:               │
   │ [_________]                    │
   │                                │
   │ [Join meeting]                 │
   └────────────────────────────────┘

STEP 4: Wait in Lobby
   "You're in the lobby. 
    The meeting organizer will let you in soon."
   
STEP 5: Join Meeting
   Organizer admits you → Meeting starts

═══════════════════════════════════════════════════════════════════

COMMON QUESTIONS:

Q: Do I need a Microsoft account?
A: NO - just the passcode

Q: What if I enter wrong passcode?
A: You'll see "Incorrect passcode" - try again

Q: How long do I wait in lobby?
A: Usually 1-2 minutes. Call organizer if >5 minutes.

Q: Can I join from phone?
A: YES - download Teams app or use dial-in number

═══════════════════════════════════════════════════════════════════
```

---

## Troubleshooting

### Common Issues & Solutions

#### Issue 1: "Incorrect passcode" Error

**Cause:** Passcode entered incorrectly

**Solution:**
```
✓ Check for typos
✓ Passcodes are case-sensitive
✓ No spaces before/after passcode
✓ Copy-paste from invite (don't type)
✓ Ask organizer to verify passcode
```

#### Issue 2: Passcode Not Appearing in Invite

**Cause:** Meeting options not saved properly

**Solution:**
```
1. Open meeting in Teams Calendar
2. Click "Meeting options"
3. Verify "Require passcode" is ON
4. Click "Save"
5. Resend meeting invite
```

#### Issue 3: External User Can't Find Where to Enter Passcode

**Cause:** Using wrong join method

**Solution:**
```
✓ Use the Teams meeting link (not dial-in)
✓ Click "Join on the web instead" if Teams app not installed
✓ Passcode prompt appears BEFORE entering name
✓ Don't skip the passcode screen
```

#### Issue 4: Passcode Works But Stuck in Lobby

**Cause:** Normal behavior - organizer must admit

**Solution:**
```
✓ This is expected - passcode gets you TO lobby
✓ Organizer must still admit from lobby
✓ Wait patiently (usually 1-2 minutes)
✓ If >5 minutes, contact organizer
```

#### Issue 5: Want to Change Passcode After Sending Invites

**Solution:**
```
1. Edit meeting in Teams Calendar
2. Meeting options → Change passcode
3. Save
4. Send UPDATE to attendees:
   "Note: Meeting passcode has changed to: [NEW]"
```

---

## Appendix A: Passcode Generator Script

Use this PowerShell script to generate secure passcodes:

```powershell
function New-SecureMeetingPasscode {
    param(
        [int]$Length = 8,
        [switch]$ExcludeSpecialChars
    )
    
    if ($ExcludeSpecialChars) {
        $chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789"
    } else {
        $chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%^&*"
    }
    
    $passcode = -join ((1..$Length) | ForEach-Object { 
        $chars[(Get-Random -Maximum $chars.Length)] 
    })
    
    return $passcode
}

# Generate 5 passcodes
Write-Host "`nGenerated Secure Passcodes:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
1..5 | ForEach-Object {
    $code = New-SecureMeetingPasscode
    Write-Host "Passcode $_: $code" -ForegroundColor Green
}
Write-Host ""

# Generate passcode without special characters (easier to read over phone)
Write-Host "Simple Passcodes (no special chars):" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
1..5 | ForEach-Object {
    $code = New-SecureMeetingPasscode -ExcludeSpecialChars
    Write-Host "Passcode $_: $code" -ForegroundColor Yellow
}
```

---

## Appendix B: Compliance Checklist

```
SECURE MEETING CHECKLIST (Organizer)
═══════════════════════════════════════════════════════════════════

BEFORE MEETING:
☐ Passcode enabled on meeting
☐ Passcode is strong (8+ chars, mixed case, numbers)
☐ External attendees notified of passcode via email
☐ Passcode verified via phone call (high-security meetings)
☐ Meeting title includes "[SECURE]" prefix
☐ Calendar reminder set for 15 minutes before

AT MEETING START:
☐ Join 5 minutes early
☐ Verify lobby settings are active
☐ Check watermarks are visible (camera + screen)
☐ Admit participants one-by-one after verification
☐ Verify each participant's identity before admitting
☐ Start recording (if required for compliance)

DURING MEETING:
☐ Monitor participant list for unexpected joiners
☐ Lock meeting once all participants joined
☐ Watch for lobby notifications
☐ End screen sharing when done presenting

AFTER MEETING:
☐ End meeting for all participants
☐ Save/distribute recording (if applicable)
☐ Document any security incidents
☐ Consider changing passcode (if link was widely shared)

═══════════════════════════════════════════════════════════════════
```

---

## Appendix C: Quick Reference

### Passcode Quick Facts

| Question | Answer |
|----------|--------|
| Where is passcode shown? | In meeting invite automatically |
| Can I customize passcode? | Yes, via Meeting Options |
| How long is default passcode? | 6 characters (letters + numbers) |
| Is passcode case-sensitive? | Yes |
| Can external users join without MS account? | Yes, just need passcode |
| Does passcode expire? | No, valid until meeting ends |
| Can I reuse passcode? | Not recommended for security |
| Where do users enter passcode? | Before joining meeting (automatic prompt) |

---

**END OF GUIDE**

For questions or assistance:
- Email: george.zarif@leonardocompany.ca
- Phone: [PHONE]

*Version 1.0 | November 2025 | Leonardo Company*