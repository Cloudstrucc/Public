# Connecting to the Dataverse Web API using PowerShell with an App Registration involves several steps. You'll need to:

#     Register an App in Azure AD to get the necessary client ID and client secret.
#     Grant the App appropriate permissions to access your Dataverse environment.
#     Use PowerShell to obtain an access token from Azure AD and make requests to the Dataverse Web API.

# Step 1: Register an App in Azure AD

#     Go to the Azure Portal.
#     Navigate to Azure Active Directory → App registrations → New registration.
#     Enter a name for your application, and set the redirect URI (it can be Web and http://localhost if you're just testing).
#     After the app is registered, note down the Application (client) ID.
#     Under "Certificates & secrets", create a new client secret and note it down.

# Step 2: Grant Appropriate Permissions

#     In the Azure portal, go to your App Registration.
#     Navigate to API permissions → Add a permission → APIs my organization uses.
#     Find "Dynamics CRM" (the Dataverse Web API) and add permissions. The exact permissions will depend on what you need (e.g., user_impersonation).
#     Grant admin consent for these permissions.

# Step 3: Use PowerShell to Connect to the Web API

# You'll use PowerShell to get an OAuth2 token from Azure AD and then use this token to make requests to the Dataverse Web API.

# Here is the baseline PowerShell script which tests your connection

$TenantId = "<Your_Tenant_Id>"
$ClientId = "<Your_Client_Id>"
$ClientSecret = "<Your_Client_Secret>"
$Resource = "https://<Your_Dataverse_Environment>.crm.dynamics.com"  # Replace with your environment URL
$Scope = "https://<Your_Dataverse_Environment>.crm.dynamics.com/.default"  # Replace with your environment URL

# Body for token request
$Body = @{
    client_id     = $ClientId
    scope         = $Scope
    client_secret = $ClientSecret
    grant_type    = "client_credentials"
    resource      = $Resource
}

# Acquire the token
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" -Method Post -Body $Body

# Use token in the Authorization header
$Headers = @{
    Authorization = "Bearer $($TokenResponse.access_token)"
}

# Making a request to the Web API
$ApiUrl = "<Dataverse_API_Endpoint>"  # Replace with the specific API endpoint
$Response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method Get

# Output the response
$Response

# Important Notes:

#     Security: Be very careful with how you store and handle your client secret. In a production environment, use secure methods like Azure Key Vault.
#     Permissions: Ensure that the app has been granted the necessary permissions and that admin consent has been given for those permissions.
#     URLs: The resource and scope URLs should match your Dataverse environment.
#     Error Handling: Add appropriate error handling for production-ready scripts.

# This script provides a basic framework for connecting to the Dataverse Web API using PowerShell with Azure AD app registration. You can expand upon this script to perform more complex operations as required by your application.