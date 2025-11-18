# ========================================
# Lock Down Secure Meeting Options
# Maximum security configuration
# Author: George Zarif
# ========================================

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  LOCK DOWN SECURE MEETING OPTIONS                               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Connect-MicrosoftTeams

$securePolicyName = "Leonardo-Secure-Meeting-Group"

Write-Host "`nApplying maximum security locks..." -ForegroundColor Yellow

try {
    Set-CsTeamsMeetingPolicy -Identity $securePolicyName `
        -AllowOrganizersToOverrideLobbySettings $false `
        -AllowPSTNUsersToBypassLobby $false `
        -AllowAnonymousUsersToJoinMeeting $false `
        -AllowAnonymousUsersToStartMeeting $false `
        -AllowAnonymousUsersToDialOut $false `
        -AllowExternalNonTrustedMeetingChat $false `
        -AutoAdmittedUsers "EveryoneInCompanyExcludingGuests" `
        -DesignatedPresenterRoleMode "OrganizerOnlyUserOverride" `
        -AllowParticipantGiveRequestControl $false `
        -AllowExternalParticipantGiveRequestControl $false `
        -AllowWatermarkForCameraVideo $true `
        -AllowWatermarkForScreenSharing $true
    
    Write-Host "✓ Secure policy locked down" -ForegroundColor Green
    
    # Verify
    $policy = Get-CsTeamsMeetingPolicy -Identity $securePolicyName
    
    Write-Host "`nVerification:" -ForegroundColor Cyan
    Write-Host "  Override Lobby: $($policy.AllowOrganizersToOverrideLobbySettings)" -ForegroundColor $(if($policy.AllowOrganizersToOverrideLobbySettings -eq $false){"Green"}else{"Red"})
    Write-Host "  Watermarks: $($policy.AllowWatermarkForCameraVideo)" -ForegroundColor $(if($policy.AllowWatermarkForCameraVideo -eq $true){"Green"}else{"Red"})
    Write-Host "  Anonymous: $($policy.AllowAnonymousUsersToJoinMeeting)" -ForegroundColor $(if($policy.AllowAnonymousUsersToJoinMeeting -eq $false){"Green"}else{"Red"})
    
} catch {
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-MicrosoftTeams

Write-Host "`n✅ Lock down complete`n" -ForegroundColor Green