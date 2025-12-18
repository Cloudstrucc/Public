# Microsoft Purview Sensitive Information Types Reference Guide

## Executive Summary

Microsoft Purview Sensitive Information Types (SITs) are pattern-based classifiers that identify and protect sensitive data across your Microsoft 365 environment. These classifiers detect specific patterns such as social security numbers, credit card numbers, passport numbers, and other regulated or confidential information through regular expressions, keyword lists, and checksum validation.

### Why Sensitive Information Types Matter

Sensitive Information Types form the foundation of data protection in Microsoft Purview. They enable organizations to:

- **Comply with Regulations**: Meet requirements for GDPR, HIPAA, PCI-DSS, PIPEDA, and other data protection frameworks
- **Prevent Data Loss**: Automatically detect and block sensitive data from leaving the organization through email, Teams, SharePoint, or endpoint devices
- **Classify Content**: Apply sensitivity labels automatically based on detected sensitive content
- **Manage Risk**: Identify where sensitive data resides across your digital estate through Content Explorer
- **Support Investigations**: Enable eDiscovery and compliance investigations by locating regulated data

### When to Apply Sensitive Information Types

SITs should be applied in the following scenarios:

- **Data Loss Prevention (DLP) Policies**: Block or warn users when sharing sensitive data externally
- **Auto-Labeling Policies**: Automatically apply sensitivity labels to documents containing specific data patterns
- **Retention Policies**: Apply retention or deletion rules to content containing sensitive information
- **Insider Risk Management**: Monitor for anomalous behavior involving sensitive data
- **Communication Compliance**: Scan communications for sensitive data sharing violations
- **Protected B and Classified Environments**: Identify and protect government-regulated data types

### Confidence Levels

Each SIT operates with confidence levels that indicate detection accuracy:

| Level | Accuracy Score | Description |
|-------|---------------|-------------|
| Low | 65 or below | Basic pattern match with minimal supporting evidence |
| Medium | 75 | Pattern match with some supporting keywords or context |
| High | 85+ | Pattern match with strong supporting evidence and validation |

---

## Global / Generic

These sensitive information types apply globally and are not specific to any country or region.

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Credit card number | Detects credit card numbers from major issuers including Visa, Mastercard, American Express, Discover, JCB, and Diners Club |
| International banking account number (IBAN) | Detects IBAN numbers covering 60+ countries/regions for international bank transfers |
| SWIFT code | Detects Society for Worldwide Interbank Financial Telecommunication codes used for international wire transfers |
| IP address | Detects both IPv4 and IPv6 network addresses |
| IP Address v4 | Detects specifically formatted IPv4 addresses |
| IP Address v6 | Detects specifically formatted IPv6 addresses |
| ABA routing number | Detects American Bankers Association routing transit numbers for US financial institutions |
| All Physical Addresses | Bundled SIT that detects physical addresses across all supported regions |
| All full names | Bundled SIT that detects person names across multiple languages and formats |

---

## Medical and Healthcare

These sensitive information types detect healthcare-related terminology and identifiers.

| Sensitive Information Type | Description |
|---------------------------|-------------|
| All medical terms and conditions | Bundled SIT covering all medical terminology categories |
| Blood test terms | Detects terminology related to blood tests and laboratory results |
| Brand medication names | Detects proprietary/brand names of pharmaceutical products |
| Generic medication names | Detects generic/non-proprietary names of medications |
| Types of medication | Detects general medication type classifications |
| Diseases | Detects names of medical conditions and diseases |
| Lab test terms | Detects laboratory test terminology and procedures |
| Lifestyles that relate to medical conditions | Detects lifestyle factors relevant to medical conditions |
| Medical specialities | Detects medical specialty and subspecialty terminology |
| Surgical procedures | Detects surgical procedure names and terminology |
| International classification of diseases (ICD-10-CM) | Detects ICD-10-CM diagnostic codes |
| International classification of diseases (ICD-9-CM) | Detects ICD-9-CM diagnostic codes |
| Impairments Listed In The U.S. Disability Evaluation Under Social Security | Detects disability impairment classifications |
| Drug Enforcement Agency (DEA) number | Detects US DEA registration numbers for controlled substance prescribers |
| Medicare Beneficiary Identifier (MBI) card | Detects US Medicare beneficiary identification numbers |

---

## Credentials and Security Keys

These sensitive information types detect authentication credentials, API keys, and security tokens.

| Sensitive Information Type | Description |
|---------------------------|-------------|
| All credentials | Bundled SIT containing all credential scanning types |
| General password | Detects password patterns in documents and communications |
| General Symmetric key | Detects symmetric encryption keys |
| Client secret / API key | Detects generic client secrets and API keys |
| User login credentials | Detects username and password combinations |
| Http authorization header | Detects HTTP authorization header values |
| X.509 certificate private key | Detects X.509 certificate private key material |

### Azure Credentials

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Azure App Service deployment password | Azure App Service deployment credentials |
| Azure Batch shared access key | Azure Batch service access keys |
| Azure Bot Framework secret key | Azure Bot Framework authentication keys |
| Azure Bot service app secret | Azure Bot Service application secrets |
| Azure Cognitive Search API key | Azure Cognitive Search service keys |
| Azure Cognitive Service key | Azure Cognitive Services authentication keys |
| Azure Container Registry access key | Azure Container Registry access credentials |
| Azure Cosmos DB account access key | Azure Cosmos DB authentication keys |
| Azure Databricks personal access token | Azure Databricks personal access tokens |
| Azure DevOps app secret | Azure DevOps application secrets |
| Azure DevOps personal access token | Azure DevOps PAT tokens |
| Azure DocumentDB auth key | Azure DocumentDB authentication keys |
| Azure EventGrid access key | Azure Event Grid access keys |
| Azure Function Master / API key | Azure Functions master and API keys |
| Azure IAAS database connection string and Azure SQL connection string | Azure database connection strings |
| Azure IoT connection string | Azure IoT Hub connection strings |
| Azure IoT shared access key | Azure IoT shared access keys |
| Azure Logic app shared access signature | Azure Logic Apps SAS tokens |
| Azure Machine Learning web service API key | Azure ML service API keys |
| Azure Maps subscription key | Azure Maps subscription keys |
| Azure publish setting password | Azure publish settings credentials |
| Azure Redis cache connection string | Azure Redis connection strings |
| Azure Redis cache connection string password | Azure Redis password components |
| Azure SAS | Azure Shared Access Signatures |
| Azure service bus connection string | Azure Service Bus connection strings |
| Azure service bus shared access signature | Azure Service Bus SAS tokens |
| Azure Shared Access key / Web Hook token | Azure shared keys and webhook tokens |
| Azure SignalR access key | Azure SignalR access keys |
| Azure SQL connection string | Azure SQL database connection strings |
| Azure storage account access key | Azure Storage account access keys |
| Azure storage account key | Azure Storage account keys |
| Azure Storage account key (generic) | Generic Azure Storage keys |
| Azure Storage account shared access signature | Azure Storage SAS tokens |
| Azure Storage account shared access signature for high risk resources | High-risk Azure Storage SAS tokens |
| Azure subscription management certificate | Azure management certificates |
| SQL Server connection string | SQL Server database connection strings |

### Microsoft Entra ID (Azure AD)

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Microsoft Entra client access token | Entra ID client access tokens |
| Microsoft Entra client secret | Entra ID application client secrets |
| Microsoft Entra user Credentials | Entra ID user authentication credentials |

### Third-Party Credentials

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Amazon S3 Client Secret Access Key | AWS S3 secret access keys |
| GitHub Personal Access Token | GitHub PAT tokens |
| Google API key | Google Cloud and service API keys |
| Slack access token | Slack API and bot tokens |
| Microsoft Bing maps key | Bing Maps API keys |
| ASP.NET machine Key | ASP.NET machine key values |

---

## North America

### United States

| Sensitive Information Type | Description |
|---------------------------|-------------|
| U.S. social security number (SSN) | Detects 9-digit US Social Security Numbers |
| U.S. individual taxpayer identification number (ITIN) | Detects US Individual Taxpayer Identification Numbers |
| U.S. bank account number | Detects US bank account numbers |
| U.S. driver's license number | Detects US driver's license numbers across all states |
| U.S. physical addresses | Detects US postal addresses |
| U.S./U.K. passport number | Detects US and UK passport numbers |

### Canada

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Canada social insurance number | Detects 9-digit Canadian Social Insurance Numbers (SIN) |
| Canada passport number | Detects Canadian passport numbers |
| Canada driver's license number | Detects Canadian provincial driver's license numbers |
| Canada bank account number | Detects Canadian bank account numbers |
| Canada health service number | Detects provincial health card numbers |
| Canada personal health identification number (PHIN) | Detects Personal Health Information Numbers |
| Canada physical addresses | Detects Canadian postal addresses |

### Mexico

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Mexico Unique Population Registry Code (CURP) | Detects 18-character Mexican population registry codes |

---

## South America

### Argentina

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Argentina national identity (DNI) number | Detects Argentine National Identity Document numbers |
| Argentina Unique Tax Identification Key (CUIT/CUIL) | Detects Argentine tax identification numbers |

### Brazil

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Brazil CPF number | Detects 11-digit Brazilian individual taxpayer registry numbers |
| Brazil legal entity number (CNPJ) | Detects Brazilian legal entity registration numbers |
| Brazil national identification card (RG) | Detects Brazilian national ID card numbers |
| Brazil physical addresses | Detects Brazilian postal addresses |

### Chile

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Chile identity card number | Detects Chilean national identity card numbers (RUN/RUT) |

### Ecuador

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Ecuador Unique Identification Number | Detects Ecuadorian unique identification numbers |

---

## European Union

These SITs provide EU-wide detection capabilities across member states.

| Sensitive Information Type | Description |
|---------------------------|-------------|
| EU debit card number | Detects EU-formatted debit card numbers |
| EU driver's license number | Bundled SIT for driver's licenses across EU member states |
| EU national identification number | Bundled SIT for national ID numbers across EU member states |
| EU passport number | Bundled SIT for passport numbers across EU member states |
| EU social security number or equivalent identification | Bundled SIT for social security numbers across EU |
| EU Tax identification number | Bundled SIT for tax IDs across EU member states |

---

## United Kingdom

| Sensitive Information Type | Description |
|---------------------------|-------------|
| U.K. national insurance number (NINO) | Detects UK National Insurance Numbers |
| U.K. national health service number | Detects UK NHS patient numbers |
| U.K. driver's license number | Detects UK driving licence numbers |
| U.K. electoral roll number | Detects UK electoral registration numbers |
| U.K. Unique Taxpayer Reference Number | Detects UK tax reference numbers |
| U.K. physical addresses | Detects UK postal addresses |
| U.S./U.K. passport number | Detects UK passport numbers |

---

## Western Europe

### Germany

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Germany identity card number | Detects German Personalausweis numbers |
| Germany driver's license number | Detects German Führerschein numbers |
| Germany passport number | Detects German Reisepass numbers |
| Germany tax identification number | Detects German Steuer-Identifikationsnummer |
| Germany value added tax number | Detects German Umsatzsteuer-Identifikationsnummer |
| Germany physical addresses | Detects German postal addresses |

### France

| Sensitive Information Type | Description |
|---------------------------|-------------|
| France social security number (INSEE) | Detects French Social Security Numbers (numéro de sécurité sociale) |
| France national id card (CNI) | Detects French Carte Nationale d'Identité numbers |
| France driver's license number | Detects French permis de conduire numbers |
| France passport number | Detects French passport numbers |
| France health insurance number | Detects French health insurance card numbers |
| France tax identification number | Detects French tax identification numbers |
| France value added tax number | Detects French TVA numbers |
| France physical addresses | Detects French postal addresses |

### Belgium

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Belgium national number | Detects Belgian Rijksregisternummer/Numéro national |
| Belgium driver's license number | Detects Belgian driving licence numbers |
| Belgium passport number | Detects Belgian passport numbers |
| Belgium value added tax number | Detects Belgian VAT numbers |
| Belgium physical addresses | Detects Belgian postal addresses |

### Netherlands

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Netherlands citizen's service (BSN) number | Detects Dutch Burgerservicenummer |
| Netherlands driver's license number | Detects Dutch rijbewijs numbers |
| Netherlands passport number | Detects Dutch passport numbers |
| Netherlands tax identification number | Detects Dutch tax ID numbers |
| Netherlands value added tax number | Detects Dutch BTW-identificatienummer |
| Netherlands physical addresses | Detects Dutch postal addresses |

### Luxembourg

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Luxemburg national identification number (natural persons) | Detects Luxembourg national ID for individuals |
| Luxemburg national identification number (non-natural persons) | Detects Luxembourg national ID for legal entities |
| Luxemburg driver's license number | Detects Luxembourg driving licence numbers |
| Luxemburg passport number | Detects Luxembourg passport numbers |
| Luxemburg physical addresses | Detects Luxembourg postal addresses |

### Austria

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Austria social security number | Detects Austrian Sozialversicherungsnummer |
| Austria identity card | Detects Austrian Personalausweis numbers |
| Austria drivers license number | Detects Austrian Führerschein numbers |
| Austria passport number | Detects Austrian Reisepass numbers |
| Austria tax identification number | Detects Austrian Steuernummer |
| Austria value added tax | Detects Austrian UID-Nummer |
| Austria physical addresses | Detects Austrian postal addresses |

### Switzerland

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Switzerland SSN AHV number | Detects Swiss AHV/AVS social security numbers |
| Switzerland physical addresses | Detects Swiss postal addresses |

### Liechtenstein

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Liechtenstein physical addresses | Detects Liechtenstein postal addresses |

---

## Southern Europe

### Italy

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Italy fiscal code | Detects Italian Codice Fiscale |
| Italy driver's license number | Detects Italian patente di guida numbers |
| Italy passport number | Detects Italian passport numbers |
| Italy value added tax number | Detects Italian Partita IVA |
| Italy physical addresses | Detects Italian postal addresses |

### Spain

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Spain DNI | Detects Spanish Documento Nacional de Identidad |
| Spain social security number (SSN) | Detects Spanish social security numbers |
| Spain driver's license number | Detects Spanish permiso de conducir numbers |
| Spain passport number | Detects Spanish passport numbers |
| Spain tax identification number | Detects Spanish NIF/CIF numbers |
| Spain physical addresses | Detects Spanish postal addresses |

### Portugal

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Portugal citizen card number | Detects Portuguese Cartão de Cidadão numbers |
| Portugal driver's license number | Detects Portuguese carta de condução numbers |
| Portugal passport number | Detects Portuguese passport numbers |
| Portugal tax identification number | Detects Portuguese NIF numbers |
| Portugal physical addresses | Detects Portuguese postal addresses |

### Greece

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Greece national ID card | Detects Greek Δελτίο Ταυτότητας numbers |
| Greece Social Security Number (AMKA) | Detects Greek ΑΜΚΑ numbers |
| Greece driver's license number | Detects Greek driving licence numbers |
| Greece passport number | Detects Greek passport numbers |
| Greece tax identification number | Detects Greek ΑΦΜ numbers |
| Greece physical addresses | Detects Greek postal addresses |

### Malta

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Malta identity card number | Detects Maltese ID card numbers |
| Malta driver's license number | Detects Maltese driving licence numbers |
| Malta passport number | Detects Maltese passport numbers |
| Malta tax identification number | Detects Maltese tax ID numbers |
| Malta physical addresses | Detects Maltese postal addresses |

### Cyprus

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Cyprus identity card | Detects Cypriot ID card numbers |
| Cyprus drivers license number | Detects Cypriot driving licence numbers |
| Cyprus passport number | Detects Cypriot passport numbers |
| Cyprus tax identification number | Detects Cypriot TIC numbers |
| Cyprus physical addresses | Detects Cypriot postal addresses |

---

## Northern Europe

### Sweden

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Sweden national ID | Detects Swedish personnummer |
| Sweden driver's license number | Detects Swedish körkort numbers |
| Sweden passport number | Detects Swedish passport numbers |
| Sweden tax identification number | Detects Swedish tax ID numbers |
| Sweden physical addresses | Detects Swedish postal addresses |

### Denmark

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Denmark personal identification number | Detects Danish CPR-nummer |
| Denmark driver's license number | Detects Danish kørekort numbers |
| Denmark passport number | Detects Danish passport numbers |
| Denmark physical addresses | Detects Danish postal addresses |

### Finland

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Finland national ID | Detects Finnish henkilötunnus (HETU) |
| Finland European health insurance number | Detects Finnish EHIC numbers |
| Finland driver's license number | Detects Finnish ajokortti numbers |
| Finland passport number | Detects Finnish passport numbers |
| Finland physical addresses | Detects Finnish postal addresses |

### Norway

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Norway identification number | Detects Norwegian fødselsnummer |
| Norway physical addresses | Detects Norwegian postal addresses |

### Iceland

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Iceland physical addresses | Detects Icelandic postal addresses |

---

## Eastern Europe

### Poland

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Poland national ID (PESEL) | Detects Polish PESEL numbers |
| Poland identity card | Detects Polish dowód osobisty numbers |
| Poland REGON number | Detects Polish business registry numbers |
| Poland driver's license number | Detects Polish prawo jazdy numbers |
| Poland passport number | Detects Polish passport numbers |
| Poland tax identification number | Detects Polish NIP numbers |
| Poland physical addresses | Detects Polish postal addresses |

### Czech Republic

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Czech personal identity number | Detects Czech rodné číslo |
| Czech driver's license number | Detects Czech řidičský průkaz numbers |
| Czech passport number | Detects Czech passport numbers |
| Czech Republic physical addresses | Detects Czech postal addresses |

### Slovakia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Slovakia personal number | Detects Slovak rodné číslo |
| Slovakia driver's license number | Detects Slovak vodičský preukaz numbers |
| Slovakia passport number | Detects Slovak passport numbers |
| Slovakia physical addresses | Detects Slovak postal addresses |

### Hungary

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Hungary personal identification number | Detects Hungarian személyi szám |
| Hungary social security number (TAJ) | Detects Hungarian TAJ numbers |
| Hungary driver's license number | Detects Hungarian vezetői engedély numbers |
| Hungary passport number | Detects Hungarian passport numbers |
| Hungary tax identification number | Detects Hungarian adóazonosító jel |
| Hungary value added tax number | Detects Hungarian ÁFA numbers |
| Hungary physical addresses | Detects Hungarian postal addresses |

### Romania

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Romania personal numeric code (CNP) | Detects Romanian Cod Numeric Personal |
| Romania driver's license number | Detects Romanian permis de conducere numbers |
| Romania passport number | Detects Romanian passport numbers |
| Romania physical addresses | Detects Romanian postal addresses |

### Bulgaria

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Bulgaria uniform civil number | Detects Bulgarian ЕГН (EGN) numbers |
| Bulgaria driver's license number | Detects Bulgarian шофьорска книжка numbers |
| Bulgaria passport number | Detects Bulgarian passport numbers |
| Bulgaria physical addresses | Detects Bulgarian postal addresses |

### Croatia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Croatia personal identification (OIB) number | Detects Croatian Osobni identifikacijski broj |
| Croatia identity card number | Detects Croatian osobna iskaznica numbers |
| Croatia driver's license number | Detects Croatian vozačka dozvola numbers |
| Croatia passport number | Detects Croatian passport numbers |
| Croatia physical addresses | Detects Croatian postal addresses |

### Slovenia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Slovenia Unique Master Citizen Number | Detects Slovenian EMŠO numbers |
| Slovenia driver's license number | Detects Slovenian vozniško dovoljenje numbers |
| Slovenia passport number | Detects Slovenian passport numbers |
| Slovenia tax identification number | Detects Slovenian davčna številka |
| Slovenia physical addresses | Detects Slovenian postal addresses |

### Estonia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Estonia Personal Identification Code | Detects Estonian isikukood |
| Estonia driver's license number | Detects Estonian juhiluba numbers |
| Estonia passport number | Detects Estonian passport numbers |
| Estonia physical addresses | Detects Estonian postal addresses |

### Latvia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Latvia personal code | Detects Latvian personas kods |
| Latvia driver's license number | Detects Latvian vadītāja apliecība numbers |
| Latvia passport number | Detects Latvian passport numbers |
| Latvia physical addresses | Detects Latvian postal addresses |

### Lithuania

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Lithuania personal code | Detects Lithuanian asmens kodas |
| Lithuania driver's license number | Detects Lithuanian vairuotojo pažymėjimas numbers |
| Lithuania passport number | Detects Lithuanian passport numbers |
| Lithuania physical addresses | Detects Lithuanian postal addresses |

---

## Eastern Europe & Central Asia

### Russia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Russia passport number domestic | Detects Russian internal passport numbers |
| Russia passport number international | Detects Russian international passport numbers |

### Ukraine

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Ukraine passport domestic | Detects Ukrainian internal passport numbers |
| Ukraine passport international | Detects Ukrainian international passport numbers |

### Turkey

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Turkey national identification number | Detects Turkish Kimlik Numarası (T.C. Kimlik No) |
| Turkey physical addresses | Detects Turkish postal addresses |

---

## Asia Pacific

### Australia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Australia tax file number | Detects 9-digit Australian Tax File Numbers |
| Australia business number | Detects 11-digit Australian Business Numbers |
| Australia company number | Detects Australian Company Numbers |
| Australia bank account number | Detects Australian bank account numbers |
| Australia drivers license number | Detects Australian state driver's licence numbers |
| Australia medical account number | Detects Medicare card numbers |
| Australia passport number | Detects Australian passport numbers |
| Australia physical addresses | Detects Australian postal addresses |

### New Zealand

| Sensitive Information Type | Description |
|---------------------------|-------------|
| New Zealand inland revenue number | Detects NZ IRD numbers |
| New Zealand bank account number | Detects NZ bank account numbers |
| New Zealand driver's license number | Detects NZ driver licence numbers |
| New Zealand ministry of health number | Detects NZ NHI numbers |
| New Zealand social welfare number | Detects NZ social welfare numbers |
| New Zealand physical addresses | Detects NZ postal addresses |

### Japan

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Japan My Number - Personal | Detects 12-digit Japanese Individual Numbers |
| Japan My Number - Corporate | Detects 13-digit Japanese Corporate Numbers |
| Japan social insurance number (SIN) | Detects Japanese social insurance numbers |
| Japan bank account number | Detects Japanese bank account numbers |
| Japan driver's license number | Detects Japanese 運転免許証 numbers |
| Japan passport number | Detects Japanese passport numbers |
| Japan residence card number | Detects Japanese residence card numbers |
| Japan resident registration number | Detects Japanese resident registration numbers |
| Japan physical addresses | Detects Japanese postal addresses |

### China

| Sensitive Information Type | Description |
|---------------------------|-------------|
| China resident identity card (PRC) number | Detects 18-digit Chinese Resident Identity Card numbers |

### Hong Kong

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Hong Kong identity card (HKID) number | Detects Hong Kong Identity Card numbers |

### Taiwan

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Taiwan national identification number | Detects Taiwan National Identification Numbers |
| Taiwan passport number | Detects Taiwan passport numbers |
| Taiwan-resident certificate (ARC/TARC) number | Detects Taiwan Alien/Taiwan Area Resident Certificate numbers |

### South Korea

| Sensitive Information Type | Description |
|---------------------------|-------------|
| South Korea resident registration number | Detects Korean 주민등록번호 |
| South Korea driver's license number | Detects Korean 운전면허 numbers |
| South Korea passport number | Detects Korean passport numbers |

### India

| Sensitive Information Type | Description |
|---------------------------|-------------|
| India unique identification (Aadhaar) number | Detects 12-digit Aadhaar numbers |
| India permanent account number (PAN) | Detects 10-character Indian PAN |
| India GST Number | Detects Indian Goods and Services Tax Identification Numbers |
| India driver's License Number | Detects Indian driving licence numbers |
| India Voter Id Card | Detects Indian EPIC numbers |

### Indonesia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Indonesia identity card (KTP) number | Detects Indonesian NIK numbers |
| Indonesia driver's license number | Detects Indonesian SIM numbers |
| Indonesia passport number | Detects Indonesian passport numbers |

### Thailand

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Thai population identification code | Detects 13-digit Thai national ID numbers |

### Malaysia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Malaysia identification card number | Detects Malaysian MyKad/NRIC numbers |
| Malaysia passport number | Detects Malaysian passport numbers |

### Singapore

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Singapore national registration identity card (NRIC) number | Detects Singaporean NRIC/FIN numbers |
| Singapore passport number | Detects Singaporean passport numbers |

### Philippines

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Philippines national identification number | Detects Philippine PhilSys ID numbers |
| Philippines unified multi-purpose identification number | Detects Philippine UMID numbers |
| Philippines passport number | Detects Philippine passport numbers |

---

## Middle East

### United Arab Emirates

| Sensitive Information Type | Description |
|---------------------------|-------------|
| U.A.E. identity card number | Detects UAE Emirates ID numbers |
| U.A.E. passport number | Detects UAE passport numbers |

### Saudi Arabia

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Saudi Arabia National ID | Detects Saudi national identification numbers |

### Qatar

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Qatari identification card number | Detects Qatar ID card numbers |

### Israel

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Israel national identification number | Detects Israeli Teudat Zehut numbers |
| Israel bank account number | Detects Israeli bank account numbers |

---

## Africa

### South Africa

| Sensitive Information Type | Description |
|---------------------------|-------------|
| South Africa identification number | Detects 13-digit South African ID numbers |

---

## Ireland

| Sensitive Information Type | Description |
|---------------------------|-------------|
| Ireland personal public service (PPS) number | Detects Irish PPSN |
| Ireland driver's license number | Detects Irish driving licence numbers |
| Ireland passport number | Detects Irish passport numbers |
| Ireland physical addresses | Detects Irish postal addresses |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Global/Generic | 9 |
| Medical and Healthcare | 15 |
| Credentials and Security Keys | 50+ |
| Country-Specific SITs | 170+ |
| **Total Available SITs** | **300+** |

---

## Best Practices for Implementation

1. **Start with High-Confidence Detection**: Begin with high confidence levels to minimize false positives, then adjust as needed
2. **Layer Multiple SITs**: Combine country-specific SITs with generic types for comprehensive coverage
3. **Test Before Deployment**: Use the SIT testing feature to validate detection accuracy against sample data
4. **Consider Regional Requirements**: Select SITs based on the geographic locations where your organization operates
5. **Regular Review**: Periodically review and update SIT configurations as Microsoft adds new types and your requirements evolve
6. **Custom SITs for Unique Data**: Create custom SITs for organization-specific patterns like employee IDs or project codes

---

## Additional Resources

- [Microsoft Learn: Sensitive Information Types](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-learn-about)
- [Sensitive Information Type Entity Definitions](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)
- [Create Custom Sensitive Information Types](https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type)

---

*Document Version: 1.0*  
*Last Updated: December 2025*  
*Source: Microsoft Purview Documentation*