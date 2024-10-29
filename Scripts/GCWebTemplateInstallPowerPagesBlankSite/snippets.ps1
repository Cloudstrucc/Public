# Configuration
$clientId = "dbe024e7-ea5c-4712-8a8e-4efa6da46fce"
$tenantId = "7030e590-392c-41bd-a573-8fa48f815afd"
$clientSecret = ""
$crmInstance = "ftnc-dev"
$websiteId = "438c4c81-3717-4fd9-95b6-efc91b4434cd"
$englishLanguageId = "4739b1ca-56fb-4e83-b578-df9537eaccf0"
$frenchLanguageId = "d1ca145d-b223-ef11-840a-000d3a8407cf"

# Auth and API setup
$authority = "https://login.microsoftonline.com/$tenantId"
$resource = "https://$crmInstance.api.crm3.dynamics.com"
$tokenEndpoint = "$authority/oauth2/v2.0/token"

$body = @{
    client_id     = $clientId
    scope         = "$resource/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

$authResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body
$token = $authResponse.access_token

$headers = @{
    "Authorization" = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}

$apiUrl = "$resource/api/data/v9.2/"

# Function to upsert a content snippet
function Upsert-ContentSnippet {
    param (
        [string]$name,
        [string]$value,
        [string]$languageId
    )

    $filter = "mspp_name eq '$name' and _mspp_contentsnippetlanguageid_value eq '$languageId'"
    $checkUrl = $apiUrl + "mspp_contentsnippets?`$filter=$filter"

    $existingSnippet = Invoke-RestMethod -Uri $checkUrl -Headers $headers -Method Get
    
    $snippetData = @{
        mspp_name = $name
        mspp_value = $value
        "mspp_websiteid@odata.bind" = "/mspp_websites($websiteId)"
        "mspp_contentsnippetlanguageid@odata.bind" = "/mspp_websitelanguages($languageId)"
    }

    if ($existingSnippet.value.Count -gt 0) {
        $snippetId = $existingSnippet.value[0].mspp_contentsnippetid
        $updateUrl = $apiUrl + "mspp_contentsnippets($snippetId)"
        Invoke-RestMethod -Uri $updateUrl -Headers $headers -Method Patch -Body ($snippetData | ConvertTo-Json)
        Write-Host "Updated snippet: $name"
    }
    else {
        Invoke-RestMethod -Uri ($apiUrl + "mspp_contentsnippets") -Headers $headers -Method Post -Body ($snippetData | ConvertTo-Json)
        Write-Host "Created snippet: $name"
    }
}

# Content snippets data
$snippets = @(
    @{
        Name = "FT/Footer/AboutSite"
        EnglishValue = "About this site"
        FrenchValue = "À propos de ce site"
    },
    @{
        Name = "FT/Footer/AgencyFullName"
        EnglishValue = "Financial Transactions and Reports Analysis Centre of Canada"
        FrenchValue = "Centre d'analyse des opérations et déclarations financières du Canada"
    },
    @{
        Name = "FT/Footer/ContactFinLink"
        EnglishValue = '<a href="/contact-contactez/1-en" data-gc-analytics-customclick="FT/Footer/ContactFin:Contact FINTRAC">Contact FINTRAC</a>'
        FrenchValue = '<a href="/contact-contactez/1-fr" data-gc-analytics-customclick="FT/Footer/ContactFin:Communiquer avec CANAFE">Communiquer avec CANAFE</a>'
    },
    @{
        Name = "FT/Footer/FintracNewsLink"
        EnglishValue = '<a href="/new-neuf/1-en" data-gc-analytics-customclick="FT/Footer/FintracNews:FINTRAC news">FINTRAC news</a>'
        FrenchValue = '<a href="/new-neuf/1-fr" data-gc-analytics-customclick="FT/Footer/FintracNews:Nouvelles de CANAFE">Nouvelles de CANAFE</a>'
    },
    @{
        Name = "FT/Footer/JoinMailingListLink"
        EnglishValue = '<a href="/contact-contactez/list-liste-en" data-gc-analytics-customclick="FT/Footer/JoinMailingList:Join FINTRACs mailing list">Join FINTRACs mailing list</a>'
        FrenchValue = '<a href="/contact-contactez/list-liste-fr" data-gc-analytics-customclick="FT/Footer/JoinMailingList:Joindre la liste de diffusion de CANAFE">Joindre la liste de diffusion de CANAFE</a>'
    },
    @{
        Name = "CS/GLOBAL/GOVCANADA"
        EnglishValue = "Government of Canada"
        FrenchValue = "Gouvernement du Canada"
    },
    @{
        Name = "FT/Footer/AllContactsLink"
        EnglishValue = '<a href="https://www.canada.ca/en/contact.html" data-gc-analytics-customclick="FT/Footer/AllContacts:All contacts">All contacts</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/contact.html" data-gc-analytics-customclick="FT/Footer/AllContacts:Toutes les coordonnées">Toutes les coordonnées</a>'
    },
    @{
        Name = "FT/Footer/DepartmentsAgenciesLink"
        EnglishValue = '<a href="https://www.canada.ca/en/government/dept.html" data-gc-analytics-customclick="FT/Footer/DepartmentsAgencies:Departments and agencies">Departments and agencies</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/government/dept.html" data-gc-analytics-customclick="FT/Footer/DepartmentsAgencies:Ministères et organismes">Ministères et organismes</a>'
    },
    @{
        Name = "FT/Footer/AboutGovernmentLink"
        EnglishValue = '<a href="https://www.canada.ca/en/government/system.html" data-gc-analytics-customclick="FT/Footer/AboutGovernment:About government">About government</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/government/system.html" data-gc-analytics-customclick="FT/Footer/AboutGovernment:À propos du gouvernement">À propos du gouvernement</a>'
    },
    @{
        Name = "FT/Footer/ThemesTopics"
        EnglishValue = "Themes and topics"
        FrenchValue = "Thèmes et sujets"
    },
    @{
        Name = "FT/Footer/JobsLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/jobs.html" data-gc-analytics-customclick="FT/Footer/Jobs:Jobs">Jobs</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/jobs.html" data-gc-analytics-customclick="FT/Footer/Jobs:Emplois">Emplois</a>'
    },
    @{
        Name = "FT/Footer/ImmigrationCitizenshipLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/immigration-citizenship.html" data-gc-analytics-customclick="FT/Footer/ImmigrationCitizenship:Immigration and citizenship">Immigration and citizenship</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/immigration-citizenship.html" data-gc-analytics-customclick="FT/Footer/ImmigrationCitizenship:Immigration et citoyenneté">Immigration et citoyenneté</a>'
    },
    @{
        Name = "FT/Footer/TravelTourismLink"
        EnglishValue = '<a href="https://travel.gc.ca/" data-gc-analytics-customclick="FT/Footer/TravelTourism:Travel and tourism">Travel and tourism</a>'
        FrenchValue = '<a href="https://travel.gc.ca/francais" data-gc-analytics-customclick="FT/Footer/TravelTourism:Voyage et tourisme">Voyage et tourisme</a>'
    },
    @{
        Name = "FT/Footer/BusinessLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/business.html" data-gc-analytics-customclick="FT/Footer/Business:Business">Business</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/business.html" data-gc-analytics-customclick="FT/Footer/Business:Entreprises">Entreprises</a>'
    },
    @{
        Name = "FT/Footer/BenefitsLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/benefits.html" data-gc-analytics-customclick="FT/Footer/Benefits:Benefits">Benefits</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/benefits.html" data-gc-analytics-customclick="FT/Footer/Benefits:Prestations">Prestations</a>'
    },
    @{
        Name = "FT/Footer/HealthLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/health.html" data-gc-analytics-customclick="FT/Footer/Health:Health">Health</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/health.html" data-gc-analytics-customclick="FT/Footer/Health:Santé">Santé</a>'
    },
    @{
        Name = "FT/Footer/TaxesLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/taxes.html" data-gc-analytics-customclick="FT/Footer/Taxes:Taxes">Taxes</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/taxes.html" data-gc-analytics-customclick="FT/Footer/Taxes:Impôts">Impôts</a>'
    },
    @{
        Name = "FT/Footer/EnvironmentLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/environment.html" data-gc-analytics-customclick="FT/Footer/Environment:Environment and natural resources">Environment and natural resources</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/environment.html" data-gc-analytics-customclick="FT/Footer/Environment:Environnement et ressources naturelles">Environnement et ressources naturelles</a>'
    },
    @{
        Name = "FT/Footer/NationalSecurityLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/defence.html" data-gc-analytics-customclick="FT/Footer/NationalSecurity:National security and defence">National security and defence</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/defence.html" data-gc-analytics-customclick="FT/Footer/NationalSecurity:Sécurité nationale et défense">Sécurité nationale et défense</a>'
    },
    @{
        Name = "FT/Footer/CultureLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/culture.html" data-gc-analytics-customclick="FT/Footer/Culture:Culture, history and sport">Culture, history and sport</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/culture.html" data-gc-analytics-customclick="FT/Footer/Culture:Culture, histoire et sport">Culture, histoire et sport</a>'
    },
    @{
        Name = "FT/Footer/PolicingLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/policing.html" data-gc-analytics-customclick="FT/Footer/Policing:Policing, justice and emergencies">Policing, justice and emergencies</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/policing.html" data-gc-analytics-customclick="FT/Footer/Policing:Services de police, justice et urgences">Services de police, justice et urgences</a>'
    },
    @{
        Name = "FT/Footer/TransportLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/transport.html" data-gc-analytics-customclick="FT/Footer/Transport:Transport and infrastructure">Transport and infrastructure</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/transport.html" data-gc-analytics-customclick="FT/Footer/Transport:Transport et infrastructure">Transport et infrastructure</a>'
    },
    @{
        Name = "FT/Footer/CanadaWorldLink"
        EnglishValue = '<a href="https://international.gc.ca/world-monde/index.aspx?lang=eng" data-gc-analytics-customclick="FT/Footer/CanadaWorld:Canada and the world">Canada and the world</a>'
        FrenchValue = '<a href="https://international.gc.ca/world-monde/index.aspx?lang=fra" data-gc-analytics-customclick="FT/Footer/CanadaWorld:Le Canada et le monde">Le Canada et le monde</a>'
    },
    @{
        Name = "FT/Footer/MoneyFinanceLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/finance.html" data-gc-analytics-customclick="FT/Footer/MoneyFinance:Money and finance">Money and finance</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/finance.html" data-gc-analytics-customclick="FT/Footer/MoneyFinance:Argent et finances">Argent et finances</a>'
    },
    @{
        Name = "FT/Footer/ScienceInnovationLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/science.html" data-gc-analytics-customclick="FT/Footer/ScienceInnovation:Science and innovation">Science and innovation</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/science.html" data-gc-analytics-customclick="FT/Footer/ScienceInnovation:Science et innovation">Science et innovation</a>'
    },
    @{
        Name = "FT/Footer/IndigenousPeoplesLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/indigenous-peoples.html" data-gc-analytics-customclick="FT/Footer/IndigenousPeoples:Indigenous peoples">Indigenous peoples</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/indigenous-peoples.html" data-gc-analytics-customclick="FT/Footer/IndigenousPeoples:Peuples autochtones">Peuples autochtones</a>'
    },
    @{
        Name = "FT/Footer/VeteransMilitaryLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/veterans-military.html" data-gc-analytics-customclick="FT/Footer/VeteransMilitary:Veterans and military">Veterans and military</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/veterans-military.html" data-gc-analytics-customclick="FT/Footer/VeteransMilitary:Anciens combattants et militaires">Anciens combattants et militaires</a>'
    },
    @{
        Name = "FT/Footer/YouthLink"
        EnglishValue = '<a href="https://www.canada.ca/en/services/youth.html" data-gc-analytics-customclick="FT/Footer/Youth:Youth">Youth</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/services/youth.html" data-gc-analytics-customclick="FT/Footer/Youth:Jeunesse">Jeunesse</a>'
    },
    @{
        Name = "FT/Footer/SocialMediaLink"
        EnglishValue = '<a href="https://www.canada.ca/en/social.html" data-gc-analytics-customclick="FT/Footer/SocialMedia:Social media">Social media</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/social.html" data-gc-analytics-customclick="FT/Footer/SocialMedia:Médias sociaux">Médias sociaux</a>'
    },
    @{
        Name = "FT/Footer/MobileApplicationsLink"
        EnglishValue = '<a href="https://www.canada.ca/en/mobile.html" data-gc-analytics-customclick="FT/Footer/MobileApplications:Mobile applications">Mobile applications</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/mobile.html" data-gc-analytics-customclick="FT/Footer/MobileApplications:Applications mobiles">Applications mobiles</a>'
    },
    @{
        Name = "FT/Footer/AboutCanadaCaLink"
        EnglishValue = '<a href="https://www.canada.ca/en/government/about.html" data-gc-analytics-customclick="FT/Footer/AboutCanadaCa:About Canada.ca">About Canada.ca</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/government/about.html" data-gc-analytics-customclick="FT/Footer/AboutCanadaCa:À propos de Canada.ca">À propos de Canada.ca</a>'
    },
    @{
        Name = "FT/Footer/TermsConditionsLink"
        EnglishValue = '<a href="https://www.canada.ca/en/transparency/terms.html" data-gc-analytics-customclick="FT/Footer/TermsConditions:Terms and conditions">Terms and conditions</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/transparency/terms.html" data-gc-analytics-customclick="FT/Footer/TermsConditions:Avis">Avis</a>'
    },
    @{
        Name = "FT/Footer/PrivacyLink"
        EnglishValue = '<a href="https://www.canada.ca/en/transparency/privacy.html" data-gc-analytics-customclick="FT/Footer/Privacy:Privacy">Privacy</a>'
        FrenchValue = '<a href="https://www.canada.ca/fr/transparency/privacy.html" data-gc-analytics-customclick="FT/Footer/Privacy:Confidentialité">Confidentialité</a>'
    },
    @{
        Name = "FT/Footer/GovernmentCanadaSymbol"
        EnglishValue = "Symbol of the Government of Canada"
        FrenchValue = "Symbole du gouvernement du Canada"
    }
)
 
# Upsert snippets
foreach ($snippet in $snippets) {
    Upsert-ContentSnippet -name $snippet.Name -value $snippet.EnglishValue -languageId $englishLanguageId
    Upsert-ContentSnippet -name $snippet.Name -value $snippet.FrenchValue -languageId $frenchLanguageId
}
 
Write-Host "Content snippet upsert process completed."