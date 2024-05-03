#!/bin/bash

read -p "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]: " useJsonConfig
jsonConfig=""

if [[ $useJsonConfig == "Y" || $useJsonConfig == "y" ]]; then
    read -p "Enter the path to the JSON configuration file: " jsonFilePath
    if [ -f "$jsonFilePath" ]; then
        jsonConfig=$(jq '.' "$jsonFilePath")
    fi
elif [[ $useJsonConfig == "H" || $useJsonConfig == "h" ]]; then
    # Display a brief description of how the JSON object should be created
    echo "JSON Configuration File Format:"
    echo '{
    "clientId": "<client id>",
    "tenantId": "<tenant id>",
    "crmInstance": "<crm instance>",
    "redirectUri": "https://login.onmicrosoft.com",
    "websiteId": "<website id>",
    "pageTemplateId": "<page template id>",
    "publishingStateId": "<publishing state id>",
    "homePageId": "<home page'\''s webpage id value>",
    "clientSecret": "app registration client secret"
    }'

    # Exit the script
    exit
fi

# Define default values
defaultConfig='{
    "clientId": "<client id>",
    "tenantId": "<tenant id>",
    "crmInstance": "<crm instance>",
    "redirectUri": "https://login.onmicrosoft.com",
    "websiteId": "<website id>",
    "pageTemplateId": "<page template id>",
    "publishingStateId": "<publishing state id>",
    "homePageId": "<home page'\''s webpage id value>",
    "clientSecret": "SIf8Q~KwaXZdzgC0gBwELfF2rgHPq5TcW-bM-b9w"
}'

# Use user-provided JSON or default values
if [ ! -z "$jsonConfig" ]; then
    config="$jsonConfig"
else
    config="$defaultConfig"
    declare -A defaultConfigMap
    defaultConfigMap=(
        ["clientId"]="client id"
        ["tenantId"]="tenant id"
        ["crmInstance"]="crm instance"
        ["websiteId"]="website id"
        ["pageTemplateId"]="page template id"
        ["publishingStateId"]="publishing state id"
        ["homePageId"]="home page's webpage id value"
        ["clientSecret"]="app registration client secret"
    )

    for key in "${!defaultConfigMap[@]}"; do
        echo "Enter the value for ${defaultConfigMap[$key]} (Default: ${config[$key]}): "
        read value
        if [ -z "$value" ]; then
            config="$config"
        else
            config="${config//\"$key\": \"${config[$key]}\",\"$key\": \"$value\"}"
        fi
    done
fi

# Set the variables based on the configuration
clientId="${config['clientId']}"
tenantId="${config['tenantId']}"
authority="https://login.microsoftonline.com/$tenantId"
crmInstance="${config['crmInstance']}"
resource="https://$crmInstance.api.crm3.dynamics.com"
redirectUri="${config['redirectUri']}"
tokenEndpoint="$authority/oauth2/v2.0/token"
websiteId="${config['websiteId']}"
pageTemplateId="${config['pageTemplateId']}"
publishingStateId="${config['publishingStateId']}"
homePageId="${config['homePageId']}"
secret="${config['clientSecret']}"
blobAddress="${config['blobAddress']}"

# Prepare the body for the token request
body="{\"client_id\":\"$clientId\",\"scope\":\"$resource/.default\",\"grant_type\":\"client_credentials\",\"redirect_uri\":\"$redirectUri\",\"client_secret\":\"$secret\"}"

# Acquire the token
authResponse=$(curl -s -X POST -d "$body" -H "Content-Type: application/x-www-form-urlencoded" "$tokenEndpoint")
token=$(echo "$authResponse" | jq -r '.access_token')

# Set up the HTTP client headers
headers=("Authorization: Bearer $token" "OData-MaxVersion: 4.0" "OData-Version: 4.0" "Accept: application/json" "Prefer: return=representation")

# Define the Dataverse API URL
apiUrl="$resource/api/data/v9.2/"

# Function to create or update a web page
function CreateWebPage {
    name="$1"
    parentPageId="$2"
    
    # Logic to determine if this is the home page
    # Check the name or ID against known values for the home page
    isHomePage=false
    if [[ "$name" == "themes-dist-14.1.0-gcweb" || -z "$parentPageId" ]]; then
        isHomePage=true
    fi

    partialUrl=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    echo "Page Name: $name, Parent Page ID: $parentPageId, Is Home Page: $isHomePage"
    
    if $isHomePage; then
        return "$existingPage.mspp_webpageid"
    fi

    # Include the website ID in the filter condition
    filter="mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$websiteId'"

    if [ -n "$parentPageId" ]; then
        filter+=" and _mspp_parentpageid_value eq $parentPageId"
    fi

    checkUrl="$apiUrl/mspp_webpages?$filter=$filter"
    
    echo "Checking URL: $checkUrl"  # Debugging statement
    existingPages=$(curl -s -X GET -H "${headers[@]}" "$checkUrl")
    existingPage=$(echo "$existingPages" | jq '.value[0]')
    
    webPage="{\"mspp_name\":\"$name\",\"mspp_partialurl\":\"$partialUrl\",\"mspp_pagetemplateid@odata.bind\":\"/mspp_pagetemplates($pageTemplateId)\",\"mspp_websiteid@odata.bind\":\"/mspp_websites($websiteId)\",\"mspp_publishingstateid@odata.bind\":\"/mspp_publishingstates($publishingStateId)\"}"
    
    if [ -n "$parentPageId" ]; then
        webPage+=",\"mspp_parentpageid@odata.bind\":\"/mspp_webpages($parentPageId)\""
    fi
    
    echo "Checking URL: $checkUrl"  # Debugging statement
    webPageJson=$(echo "$webPage" | jq -c '.')
    
    if [ -n "$existingPage" ]; then
        echo "Web page already exists. Updating existing page."
        updateUrl="$apiUrl/mspp_webpages/${existingPage.mspp_webpageid}"
        curl -s -X PATCH -d "$webPageJson" -H "${headers[@]}" -H "Content-Type: application/json" "$updateUrl"
        return "$existingPage.mspp_webpageid"
    else
        newWebPage=$(curl -s -X POST -d "$webPageJson" -H "${headers[@]}" -H "Content-Type: application/json" "$apiUrl/mspp_webpages" | jq -r '.mspp_webpageid')
        return "$newWebPage"
    fi
}

# Function to create or update a web file with the parent web page ID
function CreateWebFile {
    filePath="$1"
    parentPageId="$2"

    fileName=$(basename "$filePath")
    partialUrl=$(echo "$fileName" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    mimeType=$(file --mime-type -b "$filePath")
    fileContent=$(base64 < "$filePath")
    relativePath=${filePath#$extractionPath/themes-dist-14.1.0-gcweb}

    # Construct the blob storage URL
    blobUrl="$blobAddress$relativePath$partialUrl"

    filter="mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$websiteId'"

    if [ -n "$parentPageId" ]; then
        filter+=" and _mspp_parentpageid_value eq $parentPageId"
    fi

    checkUrl="$apiUrl/mspp_webfiles?$filter=$filter"
    existingFiles=$(curl -s -X GET -H "${headers[@]}" "$checkUrl")

    webFile="{\"mspp_name\":\"$fileName\",\"mspp_partialurl\":\"$partialUrl\",\"mspp_websiteid@odata.bind\":\"/mspp_websites($websiteId)\",\"mspp_publishingstateid@odata.bind\":\"/mspp_publishingstates($publishingStateId)\",\"mspp_cloudblobaddress\":\"$blobUrl\"}"

    if [ -n "$parentPageId" ]; then
        webFile+=",\"mspp_parentpageid@odata.bind\":\"/mspp_webpages($parentPageId)\""
    fi

    webFileJson=$(echo "$webFile" | jq -c '.')
    
    if [ -n "$existingFiles" ]; then
        echo "Web file already exists: $filePath"
        existingFile=$(echo "$existingFiles" | jq '.value[0]')
        updateUrl="$apiUrl/mspp_webfiles/${existingFile.mspp_webfileid}"
        curl -s -X PATCH -d "$webFileJson" -H "${headers[@]}" -H "Content-Type: application/json" "$updateUrl"
        webFileId="${existingFile.mspp_webfileid}"
    else
        webFileResponse=$(curl -s -X POST -d "$webFileJson" -H "${headers[@]}" -H "Content-Type: application/json" "$apiUrl/mspp_webfiles")
        webFileId=$(echo "$webFileResponse" | jq -r '.mspp_webfileid')

        if [ -z "$webFileId" ]; then
            echo "Failed to create web file for $fileName"
            return
        fi
    fi

    annotationData="{\"objectid_mspp_webfile@odata.bind\":\"/mspp_webfiles($webFileId)\",\"subject\":\"Uploaded File\",\"filename\":\"$fileName\",\"mimetype\":\"$mimeType\",\"documentbody\":\"$fileContent\"}"
    
    # Invoke-RestMethod -Uri ($apiUrl + "annotations") -Method Post -Body ($annotationData | ConvertTo-Json -Depth 10) -Headers $headers -ContentType "application/json"
}

function Get-RelativePath {
    basePath="$1"
    targetPath="$2"

    basePath=$(realpath "$basePath")
    targetPath=$(realpath "$targetPath")

    if [[ "$targetPath" == "$basePath"* ]]; then
        relativePath=${targetPath#$basePath}
        if [[ "$relativePath" == /* ]]; then
            relativePath=${relativePath#"/"}
        fi
        echo "$relativePath" | tr '\' '/'
    else
        echo "$targetPath"
    fi
}

# Function to process folder and create webpages + webfiles
function WriteHierarchy {
    path="$1"
    indent="$2"
    parentPageId="$3"
    
    items=($(find "$path" -type f -o -type d))
    
    for item in "${items[@]}"; do
        if [ ! -d "$item" ]; then
            # Process files
            if [ -z "$parentPageId" ]; then
                parentPageId="$homePageId"
            fi
            CreateWebFile "$item" "$parentPageId"
        else
            # Process directories
            newPageId=$(CreateWebPage "$(basename "$item")" "$parentPageId")
            WriteHierarchy "$item" "  $indent" "$newPageId"
        fi
    done
}

# DeleteNonRootWebPages
# FetchSampleMsppWebFiles
# Call the function
# DeleteTodaysMsppWebFiles

# Extract the zip file & runtime script calls
zipFilePath="C:/Users/Fred/source/repos/pub/Public/files/themes-dist-14.1.0-gcweb.zip"
extractionPath="C:/Users/Fred/source/repos/pub/Public/files"
unzip "$zipFilePath" -d "$extractionPath"

# Start processing the extracted folder
echo "$extractionPath"
WriteHierarchy "$extractionPath/themes-dist-14.1.0-gcweb" "" ""
