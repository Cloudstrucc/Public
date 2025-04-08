// ImportSolution.cs
using Microsoft.Crm.Sdk.Messages;
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;
using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

namespace PowerPlatformSolutionImporter
{
    class SolutionInfo
    {
        public string SolutionName { get; set; } = string.Empty;
        public string SolutionFilePath { get; set; } = string.Empty;
        public string Branch { get; set; } = string.Empty;
        public string PrUrl { get; set; } = string.Empty;
    }
    
    class AppConfig
    {
        public string TargetEnvUrl { get; set; } = string.Empty;
        public string ClientId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public string TenantId { get; set; } = string.Empty;
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
                        TargetEnvUrl = Environment.GetEnvironmentVariable("TARGET_ENV_URL") ?? "",
                        ClientId = Environment.GetEnvironmentVariable("CLIENT_ID") ?? "",
                        ClientSecret = Environment.GetEnvironmentVariable("CLIENT_SECRET") ?? "",
                        TenantId = Environment.GetEnvironmentVariable("TENANT_ID") ?? ""
                    };
                    
                    Console.WriteLine("Configuration loaded from environment variables.");
                }
                
                // Validate configuration
                if (string.IsNullOrEmpty(config.TargetEnvUrl) || 
                    string.IsNullOrEmpty(config.ClientId) || 
                    string.IsNullOrEmpty(config.ClientSecret))
                {
                    throw new Exception("Missing required configuration parameters");
                }
                
                // Load solution info
                Console.WriteLine("Loading solution info...");
                
                string solutionInfoPath = "solution-info.json";
                if (!File.Exists(solutionInfoPath))
                {
                    throw new Exception("Solution info file not found. Run the export tool first.");
                }
                
                string solutionInfoJson = File.ReadAllText(solutionInfoPath);
                var solutionInfo = JsonSerializer.Deserialize<SolutionInfo>(solutionInfoJson)
                    ?? throw new Exception("Failed to deserialize solution info");
                
                // Check if solution file exists
                if (!File.Exists(solutionInfo.SolutionFilePath))
                {
                    throw new Exception($"Solution file not found: {solutionInfo.SolutionFilePath}");
                }
                
                Console.WriteLine($"Solution: {solutionInfo.SolutionName}");
                Console.WriteLine($"File: {solutionInfo.SolutionFilePath}");
                Console.WriteLine($"Branch: {solutionInfo.Branch}");
                Console.WriteLine($"PR: {solutionInfo.PrUrl}");
                
                // Connect to target environment
                Console.WriteLine($"Connecting to target environment: {config.TargetEnvUrl}");
                var targetService = new ServiceClient(new Uri(config.TargetEnvUrl), config.ClientId, config.ClientSecret, true);
                
                if (!targetService.IsReady)
                {
                    Console.WriteLine($"Failed to connect to target environment: {targetService.LastError}");
                    return;
                }
                Console.WriteLine("Connected to target environment successfully.");
                
                // Import the solution
                Console.WriteLine("Starting solution import...");
                byte[] solutionBytes = File.ReadAllBytes(solutionInfo.SolutionFilePath);
                
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
                Console.WriteLine($"Solution: {solutionInfo.SolutionName}");
                Console.WriteLine($"Import Job ID: {importJobId}");
                
                // For Azure DevOps, set a variable to capture the import job ID
                Console.WriteLine($"##vso[task.setvariable variable=ImportJobId;]{importJobId}");
                
                Console.WriteLine("Solution import initiated successfully!");
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
                Console.WriteLine("##vso[task.logissue type=error]Solution import failed");
                Console.WriteLine("##vso[task.complete result=Failed;]");
                Environment.Exit(1);
            }
        }
    }
}