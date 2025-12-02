# Protected B Meeting Policy - Enhanced Security Settings
## Leonardo Company - LCE M365 Security Group

---

## Overview

The **Leonardo-Secure-Meeting-Group** policy now includes enhanced security features for Protected B meetings:

✅ **Watermarks** (camera + screen)  
✅ **Screen capture prevention**  
✅ **Sensitive content detection**  
✅ **Restricted recording/transcript access**  
✅ **Lobby controls (organizer admittance only)**  

---

## Enhanced Security Features

### 1. Watermarks ✅

**Setting:** `AllowWatermarkForCameraVideo = True` and `AllowWatermarkForScreenSharing = True`

**What it does:**
- User's email address appears as watermark on their camera video
- User's email address appears as watermark on their shared screen
- Cannot be disabled by meeting participants

**Benefit:**
- Deters unauthorized recording/screenshots
- Provides accountability trail
- Helps identify source of leaked content

---

### 2. Screen Capture Prevention ✅

**Setting:** `PreventScreenCaptureForNonOrganizerParticipants = True`

**What it does:**
- Blocks participants from taking screenshots during meeting
- Blocks participants from using screen recording tools
- Only organizer and co-organizers can capture screens

**Requirements:**
- Teams Premium license
- Windows or Mac desktop client (NOT web browser)
- Latest Teams client version

**Benefit:**
- Prevents unauthorized screen captures
- Ensures only authorized people can record content
- Works with Teams-native capture blocking

**Note:** This does NOT prevent OS-level screen capture tools (Snipping Tool, etc.). It only blocks Teams-native features.

---

### 3. Sensitive Content Detection ✅

**Setting:** `AllowScreenContentDigitization = False`

**What it does:**
- AI analyzes screen sharing in real-time
- Detects sensitive information:
  - Credit card numbers
  - Social Security Numbers (SSN)
  - Personally Identifiable Information (PII)
  - Phone numbers
  - Email addresses (in certain contexts)
- Warns the sharer if sensitive content is detected

**How it works:**
1. User shares screen
2. AI analyzes content in real-time
3. If sensitive data detected, user sees warning banner
4. User can choose to continue or stop sharing

**Benefit:**
- Prevents accidental exposure of sensitive data
- Real-time warnings help users make informed decisions
- Reduces risk of compliance violations

**Note:** This does NOT block sharing - it only warns. Users can still choose to share.

---

### 4. Recording & Transcript Access ✅

**Settings:**
- `RecordingStorageMode = "Stream"` (stores in OneDrive/SharePoint)
- `AllowRecordingStorageOutsideRegion = False`
- Default access: Only organizer and co-organizers

**What it does:**
- Recordings saved to Microsoft Stream (OneDrive for Business)
- By default, only organizer and co-organizers can access
- Recording cannot be stored outside your region
- Same access control applies to transcripts

**How access works:**

**Default Access (Automatic):**
- ✅ Meeting organizer
- ✅ Co-organizers (if designated)
- ❌ Regular participants
- ❌ External/guest users

**Manual Sharing (Optional):**
- Organizer can manually share recording link with others after meeting
- Organizer controls who gets access
- Provides flexibility while maintaining security by default

**Benefit:**
- Prevents unauthorized access to sensitive meeting content
- Organizer maintains control over distribution
- Compliant with data residency requirements

---

### 5. Lobby Admittance Controls ✅

**Settings:**
- `AutoAdmittedUsers = "EveryoneInCompanyExcludingGuests"`
- `AllowPSTNUsersToBypassLobby = False`
- `DesignatedPresenterRoleMode = "OrganizerOnlyUserOverride"`

**What it does:**
- Organization users (internal) join meeting directly
- Guests, external users, and phone dial-in users wait in lobby
- Only organizers and co-organizers can admit people from lobby
- Regular participants cannot admit from lobby

**Who waits in lobby:**
- ❌ External users (from other organizations)
- ❌ Anonymous users
- ❌ Guest users
- ❌ Phone dial-in users (PSTN)

**Who can bypass lobby:**
- ✅ Internal organization users (yourcompany.ca emails)

**Who can admit from lobby:**
- ✅ Meeting organizer
- ✅ Co-organizers (if designated)
- ❌ Regular participants (cannot admit)

**Benefit:**
- Ensures only authorized people admit external participants
- Prevents participants from accidentally admitting unknown users
- Organizer maintains full control over meeting access

---

### 6. Additional Restrictions ✅

**Breakout Rooms:** DISABLED  
`AllowBreakoutRooms = False`
- Prevents splitting meeting into sub-rooms
- Maintains centralized control
- All participants stay in main meeting

**Meeting Reactions:** DISABLED  
`AllowMeetingReactions = False`
- Disables emoji reactions (👍, ❤️, 😂, etc.)
- Reduces distractions in formal meetings
- Maintains professional atmosphere

**Anonymous Dial-Out:** DISABLED  
`AllowAnonymousUsersToDialOut = False`
- Prevents anonymous users from calling others
- Reduces potential for abuse
- Maintains meeting integrity

**External Meeting Join:** DISABLED  
`AllowUserToJoinExternalMeeting = "Disabled"`
- Users with this policy cannot join external organization meetings
- Prevents data leakage through external meetings
- Ensures all meetings are within controlled environment

---

## How Users Experience These Settings

### Creating a Protected B Meeting

1. Open Teams → Calendar → New Meeting
2. Select "Sensitivity" → **Protected B - Secure Meeting**
3. Meeting is automatically configured with all security settings
4. User cannot disable watermarks, screen protection, etc.

### During a Protected B Meeting

**Organizer sees:**
- Lobby notifications when external users join
- Can admit or deny lobby requests
- Has full presenter controls
- Can record meeting (saved to their OneDrive)

**Participants see:**
- Email watermark on camera video
- Email watermark on shared screens
- Cannot take screenshots (if on desktop client)
- Warning if sharing sensitive content
- Cannot admit people from lobby

**After the meeting:**
- Recording available only to organizer/co-organizers
- Transcript available only to organizer/co-organizers
- Organizer can manually share if needed

---

## Comparison: Protected B vs. General

| Feature | Protected B | General |
|---------|-------------|---------|
| **Watermarks** | ✅ Enabled (camera + screen) | ❌ Disabled |
| **Screen Capture Prevention** | ✅ Enabled | ❌ Disabled |
| **Sensitive Content Detection** | ✅ Enabled | ❌ Disabled |
| **Recording Access** | Organizer/Co-org only | All presenters |
| **Lobby Admittance** | Organizer/Co-org only | Everyone can admit |
| **Lobby Bypass** | Org users only | Org + guests |
| **Phone Dial-in Lobby** | Must wait | Can bypass |
| **Breakout Rooms** | ❌ Disabled | ✅ Enabled |
| **Reactions** | ❌ Disabled | ✅ Enabled |
| **Meeting Coach** | ❌ Disabled | ✅ Enabled |
| **Presenter Control** | Organizer controls | Everyone |
| **CMK Encryption** | ✅ Enabled | ✅ Enabled |

---

## Technical Requirements

### For Screen Capture Prevention:
- ✅ Teams Premium license (all LCE M365 Security members have this)
- ✅ Windows or Mac desktop client (NOT web browser)
- ✅ Latest Teams client version
- ❌ Does NOT work on: Teams web, mobile apps

### For Sensitive Content Detection:
- ✅ Teams Premium license
- ✅ Any Teams client (desktop, web, mobile)
- ✅ AI-powered - works automatically

### For Watermarks:
- ✅ Teams Premium license
- ✅ Any Teams client (desktop, web, mobile)
- ✅ Cannot be disabled by users

---

## Testing Checklist

### Test 1: Watermarks
1. Create meeting with Protected B label
2. Join meeting
3. Turn on camera → ✅ See email watermark on video
4. Share screen → ✅ See email watermark on screen

### Test 2: Screen Capture (Desktop Client Only)
1. Join Protected B meeting on desktop client
2. Try to take screenshot → ✅ Should be blocked
3. Have organizer try → ✅ Organizer can capture

### Test 3: Sensitive Content Detection
1. Join Protected B meeting
2. Share screen showing document with credit card number
3. ✅ Should see warning banner about sensitive content

### Test 4: Recording Access
1. Organizer records Protected B meeting
2. After meeting, check recording in Stream/OneDrive
3. ✅ Only organizer and co-organizers see it in their Stream
4. Regular participants ✅ do NOT see it

### Test 5: Lobby Controls
1. Organizer creates Protected B meeting
2. Have external user try to join
3. ✅ External user waits in lobby
4. Have participant try to admit → ✅ Cannot admit (button disabled)
5. Organizer admits → ✅ Works

---

## Troubleshooting

### Screen Capture Prevention Not Working

**Symptom:** Users can still take screenshots

**Possible Causes:**
1. User is on web browser (not desktop client)
2. User is on mobile app (feature not available)
3. User is organizer/co-organizer (they can capture)
4. User's Teams client is outdated

**Solution:**
- Ensure user is on Windows/Mac desktop client
- Update Teams to latest version
- Verify user is not organizer/co-organizer

**Note:** OS-level screen capture tools (Snipping Tool, Snagit, etc.) are NOT blocked by this feature.

---

### Sensitive Content Detection Not Showing Warnings

**Symptom:** No warning when sharing sensitive data

**Possible Causes:**
1. Feature still rolling out to tenant (can take 48 hours)
2. Sensitive content not recognized (false negative)
3. User dismissed warning quickly

**Solution:**
- Wait 48 hours after policy assignment
- Test with obvious sensitive data (credit card: 4111 1111 1111 1111)
- Check Teams admin center for feature availability

---

### Recording Not Showing for Co-Organizers

**Symptom:** Co-organizer can't see recording

**Possible Causes:**
1. User not properly designated as co-organizer
2. Recording still processing (can take hours)
3. Permissions not propagated yet

**Solution:**
- In meeting invite, explicitly add user as "Co-organizer"
- Wait 24 hours for recording to fully process
- Organizer can manually share link to co-organizer

---

## Policy Application Commands

### Check User's Current Policy
```powershell
Connect-MicrosoftTeams
Get-CsOnlineUser -Identity "user@leonardocompany.ca" | Select-Object TeamsMeetingPolicy
Disconnect-MicrosoftTeams
```

### Apply Protected B Policy to User
```powershell
Connect-MicrosoftTeams
Grant-CsTeamsMeetingPolicy -Identity "user@leonardocompany.ca" -PolicyName "Leonardo-Secure-Meeting-Group"
Disconnect-MicrosoftTeams
```

### Apply Regular Policy to User
```powershell
Connect-MicrosoftTeams
Grant-CsTeamsMeetingPolicy -Identity "user@leonardocompany.ca" -PolicyName "Leonardo-Regular-Meeting-Group"
Disconnect-MicrosoftTeams
```

### Verify Policy Settings
```powershell
Connect-MicrosoftTeams
Get-CsTeamsMeetingPolicy -Identity "Leonardo-Secure-Meeting-Group" | Select-Object `
    AllowWatermarkForCameraVideo, `
    AllowWatermarkForScreenSharing, `
    AllowScreenContentDigitization, `
    PreventScreenCaptureForNonOrganizerParticipants, `
    AutoAdmittedUsers, `
    DesignatedPresenterRoleMode, `
    RecordingStorageMode
Disconnect-MicrosoftTeams
```

---

## References

- [Teams Premium Features](https://learn.microsoft.com/en-us/microsoftteams/teams-premium-features)
- [Watermarks for Teams Meetings](https://learn.microsoft.com/en-us/microsoftteams/watermark-meeting-content-video)
- [Sensitivity Labels for Teams](https://learn.microsoft.com/en-us/microsoftteams/sensitivity-labels)
- [Meeting Policies Reference](https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-overview)

---

**Document Version:** 1.0  
**Last Updated:** November 20, 2025  
**Authors:** Fred Pearson & George Zarif  
**For:** LCE M365 Security Group