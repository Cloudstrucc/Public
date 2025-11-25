# Microsoft Teams Sensitivity Labels
## User Training Guide
### Leonardo Company - Centre of Excellence

---

**Document Information**

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Date** | November 2025 |
| **Author** | Fred Pearson, Power Platform Tenant Administrator |
| **Classification** | Internal Use Only |
| **Audience** | All Leonardo Company Employees |

---

## Table of Contents

1. [Introduction](#introduction)
2. [Why We Need This](#why-we-need-this)
3. [The Two Label Types](#the-two-label-types)
4. [How to Create a Secure Meeting](#how-to-create-a-secure-meeting)
5. [How to Create a Regular Meeting](#how-to-create-a-regular-meeting)
6. [Decision Guide: Which Label to Use](#decision-guide)
7. [What You'll See During Meetings](#what-youll-see)
8. [Meeting Options Explained](#meeting-options-explained)
9. [Common Scenarios](#common-scenarios)
10. [Troubleshooting](#troubleshooting)
11. [Frequently Asked Questions](#faq)
12. [Best Practices](#best-practices)

---

## 1. Introduction

### What Are Sensitivity Labels?

Sensitivity labels are security tags that you apply to Teams meetings to enforce appropriate protection controls based on the content you'll be discussing.

Think of them like security clearance levels for your meetings:
- **Protected B (Secure)** = Top Secret meeting room with guards and cameras
- **General (Regular)** = Open conference room

### What This Means for You

Starting **[DATE]**, every time you create a Teams meeting, you'll choose a label that determines:
- Who can join
- Who can present
- Whether watermarks appear
- Recording permissions
- Lobby settings

**Don't worry!** The default is set to the most secure option, so you're protected by default.

---

## 2. Why We Need This

### Our Security Requirements

Leonardo Company is a **defense contractor** that handles:

- 🔒 **Classified Government Contracts**
  - Discussions about defense projects
  - Technical specifications
  - Delivery schedules and milestones
  
- 🔒 **Proprietary Technology**
  - Our innovations and R&D
  - Engineering designs
  - Manufacturing processes
  
- 🔒 **Export-Controlled Information**
  - ITAR-restricted data
  - EAR-controlled technologies
  - Information subject to export licenses
  
- 🔒 **Customer Confidential Data**
  - Contract terms and pricing
  - Customer requirements
  - Project details

### The Threat Landscape

**Real risks we face:**

1. **Unauthorized Recording**
   - External parties recording classified discussions
   - Competitors capturing proprietary information
   - Foreign intelligence gathering

2. **Accidental Disclosure**
   - Wrong person joins the meeting
   - Screen share exposes sensitive documents
   - Recording stored in unsecured location

3. **Insider Threats**
   - Disgruntled employees
   - Social engineering attacks
   - Compromised accounts

4. **Compliance Violations**
   - DFARS 252.204-7012 requirements
   - NIST 800-171 controls
   - CMMC Level 2 certification
   - ITAR/EAR export controls

### What Could Go Wrong Without Controls

**Real-world example scenarios:**

❌ **Scenario 1:** Marketing team discussing new product in regular meeting. 
   Competitor joins via shared link. Records entire discussion. Product details 
   leaked before launch.

❌ **Scenario 2:** Engineering meeting about classified component. Someone shares 
   screen showing technical drawings. External consultant in meeting screenshots 
   the design.

❌ **Scenario 3:** HR meeting about confidential personnel matter. Meeting recorded 
   automatically. Recording stored in shared folder accessible by entire company.

✅ **With Sensitivity Labels:** All of these scenarios are prevented. Protected B 
   meetings block external users, apply watermarks, and restrict recording.

### Cloud Security: Shared Responsibility

**Microsoft's Responsibility:**
- Physical data center security
- Network infrastructure
- Platform availability
- Base encryption

**OUR Responsibility:**
- Access controls (who can join)
- Data classification (what's sensitive)
- Meeting security (how we protect discussions)
- Compliance monitoring (audit and enforce)

**Sensitivity labels are how we fulfill OUR responsibility.**

### Regulatory Compliance

We must comply with:

**DFARS 252.204-7012:**
- Safeguarding Covered Defense Information
- Controlled Unclassified Information (CUI)
- Requires documented security controls

**NIST 800-171:**
- 110 security requirements
- Access control (AC-3, AC-17)
- Audit and accountability (AU-2, AU-6)
- Media protection (MP-7)

**CMMC Level 2:**
- Cybersecurity Maturity Model Certification
- Required for DoD contracts
- Mandates implementation and documentation of controls

**These labels help us meet these requirements!**

---

## 3. The Two Label Types

### 🔴 Protected B - Secure Meeting

**When to use:**
- ANY classified or sensitive discussion
- Government contract details
- Technical specifications
- Proprietary information
- NDA-covered topics
- When in doubt!

**What it does:**

| Feature | Setting | Why |
|---------|---------|-----|
| **Watermarks** | ON (locked) 🔒 | Deters unauthorized recording, provides attribution |
| **Lobby** | Org only (locked) 🔒 | Prevents external parties from joining |
| **Anonymous Users** | Blocked (locked) 🔒 | No unidentified participants |
| **Phone Dial-in** | Must wait in lobby 🔒 | Control who joins via phone |
| **Who Can Present** | Organizer only (locked) 🔒 | Prevents unauthorized screen sharing |
| **Give Control** | Disabled (locked) 🔒 | No one can take control of your screen |
| **Recording** | Organizer controls 🔒 | You decide if/when to record |
| **Clipboard** | Blocked (locked) 🔒 | Can't copy content from meeting |
| **Encryption** | End-to-end enabled 🔒 | Maximum security |

**Visual indicators:**
- 🔒 Lock icons on meeting options
- Watermarks visible on all video
- "Managed by your organization" tooltips

---

### 🟢 General - Regular Meeting

**When to use:**
- Team stand-ups (non-sensitive)
- Social gatherings
- Training on non-classified topics
- Public presentations
- Routine administrative meetings

**What it does:**

| Feature | Setting | Why |
|---------|---------|-----|
| **Watermarks** | OFF | No watermarks for casual meetings |
| **Lobby** | You choose ✏️ | You control who can bypass |
| **Anonymous Users** | You choose ✏️ | Allow guests if needed |
| **Phone Dial-in** | You choose ✏️ | Flexible phone access |
| **Who Can Present** | You choose ✏️ | Anyone can share screen |
| **Give Control** | Enabled ✏️ | Can share control with others |
| **Recording** | You choose ✏️ | Standard Teams recording |
| **Clipboard** | Allowed ✏️ | Normal functionality |
| **Encryption** | Standard | Teams default encryption |

**Visual indicators:**
- ✏️ All options are editable
- No lock icons
- Standard Teams interface

---

## 4. How to Create a Secure Meeting

### Step-by-Step: Teams Desktop

**Step 1: Open Teams Calendar**
```
Click: Calendar icon on left sidebar
```

**Step 2: Create New Meeting**
```
Click: "New meeting" button (top right)
```

**Step 3: Notice the Default Label**
```
You'll see:
  Sensitivity: [Protected B - Secure Meeting ▼]
                ↑
                This is already selected by default!
```

**Step 4: Fill in Meeting Details**
```
Title: e.g., "Q4 Defense Contract Review"
Required: Add attendees
Optional: Add location, description
Date/Time: Set your schedule
```

**Step 5: Verify Protected B is Selected**
```
Check that "Protected B - Secure Meeting" is still selected
(It should be by default!)
```

**Step 6: Send the Invite**
```
Click: "Send" or "Save"
```

✅ **Done!** Your meeting is now secure.

### Step-by-Step: Teams Web

**Step 1: Go to Teams Web**
```
Browser: https://teams.microsoft.com
```

**Step 2: Open Calendar**
```
Click: Calendar (left sidebar)
```

**Step 3: New Meeting**
```
Click: "New meeting"
```

**Step 4: Check Sensitivity**
```
Look for: Sensitivity dropdown
Should show: "Protected B - Secure Meeting"
```

**Step 5: Complete Details and Send**
```
Fill in: Title, attendees, time
Click: "Send"
```

### Step-by-Step: Outlook Desktop

**Step 1: Open Outlook Calendar**
```
Click: Calendar view
```

**Step 2: Create Teams Meeting**
```
Home tab → "Teams Meeting" button
(or New Meeting → Teams Meeting toggle)
```

**Step 3: Check Sensitivity**
```
Look for: Sensitivity button/dropdown
Select: "Protected B - Secure Meeting"
```

**Step 4: Send Invite**
```
Fill in details → Send
```

---

## 5. How to Create a Regular Meeting

### When You Need to Change from Default

By default, "Protected B - Secure Meeting" is selected. Here's how to change it for casual meetings:

### Step-by-Step

**Step 1: Create Meeting as Normal**
```
Calendar → New meeting
```

**Step 2: Click Sensitivity Dropdown**
```
Click on: "Protected B - Secure Meeting ▼"
         (the dropdown arrow)
```

**Step 3: Select General**
```
Click: "General - Regular Meeting"
```

**Step 4: Verify Change**
```
Sensitivity now shows: "General - Regular Meeting"
```

**Step 5: Send Invite**
```
Complete details → Send
```

### Visual Guide

**Before (Default):**
```
┌─────────────────────────────────────────┐
│ Title: [Team Standup            ]     │
│                                         │
│ Sensitivity: [Protected B - Secure ▼] │ ← Click here
└─────────────────────────────────────────┘
```

**After Clicking:**
```
┌─────────────────────────────────────────┐
│ Sensitivity:                            │
│   • Protected B - Secure Meeting        │
│   • General - Regular Meeting     ◄──── Click this
└─────────────────────────────────────────┘
```

**Result:**
```
┌─────────────────────────────────────────┐
│ Title: [Team Standup            ]     │
│                                         │
│ Sensitivity: [General - Regular    ▼] │ ← Changed!
└─────────────────────────────────────────┘
```

---

## 6. Decision Guide: Which Label to Use?

### Quick Decision Tree

```
Creating a meeting →
  ↓
Will you discuss ANY of these?
  • Classified information
  • Contract details/pricing
  • Technical specifications
  • Customer confidential data
  • Proprietary designs
  • NDA-covered topics
  • Government requirements
  ↓
┌─ YES → Protected B - Secure Meeting 🔴
│
└─ NO → Ask: Is it purely social/administrative?
         ↓
      ┌─ YES → General - Regular Meeting 🟢
      │
      └─ UNSURE → Protected B - Secure Meeting 🔴
                  (When in doubt, be secure!)
```

### Detailed Examples

#### ✅ USE PROTECTED B FOR:

**Government/Contract Work:**
- ✅ Discussing contract deliverables
- ✅ Reviewing government requirements
- ✅ Technical reviews with DoD customers
- ✅ Proposal development meetings
- ✅ Contract negotiations

**Technical Content:**
- ✅ Engineering design reviews
- ✅ R&D discussions
- ✅ Manufacturing process reviews
- ✅ Quality control discussions involving proprietary methods
- ✅ Technical problem-solving for classified projects

**Business Sensitive:**
- ✅ Financial planning and budgets
- ✅ Strategic planning sessions
- ✅ Merger/acquisition discussions
- ✅ Pricing strategies
- ✅ Customer relationship details

**Personnel Matters:**
- ✅ Disciplinary discussions
- ✅ Salary/compensation reviews
- ✅ Performance improvement plans
- ✅ Reorganization planning
- ✅ Any HR matter involving personal information

**Legal/Compliance:**
- ✅ Discussions with legal counsel
- ✅ Regulatory compliance reviews
- ✅ Incident investigations
- ✅ Audit preparations involving sensitive findings

#### ✅ USE GENERAL FOR:

**Administrative:**
- ✅ Team stand-ups (no sensitive content)
- ✅ Status updates on non-classified work
- ✅ Scheduling and logistics
- ✅ Routine administrative tasks
- ✅ Committee meetings (non-sensitive agenda)

**Social/Team Building:**
- ✅ Birthday celebrations
- ✅ Virtual coffee breaks
- ✅ Team lunch gatherings
- ✅ Social hours
- ✅ Game sessions

**Training:**
- ✅ General IT training
- ✅ Professional development (non-classified)
- ✅ Software tutorials
- ✅ Onboarding for general company info
- ✅ Safety training (non-sensitive)

**Public Content:**
- ✅ Webinars open to public
- ✅ Marketing presentations
- ✅ Town halls with general announcements
- ✅ Recruiting/career fair sessions

---

## 7. What You'll See During Meetings

### In a Protected B (Secure) Meeting

#### Before the Meeting Starts

**Meeting Options Screen:**
```
┌────────────────────────────────────────────┐
│ Meeting options                            │
├────────────────────────────────────────────┤
│                                            │
│ 🔒 Who can bypass the lobby?             │
│    People in my organization              │
│    (Managed by your organization)         │
│                                            │
│ 🔒 Who can present?                       │
│    Only me                                │
│    (Managed by your organization)         │
│                                            │
│ 🔒 Allow mic for attendees?              │
│    Yes                                     │
│                                            │
│ 🔒 Allow camera for attendees?           │
│    Yes                                     │
│                                            │
└────────────────────────────────────────────┘

Notice: 🔒 Lock icons = Cannot change these settings
```

#### During the Meeting

**What You'll See:**

1. **Watermarks on Video**
   ```
   Every participant's video shows:
   
   ┌──────────────────────────────┐
   │                              │
   │     [Video Feed]             │
   │                              │
   │  Fred Pearson               │
   │  2025-11-18 14:23           │ ← Watermark
   └──────────────────────────────┘
   ```

2. **Watermarks on Screen Share**
   ```
   When anyone shares screen:
   
   ┌──────────────────────────────────────┐
   │ [Shared Content]                     │
   │                                      │
   │ Fred Pearson - 2025-11-18 14:23    │ ← Watermark
   │                                      │  (repeated across screen)
   └──────────────────────────────────────┘
   ```

3. **Lobby Restrictions**
   ```
   If external user tries to join:
   
   ┌────────────────────────────────────┐
   │ Someone is trying to join          │
   │                                    │
   │ external.user@othercompany.com     │
   │                                    │
   │ [Admit]  [Deny Entry]             │
   └────────────────────────────────────┘
   
   Note: You'll see this, but they can't actually join
         (blocked by policy)
   ```

4. **Presenter Controls**
   ```
   Only organizer sees:
   
   [...] (More options) →
     Make presenter
     Make co-organizer
     Remove
   
   Participants don't see these options
   ```

### In a General (Regular) Meeting

#### Before the Meeting

**Meeting Options Screen:**
```
┌────────────────────────────────────────────┐
│ Meeting options                            │
├────────────────────────────────────────────┤
│                                            │
│ ✏️ Who can bypass the lobby?             │
│    [Everyone                        ▼]    │ ← You can change
│                                            │
│ ✏️ Who can present?                       │
│    [Everyone                        ▼]    │ ← You can change
│                                            │
│ ✏️ Allow mic for attendees?              │
│    [Yes ▼]                                │ ← You can change
│                                            │
└────────────────────────────────────────────┘

Notice: ✏️ No locks = You control all settings
```

#### During the Meeting

**What You'll See:**

1. **No Watermarks**
   - Clean video feeds
   - Clean screen shares
   - Standard Teams interface

2. **Flexible Lobby**
   - External users can join (if you allowed it)
   - Phone users can bypass lobby (if configured)
   - You control admittance

3. **Flexible Presenting**
   - Anyone can share screen (if configured)
   - Participants can request control
   - You decide permissions

---

## 8. Meeting Options Explained

### Accessing Meeting Options

**Before Meeting:**
```
Method 1:
  Teams Calendar → Click meeting → "Meeting options"

Method 2:
  Meeting invite → "Meeting options" link

Method 3:
  Email invite → "Meeting options" link at bottom
```

**During Meeting:**
```
[...] (More options) → "Meeting options"
Opens in browser
```

### Key Settings Comparison

| Setting | Protected B 🔴 | General 🟢 |
|---------|---------------|-----------|
| **Watermarks** | Always ON 🔒 | Always OFF |
| **Lobby: Org members** | Bypass 🔒 | You choose ✏️ |
| **Lobby: External** | Must wait 🔒 | You choose ✏️ |
| **Lobby: Phone users** | Must wait 🔒 | You choose ✏️ |
| **Who presents** | Organizer only 🔒 | You choose ✏️ |
| **Attendee mic** | ON | You choose ✏️ |
| **Attendee camera** | ON | You choose ✏️ |
| **Chat** | Enabled | You choose ✏️ |
| **Reactions** | Enabled | You choose ✏️ |
| **Recording** | Organizer controls 🔒 | You choose ✏️ |
| **Transcription** | Available | Available |

🔒 = Locked (you cannot change)  
✏️ = Flexible (you can customize)

---

## 9. Common Scenarios

### Scenario 1: Weekly Team Standup

**Meeting:** Team standup - discussing task status (no sensitive info)

**Choose:** 🟢 General - Regular Meeting

**Steps:**
1. Create meeting
2. Change label to "General - Regular Meeting"
3. No special setup needed
4. Send invite

**During meeting:**
- No watermarks
- Everyone can share updates
- Normal Teams functionality

---

### Scenario 2: Quarterly Defense Contract Review

**Meeting:** Review Q4 deliverables for classified DoD contract

**Choose:** 🔴 Protected B - Secure Meeting

**Steps:**
1. Create meeting
2. Keep default "Protected B - Secure Meeting"
3. Add only cleared personnel as attendees
4. Send invite

**During meeting:**
- Watermarks on all video/screens
- Only org members can join
- You control presenting
- Recording controlled

---

### Scenario 3: Customer Demo (Non-Sensitive)

**Meeting:** Product demo for potential customer (general marketing material)

**Choose:** 🟢 General - Regular Meeting

**Steps:**
1. Create meeting
2. Change to "General - Regular Meeting"
3. Add customer email addresses
4. Configure lobby: Allow guests
5. Send invite

**During meeting:**
- Customer can join easily
- You can share marketing materials
- Customer can ask questions via mic/camera
- Standard experience

---

### Scenario 4: Engineering Design Review (Proprietary)

**Meeting:** Review new product design (company confidential)

**Choose:** 🔴 Protected B - Secure Meeting

**Steps:**
1. Create meeting
2. Keep "Protected B - Secure Meeting"
3. Add only internal engineering team
4. Send invite

**During meeting:**
- Watermarks protect IP
- No external join possible
- Screen shares of designs are protected
- Controlled environment

---

### Scenario 5: HR Discussion (Confidential)

**Meeting:** Performance review or disciplinary matter

**Choose:** 🔴 Protected B - Secure Meeting

**Steps:**
1. Create meeting
2. Keep "Protected B - Secure Meeting"
3. Add only HR and relevant manager
4. Send invite

**During meeting:**
- Privacy ensured
- No unauthorized recording
- Confidential discussion protected
- Audit trail maintained

---

### Scenario 6: Virtual Coffee Break

**Meeting:** Social gathering, casual chat

**Choose:** 🟢 General - Regular Meeting

**Steps:**
1. Create meeting
2. Change to "General - Regular Meeting"
3. Add team members
4. Optional: Make it recurring
5. Send invite

**During meeting:**
- Relaxed atmosphere
- No watermarks
- Social interaction
- No security restrictions

---

## 10. Troubleshooting

### Problem: Can't See Sensitivity Dropdown

**Symptoms:**
- No "Sensitivity" option when creating meeting
- Option is grayed out
- Option missing entirely

**Solutions:**

**Solution 1: Wait for Propagation**
```
Timeline: Labels take 24-48 hours to appear after rollout
Action: Check again tomorrow
```

**Solution 2: Sign Out and Back In**
```
1. Click your profile picture
2. Sign out
3. Close Teams completely
4. Reopen Teams
5. Sign in
6. Try again
```

**Solution 3: Clear Teams Cache**
```
1. Close Teams
2. Press Win+R
3. Type: %appdata%\Microsoft\Teams
4. Delete: Cache, blob_storage, databases folders
5. Restart Teams
```

**Solution 4: Try Different Client**
```
Desktop not working? → Try web (teams.microsoft.com)
Web not working? → Try desktop app
```

**Solution 5: Check with IT**
```
Still not working after 48 hours?
Contact: itsupport@leonardocompany.ca
Provide: Your email, when you last tried, screenshot
```

---

### Problem: Label is Locked/Can't Change

**Symptoms:**
- Created meeting with wrong label
- Can't change label in meeting options
- Want to switch from Protected B to General

**Solutions:**

**Before Meeting Starts:**
```
1. Open meeting in calendar
2. Click "Meeting options"
3. Look for Sensitivity dropdown
4. Change label
5. Save changes
6. Update attendees if needed
```

**After Meeting Starts:**
```
Cannot change! Security controls are enforced.

Workaround:
1. End current meeting
2. Create new meeting with correct label
3. Start new meeting
4. Invite participants
```

**Lesson:** Double-check label before sending invite!

---

### Problem: External Person Can't Join Protected B Meeting

**Symptoms:**
- External partner trying to join
- Stuck in lobby
- Cannot admit them

**Solutions:**

**This is BY DESIGN** - Protected B blocks external users.

**Options:**

**Option 1: Use General Meeting (If Content Appropriate)**
```
If meeting content is NOT sensitive:
1. Cancel Protected B meeting
2. Create new General meeting
3. External partners can join
```

**Option 2: Use Alternative Communication**
```
If content IS sensitive:
- Use secure phone line
- Schedule in-person meeting
- Use approved secure collaboration tool
- Don't compromise security!
```

**Option 3: Make Them Internal First**
```
For regular partners:
- Request guest account creation
- IT sets them up as guests
- They become "internal"
- Can join future Protected B meetings
```

---

### Problem: Can't Share Screen in Protected B Meeting

**Symptoms:**
- Share screen option grayed out
- Not the meeting organizer
- Need to present

**Solutions:**

**Solution 1: Ask Organizer for Co-Organizer Role**
```
During meeting:
1. Ask organizer in chat
2. Organizer: [...] → People → Your name → Make co-organizer
3. You can now share screen
```

**Solution 2: Organizer Shares on Your Behalf**
```
1. Share your content with organizer (chat/email)
2. Organizer shares their screen
3. Organizer shows your content
```

**Solution 3: Plan Ahead**
```
Before meeting:
- Tell organizer you need to present
- They make you co-organizer in advance
- Problem prevented!
```

---

### Problem: Watermarks Are Annoying

**Symptoms:**
- Watermarks covering important content
- Difficult to see slides
- Want to disable watermarks

**Solutions:**

**This is BY DESIGN** - Watermarks cannot be disabled in Protected B meetings.

**Understanding:**
```
Purpose: Deter unauthorized recording/screenshots
Requirement: Compliance mandate (DFARS, NIST)
Result: Cannot be removed
```

**Workarounds:**

**Tip 1: Design Around Watermarks**
```
When creating slides:
- Avoid critical info in corners
- Use center of screen for key points
- Test in meeting first
```

**Tip 2: Use General Meeting**
```
If content is NOT sensitive:
- Use General meeting instead
- No watermarks
- Better for presentations
```

**Tip 3: Accept Them**
```
Watermarks are:
- Small and semi-transparent
- Positioned to minimize obstruction
- Required for compliance
- Protecting our company
```

---

## 11. Frequently Asked Questions

### General Questions

**Q: Do I have to use labels?**
A: After the training period ([DATE]), yes. Label usage is mandatory for all meetings 
   containing sensitive information. It's a compliance requirement, not optional.

**Q: What if I forget to use a label?**
A: Good news! Protected B is the default. You have to actively change it to use 
   General. This means you're secure by default.

**Q: Can I change the label after creating the meeting?**
A: Yes, before the meeting starts. Once the meeting begins, settings are locked.

**Q: Will this work on my phone?**
A: Yes! Labels work in Teams mobile apps (iOS and Android). The interface looks 
   slightly different but functionality is the same.

**Q: What about existing meetings?**
A: Meetings created before [DATE] will continue to work as they currently do. 
   Labels only apply to newly created meetings.

---

### Label Selection Questions

**Q: When in doubt, which label should I use?**
A: Always use Protected B - Secure Meeting when in doubt. It's better to be 
   overly cautious with sensitive information.

**Q: Can I use General for meetings with government representatives?**
A: NO. ANY meeting with government representatives must use Protected B, even for 
   seemingly routine discussions.

**Q: What if the meeting starts casual but becomes sensitive?**
A: You cannot change labels mid-meeting. Best practice: End the meeting and restart 
   with a Protected B meeting if sensitive topics arise.

**Q: Are there penalties for using the wrong label?**
A: Using General for sensitive discussions may trigger security reviews and could 
   result in:
   - Additional security training
   - Access restrictions
   - Disciplinary action (if intentional or repeated)
   - Impact on security clearance

---

### Technical Questions

**Q: Do watermarks affect video quality?**
A: No. Watermarks are lightweight overlays and don't reduce video quality or 
   increase bandwidth usage.

**Q: Can someone remove the watermarks?**
A: No. Watermarks are embedded in the video feed at the source and cannot be 
   removed by participants.

**Q: What if I have poor internet - do watermarks use more bandwidth?**
A: No. Watermarks add negligible data overhead (less than 1%). Your internet speed 
   is the same with or without watermarks.

**Q: Can I record a Protected B meeting?**
A: As the organizer, yes. Recording permissions are controlled. As a participant, 
   only if the organizer allows it. Note: All recordings are audited.

**Q: Where are recordings stored?**
A: Teams recordings are stored in Microsoft Stream (OneDrive/SharePoint) with the 
   same sensitivity label applied, inheriting the protection.

---

### External Collaboration Questions

**Q: How do I meet with external partners on sensitive projects?**
A: Options:
   1. Request guest account for regular partners
   2. Use approved secure collaboration platforms
   3. Meet in person
   4. Use secure phone lines
   Do NOT downgrade to General meeting just to accommodate external access!

**Q: Can I invite contractors to Protected B meetings?**
A: Only if they have:
   - Signed NDAs
   - Been granted guest accounts by IT
   - Appropriate clearances (for classified info)
   Check with IT before inviting contractors.

**Q: What about customers who need to join?**
A: For customer meetings:
   - Sales/marketing discussions: General meeting ✓
   - Technical/contract discussions: Protected B + guest account required
   - Classified discussions: In-person or secure channels only

---

### Compliance Questions

**Q: Are my meetings monitored?**
A: Label usage is logged for compliance auditing. Meeting content is not monitored, 
   but we track:
   - Which label was used
   - Meeting duration
   - Participants
   - Recording events
   This is required for DFARS/CMMC compliance.

**Q: What happens if I misuse labels?**
A: First offense: Re-training
   Repeated issues: Manager notification
   Serious violations: Security review, possible clearance impact
   Intentional misuse: Disciplinary action

**Q: How does this help with compliance?**
A: These labels provide:
   - Documented access controls (NIST 800-171 AC-3)
   - Audit trails (NIST 800-171 AU-2)
   - Media protection (NIST 800-171 MP-7)
   - Meeting attribution via watermarks
   - Evidence of security controls for CMMC assessments

---

### Workflow Questions

**Q: Can I create a template meeting with a label?**
A: Not directly, but:
   1. Create a meeting with desired label
   2. Make it recurring
   3. Use that as your template
   4. Copy/modify for similar meetings

**Q: What about all-hands meetings?**
A: For company-wide meetings:
   - General announcements: General meeting
   - Business results (sensitive): Protected B meeting
   - Mixed content: Use Protected B (secure by default)

**Q: I schedule meetings for my boss. What label do I use?**
A: Ask your boss about meeting content:
   - Classified/sensitive: Protected B
   - Casual/administrative: General
   When in doubt, use Protected B and let them change if needed.

---

## 12. Best Practices

### ✅ DO

**Planning:**
- ✅ Think about meeting content BEFORE creating the invite
- ✅ Ask yourself: "Will we discuss anything sensitive?"
- ✅ Review participant list - anyone external?
- ✅ Set up recurring meetings with appropriate labels
- ✅ Test protected B meeting features before important calls

**During Meetings:**
- ✅ Remind participants about watermarks at meeting start
- ✅ Control screen shares in Protected B meetings
- ✅ Be mindful of what's visible on screen shares
- ✅ Use "background blur" for sensitive locations
- ✅ Mute when not speaking (good practice always)

**After Meetings:**
- ✅ Store meeting recordings securely
- ✅ Share recordings only with authorized personnel
- ✅ Delete unnecessary recordings after retention period
- ✅ Report any security concerns immediately

**General:**
- ✅ Keep Teams client updated
- ✅ Use company-issued devices for sensitive meetings
- ✅ Lock your screen when away from desk
- ✅ Use headphones for confidential meetings
- ✅ Attend training sessions to stay current

---

### ❌ DON'T

**Label Selection:**
- ❌ Don't use General just because it's "easier"
- ❌ Don't downgrade to General to bypass restrictions
- ❌ Don't assume "quick call" means "not sensitive"
- ❌ Don't forget that contract discussions = Protected B
- ❌ Don't think watermarks are optional

**Security:**
- ❌ Don't share meeting links publicly
- ❌ Don't join Protected B meetings from public WiFi
- ❌ Don't photograph/screenshot watermarked content
- ❌ Don't record Protected B meetings without authorization
- ❌ Don't discuss classified info in General meetings (!)

**External Collaboration:**
- ❌ Don't create General meetings just so external can join
- ❌ Don't share sensitive information in General meetings
- ❌ Don't assume external partners understand our security
- ❌ Don't bypass security controls for convenience

**Common Mistakes:**
- ❌ Don't create meeting then forget to check label
- ❌ Don't assume someone else will fix label issues
- ❌ Don't ignore security warnings or blocked actions
- ❌ Don't work around security controls
- ❌ Don't delay reporting security incidents

---

### 🎯 Quick Tips for Success

**Tip 1: Create a Mental Checklist**
```
Before every meeting ask:
□ Will we discuss contracts?
□ Will we discuss technical details?
□ Will we mention customer names?
□ Will we show proprietary information?
□ Is anyone external attending?

Any "Yes" → Protected B - Secure Meeting
All "No" → Can use General
```

**Tip 2: Use Descriptive Meeting Titles**
```
Good titles that help you remember label:
✓ "Q4 Contract Review (Protected B)"
✓ "Team Coffee Break (General)"
✓ "Engineering Design Review - CLASSIFIED"
✓ "Training: New Timesheet System (General)"
```

**Tip 3: Set Calendar Reminders**
```
Recurring reminders:
- Weekly: Review my upcoming meetings for correct labels
- Monthly: Check security compliance in my calendar
- Quarterly: Attend refresher training
```

**Tip 4: Keep Reference Materials Handy**
```
Print and keep at desk:
- Quick reference card
- Decision tree
- IT support contact info
```

**Tip 5: Practice During Training Period**
```
Create test meetings with both labels
Experience the differences firsthand
Learn the interface before you need it
Build muscle memory
```

---

## Summary Card

### 📋 Quick Reference

**Two Labels:**
- 🔴 Protected B - Secure Meeting → Classified/sensitive content
- 🟢 General - Regular Meeting → Casual/administrative content

**When in Doubt:**
→ Use Protected B - Secure Meeting

**Key Differences:**
- Protected B: Watermarks ON, External blocked, Settings locked 🔒
- General: No watermarks, External allowed, Settings flexible ✏️

**Getting Help:**
- IT Support: itsupport@leonardocompany.ca
- Training: [TRAINING LINK]
- This Guide: [SHAREPOINT LINK]

---

## Training Completion

Congratulations! You've completed the Teams Sensitivity Labels training guide.

**Next Steps:**
□ Practice creating both types of meetings
□ Save this guide for future reference
□ Bookmark the FAQ section
□ Print the quick reference card
□ Attend a live training session
□ Complete the acknowledgment form

**Questions?**
Contact: fred.pearson@leonardocompany.ca

---

**Document Control**

Version: 1.0
Date: November 2025
Classification: Internal Use Only
Next Review: February 2026

© Leonardo Company - Centre of Excellence
