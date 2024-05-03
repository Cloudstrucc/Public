# Define your Dynamics 365 organization URL and credentials
$orgUrl = "https://yourorg.crm.dynamics.com"
$username = "yourusername"
$password = "yourpassword"

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Connect to Dynamics 365
Add-Type -TypeDefinition @"
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
"@

$httpClient = New-Object System.Net.Http.HttpClient
$httpClient.BaseAddress = New-Object System.Uri("$orgUrl/api/data/v9.1/")
$httpClient.DefaultRequestHeaders.Accept.Add("application/json")
$httpClient.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Basic", [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username:$securePassword")))

# Define a function to delete annotations
Function DeleteAnnotations($webfileId) {
    $annotationsUrl = "annotations"
    $annotationsQuery = "?`$filter=_objectid_value eq $webfileId and filename ne null&`$orderby=createdon desc"
    
    $response = $httpClient.GetAsync("$annotationsUrl$annotationsQuery").Result
    if ($response.IsSuccessStatusCode) {
        $annotations = $response.Content.ReadAsAsync([PSCustomObject[]]).Result

        # Keep track of the latest annotation with an attachment
        $latestAnnotationWithAttachment = $null

        # Loop through annotations and delete
        foreach ($annotation in $annotations) {
            if ($latestAnnotationWithAttachment -eq $null -and $annotation.filename -ne $null) {
                # Keep the first annotation with an attachment as the latest
                $latestAnnotationWithAttachment = $annotation
            } else {
                # Delete other annotations
                $annotationId = $annotation.annotationid
                $deleteResponse = $httpClient.DeleteAsync("$annotationsUrl($annotationId)").Result
                if ($deleteResponse.IsSuccessStatusCode) {
                    Write-Host "Deleted annotation with ID: $annotationId"
                } else {
                    Write-Host "Failed to delete annotation with ID: $annotationId"
                }
            }
        }
    } else {
        Write-Host "Failed to retrieve annotations for webfile with ID: $webfileId"
    }
}

# Query and delete annotations for each webfile
$webfilesUrl = "adx_webfiles"
$webfilesQuery = "?`$select=adx_webfileid"
$response = $httpClient.GetAsync("$webfilesUrl$webfilesQuery").Result

if ($response.IsSuccessStatusCode) {
    $webfiles = $response.Content.ReadAsAsync([PSCustomObject[]]).Result

    foreach ($webfile in $webfiles) {
        $webfileId = $webfile.adx_webfileid
        Write-Host "Processing webfile with ID: $webfileId"
        DeleteAnnotations $webfileId
    }
} else {
    Write-Host "Failed to retrieve webfiles"
}

# Clean up resources
$httpClient.Dispose()
