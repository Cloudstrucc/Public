#!/bin/bash

# Update the breadcrumbs web template & the language toggle
# GC WET RELEASES: https://github.com/wet-boew/GCWeb/releases

# Dataverse environment
# 1 Solution Installs
# Languages Packs
# System Settings -> email file size (100000), file restrictions (delete all, re-add post script)
# 2 Deploy website
# 3 add the french website language
# Set the connection parameters in a JSON file (to run the script with a JSON config rather than manually)
# Set the variables at the top of the buildwetfromscratch_enhanced.ps1 (to be updated)
# (optional) Update the web templates (and add new ones if needed), (Optional) set the snippets values for each language in the snippets JSON.
# Run the script 
# Go to power pages site and press Sync

basePath="/home/username/source/repos/pub/Public/"
basePathSnippets="${basePath}liquid/contentsnippets/snippets.json"
portalBasicThemePath="${basePath}portalbasictheme.css"
themePath="${basePath}theme.css"
bootstrapPath="${basePath}bootstrap.min.css"
faviconPath="${basePath}favicon.ico"
zipFilePath="/home/username/themes-dist-15.0.0-gcweb.zip"
extractionPath="${basePath}files/"
themeRootFolderName="themes-dist-15.0.0-gcweb"
basePathTemplates="${basePath}liquid/webtemplates"
pageTemplateNameNewHome="CS-Home-WET"
webTemplateHeader="CS-header"
webTemplateFooter="CS-footer"
englishLanguageCode=1033
frenchLanguageCode=1036

# Default configuration
defaultConfig='{
  "clientId": "<client id>",
  "tenantId": "<tenant id>",
  "crmInstance": "<crm instance>",
  "redirectUri": "https://login.onmicrosoft.com",
  "websiteId": "<website id>",
  "blobAddress": "<blob address>",
  "FlowURL": "<flow url>"
}'

# Read user input for JSON configuration file
read -p "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]: " useJsonConfig

jsonConfig=""

if [[ "$useJsonConfig" == "Y" || "$useJsonConfig" == "y" ]]; then
  read -p "Enter the path to the JSON configuration file: " jsonFilePath
  if [[ -f "$jsonFilePath" ]]; then
    jsonConfig=$(cat "$jsonFilePath")
  else
    echo "Invalid file path."
    exit 1
  fi
elif [[ "$useJsonConfig" == "H" || "$useJsonConfig" == "h" ]]; then
  echo "JSON Configuration File Format:"
  echo '{
    "clientId": "<client id>",
    "tenantId": "<tenant id>",
    "crmInstance": "<crm instance>",
    "redirectUri": "https://login.onmicrosoft.com",
    "websiteId": "<website id>",
    "blobAddress": "<blob address>",
    "FlowURL": "<flow URL>"
  }'
  exit 0
else
  jsonConfig="$defaultConfig"
fi

config=$(echo "$jsonConfig" | jq -r 'to_entries[] | .key + "=" + .value')
for entry in $config; do
  eval "$entry"
done

# Authentication
authority="https://login.microsoftonline.com/$tenantId"
resource="https://${crmInstance}.api.crm3.dynamics.com"
tokenEndpoint="$authority/oauth2/v2.0/token"

# Get token
response=$(curl -X POST "$tokenEndpoint" -d "client_id=$clientId&scope=${resource}/.default&grant_type=client_credentials&redirect_uri=$redirectUri&client_secret=$secret" -H "Content-Type: application/x-www-form-urlencoded")
token=$(echo "$response" | jq -r .access_token)

# Set headers
headers="Authorization: Bearer $token"
updateHeaders="Authorization: Bearer $token"
headers+=" OData-MaxVersion: 4.0 OData-Version: 4.0 Accept: application/json Prefer: return=representation"
updateHeaders+=" OData-MaxVersion: 4.0 OData-Version: 4.0 Accept: application/json Prefer: return=representation If-Match: *"

# Define the Dataverse API URL
apiUrl="${resource}/api/data/v9.2/"

# Functions
create_record() {
  url=$1
  body=$2
  curl -X POST "$url" -d "$body" -H "$headers" -H "Content-Type: application/json; charset=utf-8"
}

update_record() {
  url=$1
  body=$2
  curl -X PATCH "$url" -d "$body" -H "$updateHeaders" -H "Content-Type: application/json; charset=utf-8"
}

get_record() {
  url=$1
  curl -X GET "$url" -H "$headers"
}

get_page_template_id() {
  filter="_mspp_websiteid_value eq '$websiteId' and mspp_name eq 'Access Denied'"
  pageTemplateQuery="${apiUrl}mspp_pagetemplates?\$filter=$filter"
  pageTemplate=$(get_record "$pageTemplateQuery")
  pageTemplateId=$(echo "$pageTemplate" | jq -r '.value[0].mspp_pagetemplateid')
  echo "$pageTemplateId"
}

pageTemplateId=$(get_page_template_id)

# (Similar functions for other parts can be created following the above pattern)

# Example of creating a webpage
create_webpage() {
  name=$1
  parentPageId=$2
  partialUrl=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  webPage=$(jq -n --arg name "$name" --arg partialUrl "$partialUrl" --arg parentPageId "$parentPageId" --arg pageTemplateId "$pageTemplateId" --arg websiteId "$websiteId" --arg publishingStateId "$publishingStateId" \
  '{
    mspp_name: $name,
    mspp_partialurl: $partialUrl,
    "mspp_parentpageid@odata.bind": "/mspp_webpages($parentPageId)",
    "mspp_pagetemplateid@odata.bind": "/mspp_pagetemplates($pageTemplateId)",
    "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
    "mspp_publishingstateid@odata.bind": "/mspp_publishingstates($publishingStateId)"
  }')

  filter="mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$websiteId'"
  if [[ -n "$parentPageId" ]]; then
    filter+=" and _mspp_parentpageid_value eq $parentPageId"
  fi

  checkUrl="${apiUrl}mspp_webpages?\$filter=$filter"
  existingPages=$(get_record "$checkUrl")
  existingPage=$(echo "$existingPages" | jq -r '.value[0]')
  webPageJson=$(echo "$webPage" | jq -c '.')

  if [[ -n "$existingPage" ]]; then
    updateUrl="${apiUrl}mspp_webpages(${existingPage.mspp_webpageid})"
    update_record "$updateUrl" "$webPageJson"
  else
    create_record "${apiUrl}mspp_webpages" "$webPageJson"
  fi
}

# Create or update baseline styles
create_webfile() {
  filePath=$1
  parentPageId=$2

  fileName=$(basename "$filePath")
  partialUrl=$(echo "$fileName" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
  mimeType=$(file --mime-type -b "$filePath")
  fileContent=$(base64 "$filePath")
  relativePath=$(realpath --relative-to="$extractionPath/$themeRootFolderName" "$filePath")

  blobUrl="$blobAddress$relativePath$partialUrl"
  filter="mspp_partialurl eq '$partialUrl' and _mspp_websiteid_value eq '$websiteId'"
  if [[ -n "$parentPageId" ]]; then
    filter+=" and _mspp_parentpageid_value eq $parentPageId"
  fi

  checkUrl="${apiUrl}mspp_webfiles?\$filter=$filter"
  existingFiles=$(get_record "$checkUrl")

  webFile=$(jq -n --arg fileName "$fileName" --arg partialUrl "$partialUrl" --arg websiteId "$websiteId" --arg publishingStateId "$publishingStateId" --arg parentPageId "$parentPageId" \
  '{
    mspp_name: $fileName,
    mspp_partialurl: $partialUrl,
    "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
    "mspp_publishingstateid@odata.bind": "/mspp_publishingstates($publishingStateId)"
  }')

  webFileJson=$(echo "$webFile" | jq -c '.')

  if [[ $(echo "$existingFiles" | jq -r '.value | length') -gt 0 ]]; then
    existingFile=$(echo "$existingFiles" | jq -r '.value[0]')
    updateUrl="${apiUrl}mspp_webfiles(${existingFile.mspp_webfileid})"
    update_record "$updateUrl" "$webFileJson"
  else
    create_record "${apiUrl}mspp_webfiles" "$webFileJson"
  fi
}

# Process folder and create webpages + webfiles
write_hierarchy() {
  path=$1
  indent=$2
  parentPageId=$3

  items=$(find "$path" -maxdepth 1)
  for item in $items; do
    if [[ -f "$item" ]]; then
      if [[ -z "$parentPageId" ]]; then
        parentPageId=$homePageId
      fi
      create_webfile "$item" "$parentPageId"
    elif [[ -d "$item" ]]; then
      newPageId=$(create_webpage "$(basename "$item")" "$parentPageId")
      write_hierarchy "$item" "  $indent" "$newPageId"
    fi
  done
}

# Main function to run the script
run_portal_template_install() {
  # Uncomment the following line to extract the archive
  # unzip "$zipFilePath" -d "$extractionPath"
  create_snippets
  write_templates "$basePathTemplates"
  update_home_page "$pageTemplateNameNewHome"
  write_hierarchy "$extractionPath$themeRootFolderName" "" "$homePageId"
  update_baseline_styles
}

run_portal_template_install
