# ========================================
# Create Meeting Templates Guide
# Opens Admin Center and provides instructions
# ========================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MEETING TEMPLATE SETUP WIZARD                                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nThis script will:" -ForegroundColor Yellow
Write-Host "  1. Open Teams Admin Center in your browser" -ForegroundColor White
Write-Host "  2. Guide you through creating two meeting templates" -ForegroundColor White
Write-Host "  3. Test that templates appear in Teams" -ForegroundColor White

Write-Host "`nPress ENTER to open Teams Admin Center..." -ForegroundColor Yellow
Read-Host

# Open Teams Admin Center to meeting templates page
Write-Host "`nOpening Teams Admin Center..." -ForegroundColor Cyan
Start-Process "https://admin.teams.microsoft.com/meetings/templates"

Write-Host "`nBrowser opening..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Display instructions
$instructions = @"

╔══════════════════════════════════════════════════════════════════╗
║  FOLLOW THESE STEPS IN YOUR BROWSER                             ║
╚══════════════════════════════════════════════════════════════════╝

TEMPLATE 1: SECURE MEETING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Click "+ Add" button (top right corner)

Step 2: Fill in these details:

  Template name: Leonardo - Secure Meeting
  
  Description: For classified, NDA, or sensitive content. 
               Includes watermarks and strict security controls.
  
  Template type: Custom

Step 3: Configure options:

  Security:
    ✅ Watermark everyone's video
    ✅ Watermark shared content
    
  Lobby:
    Who can bypass: People in my organization and guests
    People dialing in can bypass: OFF
    
  Engagement:
    Who can present: Only organizers and co-organizers
    Allow mic for attendees: ON
    Allow camera for attendees: ON
    Allow meeting chat: Enabled
    Allow reactions: ON
    
  Recording & transcription:
    Automatically record: Organizer can choose
    Who can record: Organizers and co-organizers

Step 4: Click "Save"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TEMPLATE 2: REGULAR MEETING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Click "+ Add" button again

Step 2: Fill in these details:

  Template name: Leonardo - Regular Meeting
  
  Description: For team syncs, casual calls, and external 
               collaboration. Open access with AI features.
  
  Template type: Custom

Step 3: Configure options:

  Security:
    ❌ Watermark everyone's video
    ❌ Watermark shared content
    
  Lobby:
    Who can bypass: Everyone
    People dialing in can bypass: ON
    
  Engagement:
    Who can present: Everyone
    Allow mic for attendees: ON
    Allow camera for attendees: ON
    Allow meeting chat: Enabled
    Allow reactions: ON
    
  Recording & transcription:
    Automatically record: Organizer can choose
    Who can record: Organizers, co-organizers, presenters

Step 4: Click "Save"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@

Write-Host $instructions -ForegroundColor White

Write-Host "Press ENTER after you've created BOTH templates..." -ForegroundColor Yellow
Read-Host

# Test instructions
Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  NOW LET'S TEST IN TEAMS                                        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nNOTE: Templates may take 5-15 minutes to sync to Teams client" -ForegroundColor Yellow

$testSteps = @"

TESTING STEPS:

1. Open Microsoft Teams (desktop app)

2. Sign out and sign back in (to refresh policies)
   - Click your profile picture (top right)
   - Click "Sign out"
   - Sign back in as fred.pearson@leonardocompany.ca

3. Go to Calendar (left sidebar)

4. Click "New meeting" button

5. Look for "Meeting template" or "Template" dropdown

   You should see:
   ┌──────────────────────────────────────┐
   │ Meeting template                     │
   │ [Select a template ▼]                │
   │                                      │
   │ Options:                             │
   │   • Leonardo - Regular Meeting       │
   │   • Leonardo - Secure Meeting        │
   └──────────────────────────────────────┘

6. Try selecting "Leonardo - Secure Meeting"

7. Create a test meeting and verify:
   - Meeting options link appears
   - Click it and verify watermarks are enabled

"@

Write-Host $testSteps -ForegroundColor White

Write-Host "`nDid the templates appear in Teams? (y/n): " -ForegroundColor Yellow -NoNewline
$response = Read-Host

if ($response -eq 'y') {
    Write-Host "`n✅ SUCCESS! Your meeting templates are working!" -ForegroundColor Green
    Write-Host "`nQuick Reference:" -ForegroundColor Cyan
    Write-Host "  🔒 Secure Meeting: Use for classified, NDA, sensitive content" -ForegroundColor White
    Write-Host "  📋 Regular Meeting: Use for team syncs, casual calls, external collab" -ForegroundColor White
    Write-Host "`nYou're all set! Create meetings and choose your template." -ForegroundColor Green
} else {
    Write-Host "`n⏱️  Templates may need more time to sync." -ForegroundColor Yellow
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Cyan
    Write-Host "  1. Wait 10-15 minutes" -ForegroundColor White
    Write-Host "  2. Close Teams completely and reopen" -ForegroundColor White
    Write-Host "  3. Clear Teams cache:" -ForegroundColor White
    Write-Host "     - Close Teams" -ForegroundColor Gray
    Write-Host "     - Press Win+R, type: %appdata%\Microsoft\Teams" -ForegroundColor Gray
    Write-Host "     - Delete the 'Cache' folder" -ForegroundColor Gray
    Write-Host "     - Restart Teams" -ForegroundColor Gray
    Write-Host "  4. Try using web Teams: https://teams.microsoft.com" -ForegroundColor White
    
    Write-Host "`nFALLBACK OPTION:" -ForegroundColor Yellow
    Write-Host "  If templates still don't appear, you can manually configure" -ForegroundColor White
    Write-Host "  each meeting using 'Meeting options' link in the invite." -ForegroundColor White
    Write-Host "  The end result is the same!" -ForegroundColor White
}

Write-Host "`n═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Setup complete! Check your email for the Quick Start Guide." -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan