# Connect to Security & Compliance PowerShell if not already connected
# Connect-IPPSSession

# Get the label GUID
$labelName = "Protected B - Official Sensitive - NATO"
$label = Get-Label | Where-Object { $_.DisplayName -eq $labelName }

if (-not $label) {
    Write-Error "Label '$labelName' not found"
    return
}

Write-Host "Found label: $($label.DisplayName)" -ForegroundColor Green
Write-Host "Label GUID: $($label.Guid)" -ForegroundColor Green

# View current advanced settings
Write-Host "`nCurrent Advanced Settings:" -ForegroundColor Cyan
$label.Settings | Format-List

# Set enforcement for all meeting options
# Adjust the values below to match your current label configuration
Set-Label -Identity $label.Guid -AdvancedSettings @{
    # Who can bypass lobby - enforce your current setting
    "teamworkbypasslobbyfordialedinusers_enforced" = "true"
    "teamworklobbybypassscope_enforced" = "true"
    
    # Who can present - enforce
    "teamworkpresentersscope_enforced" = "true"
    
    # Who can record - enforce
    "teamworkwhocanrecord_enforced" = "true"
    
    # Automatic recording - enforce
    "teamworkrecordautomatically_enforced" = "true"
    
    # Video and audio settings - enforce
    "teamworkallowcamerafromattendees_enforced" = "true"
    "teamworkallowmicfromattendees_enforced" = "true"
    
    # Chat settings - enforce
    "teamworkallowmeetingchat_enforced" = "true"
    
    # Watermarks - enforce
    "teamworkapplywatermarkforvideo_enforced" = "true"
    "teamworkapplywatermarkforscreenshare_enforced" = "true"
    
    # End-to-end encryption - enforce
    "teamworkendtoendencryption_enforced" = "true"
    
    # Prevent copying chat - enforce
    "teamworkpreventcopyingchatcontent_enforced" = "true"
}

Write-Host "`nEnforcement settings applied!" -ForegroundColor Green

# Verify the changes
$updatedLabel = Get-Label -Identity $label.Guid
Write-Host "`nUpdated Advanced Settings:" -ForegroundColor Cyan
$updatedLabel.Settings | Format-List