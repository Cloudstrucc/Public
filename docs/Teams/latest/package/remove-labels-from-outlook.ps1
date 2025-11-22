<#
.SYNOPSIS
    Remove Sensitivity Labels from Outlook/Email (Keep Teams Only)
.DESCRIPTION
    This script removes the sensitivity label policy from Exchange/Outlook locations
    while preserving it for Teams meetings. Shows affected distribution group members.
.AUTHOR
    Fred Pearson
.DATE
    November 20, 2025
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  REMOVE LABELS FROM OUTLOOK/EMAIL                                ║" -ForegroundColor Cyan
Write-Host "║  (Keep Teams Only)                                               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Configuration
$policyName = "LCE Meeting Labels"
$groupEmail = "lcem365security@leonardocompany.ca"

Write-Host "`n[Connecting to Security & Compliance Center...]" -ForegroundColor Yellow
Connect-IPPSSession

# Also connect to Exchange Online for distribution group access
Write-Host "[Connecting to Exchange Online...]" -ForegroundColor Yellow
try {
    # Check if already connected to Exchange Online
    $exoSession = Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened"}
    if (-not $exoSession) {
        Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
    }
} catch {
    Write-Host "  ⚠️  Could not connect to Exchange Online: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n[1/4] Checking current policy status..." -ForegroundColor Cyan

$policy = Get-LabelPolicy -Identity $policyName -ErrorAction SilentlyContinue

if (-not $policy) {
    Write-Host "  ✗ Policy '$policyName' not found!" -ForegroundColor Red
    Write-Host "    Make sure you ran the main configuration script first." -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return
}

Write-Host "  ✓ Found policy: $($policy.Name)" -ForegroundColor Green
Write-Host "`n  Current locations:" -ForegroundColor Cyan
Write-Host "    Exchange: $($policy.ExchangeLocation.Count)" -ForegroundColor $(if($policy.ExchangeLocation.Count -gt 0){"Yellow"}else{"Green"})
Write-Host "    SharePoint: $($policy.SharePointLocation.Count)" -ForegroundColor $(if($policy.SharePointLocation.Count -gt 0){"Yellow"}else{"Green"})
Write-Host "    OneDrive: $($policy.OneDriveLocation.Count)" -ForegroundColor $(if($policy.OneDriveLocation.Count -gt 0){"Yellow"}else{"Green"})

# Check total locations
$totalLocations = 0
if ($policy.ExchangeLocation) { $totalLocations += $policy.ExchangeLocation.Count }
if ($policy.SharePointLocation) { $totalLocations += $policy.SharePointLocation.Count }
if ($policy.OneDriveLocation) { $totalLocations += $policy.OneDriveLocation.Count }

# Get distribution group members (works for Exchange Distribution Lists)
Write-Host "`n[2/4] Checking distribution group members..." -ForegroundColor Cyan
$groupMembers = @()

try {
    # Try to get distribution group members
    $dgMembers = Get-DistributionGroupMember -Identity $groupEmail -ErrorAction SilentlyContinue
    
    if ($dgMembers) {
        Write-Host "  ✓ Found distribution group: $groupEmail" -ForegroundColor Green
        Write-Host "  ✓ Members: $($dgMembers.Count)" -ForegroundColor Green
        Write-Host "`n  Users affected by this policy:" -ForegroundColor Cyan
        
        foreach ($member in $dgMembers) {
            $groupMembers += [PSCustomObject]@{
                DisplayName = $member.DisplayName
                UserPrincipalName = $member.PrimarySmtpAddress
            }
            Write-Host "    • $($member.DisplayName) - $($member.PrimarySmtpAddress)" -ForegroundColor White
        }
    } else {
        Write-Host "  ⚠️  Distribution group not found: $groupEmail" -ForegroundColor Yellow
        Write-Host "     Checking for M365 group..." -ForegroundColor Gray
        
        # Try as M365 Group
        $m365Group = Get-UnifiedGroup -Identity $groupEmail -ErrorAction SilentlyContinue
        if ($m365Group) {
            $m365Members = Get-UnifiedGroupLinks -Identity $groupEmail -LinkType Members -ErrorAction SilentlyContinue
            
            if ($m365Members) {
                Write-Host "  ✓ Found M365 group: $groupEmail" -ForegroundColor Green
                Write-Host "  ✓ Members: $($m365Members.Count)" -ForegroundColor Green
                Write-Host "`n  Users affected by this policy:" -ForegroundColor Cyan
                
                foreach ($member in $m365Members) {
                    $groupMembers += [PSCustomObject]@{
                        DisplayName = $member.DisplayName
                        UserPrincipalName = $member.PrimarySmtpAddress
                    }
                    Write-Host "    • $($member.DisplayName) - $($member.PrimarySmtpAddress)" -ForegroundColor White
                }
            }
        } else {
            Write-Host "  ⚠️  Could not find group" -ForegroundColor Yellow
            Write-Host "     Policy applies to all users with the label policy assigned" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "  ⚠️  Could not retrieve group members: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check if already clean
if ($totalLocations -eq 0) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅ POLICY ALREADY CONFIGURED CORRECTLY                          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`n✅ Current Status:" -ForegroundColor Yellow
    Write-Host "  • Policy: $policyName" -ForegroundColor White
    Write-Host "  • Exchange locations: 0 (No Outlook)" -ForegroundColor Green
    Write-Host "  • SharePoint locations: 0" -ForegroundColor Green
    Write-Host "  • OneDrive locations: 0" -ForegroundColor Green
    Write-Host "  • Labels appear ONLY in Teams ✓" -ForegroundColor Green
    
    if ($groupMembers.Count -gt 0) {
        Write-Host "`n✅ AFFECTED USERS ($($groupMembers.Count) members):" -ForegroundColor Yellow
        foreach ($member in $groupMembers) {
            Write-Host "  • $($member.DisplayName) - $($member.UserPrincipalName)" -ForegroundColor White
        }
        Write-Host "`n  Impact:" -ForegroundColor Cyan
        Write-Host "    ✓ These users should NOT see labels in Outlook" -ForegroundColor Green
        Write-Host "    ✓ These users WILL see labels in Teams meetings" -ForegroundColor Green
    } else {
        Write-Host "`n  Note: Could not retrieve group membership" -ForegroundColor Gray
        Write-Host "  Policy applies to all users with label policy assigned" -ForegroundColor Gray
    }
    
    Write-Host "`n⏱️  If labels still appear in Outlook:" -ForegroundColor Yellow
    Write-Host "  • Wait full 24 hours for propagation" -ForegroundColor White
    Write-Host "  • Restart Outlook completely" -ForegroundColor White
    Write-Host "  • Clear Outlook cache" -ForegroundColor White
    
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return
}

# Remove locations
Write-Host "`n[3/4] Removing all Office locations..." -ForegroundColor Cyan
Write-Host "  This will remove labels from:" -ForegroundColor Gray
Write-Host "    • Outlook (new email)" -ForegroundColor Gray
Write-Host "    • Word, Excel, PowerPoint" -ForegroundColor Gray
Write-Host "    • SharePoint, OneDrive" -ForegroundColor Gray
Write-Host "`n  Labels will ONLY remain in Teams meetings" -ForegroundColor Green

$removed = 0
$errors = 0

# Remove Exchange locations
if ($policy.ExchangeLocation) {
    Write-Host "`n  Removing Exchange locations..." -ForegroundColor Cyan
    foreach ($location in @($policy.ExchangeLocation)) {
        try {
            Write-Host "    Removing: $location" -NoNewline
            Set-LabelPolicy -Identity $policyName -RemoveExchangeLocation $location -ErrorAction Stop
            Write-Host " ✓" -ForegroundColor Green
            $removed++
            Start-Sleep -Milliseconds 500
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Yellow
            $errors++
        }
    }
}

# Refresh policy
Start-Sleep -Seconds 2
$policy = Get-LabelPolicy -Identity $policyName -ErrorAction SilentlyContinue

# Remove SharePoint locations
if ($policy.SharePointLocation) {
    Write-Host "`n  Removing SharePoint locations..." -ForegroundColor Cyan
    foreach ($location in @($policy.SharePointLocation)) {
        try {
            Write-Host "    Removing: $location" -NoNewline
            Set-LabelPolicy -Identity $policyName -RemoveSharePointLocation $location -ErrorAction Stop
            Write-Host " ✓" -ForegroundColor Green
            $removed++
            Start-Sleep -Milliseconds 500
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Yellow
            $errors++
        }
    }
}

# Refresh policy
Start-Sleep -Seconds 2
$policy = Get-LabelPolicy -Identity $policyName -ErrorAction SilentlyContinue

# Remove OneDrive locations
if ($policy.OneDriveLocation) {
    Write-Host "`n  Removing OneDrive locations..." -ForegroundColor Cyan
    foreach ($location in @($policy.OneDriveLocation)) {
        try {
            Write-Host "    Removing: $location" -NoNewline
            Set-LabelPolicy -Identity $policyName -RemoveOneDriveLocation $location -ErrorAction Stop
            Write-Host " ✓" -ForegroundColor Green
            $removed++
            Start-Sleep -Milliseconds 500
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Yellow
            $errors++
        }
    }
}

Write-Host "`n  Summary:" -ForegroundColor Cyan
Write-Host "    Locations removed: $removed" -ForegroundColor Green
Write-Host "    Errors: $errors" -ForegroundColor $(if($errors -gt 0){"Red"}else{"Green"})

# Verify
Write-Host "`n[4/4] Verifying changes..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

$verifiedPolicy = Get-LabelPolicy -Identity $policyName -ErrorAction SilentlyContinue

if (-not $verifiedPolicy) {
    Write-Host "  ⚠️  Cannot verify - policy not found" -ForegroundColor Yellow
    Write-Host "     Wait 5 minutes and check manually" -ForegroundColor Gray
} else {
    $finalCount = 0
    if ($verifiedPolicy.ExchangeLocation) { $finalCount += $verifiedPolicy.ExchangeLocation.Count }
    if ($verifiedPolicy.SharePointLocation) { $finalCount += $verifiedPolicy.SharePointLocation.Count }
    if ($verifiedPolicy.OneDriveLocation) { $finalCount += $verifiedPolicy.OneDriveLocation.Count }
    
    Write-Host "`n  Final status:" -ForegroundColor Cyan
    Write-Host "    Exchange: $($verifiedPolicy.ExchangeLocation.Count)" -ForegroundColor $(if($verifiedPolicy.ExchangeLocation.Count -eq 0){"Green"}else{"Red"})
    Write-Host "    SharePoint: $($verifiedPolicy.SharePointLocation.Count)" -ForegroundColor $(if($verifiedPolicy.SharePointLocation.Count -eq 0){"Green"}else{"Red"})
    Write-Host "    OneDrive: $($verifiedPolicy.OneDriveLocation.Count)" -ForegroundColor $(if($verifiedPolicy.OneDriveLocation.Count -eq 0){"Green"}else{"Red"})
    Write-Host "    Total: $finalCount" -ForegroundColor $(if($finalCount -eq 0){"Green"}else{"Red"})
    
    if ($finalCount -eq 0) {
        Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║  ✅ SUCCESS - LABELS REMOVED FROM OUTLOOK                        ║" -ForegroundColor Green
        Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        
        Write-Host "`n✅ Configuration:" -ForegroundColor Yellow
        Write-Host "  • Policy: $policyName" -ForegroundColor White
        Write-Host "  • Exchange locations: 0 (Outlook labels REMOVED)" -ForegroundColor Green
        Write-Host "  • SharePoint locations: 0" -ForegroundColor Green
        Write-Host "  • OneDrive locations: 0" -ForegroundColor Green
        Write-Host "  • Teams: Labels STILL AVAILABLE ✓" -ForegroundColor Green
        
        if ($groupMembers.Count -gt 0) {
            Write-Host "`n✅ AFFECTED USERS ($($groupMembers.Count) members):" -ForegroundColor Yellow
            foreach ($member in $groupMembers) {
                Write-Host "  • $($member.DisplayName) - $($member.UserPrincipalName)" -ForegroundColor White
            }
            Write-Host "`n  Impact:" -ForegroundColor Cyan
            Write-Host "    ✓ These users will NO LONGER see labels in Outlook (after 24h)" -ForegroundColor Green
            Write-Host "    ✓ These users WILL see labels in Teams meetings" -ForegroundColor Green
        }
        
        Write-Host "`n⏱️  TIMELINE:" -ForegroundColor Yellow
        Write-Host "  • Immediate: Changes saved" -ForegroundColor White
        Write-Host "  • 15-30 minutes: Policy propagation starts" -ForegroundColor White
        Write-Host "  • 24 hours: Labels disappear from Outlook" -ForegroundColor White
        Write-Host "  • 24-48 hours: Labels appear in Teams" -ForegroundColor White
        
        Write-Host "`n✅ TESTING:" -ForegroundColor Yellow
        Write-Host "  1. Wait 24 hours" -ForegroundColor White
        Write-Host "  2. Have user create NEW email in Outlook" -ForegroundColor White
        Write-Host "  3. Check for 'Sensitivity' button - should NOT appear" -ForegroundColor White
        Write-Host "  4. Have user create Teams meeting" -ForegroundColor White
        Write-Host "  5. Check for labels - SHOULD appear" -ForegroundColor White
        
    } else {
        Write-Host "`n⚠️  WARNING: Still have $finalCount location(s)" -ForegroundColor Yellow
        Write-Host "   Labels may still appear in Outlook" -ForegroundColor Yellow
    }
}

# Generate simple report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
$reportFile = "$exportPath\Remove-Outlook-Labels-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

$report = @"
REMOVE LABELS FROM OUTLOOK - REPORT
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

POLICY: $policyName
Exchange Locations: $(if($verifiedPolicy){$verifiedPolicy.ExchangeLocation.Count}else{'N/A'})
SharePoint Locations: $(if($verifiedPolicy){$verifiedPolicy.SharePointLocation.Count}else{'N/A'})
OneDrive Locations: $(if($verifiedPolicy){$verifiedPolicy.OneDriveLocation.Count}else{'N/A'})

AFFECTED USERS ($($groupMembers.Count)):
$(if($groupMembers.Count -gt 0){($groupMembers | ForEach-Object { "  • $($_.DisplayName) - $($_.UserPrincipalName)" }) -join "`n"}else{"  (Could not retrieve group membership)"})

STATUS: $(if($finalCount -eq 0){'✅ Success - Labels removed from Outlook'}else{'⚠️ Incomplete'})
"@

$report | Out-File $reportFile -Encoding UTF8
Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Gray

Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "`n✅ Done! Wait 24 hours, then verify labels are gone from Outlook." -ForegroundColor Green
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")