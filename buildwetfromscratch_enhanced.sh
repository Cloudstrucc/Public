#!/bin/bash

read -p "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]: " useJsonConfig
jsonConfig=""

if [[ $useJsonConfig =~ ^[Yy]$ ]]; then
    read -p "Enter the path to the JSON configuration file: " jsonFilePath
    if [ -f "$jsonFilePath" ]; then
        jsonConfig=$(jq -c '.' "$jsonFilePath")
    fi
elif [[ $useJsonConfig =~ ^[Hh]$ ]]; then
    # Display a brief description of how the JSON object should be created
    echo "JSON Configuration File Format:"
#     echo '{
#     "clientId": "<client id>",
#     "tenantId": "<tenant id>",
#     "crmInstance": "<crm instance>",
#     "redirectUri": "https://login.onmicrosoft.com",
#     "websiteId": "<website id>",
#     "pageTemplateId": "<page template id>",
#     "publishingStateId": "<publishing state id>",
#     "homePageId": "<home page's webpage id value>",   
#     "blobAddress": "<blob address>"
# }'"
    # Exit the script
    exit
fi

# Define default values
declare -A defaultConfig=(
    ["clientId"]="<client id>"
    ["tenantId"]="<tenant id>"
    ["crmInstance"]="<crm instance>"
    ["redirectUri"]="https://login.onmicrosoft.com"
    ["websiteId"]="<website id>"
    ["pageTemplateId"]="<page template id>"
    ["publishingStateId"]="<publishing state id>"
    ["homePageId"]="<home page's webpage id value>"
    ["clientSecret"]="<client secret>"
    ["blobAddress"]="<blob address>"
)

# Use user-provided JSON or default values
if [ -n "$jsonConfig" ]; then
    config="$jsonConfig"
else
    config=""
    for key in "${!defaultConfig[@]}"; do
        read -p "Enter the value for $key (Default: ${defaultConfig[$key]}): " value
        if [ -z "$value" ]; then
            value="${defaultConfig[$key]}"
        fi
        config+="$key=$value"$'\n'
    done
fi

# Set the variables based on the configuration
clientId=$(echo "$config" | grep -oP '(?<=clientId=).*' | tr -d '\n\r')
tenantId=$(echo "$config" | grep -oP '(?<=tenantId=).*' | tr -d '\n\r')
authority="https://login.microsoftonline.com/$tenantId"
crmInstance=$(echo "$config" | grep -oP '(?<=crmInstance=).*' | tr -d '\n\r')
resource="https://$crmInstance.api.crm3.dynamics.com"
redirectUri=$(echo "$config" | grep -oP '(?<=redirectUri=).*' | tr -d '\n\r')
tokenEndpoint="$authority/oauth2/v2.0/token"
websiteId=$(echo "$config" | grep -oP '(?<=websiteId=).*' | tr -d '\n\r')
pageTemplateId=$(echo "$config" | grep -oP '(?<=pageTemplateId=).*' | tr -d '\n\r')
publishingStateId=$(echo "$config" | grep -oP '(?<=publishingStateId=).*' | tr -d '\n\r')
homePageId=$(echo "$config" | grep -oP '(?<=homePageId=).*' | tr -d '\n\r')
clientSecret=$(echo "$config" | grep -oP '(?<=clientSecret=).*' | tr -d '\n\r')
blobAddress=$(echo "$config" | grep -oP '(?<=blobAddress=).*' | tr -d '\n\r')

# Prepare the body for the token request
body="client_id=$clientId&scope=$resource/.default&grant_type=client_credentials&redirect_uri=$redirectUri&client_secret=$clientSecret"
# Acquire the token
authResponse=$(curl -s -X POST -d "$body" -H "Content-Type: application/x-www-form-urlencoded" "$tokenEndpoint")
token=$(echo "$authResponse" | jq -r '.access_token')

# Set up the HTTP client headers
headers=(
    "Authorization: Bearer $token"
    "OData-MaxVersion: 4.0"
    "OData-Version: 4.0"
    "Accept: application/json"
    "Prefer: return=representation"
)

# Define the Dataverse API URL
apiUrl="$resource/api/data/v9.2/"

# Function to create or update a web page
function CreateWebPage {
    local name=$1
    local parentPageId=$2
    
    # Logic to determine if this is the home page
    # Check the name or ID against known values for the home page
    local isHomePage=false
    if [ "$name" = "themes-dist-14.1.0-gcweb" ] || [ -z "$parentPageId" ]; then
        isHomePage=true
        echo "Page Name: $name, Parent Page ID: $parentPageId, Is Home Page: $isHomePage"
    fi

    local partialUrl=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    echo "Page Name: $name, Parent Page ID: $parentPageId, Is Home Page: $isHomePage"
    
    if [ "$isHomePage" = true ]; then
        echo "$homePageId"
        return
    fi

    # Include the website ID in the filter condition
    local filter="mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$websiteId'"

    if [ -n "$parentPageId" ]; then
        filter+=" and _mspp_parentpageid_value eq $parentPageId"
    fi

    local checkUrl="$apiUrl/mspp_webpages?\$filter=$filter"
    
    echo "Checking URL: $checkUrl"  # Debugging statement
    existingPage=$(curl -s -H "${headers[@]}" "$checkUrl" | jq -r '.value[0]')

    local webPageJson='{
        "mspp_name": "'"$name"'",
        "mspp_partialurl": "'"$partialUrl"'",
        "mspp_parentpageid@odata.bind": "/mspp_webpages($parentPageId)",
        "mspp_pagetemplateid@odata.bind": "/mspp_pagetemplates($pageTemplateId)",
        "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
        "mspp_publishingstateid@odata.bind": "/mspp_publishingstates($publishingStateId)"
    }'

    if [ -n "$parentPageId" ]; then
        webPageJson=$(echo "$webPageJson" | jq -c '.mspp_parentpageid@odata.bind = "/mspp_webpages($parentPageId)"')
    fi

    echo "Checking URL: $checkUrl"  # Debugging statement

    if [ -n "$existingPage" ]; then
        echo "Web page already exists. Updating existing page."
        updateUrl="$apiUrl/mspp_webpages/$(echo "$existingPage" | jq -r '.mspp_webpageid')"
        curl -s -X PATCH -d "$webPageJson" -H "${headers[@]}" -H "Content-Type: application/json; charset=utf-8" "$updateUrl"
        echo "$(echo "$existingPage" | jq -r '.mspp_webpageid')"
    else
        try {
            webPageResponse=$(curl -s -X POST -d "$webPageJson" -H "${headers[@]}" -H "Content-Type: application/json; charset=utf-8" "$apiUrl/mspp_webpages")
            newWebPage=$(echo "$webPageResponse" | jq -r '.mspp_webpageid')
            echo "$newWebPage"
        } catch {
            echo "API call failed with $_.Exception.Message"
        }
    fi
}


# Function to create or update a web file with the parent web page ID
function CreateWebFile {
    local filePath=$1
    local parentPageId=$2

    fileName=$(basename "$filePath")
    partialUrl=$(echo "$fileName" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    mimeType=$(file -b --mime-type "$filePath")
    fileContent=$(base64 -w 0 "$filePath")
    relativePath=$(realpath --relative-to="$extractionPath/themes-dist-14.1.0-gcweb" "$filePath")

    # Construct the blob storage URL
    blobUrl="$blobAddress$relativePath$partialUrl"

    filter="mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$websiteId'"

    if [ -n "$parentPageId" ]; then
        filter+=" and _mspp_parentpageid_value eq $parentPageId"
    fi

    checkUrl="$apiUrl/mspp_webfiles?\$filter=$filter"
    existingFiles=$(curl -s -H "${headers[@]}" "$checkUrl")

    webFile='{
        "mspp_name": "'"$fileName"'",
        "mspp_partialurl": "'"$partialUrl"'",
        "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
        "mspp_publishingstateid@odata.bind": "/mspp_publishingstates($publishingStateId)"
    }'

    if [ -n "$parentPageId" ]; then
        webFile=$(echo "$webFile" | jq -c '.mspp_parentpageid@odata.bind = "/mspp_webpages($parentPageId)"')
    fi

    webFileJson=$(echo "$webFile" | jq -c '.')

    if [ "${existingFiles['value']}" ]; then
        echo "Web file already exists: $filePath"
        existingFile=$(echo "${existingFiles['value'][0]}")
        updateUrl="$apiUrl/mspp_webfiles/$(echo "$existingFile" | jq -r '.mspp_webfileid')"
        curl -s -X PATCH -d "$webFileJson" -H "${headers[@]}" -H "Content-Type: application/json; charset=utf-8" "$updateUrl"
        webFileId=$(echo "$existingFile" | jq -r '.mspp_webfileid')
    else
        webFileResponse=$(curl -s -X POST -d "$webFileJson" -H "${headers[@]}" -H "Content-Type: application/json; charset=utf-8" "$apiUrl/mspp_webfiles")
        webFileId=$(echo "$webFileResponse" | jq -r '.mspp_webfileid')

        if [ -z "$webFileId" ]; then
            echo "Failed to create web file for $fileName"
            return
        fi
    fi

    existingRow=$(curl -s -H "${headers[@]}" "$apiUrl/powerpagecomponents/$webFileId")

    echo "File Name: $(echo "$existingRow" | jq -r '.name')"
    existingRow=$(echo "$existingRow" | jq -c '. + {"filecontent": "'"$fileContent"'"}')

    # Set this to the url, of your automation, which places the file
    apiUrl="https://prod-16.canadacentral.logic.azure.com:443/workflows/d0266af9e24b457e81d042e204f1c990/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=cnCrDBP18LAb40X3H7E_dtydKWbGK9GpdL0tK68_z8s"

    curl -s -X POST -d "$existingRow" -H "Content-Type: application/json; charset=utf-8" "$apiUrl"
}

function Get-RelativePath {
    local basePath=$1
    local targetPath=$2

    basePath=$(realpath "$basePath")
    targetPath=$(realpath "$targetPath")

    if [[ $targetPath == $basePath* ]]; then
        relativePath=${targetPath#$basePath}
        echo "${relativePath#/}"
    else
        echo "$targetPath"
    fi
}

# Function to process folder and create webpages + webfiles
function WriteHierarchy {
    local path=$1
    local indent=$2
    local parentPageId=$3

    items=$(find "$path" -mindepth 1)

    for item in $items; do
        if [ ! -d "$item" ]; then
            #Process files
            
            if [ -z "$parentPageId" ]; then
                parentPageId=$homePageId
            fi
            echo "IS NOT FOLDER + $parentPageId + $item"
            CreateWebFile "$item" "$parentPageId" 
                   
        else
            # Process directories
            echo "IS FOLDER + $parentPageId + $item"
            newPageId=$(CreateWebPage "$(basename "$item")" "$parentPageId")

            WriteHierarchy "$item" "  $indent" "$newPageId"
        fi
    done
}

# Extract the zip file & runtime script calls
zipFilePath="C:/themes-dist-14.1.0-gcweb.zip"
extractionPath="/mnt/c/Users/Fred/source/repos/pub/Public/files/themes-dist-14.1.0-gcweb" 
unzip -o "$zipFilePath" -d "$extractionPath"

# Start processing the extracted folder
echo "$extractionPath"
WriteHierarchy "$extractionPath" "" "$homePageId"
