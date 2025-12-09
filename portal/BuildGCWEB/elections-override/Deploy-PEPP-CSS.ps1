<#
.SYNOPSIS
    Deploy PEPP Color Override CSS to Power Pages Dataverse environment

.DESCRIPTION
    This script creates or updates a Web File record in Dataverse with the PEPP color 
    override CSS file. It handles authentication, file upload, and publishing state management.

.PARAMETER Environment
    The Power Platform environment URL (e.g., https://orgname.crm3.dynamics.com)

.PARAMETER CSSFilePath
    Path to the pepp-color-override.css file

.PARAMETER WebsiteName
    Name of the Power Pages website (default: PEPP Portal)

.PARAMETER PartialURL
    The partial URL for the CSS file (default: /css/pepp-override.css)

.EXAMPLE
    .\Deploy-PEPP-CSS.ps1 -Environment "https://leonardocompany.crm3.dynamics.com" -CSSFilePath "C:\PEPP\pepp-color-override.css"

.NOTES
    Author: Leonardo Company - LCE M365 Security Team
    Date: December 9, 2024
    Requires: Microsoft.PowerApps.Administration.PowerShell, Microsoft.Xrm.Data.PowerShell
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Environment,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$CSSFilePath,
    
    [Parameter(Mandatory = $false)]
    [string]$WebsiteName = "PEPP Portal",
    
    [Parameter(Mandatory = $false)]
    [string]$PartialURL = "/css/pepp-override.css",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

#Requires -Version 5.1

# Script variables
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$script:LogFile = Join-Path $env:TEMP "PEPP-CSS-Deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

#region Helper Functions

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output with color
    switch ($Level) {
        'Info'    { Write-Host $logMessage -ForegroundColor Cyan }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
    }
    
    # File output
    Add-Content -Path $script:LogFile -Value $logMessage
}

function Test-RequiredModules {
    Write-Log "Checking required PowerShell modules..."
    
    $requiredModules = @(
        @{Name = 'Microsoft.Xrm.Data.PowerShell'; MinVersion = '2.8.0'}
    )
    
    $missingModules = @()
    
    foreach ($module in $requiredModules) {
        $installed = Get-Module -ListAvailable -Name $module.Name | 
            Where-Object { $_.Version -ge [version]$module.MinVersion }
        
        if (-not $installed) {
            $missingModules += $module.Name
            Write-Log "Module $($module.Name) (>= $($module.MinVersion)) is not installed" -Level Warning
        } else {
            Write-Log "Module $($module.Name) is installed (v$($installed[0].Version))" -Level Success
        }
    }
    
    if ($missingModules.Count -gt 0) {
        Write-Log "Installing missing modules..." -Level Warning
        foreach ($moduleName in $missingModules) {
            try {
                Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber
                Write-Log "Successfully installed $moduleName" -Level Success
            } catch {
                Write-Log "Failed to install $moduleName : $_" -Level Error
                throw "Required module installation failed"
            }
        }
    }
    
    # Import modules
    foreach ($module in $requiredModules) {
        Import-Module $module.Name -ErrorAction Stop
        Write-Log "Imported module $($module.Name)" -Level Success
    }
}

function Connect-DataverseEnvironment {
    param([string]$EnvironmentUrl)
    
    Write-Log "Connecting to Dataverse environment: $EnvironmentUrl"
    
    try {
        # Try interactive login
        $conn = Get-CrmConnection -InteractiveMode -ServerUrl $EnvironmentUrl
        
        if ($conn.IsReady) {
            Write-Log "Successfully connected to Dataverse" -Level Success
            return $conn
        } else {
            throw "Connection not ready"
        }
    } catch {
        Write-Log "Failed to connect to Dataverse: $_" -Level Error
        throw
    }
}

function Get-WebsiteRecord {
    param(
        [Parameter(Mandatory = $true)]
        $Connection,
        
        [Parameter(Mandatory = $true)]
        [string]$WebsiteName
    )
    
    Write-Log "Searching for website: $WebsiteName"
    
    $fetchXml = @"
<fetch top='1'>
  <entity name='adx_website'>
    <attribute name='adx_websiteid'/>
    <attribute name='adx_name'/>
    <filter>
      <condition attribute='adx_name' operator='eq' value='$WebsiteName'/>
    </filter>
  </entity>
</fetch>
"@
    
    try {
        $result = Get-CrmRecordsByFetch -conn $Connection -Fetch $fetchXml
        
        if ($result.CrmRecords.Count -eq 0) {
            Write-Log "Website '$WebsiteName' not found" -Level Error
            throw "Website not found"
        }
        
        $websiteId = $result.CrmRecords[0].adx_websiteid
        Write-Log "Found website with ID: $websiteId" -Level Success
        return $websiteId
    } catch {
        Write-Log "Error retrieving website record: $_" -Level Error
        throw
    }
}

function Get-PublishingState {
    param(
        [Parameter(Mandatory = $true)]
        $Connection,
        
        [Parameter(Mandatory = $true)]
        [string]$WebsiteId
    )
    
    Write-Log "Retrieving 'Published' publishing state..."
    
    $fetchXml = @"
<fetch top='1'>
  <entity name='adx_publishingstate'>
    <attribute name='adx_publishingstateid'/>
    <attribute name='adx_name'/>
    <filter>
      <condition attribute='adx_name' operator='eq' value='Published'/>
      <condition attribute='adx_websiteid' operator='eq' value='$WebsiteId'/>
    </filter>
  </entity>
</fetch>
"@
    
    try {
        $result = Get-CrmRecordsByFetch -conn $Connection -Fetch $fetchXml
        
        if ($result.CrmRecords.Count -eq 0) {
            Write-Log "Published state not found for website" -Level Warning
            return $null
        }
        
        $stateId = $result.CrmRecords[0].adx_publishingstateid
        Write-Log "Found Published state with ID: $stateId" -Level Success
        return $stateId
    } catch {
        Write-Log "Error retrieving publishing state: $_" -Level Error
        return $null
    }
}

function Get-ExistingWebFile {
    param(
        [Parameter(Mandatory = $true)]
        $Connection,
        
        [Parameter(Mandatory = $true)]
        [string]$PartialURL,
        
        [Parameter(Mandatory = $true)]
        [string]$WebsiteId
    )
    
    Write-Log "Checking for existing web file: $PartialURL"
    
    $fetchXml = @"
<fetch top='1'>
  <entity name='adx_webfile'>
    <attribute name='adx_webfileid'/>
    <attribute name='adx_name'/>
    <attribute name='adx_partialurl'/>
    <filter>
      <condition attribute='adx_partialurl' operator='eq' value='$PartialURL'/>
      <condition attribute='adx_websiteid' operator='eq' value='$WebsiteId'/>
    </filter>
  </entity>
</fetch>
"@
    
    try {
        $result = Get-CrmRecordsByFetch -conn $Connection -Fetch $fetchXml
        
        if ($result.CrmRecords.Count -gt 0) {
            $webFileId = $result.CrmRecords[0].adx_webfileid
            Write-Log "Found existing web file with ID: $webFileId" -Level Info
            return $webFileId
        } else {
            Write-Log "No existing web file found" -Level Info
            return $null
        }
    } catch {
        Write-Log "Error checking for existing web file: $_" -Level Error
        return $null
    }
}

function New-WebFileRecord {
    param(
        [Parameter(Mandatory = $true)]
        $Connection,
        
        [Parameter(Mandatory = $true)]
        [string]$PartialURL,
        
        [Parameter(Mandatory = $true)]
        [string]$WebsiteId,
        
        [Parameter(Mandatory = $false)]
        [string]$PublishingStateId
    )
    
    Write-Log "Creating new web file record..."
    
    $fileName = Split-Path $PartialURL -Leaf
    
    $fields = @{
        'adx_name' = "PEPP Color Override CSS"
        'adx_partialurl' = $PartialURL
        'adx_websiteid' = New-CrmEntityReference -EntityLogicalName 'adx_website' -Id $WebsiteId
        'adx_displayorder' = 100
    }
    
    if ($PublishingStateId) {
        $fields['adx_publishingstateid'] = New-CrmEntityReference -EntityLogicalName 'adx_publishingstate' -Id $PublishingStateId
    }
    
    try {
        $webFileId = New-CrmRecord -conn $Connection -EntityLogicalName 'adx_webfile' -Fields $fields
        Write-Log "Created web file with ID: $webFileId" -Level Success
        return $webFileId
    } catch {
        Write-Log "Error creating web file: $_" -Level Error
        throw
    }
}

function Update-WebFileRecord {
    param(
        [Parameter(Mandatory = $true)]
        $Connection,
        
        [Parameter(Mandatory = $true)]
        [string]$WebFileId,
        
        [Parameter(Mandatory = $false)]
        [string]$PublishingStateId
    )
    
    Write-Log "Updating existing web file record..."
    
    $fields = @{
        'adx_name' = "PEPP Color Override CSS"
    }
    
    if ($PublishingStateId) {
        $fields['adx_publishingstateid'] = New-CrmEntityReference -EntityLogicalName 'adx_publishingstate' -Id $PublishingStateId
    }
    
    try {
        Set-CrmRecord -conn $Connection -EntityLogicalName 'adx_webfile' -Id $WebFileId -Fields $fields
        Write-Log "Updated web file successfully" -Level Success
    } catch {
        Write-Log "Error updating web file: $_" -Level Error
        throw
    }
}

function Add-CSSFileAsNote {
    param(
        [Parameter(Mandatory = $true)]
        $Connection,
        
        [Parameter(Mandatory = $true)]
        [string]$WebFileId,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    Write-Log "Uploading CSS file as annotation..."
    
    $fileName = Split-Path $FilePath -Leaf
    $fileContent = [System.IO.File]::ReadAllBytes($FilePath)
    $base64Content = [System.Convert]::ToBase64String($fileContent)
    
    # Check for existing note
    $fetchXml = @"
<fetch top='1'>
  <entity name='annotation'>
    <attribute name='annotationid'/>
    <filter>
      <condition attribute='objectid' operator='eq' value='$WebFileId'/>
      <condition attribute='filename' operator='eq' value='$fileName'/>
    </filter>
    <order attribute='createdon' descending='true'/>
  </entity>
</fetch>
"@
    
    try {
        $existingNote = Get-CrmRecordsByFetch -conn $Connection -Fetch $fetchXml
        
        if ($existingNote.CrmRecords.Count -gt 0) {
            # Update existing note
            $noteId = $existingNote.CrmRecords[0].annotationid
            Write-Log "Updating existing annotation: $noteId" -Level Info
            
            $fields = @{
                'documentbody' = $base64Content
                'modifiedon' = (Get-Date).ToUniversalTime()
            }
            
            Set-CrmRecord -conn $Connection -EntityLogicalName 'annotation' -Id $noteId -Fields $fields
            Write-Log "Updated existing CSS file annotation" -Level Success
        } else {
            # Create new note
            $fields = @{
                'objectid' = New-CrmEntityReference -EntityLogicalName 'adx_webfile' -Id $WebFileId
                'objecttypecode' = 'adx_webfile'
                'subject' = "CSS File"
                'filename' = $fileName
                'documentbody' = $base64Content
                'mimetype' = 'text/css'
            }
            
            $noteId = New-CrmRecord -conn $Connection -EntityLogicalName 'annotation' -Fields $fields
            Write-Log "Created new annotation with ID: $noteId" -Level Success
        }
        
        return $true
    } catch {
        Write-Log "Error creating/updating annotation: $_" -Level Error
        throw
    }
}

function Get-FileHash {
    param([string]$FilePath)
    
    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash
}

#endregion

#region Main Script

Write-Log "========================================" -Level Info
Write-Log "PEPP Color Override CSS Deployment" -Level Info
Write-Log "========================================" -Level Info
Write-Log "Environment: $Environment" -Level Info
Write-Log "CSS File: $CSSFilePath" -Level Info
Write-Log "Partial URL: $PartialURL" -Level Info
Write-Log "Website: $WebsiteName" -Level Info
Write-Log "Log File: $script:LogFile" -Level Info
Write-Log "========================================" -Level Info

try {
    # Validate CSS file
    if (-not (Test-Path $CSSFilePath)) {
        throw "CSS file not found: $CSSFilePath"
    }
    
    $fileSize = (Get-Item $CSSFilePath).Length
    $fileHash = Get-FileHash $CSSFilePath
    Write-Log "CSS file size: $([math]::Round($fileSize/1KB, 2)) KB" -Level Info
    Write-Log "CSS file hash: $fileHash" -Level Info
    
    # Check modules
    Test-RequiredModules
    
    # Connect to Dataverse
    $connection = Connect-DataverseEnvironment -EnvironmentUrl $Environment
    
    # Get website record
    $websiteId = Get-WebsiteRecord -Connection $connection -WebsiteName $WebsiteName
    
    # Get publishing state
    $publishingStateId = Get-PublishingState -Connection $connection -WebsiteId $websiteId
    
    # Check for existing web file
    $existingWebFileId = Get-ExistingWebFile -Connection $connection -PartialURL $PartialURL -WebsiteId $websiteId
    
    if ($existingWebFileId) {
        if ($Force -or $PSCmdlet.ShouldContinue("Update existing web file?", "Existing File Found")) {
            # Update existing
            Update-WebFileRecord -Connection $connection -WebFileId $existingWebFileId -PublishingStateId $publishingStateId
            $webFileId = $existingWebFileId
        } else {
            Write-Log "Deployment cancelled by user" -Level Warning
            return
        }
    } else {
        # Create new
        $webFileId = New-WebFileRecord -Connection $connection -PartialURL $PartialURL -WebsiteId $websiteId -PublishingStateId $publishingStateId
    }
    
    # Upload CSS file
    if (-not $WhatIf) {
        Add-CSSFileAsNote -Connection $connection -WebFileId $webFileId -FilePath $CSSFilePath
    } else {
        Write-Log "[WHATIF] Would upload CSS file to annotation" -Level Info
    }
    
    Write-Log "========================================" -Level Success
    Write-Log "Deployment completed successfully!" -Level Success
    Write-Log "Web File ID: $webFileId" -Level Success
    Write-Log "Access URL: $PartialURL" -Level Success
    Write-Log "========================================" -Level Success
    
    # Next steps
    Write-Log ""
    Write-Log "Next Steps:" -Level Info
    Write-Log "1. Add CSS reference to your header template:" -Level Info
    Write-Log "   <link href='$PartialURL' rel='stylesheet'>" -Level Info
    Write-Log "2. Clear Power Pages cache" -Level Info
    Write-Log "3. Republish website if needed" -Level Info
    Write-Log "4. Test in browser with cache cleared (Ctrl+Shift+R)" -Level Info
    
} catch {
    Write-Log "========================================" -Level Error
    Write-Log "Deployment failed: $_" -Level Error
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level Error
    Write-Log "========================================" -Level Error
    
    Write-Host ""
    Write-Host "Check log file for details: $script:LogFile" -ForegroundColor Yellow
    
    exit 1
} finally {
    # Cleanup
    if ($connection) {
        Write-Log "Closing Dataverse connection..." -Level Info
    }
}

Write-Host ""
Write-Host "Log file saved to: $script:LogFile" -ForegroundColor Cyan

#endregion
