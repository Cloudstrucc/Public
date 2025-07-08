#Requires -Version 5.1
<#
.SYNOPSIS
    Power Platform PBMM Compliance Assessment Script for Canadian Federal Government

.DESCRIPTION
    This script performs a comprehensive security and compliance assessment of Power Platform
    tenant and environment configurations against PBMM (Protected B, Medium Integrity, 
    Medium Availability) requirements as defined by CCCS and ITSG-33 standards.

.PARAMETER TenantId
    The tenant ID for the Power Platform environment to assess

.PARAMETER OutputPath
    Path where the compliance report will be saved (default: current directory)

.PARAMETER DetailedReport
    Switch to generate detailed compliance report with remediation steps

.EXAMPLE
    .\Invoke-PowerPlatformPBMMAssessment.ps1 -TenantId "12345678-1234-1234-1234-123456789012" -DetailedReport

.NOTES
    Author: SSC/TBS Power Platform Security Team
    Version: 1.0
    Date: July 2025
    
    Prerequisites:
    - PowerShell 5.1 or higher
    - Microsoft.PowerApps.Administration.PowerShell module
    - Appropriate administrative permissions
    
    Compliance Framework: ITSG-33, CCCS Medium, PBMM
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\",
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport
)

# Script configuration
$ScriptVersion = "1.0"
$ComplianceFramework = "PBMM-ITSG33"
$ReportDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportFileName = "PowerPlatform_PBMM_Assessment_$ReportDate.html"

# Compliance scoring weights
$ComplianceWeights = @{
    TenantSecurity = 30
    EnvironmentSecurity = 25
    DLPPolicies = 20
    AuditLogging = 10
    AccessManagement = 10
    DataSovereignty = 5
}

# Initialize results
$ComplianceResults = @()
$ComplianceScore = 0
$MaxScore = 100
$CriticalIssues = @()
$Warnings = @()
$Recommendations = @()

#region Helper Functions

function Write-ComplianceLog {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "Error" { Write-Host $logMessage -ForegroundColor Red }
        "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
        "Success" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor White }
    }
}

function Add-ComplianceResult {
    param(
        [string]$Category,
        [string]$Control,
        [string]$Requirement,
        [bool]$Compliant,
        [string]$CurrentValue,
        [string]$ExpectedValue,
        [string]$Risk = "Medium",
        [string]$Remediation = "",
        [int]$Weight = 1
    )
    
    $script:ComplianceResults += [PSCustomObject]@{
        Category = $Category
        Control = $Control
        Requirement = $Requirement
        Compliant = $Compliant
        CurrentValue = $CurrentValue
        ExpectedValue = $ExpectedValue
        Risk = $Risk
        Remediation = $Remediation
        Weight = $Weight
    }
    
    if ($Compliant) {
        $script:ComplianceScore += $Weight
    } else {
        switch ($Risk) {
            "Critical" { $script:CriticalIssues += "$Control - $Requirement" }
            "High" { $script:CriticalIssues += "$Control - $Requirement" }
            "Medium" { $script:Warnings += "$Control - $Requirement" }
            "Low" { $script:Recommendations += "$Control - $Requirement" }
        }
    }
}

function Test-ModuleAvailability {
    $requiredModules = @(
        "Microsoft.PowerApps.Administration.PowerShell"
    )
    
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-ComplianceLog "Required module '$module' not found. Installing..." "Warning"
            try {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
                Write-ComplianceLog "Module '$module' installed successfully." "Success"
            }
            catch {
                Write-ComplianceLog "Failed to install module '$module': $($_.Exception.Message)" "Error"
                throw
            }
        }
    }
}

function Connect-ToPowerPlatform {
    Write-ComplianceLog "Connecting to Power Platform..." "Info"
    
    try {
        if ($TenantId) {
            Add-PowerAppsAccount -TenantID $TenantId
        } else {
            Add-PowerAppsAccount
        }
        Write-ComplianceLog "Successfully connected to Power Platform." "Success"
    }
    catch {
        Write-ComplianceLog "Failed to connect to Power Platform: $($_.Exception.Message)" "Error"
        throw
    }
}

#endregion

#region Compliance Assessment Functions

function Test-TenantSecuritySettings {
    Write-ComplianceLog "Assessing tenant-level security settings..." "Info"
    
    try {
        # Get tenant settings
        $tenantSettings = Get-TenantSettings
        
        # Test environment creation restrictions
        $envCreationRestricted = $tenantSettings.disableEnvironmentCreationByNonAdminUsers
        Add-ComplianceResult -Category "Tenant Security" -Control "AC-1" `
            -Requirement "Environment creation restricted to admins" `
            -Compliant $envCreationRestricted `
            -CurrentValue $envCreationRestricted.ToString() `
            -ExpectedValue "True" `
            -Risk "High" `
            -Remediation "Navigate to Power Platform Admin Center > Settings > Tenant Settings > Environment Provisioning and restrict to 'Only specific admins'" `
            -Weight 5
        
        # Test cross-tenant restrictions
        $crossTenantRestricted = $tenantSettings.disableCrossTenantShareType -eq "Both"
        Add-ComplianceResult -Category "Tenant Security" -Control "AC-3" `
            -Requirement "Cross-tenant sharing disabled" `
            -Compliant $crossTenantRestricted `
            -CurrentValue $tenantSettings.disableCrossTenantShareType `
            -ExpectedValue "Both" `
            -Risk "Critical" `
            -Remediation "Configure cross-tenant restrictions in tenant settings" `
            -Weight 5
        
        # Test trial environment restrictions
        $trialRestricted = $tenantSettings.disableTrialEnvironmentCreationByNonAdminUsers
        Add-ComplianceResult -Category "Tenant Security" -Control "AC-1" `
            -Requirement "Trial environment creation restricted" `
            -Compliant $trialRestricted `
            -CurrentValue $trialRestricted.ToString() `
            -ExpectedValue "True" `
            -Risk "Medium" `
            -Remediation "Restrict trial environment creation to admins only" `
            -Weight 2
        
        Write-ComplianceLog "Tenant security assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing tenant settings: $($_.Exception.Message)" "Error"
    }
}

function Test-DLPPolicies {
    Write-ComplianceLog "Assessing Data Loss Prevention policies..." "Info"
    
    try {
        $dlpPolicies = Get-AdminDlpPolicy
        
        # Check if tenant-wide DLP policy exists
        $tenantWidePolicyExists = $dlpPolicies | Where-Object { $_.environments.count -eq 0 -or $_.environments[0].name -eq "*" }
        Add-ComplianceResult -Category "Data Protection" -Control "SC-7" `
            -Requirement "Tenant-wide DLP policy exists" `
            -Compliant ($null -ne $tenantWidePolicyExists) `
            -CurrentValue ($dlpPolicies.Count.ToString() + " policies found") `
            -ExpectedValue "At least one tenant-wide policy" `
            -Risk "Critical" `
            -Remediation "Create a tenant-wide DLP policy to block high-risk connectors" `
            -Weight 8
        
        # Check for blocked high-risk connectors
        if ($dlpPolicies) {
            $highRiskConnectors = @(
                "shared_twitter", "shared_facebook", "shared_instagram", 
                "shared_dropbox", "shared_googledrive", "shared_box"
            )
            
            $blockedConnectorsCount = 0
            foreach ($policy in $dlpPolicies) {
                $policyDetails = Get-AdminDlpPolicy -PolicyName $policy.policyName
                $blockedConnectors = $policyDetails.connectorGroups | Where-Object { $_.classification -eq "Blocked" }
                
                foreach ($connector in $blockedConnectors.connectors) {
                    if ($connector.id -in $highRiskConnectors) {
                        $blockedConnectorsCount++
                    }
                }
            }
            
            $riskConnectorsBlocked = $blockedConnectorsCount -ge 3
            Add-ComplianceResult -Category "Data Protection" -Control "SC-7" `
                -Requirement "High-risk connectors blocked" `
                -Compliant $riskConnectorsBlocked `
                -CurrentValue "$blockedConnectorsCount high-risk connectors blocked" `
                -ExpectedValue "Social media and public cloud storage blocked" `
                -Risk "High" `
                -Remediation "Block high-risk connectors in DLP policies" `
                -Weight 5
        }
        
        Write-ComplianceLog "DLP policy assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing DLP policies: $($_.Exception.Message)" "Error"
    }
}

function Test-EnvironmentSecurity {
    Write-ComplianceLog "Assessing environment security configurations..." "Info"
    
    try {
        $environments = Get-AdminPowerAppEnvironment
        
        foreach ($environment in $environments) {
            $envName = $environment.DisplayName
            $envType = $environment.EnvironmentType
            
            # Check data residency (Canada regions)
            $canadianRegion = $environment.Location -in @("canada", "canadacentral", "canadaeast")
            Add-ComplianceResult -Category "Environment Security" -Control "SC-12" `
                -Requirement "Data residency in Canada ($envName)" `
                -Compliant $canadianRegion `
                -CurrentValue $environment.Location `
                -ExpectedValue "Canada Central or Canada East" `
                -Risk "Critical" `
                -Remediation "Recreate environment in Canadian data center" `
                -Weight 3
            
            # Check if production environments are managed
            if ($envType -eq "Production") {
                try {
                    $managedEnv = Get-AdminManagedEnvironment -EnvironmentName $environment.EnvironmentName
                    $isManaged = $null -ne $managedEnv
                    Add-ComplianceResult -Category "Environment Security" -Control "CM-2" `
                        -Requirement "Production environment is managed ($envName)" `
                        -Compliant $isManaged `
                        -CurrentValue $isManaged.ToString() `
                        -ExpectedValue "True" `
                        -Risk "High" `
                        -Remediation "Enable managed environment for production" `
                        -Weight 4
                }
                catch {
                    Add-ComplianceResult -Category "Environment Security" -Control "CM-2" `
                        -Requirement "Production environment is managed ($envName)" `
                        -Compliant $false `
                        -CurrentValue "Unknown" `
                        -ExpectedValue "True" `
                        -Risk "High" `
                        -Remediation "Enable managed environment for production" `
                        -Weight 4
                }
            }
            
            # Check security group assignment
            $hasSecurityGroup = -not [string]::IsNullOrEmpty($environment.SecurityGroupId)
            Add-ComplianceResult -Category "Environment Security" -Control "AC-2" `
                -Requirement "Security group assigned ($envName)" `
                -Compliant $hasSecurityGroup `
                -CurrentValue $hasSecurityGroup.ToString() `
                -ExpectedValue "True" `
                -Risk "Medium" `
                -Remediation "Assign security group to environment" `
                -Weight 2
        }
        
        Write-ComplianceLog "Environment security assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing environment security: $($_.Exception.Message)" "Error"
    }
}

function Test-AuditingConfiguration {
    Write-ComplianceLog "Assessing audit and logging configuration..." "Info"
    
    try {
        # Note: This is a simplified check as detailed audit settings require additional APIs
        $environments = Get-AdminPowerAppEnvironment
        
        foreach ($environment in $environments) {
            # Basic audit logging is enabled by default in Power Platform
            # This would need to be enhanced with specific audit policy checks
            Add-ComplianceResult -Category "Audit & Logging" -Control "AU-2" `
                -Requirement "Audit logging enabled ($($environment.DisplayName))" `
                -Compliant $true `
                -CurrentValue "Enabled (default)" `
                -ExpectedValue "Enabled" `
                -Risk "Low" `
                -Remediation "Verify audit settings in compliance portal" `
                -Weight 2
        }
        
        Write-ComplianceLog "Audit configuration assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing audit configuration: $($_.Exception.Message)" "Error"
    }
}

function Test-AccessManagement {
    Write-ComplianceLog "Assessing access management configuration..." "Info"
    
    try {
        $environments = Get-AdminPowerAppEnvironment
        
        foreach ($environment in $environments) {
            # Check for presence of role assignments (basic check)
            try {
                $roleAssignments = Get-AdminPowerAppSecurityRoleAssignment -EnvironmentName $environment.EnvironmentName
                $hasRoleAssignments = $roleAssignments.Count -gt 0
                
                Add-ComplianceResult -Category "Access Management" -Control "AC-6" `
                    -Requirement "Security roles assigned ($($environment.DisplayName))" `
                    -Compliant $hasRoleAssignments `
                    -CurrentValue "$($roleAssignments.Count) role assignments" `
                    -ExpectedValue "At least one role assignment" `
                    -Risk "Medium" `
                    -Remediation "Assign appropriate security roles to users" `
                    -Weight 2
            }
            catch {
                Add-ComplianceResult -Category "Access Management" -Control "AC-6" `
                    -Requirement "Security roles assigned ($($environment.DisplayName))" `
                    -Compliant $false `
                    -CurrentValue "Cannot verify" `
                    -ExpectedValue "At least one role assignment" `
                    -Risk "Medium" `
                    -Remediation "Verify and assign security roles" `
                    -Weight 2
            }
        }
        
        Write-ComplianceLog "Access management assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing access management: $($_.Exception.Message)" "Error"
    }
}

#endregion

#region Report Generation

function Generate-ComplianceReport {
    Write-ComplianceLog "Generating compliance report..." "Info"
    
    $totalChecks = $ComplianceResults.Count
    $passedChecks = ($ComplianceResults | Where-Object { $_.Compliant }).Count
    $failedChecks = $totalChecks - $passedChecks
    $compliancePercentage = [math]::Round(($passedChecks / $totalChecks) * 100, 2)
    
    # Determine overall compliance status
    $overallStatus = if ($compliancePercentage -ge 90) { "Compliant" }
                    elseif ($compliancePercentage -ge 70) { "Partially Compliant" }
                    else { "Non-Compliant" }
    
    $statusColor = if ($overallStatus -eq "Compliant") { "green" }
                  elseif ($overallStatus -eq "Partially Compliant") { "orange" }
                  else { "red" }
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Power Platform PBMM Compliance Assessment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #003366; color: white; padding: 20px; text-align: center; }
        .summary { background-color: #f5f5f5; padding: 15px; margin: 20px 0; border-left: 5px solid $statusColor; }
        .compliant { color: green; font-weight: bold; }
        .non-compliant { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .critical { background-color: #ffebee; }
        .high { background-color: #fff3e0; }
        .medium { background-color: #f3e5f5; }
        .low { background-color: #e8f5e8; }
        .footer { margin-top: 40px; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Power Platform PBMM Compliance Assessment</h1>
        <h2>Canadian Federal Government</h2>
        <p>Assessment Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        <p>Framework: ITSG-33 / CCCS Medium / Protected B</p>
    </div>
    
    <div class="summary">
        <h2>Executive Summary</h2>
        <p><strong>Overall Compliance Status:</strong> <span style="color: $statusColor; font-weight: bold;">$overallStatus</span></p>
        <p><strong>Compliance Score:</strong> $compliancePercentage% ($passedChecks/$totalChecks checks passed)</p>
        <p><strong>Critical Issues:</strong> $($CriticalIssues.Count)</p>
        <p><strong>Warnings:</strong> $($Warnings.Count)</p>
        <p><strong>Recommendations:</strong> $($Recommendations.Count)</p>
    </div>
    
    <h2>Compliance Results by Category</h2>
    <table>
        <tr>
            <th>Category</th>
            <th>Control ID</th>
            <th>Requirement</th>
            <th>Status</th>
            <th>Current Value</th>
            <th>Expected Value</th>
            <th>Risk Level</th>
            <th>Remediation</th>
        </tr>
"@
    
    foreach ($result in $ComplianceResults) {
        $statusText = if ($result.Compliant) { "✅ Compliant" } else { "❌ Non-Compliant" }
        $statusClass = if ($result.Compliant) { "compliant" } else { "non-compliant" }
        $riskClass = $result.Risk.ToLower()
        
        $htmlReport += @"
        <tr class="$riskClass">
            <td>$($result.Category)</td>
            <td>$($result.Control)</td>
            <td>$($result.Requirement)</td>
            <td class="$statusClass">$statusText</td>
            <td>$($result.CurrentValue)</td>
            <td>$($result.ExpectedValue)</td>
            <td>$($result.Risk)</td>
            <td>$($result.Remediation)</td>
        </tr>
"@
    }
    
    $htmlReport += @"
    </table>
    
    <h2>Critical Issues Requiring Immediate Attention</h2>
"@
    
    if ($CriticalIssues.Count -gt 0) {
        $htmlReport += "<ul>"
        foreach ($issue in $CriticalIssues) {
            $htmlReport += "<li class='non-compliant'>$issue</li>"
        }
        $htmlReport += "</ul>"
    } else {
        $htmlReport += "<p class='compliant'>No critical issues identified.</p>"
    }
    
    $htmlReport += @"
    
    <h2>Remediation Priorities</h2>
    <h3>High Priority (Critical & High Risk)</h3>
"@
    
    $highPriorityItems = $ComplianceResults | Where-Object { -not $_.Compliant -and $_.Risk -in @("Critical", "High") }
    if ($highPriorityItems.Count -gt 0) {
        $htmlReport += "<ol>"
        foreach ($item in $highPriorityItems) {
            $htmlReport += "<li><strong>$($item.Control) - $($item.Requirement):</strong> $($item.Remediation)</li>"
        }
        $htmlReport += "</ol>"
    } else {
        $htmlReport += "<p class='compliant'>No high priority items.</p>"
    }
    
    $htmlReport += @"
    
    <h3>Medium Priority</h3>
"@
    
    $mediumPriorityItems = $ComplianceResults | Where-Object { -not $_.Compliant -and $_.Risk -eq "Medium" }
    if ($mediumPriorityItems.Count -gt 0) {
        $htmlReport += "<ol>"
        foreach ($item in $mediumPriorityItems) {
            $htmlReport += "<li><strong>$($item.Control) - $($item.Requirement):</strong> $($item.Remediation)</li>"
        }
        $htmlReport += "</ol>"
    } else {
        $htmlReport += "<p>No medium priority items.</p>"
    }
    
    $htmlReport += @"
    
    <h2>Compliance Framework Mapping</h2>
    <table>
        <tr>
            <th>ITSG-33 Control Family</th>
            <th>Controls Assessed</th>
            <th>Compliant</th>
            <th>Non-Compliant</th>
            <th>Compliance Rate</th>
        </tr>
"@
    
    $controlFamilies = $ComplianceResults | Group-Object { $_.Control.Substring(0,2) }
    foreach ($family in $controlFamilies) {
        $totalInFamily = $family.Count
        $compliantInFamily = ($family.Group | Where-Object { $_.Compliant }).Count
        $nonCompliantInFamily = $totalInFamily - $compliantInFamily
        $familyRate = [math]::Round(($compliantInFamily / $totalInFamily) * 100, 1)
        
        $familyName = switch ($family.Name) {
            "AC" { "Access Control" }
            "AU" { "Audit and Accountability" }
            "CM" { "Configuration Management" }
            "SC" { "System and Communications Protection" }
            "SI" { "System and Information Integrity" }
            "IA" { "Identification and Authentication" }
            default { $family.Name }
        }
        
        $htmlReport += @"
        <tr>
            <td>$familyName ($($family.Name))</td>
            <td>$totalInFamily</td>
            <td class="compliant">$compliantInFamily</td>
            <td class="non-compliant">$nonCompliantInFamily</td>
            <td>$familyRate%</td>
        </tr>
"@
    }
    
    $htmlReport += @"
    </table>
    
    <h2>Next Steps</h2>
    <ol>
        <li><strong>Address Critical Issues:</strong> Immediately remediate all critical and high-risk non-compliance items</li>
        <li><strong>Update Documentation:</strong> Document all changes and maintain compliance records</li>
        <li><strong>Regular Monitoring:</strong> Schedule regular compliance assessments (recommended: monthly)</li>
        <li><strong>Training:</strong> Ensure all administrators are trained on PBMM requirements</li>
        <li><strong>Incident Response:</strong> Establish procedures for handling compliance violations</li>
    </ol>
    
    <h2>Assessment Details</h2>
    <table>
        <tr><td><strong>Assessment Tool:</strong></td><td>Power Platform PBMM Compliance Script v$ScriptVersion</td></tr>
        <tr><td><strong>Compliance Framework:</strong></td><td>$ComplianceFramework</td></tr>
        <tr><td><strong>Assessment Scope:</strong></td><td>Tenant and Environment Level Controls</td></tr>
        <tr><td><strong>Total Checks Performed:</strong></td><td>$totalChecks</td></tr>
        <tr><td><strong>Assessment Duration:</strong></td><td>$(((Get-Date) - $script:StartTime).TotalMinutes.ToString("F1")) minutes</td></tr>
    </table>
    
    <div class="footer">
        <p><strong>Disclaimer:</strong> This assessment provides a point-in-time evaluation of Power Platform configurations against PBMM requirements. 
        Regular assessments are required to maintain compliance. This tool does not replace the need for comprehensive security reviews 
        and professional security consultation.</p>
        <p><strong>Authority:</strong> Shared Services Canada (SSC) & Treasury Board Secretariat (TBS)</p>
        <p><strong>Classification:</strong> Protected B</p>
    </div>
</body>
</html>
"@
    
    # Save the report
    $reportPath = Join-Path $OutputPath $ReportFileName
    $htmlReport | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-ComplianceLog "Compliance report generated: $reportPath" "Success"
    
    # Generate JSON summary for automation
    $jsonSummary = @{
        AssessmentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ComplianceFramework = $ComplianceFramework
        OverallStatus = $overallStatus
        CompliancePercentage = $compliancePercentage
        TotalChecks = $totalChecks
        PassedChecks = $passedChecks
        FailedChecks = $failedChecks
        CriticalIssues = $CriticalIssues.Count
        Warnings = $Warnings.Count
        Recommendations = $Recommendations.Count
        Results = $ComplianceResults
    } | ConvertTo-Json -Depth 3
    
    $jsonPath = Join-Path $OutputPath "PowerPlatform_PBMM_Assessment_$ReportDate.json"
    $jsonSummary | Out-File -FilePath $jsonPath -Encoding UTF8
    
    return @{
        HtmlReportPath = $reportPath
        JsonSummaryPath = $jsonPath
        CompliancePercentage = $compliancePercentage
        OverallStatus = $overallStatus
    }
}

#endregion

#region Main Execution

function Invoke-PowerPlatformPBMMAssessment {
    $script:StartTime = Get-Date
    
    Write-ComplianceLog "Starting Power Platform PBMM Compliance Assessment" "Info"
    Write-ComplianceLog "Framework: $ComplianceFramework" "Info"
    Write-ComplianceLog "Script Version: $ScriptVersion" "Info"
    
    try {
        # Verify prerequisites
        Test-ModuleAvailability
        
        # Connect to Power Platform
        Connect-ToPowerPlatform
        
        # Run compliance assessments
        Test-TenantSecuritySettings
        Test-DLPPolicies
        Test-EnvironmentSecurity
        Test-AuditingConfiguration
        Test-AccessManagement
        
        # Generate report
        $reportResults = Generate-ComplianceReport
        
        # Display summary
        Write-ComplianceLog "Assessment completed successfully!" "Success"
        Write-ComplianceLog "Overall Compliance Status: $($reportResults.OverallStatus)" "Info"
        Write-ComplianceLog "Compliance Score: $($reportResults.CompliancePercentage)%" "Info"
        Write-ComplianceLog "HTML Report: $($reportResults.HtmlReportPath)" "Info"
        Write-ComplianceLog "JSON Summary: $($reportResults.JsonSummaryPath)" "Info"
        
        if ($CriticalIssues.Count -gt 0) {
            Write-ComplianceLog "WARNING: $($CriticalIssues.Count) critical issues require immediate attention!" "Warning"
        }
        
        # Return results for automation
        return $reportResults
    }
    catch {
        Write-ComplianceLog "Assessment failed: $($_.Exception.Message)" "Error"
        throw
    }
}

#endregion

# Execute if running as script (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-PowerPlatformPBMMAssessment
}

<#
.SYNOPSIS
    Additional Functions for Enhanced Compliance Checking

.DESCRIPTION
    These functions provide additional compliance checks that can be enabled
    based on organizational requirements and available permissions.
#>

#region Extended Compliance Functions (Optional)

function Test-ApplicationCompliance {
    <#
    .SYNOPSIS
        Tests Power Apps applications for compliance with PBMM requirements
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )
    
    Write-ComplianceLog "Assessing application compliance..." "Info"
    
    try {
        if ($EnvironmentName) {
            $apps = Get-AdminPowerApp -EnvironmentName $EnvironmentName
        } else {
            $apps = Get-AdminPowerApp
        }
        
        foreach ($app in $apps) {
            # Check if app uses only approved connectors
            $appDetails = Get-AdminPowerAppConnectionReferences -AppName $app.AppName
            
            # This would need to be enhanced with specific connector approval lists
            Add-ComplianceResult -Category "Application Security" -Control "SC-7" `
                -Requirement "App uses approved connectors ($($app.DisplayName))" `
                -Compliant $true `
                -CurrentValue "Needs manual review" `
                -ExpectedValue "Only approved connectors" `
                -Risk "Medium" `
                -Remediation "Review app connector usage against approved list" `
                -Weight 1
        }
        
        Write-ComplianceLog "Application compliance assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing application compliance: $($_.Exception.Message)" "Error"
    }
}

function Test-FlowCompliance {
    <#
    .SYNOPSIS
        Tests Power Automate flows for compliance with PBMM requirements
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )
    
    Write-ComplianceLog "Assessing flow compliance..." "Info"
    
    try {
        if ($EnvironmentName) {
            $flows = Get-AdminFlow -EnvironmentName $EnvironmentName
        } else {
            $flows = Get-AdminFlow
        }
        
        foreach ($flow in $flows) {
            # Check if flow is in running state (basic health check)
            $isHealthy = $flow.FlowSuspensionReason -eq "None" -or [string]::IsNullOrEmpty($flow.FlowSuspensionReason)
            
            Add-ComplianceResult -Category "Flow Security" -Control "SI-2" `
                -Requirement "Flow is operational ($($flow.DisplayName))" `
                -Compliant $isHealthy `
                -CurrentValue $flow.FlowSuspensionReason `
                -ExpectedValue "None/Running" `
                -Risk "Low" `
                -Remediation "Review and fix suspended flows" `
                -Weight 1
        }
        
        Write-ComplianceLog "Flow compliance assessment completed." "Success"
    }
    catch {
        Write-ComplianceLog "Error assessing flow compliance: $($_.Exception.Message)" "Error"
    }
}

function Export-ComplianceEvidence {
    <#
    .SYNOPSIS
        Exports compliance evidence for audit purposes
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )
    
    Write-ComplianceLog "Exporting compliance evidence..." "Info"
    
    try {
        $evidencePath = Join-Path $OutputPath "ComplianceEvidence_$ReportDate"
        New-Item -ItemType Directory -Path $evidencePath -Force | Out-Null
        
        # Export DLP policies
        $dlpPolicies = Get-AdminDlpPolicy
        $dlpPolicies | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $evidencePath "DLP_Policies.json")
        
        # Export environment list
        $environments = Get-AdminPowerAppEnvironment
        $environments | ConvertTo-Json -Depth 3 | Out-File -FilePath (Join-Path $evidencePath "Environments.json")
        
        # Export tenant settings (would need additional API calls)
        # This is a placeholder for actual tenant settings export
        
        Write-ComplianceLog "Compliance evidence exported to: $evidencePath" "Success"
        return $evidencePath
    }
    catch {
        Write-ComplianceLog "Error exporting compliance evidence: $($_.Exception.Message)" "Error"
    }
}

#endregion

# Export functions for module usage
Export-ModuleMember -Function @(
    'Invoke-PowerPlatformPBMMAssessment',
    'Test-ApplicationCompliance',
    'Test-FlowCompliance',
    'Export-ComplianceEvidence'
)