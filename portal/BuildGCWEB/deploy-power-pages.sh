#!/bin/bash

#####################################
# Power Pages Deployment Script for Mac OS
# GC WET RELEASES: https://github.com/wet-boew/GCWeb/releases
#####################################

### TO DO ###
# UPDATE the breadcrumbs webtemplate & the language toggle
##############

#####################################
# PRE-REQUISITES BEFORE RUNNING THIS SCRIPT
# STEP 1: INSTALL A LANGUAGE PACK (E.G. FRENCH) AND UPDATE THE FRENCH_LANGUAGE_CODE VARIABLE BELOW
# STEP 2: ONCE THE LANGUAGE PACK IS INSTALLED, CREATE A NEW BLANK WEBSITE IN YOUR DATAVERSE ENVIRONMENT (MUST BE ENHANCED DATAMODEL)
# STEP 3: ONCE THE WEBSITE IS CREATED, GO TO THE POWER PAGES MANAGEMENT APP, THEN OPEN THE WEBSITE RECORD AND ADD FRENCH AS AN ADDITIONAL LANGUAGE
# STEP 4: COPY THE WEBSITE ID (GUID) FOR THE CONFIGURATION FILE (SEE STEP 6)
# STEP 5: INSTALL THE FILE_UPLOAD_FLOW.ZIP SOLUTION IN YOUR DATAVERSE ENVIRONMENT
# STEP 6: ONCE THE FILE_UPDLOAD_FLOW.ZIP SOLUTION IS INSTALL, OPEN THE SOLUTION AND OPEN THE CLOUD FLOW. PRESS EDIT, AND COPY THE FIRST TRIGGER ACTION'S HTTP POST URL FOR THE CONFIGURATION FILE (SEE STEP 6)
# STEP 6: CREATE A CONNECTION.JSON FILE SOMEWHERE ON YOUR FILE SYSTEM AND POPULATE THESE VARIABLES (NOTE YOU CAN IGNORE THE BLOB ADDRESS VARIABLE AS THIS IS NOT YET SUPPORTED):
# {
#   "clientId": "",
#   "tenantId": "",
#   "crmInstance": "",
#   "redirectUri": "https://login.onmicrosoft.com",
#   "websiteId": "",
#   "blobAddress": "https://yourstorageaccount.blob.core.windows.net/yourcontainer/",
#   "FlowURL": "https://SOMEID.f3.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/b361d67fd1SOMEID954a569a01efdcfd7337c4/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=SOMESIG",
#   "clientSecret": ""
# }

#####################################

# Configuration variables
BASE_PATH="/Users/frederickpearson/projects/Public/portal/BuildGCWEB/files/"
BASE_PATH_SNIPPETS="${BASE_PATH}liquid/contentsnippets/snippets.json"
BASE_PATH_TEMPLATES="${BASE_PATH}liquid/webtemplates/"
PORTAL_BASIC_THEME_PATH="${BASE_PATH}portalbasictheme.css"
THEME_PATH="${BASE_PATH}theme.css"
CUSTOMCSS_PATH="${BASE_PATH}custom-styles.css"
BOOTSTRAP_PATH="${BASE_PATH}bootstrap.min.css"
FAVICON_PATH="${BASE_PATH}favicon.ico"
ZIP_FILE_PATH="${BASE_PATH}themes-dist-18.1.1-gcweb.zip"
EXTRACTION_PATH="${BASE_PATH}"
THEME_ROOT_FOLDER_NAME="themes-dist-18.1.1-gcweb"
PAGE_TEMPLATE_NAME_NEW_HOME="CS-Home-WET"
WEB_TEMPLATE_HEADER="CS-header"
WEB_TEMPLATE_FOOTER="CS-footer"
ENGLISH_LANGUAGE_CODE=1033
FRENCH_LANGUAGE_CODE=1036

# URL encode function for query parameters
urlencode() {
    python3 -c "import sys; from urllib.parse import quote; print(quote(sys.argv[1], safe=''))" "$1"
}

####################################
# Functions
####################################

# JSON config prompt
prompt_json_config() {
    echo "Do you want to provide a JSON configuration file? (Y/N/H) [H for Help]"
    read -r use_json_config
    
    if [[ "$use_json_config" =~ ^[Yy]$ ]]; then
        echo "Enter the path to the JSON configuration file:"
        read -r json_file_path
        
        if [[ -f "$json_file_path" ]]; then
            JSON_CONFIG=$(cat "$json_file_path")
        else
            echo "File not found. Exiting."
            exit 1
        fi
    elif [[ "$use_json_config" =~ ^[Hh]$ ]]; then
        echo "JSON Configuration File Format:"
        echo '{'
        echo '  "clientId": "<client id>",'
        echo '  "tenantId": "<tenant id>",'
        echo '  "crmInstance": "<crm instance>",'
        echo '  "redirectUri": "https://login.onmicrosoft.com",'
        echo '  "websiteId": "<website id>",'
        echo '  "blobAddress": "<blob address>",'
        echo '  "FlowURL": "<flow URL>",'
        echo '  "clientSecret": "<client secret>"'
        echo '}'
        exit 0
    fi
}

# Configuration setup
setup_config() {
    if [[ -n "$JSON_CONFIG" ]]; then
        CLIENT_ID=$(echo "$JSON_CONFIG" | jq -r '.clientId')
        TENANT_ID=$(echo "$JSON_CONFIG" | jq -r '.tenantId')
        CRM_INSTANCE=$(echo "$JSON_CONFIG" | jq -r '.crmInstance')
        REDIRECT_URI=$(echo "$JSON_CONFIG" | jq -r '.redirectUri')
        WEBSITE_ID=$(echo "$JSON_CONFIG" | jq -r '.websiteId')
        BLOB_ADDRESS=$(echo "$JSON_CONFIG" | jq -r '.blobAddress')
        FLOW_URL=$(echo "$JSON_CONFIG" | jq -r '.FlowURL')
        CLIENT_SECRET=$(echo "$JSON_CONFIG" | jq -r '.clientSecret')
    else
        echo "Enter the value for clientId:"
        read -r CLIENT_ID
        
        echo "Enter the value for tenantId:"
        read -r TENANT_ID
        
        echo "Enter the value for crmInstance:"
        read -r CRM_INSTANCE
        
        echo "Enter the value for redirectUri (Default: https://login.onmicrosoft.com):"
        read -r REDIRECT_URI
        REDIRECT_URI=${REDIRECT_URI:-"https://login.onmicrosoft.com"}
        
        echo "Enter the value for websiteId:"
        read -r WEBSITE_ID
        
        echo "Enter the value for blobAddress:"
        read -r BLOB_ADDRESS
        
        echo "Enter the value for FlowURL:"
        read -r FLOW_URL
        
        echo "Enter the value for clientSecret:"
        read -rs CLIENT_SECRET
        echo
    fi
    
    AUTHORITY="https://login.microsoftonline.com/$TENANT_ID"
    RESOURCE="https://${CRM_INSTANCE}.api.crm3.dynamics.com"
    TOKEN_ENDPOINT="$AUTHORITY/oauth2/v2.0/token"
    API_URL="${RESOURCE}/api/data/v9.2/"
}

# Acquire OAuth token
acquire_token() {
    local response
    response=$(curl -s -X POST "$TOKEN_ENDPOINT" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$CLIENT_ID" \
        -d "scope=${RESOURCE}/.default" \
        -d "grant_type=client_credentials" \
        -d "redirect_uri=$REDIRECT_URI" \
        -d "client_secret=$CLIENT_SECRET")
    
    TOKEN=$(echo "$response" | jq -r '.access_token')
    
    if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
        echo "Failed to acquire token. Response:"
        echo "$response"
        exit 1
    fi
    
    echo "Token acquired successfully"
}

# API call functions
create_record_api() {
    local url="$1"
    local body="$2"
    
    curl -s -X POST "$url" \
        -H "Authorization: Bearer $TOKEN" \
        -H "OData-MaxVersion: 4.0" \
        -H "OData-Version: 4.0" \
        -H "Accept: application/json" \
        -H "Prefer: return=representation" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d "$body"
}

update_record_api() {
    local url="$1"
    local body="$2"
    
    curl -s -X PATCH "$url" \
        -H "Authorization: Bearer $TOKEN" \
        -H "OData-MaxVersion: 4.0" \
        -H "OData-Version: 4.0" \
        -H "Accept: application/json" \
        -H "Prefer: return=representation" \
        -H "If-Match: *" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d "$body"
}

get_record_api() {
    local url="$1"
    
    # URL encode spaces and special characters
    url="${url// /%20}"
    url="${url//\'/%27}"
    
    local response
    response=$(curl -s "$url" \
        -H "Authorization: Bearer $TOKEN" \
        -H "OData-MaxVersion: 4.0" \
        -H "OData-Version: 4.0" \
        -H "Accept: application/json")
    
    echo "$response"
}

# Get IDs functions
get_page_template_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_name eq 'Access Denied'"
    local query="${API_URL}mspp_pagetemplates?\$filter=$filter"
    
    echo "Query: $query"
    local response
    response=$(get_record_api "$query")
    PAGE_TEMPLATE_ID=$(echo "$response" | jq -r '.value[0].mspp_pagetemplateid')
    >&2 echo "Page Template ID: $PAGE_TEMPLATE_ID"
}

get_publishing_state_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_name eq 'Published'"
    local query="${API_URL}mspp_publishingstates?\$filter=$filter"
    
    >&2 echo "Query: $query"
    local response
    response=$(get_record_api "$query")
    PUBLISHING_STATE_ID=$(echo "$response" | jq -r '.value[0].mspp_publishingstateid')
    >&2 echo "Publishing State ID: $PUBLISHING_STATE_ID"
}

get_english_language_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_lcid eq $ENGLISH_LANGUAGE_CODE"
    local query="${API_URL}mspp_websitelanguages?\$filter=$filter"
    
    >&2 echo "Query: $query"
    local response
    response=$(get_record_api "$query")
    ENGLISH_LANGUAGE_ID=$(echo "$response" | jq -r '.value[0].mspp_websitelanguageid')
    >&2 echo "English Language ID: $ENGLISH_LANGUAGE_ID"
}

get_french_language_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_lcid eq $FRENCH_LANGUAGE_CODE"
    local query="${API_URL}mspp_websitelanguages?\$filter=$filter"
    
    local response
    response=$(get_record_api "$query")
    FRENCH_LANGUAGE_ID=$(echo "$response" | jq -r '.value[0].mspp_websitelanguageid')
    >&2 echo "French Language ID: $FRENCH_LANGUAGE_ID"
}

get_root_home_page_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_isroot eq true and mspp_name eq 'Home'"
    local query="${API_URL}mspp_webpages?\$filter=$filter"
    
    >&2 echo "DEBUG: Query for home page: $query"
    
    local response
    response=$(get_record_api "$query")
    
    >&2 echo "DEBUG: API Response: $response"
    
    HOME_PAGE_ID=$(echo "$response" | jq -r '.value[0].mspp_webpageid')
    
    >&2 echo "DEBUG: Extracted HOME_PAGE_ID: $HOME_PAGE_ID"
    >&2 echo "Home Web Page ID: $HOME_PAGE_ID"
}

# get_root_home_page_id() {
#     HOME_PAGE_ID="e3ac7a40-e299-ee11-be37-0022483c04c3"
#     >&2 echo "Home Web Page ID: $HOME_PAGE_ID"
# }

get_english_home_page_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_name eq 'Home' and _mspp_webpagelanguageid_value eq '$ENGLISH_LANGUAGE_ID'"
    local query="${API_URL}mspp_webpages?\$filter=$filter"
    
    echo "Query: $query"
    local response
    response=$(get_record_api "$query")
    HOME_CONTENT_PAGE_EN=$(echo "$response" | jq -r '.value[0].mspp_webpageid')
    >&2 echo "EN Home Web Page ID: $HOME_CONTENT_PAGE_EN"
}

get_french_home_page_id() {
    local filter="_mspp_websiteid_value eq '$WEBSITE_ID' and mspp_name eq 'Home' and _mspp_webpagelanguageid_value eq '$FRENCH_LANGUAGE_ID'"
    local query="${API_URL}mspp_webpages?\$filter=$filter"
    
    local response
    response=$(get_record_api "$query")
    HOME_CONTENT_PAGE_FR=$(echo "$response" | jq -r '.value[0].mspp_webpageid')
    >&2 echo "FR Home Web Page ID: $HOME_CONTENT_PAGE_FR"
}

# Update baseline styles
update_baseline_styles() {
    create_web_file "$PORTAL_BASIC_THEME_PATH" "$HOME_PAGE_ID"
    create_web_file "$THEME_PATH" "$HOME_PAGE_ID"    
    create_web_file "$BOOTSTRAP_PATH" "$HOME_PAGE_ID"
    create_web_file "$FAVICON_PATH" "$HOME_PAGE_ID"
    create_web_file "$CUSTOMCSS_PATH" "$HOME_PAGE_ID"
}

# Get relative path
get_relative_path() {
    local base_path="$1"
    local target_path="$2"
    
    # Use Python for cross-platform path manipulation
    python3 -c "import os; print(os.path.relpath('$target_path', '$base_path').replace(os.sep, '/'))"
}

# Get MIME type
get_mime_type() {
    local file_path="$1"
    local extension="${file_path##*.}"
    
    case "$extension" in
        css) echo "text/css" ;;
        js) echo "application/javascript" ;;
        json) echo "application/json" ;;
        png) echo "image/png" ;;
        jpg|jpeg) echo "image/jpeg" ;;
        gif) echo "image/gif" ;;
        svg) echo "image/svg+xml" ;;
        ico) echo "image/x-icon" ;;
        woff) echo "font/woff" ;;
        woff2) echo "font/woff2" ;;
        ttf) echo "font/ttf" ;;
        *) echo "application/octet-stream" ;;
    esac
}

# Create web page
create_web_page() {
    local name="$1"
    local parent_page_id="$2"
    
    # Validate inputs
    if [[ -z "$name" || -z "$parent_page_id" ]]; then
        >&2 echo "ERROR: create_web_page called with empty name or parent_page_id"
        return 1
    fi
    
    local partial_url=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    
    >&2 echo "Creating/Updating page: $name (parent: $parent_page_id)"
    
    local filter="mspp_partialurl eq '$partial_url' and _mspp_websiteid_value eq '$WEBSITE_ID'"
    
    if [[ -n "$parent_page_id" ]]; then
        filter+=" and _mspp_parentpageid_value eq $parent_page_id"
    fi
    
    local check_url="${API_URL}mspp_webpages?\$filter=$filter"
    
    local existing_pages
    existing_pages=$(get_record_api "$check_url")
    local existing_page_id
    existing_page_id=$(echo "$existing_pages" | jq -r '.value[0].mspp_webpageid // empty')
    
    local web_page_json
    web_page_json=$(jq -n \
        --arg name "$name" \
        --arg partial_url "$partial_url" \
        --arg parent_page_id "$parent_page_id" \
        --arg page_template_id "$PAGE_TEMPLATE_ID" \
        --arg website_id "$WEBSITE_ID" \
        --arg publishing_state_id "$PUBLISHING_STATE_ID" \
        '{
            "mspp_name": $name,
            "mspp_partialurl": $partial_url,
            "mspp_parentpageid@odata.bind": ("/mspp_webpages(" + $parent_page_id + ")"),
            "mspp_pagetemplateid@odata.bind": ("/mspp_pagetemplates(" + $page_template_id + ")"),
            "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
            "mspp_publishingstateid@odata.bind": ("/mspp_publishingstates(" + $publishing_state_id + ")")
        }')
    
    if [[ -n "$existing_page_id" && "$existing_page_id" != "null" ]]; then
        >&2 echo "Web page already exists with ID: $existing_page_id"
        local update_url="${API_URL}mspp_webpages($existing_page_id)"
        update_record_api "$update_url" "$web_page_json" > /dev/null 2>&1
        echo "$existing_page_id"
    else
        local response
        response=$(create_record_api "${API_URL}mspp_webpages" "$web_page_json")
        local new_page_id
        new_page_id=$(echo "$response" | jq -r '.mspp_webpageid')
        
        if [[ -n "$new_page_id" && "$new_page_id" != "null" ]]; then
            >&2 echo "Created new page with ID: $new_page_id"
            echo "$new_page_id"
        else
            >&2 echo "ERROR: Failed to create page. API response: $response"
            return 1
        fi
    fi
}

# Create web file
create_web_file() {
    local file_path="$1"
    local parent_page_id="$2"
    
    # Validate inputs
    if [[ -z "$file_path" || ! -f "$file_path" ]]; then
        >&2 echo "ERROR: Invalid file path: $file_path"
        return 1
    fi
    
    if [[ -z "$parent_page_id" || "$parent_page_id" == "null" ]]; then
        >&2 echo "ERROR: Invalid parent_page_id for file $(basename "$file_path"): '$parent_page_id'"
        return 1
    fi
    
    local file_name=$(basename "$file_path")
    local partial_url=$(echo "$file_name" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
    local mime_type=$(get_mime_type "$file_path")
    local relative_path=$(get_relative_path "${EXTRACTION_PATH}${THEME_ROOT_FOLDER_NAME}" "$file_path")
    
    local blob_url="${BLOB_ADDRESS}${relative_path}${partial_url}"
    
    local filter="mspp_partialurl eq '$partial_url' and _mspp_websiteid_value eq '$WEBSITE_ID'"
    
    if [[ -n "$parent_page_id" ]]; then
        filter+=" and _mspp_parentpageid_value eq $parent_page_id"
    fi
    
    local check_url="${API_URL}mspp_webfiles?\$filter=$filter"
    local existing_files
    existing_files=$(get_record_api "$check_url")
    
    local web_file_json
    if [[ -n "$parent_page_id" ]]; then
        web_file_json=$(jq -n \
            --arg name "$file_name" \
            --arg partial_url "$partial_url" \
            --arg website_id "$WEBSITE_ID" \
            --arg publishing_state_id "$PUBLISHING_STATE_ID" \
            --arg parent_page_id "$parent_page_id" \
            '{
                "mspp_name": $name,
                "mspp_partialurl": $partial_url,
                "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
                "mspp_publishingstateid@odata.bind": ("/mspp_publishingstates(" + $publishing_state_id + ")"),
                "mspp_parentpageid@odata.bind": ("/mspp_webpages(" + $parent_page_id + ")")
            }')
    else
        web_file_json=$(jq -n \
            --arg name "$file_name" \
            --arg partial_url "$partial_url" \
            --arg website_id "$WEBSITE_ID" \
            --arg publishing_state_id "$PUBLISHING_STATE_ID" \
            '{
                "mspp_name": $name,
                "mspp_partialurl": $partial_url,
                "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
                "mspp_publishingstateid@odata.bind": ("/mspp_publishingstates(" + $publishing_state_id + ")")
            }')
    fi
    
    local existing_count
    existing_count=$(echo "$existing_files" | jq -r '.value | length')
    
    local web_file_id
    if [[ "$existing_count" -gt 0 ]]; then
        local existing_file_id
        existing_file_id=$(echo "$existing_files" | jq -r '.value[0].mspp_webfileid')
        local update_url="${API_URL}mspp_webfiles($existing_file_id)"
        local update_response
        update_response=$(update_record_api "$update_url" "$web_file_json" 2>&1)
        web_file_id="$existing_file_id"
        >&2 echo "Updated web file: $file_name (ID: $web_file_id)"
    else
        local response
        response=$(create_record_api "${API_URL}mspp_webfiles" "$web_file_json" 2>&1)
        web_file_id=$(echo "$response" | jq -r '.mspp_webfileid // empty')
        
        if [[ -z "$web_file_id" || "$web_file_id" == "null" ]]; then
            >&2 echo "ERROR: Failed to create web file for $file_name"
            >&2 echo "API Response: $response"
            return 1
        fi
        >&2 echo "Created web file: $file_name (ID: $web_file_id)"
    fi
    
    # Get the power page component
    local existing_row
    existing_row=$(get_record_api "${API_URL}powerpagecomponents($web_file_id)" 2>&1)
    
    local component_id
    component_id=$(echo "$existing_row" | jq -r '.powerpagecomponentid // empty')
    
    if [[ -z "$component_id" || "$component_id" == "null" ]]; then
        >&2 echo "WARNING: Could not get power page component for $file_name"
        return 0
    fi
    
    # Upload file content directly via Web API (binary upload)
    local upload_response
    upload_response=$(curl -s -X PATCH "${API_URL}powerpagecomponents($component_id)/filecontent" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/octet-stream" \
        -H "x-ms-file-name: $file_name" \
        --data-binary "@$file_path")
    
    # Check for errors in response
    local error_code
    error_code=$(echo "$upload_response" | jq -r '.error.code // empty' 2>/dev/null)
    
    if [[ -n "$error_code" ]]; then
        >&2 echo "ERROR: Failed to upload file content for $file_name"
        >&2 echo "Response: $upload_response"
        return 1
    fi
    
    >&2 echo "Uploaded file content for: $file_name"
}

# Write hierarchy
# write_hierarchy() {
#     local path="$1"
#     local parent_page_id="$2"
    
#     # If parent_page_id is empty and this is the root theme folder, use HOME_PAGE_ID
#     if [[ -z "$parent_page_id" ]]; then
#         >&2 echo "WARNING: parent_page_id is empty, using HOME_PAGE_ID"
#         parent_page_id="$HOME_PAGE_ID"
#     fi
    
#     # Validate HOME_PAGE_ID is set
#     if [[ -z "$HOME_PAGE_ID" || "$HOME_PAGE_ID" == "null" ]]; then
#         >&2 echo "ERROR: HOME_PAGE_ID is not set! Cannot continue."
#         return 1
#     fi
    
#     for item in "$path"/*; do
#         # Skip if glob doesn't match any files
#         [[ -e "$item" ]] || continue
        
#         if [[ -f "$item" ]]; then
#             >&2 echo "Processing file: $(basename "$item") with parent: $parent_page_id"
#             create_web_file "$item" "$parent_page_id"
#         elif [[ -d "$item" ]]; then
#             local folder_name=$(basename "$item")
            
#             # Skip the root theme folder itself
#             if [[ "$folder_name" == "$THEME_ROOT_FOLDER_NAME" ]]; then
#                 >&2 echo "ROOT FOLDER detected: $folder_name - recursing with HOME_PAGE_ID"
#                 write_hierarchy "$item" "$HOME_PAGE_ID"
#             else
#                 >&2 echo "Processing folder: $folder_name with parent: $parent_page_id"
#                 local new_page_id
#                 new_page_id=$(create_web_page "$folder_name" "$parent_page_id")
                
#                 # Only recurse if we got a valid page ID
#                 if [[ -n "$new_page_id" && "$new_page_id" != "null" ]]; then
#                     >&2 echo "Successfully created page for $folder_name (ID: $new_page_id)"
#                     write_hierarchy "$item" "$new_page_id"
#                 else
#                     >&2 echo "WARNING: Failed to create page for $folder_name, using parent ID ($parent_page_id) for children"
#                     write_hierarchy "$item" "$parent_page_id"
#                 fi
#             fi
#         fi
#     done
# }

# Write hierarchy
write_hierarchy() {
    local path="$1"
    local parent_page_id="$2"
    
    # If parent_page_id is empty and this is the root theme folder, use HOME_PAGE_ID
    if [[ -z "$parent_page_id" ]]; then
        >&2 echo "WARNING: parent_page_id is empty, using HOME_PAGE_ID"
        parent_page_id="$HOME_PAGE_ID"
    fi
    
    # Validate HOME_PAGE_ID is set
    if [[ -z "$HOME_PAGE_ID" || "$HOME_PAGE_ID" == "null" ]]; then
        >&2 echo "ERROR: HOME_PAGE_ID is not set! Cannot continue."
        return 1
    fi
    
    for item in "$path"/*; do
        # Skip if glob doesn't match any files
        [[ -e "$item" ]] || continue
        
        if [[ -f "$item" ]]; then
            >&2 echo "Processing file: $(basename "$item") with parent: $parent_page_id"
            create_web_file "$item" "$parent_page_id"
        elif [[ -d "$item" ]]; then
            local folder_name=$(basename "$item")
            
            # Skip the root theme folder itself
            if [[ "$folder_name" == "$THEME_ROOT_FOLDER_NAME" ]]; then
                >&2 echo "ROOT FOLDER detected: $folder_name - recursing with HOME_PAGE_ID"
                write_hierarchy "$item" "$HOME_PAGE_ID"
            else
                >&2 echo "Processing folder: $folder_name with parent: $parent_page_id"
                local new_page_id
                new_page_id=$(create_web_page "$folder_name" "$parent_page_id")
                
                # Only recurse if we got a valid page ID
                if [[ -n "$new_page_id" && "$new_page_id" != "null" ]]; then
                    >&2 echo "Successfully got/created page for $folder_name (ID: $new_page_id)"
                    write_hierarchy "$item" "$new_page_id"
                else
                    >&2 echo "ERROR: Failed to get/create page for $folder_name, skipping folder contents"
                    # Don't use parent_page_id as fallback - this could cause duplicates
                    continue
                fi
            fi
        fi
    done
}


# Create web template
create_web_template() {
    local markup="$1"
    local filename="$2"
    
    local filter="mspp_name eq '$filename'"
    local check_url="${API_URL}mspp_webtemplates?\$filter=$filter"
    local existing_templates
    existing_templates=$(get_record_api "$check_url")
    
    local existing_count
    existing_count=$(echo "$existing_templates" | jq -r '.value | length')
    
    local web_template_payload
    web_template_payload=$(jq -n \
        --arg name "$filename" \
        --arg website_id "$WEBSITE_ID" \
        --arg source "$markup" \
        '{
            "mspp_name": $name,
            "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
            "mspp_source": $source
        }')
    
    if [[ "$existing_count" -gt 0 ]]; then
        echo "Web template already exists: $filename"
        local existing_template_id
        existing_template_id=$(echo "$existing_templates" | jq -r '.value[0].mspp_webtemplateid')
        
        local update_url="${API_URL}mspp_webtemplates($existing_template_id)"
        local update_payload
        update_payload=$(jq -n --arg source "$markup" '{"mspp_source": $source}')
        
        local response
        response=$(update_record_api "$update_url" "$update_payload")
        
        if [[ -n "$response" ]]; then
            echo "mspp_webtemplate UPDATED successfully"
        else
            echo "Failed to UPDATE mspp_webtemplate"
        fi
    else
        local response
        response=$(create_record_api "${API_URL}mspp_webtemplates" "$web_template_payload")
        local wt_id
        wt_id=$(echo "$response" | jq -r '.mspp_webtemplateid')
        
        local page_template_payload
        page_template_payload=$(jq -n \
            --arg name "$filename" \
            --arg website_id "$WEBSITE_ID" \
            --arg wt_id "$wt_id" \
            '{
                "mspp_name": $name,
                "mspp_type": 756150001,
                "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
                "mspp_webtemplateid@odata.bind": ("/mspp_webtemplates(" + $wt_id + ")")
            }')
        
        create_record_api "${API_URL}mspp_pagetemplates" "$page_template_payload"
        
        if [[ -n "$response" ]]; then
            >&2 echo "mspp_webtemplate created successfully with ID: $wt_id"
            
            if [[ "$filename" == "$WEB_TEMPLATE_HEADER" || "$filename" == "$WEB_TEMPLATE_FOOTER" ]]; then
                local lookup_name="mspp_headerwebtemplateid@odata.bind"
                if [[ "$filename" == "$WEB_TEMPLATE_FOOTER" ]]; then
                    lookup_name="mspp_footerwebtemplateid@odata.bind"
                fi
                
                local website_update_url="${API_URL}mspp_websites($WEBSITE_ID)"
                local website_payload
                website_payload=$(jq -n \
                    --arg lookup "$lookup_name" \
                    --arg wt_id "$wt_id" \
                    '{($lookup): ("/mspp_webtemplates(" + $wt_id + ")")}')
                
                update_record_api "$website_update_url" "$website_payload"
            fi
        else
            echo "Failed to create mspp_webtemplate"
        fi
    fi
}

# Create snippets
create_snippets() {
    # Check if language IDs are set
    if [[ -z "$ENGLISH_LANGUAGE_ID" || "$ENGLISH_LANGUAGE_ID" == "null" ]]; then
        >&2 echo "ERROR: English Language ID is not set. Cannot create snippets."
        return 1
    fi
    
    if [[ -z "$FRENCH_LANGUAGE_ID" || "$FRENCH_LANGUAGE_ID" == "null" ]]; then
        >&2 echo "ERROR: French Language ID is not set. Cannot create snippets."
        return 1
    fi

    # Read snippet content from the JSON file
    local snippets_json
    snippets_json=$(cat "$BASE_PATH_SNIPPETS")
    
    # Get all keys from the JSON object
    local snippet_names
    snippet_names=$(echo "$snippets_json" | jq -r 'keys[]')
    
    while IFS= read -r snippet_name; do
        [[ -z "$snippet_name" ]] && continue
        
        local snippet_content_english
        snippet_content_english=$(echo "$snippets_json" | jq -r --arg name "$snippet_name" '.[$name][0]')
        local snippet_content_french
        snippet_content_french=$(echo "$snippets_json" | jq -r --arg name "$snippet_name" '.[$name][1]')
        
        >&2 echo "Processing snippet: $snippet_name"
        
        # English snippet
        local snippet_payload_en
        snippet_payload_en=$(jq -n \
            --arg name "$snippet_name" \
            --arg website_id "$WEBSITE_ID" \
            --arg value "$snippet_content_english" \
            --arg lang_id "$ENGLISH_LANGUAGE_ID" \
            '{
                "mspp_name": $name,
                "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
                "mspp_value": $value,
                "mspp_contentsnippetlanguageid@odata.bind": ("/mspp_websitelanguages(" + $lang_id + ")")
            }')
        
        local filter_en="(mspp_name%20eq%20'$snippet_name'%20and%20_mspp_contentsnippetlanguageid_value%20eq%20$ENGLISH_LANGUAGE_ID)"
        local check_url_en="${API_URL}mspp_contentsnippets?\$filter=$filter_en"
        local existing_snippets_en
        existing_snippets_en=$(get_record_api "$check_url_en")
        
        local existing_count_en
        existing_count_en=$(echo "$existing_snippets_en" | jq -r '.value | length // 0')
        
        if [[ "$existing_count_en" -gt 0 ]]; then
            >&2 echo "Snippet already exists: $snippet_name (EN)"
            local existing_snippet_id
            existing_snippet_id=$(echo "$existing_snippets_en" | jq -r '.value[0].mspp_contentsnippetid')
            local update_url="${API_URL}mspp_contentsnippets($existing_snippet_id)"
            update_record_api "$update_url" "$snippet_payload_en" > /dev/null 2>&1
        else
            create_record_api "${API_URL}mspp_contentsnippets" "$snippet_payload_en" > /dev/null 2>&1
            >&2 echo "Created snippet: $snippet_name (EN)"
        fi
        
        # French snippet
        local snippet_payload_fr
        snippet_payload_fr=$(jq -n \
            --arg name "$snippet_name" \
            --arg website_id "$WEBSITE_ID" \
            --arg value "$snippet_content_french" \
            --arg lang_id "$FRENCH_LANGUAGE_ID" \
            '{
                "mspp_name": $name,
                "mspp_websiteid@odata.bind": ("/mspp_websites(" + $website_id + ")"),
                "mspp_value": $value,
                "mspp_contentsnippetlanguageid@odata.bind": ("/mspp_websitelanguages(" + $lang_id + ")")
            }')
        
        local filter_fr="(mspp_name%20eq%20'$snippet_name'%20and%20_mspp_contentsnippetlanguageid_value%20eq%20$FRENCH_LANGUAGE_ID)"
        local check_url_fr="${API_URL}mspp_contentsnippets?\$filter=$filter_fr"
        local existing_snippets_fr
        existing_snippets_fr=$(get_record_api "$check_url_fr")
        
        local existing_count_fr
        existing_count_fr=$(echo "$existing_snippets_fr" | jq -r '.value | length // 0')
        
        if [[ "$existing_count_fr" -gt 0 ]]; then
            >&2 echo "Snippet already exists: $snippet_name (FR)"
            local existing_snippet_id
            existing_snippet_id=$(echo "$existing_snippets_fr" | jq -r '.value[0].mspp_contentsnippetid')
            local update_url="${API_URL}mspp_contentsnippets($existing_snippet_id)"
            update_record_api "$update_url" "$snippet_payload_fr" > /dev/null 2>&1
        else
            create_record_api "${API_URL}mspp_contentsnippets" "$snippet_payload_fr" > /dev/null 2>&1
            >&2 echo "Created snippet: $snippet_name (FR)"
        fi
    done <<< "$snippet_names"
}

# Write templates
write_templates() {
    local folder_path="$1"
    
    >&2 echo "Folder: $(basename "$folder_path")"
    
    # Process .html files
    for file in "$folder_path"/*.html; do
        [[ -e "$file" ]] || continue
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file" .html)
            >&2 echo "  File: $filename"
            local html
            html=$(cat "$file")
            create_web_template "$html" "$filename"
        fi
    done
    
    # Process .liquid files
    for file in "$folder_path"/*.liquid; do
        [[ -e "$file" ]] || continue
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file" .liquid)
            >&2 echo "  File: $filename"
            local html
            html=$(cat "$file")
            create_web_template "$html" "$filename"
        fi
    done
}

# Update home page
update_home_page() {
    local page_template_name="$1"
    
    local filter="mspp_name eq '$page_template_name'"
    local check_url="${API_URL}mspp_pagetemplates?\$filter=$filter"
    local existing_templates
    existing_templates=$(get_record_api "$check_url")
    
    local existing_count
    existing_count=$(echo "$existing_templates" | jq -r '.value | length')
    
    if [[ "$existing_count" -gt 0 ]]; then
        echo "Page template exists: $page_template_name"
        
        local page_template_id
        page_template_id=$(echo "$existing_templates" | jq -r '.value[0].mspp_pagetemplateid')
        
        local update_url="${API_URL}mspp_webpages($HOME_PAGE_ID)"
        local web_page_payload
        web_page_payload=$(jq -n \
            --arg pt_id "$page_template_id" \
            '{"mspp_pagetemplateid@odata.bind": ("/mspp_pagetemplates(" + $pt_id + ")")}')
        
        local response
        response=$(update_record_api "$update_url" "$web_page_payload")
        
        if [[ -n "$response" ]]; then
            echo "mspp_webpage UPDATED successfully"
        else
            echo "Failed to UPDATE home page"
        fi
        
        # Update English content page
        local update_url_en="${API_URL}mspp_webpages($HOME_CONTENT_PAGE_EN)"
        local content_payload_en='{"mspp_copy": ""}'
        update_record_api "$update_url_en" "$content_payload_en"
        
        # Update French content page
        local update_url_fr="${API_URL}mspp_webpages($HOME_CONTENT_PAGE_FR)"
        local content_payload_fr='{"mspp_copy": ""}'
        update_record_api "$update_url_fr" "$content_payload_fr"
    fi
}

# Main installation function
run_portal_template_install() {

#####################################
# STEP 1: EXTRACT GCWEB FILES
#####################################
    echo "Extracting theme files..."
    unzip -o "$ZIP_FILE_PATH" -d "$EXTRACTION_PATH"

#####################################
# STEP 2: CREATE SNIPPETS
#####################################
    echo "Creating snippets..."
    create_snippets

#####################################
# STEP 3: CREATE TEMPLATES
#####################################
    echo "Writing templates..."
    write_templates "$BASE_PATH_TEMPLATES"

#####################################
# STEP 4: UPDATE HOME PAGE COPY
#####################################
    echo "Updating home page..."
    update_home_page "$PAGE_TEMPLATE_NAME_NEW_HOME"
    
#####################################
# STEP 5: CREATE WEB PAGES & WEB FILES
#####################################
    echo "Writing hierarchy (using the extracted gcweb zip file structure & files)..."
    >&2 echo "DEBUG: HOME_PAGE_ID before write_hierarchy: $HOME_PAGE_ID"
    >&2 echo "DEBUG: Calling write_hierarchy with path: ${EXTRACTION_PATH}${THEME_ROOT_FOLDER_NAME}"
    
    write_hierarchy "${EXTRACTION_PATH}${THEME_ROOT_FOLDER_NAME}" "$HOME_PAGE_ID"

#####################################
# STEP 6: UPSERT THE BASELINE STYLES REQUIRED BY POWER PAGES
#####################################
    echo "Updating baseline styles..."
    # update_baseline_styles
    
    echo "Portal template installation complete!"
}

####################################
# Main Script Execution
####################################

main() {
    echo "================================================"
    echo "Power Pages Deployment Script"
    echo "================================================"
    echo
    
    # Check for required dependencies
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install it using: brew install jq"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed."
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is required but not installed."
        exit 1
    fi
    
    # Prompt for configuration
    prompt_json_config
    
    # Setup configuration
    setup_config

    # Debug: Verify config was loaded
    >&2 echo "========== CONFIG DEBUG =========="
    >&2 echo "CLIENT_ID: ${CLIENT_ID:0:10}..."
    >&2 echo "WEBSITE_ID: $WEBSITE_ID"
    >&2 echo "API_URL: $API_URL"
    >&2 echo "CRM_INSTANCE: $CRM_INSTANCE"
    >&2 echo "=================================="
    
    # Acquire authentication token
    echo "Acquiring authentication token..."
    acquire_token
    
    # Get all required IDs
    echo "Retrieving configuration IDs..."
    get_page_template_id
    get_publishing_state_id
    get_english_language_id
    get_french_language_id
    get_root_home_page_id
    get_english_home_page_id
    get_french_home_page_id

    # Debug: Check if critical variables are set
    >&2 echo "DEBUG: WEBSITE_ID = $WEBSITE_ID"
    >&2 echo "DEBUG: API_URL = $API_URL"
    
    # Run the installation
    echo "Starting portal template installation..."
    run_portal_template_install
    
    echo
    echo "================================================"
    echo "Deployment completed successfully!"
    echo "Please go to Power Pages site and press Sync"
    echo "================================================"
}

# Execute main function
main "$@"