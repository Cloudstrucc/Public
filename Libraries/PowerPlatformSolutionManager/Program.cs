using Microsoft.Crm.Sdk.Messages;
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Collections.Generic;

namespace PowerPlatformSolutionManager
{
    class Program
    {
        // Connection parameters
        private static readonly string SourceEnvUrl = "https://goc-wetv14.crm3.dynamics.com";
        private static readonly string TargetEnvUrl = "https://goc-theme-dev.crm3.dynamics.com";
        private static readonly string ClientId = "4ff994b1-9789-40e1-874c-50fc92007812";
        private static readonly string ClientSecret = "secret";
        private static readonly string OutputDir = "./exports";

        static void Main(string[] args)
        {
            try
            {
                // Ensure output directory exists
                Directory.CreateDirectory(OutputDir);

                // Connect to source environment
                Console.WriteLine("Connecting to source environment...");
                var sourceService = new ServiceClient(new Uri(SourceEnvUrl), ClientId, ClientSecret, true);
                
                if (!sourceService.IsReady)
                {
                    Console.WriteLine($"Failed to connect to source environment: {sourceService.LastError}");
                    return;
                }
                Console.WriteLine("Connected to source environment successfully.");

                // Connect to target environment
                Console.WriteLine("Connecting to target environment...");
                var targetService = new ServiceClient(new Uri(TargetEnvUrl), ClientId, ClientSecret, true);
                
                if (!targetService.IsReady)
                {
                    Console.WriteLine($"Failed to connect to target environment: {targetService.LastError}");
                    return;
                }
                Console.WriteLine("Connected to target environment successfully.");

                // Prompt for solution name
                Console.Write("Enter the name of the solution to export: ");
                string solutionName = Console.ReadLine() ?? "";
                
                if (string.IsNullOrEmpty(solutionName))
                {
                    Console.WriteLine("Solution name cannot be empty.");
                    return;
                }
                
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
                    exportedSolutionFilePath = Path.Combine(OutputDir, $"{clonedUniqueName}.zip");
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
                    exportedSolutionFilePath = Path.Combine(OutputDir, $"{uniqueName}.zip");
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
                Console.WriteLine($"Environment: {TargetEnvUrl}");
                Console.WriteLine($"Solution: {exportedSolutionName}");
                Console.WriteLine($"Import Job ID: {importJobId}");
                
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
            }
        }
    }
}