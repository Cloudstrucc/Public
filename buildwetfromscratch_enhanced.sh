#!/bin/bash

#####################################
# GC WET RELEASES: https://github.com/wet-boew/GCWeb/releases
#####################################

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
headers+=" OData-MaxVersion: 4.0 OData-Version: 4.0 Accept: application/json Prefer: return=representation"
updateHeaders="$headers If-Match: *"

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

get_publishing_state_id() {
  filter="mspp_name eq 'Published'"
  publishingStateQuery="${apiUrl}mspp_publishingstates?\$filter=$filter"
  publishingState=$(get_record "$publishingStateQuery")
  publishingStateId=$(echo "$publishingState" | jq -r '.value[0].mspp_publishingstateid')
  echo "$publishingStateId"
}

publishingStateId=$(get_publishing_state_id)

get_language_id() {
  languageCode=$1
  filter="mspp_lcid eq $languageCode"
  languageQuery="${apiUrl}mspp_websitelanguages?\$filter=$filter"
  language=$(get_record "$languageQuery")
  languageId=$(echo "$language" | jq -r '.value[0].mspp_websitelanguageid')
  echo "$languageId"
}

englishLanguageId=$(get_language_id "$englishLanguageCode")
frenchLanguageId=$(get_language_id "$frenchLanguageCode")

get_home_page_id() {
  filter="_mspp_websiteid_value eq '$websiteId' and mspp_isroot eq true and mspp_name eq 'Home'"
  homePageQuery="${apiUrl}mspp_webpages?\$filter=$filter"
  homePage=$(get_record "$homePageQuery")
  homePageId=$(echo "$homePage" | jq -r '.value[0].mspp_webpageid')
  echo "$homePageId"
}

homePageId=$(get_home_page_id)

get_home_content_page_id() {
  languageId=$1
  filter="_mspp_websiteid_value eq '$websiteId' and mspp_name eq 'Home' and _mspp_webpagelanguageid_value eq '$languageId'"
  homePageQuery="${apiUrl}mspp_webpages?\$filter=$filter"
  homePage=$(get_record "$homePageQuery")
  homeContentPageId=$(echo "$homePage" | jq -r '.value[0].mspp_webpageid')
  echo "$homeContentPageId"
}

homeContentPageEN=$(get_home_content_page_id "$englishLanguageId")
homeContentPageFR=$(get_home_content_page_id "$frenchLanguageId")

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

create_web_template() {
  markup=$1
  filename=$2

  htmlString=$markup

  webTemplatePayload=$(jq -n --arg filename "$filename" --arg websiteId "$websiteId" --arg htmlString "$htmlString" \
  '{
    mspp_name: $filename,
    "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
    mspp_source: $htmlString
  }')

  filter="mspp_name eq '$filename'"
  checkWebTemplateExists="${apiUrl}mspp_webtemplates?\$filter=$filter"
  existingTemplates=$(get_record "$checkWebTemplateExists")

  if [[ $(echo "$existingTemplates" | jq -r '.value | length') -gt 0 ]]; then
    existingTemplate=$(echo "$existingTemplates" | jq -r '.value[0]')
    if [[ -n "$existingTemplate" ]]; then
      updateUrl="${apiUrl}mspp_webtemplates(${existingTemplate.mspp_webtemplateid})"
      webTemplatePayloadUpdate=$(jq -n --arg htmlString "$htmlString" '{ mspp_source: $htmlString }')
      update_record "$updateUrl" "$webTemplatePayloadUpdate"
    fi
  else
    webresponse=$(create_record "${apiUrl}mspp_webtemplates" "$webTemplatePayload")
    wtid=$(echo "$webresponse" | jq -r '.mspp_webtemplateid')
    pageTemplatePayload=$(jq -n --arg filename "$filename" --arg websiteId "$websiteId" --arg wtid "$wtid" \
    '{
      mspp_name: $filename,
      mspp_type: "756150001",
      "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
      "mspp_webtemplateid@odata.bind": "/mspp_webtemplates($wtid)"
    }')
    create_record "${apiUrl}mspp_pagetemplates" "$pageTemplatePayload"
  fi
}

create_snippets() {
  snippetsJson=$(cat "$basePathSnippets" | jq -c '.')
  snippets=$(echo "$snippetsJson" | jq -r 'keys[] as $k | "\($k)=\(.[$k])"')

  for snippet in $snippets; do
    snippetName=$(echo "$snippet" | cut -d '=' -f 1)
    snippetContent=$(echo "$snippet" | cut -d '=' -f 2-)
    snippetContentEnglish=$(echo "$snippetContent" | jq -r '.[0]')
    snippetContentFrench=$(echo "$snippetContent" | jq -r '.[1]')

    snippetPayloadEnglish=$(jq -n --arg snippetName "$snippetName" --arg websiteId "$websiteId" --arg snippetContentEnglish "$snippetContentEnglish" --arg englishLanguageId "$englishLanguageId" \
    '{
      mspp_name: $snippetName,
      "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
      mspp_value: $snippetContentEnglish,
      "mspp_contentsnippetlanguageid@odata.bind": "/mspp_websitelanguages($englishLanguageId)"
    }')

    snippetPayloadFrench=$(jq -n --arg snippetName "$snippetName" --arg websiteId "$websiteId" --arg snippetContentFrench "$snippetContentFrench" --arg frenchLanguageId "$frenchLanguageId" \
    '{
      mspp_name: $snippetName,
      "mspp_websiteid@odata.bind": "/mspp_websites($websiteId)",
      mspp_value: $snippetContentFrench,
      "mspp_contentsnippetlanguageid@odata.bind": "/mspp_websitelanguages($frenchLanguageId)"
    }')

    filterEN="(mspp_name eq '$snippetName' and _mspp_contentsnippetlanguageid_value eq $englishLanguageId)"
    filterFR="(mspp_name eq '$snippetName' and _mspp_contentsnippetlanguageid_value eq $frenchLanguageId)"

    checkENSnippetExists="${apiUrl}mspp_contentsnippets?\$filter=$filterEN"
    existingENSnippets=$(get_record "$checkENSnippetExists")

    if [[ $(echo "$existingENSnippets" | jq -r '.value | length') -gt 0 ]]; then
      existingSnippet=$(echo "$existingENSnippets" | jq -r '.value[0]')
      if [[ -n "$existingSnippet" ]]; then
        updateUrl="${apiUrl}mspp_contentsnippets(${existingSnippet.mspp_contentsnippetid})"
        update_record "$updateUrl" "$snippetPayloadEnglish"
      fi
    else
      create_record "${apiUrl}mspp_contentsnippets" "$snippetPayloadEnglish"
      create_record "${apiUrl}mspp_contentsnippets" "$snippetPayloadFrench"
    fi

    checkFRSnippetExists="${apiUrl}mspp_contentsnippets?\$filter=$filterFR"
    existingFRSnippets=$(get_record "$checkFRSnippetExists")

    if [[ $(echo "$existingFRSnippets" | jq -r '.value | length') -gt 0 ]]; then
      existingSnippet=$(echo "$existingFRSnippets" | jq -r '.value[0]')
      if [[ -n "$existingSnippet" ]]; then
        updateUrl="${apiUrl}mspp_contentsnippets(${existingSnippet.mspp_contentsnippetid})"
        update_record "$updateUrl" "$snippetPayloadFrench"
      fi
    else
      create_record "${apiUrl}mspp_contentsnippets" "$snippetPayloadEnglish"
      create_record "${apiUrl}mspp_contentsnippets" "$snippetPayloadFrench"
    fi
  done
}

write_templates() {
  folderPath=$1
  indent=$2

  files=$(find "$folderPath" -type f)
  for file in $files; do
    html=$(cat "$file")
    create_web_template "$html" "$(basename "$file" .${file##*.})"
  done
}

update_home_page() {
  pageTemplateName=$1

  filter="mspp_name eq '$pageTemplateName'"
  checkPageTemplateExists="${apiUrl}mspp_pagetemplates?\$filter=$filter"
  existingTemplates=$(get_record "$checkPageTemplateExists")

  if [[ $(echo "$existingTemplates" | jq -r '.value | length') -gt 0 ]]; then
    existingTemplate=$(echo "$existingTemplates" | jq -r '.value[0]')
    pageTemplateId=$(echo "$existingTemplate" | jq -r '.mspp_pagetemplateid')

    updateUrl="${apiUrl}mspp_webpages(${homePageId})"
    webPagePayload=$(jq -n --arg pageTemplateId "$pageTemplateId" '{ "mspp_pagetemplateid@odata.bind": "/mspp_pagetemplates($pageTemplateId)" }')
    update_record "$updateUrl" "$webPagePayload"

    updateUrlContentEN="${apiUrl}mspp_webpages(${homeContentPageEN})"
    contentPagePayloadEN=$(jq -n '{ mspp_copy: "" }')
    update_record "$updateUrlContentEN" "$contentPagePayloadEN"

    updateUrlContentFR="${apiUrl}mspp_webpages(${homeContentPageFR})"
    contentPagePayloadFR=$(jq -n '{ mspp_copy: "" }')
    update_record "$updateUrlContentFR" "$contentPagePayloadFR"
  fi
}

run_portal_template_install() {
  # Uncomment the following line to extract the archive
  # unzip "$zipFilePath" -d "$extractionPath"
  create_snippets
  write_templates "$basePathTemplates"
  update_home_page "$pageTemplateNameNewHome"
  write_hierarchy "$extractionPath$themeRootFolderName + $homePageId"
  update_baseline_styles
}

run_portal_template_install
