using System;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using HtmlAgilityPack;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Text;

class Program
{
    static async Task Main(string[] args)
    {
        string url = "https://moneypuck.com/data.htm";
        string htmlContent;
        
        try
        {
            string destinationFolder = Path.Combine(Environment.CurrentDirectory, "HockeyStats");
            Console.WriteLine($"Using destination folder: {destinationFolder}");

            if (!Directory.Exists(destinationFolder))
            {
                Directory.CreateDirectory(destinationFolder);
                Console.WriteLine($"Created directory: {destinationFolder}");
            }

            Console.WriteLine("\nFetching available files...");
            using (var client = new HttpClient())
            {
                htmlContent = await client.GetStringAsync(url);
            }
           
            var doc = new HtmlDocument();
            doc.LoadHtml(htmlContent);

            var linkNodes = doc.DocumentNode.SelectNodes("//a[@href]");

            if (linkNodes != null)
            {
                var zipFiles = linkNodes
                    .Select(node => new
                    {
                        Href = node.GetAttributeValue("href", ""),
                        Text = node.InnerText.Trim()
                    })
                    .Where(link => link.Href.Contains("shots") && link.Href.EndsWith(".zip"))
                    .Select(link => new
                    {
                        FileName = link.Href.Split('/').Last(),
                        FullText = link.Text,
                        Url = link.Href
                    })
                    .ToList();

                int totalFiles = zipFiles.Count;
                Console.WriteLine($"\nFound {totalFiles} files to process");
                Console.WriteLine("================================");

                List<string> extractedFolders = new List<string>();
                int processedFiles = 0;

                using (var httpClient = new HttpClient())
                {
                    foreach (var file in zipFiles)
                    {
                        processedFiles++;
                        string zipPath = Path.Combine(destinationFolder, file.FileName);
                        string progressPrefix = $"[{processedFiles}/{totalFiles}] ({(processedFiles * 100.0 / totalFiles):F1}%)";
                        
                        try
                        {
                            // Download
                            Console.WriteLine($"\n{progressPrefix} Downloading {file.FileName}...");
                            
                            var progress = new Progress<float>(percent =>
                            {
                                Console.Write($"\r{progressPrefix} Download progress: {percent:F1}%");
                            });

                            await DownloadFileWithProgressAsync(httpClient, file.Url, zipPath, progress);
                            Console.WriteLine($"\n{progressPrefix} Download complete: {file.FileName}");

                            // Extract
                            Console.WriteLine($"{progressPrefix} Extracting {file.FileName}...");
                            string extractPath = Path.Combine(destinationFolder, Path.GetFileNameWithoutExtension(file.FileName));
                            if (Directory.Exists(extractPath))
                            {
                                Directory.Delete(extractPath, true);
                            }
                            ZipFile.ExtractToDirectory(zipPath, extractPath);
                            extractedFolders.Add(extractPath);
                            Console.WriteLine($"{progressPrefix} Extracted to: {extractPath}");

                            // Delete ZIP file
                            File.Delete(zipPath);
                            Console.WriteLine($"{progressPrefix} Deleted ZIP file: {file.FileName}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"\n{progressPrefix} Error processing {file.FileName}: {ex.Message}");
                            Console.WriteLine($"{progressPrefix} Continuing with next file...");
                            continue;
                        }
                    }
                }

                Console.WriteLine("\n================================");
                Console.WriteLine($"Processing complete. Processed {processedFiles} of {totalFiles} files.");
                Console.WriteLine($"Files are located in: {destinationFolder}");

                // Merge CSV files after all downloads are complete
                if (extractedFolders.Any())
                {
                    Console.WriteLine("\nMerging CSV files...");
                    await MergeCsvFiles(extractedFolders, destinationFolder);
                }
            }
            else
            {
                Console.WriteLine("No links found in the HTML content.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"An error occurred: {ex.Message}");
        }

        Console.WriteLine("\nPress any key to exit...");
        Console.ReadKey();
    }

    private static async Task DownloadFileWithProgressAsync(HttpClient client, string url, string destinationPath, IProgress<float> progress)
    {
        using (var response = await client.GetAsync(url, HttpCompletionOption.ResponseHeadersRead))
        {
            response.EnsureSuccessStatusCode();
            var totalBytes = response.Content.Headers.ContentLength ?? -1L;
            var totalRead = 0L;

            using (var contentStream = await response.Content.ReadAsStreamAsync())
            using (var fileStream = new FileStream(destinationPath, FileMode.Create, FileAccess.Write, FileShare.None, 6291456, true))
            {
                var buffer = new byte[6291456]; // 6MB buffer size
                var isMoreToRead = true;

                do
                {
                    var read = await contentStream.ReadAsync(buffer, 0, buffer.Length);
                    if (read == 0)
                    {
                        isMoreToRead = false;
                    }
                    else
                    {
                        await fileStream.WriteAsync(buffer, 0, read);
                        totalRead += read;

                        if (totalBytes != -1L)
                        {
                            var progressPercentage = (float)totalRead * 100 / totalBytes;
                            progress.Report(progressPercentage);
                        }
                    }
                }
                while (isMoreToRead);
            }
        }
    }

    private static async Task MergeCsvFiles(List<string> extractedFolders, string destinationFolder)
    {
        try
        {
            string masterFileName = "merged_shots_data.csv";
            string masterFilePath = Path.Combine(destinationFolder, masterFileName);
            bool isFirstFile = true;
            int totalRows = 0;

            using (var masterFile = new StreamWriter(masterFilePath, false, Encoding.UTF8))
            {
                foreach (var folder in extractedFolders)
                {
                    var csvFiles = Directory.GetFiles(folder, "*.csv");
                    foreach (var csvFile in csvFiles)
                    {
                        Console.WriteLine($"Processing: {Path.GetFileName(csvFile)}");
                        string[] lines = await File.ReadAllLinesAsync(csvFile);

                        if (lines.Length > 0)
                        {
                            // Write header only from the first file
                            if (isFirstFile)
                            {
                                await masterFile.WriteLineAsync(lines[0]);
                                isFirstFile = false;
                            }

                            // Write data rows, skipping header for all files after the first
                            for (int i = (isFirstFile ? 1 : 1); i < lines.Length; i++)
                            {
                                await masterFile.WriteLineAsync(lines[i]);
                                totalRows++;

                                // Show progress every 100,000 rows
                                if (totalRows % 100000 == 0)
                                {
                                    Console.WriteLine($"Processed {totalRows:N0} rows...");
                                }
                            }
                        }
                    }
                }
            }

            Console.WriteLine($"\nCSV merge complete!");
            Console.WriteLine($"Total rows processed: {totalRows:N0}");
            Console.WriteLine($"Merged file location: {masterFilePath}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error merging CSV files: {ex.Message}");
        }
    }
}