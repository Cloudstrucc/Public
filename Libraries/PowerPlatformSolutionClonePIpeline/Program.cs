using Microsoft.Crm.Sdk.Messages;
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.IO;
using System.Text.Json;
using System.Threading;

namespace PowerPlatformSolutionManager
{
    class AppConfig
    {
        public string SourceEnvUrl { get; set; } = string.Empty;
        public string TargetEnvUrl { get; set; } = string.Empty;
        public string ClientId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public string TenantId { get; set; } = string.Empty;
        public string SolutionName { get; set; } = string.Empty;
    }

    class Program
    {
        static void Main(string[] args)
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
                        SolutionName = Environment.GetEnvironmentVariable("SOLUTION_NAME") ?? ""
                    };
                    
                    Console.WriteLine("Configuration loaded from environment variables.");
                }
                
                // Validate configuration
                if (string.IsNullOrEmpty(config.SourceEnvUrl) || 
                    string.IsNullOrEmpty(config.TargetEnvUrl) || 
                    string.IsNullOrEmpty(config.ClientId) || 
                    string.IsNullOrEmpty(config.ClientSecret))
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

                // Ensure output directory exists
                string outputDir = "./exports";
                Directory.CreateDirectory(outputDir);

                // Connect to source environment
                Console.WriteLine($"Connecting to source environment: {config.SourceEnvUrl}");
                var sourceService = new ServiceClient(new Uri(config.SourceEnvUrl), config.ClientId, config.ClientSecret, true);
                
                if (!sourceService.IsReady)
                {
                    Console.WriteLine($"Failed to connect to source environment: {sourceService.LastError}");
                    return;
                }
                Console.WriteLine("Connected to source environment successfully.");

                // Connect to target environment
                Console.WriteLine($"Connecting to target environment: {config.TargetEnvUrl}");
                var targetService = new ServiceClient(new Uri(config.TargetEnvUrl), config.ClientId, config.ClientSecret, true);
                
                if (!targetService.IsReady)
                {
                    Console.WriteLine($"Failed to connect to target environment: {targetService.LastError}");
                    return;
                }
                Console.WriteLine("Connected to target environment successfully.");
                
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
                    
                    // Export the cloned solution
                    var exportRequest = new ExportSolutionRequest
                    {
                        SolutionName = clonedUniqueName,
                        Managed = false
                    };
                    
                    var exportResponse = (ExportSolutionResponse)sourceService.Execute(exportRequest);
                    
                    // Save the exported solution
                    exportedSolutionFilePath = Path.Combine(outputDir, $"{clonedUniqueName}.zip");
                    File.WriteAllBytes(exportedSolutionFilePath, exportResponse.ExportSolutionFile);
                    exportedSolutionName = clonedUniqueName;
                    
                    Console.WriteLine($"Solution exported to: {exportedSolutionFilePath}");
                }
                else
                {
                    // Export the solution directly if no patches
                    var exportRequest = new ExportSolutionRequest
                    {
                        SolutionName = uniqueName,
                        Managed = false
                    };
                    
                    var exportResponse = (ExportSolutionResponse)sourceService.Execute(exportRequest);
                    
                    // Save the exported solution
                    exportedSolutionFilePath = Path.Combine(outputDir, $"{uniqueName}.zip");
                    File.WriteAllBytes(exportedSolutionFilePath, exportResponse.ExportSolutionFile);
                    exportedSolutionName = uniqueName;
                    
                    Console.WriteLine($"Solution exported to: {exportedSolutionFilePath}");
                }
                
                // Import the solution to target environment (asynchronously)
                Console.WriteLine("Starting solution import...");
                byte[] solutionBytes = File.ReadAllBytes(exportedSolutionFilePath);
                
                // Generate a new import job ID
                Guid importJobId = Guid.NewGuid();
                
                // Create an asynchronous import request
                var importRequest = new ImportSolutionAsyncRequest
                {
                    CustomizationFile = solutionBytes,
                    OverwriteUnmanagedCustomizations = true,
                    PublishWorkflows = true,
                    ImportJobId = importJobId
                };
                
                // Execute the import async request
                targetService.Execute(importRequest);
                
                Console.WriteLine($"Import job started successfully with ID: {importJobId}");
                Console.WriteLine("The import will continue on the server even after this program exits.");
                Console.WriteLine("You can check the status in the Power Platform admin center.");
                Console.WriteLine($"Environment: {config.TargetEnvUrl}");
                Console.WriteLine($"Solution: {exportedSolutionName}");
                Console.WriteLine($"Import Job ID: {importJobId}");
                
                // For Azure DevOps, set a variable to capture the import job ID
                Console.WriteLine($"##vso[task.setvariable variable=ImportJobId;]{importJobId}");
                Console.WriteLine($"##vso[task.setvariable variable=ExportedSolutionName;]{exportedSolutionName}");
                
                Console.WriteLine("Operation completed successfully!");
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
                Console.WriteLine("##vso[task.logissue type=error]Solution migration failed");
                Console.WriteLine("##vso[task.complete result=Failed;]");
                Environment.Exit(1);
            }
        }
    }
}