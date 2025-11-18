#Requires -Version 5.1

<#
.SYNOPSIS
    Unpublish and Delete Sensitivity Label

.DESCRIPTION
    Removes label policy and then deletes the sensitivity label.
    Use this when you need to start fresh with label configuration.

.PARAMETER LabelName
    Name of the label to delete (default: "Protected B - Secure Meeting")

.EXAMPLE
    .\Delete-Sensitivity-Label.ps1
    
    Deletes the "Protected B - Secure Meeting" label

.EXAMPLE
    .\Delete-Sensitivity-Label.ps1 -LabelName "My Label"
    
    Deletes a specific label by name

.NOTES
    Author: George Zarif
    Version: 1.0
    
    This will:
    1. Find all policies publishing the label
    2. Remove the label from those policies (or delete the policy)
    3. Delete the label itself
#>

param(
    [string]$LabelName = "Protected B - Secure Meeting"
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Delete Sensitivity Label" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  WARNING: This will permanently delete the label!" -ForegroundColor Red
Write-Host ""

# Connect
Write-Host "Connecting to Security & Compliance Center..." -ForegroundColor Yellow
try {
    Connect-IPPSSession
    Write-Host "✓ Connected" -ForegroundColor Green
} catch {
    Write-Host "✗ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ========================================
# STEP 1: Find the label
# ========================================

Write-Host ""
Write-Host "STEP 1: Finding label '$LabelName'..." -ForegroundColor Cyan

$label = Get-Label | Where-Object {$_.DisplayName -eq $LabelName}

if (!$label) {
    Write-Host "✗ Label not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available labels:" -ForegroundColor Yellow
    Get-Label | Select-Object DisplayName | Format-Table -AutoSize
    Disconnect-ExchangeOnline
    exit 1
}

Write-Host "✓ Found label: $($label.DisplayName)" -ForegroundColor Green
Write-Host "  Label ID: $($label.Guid)" -ForegroundColor Gray

# ========================================
# STEP 2: Find all policies using this label
# ========================================

Write-Host ""
Write-Host "STEP 2: Finding policies that publish this label..." -ForegroundColor Cyan

$allPolicies = Get-LabelPolicy
$policiesUsingLabel = @()

foreach ($policy in $allPolicies) {
    if ($policy.Labels -contains $label.Guid) {
        $policiesUsingLabel += $policy
        Write-Host "  Found: $($policy.Name)" -ForegroundColor Yellow
    }
}

if ($policiesUsingLabel.Count -eq 0) {
    Write-Host "✓ No policies are publishing this label" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Found $($policiesUsingLabel.Count) policy/policies using this label:" -ForegroundColor Yellow
    $policiesUsingLabel | Select-Object Name, ExchangeLocation | Format-Table -AutoSize
}

# ========================================
# STEP 3: Confirm deletion
# ========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "CONFIRMATION REQUIRED" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will:" -ForegroundColor White

if ($policiesUsingLabel.Count -gt 0) {
    Write-Host "  1. Delete $($policiesUsingLabel.Count) label policy/policies" -ForegroundColor Red
}
Write-Host "  2. Delete the label: $LabelName" -ForegroundColor Red
Write-Host ""
Write-Host "This action CANNOT be undone!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Type 'DELETE' to confirm (or anything else to cancel)"

if ($confirm -ne "DELETE") {
    Write-Host ""
    Write-Host "Cancelled by user" -ForegroundColor Yellow
    Disconnect-ExchangeOnline
    exit 0
}

# ========================================
# STEP 4: Delete policies
# ========================================

if ($policiesUsingLabel.Count -gt 0) {
    Write-Host ""
    Write-Host "STEP 4: Deleting label policies..." -ForegroundColor Cyan
    
    foreach ($policy in $policiesUsingLabel) {
        Write-Host ""
        Write-Host "  Deleting policy: $($policy.Name)" -ForegroundColor Yellow
        
        try {
            Remove-LabelPolicy -Identity $policy.Name -Confirm:$false
            Write-Host "  ✓ Policy deleted" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "Stopping - cannot proceed without removing policies" -ForegroundColor Red
            Disconnect-ExchangeOnline
            exit 1
        }
        
        Start-Sleep -Seconds 2
    }
} else {
    Write-Host ""
    Write-Host "STEP 4: No policies to delete" -ForegroundColor Gray
}

# ========================================
# STEP 5: Delete the label
# ========================================

Write-Host ""
Write-Host "STEP 5: Deleting label..." -ForegroundColor Cyan

try {
    Remove-Label -Identity $label.Guid -Confirm:$false
    Write-Host "✓ Label deleted successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Error deleting label: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Label is still in use somewhere" -ForegroundColor White
    Write-Host "  - Policy deletion hasn't propagated yet (wait 30 mins)" -ForegroundColor White
    Write-Host "  - Label has child labels (delete children first)" -ForegroundColor White
    Disconnect-ExchangeOnline
    exit 1
}

# ========================================
# VERIFICATION
# ========================================

Write-Host ""
Write-Host "STEP 6: Verifying deletion..." -ForegroundColor Cyan

$check = Get-Label | Where-Object {$_.DisplayName -eq $LabelName}

if ($check) {
    Write-Host "⚠️  Label still exists (may take time to fully delete)" -ForegroundColor Yellow
} else {
    Write-Host "✓ Label completely removed" -ForegroundColor Green
}

# ========================================
# SUMMARY
# ========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DELETION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Label deleted: $LabelName" -ForegroundColor Green
if ($policiesUsingLabel.Count -gt 0) {
    Write-Host "✅ Policies deleted: $($policiesUsingLabel.Count)" -ForegroundColor Green
}
Write-Host ""
Write-Host "You can now:" -ForegroundColor White
Write-Host "  1. Create a new label with the same name" -ForegroundColor Gray
Write-Host "  2. Or use a different configuration" -ForegroundColor Gray
Write-Host ""

# Cleanup
Disconnect-ExchangeOnline

Write-Host "Complete!" -ForegroundColor Green
Write-Host ""
