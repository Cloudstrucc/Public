// ExportSolution.cs
using Microsoft.Crm.Sdk.Messages;
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.Diagnostics;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

namespace PowerPlatformSolutionExporter
{
    class AppConfig
    {
        public string SourceEnvUrl { get; set; } = string.Empty;
        public string TargetEnvUrl { get; set; } = string.Empty;
        public string ClientId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public string TenantId { get; set; } = string.Empty;
        public string SolutionName { get; set; } = string.Empty;
        public string GitRepoUrl { get; set; } = string.Empty;
        public string GitPat { get; set; } = string.Empty;
        public string GitUserEmail { get; set; } = string.Empty;
        public string GitUserName { get; set; } = string.Empty;
    }

    class Program
    {
        static async Task Main(string[] args)
        {
            try
            {
                // Load configuration
                Console.WriteLine("Loading configuration...");
                AppConfig config;
                
                string configPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "config.json");
                if (!File.Exists(configPath))
                {
                    configPath = "config.json"; // Try in current directory
                }
                
                if (File.Exists(configPath))
                {
                    string configJson = File.ReadAllText(configPath);
                    config = JsonSerializer.Deserialize<AppConfig>(configJson) 
                        ?? throw new Exception("Failed to deserialize configuration");
                    
                    Console.WriteLine("Configuration loaded from file.");
                }
                else
                {
                    // Use environment variables as fallback
                    config = new AppConfig
                    {
                        SourceEnvUrl = Environment.GetEnvironmentVariable("SOURCE_ENV_URL") ?? "",
                        TargetEnvUrl = Environment.GetEnvironmentVariable("TARGET_ENV_URL") ?? "",
                        ClientId = Environment.GetEnvironmentVariable("CLIENT_ID") ?? "",
                        ClientSecret = Environment.GetEnvironmentVariable("CLIENT_SECRET") ?? "",
                        TenantId = Environment.GetEnvironmentVariable("TENANT_ID") ?? "",
                        SolutionName = Environment.GetEnvironmentVariable("SOLUTION_NAME") ?? "",
                        GitRepoUrl = Environment.GetEnvironmentVariable("GIT_REPO_URL") ?? "",
                        GitPat = Environment.GetEnvironmentVariable("GIT_PAT") ?? "",
                        GitUserEmail = Environment.GetEnvironmentVariable("GIT_USER_EMAIL") ?? "",
                        GitUserName = Environment.GetEnvironmentVariable("GIT_USER_NAME") ?? ""
                    };
                    
                    Console.WriteLine("Configuration loaded from environment variables.");
                }
                
                // Validate configuration
                if (string.IsNullOrEmpty(config.SourceEnvUrl) || 
                    string.IsNullOrEmpty(config.ClientId) || 
                    string.IsNullOrEmpty(config.ClientSecret) ||
                    string.IsNullOrEmpty(config.GitRepoUrl) ||
                    string.IsNullOrEmpty(config.GitPat))
                {
                    throw new Exception("Missing required configuration parameters");
                }
                
                // Get solution name from args if not in config
                string solutionName = config.SolutionName;
                if (string.IsNullOrEmpty(solutionName) && args.Length > 0)
                {
                    solutionName = args[0];
                }
                
                if (string.IsNullOrEmpty(solutionName))
                {
                    Console.Write("Enter the name of the solution to export: ");
                    solutionName = Console.ReadLine() ?? "";
                    
                    if (string.IsNullOrEmpty(solutionName))
                    {
                        Console.WriteLine("Solution name cannot be empty.");
                        return;
                    }
                }
                else
                {
                    Console.WriteLine($"Using solution name from configuration: {solutionName}");
                }

                // Create output directories
                string outputDir = "./exports";
                string unpackDir = "./unpacked";
                Directory.CreateDirectory(outputDir);
                Directory.CreateDirectory(unpackDir);

                // Connect to source environment
                Console.WriteLine($"Connecting to source environment: {config.SourceEnvUrl}");
                var sourceService = new ServiceClient(new Uri(config.SourceEnvUrl), config.ClientId, config.ClientSecret, true);
                
                if (!sourceService.IsReady)
                {
                    Console.WriteLine($"Failed to connect to source environment: {sourceService.LastError}");
                    return;
                }
                Console.WriteLine("Connected to source environment successfully.");
                
                // Retrieve the solution
                Console.WriteLine($"Retrieving solution '{solutionName}'...");
                var query = new QueryExpression("solution")
                {
                    ColumnSet = new ColumnSet("uniquename", "friendlyname", "solutionid", "version"),
                    Criteria = new FilterExpression
                    {
                        Conditions = 
                        {
                            new ConditionExpression("uniquename", ConditionOperator.Equal, solutionName)
                        }
                    }
                };
                
                var solutions = sourceService.RetrieveMultiple(query).Entities;
                
                if (solutions.Count == 0)
                {
                    Console.WriteLine($"Solution '{solutionName}' not found.");
                    return;
                }
                
                // Get the solution
                var selectedSolution = solutions[0];
                var solutionId = selectedSolution.Id;
                var uniqueName = selectedSolution["uniquename"].ToString() ?? "";
                var friendlyName = selectedSolution["friendlyname"].ToString() ?? "";
                var versionStr = selectedSolution["version"].ToString() ?? "1.0.0.0";

                Console.WriteLine($"Found solution: {uniqueName} ({friendlyName}) v{versionStr}");
                
                // Check if solution has patches
                var patchQuery = new QueryExpression("solution")
                {
                    ColumnSet = new ColumnSet("uniquename", "friendlyname", "solutionid", "version"),
                    Criteria = new FilterExpression
                    {
                        Conditions = 
                        {
                            new ConditionExpression("uniquename", ConditionOperator.BeginsWith, $"{uniqueName}_Patch_")
                        }
                    }
                };
                
                var patches = sourceService.RetrieveMultiple(patchQuery).Entities;
                Console.WriteLine($"Found {patches.Count} patches for this solution.");
                
                string exportedSolutionFilePath = "";
                string exportedSolutionName = "";
                
                if (patches.Count > 0)
                {
                    Console.WriteLine("Patches:");
                    foreach (var patch in patches)
                    {
                        Console.WriteLine($"- {patch["uniquename"]} ({patch["friendlyname"]}) v{patch["version"]}");
                    }
                    
                    // Find the highest version among all solutions and patches
                    Version highestVersion = new Version(versionStr);
                    foreach (var patch in patches)
                    {
                        string patchVersionStr = patch["version"].ToString() ?? "1.0.0.0";
                        Version patchVersion = new Version(patchVersionStr);
                        if (patchVersion > highestVersion)
                            highestVersion = patchVersion;
                    }
                    
                    // Increment the SECOND integer in the version (Minor)
                    Version newVersion = new Version(
                        highestVersion.Major,
                        highestVersion.Minor + 1,
                        0,  // Reset build to 0
                        0   // Reset revision to 0
                    );
                    string incrementedVersion = newVersion.ToString();
                    
                    Console.WriteLine($"Using incremented version for clone: {incrementedVersion}");
                    
                    // Create a clone to include patches
                    Console.WriteLine("Creating a solution clone to include patches...");
                    
                    // Generate a unique name for the clone
                    string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                    string cloneName = $"{uniqueName}_WithPatches_{timestamp}";
                    string cloneDisplayName = $"{friendlyName} With Patches {DateTime.Now.ToString("yyyy-MM-dd")}";
                    
                    // Create the CloneAsSolution request
                    var cloneRequest = new CloneAsSolutionRequest
                    {
                        DisplayName = cloneDisplayName,
                        ParentSolutionUniqueName = uniqueName,
                        VersionNumber = incrementedVersion
                    };
                    
                    var cloneResponse = (CloneAsSolutionResponse)sourceService.Execute(cloneRequest);
                    string clonedSolutionId = cloneResponse.SolutionId.ToString();
                    
                    Console.WriteLine($"Created clone solution with ID: {clonedSolutionId}");
                    
                    // Get the unique name of the cloned solution
                    var clonedSolution = sourceService.Retrieve("solution", cloneResponse.SolutionId, new ColumnSet("uniquename"));
                    string clonedUniqueName = clonedSolution["uniquename"].ToString() ?? "";
                    
                    Console.WriteLine($"Cloned solution unique name: {clonedUniqueName}");
                    
                    // Export the cloned solution (managed)
                    var exportRequest = new ExportSolutionRequest
                    {
                        SolutionName = clonedUniqueName,
                        Managed = true  // Export as managed
                    };
                    
                    var exportResponse = (ExportSolutionResponse)sourceService.Execute(exportRequest);
                    
                    // Save the exported solution
                    exportedSolutionFilePath = Path.Combine(outputDir, $"{clonedUniqueName}_managed.zip");
                    File.WriteAllBytes(exportedSolutionFilePath, exportResponse.ExportSolutionFile);
                    exportedSolutionName = clonedUniqueName;
                    
                    Console.WriteLine($"Managed solution exported to: {exportedSolutionFilePath}");
                }
                else
                {
                    // Export the solution directly if no patches (managed)
                    var exportRequest = new ExportSolutionRequest
                    {
                        SolutionName = uniqueName,
                        Managed = true  // Export as managed
                    };
                    
                    var exportResponse = (ExportSolutionResponse)sourceService.Execute(exportRequest);
                    
                    // Save the exported solution
                    exportedSolutionFilePath = Path.Combine(outputDir, $"{uniqueName}_managed.zip");
                    File.WriteAllBytes(exportedSolutionFilePath, exportResponse.ExportSolutionFile);
                    exportedSolutionName = uniqueName;
                    
                    Console.WriteLine($"Managed solution exported to: {exportedSolutionFilePath}");
                }
                
                // Unpack the solution using SolutionPackager
                Console.WriteLine("Unpacking solution...");
                
                // Create a process to run SolutionPackager
                string solutionPackagerPath = "SolutionPackager.exe"; // Make sure this is in PATH or provide full path
                if (Environment.OSVersion.Platform == PlatformID.Unix || Environment.OSVersion.Platform == PlatformID.MacOSX)
                {
                    // Use dotnet pac for macOS/Linux
                    solutionPackagerPath = "pac";
                }
                
                ProcessStartInfo psi;
                if (Environment.OSVersion.Platform == PlatformID.Unix || Environment.OSVersion.Platform == PlatformID.MacOSX)
                {
                    // Use pac solution unpack command on macOS/Linux
                    psi = new ProcessStartInfo
                    {
                        FileName = solutionPackagerPath,
                        Arguments = $"solution unpack --zipfile \"{exportedSolutionFilePath}\" --folder \"{unpackDir}\" --packagetype Both",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    };
                }
                else
                {
                    // Use SolutionPackager.exe on Windows
                    psi = new ProcessStartInfo
                    {
                        FileName = solutionPackagerPath,
                        Arguments = $"/action:Extract /zipfile:\"{exportedSolutionFilePath}\" /folder:\"{unpackDir}\" /packagetype:Both",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    };
                }
                
                using (var process = Process.Start(psi))
                {
                    if (process == null)
                    {
                        throw new Exception("Failed to start solution unpacking process");
                    }
                    
                    string output = process.StandardOutput.ReadToEnd();
                    string error = process.StandardError.ReadToEnd();
                    
                    process.WaitForExit();
                    
                    if (process.ExitCode != 0)
                    {
                        Console.WriteLine("Error during solution unpacking:");
                        Console.WriteLine(error);
                        throw new Exception("Solution unpacking failed");
                    }
                    
                    Console.WriteLine("Solution unpacked successfully.");
                    Console.WriteLine(output);
                }
                
                // Create a branch and PR
                string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                string branchName = $"solution/{exportedSolutionName}_{timestamp}";
                
                // Set up git repository
                Console.WriteLine("Setting up Git repository...");
                
                // Create a credential helper for Git
                string gitCredentialHelperPath = Path.Combine(Path.GetTempPath(), "git-credential-helper.sh");
                File.WriteAllText(gitCredentialHelperPath, $@"#!/bin/bash
echo ""protocol=https
host=$(echo $1 | sed 's/https:\/\///' | sed 's/\/.*//')
username={config.GitUserName}
password={config.GitPat}
""
");
                
                // Make the script executable
                ProcessStartInfo chmodPsi = new ProcessStartInfo
                {
                    FileName = "chmod",
                    Arguments = $"+x {gitCredentialHelperPath}",
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                
                using (var chmodProcess = Process.Start(chmodPsi))
                {
                    chmodProcess?.WaitForExit();
                }
                
                // Clone the repository
                Console.WriteLine($"Cloning repository: {config.GitRepoUrl}");
                string repoDir = "./repo";
                Directory.CreateDirectory(repoDir);
                
                var gitClonePsi = new ProcessStartInfo
                {
                    FileName = "git",
                    Arguments = $"clone {config.GitRepoUrl} {repoDir}",
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    EnvironmentVariables = 
                    {
                        { "GIT_ASKPASS", gitCredentialHelperPath }
                    }
                };
                
                using (var gitCloneProcess = Process.Start(gitClonePsi))
                {
                    if (gitCloneProcess == null)
                    {
                        throw new Exception("Failed to start git clone process");
                    }
                    
                    string output = gitCloneProcess.StandardOutput.ReadToEnd();
                    string error = gitCloneProcess.StandardError.ReadToEnd();
                    
                    gitCloneProcess.WaitForExit();
                    
                    if (gitCloneProcess.ExitCode != 0)
                    {
                        Console.WriteLine("Error during git clone:");
                        Console.WriteLine(error);
                        throw new Exception("Git clone failed");
                    }
                    
                    Console.WriteLine(output);
                }
                
                // Configure Git user
                ExecuteGitCommand(repoDir, $"config user.email \"{config.GitUserEmail}\"");
                ExecuteGitCommand(repoDir, $"config user.name \"{config.GitUserName}\"");
                
                // Create a new branch
                Console.WriteLine($"Creating branch: {branchName}");
                ExecuteGitCommand(repoDir, $"checkout -b {branchName}");
                
                // Copy unpacked solution to repo
                string solutionRepoDir = Path.Combine(repoDir, exportedSolutionName);
                if (Directory.Exists(solutionRepoDir))
                {
                    Directory.Delete(solutionRepoDir, true);
                }
                CopyDirectory(unpackDir, solutionRepoDir);
                
                // Add files to git
                Console.WriteLine("Adding files to git...");
                ExecuteGitCommand(repoDir, "add .");
                
                // Commit changes
                Console.WriteLine("Committing changes...");
                ExecuteGitCommand(repoDir, $"commit -m \"Update solution {exportedSolutionName} to version {versionStr}\"");
                
                // Push to remote
                Console.WriteLine("Pushing to remote...");
                var gitPushPsi = new ProcessStartInfo
                {
                    FileName = "git",
                    Arguments = $"push --set-upstream origin {branchName}",
                    WorkingDirectory = repoDir,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    EnvironmentVariables = 
                    {
                        { "GIT_ASKPASS", gitCredentialHelperPath }
                    }
                };
                
                using (var gitPushProcess = Process.Start(gitPushPsi))
                {
                    if (gitPushProcess == null)
                    {
                        throw new Exception("Failed to start git push process");
                    }
                    
                    string output = gitPushProcess.StandardOutput.ReadToEnd();
                    string error = gitPushProcess.StandardError.ReadToEnd();
                    
                    gitPushProcess.WaitForExit();
                    
                    if (gitPushProcess.ExitCode != 0)
                    {
                        Console.WriteLine("Error during git push:");
                        Console.WriteLine(error);
                        throw new Exception("Git push failed");
                    }
                    
                    Console.WriteLine(output);
                }
                
                // Create PR using GitHub CLI or Azure DevOps CLI
                // This varies based on your Git provider - this example uses GitHub CLI
                Console.WriteLine("Creating pull request...");
                var prTitle = $"Solution update: {exportedSolutionName} {versionStr}";
                var prDescription = $"This PR contains updates to {exportedSolutionName} solution exported from {config.SourceEnvUrl}.\n\nApprove this PR to deploy to {config.TargetEnvUrl}.";
                
                // Example using GitHub CLI
                // Install GitHub CLI in your pipeline if needed
                var createPrPsi = new ProcessStartInfo
                {
                    FileName = "gh",
                    Arguments = $"pr create --title \"{prTitle}\" --body \"{prDescription}\" --base main --head {branchName}",
                    WorkingDirectory = repoDir,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    EnvironmentVariables = 
                    {
                        { "GITHUB_TOKEN", config.GitPat }
                    }
                };
                
                string prUrl = "";
                using (var createPrProcess = Process.Start(createPrPsi))
                {
                    if (createPrProcess == null)
                    {
                        throw new Exception("Failed to start PR creation process");
                    }
                    
                    string output = createPrProcess.StandardOutput.ReadToEnd();
                    string error = createPrProcess.StandardError.ReadToEnd();
                    
                    createPrProcess.WaitForExit();
                    
                    if (createPrProcess.ExitCode != 0)
                    {
                        Console.WriteLine("Error during PR creation:");
                        Console.WriteLine(error);
                        throw new Exception("PR creation failed");
                    }
                    
                    Console.WriteLine(output);
                    prUrl = output.Trim();
                }
                
                // Save solution info for import task
                var solutionInfo = new
                {
                    SolutionName = exportedSolutionName,
                    SolutionFilePath = exportedSolutionFilePath,
                    Branch = branchName,
                    PrUrl = prUrl
                };
                
                string solutionInfoJson = JsonSerializer.Serialize(solutionInfo, new JsonSerializerOptions { WriteIndented = true });
                File.WriteAllText("solution-info.json", solutionInfoJson);
                
                // For Azure DevOps, set variables
                Console.WriteLine($"##vso[task.setvariable variable=SolutionName;isOutput=true]{exportedSolutionName}");
                Console.WriteLine($"##vso[task.setvariable variable=SolutionFilePath;isOutput=true]{exportedSolutionFilePath}");
                Console.WriteLine($"##vso[task.setvariable variable=Branch;isOutput=true]{branchName}");
                Console.WriteLine($"##vso[task.setvariable variable=PrUrl;isOutput=true]{prUrl}");
                
                Console.WriteLine("Solution export and PR creation completed successfully!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine(ex.StackTrace);
                
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"Inner Exception: {ex.InnerException.Message}");
                    Console.WriteLine(ex.InnerException.StackTrace);
                }
                
                // Set error flag for Azure DevOps
                Console.WriteLine("##vso[task.logissue type=error]Solution export failed");
                Console.WriteLine("##vso[task.complete result=Failed;]");
                Environment.Exit(1);
            }
        }
        
        // Helper method to execute git commands
        private static void ExecuteGitCommand(string workingDirectory, string arguments)
        {
            var psi = new ProcessStartInfo
            {
                FileName = "git",
                Arguments = arguments,
                WorkingDirectory = workingDirectory,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            
            using (var process = Process.Start(psi))
            {
                if (process == null)
                {
                    throw new Exception($"Failed to start git process for command: {arguments}");
                }
                
                string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();
                
                process.WaitForExit();
                
                if (process.ExitCode != 0)
                {
                    Console.WriteLine($"Error executing git {arguments}:");
                    Console.WriteLine(error);
                    throw new Exception($"Git command failed: {arguments}");
                }
            }
        }
        
        // Helper method to copy directory recursively
        private static void CopyDirectory(string sourceDir, string targetDir)
        {
            Directory.CreateDirectory(targetDir);
            
            foreach (var file in Directory.GetFiles(sourceDir))
            {
                string fileName = Path.GetFileName(file);
                string targetPath = Path.Combine(targetDir, fileName);
                File.Copy(file, targetPath, true);
            }
            
            foreach (var directory in Directory.GetDirectories(sourceDir))
            {
                string dirName = Path.GetFileName(directory);
                string targetPath = Path.Combine(targetDir, dirName);
                CopyDirectory(directory, targetPath);
            }
        }
    }
}