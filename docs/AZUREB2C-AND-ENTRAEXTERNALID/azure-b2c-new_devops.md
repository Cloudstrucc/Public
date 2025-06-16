<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Azure B2C - Secure Enterprise SSO for {ORG NAME}</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .infographic-container {
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            background-color: white;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        .header {
            background-color: #ffffff;
            padding: 20px;
            position: relative;
            border-bottom: 5px solid #FF0000;
        }
        .title {
            color: #333;
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
        }
        .subtitle {
            color: #666;
            font-size: 20px;
            margin-top: 0;
        }
        .main-content {
            padding: 30px;
            position: relative;
        }
        .protected-b {
            position: absolute;
            top: 20px;
            right: 30px;
            background-color: #FF0000;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 14px;
        }
        .architecture-diagram {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin: 20px 0 40px;
            position: relative;
        }
        .layer {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            z-index: 1;
            margin: 15px 0;
        }
        .connector {
            height: 60px;
            width: 4px;
            background-color: #0078D4;
            position: relative;
        }
        .connector::before,
        .connector::after {
            content: '';
            position: absolute;
            width: 12px;
            height: 12px;
            background-color: #0078D4;
            border-radius: 50%;
            left: 50%;
            transform: translateX(-50%);
        }
        .connector::before {
            top: -6px;
        }
        .connector::after {
            bottom: -6px;
        }
        .user-layer {
            background-color: #f0f5ff;
            border-radius: 12px;
            padding: 15px 30px;
            box-shadow: 0 4px 12px rgba(0,120,212,0.1);
        }
        .b2c-layer {
            background-color: #e6f7ff;
            border-radius: 12px;
            padding: 20px 30px;
            box-shadow: 0 4px 12px rgba(0,120,212,0.2);
            border: 2px solid #0078D4;
            position: relative;
        }
        .services-layer {
            background-color: #f0f5ff;
            border-radius: 12px;
            padding: 15px 30px;
            box-shadow: 0 4px 12px rgba(0,120,212,0.1);
        }
        .shield {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            border-radius: 12px;
            border: 3px solid #FFD700;
            box-shadow: 0 0 30px rgba(255,215,0,0.2);
            pointer-events: none;
            z-index: -1;
        }
        .layer-title {
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        .icon-container {
            display: flex;
            gap: 25px;
            flex-wrap: wrap;
            justify-content: center;
        }
        .icon-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }
        .icon {
            width: 36px;
            height: 36px;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 8px;
        }
        .icon-label {
            font-size: 12px;
            text-align: center;
            color: #555;
        }
        .security-features {
            display: flex;
            justify-content: space-around;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        .feature {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100px;
            margin: 10px;
        }
        .feature-icon {
            width: 50px;
            height: 50px;
            background-color: #f5f5f5;
            border-radius: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .feature-label {
            text-align: center;
            font-size: 12px;
            color: #333;
        }
        .canada-emblem {
            position: absolute;
            opacity: 0.05;
            width: 300px;
            height: auto;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: -1;
        }
        .footer {
            background-color: #f0f5ff;
            padding: 15px 30px;
            text-align: center;
            font-size: 14px;
            color: #555;
            border-top: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="infographic-container">
        <div class="header">
            <h1 class="title">Azure B2C - Secure Enterprise SSO for {ORG NAME}</h1>
            <p class="subtitle">Architecture, Implementation & Operational Guide</p>
        </div>
        <div class="main-content">
            <div class="protected-b">PBMM GUIDELINES</div>
            <svg class="canada-emblem" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 645.8 686.8">
                <path fill="#FF0000" d="M116.2 526.8L7.1 654.8C46.2 678.4 103.4 686.8 116.2 686.8 129 686.8 185.6 670.9 225.3 654.8L116.2 526.8zM46.3 303.9L0 303.9 0 444 53.7 470.2 46.3 303.9zM186.2 303.9L186.2 444 139.9 470.2 139.9 303.9 93.6 303.9 116.2 202.7 186.2 303.9zM116.2 0L67.3 118.2 48.5 118.2 76.4 202.7 0 202.7 48.2 280 0 280 0 303.9 48.5 303.9 48.5 118.2 116.2 0zM184 118.2L165.1 118.2 184 202.7 107.6 202.7 155.8 280 107.6 280 107.6 303.9 155.8 303.9 155.8 118.2 184 118.2z"/>
            </svg>
            <div class="architecture-diagram">
                <div class="layer user-layer">
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M12,12A6,6 0 0,0 18,6C18,2.68 15.31,0 12,0C8.68,0 6,2.68 6,6A6,6 0 0,0 12,12M12,14C7.58,14 4,15.79 4,18V20H20V18C20,15.79 16.42,14 12,14Z"/>
                        </svg>
                        EXTERNAL USERS
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,4A4,4 0 0,1 16,8A4,4 0 0,1 12,12A4,4 0 0,1 8,8A4,4 0 0,1 12,4M12,14C16.42,14 20,15.79 20,18V20H4V18C4,15.79 7.58,14 12,14Z" />
                            </svg>
                            <div class="icon-label">Citizens</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,5A3.5,3.5 0 0,0 8.5,8.5A3.5,3.5 0 0,0 12,12A3.5,3.5 0 0,0 15.5,8.5A3.5,3.5 0 0,0 12,5M12,7A1.5,1.5 0 0,1 13.5,8.5A1.5,1.5 0 0,1 12,10A1.5,1.5 0 0,1 10.5,8.5A1.5,1.5 0 0,1 12,7M5.5,8A2.5,2.5 0 0,0 3,10.5C3,11.44 3.53,12.25 4.29,12.68C4.65,12.88 5.06,13 5.5,13C5.94,13 6.35,12.88 6.71,12.68C7.08,12.47 7.39,12.17 7.62,11.81C6.89,10.86 6.5,9.7 6.5,8.5C6.5,8.41 6.5,8.31 6.5,8.22C6.2,8.08 5.86,8 5.5,8M18.5,8C18.14,8 17.8,8.08 17.5,8.22C17.5,8.31 17.5,8.41 17.5,8.5C17.5,9.7 17.11,10.86 16.38,11.81C16.5,12 16.63,12.15 16.78,12.3C16.94,12.45 17.1,12.58 17.29,12.68C17.65,12.88 18.06,13 18.5,13C18.94,13 19.35,12.88 19.71,12.68C20.47,12.25 21,11.44 21,10.5A2.5,2.5 0 0,0 18.5,8M12,14C9.66,14 5,15.17 5,17.5V19H19V17.5C19,15.17 14.34,14 12,14M4.71,14.55C2.78,14.78 0,15.76 0,17.5V19H3V17.07C3,16.06 3.69,15.22 4.71,14.55M19.29,14.55C20.31,15.22 21,16.06 21,17.07V19H24V17.5C24,15.76 21.22,14.78 19.29,14.55M12,16C13.53,16 15.24,16.5 16.23,17H7.77C8.76,16.5 10.47,16 12,16Z" />
                            </svg>
                            <div class="icon-label">Partners</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M16,9C18.33,9 23,10.17 23,12.5V15H17V12.5C17,11 16.19,9.89 15.04,9.05L16,9M8,9C10.33,9 15,10.17 15,12.5V15H1V12.5C1,10.17 5.67,9 8,9M8,7A3,3 0 0,1 5,4A3,3 0 0,1 8,1A3,3 0 0,1 11,4A3,3 0 0,1 8,7M16,7A3,3 0 0,1 13,4A3,3 0 0,1 16,1A3,3 0 0,1 19,4A3,3 0 0,1 16,7Z" />
                            </svg>
                            <div class="icon-label">Businesses</div>
                        </div>
                    </div>
                </div>
                <div class="connector"></div>
                <div class="layer b2c-layer">
                    <div class="shield"></div>
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="32" height="32">
                            <path fill="#0078D4" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,7C13.4,7 14.8,8.1 14.8,9.5V11C15.4,11 16,11.6 16,12.3V15.8C16,16.4 15.4,17 14.7,17H9.2C8.6,17 8,16.4 8,15.7V12.2C8,11.6 8.6,11 9.2,11V9.5C9.2,8.1 10.6,7 12,7M12,8.2C11.2,8.2 10.5,8.7 10.5,9.5V11H13.5V9.5C13.5,8.7 12.8,8.2 12,8.2Z" />
                        </svg>
                        AZURE B2C IDENTITY SERVICE
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#0078D4" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,5A3,3 0 0,1 15,8A3,3 0 0,1 12,11A3,3 0 0,1 9,8A3,3 0 0,1 12,5M17,17.25C17,14.87 14.87,13 12,13C9.13,13 7,14.87 7,17.25V20H17V17.25Z" />
                            </svg>
                            <div class="icon-label">User Flows</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#0078D4" d="M10,17L6,13L7.41,11.59L10,14.17L16.59,7.58L18,9M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1Z" />
                            </svg>
                            <div class="icon-label">Policies</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#0078D4" d="M21,11C21,16.55 17.16,21.74 12,23C6.84,21.74 3,16.55 3,11V5L12,1L21,5V11M12,21C15.75,20 19,15.54 19,11.22V6.3L12,3.18L5,6.3V11.22C5,15.54 8.25,20 12,21Z" />
                            </svg>
                            <div class="icon-label">Security</div>
                        </div>
                    </div>
                </div>
                <div class="connector"></div>
                <div class="layer services-layer">
                    <div class="layer-title">
                        <svg class="icon" viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M20,8H4V6H20M20,18H4V12H20M20,4H4C2.89,4 2,4.89 2,6V18A2,2 0 0,0 4,20H20A2,2 0 0,0 22,18V6C22,4.89 21.1,4 20,4Z" />
                        </svg>
                        INTEGRATED SERVICES
                    </div>
                    <div class="icon-container">
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M5,3C3.89,3 3,3.9 3,5V19C3,20.1 3.9,21 5,21H19C20.1,21 21,20.1 21,19V5C21,3.9 20.1,3 19,3H5M5,5H19V19H5V5M7,7V9H17V7H7M7,11V13H17V11H7M7,15V17H14V15H7Z" />
                            </svg>
                            <div class="icon-label">Web Apps</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M17,13H13V17H11V13H7V11H11V7H13V11H17M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z" />
                            </svg>
                            <div class="icon-label">Power Pages</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M12,3C7.58,3 4,4.79 4,7C4,9.21 7.58,11 12,11C16.42,11 20,9.21 20,7C20,4.79 16.42,3 12,3M4,9V12C4,14.21 7.58,16 12,16C16.42,16 20,14.21 20,12V9C20,11.21 16.42,13 12,13C7.58,13 4,11.21 4,9M4,14V17C4,19.21 7.58,21 12,21C16.42,21 20,19.21 20,17V14C20,16.21 16.42,18 12,18C7.58,18 4,16.21 4,14Z" />
                            </svg>
                            <div class="icon-label">APIs</div>
                        </div>
                        <div class="icon-item">
                            <svg class="icon" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#555" d="M17,1H7A2,2 0 0,0 5,3V21A2,2 0 0,0 7,23H17A2,2 0 0,0 19,21V3A2,2 0 0,0 17,1M17,19H7V5H17V19M16,13H13V8H11V13H8L12,17L16,13Z" />
                            </svg>
                            <div class="icon-label">Mobile Apps</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="security-features">
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M2,6H4V18H2V6M5,6H6V18H5V6M7,6H10V18H7V6M11,6H12V18H11V6M14,6H16V18H14V6M17,6H20V18H17V6M21,6H22V18H21V6Z" />
                        </svg>
                    </div>
                    <div class="feature-label">Protected B Compliant</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M12,2A2,2 0 0,0 10,4A2,2 0 0,0 12,6A2,2 0 0,0 14,4A2,2 0 0,0 12,2M12,8A6,6 0 0,0 6,14C6,14.97 6.27,15.88 6.74,16.66L12,23L17.26,16.66C17.73,15.88 18,14.97 18,14A6,6 0 0,0 12,8Z" />
                        </svg>
                    </div>
                    <div class="feature-label">Canadian Data Residency</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M2,5V19H22V5H2M20,12H16V7H20V12M14,10H10V7H14V10M10,12H14V17H10V12M4,7H8V17H4V7Z" />
                        </svg>
                    </div>
                    <div class="feature-label">ITSG-33 Compliant</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M11,17A1,1 0 0,0 12,18A1,1 0 0,0 13,17A1,1 0 0,0 12,16A1,1 0 0,0 11,17M12,6A5,5 0 0,1 17,11C17,11.9 16.7,12.7 16.1,13.4L15.5,14L16.1,14.6C16.7,15.3 17,16.1 17,17A5,5 0 0,1 12,22A5,5 0 0,1 7,17C7,16.1 7.3,15.3 7.9,14.6L8.5,14L7.9,13.4C7.3,12.7 7,11.9 7,11A5,5 0 0,1 12,6M12,8A3,3 0 0,0 9,11C9,11.8 9.3,12.5 9.8,13.1L10.4,13.8L9.8,14.5C9.3,15.1 9,15.8 9,16.6C9,18.5 10.3,20 12,20C13.7,20 15,18.5 15,16.6C15,15.8 14.7,15.1 14.2,14.5L13.6,13.8L14.2,13.1C14.7,12.5 15,11.8 15,11C15,9.3 13.7,8 12,8Z" />
                        </svg>
                    </div>
                    <div class="feature-label">Multi-Factor Authentication</div>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28">
                            <path fill="#0078D4" d="M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1M12,5A3,3 0 0,1 15,8A3,3 0 0,1 12,11A3,3 0 0,1 9,8A3,3 0 0,1 12,5Z" />
                        </svg>
                    </div>
                    <div class="feature-label">GCKey & Sign-In Partners</div>
                </div>
            </div>
        </div>
        <div class="footer">
            Government of Canada | Department of [Your Department] | April 2025
        </div>
    </div>
</body>
</html>

## EXECUTIVE OVERVIEW

This document defines the architecture, implementation, and operational requirements for enabling secure single sign-on (SSO) services using Azure B2C for the Government of Canada department's web applications and APIs requiring Protected B compliance. Azure B2C provides business-to-customer identity as a service that adheres to Government of Canada security standards including ITSG-33, ISO 27001, and Protected B requirements.

The implementation will:

1. Provide a secure enterprise identity platform for external users accessing departmental services
2. Enable integration with Government of Canada identity services (GCKey/Sign-in Partner via OIDC brokers)
3. Implement Protected B security posture meeting all Government of Canada cloud security requirements
4. Support multiple platforms including Power Pages portals, .NET applications, Node.js, and Python
5. Deliver both web application SSO (OpenID Connect) and API authorization (OAuth 2.0)
6. Establish a standardized application registration process with proper governance
7. Create a scalable service management framework for enterprise-wide operations

:::mermaid
graph TB
    subgraph "Client Applications"
        WebApps["Web Applications<br>(Power Pages, .NET Core, Node.js)"]
        SPAs["Single Page Applications<br>(JavaScript Frameworks)"]
        APIs["Protected APIs"]
        Mobile["Mobile Applications"]
    end
    
    subgraph "Azure B2C Tenant"
        B2C["Azure B2C"]
        UserFlows["User Flows & Policies"]
        AppReg["App Registrations"]
        CustomDomain["Custom Canada.ca Domain"]
    end
    
    subgraph "GC Identity Providers"
        GCOIDC["GC OIDC Brokers<br>(EAB & SIC)"]
        GCSML["SAML 2.0 IdPs<br>(GCKey & Sign-In Partners)"]
    end
    
    WebApps --> B2C
    SPAs --> B2C
    APIs --> B2C
    Mobile --> B2C
    
    B2C --> UserFlows
    B2C --> AppReg
    B2C --> CustomDomain
    
    B2C --> GCOIDC
    GCOIDC --> GCSML
    
    classDef govcloud fill:#e6f7ff,stroke:#1890ff;
    classDef security fill:#fff2e8,stroke:#fa541c;
    classDef apps fill:#f6ffed,stroke:#52c41a;
    
    class B2C,UserFlows,AppReg,CustomDomain govcloud;
    class GCOIDC,GCSML security;
    class WebApps,SPAs,APIs,Mobile apps;
:::

## ALIGNMENT TO GC CLOUD USAGE PROFILES AND CONNECTION PATTERNS

This implementation aligns with the Government of Canada's Cloud Adoption Strategy and follows approved cloud usage profiles and connection patterns documented in the GC Cloud Security Control Framework.

### Applicable Connection Patterns

| Reference | Scenario | Application to Azure B2C |
|-----------|----------|--------------------------|
| C | External user access to cloud-based service | Primary pattern: Non-GC users accessing departmental services via Azure B2C authentication |
| D | Service/Application Interoperability | API-to-API authentication using OAuth 2.0 token-based flows |
| E | Cloud Administration and Management | Administrative access to the Azure B2C tenant for configuration and monitoring |

### Cloud Usage Profiles

This implementation aligns with GC Cloud Profile 4 (Protected B / Medium Integrity / Medium Availability) for the production environment, with development environments aligned to Profile 1 or 2 as appropriate. By deploying Azure B2C as a SAAS solution, we leverage Microsoft's robust security model while implementing additional department-specific guardrails to ensure full compliance with Protected B requirements.

## IMPLEMENTATION ARCHITECTURE COMPONENTS

### Azure B2C Core Architecture

The department's implementation will utilize the following key components:

1. **Azure B2C Tenant**: A dedicated B2C directory separate from the department's primary Azure AD
2. **Azure Front Door**: CDN service to apply TLS 1.2+ requirements and provide custom domain capabilities
3. **Key Vault**: Secure storage for certificates, secrets and encryption keys
4. **Azure Monitor**: Comprehensive logging and alerting for security compliance
5. **App Registrations**: Secured application identities for each integrated service
6. **User Flows**: Customized authentication workflows for various application types
7. **Custom Policies**: For advanced scenarios requiring greater control over the authentication processes
8. **Custom Domain**: Canada.ca subdomain for the user experience

:::mermaid
graph TB
    subgraph "External Users"
        Users["Department Service Users"]
    end
    
    subgraph "Microsoft Azure"
        AFD["Azure Front Door<br>(TLS 1.2+, Custom Domain)"]
        
        subgraph "Azure B2C Tenant"
            B2C["Azure B2C Service"]
            Policies["User Flows & Custom Policies"]
            IDP["Identity Provider<br>Connections"]
        end
        
        KeyVault["Azure Key Vault"]
        Monitor["Azure Monitor"]
    end
    
    subgraph "Department Applications"
        WebApps["Web Applications"]
        APIs["Protected APIs"]
    end
    
    subgraph "GC Identity Services"
        GCSSO["GCKey & Sign-In Partners"]
        Brokers["EAB & SIC OIDC Brokers"]
    end
    
    Users --> AFD
    AFD --> B2C
    B2C --> Policies
    B2C --> IDP
    B2C <--> KeyVault
    B2C --> Monitor
    
    WebApps --> B2C
    APIs --> B2C
    
    IDP --> Brokers
    Brokers --> GCSSO
    
    classDef external fill:#f0f2f5,stroke:#8c8c8c;
    classDef azure fill:#e6f7ff,stroke:#1890ff;
    classDef dept fill:#f6ffed,stroke:#52c41a;
    classDef gc fill:#fff2e8,stroke:#fa541c;
    
    class Users external;
    class AFD,B2C,Policies,IDP,KeyVault,Monitor azure;
    class WebApps,APIs dept;
    class GCSSO,Brokers gc;
:::

### Integration with GC Identity Services

The department's Azure B2C implementation will integrate with the Government of Canada's identity ecosystem through OpenID Connect brokers:

1. **Enterprise Authorization Broker (EAB)**: SSC's OIDC broker service for GCKey and Sign-in Partners
2. **Sign-in Canada (SIC)**: TBS's OIDC broker service for GCKey and Sign-in Partners

Rather than implementing complex SAML 2.0 integrations directly with GCKey/Sign-in Partners, Azure B2C will connect to these OIDC brokers which handle the SAML complexity on the department's behalf, including the SOAP binding required for proper single logout that B2C does not natively support.

## SECURITY AND COMPLIANCE IMPLEMENTATION

### Protected B Compliance Requirements

The Azure B2C implementation must adhere to the ITSG-33 control profile for Protected B information, which includes:

1. **Data Protection**: Encryption in transit (TLS 1.2+) and at rest (AES-256)
2. **Identity and Access Management**: MFA, strong authentication, privileged access controls
3. **Boundary Defense**: Network segmentation, DLP controls, WAF protection
4. **Monitoring and Logging**: Comprehensive audit trails for user activities
5. **Incident Response**: Detection and response capabilities for security events

### Guardrails Implementation

The following guardrails must be implemented to achieve Protected B compliance:

| Category | Guardrail | Implementation Approach |
|----------|-----------|--------------------------|
| Access Control | Minimum of 2 Global Admins with MFA | Configure department-federated accounts with appropriate privileges |
| Access Control | Application segmentation | Create dedicated security groups for each integrated application |
| Network Security | TLS 1.2+ enforcement | Deploy Azure Front Door to enforce TLS version |
| Network Security | Custom Canada.ca domain | Deploy Azure Front Door with Canada.ca subdomain |
| Cryptography | Use Entrust certificates | Generate CSRs from Key Vault for all TLS endpoints |
| Cryptography | RSA 2048+ for tenant keys | Configure B2C encryption settings to use strong cryptography |
| Authentication | JWT signatures for federation | Use Entrust certificates for token signing |
| Authentication | Prohibit implicit flows | Standardize on authorization code flow with PKCE |
| Secret Management | Centralized secret storage | Store all credentials in Azure Key Vault |
| Session Management | Front-channel logout | Require implementation for all applications |
| Monitoring | Risk detection enabled | Configure risk detection policies in Azure AD B2C Premium P2 |
| Geography | Canadian region selection | Ensure Canadian region selection for data residency |
| Environment | Dev/Test/Prod separation | Maintain separate environments with consistent controls |
| Audit | Log retention | Configure Azure Monitor for 1+ year retention |
| User Experience | Track user behavior | Implement Application Insights for user journey analysis |

## BUILD BOOK: DETAILED IMPLEMENTATION STEPS

### A. PROVISIONING AZURE B2C TENANT

#### A.1 Prerequisites

- Global Administrator rights to the Azure subscription
- Separate subscriptions for Development and Production environments
- Access to Azure Key Vault for certificate and secret management
- Access to DNS for Canada.ca domain configuration

#### A.2 Tenant Creation Process

1. Sign into the Azure portal as Global Administrator
2. Navigate to "Create a resource" > search for "Azure Active Directory B2C"
3. Select "Create a new Azure AD B2C Tenant"
4. Configure tenant with appropriate naming:
   - Organization name: `{DEPARTMENT}-b2c-{ENV}`
   - Initial domain name: `{DEPARTMENT}b2c{ENV}`
   - Country: Canada
   - Subscription: Select appropriate subscription
   - Resource group: Create dedicated RG for B2C resources
   - Resource group region: Canada Central or Canada East
5. Complete validation and create the tenant
6. Switch to the new B2C tenant directory
7. Add additional administrators as Global Administrators to the tenant:
   - Select "Users" from the Azure AD B2C menu
   - Create new invited users with Global Administrator role
   - Ensure all administrators use MFA

#### A.3 Tenant Branding Configuration

1. Navigate to "Company Branding" in the Azure B2C tenant
2. Configure the default brand with:
   - Sign-in page background image: Government of Canada banner
   - Banner logo: Canada wordmark
   - Configure additional elements to match GC design system
3. Ensure all branding elements meet official GC visual identity requirements

### B. CONFIGURING USER AUTHENTICATION FLOWS

#### B.1 Local Account User Flow Configuration

1. Navigate to "User flows" in the Azure B2C tenant
2. Create a new "Sign up and sign in" user flow:
   - Select "Recommended" version
   - Name: `{APPNAME}_susi`
   - Identity providers: Email signup
   - MFA: Conditional (based on risk)
   - Collect attributes: Email, Given Name, Surname
   - Return claims: Minimum necessary for application function
3. Configure user flow properties:
   - Enable "Require ID Token in Logout Requests"
   - Configure page layouts to match GC design system
   - Set appropriate session behavior
4. Create additional flows as needed:
   - Profile editing: `{APPNAME}_editprofile`
   - Password reset: `{APPNAME}_pwdreset`

#### B.2 Enterprise Access Broker (EAB) Integration

1. Navigate to "Identity providers" in the Azure B2C tenant
2. Create a new "OpenID Connect" provider:
   - Name: Enterprise Access Broker
   - Metadata URL: `{EAB_METADATA_URL}`
   - Client ID: Provided by SSC
   - Client secret: Provided by SSC
   - Scope: openid
   - Response type: code
   - Response mode: query
   - User ID: sub
   - Display name: sub
3. Create a dedicated user flow for EAB:
   - Name: `eab_sso`
   - Identity providers: Select only EAB
   - Configure appropriate claim mapping
4. Submit Azure B2C metadata and redirect URLs to SSC for configuration:
   - Tenant ID: Copy from B2C properties
   - Metadata URL: Copy from user flow "Run" screen
   - Redirect URL: Copy from user flow "Run" screen

#### B.3 Sign-in Canada (SIC) Integration

1. Navigate to "Identity providers" in the Azure B2C tenant
2. Create a new "OpenID Connect" provider:
   - Name: Sign-in Canada
   - Metadata URL: `{SIC_METADATA_URL}`
   - Client ID: Provided by TBS
   - Client secret: Provided by TBS
   - Scope: openid
   - Response type: code
   - Response mode: query
   - User ID: sub
   - Display name: sub
3. Create a dedicated user flow for SIC:
   - Name: `sic_sso`
   - Identity providers: Select only SIC
   - Configure appropriate claim mapping
4. Submit Azure B2C metadata and redirect URLs to TBS for configuration:
   - Tenant ID: Copy from B2C properties
   - Metadata URL: Copy from user flow "Run" screen
   - Redirect URL: Copy from user flow "Run" screen

### C. IMPLEMENTING CUSTOM DOMAIN AND TLS ENFORCEMENT

#### C.1 Custom Domain Registration

1. Register custom domain in Azure AD B2C:
   - Navigate to "Custom domain names"
   - Add custom domain (e.g., `auth.{DEPARTMENT}.canada.ca`)
2. Submit DNS change request to SSC for TXT verification:
   - Domain: `auth.{DEPARTMENT}.canada.ca`
   - Type: TXT
   - Value: Microsoft verification string
3. Verify domain in Azure AD B2C after DNS propagation

#### C.2 Azure Front Door Deployment (Recommended Approach)

1. Create Azure Front Door resource:
   ```powershell
   # Create Resource Group if it doesn't exist
   New-AzResourceGroup -Name "rg-{DEPARTMENT}-afd-{ENV}" -Location "Canada Central"
   
   # Create Front Door profile
   New-AzFrontDoorCdnProfile -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -Name "afd-{DEPARTMENT}-b2c-{ENV}" -Location "Global" -Sku "Standard_AzureFrontDoor"
   
   # Create endpoint
   New-AzFrontDoorCdnEndpoint -EndpointName "auth-{DEPARTMENT}-{ENV}" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -Location "Global"
   
   # Add origin group
   New-AzFrontDoorCdnOriginGroup -OriginGroupName "b2c-origin-group" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -HealthProbePath "/" -HealthProbeRequestType "HEAD" `
     -HealthProbeProtocol "Https" -SessionAffinityState "Disabled"
   
   # Add B2C origin
   New-AzFrontDoorCdnOrigin -OriginName "b2c-origin" `
     -OriginGroupName "b2c-origin-group" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -HostName "{TENANT}.b2clogin.com" `
     -OriginHostHeader "{TENANT}.b2clogin.com" `
     -HttpPort 80 -HttpsPort 443 -Priority 1 -Weight 1000 -Enabled $true
   
   # Create route
   New-AzFrontDoorCdnRoute -RouteName "b2c-route" `
     -EndpointName "auth-{DEPARTMENT}-{ENV}" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -OriginGroupId "/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/rg-{DEPARTMENT}-afd-{ENV}/providers/Microsoft.Cdn/profiles/afd-{DEPARTMENT}-b2c-{ENV}/originGroups/b2c-origin-group" `
     -SupportedProtocols @("Http", "Https") `
     -PatternsToMatch @("/*") -ForwardingProtocol "HttpsOnly" `
     -LinkToDefaultDomain "Enabled" -HttpsRedirect "Enabled" `
     -EnabledState "Enabled"
   ```

2. Generate Entrust certificate for custom domain:
   - Create Key Vault CSR for `auth.{DEPARTMENT}.canada.ca`
   ```powershell
   # Create CSR in Key Vault
   $policy = New-AzKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" `
     -SubjectName "CN=auth.{DEPARTMENT}.canada.ca" `
     -IssuerName "Unknown" `
     -ValidityInMonths 12 `
     -ReuseKeyOnRenewal `
     -KeyType "RSA" `
     -KeySize 2048 `
     -KeyUsage "DigitalSignature", "KeyEncipherment" `
     -Ekus @("1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2") `
     -CertificateTransparency $true
   
   Add-AzKeyVaultCertificate -VaultName "kv-{DEPARTMENT}-b2c-{ENV}" `
     -Name "auth-{DEPARTMENT}-canada-ca" `
     -CertificatePolicy $policy
   ```
   - Download CSR from Key Vault and submit to Entrust CA
   - After receiving the certificate, import to Key Vault:
   ```powershell
   # Merge certificate with CSR in Key Vault
   Import-AzKeyVaultCertificateMerge -VaultName "kv-{DEPARTMENT}-b2c-{ENV}" `
     -Name "auth-{DEPARTMENT}-canada-ca" `
     -FilePath "path/to/certificate.cer"
   ```

3. Configure AFD with custom domain certificate:
   ```powershell
   # Create custom domain in AFD
   New-AzFrontDoorCdnCustomDomain -CustomDomainName "auth-{DEPARTMENT}-canada-ca" `
     -HostName "auth.{DEPARTMENT}.canada.ca" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -MinimumTlsVersion "TLS12" `
     -CertificateSource "AzureKeyVault" `
     -SecretId "/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/rg-{DEPARTMENT}-b2c-{ENV}/providers/Microsoft.KeyVault/vaults/kv-{DEPARTMENT}-b2c-{ENV}/secrets/auth-{DEPARTMENT}-canada-ca"
   
   # Update route to use custom domain
   Update-AzFrontDoorCdnRoute -RouteName "b2c-route" `
     -EndpointName "auth-{DEPARTMENT}-{ENV}" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -CustomDomainId "/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/rg-{DEPARTMENT}-afd-{ENV}/providers/Microsoft.Cdn/profiles/afd-{DEPARTMENT}-b2c-{ENV}/customDomains/auth-{DEPARTMENT}-canada-ca"
   ```

4. Configure TLS 1.2+ enforcement:
   ```powershell
   # Create security policy to enforce TLS 1.2+
   New-AzFrontDoorCdnSecurityPolicy -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -SecurityPolicyName "tls-policy" `
     -SecurityType "SecurityPolicies" `
     -MinimumTlsVersion "TLS12" `
     -EndpointName "auth-{DEPARTMENT}-{ENV}"
   ```

5. Setup WAF policy (Optional but recommended):
   ```powershell
   # Create WAF policy
   New-AzFrontDoorWafPolicy -Name "waf-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -Sku "Standard_AzureFrontDoor" `
     -Mode "Prevention" `
     -EnabledState "Enabled" `
     -CustomBlockResponseStatusCode 403
   
   # Add managed ruleset
   New-AzFrontDoorWafManagedRuleObject -Type "DefaultRuleSet" `
     -Version "1.0" `
     -Action "Block" `
     -WafPolicy $wafPolicy
   
   # Apply WAF policy to security policy
   New-AzFrontDoorCdnSecurityPolicy -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -SecurityPolicyName "waf-policy" `
     -SecurityType "WebApplicationFirewall" `
     -WafPolicyId "/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/rg-{DEPARTMENT}-afd-{ENV}/providers/Microsoft.Network/frontdoorwebapplicationfirewallpolicies/waf-{DEPARTMENT}-b2c-{ENV}" `
     -EndpointName "auth-{DEPARTMENT}-{ENV}"
   ```

#### C.3 Azure Application Gateway Deployment (Alternative Approach)

Azure Application Gateway can be used as an alternative to Azure Front Door when:
- You require more advanced WAF capabilities
- You need additional network-level control
- You prefer a regional deployment instead of global
- You need to integrate with on-premises networks via ExpressRoute

1. Create Virtual Network for Application Gateway:
   ```powershell
   # Create VNET and subnet
   New-AzVirtualNetwork -ResourceGroupName "rg-{DEPARTMENT}-appgw-{ENV}" `
     -Location "Canada Central" `
     -Name "vnet-{DEPARTMENT}-appgw-{ENV}" `
     -AddressPrefix "10.0.0.0/16"
   
   Add-AzVirtualNetworkSubnetConfig -Name "snet-appgw" `
     -VirtualNetwork $vnet `
     -AddressPrefix "10.0.1.0/24"
   
   $vnet | Set-AzVirtualNetwork
   ```

2. Create public IP for Application Gateway:
   ```powershell
   New-AzPublicIpAddress -ResourceGroupName "rg-{DEPARTMENT}-appgw-{ENV}" `
     -Location "Canada Central" `
     -Name "pip-{DEPARTMENT}-appgw-{ENV}" `
     -AllocationMethod "Static" `
     -Sku "Standard"
   ```

3. Create Application Gateway configuration:
   ```powershell
   # Create IP configuration
   $vnet = Get-AzVirtualNetwork -Name "vnet-{DEPARTMENT}-appgw-{ENV}" -ResourceGroupName "rg-{DEPARTMENT}-appgw-{ENV}"
   $subnet = Get-AzVirtualNetworkSubnetConfig -Name "snet-appgw" -VirtualNetwork $vnet
   $pip = Get-AzPublicIpAddress -Name "pip-{DEPARTMENT}-appgw-{ENV}" -ResourceGroupName "rg-{DEPARTMENT}-appgw-{ENV}"
   
   $gipconfig = New-AzApplicationGatewayIPConfiguration -Name "appgw-ip-config" -Subnet $subnet
   
   # Create frontend port
   $frontendport = New-AzApplicationGatewayFrontendPort -Name "appgw-frontend-port" -Port 443
   
   # Create frontend IP config
   $frontendip = New-AzApplicationGatewayFrontendIPConfig -Name "appgw-frontend-ip" -PublicIPAddress $pip
   
   # Create backend pool
   $backendPool = New-AzApplicationGatewayBackendAddressPool -Name "b2c-backend-pool" `
     -BackendIPAddresses "{TENANT}.b2clogin.com"
   
   # Create backend settings
   $backendsetting = New-AzApplicationGatewayBackendHttpSetting -Name "b2c-backend-setting" `
     -Port 443 `
     -Protocol "Https" `
     -CookieBasedAffinity "Disabled" `
     -HostName "{TENANT}.b2clogin.com" `
     -RequestTimeout 30
   
   # Create certificate from Key Vault
   $sslCert = New-AzApplicationGatewaySslCertificate -Name "b2c-ssl-cert" `
     -KeyVaultSecretId "https://kv-{DEPARTMENT}-b2c-{ENV}.vault.azure.net/secrets/auth-{DEPARTMENT}-canada-ca"
   
   # Create HTTP listener
   $listener = New-AzApplicationGatewayHttpListener -Name "b2c-https-listener" `
     -Protocol "Https" `
     -FrontendIPConfiguration $frontendip `
     -FrontendPort $frontendport `
     -SslCertificate $sslCert `
     -HostName "auth.{DEPARTMENT}.canada.ca"
   
   # Create routing rule
   $rule = New-AzApplicationGatewayRequestRoutingRule -Name "b2c-routing-rule" `
     -RuleType "Basic" `
     -HttpListener $listener `
     -BackendAddressPool $backendPool `
     -BackendHttpSettings $backendsetting
   
   # Create WAF configuration
   $wafConfig = New-AzApplicationGatewayWebApplicationFirewallConfiguration `
     -Enabled $true `
     -FirewallMode "Prevention" `
     -RuleSetType "OWASP" `
     -RuleSetVersion "3.2"
   
   # Create SSL policy to enforce TLS 1.2+
   $sslPolicy = New-AzApplicationGatewaySslPolicy -PolicyType "Custom" `
     -MinProtocolVersion "TLSv1_2" `
     -CipherSuite @("TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", 
                   "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
                   "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
                   "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256")
   
   # Create Application Gateway with WAF v2 SKU
   New-AzApplicationGateway -Name "appgw-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-appgw-{ENV}" `
     -Location "Canada Central" `
     -BackendAddressPools $backendPool `
     -BackendHttpSettingsCollection $backendsetting `
     -FrontendIPConfigurations $frontendip `
     -GatewayIPConfigurations $gipconfig `
     -FrontendPorts $frontendport `
     -HttpListeners $listener `
     -RequestRoutingRules $rule `
     -Sku @{Name = "WAF_v2"; Tier = "WAF_v2"; Capacity = 2} `
     -WebApplicationFirewallConfig $wafConfig `
     -SslCertificates $sslCert `
     -SslPolicy $sslPolicy
   ```

4. Submit DNS change request to SSC for your custom domain:
   - Domain: `auth.{DEPARTMENT}.canada.ca`
   - Type: A/CNAME
   - Value: Public IP address or DNS name of Application Gateway

5. Configure health probe for B2C endpoints:
   ```powershell
   $probe = New-AzApplicationGatewayProbeConfig -Name "b2c-health-probe" `
     -Protocol "Https" `
     -Path "/" `
     -Interval 30 `
     -Timeout 30 `
     -UnhealthyThreshold 3 `
     -PickHostNameFromBackendHttpSettings $false `
     -Host "{TENANT}.b2clogin.com"
   
   $appgw = Get-AzApplicationGateway -Name "appgw-{DEPARTMENT}-b2c-{ENV}" -ResourceGroupName "rg-{DEPARTMENT}-appgw-{ENV}"
   $appgw = Add-AzApplicationGatewayProbeConfig -ApplicationGateway $appgw -Name "b2c-health-probe" -Probe $probe
   $appgw = Set-AzApplicationGateway -ApplicationGateway $appgw
   ```

#### C.4 URL Redirect Configuration

1. Configure B2C to redirect to custom domain when accessed directly:
   - In Azure Portal, navigate to Azure AD B2C tenant
   - Select "Properties"
   - Under "Domain name for branding", enter your custom domain
   - Save the configuration

2. Test all authentication flows to ensure proper domain usage:
   - Verify redirects work correctly
   - Ensure TLS 1.2+ is enforced
   - Validate certificate trust chain

3. Implement URL rewrite rules:

   **For Azure Front Door:**
   ```powershell
   # Create a rule to handle B2C paths correctly
   New-AzFrontDoorCdnRuleSet -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -RuleSetName "b2c-rules"
   
   New-AzFrontDoorCdnRule -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -RuleSetName "b2c-rules" `
     -RuleName "rewrite-tenant-domain" `
     -Order 1 `
     -Condition @{MatchVariable="RequestUri"; Operator="Contains"; Value="{TENANT}.onmicrosoft.com"} `
     -Action @{Type="UrlRewrite"; SourcePattern="{TENANT}.onmicrosoft.com"; DestinationPattern="auth.{DEPARTMENT}.canada.ca"; PreserveUnmatchedPath=$true}
   
   # Associate rule set with route
   Update-AzFrontDoorCdnRoute -RouteName "b2c-route" `
     -EndpointName "auth-{DEPARTMENT}-{ENV}" `
     -ProfileName "afd-{DEPARTMENT}-b2c-{ENV}" `
     -ResourceGroupName "rg-{DEPARTMENT}-afd-{ENV}" `
     -RuleSetId "/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/rg-{DEPARTMENT}-afd-{ENV}/providers/Microsoft.Cdn/profiles/afd-{DEPARTMENT}-b2c-{ENV}/rulesets/b2c-rules"
   ```

   **For Application Gateway:**
   ```powershell
   # Create URL rewrite configuration
   $rewriteRuleSet = New-AzApplicationGatewayRewriteRuleSet -Name "b2c-rewrite-ruleset"
   
   $rewriteRule = New-AzApplicationGatewayRewriteRule -Name "rewrite-tenant-domain" `
     -ActionSet @{
       UrlConfiguration = @{
         ModifiedUrl = @{
           Value = "https://auth.{DEPARTMENT}.canada.ca{http_req_url}"
         }
       }
     } `
     -Condition @{
       Variable = "http_req_url"
       Pattern = "{TENANT}.onmicrosoft.com"
       IgnoreCase = $true
       Negate = $false
     }
   
   $rewriteRuleSet.RewriteRules.Add($rewriteRule)
   $appgw = Add-AzApplicationGatewayRewriteRuleSet -ApplicationGateway $appgw -Name "b2c-rewrite-ruleset" -RewriteRuleSet $rewriteRuleSet
   $appgw = Set-AzApplicationGateway -ApplicationGateway $appgw
   ```

4. Block direct access to B2C tenant:
   - Create WAF rules to block requests that bypass your custom domain
   - Monitor for any direct access attempts to the B2C tenant
   - Implement IP restrictions if necessary to limit administrative access

### D. APPLICATION INTEGRATION PATTERNS

#### D.1 Web Application Integration (OpenID Connect)

1. Create App Registration for the web application:
   - Name: `{APPNAME}-{ENV}`
   - Supported account types: Accounts in this organizational directory only
   - Redirect URI: Application callback URL
   - Application ID URI: Generated automatically
2. Configure authentication settings:
   - Platform configurations: Web
   - Redirect URIs: Application callback URLs
   - Front-channel logout URL: Application logout endpoint
   - Implicit grant: Do NOT enable ID tokens
3. Configure application settings:
   - Client secret: Generate and store in Key Vault
   - API permissions: None required for basic authentication
4. Provide integration details to application team:
   - Client ID: App registration client ID
   - Client secret: Key Vault reference
   - Authority: `https://auth.{DEPARTMENT}.canada.ca/{TENANT}/{USERFLOW}`
   - Metadata URL: User flow metadata endpoint

#### D.2 Single Page Application Integration

1. Create App Registration for SPA:
   - Name: `{APPNAME}-{ENV}`
   - Supported account types: Accounts in this organizational directory only
   - Redirect URI: SPA application URL
2. Configure authentication settings:
   - Platform configurations: Single-page application
   - Redirect URIs: SPA application URLs
   - Access tokens and authorization codes
   - Do NOT enable implicit flow for ID tokens
3. Configure CORS settings for SPA domains
4. Provide integration details to application team:
   - Client ID: App registration client ID
   - Authority: `https://auth.{DEPARTMENT}.canada.ca/{TENANT}/{USERFLOW}`
   - Metadata URL: User flow metadata endpoint
   - Scopes: Authorize appropriate scopes

#### D.3 API Integration (OAuth 2.0)

1. Create App Registration for the API:
   - Name: `{APINAME}-{ENV}`
   - Supported account types: Accounts in this organizational directory only
2. Configure Expose an API settings:
   - Application ID URI: Set custom URI if needed
   - Add scopes: Define appropriate scopes with descriptive names
3. Create App Registration for client application:
   - Configure API permissions to the API scopes
   - Generate client secret or certificate
4. Provide integration details to application teams:
   - Authority: `https://auth.{DEPARTMENT}.canada.ca/{TENANT}`
   - Token endpoint: `/oauth2/v2.0/token`
   - Client ID and secret/certificate references
   - Authorized scopes

#### D.4 Power Pages Portal Integration

1. Create App Registration for Power Pages portal:
   - Name: `{PORTALNAME}-{ENV}`
   - Redirect URI: Power Pages authentication callback URL
   - Front-channel logout URL: Portal logout URL
2. Configure portal authentication in Power Pages admin:
   - Authentication type: OpenID Connect
   - Display Name: GC Single Sign-On
   - Client ID: App registration client ID
   - Client secret: From Key Vault
   - Authority: `https://auth.{DEPARTMENT}.canada.ca/{TENANT}/{USERFLOW}`
   - Metadata URL: User flow metadata endpoint
3. Configure logout URL in portal site settings
4. Test authentication flow and verify claims mapping

### E. MONITORING AND SECURITY OPERATIONS

#### E.1 Logging and Monitoring Setup

1. Create Log Analytics workspace for Azure B2C logs:
   - Deploy in Canadian region
   - Configure appropriate retention period (minimum 1 year)
2. Configure diagnostic settings in Azure B2C:
   - Send audit logs to Log Analytics
   - Send sign-in logs to Log Analytics
   - Configure streaming to Event Hub if required for SIEM integration
3. Deploy Application Insights for user journey tracking:
   - Configure custom events for authentication flows
   - Implement user behavior analytics

#### E.2 Security Alerts Configuration

1. Configure Azure Monitor alerts for:
   - Failed authentication attempts exceeding threshold
   - Administrative actions on tenant
   - Risk detection events
   - Unusual sign-in patterns
2. Create action groups for alert notifications:
   - Email to security team
   - Integration with departmental ITSM system
   - Optional SMS for critical alerts
3. Implement custom KQL queries for advanced detection

#### E.3 Risk Detection Implementation

1. Enable Identity Protection features (requires Premium P2):
   - Sign-in risk policies
   - User risk policies
   - MFA registration policy
2. Configure risk level thresholds:
   - High risk: Block access
   - Medium risk: Require MFA
   - Low risk: Allow with monitoring
3. Implement risk remediation workflows:
   - User notification process
   - Self-service remediation options
   - Administrative intervention procedures

## STANDARD OPERATING PROCEDURES

### A. SERVICE MANAGEMENT FRAMEWORK

#### A.1 Organizational Structure and Roles

The Azure B2C service requires a well-defined team structure with clear roles and responsibilities:

| Role | Responsibilities | Department | Access Level |
|------|-----------------|------------|-------------|
| Service Owner | Strategic oversight, compliance accountability | IT Director | Read |
| Platform Administrator | Configuration management, updates, monitoring | Identity Team | Global Admin |
| Identity Operations | Day-to-day management, application onboarding | Identity Team | B2C Admin |
| Security Officer | Risk assessment, policy enforcement | Security Team | Read/Audit |
| Application Owner | Integration requirements, application-specific policies | Business Units | No direct access |
| Help Desk (Tier 1) | Basic troubleshooting, user assistance | IT Support | Directory Reader |
| Help Desk (Tier 2) | Advanced troubleshooting, application configuration | Identity Team | Application Admin |

#### A.2 Service Level Objectives

The Azure B2C service will maintain the following SLOs:

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Service Availability | 99.9% | Azure Monitor uptime tracking |
| Authentication Success Rate | 99.5% | Sign-in logs analysis |
| Response Time - Authentication | < 2 seconds | Application Insights |
| Response Time - Self-Service | < 5 seconds | Application Insights |
| Incident Response Time (Critical) | < 30 minutes | ITSM metrics |
| Incident Resolution Time (Critical) | < 4 hours | ITSM metrics |
| Change Implementation | < 5 business days | Change management system |

#### A.3 Capacity Management

1. Monitor resource utilization:
   - Authentication transactions per day/month
   - Directory object count
   - API request volume
2. Establish thresholds for scaling:
   - Alert at 70% of quota utilization
   - Plan expansion at 80% of quota utilization
3. Quarterly capacity review process:
   - Analyze growth trends
   - Forecast future requirements
   - Adjust licensing and resources as needed

### B. OPERATIONAL PROCEDURES

#### B.1 Application Onboarding Process

1. **Intake Phase**:
   - Application owner submits formal request via self-service portal
   - Required information: application details, integration type, user volumes
   - Security assessment performed for risk classification
   - Architecture review to validate integration pattern

2. **Implementation Phase**:
   - Create App Registration following naming standards
   - Configure appropriate authentication flow
   - Implement required custom claims
   - Store credentials in Key Vault
   - Document configuration in CMDB

3. **Validation Phase**:
   - Test authentication flows in non-production environment
   - Validate security controls and compliance
   - Perform user acceptance testing
   - Obtain security approval for production deployment

4. **Production Deployment**:
   - Implement via change management process
   - Provide integration details to application team
   - Monitor initial authentication activity
   - Conduct post-implementation review

#### B.2 Credential Management

1. **Secret Rotation Schedule**:
   - Client secrets: Every 180 days
   - Certificates: Before expiration (minimum 30 days)
   - TLS certificates: Annual renewal

2. **Rotation Process**:
   - Create new credential in B2C
   - Update reference in Key Vault
   - Configure application to use new credential
   - Verify functionality with new credential
   - Remove old credential after transition period

3. **Emergency Rotation**:
   - Defined process for compromised credentials
   - Immediate revocation capabilities
   - Notification procedures for affected applications

#### B.3 User Account Management

1. **External User Management**:
   - Self-service registration via user flows
   - Self-service password reset
   - Account closure process
   - Dormant account deactivation (365 days)

2. **Administrative Account Management**:
   - Quarterly access review for all privileged accounts
   - Just-in-time access for administrative operations
   - Separation of duties enforcement
   - Comprehensive audit logging

3. **Service Account Management**:
   - Dedicated service principals for automated processes
   - Least privilege access model
   - Quarterly review and recertification
   - Automated monitoring for suspicious activity

#### B.4 Incident Response

1. **Detection Capabilities**:
   - Automated alerts for security events
   - User-reported issues triage
   - Regular security reviews

2. **Response Procedures**:
   - Severity classification matrix
   - Defined escalation paths
   - Communication templates
   - Containment strategies

3. **Recovery Procedures**:
   - Service restoration priorities
   - User communication process
   - Post-incident review
   - Lessons learned documentation

### C. SELF-SERVICE PORTAL FOR APPLICATION TEAMS

The department will implement a self-service portal for application teams to request and manage their Azure B2C integration:

#### C.1 Portal Capabilities

1. **Application Registration Requests**:
   - Standardized form for new application onboarding
   - Integration type selection (web, SPA, API)
   - Required claims specification
   - Environment selection (Dev/Test/Prod)

2. **Integration Management**:
   - View existing application integrations
   - Request credential rotation
   - Update redirect URIs
   - Monitor application usage statistics

3. **Documentation and Guidance**:
   - Integration patterns and code samples
   - Troubleshooting guides
   - Best practices documentation
   - Security requirements reference

4. **Support Request Management**:
   - Ticketing interface for B2C-related issues
   - Status tracking for open requests
   - Knowledge base for common issues
   - Escalation path for complex problems

#### C.2 Portal Implementation

1. **Technology Platform**:
   - Power Pages portal with Azure AD authentication
   - Integration with departmental ITSM system
   - Automated workflows using Power Automate
   - Backend data in Dataverse

2. **Security Controls**:
   - Role-based access control
   - Audit logging for all portal actions
   - Approval workflows for sensitive operations
   - Data encryption for all stored information

3. **Integration with Azure B2C**:
   - Automated provisioning via Microsoft Graph API
   - Read-only dashboard for application metrics
   - Alert notification capabilities
   - Change request implementation tracking

### D. CHANGE MANAGEMENT

#### D.1 Change Types and Classification

| Change Type | Description | Approval Path | Implementation Window |
|-------------|-------------|--------------|----------------------|
| Standard | Routine changes with established procedures | Team Lead | Regular maintenance window |
| Normal | Significant changes requiring planning | Change Advisory Board | Scheduled maintenance window |
| Emergency | Urgent changes to restore service | Emergency CAB | As needed with post-implementation review |

#### D.2 Change Implementation Process

1. **Request and Assessment**:
   - Formal change request submission
   - Impact analysis and risk assessment
   - Documentation of implementation plan
   - Rollback procedure definition

2. **Approval Process**:
   - Technical review by identity team
   - Security review for compliance impact
   - Business approval for user-facing changes
   - Final authorization by appropriate authority

3. **Implementation**:
   - Pre-implementation testing in non-production
   - Scheduled deployment in maintenance window
   - Verification testing post-implementation
   - Documentation update in CMDB

4. **Review and Closure**:
   - Confirmation of successful implementation
   - Incident review for any issues encountered
   - Lessons learned documentation
   - Procedure updates if required

### E. CONTINUOUS IMPROVEMENT

#### E.1 Key Performance Indicators

1. **Operational Metrics**:
   - Authentication success rate
   - Average response time
   - Error rates by application
   - Self-service utilization

2. **Security Metrics**:
   - Risk events detected
   - MFA adoption rate
   - Policy compliance percentage
   - Credential rotation compliance

3. **User Experience Metrics**:
   - Authentication completion rate
   - Average authentication time
   - Password reset success rate
   - User satisfaction surveys

#### E.2 Review Cycle

1. **Monthly Operational Review**:
   - Performance metrics analysis
   - Incident review and trending
   - Capacity planning updates
   - Short-term improvement actions

2. **Quarterly Security Review**:
   - Risk assessment update
   - Compliance verification
   - Threat intelligence review
   - Security control effectiveness

3. **Annual Service Review**:
   - Strategic alignment assessment
   - Technology roadmap update
   - Major enhancement planning
   - Long-term improvement strategy

## APPENDICES

### APPENDIX A: REFERENCE ARCHITECTURE DIAGRAMS

#### A.1 Logical Architecture

[Detailed logical architecture diagram showing all components and their relationships]

#### A.2 Network Flow Diagrams

[Network flow diagrams for each integration pattern]

#### A.3 Security Architecture

[Security architecture diagram highlighting control points and data protection]

### APPENDIX B: SAMPLE CODE FOR INTEGRATIONS

#### B.1 .NET Core Integration

```csharp
// ASP.NET Core Web App with Azure B2C Authentication
// File: Program.cs

using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;

var builder = WebApplication.CreateBuilder(args);

// Add Azure B2C authentication
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(options =>
    {
        builder.Configuration.Bind("AzureAdB2C", options);
        
        options.Events = new OpenIdConnectEvents
        {
            OnSignedOutCallbackRedirect = (context) =>
            {
                context.Response.Redirect("/");
                context.HandleResponse();
                return Task.CompletedTask;
            }
        };
    });

// Add MVC controllers and views
builder.Services.AddControllersWithViews()
    .AddMicrosoftIdentityUI();

// Add authorization policies
builder.Services.AddAuthorization(options =>
{
    // Default policy requiring authentication
    options.FallbackPolicy = options.DefaultPolicy;
});

// Add session state
builder.Services.AddRazorPages();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(60);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.None;
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.UseSession();

app.MapRazorPages();
app.MapControllers();

app.Run();
```

```csharp
// File: appsettings.json

{
  "AzureAdB2C": {
    "Instance": "https://auth.{DEPARTMENT}.canada.ca/",
    "TenantId": "{TENANT_ID}",
    "ClientId": "{CLIENT_ID}",
    "ClientSecret": "{CLIENT_SECRET}",
    "CallbackPath": "/signin-oidc",
    "SignedOutCallbackPath": "/signout-callback-oidc",
    "SignUpSignInPolicyId": "{POLICY_NAME}",
    "ResetPasswordPolicyId": "{RESET_POLICY_NAME}",
    "EditProfilePolicyId": "{EDIT_PROFILE_POLICY_NAME}"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

```csharp
// File: AccountController.cs

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web;

[AllowAnonymous]
public class AccountController : Controller
{
    private readonly IConfiguration _configuration;
    
    public AccountController(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    [HttpGet]
    public IActionResult SignIn()
    {
        var redirectUrl = Url.Action("Index", "Home");
        return Challenge(
            new AuthenticationProperties { RedirectUri = redirectUrl },
            OpenIdConnectDefaults.AuthenticationScheme);
    }
    
    [HttpGet]
    public IActionResult ResetPassword()
    {
        var redirectUrl = Url.Action("Index", "Home");
        var properties = new AuthenticationProperties { RedirectUri = redirectUrl };
        properties.Items[Constants.Policy] = _configuration["AzureAdB2C:ResetPasswordPolicyId"];
        return Challenge(properties, OpenIdConnectDefaults.AuthenticationScheme);
    }
    
    [HttpGet]
    public IActionResult EditProfile()
    {
        var redirectUrl = Url.Action("Index", "Home");
        var properties = new AuthenticationProperties { RedirectUri = redirectUrl };
        properties.Items[Constants.Policy] = _configuration["AzureAdB2C:EditProfilePolicyId"];
        return Challenge(properties, OpenIdConnectDefaults.AuthenticationScheme);
    }
    
    [HttpGet]
    public IActionResult SignOut()
    {
        var callbackUrl = Url.Action("SignedOut", "Account", values: null, protocol: Request.Scheme);
        return SignOut(
            new AuthenticationProperties { RedirectUri = callbackUrl },
            OpenIdConnectDefaults.AuthenticationScheme,
            CookieAuthenticationDefaults.AuthenticationScheme);
    }
    
    [HttpGet]
    public IActionResult SignedOut()
    {
        if (User.Identity.IsAuthenticated)
        {
            // Redirect to home page if user is authenticated
            return RedirectToAction("Index", "Home");
        }
        
        return View();
    }
    
    [HttpGet]
    [Authorize]
    public IActionResult Profile()
    {
        return View(User.Claims);
    }
}
```

#### B.2 Node.js Integration

```javascript
// Node.js Express App with Azure B2C Authentication
// File: app.js

const express = require('express');
const session = require('express-session');
const passport = require('passport');
const BearerStrategy = require('passport-azure-ad').BearerStrategy;
const OIDCStrategy = require('passport-azure-ad').OIDCStrategy;
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config();

// Create Express app
const app = express();

// Configure session middleware
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,
    httpOnly: true,
    maxAge: 3600000 // 1 hour
  }
}));

// Configure view engine
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// Configure Passport middleware
app.use(passport.initialize());
app.use(passport.session());

// Configure passport OIDC strategy for web app authentication
passport.use('oidc', new OIDCStrategy({
  identityMetadata: `https://auth.${process.env.DEPARTMENT}.canada.ca/${process.env.TENANT}/v2.0/.well-known/openid-configuration?p=${process.env.POLICY_NAME}`,
  clientID: process.env.CLIENT_ID,
  clientSecret: process.env.CLIENT_SECRET,
  responseType: 'code',
  responseMode: 'form_post',
  redirectUrl: process.env.REDIRECT_URI,
  allowHttpForRedirectUrl: false,
  validateIssuer: true,
  isB2C: true,
  passReqToCallback: false,
  scope: ['openid', 'profile'],
  loggingLevel: 'info'
}, (profile, done) => {
  // Passport callback after authentication
  return done(null, profile);
}));

// Configure passport Bearer strategy for API authentication
passport.use('bearer', new BearerStrategy({
  identityMetadata: `https://auth.${process.env.DEPARTMENT}.canada.ca/${process.env.TENANT}/v2.0/.well-known/openid-configuration`,
  clientID: process.env.CLIENT_ID,
  validateIssuer: true,
  issuer: `https://auth.${process.env.DEPARTMENT}.canada.ca/${process.env.TENANT}/v2.0/`,
  passReqToCallback: false,
  loggingLevel: 'info'
}, (token, done) => {
  // Passport callback for API calls
  return done(null, token, token);
}));

// Serialize and deserialize user
passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

// Authentication middleware
const ensureAuthenticated = (req, res, next) => {
  if (req.isAuthenticated()) {
    return next();
  }
  res.redirect('/login');
};

// Routes
app.get('/', (req, res) => {
  res.render('index', { user: req.user });
});

app.get('/login', passport.authenticate('oidc', { 
  successRedirect: '/',
  failureRedirect: '/login-failed'
}));

app.post('/auth/openid/return', passport.authenticate('oidc', { 
  successRedirect: '/',
  failureRedirect: '/login-failed'
}));

app.get('/profile', ensureAuthenticated, (req, res)
```

### APPENDIX D: REFERENCE DOCUMENTS

#### D.1 Government of Canada Resources

- ITSG-33: IT Security Risk Management
- Cloud Security Control Profile for Protected B Information
- GC Digital Standards
- Official Languages Requirements for External Services

#### D.2 Microsoft Documentation

- Azure AD B2C Technical Documentation
- Azure Architecture Center Reference Architectures
- Microsoft Identity Platform Best Practices

#### D.3 Industry Standards

- ISO/IEC 27001:2013 Control Mappings
- NIST SP 800-63 Digital Identity Guidelines
- OWASP Authentication Security Best Practices

### APPENDIX E: GLOSSARY OF TERMS

| Term | Definition |
|------|------------|
| AAD | Azure Active Directory, Microsoft's cloud identity service |
| AFD | Azure Front Door, a global content delivery network service |
| App Registration | A record in Azure AD representing an application that can use Azure AD for authentication |
| Azure B2C | Azure Active Directory Business-to-Consumer, a customer identity access management solution |
| Azure App Gateway | Application delivery controller service providing layer 7 load balancing, WAF, and SSL termination |
| CATS | Canadian Authentication and Trust Services, a standard for government authentication |
| CDN | Content Delivery Network, a distributed server network that delivers web content to users |
| Claims | Pieces of information about a user that are passed between identity provider and application |
| Conditional Access | A feature of Azure AD that controls access to applications based on specific conditions |
| CSR | Certificate Signing Request, a request for a digital certificate from a certificate authority |
| Custom Domain | A domain name configured for Azure B2C instead of the default *.b2clogin.com domain |
| Custom Policy | XML files that define the behavior of Azure B2C authentication experiences |
| EAB | Enterprise Access Broker, SSC's OIDC broker service for GCKey and Sign-in Partners |
| Front Channel Logout | Browser-based logout mechanism that notifies all applications of a user's logout event |
| GCKey | Government of Canada credential service providing secure access to online government services |
| GCCF | Government of Canada Credential Federation, the federation of GC credential services |
| Identity Experience Framework (IEF) | The framework used by Azure B2C for customizing authentication experiences |
| Identity Provider (IdP) | A system that creates, maintains and manages identity information and authentication services |
| IDP | Identity Provider, such as GCKey, Sign-in Partner, or other social identity providers |
| ITSG-33 | IT Security Guidance document by CSE defining security control profiles for the GC |
| JWT | JSON Web Token, a compact, URL-safe means of representing claims to be transferred between parties |
| Key Vault | Azure service for securely storing and accessing secrets like certificates and API keys |
| MFA | Multi-Factor Authentication, requiring two or more verification methods for authentication |
| OAuth 2.0 | Authorization framework that enables applications to obtain limited access to user accounts |
| OIDC | OpenID Connect, an authentication layer built on top of OAuth 2.0 |
| OpenID Connect | Identity layer on top of OAuth 2.0 that allows clients to verify user identity |
| PAI | Persistent Anonymous Identifier, a unique identifier for users that doesn't reveal personal information |
| Protected B | Government of Canada information classification requiring medium security controls |
| Relying Party (RP) | Application that relies on an identity provider for authentication |
| SAML 2.0 | Security Assertion Markup Language, an XML-based protocol for authentication and authorization |
| SIC | Sign-in Canada, TBS's OIDC broker service for GCKey and Sign-in Partners |
| Sign-in Partners | Canadian financial institutions that provide credential services for government authentication |
| SSO | Single Sign-On, authentication process allowing users to access multiple applications with one login |
| TLS | Transport Layer Security, cryptographic protocol for secure communications over a network |
| User Flow | Pre-defined authentication experience path in Azure B2C |
| WAF | Web Application Firewall, a security solution that monitors and filters HTTP traffic |

# APPENDIX F: REFERENCE DOCUMENTS

## Government of Canada Resources

- [ITSG-33: IT Security Risk Management](https://cyber.gc.ca/en/guidance/it-security-risk-management-lifecycle-approach-itsg-33)
- [ITSG-22: Baseline Security Requirements for Network Security Zones](https://cyber.gc.ca/en/guidance/baseline-security-requirements-network-security-zones-government-canada-itsg-22)
- [Cloud Security Control Profile for Protected B Information](https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/cloud-services/government-canada-security-control-profile-cloud-based-it-services.html)
- [GC Digital Standards](https://www.canada.ca/en/government/system/digital-government/government-canada-digital-standards.html)
- [Official Languages Requirements for External Services](https://www.tbs-sct.canada.ca/pol/doc-eng.aspx?id=26160)
- [Government of Canada Web Standards](https://www.canada.ca/en/treasury-board-secretariat/services/government-communications/canada-content-information-architecture-specification.html)
- [Directive on Service and Digital](https://www.tbs-sct.gc.ca/pol/doc-eng.aspx?id=32601)
- [Standard on Web Accessibility](https://www.tbs-sct.gc.ca/pol/doc-eng.aspx?id=23601)
- [Standard on Optimizing Websites and Applications for Mobile Devices](https://www.tbs-sct.gc.ca/pol/doc-eng.aspx?id=27088)
- [Guidance on Cloud Authentication for the Government of Canada](https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/cloud-services/guidance-cloud-authentication-government-canada.html)

## Microsoft Azure B2C Documentation

### Core Documentation

- [Azure AD B2C Documentation](https://learn.microsoft.com/en-us/azure/active-directory-b2c/)
- [What is Azure AD B2C?](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview)
- [Azure AD B2C Pricing](https://azure.microsoft.com/en-us/pricing/details/active-directory-b2c/)
- [Azure AD B2C Service Limits and Restrictions](https://learn.microsoft.com/en-us/azure/active-directory-b2c/service-limits)

### Architecture and Implementation

- [Azure AD B2C Architecture Overview](https://learn.microsoft.com/en-us/azure/active-directory-b2c/technical-overview)
- [Creating an Azure AD B2C Tenant](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant)
- [Custom Domain Configuration](https://learn.microsoft.com/en-us/azure/active-directory-b2c/custom-domain)
- [Azure Front Door with B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/custom-domain-azure-front-door)
- [Azure Application Gateway Documentation](https://learn.microsoft.com/en-us/azure/application-gateway/)

### User Authentication and Policies

- [Azure AD B2C User Flows](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-flow-overview)
- [Azure AD B2C Custom Policies](https://learn.microsoft.com/en-us/azure/active-directory-b2c/custom-policy-overview)
- [Identity Experience Framework](https://learn.microsoft.com/en-us/azure/active-directory-b2c/custom-policy-trust-frameworks)
- [Adding External Identity Providers](https://learn.microsoft.com/en-us/azure/active-directory-b2c/add-identity-provider)
- [User Migration to Azure AD B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/user-migration)
- [SAML Service Provider Configuration](https://learn.microsoft.com/en-us/azure/active-directory-b2c/saml-service-provider)

### Security and Compliance

- [Azure AD B2C MFA Configuration](https://learn.microsoft.com/en-us/azure/active-directory-b2c/multi-factor-authentication)
- [Azure AD B2C Identity Protection](https://learn.microsoft.com/en-us/azure/active-directory-b2c/identity-protection-overview)
- [Azure Key Vault Integration](https://learn.microsoft.com/en-us/azure/active-directory-b2c/key-vault-keys)
- [Microsoft Entra Permissions Management](https://learn.microsoft.com/en-us/azure/active-directory/cloud-infrastructure-entitlement-management/overview)
- [Conditional Access for B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/conditional-access-identity-protection-overview)
- [Restricting Azure AD Access by Location](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-location)

### Application Integration

- [B2C App Integration Patterns](https://learn.microsoft.com/en-us/azure/active-directory-b2c/code-samples)
- [Register a Web Application](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications)
- [Single-Page Application Integration](https://learn.microsoft.com/en-us/azure/active-directory-b2c/configure-authentication-sample-spa)
- [Mobile and Desktop App Integration](https://learn.microsoft.com/en-us/azure/active-directory-b2c/configure-authentication-sample-mobile-desktop-app)
- [API Authorization with Azure AD B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/add-web-api-application)
- [Power Pages Portal Integration](https://learn.microsoft.com/en-us/power-pages/security/azure-ad-b2c)

### Monitoring and Operations

- [B2C Audit Logs and Monitoring](https://learn.microsoft.com/en-us/azure/active-directory-b2c/view-audit-logs)
- [User Behavior Analytics](https://learn.microsoft.com/en-us/azure/active-directory-b2c/analytics-with-application-insights)
- [Azure Monitor for B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/azure-monitor)
- [B2C Operational Readiness Checklist](https://learn.microsoft.com/en-us/azure/active-directory-b2c/operational-readiness-checklist)
- [Troubleshooting Azure AD B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/troubleshoot)

### Token and Protocol Reference

- [B2C Token Reference](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tokens-overview)
- [OpenID Connect Protocol](https://learn.microsoft.com/en-us/azure/active-directory-b2c/openid-connect)
- [OAuth 2.0 Authorization Code Flow](https://learn.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow)
- [JWT Validation](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tokens-overview#validation)

## Industry Standards and Specifications

- [ISO/IEC 27001:2013 Information Security Management](https://www.iso.org/standard/54534.html)
- [ISO/IEC 27017:2015 Cloud Security](https://www.iso.org/standard/43757.html)
- [ISO/IEC 27018:2019 Protection of PII in Public Clouds](https://www.iso.org/standard/76559.html)
- [NIST SP 800-63 Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [OpenID Connect Specifications](https://openid.net/connect/)
- [OAuth 2.0 Specifications](https://oauth.net/2/)
- [FIDO2 Authentication Standards](https://fidoalliance.org/specifications/)
- [OWASP Authentication Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP SAML Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SAML_Security_Cheat_Sheet.html)

## Code Samples and SDKs

- [Microsoft Identity Platform Code Samples](https://learn.microsoft.com/en-us/azure/active-directory/develop/sample-v2-code)
- [Microsoft Authentication Library (MSAL)](https://learn.microsoft.com/en-us/azure/active-directory/develop/msal-overview)
- [Azure AD B2C .NET Code Samples](https://learn.microsoft.com/en-us/azure/active-directory-b2c/code-samples#web-applications-and-apis)
- [Azure AD B2C JavaScript/SPA Code Samples](https://learn.microsoft.com/en-us/azure/active-directory-b2c/code-samples#single-page-applications)
- [Azure AD B2C Mobile Code Samples](https://learn.microsoft.com/en-us/azure/active-directory-b2c/code-samples#mobile-and-desktop-apps)
- [Azure AD B2C Custom Policy Samples](https://github.com/azure-ad-b2c/samples)

## Whitepapers and Advanced Topics

- [Azure AD B2C FAQ](https://learn.microsoft.com/en-us/azure/active-directory-b2c/faq)
- [Azure Security Benchmarks](https://learn.microsoft.com/en-us/security/benchmark/azure/)
- [Azure Identity Management Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/identity-management-best-practices)
- [Zero Trust Identity and Access Management](https://learn.microsoft.com/en-us/security/zero-trust/deploy/identity)
- [Microsoft Security Documentation](https://learn.microsoft.com/en-us/security/)
