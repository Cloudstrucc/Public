<#
.SYNOPSIS
    Diagnose Label Policy Status - Comprehensive Diagnostic Tool
.DESCRIPTION
    Shows detailed status of all label policies in your tenant.
    Use this to troubleshoot and verify label configuration.
    
    Shows:
    - All sensitivity label policies
    - Which labels are in each policy
    - Location assignments (Exchange, SharePoint, OneDrive, Teams)
    - Advanced settings
    - Identifies LCE Meeting Labels policy specifically
    
    Safe to run anytime - read-only diagnostic.
.AUTHOR
    Fred Pearson & George Zarif
.DATE
    November 22, 2025
.NOTES
    VERSION 9.0
    Diagnostic tool - does not modify anything
#>

Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  LABEL POLICY DIAGNOSTIC TOOL                                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nThis tool shows all label policies and their configuration." -ForegroundColor Yellow
Write-Host "Use this to verify LCE Meeting Labels are configured correctly.`n" -ForegroundColor Yellow

# Connect to Microsoft Purview
Write-Host "Connecting to Microsoft Purview..." -ForegroundColor Cyan

try {
    Connect-IPPSSession -ErrorAction Stop
    Write-Host "✓ Connected`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Connection failed: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# Get all label policies
Write-Host "Retrieving all label policies...`n" -ForegroundColor Cyan

try {
    $allPolicies = Get-LabelPolicy -ErrorAction Stop
    
    if ($allPolicies.Count -eq 0) {
        Write-Host "⚠️  No label policies found in tenant" -ForegroundColor Yellow
        Write-Host "You need to create one with: 02-Configure-Label-Policy-TeamsOnly.ps1`n" -ForegroundColor White
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        exit 0
    }
    
    Write-Host "Found $($allPolicies.Count) label policy/policies`n" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════════════`n" -ForegroundColor Gray
    
} catch {
    Write-Host "✗ Error retrieving policies: $($_.Exception.Message)`n" -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    exit 1
}

# Initialize report
$report = @"
Label Policy Diagnostic Report
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Run By: $env:USERNAME

Total Policies Found: $($allPolicies.Count)

"@

# Analyze each policy
$policyNumber = 1
foreach ($policy in $allPolicies) {
    
    $isLCEPolicy = $policy.Name -eq "LCE Meeting Labels"
    
    # Display header
    if ($isLCEPolicy) {
        Write-Host "🎯 POLICY $policyNumber (LCE MEETING LABELS - TARGET POLICY)" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
    } else {
        Write-Host "POLICY $policyNumber" -ForegroundColor White
        Write-Host "───────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    }
    
    # Basic info
    Write-Host "Name: " -NoNewline -ForegroundColor White
    Write-Host $policy.Name -ForegroundColor $(if ($isLCEPolicy) { "Green" } else { "Cyan" })
    
    Write-Host "GUID: " -NoNewline -ForegroundColor Gray
    Write-Host $policy.Guid -ForegroundColor Gray
    
    Write-Host "Created: " -NoNewline -ForegroundColor White
    Write-Host $policy.WhenCreated -ForegroundColor Gray
    
    Write-Host "Modified: " -NoNewline -ForegroundColor White
    Write-Host $policy.WhenChanged -ForegroundColor Gray
    
    # Labels in this policy
    Write-Host "`nLabels ($($policy.Labels.Count)):" -ForegroundColor White
    
    if ($policy.Labels.Count -eq 0) {
        Write-Host "  (none)" -ForegroundColor Gray
    } else {
        foreach ($labelGuid in $policy.Labels) {
            try {
                $label = Get-Label -Identity $labelGuid -ErrorAction SilentlyContinue
                if ($label) {
                    $labelColor = if ($label.DisplayName -like "*Protected B*") { "Red" } 
                                  elseif ($label.DisplayName -like "*General*") { "Green" } 
                                  else { "White" }
                    Write-Host "  • $($label.DisplayName)" -ForegroundColor $labelColor
                } else {
                    Write-Host "  • $labelGuid (label not found)" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "  • $labelGuid (error retrieving)" -ForegroundColor Yellow
            }
        }
    }
    
    # Location analysis
    Write-Host "`nLocations:" -ForegroundColor White
    
    # Exchange (Outlook)
    $exchangeCount = $policy.ExchangeLocation.Count
    $exchangeColor = if ($isLCEPolicy) {
        if ($exchangeCount -eq 0) { "Green" } else { "Red" }
    } else {
        if ($exchangeCount -gt 0) { "White" } else { "Gray" }
    }
    
    Write-Host "  Exchange (Outlook): " -NoNewline -ForegroundColor White
    Write-Host "$exchangeCount locations" -ForegroundColor $exchangeColor
    
    if ($isLCEPolicy -and $exchangeCount -gt 0) {
        Write-Host "    ⚠️  WARNING: Should be 0 for Teams-only labels!" -ForegroundColor Red
    }
    
    # SharePoint
    $sharepointCount = $policy.SharePointLocation.Count
    Write-Host "  SharePoint: " -NoNewline -ForegroundColor White
    Write-Host "$sharepointCount locations" -ForegroundColor $(if ($sharepointCount -gt 0) { "White" } else { "Gray" })
    
    if ($isLCEPolicy -and $sharepointCount -gt 0) {
        Write-Host "    ℹ️  Note: Should be 0 for Teams-only labels" -ForegroundColor Yellow
    }
    
    # OneDrive
    $onedriveCount = $policy.OneDriveLocation.Count
    Write-Host "  OneDrive: " -NoNewline -ForegroundColor White
    Write-Host "$onedriveCount locations" -ForegroundColor $(if ($onedriveCount -gt 0) { "White" } else { "Gray" })
    
    if ($isLCEPolicy -and $onedriveCount -gt 0) {
        Write-Host "    ℹ️  Note: Should be 0 for Teams-only labels" -ForegroundColor Yellow
    }
    
    # Advanced Settings
    if ($policy.Settings -or $policy.AdvancedSettings) {
        Write-Host "`nAdvanced Settings:" -ForegroundColor White
        
        $advSettings = $policy.Settings
        if ($advSettings) {
            foreach ($key in $advSettings.Keys) {
                Write-Host "  $key = $($advSettings[$key])" -ForegroundColor Gray
            }
        }
        
        # Check for Outlook-specific settings
        if ($policy.AdvancedSettings) {
            $outlookSettings = @(
                "OutlookDefaultLabel",
                "DisableMandatoryInOutlook",
                "TeamsMeetingPolicy"
            )
            
            foreach ($setting in $outlookSettings) {
                if ($policy.AdvancedSettings.ContainsKey($setting)) {
                    $value = $policy.AdvancedSettings[$setting]
                    $color = if ($setting -like "*Outlook*" -and $value -like "*True*") { "Green" } else { "Gray" }
                    Write-Host "  $setting = $value" -ForegroundColor $color
                }
            }
        }
    }
    
    # Health check for LCE policy
    if ($isLCEPolicy) {
        Write-Host "`nHealth Check:" -ForegroundColor Cyan
        
        $issues = @()
        $warnings = @()
        
        if ($exchangeCount -gt 0) {
            $issues += "Exchange locations configured (should be 0)"
        }
        
        if ($sharepointCount -gt 0) {
            $warnings += "SharePoint locations configured"
        }
        
        if ($onedriveCount -gt 0) {
            $warnings += "OneDrive locations configured"
        }
        
        if ($policy.Labels.Count -ne 2) {
            $warnings += "Expected 2 labels, found $($policy.Labels.Count)"
        }
        
        if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
            Write-Host "  ✅ HEALTHY - No issues detected" -ForegroundColor Green
        } else {
            if ($issues.Count -gt 0) {
                Write-Host "  ❌ ISSUES:" -ForegroundColor Red
                foreach ($issue in $issues) {
                    Write-Host "     • $issue" -ForegroundColor Red
                }
            }
            
            if ($warnings.Count -gt 0) {
                Write-Host "  ⚠️  WARNINGS:" -ForegroundColor Yellow
                foreach ($warning in $warnings) {
                    Write-Host "     • $warning" -ForegroundColor Yellow
                }
            }
        }
        
        # Recommended actions
        if ($issues.Count -gt 0) {
            Write-Host "`nRecommended Action:" -ForegroundColor Cyan
            Write-Host "  Run: .\02B-Emergency-Remove-Outlook-Labels.ps1" -ForegroundColor Yellow
        }
    }
    
    Write-Host "" # Blank line
    
    # Add to report
    $report += @"

───────────────────────────────────────────────────────────────────
POLICY $policyNumber$(if ($isLCEPolicy) { " (LCE MEETING LABELS)" } else { "" })
───────────────────────────────────────────────────────────────────
Name: $($policy.Name)
GUID: $($policy.Guid)
Created: $($policy.WhenCreated)

Labels: $($policy.Labels.Count)
$((0..($policy.Labels.Count-1) | ForEach-Object {
    $labelGuid = $policy.Labels[$_]
    $label = Get-Label -Identity $labelGuid -ErrorAction SilentlyContinue
    if ($label) { "  • $($label.DisplayName)" } else { "  • $labelGuid" }
}) -join "`n")

Locations:
  Exchange: $exchangeCount
  SharePoint: $sharepointCount
  OneDrive: $onedriveCount

"@
    
    $policyNumber++
}

# Summary
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray

$lcePolicy = $allPolicies | Where-Object { $_.Name -eq "LCE Meeting Labels" }

if ($lcePolicy) {
    Write-Host "`n✓ LCE Meeting Labels policy found" -ForegroundColor Green
    
    $overallHealth = "HEALTHY"
    $healthColor = "Green"
    
    if ($lcePolicy.ExchangeLocation.Count -gt 0) {
        $overallHealth = "NEEDS ATTENTION"
        $healthColor = "Red"
    } elseif ($lcePolicy.SharePointLocation.Count -gt 0 -or $lcePolicy.OneDriveLocation.Count -gt 0) {
        $overallHealth = "MINOR WARNINGS"
        $healthColor = "Yellow"
    }
    
    Write-Host "Status: " -NoNewline -ForegroundColor White
    Write-Host $overallHealth -ForegroundColor $healthColor
    
    Write-Host "`nQuick Stats:" -ForegroundColor White
    Write-Host "  Labels: $($lcePolicy.Labels.Count)" -ForegroundColor Gray
    Write-Host "  Exchange: $($lcePolicy.ExchangeLocation.Count)" -ForegroundColor $(if ($lcePolicy.ExchangeLocation.Count -eq 0) { "Green" } else { "Red" })
    Write-Host "  SharePoint: $($lcePolicy.SharePointLocation.Count)" -ForegroundColor Gray
    Write-Host "  OneDrive: $($lcePolicy.OneDriveLocation.Count)" -ForegroundColor Gray
    
} else {
    Write-Host "`n⚠️  LCE Meeting Labels policy NOT FOUND" -ForegroundColor Yellow
    Write-Host "Create it with: 02-Configure-Label-Policy-TeamsOnly.ps1" -ForegroundColor White
}

Write-Host ""

# Disconnect
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

# Save report
$exportPath = "C:\LeonardoReports"
New-Item -Path $exportPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

$reportFile = "$exportPath\Policy-Diagnostic-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

$report += @"

═══════════════════════════════════════════════════════════════════
SUMMARY
═══════════════════════════════════════════════════════════════════

Total Policies: $($allPolicies.Count)
LCE Meeting Labels Found: $(if ($lcePolicy) { "Yes" } else { "No" })

$(if ($lcePolicy) {
"LCE Policy Status:
  Labels: $($lcePolicy.Labels.Count)
  Exchange: $($lcePolicy.ExchangeLocation.Count) $(if ($lcePolicy.ExchangeLocation.Count -gt 0) { "(ISSUE)" } else { "(OK)" })
  SharePoint: $($lcePolicy.SharePointLocation.Count)
  OneDrive: $($lcePolicy.OneDriveLocation.Count)
"
} else {
"LCE Meeting Labels policy not found.
Run: 02-Configure-Label-Policy-TeamsOnly.ps1
"
})

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

$report | Out-File $reportFile -Encoding UTF8

Write-Host "📄 Full report: $reportFile" -ForegroundColor Gray
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
