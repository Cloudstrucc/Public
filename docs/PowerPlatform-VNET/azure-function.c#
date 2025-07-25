using System.Net;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

[FunctionName("InternalDnsLookup")]
public static async Task<IActionResult> Run([HttpTrigger] HttpRequest req)
{
    string hostname = req.Query["hostname"];
    
    try 
    {
        // This will use the VNet's internal DNS
        var hostEntry = await Dns.GetHostEntryAsync(hostname);
        var result = new
        {
            hostname = hostname,
            addresses = hostEntry.AddressList.Select(ip => ip.ToString()).ToArray(),
            timestamp = DateTime.UtcNow
        };
        
        return new OkObjectResult(result);
    }
    catch (Exception ex)
    {
        return new BadRequestObjectResult($"DNS lookup failed: {ex.Message}");
    }
}