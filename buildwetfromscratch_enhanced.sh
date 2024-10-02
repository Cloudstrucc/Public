#!/bin/bash

# Configuration
CONFIG_FILE="connection.json"
LOG_FILE="script_log_$(date +"%Y%m%d_%H%M%S").log"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Load configuration
load_config() {
    local default_config='{
        "BasePath": "/Users/frederickpearson/Public/",
        "ZipFilePath": "/Users/frederickpearson/Public/files/themes-dist-15.2.0-gcweb.zip",
        "ExtractionPath": "/Users/frederickpearson/Public/files/",
        "ThemeRootFolderName": "themes-dist-15.2.0-gcweb",
        "EnglishLanguageCode": 1033,
        "FrenchLanguageCode": 1036,
        "PageTemplateNameNewHome": "CS-Home-WET",
        "WebTemplateHeader": "CS-header",
        "WebTemplateFooter": "CS-footer",
        "ClientId": "<client id>",
        "TenantId": "<tenant id>",
        "CrmInstance": "<crm instance>",
        "RedirectUri": "https://login.onmicrosoft.com",
        "WebsiteId": "<website id>",
        "BlobAddress": "<blob address>",
        "FlowURL": "<flow url>"
    }'

    if [ -f "$CONFIG_FILE" ]; then
        log_message "Config file found. Loading and merging with defaults."
        local file_config=$(jq '.' "$CONFIG_FILE")
        # Merge file config with default config, preferring file config values
        config=$(echo "$default_config" "$file_config" | jq -s '.[0] * .[1]')
    else
        log_message "Config file not found. Using default values."
        config=$default_config
    fi
    
    # Debug logging
    log_message "BasePath: $(echo $config | jq -r '.BasePath')"
    log_message "ZipFilePath: $(echo $config | jq -r '.ZipFilePath')"
    log_message "ExtractionPath: $(echo $config | jq -r '.ExtractionPath')"
    log_message "ThemeRootFolderName: $(echo $config | jq -r '.ThemeRootFolderName')"
    log_message "PageTemplateNameNewHome: $(echo $config | jq -r '.PageTemplateNameNewHome')"
    log_message "WebTemplateHeader: $(echo $config | jq -r '.WebTemplateHeader')"
    log_message "WebTemplateFooter: $(echo $config | jq -r '.WebTemplateFooter')"
}

# Get auth token
get_auth_token() {
    local authority="https://login.microsoftonline.com/$(echo $config | jq -r '.TenantId')"
    local resource="https://$(echo $config | jq -r '.CrmInstance').api.crm3.dynamics.com"
    local token_endpoint="$authority/oauth2/v2.0/token"
    local client_id=$(echo $config | jq -r '.ClientId')
    local client_secret=$(echo $config | jq -r '.ClientSecret')
    local redirect_uri=$(echo $config | jq -r '.RedirectUri')

    local response=$(curl -s -X POST "$token_endpoint" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$client_id&scope=$resource/.default&grant_type=client_credentials&redirect_uri=$redirect_uri&client_secret=$client_secret")

    echo $response | jq -r '.access_token'
}

# API call function with retry mechanism
invoke_dataverse_api() {
    local method="$1"
    local url="$2"
    local body="$3"
    local use_update_headers="$4"
    local max_retries=3
    local retry_count=0
    local response

    while [ $retry_count -lt $max_retries ]; do
        local headers=(-H "Authorization: Bearer $TOKEN" -H "OData-MaxVersion: 4.0" -H "OData-Version: 4.0" -H "Accept: application/json" -H "Prefer: return=representation")
        
        if [ "$use_update_headers" = true ]; then
            headers+=(-H "If-Match: *")
        fi

        if [ -n "$body" ]; then
            response=$(curl -s -X "$method" "${headers[@]}" -H "Content-Type: application/json" -d "$body" "$url")
        else
            response=$(curl -s -X "$method" "${headers[@]}" "$url")
        fi

        log_message "API Response: $response"

        # Check if the response is valid JSON
        if echo "$response" | jq empty > /dev/null 2>&1; then
            echo "$response"
            return 0
        else
            log_message "Invalid JSON response. Retrying..."
            log_message "Response content: $response"
        fi
        
        retry_count=$((retry_count + 1))
        sleep 5  # Wait for 5 seconds before retrying
    done

    log_message "API call failed after $max_retries attempts"
    echo "INVALID_JSON_RESPONSE"
    return 1
}

get_page_template_id() {
    local website_id=$(echo $config | jq -r '.WebsiteId')
    local filter="_mspp_websiteid_value eq '$website_id' and mspp_name eq 'Access Denied'"
    local url="${API_URL}mspp_pagetemplates?\$filter=$filter"
    local response=$(invoke_dataverse_api "GET" "$url")
    echo $response | jq -r '.value[0].mspp_pagetemplateid'
}

get_publishing_state_id() {
    local filter="mspp_name eq 'Published'"
    local url="${API_URL}mspp_publishingstates?\$filter=$filter"
    local response=$(invoke_dataverse_api "GET" "$url")
    echo $response | jq -r '.value[0].mspp_publishingstateid'
}

get_language_id() {
    local language_code="$1"
    local filter="mspp_lcid eq $language_code"
    local url="${API_URL}mspp_websitelanguages?\$filter=$filter"
    local response=$(invoke_dataverse_api "GET" "$url")
    echo $response | jq -r '.value[0].mspp_websitelanguageid'
}

get_home_page_id() {
    local website_id=$(echo $config | jq -r '.WebsiteId')
    local language_id="$1"
    local filter="_mspp_websiteid_value eq '$website_id' and mspp_name eq 'Home'"
    if [ -n "$language_id" ]; then
        filter="$filter and _mspp_webpagelanguageid_value eq '$language_id'"
    else
        filter="$filter and mspp_isroot eq true"
    fi
    local url="${API_URL}mspp_webpages?\$filter=$filter"
    local response=$(invoke_dataverse_api "GET" "$url")
    echo $response | jq -r '.value[0].mspp_webpageid'
}

update_baseline_styles() {
    local home_page_id="$1"
    local style_paths=(
        "$(echo $config | jq -r '.PortalBasicThemePath')"
        "$(echo $config | jq -r '.ThemePath')"
        "$(echo $config | jq -r '.BootstrapPath')"
        "$(echo $config | jq -r '.FaviconPath')"
    )
    for path in "${style_paths[@]}"; do
        create_web_file "$path" "$home_page_id"
    done
}
create_web_page() {
    local name="$1"
    local parent_page_id="$2"
    local website_id=$(echo $config | jq -r '.WebsiteId')
    local page_template_id="$PAGE_TEMPLATE_ID"
    local publishing_state_id="$PUBLISHING_STATE_ID"

    log_message "Creating web page: $name"

    local partial_url=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    local filter="mspp_partialurl eq '$partial_url' and _mspp_websiteid_value eq '$website_id'"
    if [ -n "$parent_page_id" ] && [ "$parent_page_id" != "null" ]; then
        filter="$filter and _mspp_parentpageid_value eq $parent_page_id"
    fi

    local check_url="${API_URL}mspp_webpages?\$filter=$filter"
    local existing_pages=$(invoke_dataverse_api "GET" "$check_url")

    if [ $? -ne 0 ]; then
        log_message "Error checking for existing pages"
        return 1
    fi

    local web_page
    web_page=$(jq -n \
        --arg name "$name" \
        --arg partial_url "$partial_url" \
        --arg website_id "$website_id" \
        --arg publishing_state_id "$publishing_state_id" \
        --arg page_template_id "$page_template_id" \
        --arg parent_page_id "$parent_page_id" \
        '{
            "mspp_name": $name,
            "mspp_partialurl": $partial_url,
            "mspp_websiteid@odata.bind": "/mspp_websites(\($website_id))",
            "mspp_publishingstateid@odata.bind": "/mspp_publishingstates(\($publishing_state_id))",
            "mspp_pagetemplateid@odata.bind": "/mspp_pagetemplates(\($page_template_id))"
        } + if ($parent_page_id != "" and $parent_page_id != "null") then {"mspp_parentpageid@odata.bind": "/mspp_webpages(\($parent_page_id))"} else {} end')

    local new_page_id
    if [ "$(echo $existing_pages | jq '.value | length')" -gt 0 ]; then
        new_page_id=$(echo $existing_pages | jq -r '.value[0].mspp_webpageid')
        local update_url="${API_URL}mspp_webpages($new_page_id)"
        local response=$(invoke_dataverse_api "PATCH" "$update_url" "$web_page" true)
        if [ $? -ne 0 ]; then
            log_message "Error updating existing web page"
            return 1
        fi
    else
        local response=$(invoke_dataverse_api "POST" "${API_URL}mspp_webpages" "$web_page")
        if [ $? -ne 0 ]; then
            log_message "Error creating new web page"
            return 1
        fi
        new_page_id=$(echo $response | jq -r '.mspp_webpageid')
    fi

    if [ -z "$new_page_id" ] || [ "$new_page_id" == "null" ]; then
        log_message "Error: Failed to create or update web page - $name"
        return 1
    fi

    log_message "Successfully created/updated web page: $name with ID: $new_page_id"
    echo "$new_page_id"
}
create_web_file() {
    local file_path="$1"
    local parent_page_id="$2"
    local website_id=$(echo $config | jq -r '.WebsiteId')
    local publishing_state_id="$PUBLISHING_STATE_ID"
    local blob_address=$(echo $config | jq -r '.BlobAddress')

    log_message "Creating web file: $file_path"

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        log_message "Error: File not found - $file_path"
        return 1
    fi

    local file_name=$(basename "$file_path")
    local partial_url=$(echo "$file_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    local file_content=$(base64 "$file_path")
    
    # Pure Bash solution for relative path
    local extraction_path="$(echo $config | jq -r '.ExtractionPath')$(echo $config | jq -r '.ThemeRootFolderName')"
    local relative_path="${file_path#$extraction_path}"
    relative_path="${relative_path#/}"  # Remove leading slash if present

    local filter="mspp_partialurl eq '$partial_url' and _mspp_websiteid_value eq '$website_id'"
    if [ -n "$parent_page_id" ] && [ "$parent_page_id" != "null" ]; then
        filter="$filter and _mspp_parentpageid_value eq $parent_page_id"
    fi

    local check_url="${API_URL}mspp_webfiles?\$filter=$filter"
    local existing_files=$(invoke_dataverse_api "GET" "$check_url")

    if [ "$existing_files" = "INVALID_JSON_RESPONSE" ]; then
        log_message "Error: Invalid JSON response when checking for existing files"
        return 1
    fi

    local web_file
    web_file=$(jq -n \
        --arg name "$file_name" \
        --arg partial_url "$partial_url" \
        --arg website_id "$website_id" \
        --arg publishing_state_id "$publishing_state_id" \
        --arg parent_page_id "$parent_page_id" \
        '{
            "mspp_name": $name,
            "mspp_partialurl": $partial_url,
            "mspp_websiteid@odata.bind": "/mspp_websites(\($website_id))",
            "mspp_publishingstateid@odata.bind": "/mspp_publishingstates(\($publishing_state_id))"
        } + if ($parent_page_id != "" and $parent_page_id != "null") then {"mspp_parentpageid@odata.bind": "/mspp_webpages(\($parent_page_id))"} else {} end')

    local web_file_id
    local existing_files_count=$(echo "$existing_files" | jq '.value | length' 2>/dev/null)
    if [ $? -eq 0 ] && [ "$existing_files_count" -gt 0 ]; then
        web_file_id=$(echo "$existing_files" | jq -r '.value[0].mspp_webfileid')
        local update_url="${API_URL}mspp_webfiles($web_file_id)"
        local response=$(invoke_dataverse_api "PATCH" "$update_url" "$web_file" true)
        if [ "$response" = "INVALID_JSON_RESPONSE" ]; then
            log_message "Error: Invalid JSON response when updating existing web file"
            return 1
        fi
    else
        local response=$(invoke_dataverse_api "POST" "${API_URL}mspp_webfiles" "$web_file")
        if [ "$response" = "INVALID_JSON_RESPONSE" ]; then
            log_message "Error: Invalid JSON response when creating new web file"
            return 1
        fi
        web_file_id=$(echo "$response" | jq -r '.mspp_webfileid')
    fi

    if [ -z "$web_file_id" ] || [ "$web_file_id" == "null" ]; then
        log_message "Error: Failed to create or update web file - $file_name"
        return 1
    fi

    log_message "Successfully created/updated web file: $file_name with ID: $web_file_id"

    local existing_row=$(invoke_dataverse_api "GET" "${API_URL}powerpagecomponents($web_file_id)")
    if [ "$existing_row" = "INVALID_JSON_RESPONSE" ]; then
        log_message "Error: Invalid JSON response when getting existing row for web file"
        return 1
    fi

    local file_update_payload
    file_update_payload=$(jq -n \
        --arg id "$(echo "$existing_row" | jq -r '.powerpagecomponentid')" \
        --arg name "$(echo "$existing_row" | jq -r '.name')" \
        --arg content "$file_content" \
        '{
            "powerpagecomponentid": $id,
            "name": $name,
            "filecontent": $content
        }')

    local flow_response=$(curl -s -X POST "$(echo $config | jq -r '.FlowURL')" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d "$file_update_payload")

    log_message "Flow response: $flow_response"

    if [ $? -ne 0 ]; then
        log_message "Error updating file content via Flow"
        return 1
    fi

    log_message "Successfully updated file content for: $file_name"
    return 0
}

write_hierarchy() {
    local path="$1"
    local parent_page_id="$2"
    local website_id=$(echo $config | jq -r '.WebsiteId')

    if [ ! -d "$path" ]; then
        log_message "Error: Directory not found - $path"
        return 1
    fi

    for item in "$path"/*; do
        if [ -f "$item" ]; then
            log_message "Processing file: $item"
            if ! create_web_file "$item" "$parent_page_id"; then
                log_message "Error processing file: $item"
                # Uncomment the next line if you want to stop processing on first error
                # return 1
            fi
        elif [ -d "$item" ]; then
            log_message "Processing folder: $item"
            local new_page_id=$(create_web_page "$(basename "$item")" "$parent_page_id")
            if [ $? -eq 0 ] && [ -n "$new_page_id" ] && [ "$new_page_id" != "null" ]; then
                if ! write_hierarchy "$item" "$new_page_id"; then
                    log_message "Error processing subfolder: $item"
                    # Uncomment the next line if you want to stop processing on first error
                    # return 1
                fi
            else
                log_message "Error creating page for folder: $item"
                # Uncomment the next line if you want to stop processing on first error
                # return 1
            fi
        fi
    done

    return 0
}

create_web_template() {
    local file_path="$1"
    local website_id=$(echo $config | jq -r '.WebsiteId')

    log_message "Creating web template from file: $file_path"

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        log_message "Error: Template file not found - $file_path"
        return 1
    fi

    local filename=$(basename "$file_path")
    local markup=$(cat "$file_path" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

    local web_template_payload
    web_template_payload=$(jq -n \
        --arg name "${filename%.*}" \
        --arg website_id "$website_id" \
        --arg source "$markup" \
        '{
            "mspp_name": $name,
            "mspp_websiteid@odata.bind": "/mspp_websites(\($website_id))",
            "mspp_source": $source
        }')

    local filter="mspp_name eq '${filename%.*}'"
    local check_url="${API_URL}mspp_webtemplates?\$filter=$filter"
    local existing_templates=$(invoke_dataverse_api "GET" "$check_url")

    if [ $? -ne 0 ]; then
        log_message "Error checking for existing templates"
        return 1
    fi

    local web_template_id
    if [ "$(echo "$existing_templates" | jq '.value | length')" -gt 0 ]; then
        web_template_id=$(echo "$existing_templates" | jq -r '.value[0].mspp_webtemplateid')
        local update_url="${API_URL}mspp_webtemplates($web_template_id)"
        local response=$(invoke_dataverse_api "PATCH" "$update_url" "$web_template_payload" true)
        if [ $? -ne 0 ]; then
            log_message "Error updating existing web template"
            return 1
        fi
    else
        local response=$(invoke_dataverse_api "POST" "${API_URL}mspp_webtemplates" "$web_template_payload")
        if [ $? -ne 0 ]; then
            log_message "Error creating new web template"
            return 1
        fi
        web_template_id=$(echo "$response" | jq -r '.mspp_webtemplateid')
    fi

    if [ -z "$web_template_id" ] || [ "$web_template_id" == "null" ]; then
        log_message "Error: Failed to create or update web template - $filename"
        return 1
    fi

    log_message "Successfully created/updated web template: $filename with ID: $web_template_id"

    local web_template_header=$(echo $config | jq -r '.WebTemplateHeader')
    local web_template_footer=$(echo $config | jq -r '.WebTemplateFooter')
    if [ "${filename%.*}" = "$web_template_header" ] || [ "${filename%.*}" = "$web_template_footer" ]; then
        local lookup_name=$([ "${filename%.*}" = "$web_template_header" ] && echo "mspp_headerwebtemplateid@odata.bind" || echo "mspp_footerwebtemplateid@odata.bind")
        local website_update_payload
        website_update_payload=$(jq -n \
            --arg lookup_name "$lookup_name" \
            --arg web_template_id "$web_template_id" \
            '{($lookup_name): "/mspp_webtemplates(\($web_template_id))"}')
        invoke_dataverse_api "PATCH" "${API_URL}mspp_websites($website_id)" "$website_update_payload" true
    fi

    return 0
}

create_snippets() {
    local website_id=$(echo $config | jq -r '.WebsiteId')
    local english_language_id="$ENGLISH_LANGUAGE_ID"
    local french_language_id="$FRENCH_LANGUAGE_ID"
    local snippets_json=$(cat "$(echo $config | jq -r '.BasePathSnippets')")

    echo "$snippets_json" | jq -c 'to_entries[]' | while read -r entry; do
        local snippet_name=$(echo "$entry" | jq -r '.key')
        local snippet_content_english=$(echo "$entry" | jq -r '.value[0]')
        local snippet_content_french=$(echo "$entry" | jq -r '.value[1]')

        create_or_update_snippet "$snippet_name" "$snippet_content_english" "$english_language_id"
        create_or_update_snippet "$snippet_name" "$snippet_content_french" "$french_language_id"
    done
}

create_or_update_snippet() {
    local snippet_name="$1"
    local content="$2"
    local language_id="$3"
    local website_id=$(echo $config | jq -r '.WebsiteId')

    local snippet_payload
    snippet_payload=$(jq -n \
        --arg name "$snippet_name" \
        --arg website_id "$website_id" \
        --arg value "$content" \
        --arg language_id "$language_id" \
        '{
            "mspp_name": $name,
            "mspp_websiteid@odata.bind": "/mspp_websites(\($website_id))",
            "mspp_value": $value,
            "mspp_contentsnippetlanguageid@odata.bind": "/mspp_websitelanguages(\($language_id))"
        }')

    local filter="(mspp_name eq '$snippet_name' and _mspp_contentsnippetlanguageid_value eq $language_id)"
    local check_url="${API_URL}mspp_contentsnippets?\$filter=$filter"
    local existing_snippets=$(invoke_dataverse_api "GET" "$check_url")

    if [ "$(echo $existing_snippets | jq '.value | length')" -gt 0 ]; then
        local existing_snippet_id=$(echo $existing_snippets | jq -r '.value[0].mspp_contentsnippetid')
        local update_url="${API_URL}mspp_contentsnippets($existing_snippet_id)"
        invoke_dataverse_api "PATCH" "$update_url" "$snippet_payload" true
    else
        invoke_dataverse_api "POST" "${API_URL}mspp_contentsnippets" "$snippet_payload"
    fi
}

write_templates() {
    local folder_path="$1"
    log_message "Processing templates in folder: $(basename "$folder_path")"
    
    for file in "$folder_path"/*; do
        if [ -f "$file" ]; then
            log_message "Processing template file: $(basename "$file")"
            local markup=$(cat "$file")
            local template_name=$(basename "$file" | sed 's/\.[^.]*$//')
            create_web_template "$markup" "$template_name"
        fi
    done
}

update_home_page() {
    local page_template_name="$1"
    local website_id=$(echo $config | jq -r '.WebsiteId')

    local filter="mspp_name eq '$page_template_name'"
    local check_url="${API_URL}mspp_pagetemplates?\$filter=$filter"
    local existing_templates=$(invoke_dataverse_api "GET" "$check_url")

    if [ "$(echo $existing_templates | jq '.value | length')" -gt 0 ]; then
        local page_template_id=$(echo $existing_templates | jq -r '.value[0].mspp_pagetemplateid')
        
        local update_url="${API_URL}mspp_webpages($HOME_PAGE_ID)"
        local web_page_payload
        web_page_payload=$(jq -n \
            --arg page_template_id "$page_template_id" \
            '{"mspp_pagetemplateid@odata.bind": "/mspp_pagetemplates(\($page_template_id))"}')
        invoke_dataverse_api "PATCH" "$update_url" "$web_page_payload" true

        update_content_page "$HOME_CONTENT_PAGE_EN"
        update_content_page "$HOME_CONTENT_PAGE_FR"
    else
        log_message "Page template '$page_template_name' not found."
    fi
}

update_content_page() {
    local page_id="$1"
    local update_url="${API_URL}mspp_webpages($page_id)"
    local content_page_payload='{"mspp_copy": ""}'
    invoke_dataverse_api "PATCH" "$update_url" "$content_page_payload" true
}

install_portal_template() {
    local zip_file=$(echo $config | jq -r '.ZipFilePath')
    local extraction_path=$(echo $config | jq -r '.ExtractionPath')
    local theme_root=$(echo $config | jq -r '.ThemeRootFolderName')
    local base_path=$(echo $config | jq -r '.BasePath')
    local base_path_templates="${base_path}liquid/webtemplates"

    log_message "Checking zip file: $zip_file"
    if [ ! -f "$zip_file" ]; then
        log_message "Error: Zip file not found at $zip_file"
        log_message "Current directory: $(pwd)"
        log_message "Files in $(dirname "$zip_file"):"
        ls -l "$(dirname "$zip_file")"
        return 1
    fi

    log_message "Checking extraction path: $extraction_path"
    if [ ! -d "$extraction_path" ]; then
        log_message "Error: Extraction path does not exist: $extraction_path"
        return 1
    fi

    log_message "Unzipping file..."
    unzip -o "$zip_file" -d "$extraction_path"
    log_message "Extracted theme to: $extraction_path"

    create_snippets
    
    log_message "Checking templates directory: $base_path_templates"
    if [ ! -d "$base_path_templates" ]; then
        log_message "Error: Templates directory not found: $base_path_templates"
    else
        write_templates "$base_path_templates"
    fi

    update_home_page "$(echo $config | jq -r '.PageTemplateNameNewHome')"

    local full_theme_path="$extraction_path$theme_root"
    log_message "Checking theme root folder: $full_theme_path"
    if [ ! -d "$full_theme_path" ]; then
        log_message "Error: Theme root folder not found: $full_theme_path"
    else
        write_hierarchy "$full_theme_path" "$HOME_PAGE_ID"
    fi

    update_baseline_styles "$HOME_PAGE_ID"
}

# Main execution
main() {
    log_message "Script started"
    load_config

    TOKEN=$(get_auth_token)
    API_URL="https://$(echo $config | jq -r '.CrmInstance').api.crm3.dynamics.com/api/data/v9.2/"

    PAGE_TEMPLATE_ID=$(get_page_template_id)
    PUBLISHING_STATE_ID=$(get_publishing_state_id)
    ENGLISH_LANGUAGE_ID=$(get_language_id "$(echo $config | jq -r '.EnglishLanguageCode')")
    FRENCH_LANGUAGE_ID=$(get_language_id "$(echo $config | jq -r '.FrenchLanguageCode')")
    HOME_PAGE_ID=$(get_home_page_id)
    HOME_CONTENT_PAGE_EN=$(get_home_page_id "$ENGLISH_LANGUAGE_ID")
    HOME_CONTENT_PAGE_FR=$(get_home_page_id "$FRENCH_LANGUAGE_ID")

    install_portal_template

    log_message "Script ended"
}

# Run the script
main