<#
.SYNOPSIS
    Applies custom font settings to sensitivity label email header content marking.

.DESCRIPTION
    This script configures custom font name, size, and color for the header
    content marking on the "Unclassified" sensitivity label.
    
    Requires connection to Security & Compliance PowerShell.

.NOTES
    Author:         Leonardo Canada - LCE M365 Security Team
    Date:           December 2025
    Prerequisite:   ExchangeOnlineManagement module v3.0.0 or later
    
.EXAMPLE
    .\Set-SensitivityLabelHeaderFont-Unclassified.ps1
#>

#Requires -Version 5.1

# ============================================================================
# CONFIGURATION - Modify these values as needed
# ============================================================================

$LabelName = "Unclassified"

# Header Font Settings
$HeaderFontName  = "Franklin Gothic Medium"
$HeaderFontSize  = 14
$HeaderFontColor = "#107C10"  # Microsoft Green (Success)

# ============================================================================
# SCRIPT START
# ============================================================================

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Sensitivity Label Header Font Configuration Script" -ForegroundColor Cyan
Write-Host "  Label: Unclassified (Green/Success)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# Check if ExchangeOnlineManagement module is installed
Write-Host "[1/4] Checking for ExchangeOnlineManagement module..." -ForegroundColor Yellow

if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "      ExchangeOnlineManagement module not found." -ForegroundColor Red
    Write-Host "      Installing module..." -ForegroundColor Yellow
    
    try {
        Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
        Write-Host "      Module installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "      ERROR: Failed to install module. Run PowerShell as Administrator." -ForegroundColor Red
        Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "      Module found." -ForegroundColor Green
}

# Import the module
Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue

# Connect to Security & Compliance PowerShell
Write-Host ""
Write-Host "[2/4] Connecting to Security & Compliance PowerShell..." -ForegroundColor Yellow
Write-Host "      (A sign-in prompt will appear - use your admin credentials)" -ForegroundColor Gray

try {
    # Check if already connected
    $existingSession = Get-ConnectionInformation -ErrorAction SilentlyContinue | 
                       Where-Object { $_.ConnectionUri -like "*compliance*" }
    
    if ($existingSession) {
        Write-Host "      Already connected to Security & Compliance PowerShell." -ForegroundColor Green
    }
    else {
        Connect-IPPSSession -ErrorAction Stop
        Write-Host "      Connected successfully." -ForegroundColor Green
    }
}
catch {
    Write-Host "      ERROR: Failed to connect to Security & Compliance PowerShell." -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify the label exists
Write-Host ""
Write-Host "[3/4] Verifying label exists: '$LabelName'..." -ForegroundColor Yellow

$Label = $null

try {
    $Label = Get-Label -Identity $LabelName -ErrorAction Stop
    Write-Host "      Label found: $($Label.DisplayName)" -ForegroundColor Green
    Write-Host "      Label GUID:  $($Label.Guid)" -ForegroundColor Gray
}
catch {
    Write-Host "      Label '$LabelName' not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "      Available labels:" -ForegroundColor Yellow
    Write-Host ""
    
    # Get all labels and display with numbers for selection
    $AllLabels = Get-Label | Select-Object DisplayName, Guid
    $index = 1
    foreach ($lbl in $AllLabels) {
        Write-Host "      [$index] $($lbl.DisplayName)" -ForegroundColor White
        Write-Host "          GUID: $($lbl.Guid)" -ForegroundColor Gray
        $index++
    }
    
    Write-Host ""
    Write-Host "      [0] Exit script" -ForegroundColor Gray
    Write-Host ""
    
    # Prompt user to select a label
    do {
        $selection = Read-Host "      Enter the number of the label to configure (or 0 to exit)"
        
        if ($selection -eq "0") {
            Write-Host ""
            Write-Host "      Script cancelled by user." -ForegroundColor Yellow
            exit 0
        }
        
        $selectionInt = $selection -as [int]
        $labelCount = @($AllLabels).Count
        
        if ($selectionInt -and $selectionInt -ge 1 -and $selectionInt -le $labelCount) {
            $SelectedLabel = @($AllLabels)[$selectionInt - 1]
            $LabelGuid = $SelectedLabel.Guid
            
            # Re-fetch the full label object using GUID (more reliable than DisplayName)
            $Label = Get-Label -Identity $LabelGuid -ErrorAction SilentlyContinue
            
            if ($Label) {
                $LabelName = $Label.DisplayName
                Write-Host ""
                Write-Host "      Selected: $($Label.DisplayName)" -ForegroundColor Green
                Write-Host "      GUID:     $($Label.Guid)" -ForegroundColor Gray
            }
            else {
                Write-Host "      ERROR: Could not retrieve label details for GUID: $LabelGuid" -ForegroundColor Red
                $Label = $null
            }
        }
        else {
            Write-Host "      Invalid selection. Please enter a number between 0 and $labelCount." -ForegroundColor Red
        }
        
    } while (-not $Label)
}

# Confirm before applying changes
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "  Ready to apply the following settings:" -ForegroundColor Yellow
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Label:      $LabelName" -ForegroundColor White
Write-Host "  Font Name:  $HeaderFontName" -ForegroundColor White
Write-Host "  Font Size:  $HeaderFontSize pt" -ForegroundColor White
Write-Host "  Font Color: $HeaderFontColor " -ForegroundColor Green -NoNewline
Write-Host "(Green/Success)" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "  Proceed with these settings? (Y/N)"

if ($confirm -notmatch "^[Yy]") {
    Write-Host ""
    Write-Host "  Script cancelled by user." -ForegroundColor Yellow
    exit 0
}

# Apply the header font settings
Write-Host ""
Write-Host "[4/4] Applying header font settings..." -ForegroundColor Yellow

try {
    # Use GUID for Set-Label if available (more reliable), otherwise use DisplayName
    $LabelIdentity = if ($Label.Guid) { $Label.Guid } else { $LabelName }
    
    Set-Label -Identity $LabelIdentity `
        -ApplyContentMarkingHeaderFontName $HeaderFontName `
        -ApplyContentMarkingHeaderFontSize $HeaderFontSize `
        -ApplyContentMarkingHeaderFontColor $HeaderFontColor `
        -ErrorAction Stop
    
    Write-Host "      Header font settings applied successfully!" -ForegroundColor Green
}
catch {
    Write-Host "      ERROR: Failed to apply header font settings." -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Configuration Complete" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Label:      $LabelName" -ForegroundColor White
Write-Host "  Font:       $HeaderFontName" -ForegroundColor White
Write-Host "  Size:       $HeaderFontSize pt" -ForegroundColor White
Write-Host "  Color:      $HeaderFontColor " -ForegroundColor Green -NoNewline
Write-Host "(Green/Success)" -ForegroundColor White
Write-Host ""
Write-Host "  NOTE: Changes may take up to 24 hours to propagate" -ForegroundColor Yellow
Write-Host "        to all users and applications." -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan

# ============================================================================
# END OF SCRIPT
# ============================================================================