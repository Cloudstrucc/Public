# RemoveGitSecrets.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName,
    
    [Parameter(Mandatory=$true)]
    [string]$CommitHash,
    
    [Parameter(Mandatory=$false)]
    [string]$RemoteName = "origin"
)

# Error handling
$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Execute-GitCommand {
    param(
        [string]$Command,
        [bool]$AllowError = $false,
        [bool]$Silent = $false
    )
    if (-not $Silent) {
        Write-Host "`nExecuting: git $Command" -ForegroundColor Gray
    }
    
    # Split the command properly handling quotes
    $splitCommand = ($Command -split ' (?=(?:[^"]|"[^"]*")*$)') | ForEach-Object { $_.Trim('"') }
    
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "git"
    $processInfo.Arguments = $splitCommand -join " "
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null

    $output = $process.StandardOutput.ReadToEnd()
    $error = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -ne 0 -and -not $AllowError) {
        Write-Host "Error executing git command. Exit code: $($process.ExitCode)" -ForegroundColor Red
        if ($error) {
            Write-Host "Error output: $error" -ForegroundColor Red
        }
        if ($output) {
            Write-Host "Standard output: $output" -ForegroundColor Yellow
        }
        exit $process.ExitCode
    }

    if ($output) { Write-Host $output }
    if ($error -and -not $Silent) { Write-Host $error -ForegroundColor Yellow }
    
    return $output
}

function Get-CurrentBranch {
    return (Execute-GitCommand "rev-parse --abbrev-ref HEAD" -Silent $true).Trim()
}

try {
    # Verify we're in a git repository
    Write-Status "Verifying Git repository"
    if (-not (Test-Path ".git")) {
        throw "Not a git repository. Please run this script from the root of your git repository."
    }

    # Verify commit hash exists
    Write-Status "Verifying commit hash"
    $commitExists = Execute-GitCommand "rev-parse --quiet --verify $CommitHash^{commit}" -Silent $true -AllowError $true
    if (-not $commitExists) {
        throw "Commit hash '$CommitHash' not found in repository"
    }

    # Stash any current changes
    Write-Status "Stashing current changes"
    $stashOutput = Execute-GitCommand "stash" -AllowError $true
    $changesStashed = $stashOutput -notlike "*No local changes to save*"

    # Create backup branch
    Write-Status "Creating backup branch"
    $backupBranchName = "backup-$BranchName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Execute-GitCommand "branch $backupBranchName $BranchName"

    # Check and switch to target branch if necessary
    $currentBranch = Get-CurrentBranch
    if ($currentBranch -ne $BranchName) {
        Write-Status "Checking out target branch"
        Execute-GitCommand "checkout $BranchName"
    } else {
        Write-Status "Already on target branch '$BranchName'"
    }

    # Reset to commit before the one containing secrets
    Write-Status "Resetting to commit before secrets"
    Execute-GitCommand "reset --soft $CommitHash~1"

    # Temporarily move .gitignore
    Write-Status "Handling .gitignore"
    if (Test-Path ".gitignore") {
        Copy-Item ".gitignore" ".gitignore.backup"
        Remove-Item ".gitignore"
    }

    # Remove sensitive files from tracking
    Write-Status "Removing sensitive files from Git tracking"
    $sensitiveFiles = @(
        "Scripts/CustomTools/polymorphiclookupconfig-ec.json",
        "Scripts/GCWebTemplateInstallPowerPagesBlankSite/connectionparams.json"
    )

    foreach ($file in $sensitiveFiles) {
        if (Test-Path $file) {
            Execute-GitCommand "rm --cached `"$file`"" -AllowError $true
        }
    }

    # Create template files
    Write-Status "Creating template files"
    $templateContent = @"
{
    // Template structure - replace sensitive values with placeholders
    "connectionString": "YOUR_CONNECTION_STRING_HERE",
    "clientId": "YOUR_CLIENT_ID",
    "clientSecret": "YOUR_CLIENT_SECRET"
}
"@

    foreach ($file in $sensitiveFiles) {
        $directory = Split-Path $file
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        $templateContent | Out-File -FilePath $file -Encoding utf8 -Force
        Execute-GitCommand "add -f `"$file`""
    }

    # Commit template files
    Write-Status "Committing template files"
    $commitMessage = @"
Replace sensitive configuration with templates

- Remove Azure AD secrets from configuration files
- Add template files with placeholder values
- Update .gitignore to exclude actual configuration files
"@
    $commitMessage | Out-File -FilePath "commit_msg.tmp" -Encoding utf8
    Execute-GitCommand "commit -F commit_msg.tmp"
    Remove-Item "commit_msg.tmp"

    # Restore and update .gitignore
    Write-Status "Updating .gitignore"
    if (Test-Path ".gitignore.backup") {
        Copy-Item ".gitignore.backup" ".gitignore" -Force
        Remove-Item ".gitignore.backup"
    }
    
    $gitignoreContent = @"

# Sensitive configuration files
Scripts/CustomTools/polymorphiclookupconfig-ec.prod.json
Scripts/GCWebTemplateInstallPowerPagesBlankSite/connectionparams.prod.json
"@
    Add-Content .gitignore $gitignoreContent
    Execute-GitCommand "add .gitignore"
    Execute-GitCommand "commit -m `"Update .gitignore to exclude sensitive configuration files`""

    # Force push changes
    Write-Status "Force pushing changes"
    Execute-GitCommand "push --force-with-lease $RemoteName $BranchName"

    # Create production config files
    Write-Status "Creating production config files"
    foreach ($file in $sensitiveFiles) {
        $prodFile = $file.Replace(".json", ".prod.json")
        Copy-Item $file $prodFile -Force
    }

    # Pop stashed changes if we stashed them
    if ($changesStashed) {
        Write-Status "Restoring stashed changes"
        Execute-GitCommand "stash pop" -AllowError $true
    }

    Write-Host "`nScript completed successfully!" -ForegroundColor Green
    Write-Host "Backup branch created: $backupBranchName" -ForegroundColor Yellow
    Write-Host "Please update the .prod.json files with your actual configuration values." -ForegroundColor Yellow

} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    
    # Restore .gitignore if script fails
    if (Test-Path ".gitignore.backup") {
        Copy-Item ".gitignore.backup" ".gitignore" -Force
        Remove-Item ".gitignore.backup"
    }
    
    # Try to restore stashed changes if we stashed them
    if ($changesStashed) {
        Write-Status "Attempting to restore stashed changes"
        Execute-GitCommand "stash pop" -AllowError $true
    }
    
    exit 1
}