<div align="center">
  <img src="./entra-infographic.png" alt="Microsoft Entra External ID Infographic" width="800">
  <p><i>Microsoft Entra External ID - Secure Identity Management for External Users</i></p>
</div>

# Elections Canada: External ID Integration with Microsoft Entra ID

This document outlines the integration between Elections Canada's Microsoft Entra External ID solution for managing external identities. The implementation provides secure access to applications for various external clients while maintaining strict security standards.

## Overview

Elections Canada requires a secure identity solution that allows external users to access specific applications while maintaining strict security standards mandated by federal regulations. This document describes the implementation of Microsoft Entra External ID (formerly Azure AD B2C) for managing external identities.

```mermaid
graph TD
    A[External User] -->|Authentication Request| B[Application Portal]
    B -->|Redirect to Identity Provider| C[Microsoft Entra External ID]
    C -->|User Authentication| D{Authentication Type}
    D -->|Social Identity| E[Social Identity Provider]
    D -->|Local Account| G[Entra External ID Store]
    E -->|Authentication Response| C
    G -->|Authentication Response| C
    C -->|Token Issuance| B
    B -->|Access Granted| H[Protected Applications]
    
    style C fill:#f9f,stroke:#333,stroke-width:2px
    style H fill:#bbf,stroke:#333,stroke-width:2px
```

## Key Components

### 1. Microsoft Entra External ID Tenant

Elections Canada utilizes a dedicated Microsoft Entra External ID tenant (`electcan2.onmicrosoft.com`) for managing external identities. This tenant is separate from the organizational Entra ID used for internal staff.

### 2. User Flows

The implementation uses the standard "Sign up and sign in" user flow that facilitates the external client authentication process:

```mermaid
graph LR
    A[External User] --> B[Sign Up and Sign In User Flow]
    B --> C[Email Verification]
    C --> D[Credential Creation/Validation]
    D --> E[Claims Collection]
    E --> F[Application Access]
```

#### Sign Up and Sign In User Flow
- Email and password authentication
- Email-based verification during registration
- Collection of key user attributes:
  - Email address
  - First name
  - Last name
  - Phone number
- Multi-factor authentication via email for sensitive operations
- Bilingual support (English and French)

### 3. Identity Provider Configuration

Elections Canada's implementation uses the default local account identity provider to manage external client accounts:

```mermaid
graph TD
    A[Authentication Request] --> B[Entra External ID]
    B --> C[Local Account Provider]
    C --> D[Token Issuance]
    D --> E[Application Access]
```

The following identity provider configuration is used:

- **Local Accounts**: Email and password based accounts in the Entra External ID identity store
- Self-service password reset
- Email verification
- Progressive profiling capabilities

## Technical Implementation

### Architecture

```mermaid
graph TB
    A[User Browser] -->|1. Access Request| B[Application Portal]
    B -->|2. Auth Redirect| C[Microsoft Entra External ID]
    C -->|3. Authentication| D[Identity Provider]
    D -->|4. Token| C
    C -->|5. Token Issuance| B
    B -->|6. API Call with Token| E[Protected API]
    E -->|7. Token Validation| F[Microsoft Entra ID]
    
    subgraph "Azure"
    C
    F
    end
    
    subgraph "Organizational Infrastructure"
    B
    E
    G[Database]
    end
    
    E --> G
```

### Protocol Support

The Entra External ID tenant supports industry-standard authentication protocols for application integration:

```mermaid
graph TD
    A[Integration Protocols] --> B[OpenID Connect]
    A --> C[SAML 2.0]
    
    B --> D[Authorization Code Flow]
    B --> E[Implicit Flow]
    B --> F[Hybrid Flow]
    
    C --> G[SP-Initiated SSO]
    C --> H[IdP-Initiated SSO]
    
    D --> I[Application Integration]
    E --> I
    F --> I
    G --> I
    H --> I
```

#### OpenID Connect (OIDC) Benefits
- Modern, REST-based protocol
- Simplified token handling
- Mobile application support
- User info endpoint for attribute retrieval
- Lightweight implementation

#### SAML Benefits
- Widespread enterprise application support
- Rich attribute statements
- Mature implementation patterns
- Legacy application compatibility

### Data Flow

The authentication process follows these steps:

1. User attempts to access application
2. User is redirected to Entra External ID for authentication
3. User authenticates via local account
4. Entra External ID issues a token containing claims about the user
5. The application validates the token and extracts user information
6. Access is granted based on user claims and application permissions

### Security Controls

The following security controls have been implemented:

```mermaid
graph TD
    A[Security Controls] --> B[Authentication Policies]
    A --> C[Token Handling]
    A --> D[Data Protection]
    A --> E[Monitoring]
    
    B --> B1[MFA Requirements]
    B --> B2[Password Policies]
    B --> B3[Session Management]
    
    C --> C1[Token Encryption]
    C --> C2[Signature Validation]
    C --> C3[Lifetime Policies]
    
    D --> D1[Data Encryption]
    D --> D2[Personal Info Handling]
    D --> D3[Consent Management]
    
    E --> E1[Logging]
    E --> E2[Alerting]
    E --> E3[Reporting]
```

#### Authentication Policies
- Strong password requirements (12+ characters, complexity)
- Multi-factor authentication via email for sensitive operations
- Session timeout after 30 minutes of inactivity

#### Token Security
- JWT tokens with industry-standard encryption
- Configurable token lifetimes
- Refresh token patterns
- Audience and issuer validation

#### Data Protection
- Encryption of all personal data at rest and in transit
- Minimal data collection in accordance with Privacy Act
- Automated data retention policies
- Strict data classification

## Application Integration

### Single Sign-On Benefits

The implementation of Entra External ID provides the following SSO benefits:

- **Improved User Experience**: Users sign in once and access multiple applications
- **Reduced Password Fatigue**: Eliminating multiple credentials for different applications
- **Centralized Access Control**: Manage permissions from a single location
- **Consistent Security Policies**: Apply uniform security controls across applications
- **Simplified Onboarding/Offboarding**: Streamlined user lifecycle management
- **Enhanced Security Monitoring**: Consolidated authentication logging

### Authentication Flow

The following diagram shows how applications integrate with Entra ID:

```mermaid
sequenceDiagram
    participant User
    participant App as Application
    participant Auth as Entra External ID
    participant API as Protected API
    
    User->>App: Access Request
    App->>Auth: Redirect to Authentication
    Auth->>User: Authentication Prompt
    User->>Auth: Provide Credentials
    Auth->>User: Email MFA (if required)
    User->>Auth: Complete MFA
    Auth->>App: Issue ID Token + Access Token
    App->>API: API Request with Access Token
    API->>API: Validate Token
    API->>App: API Response
    App->>User: Display Protected Content
```

### Token Claims

The token issued to applications contains the following claims:

- Standard claims:
  - `sub`: Unique identifier for the user
  - `email`: User's email address
  - `given_name`: User's first name
  - `family_name`: User's last name
  - `phone_number`: User's phone number
  - `iat`: Time at which the token was issued
  - `exp`: Expiration time

## Operational Considerations

### Custom Domain Configuration

The current Entra External ID tenant uses the default domain `electcan2.onmicrosoft.com`. To configure a custom domain (e.g., `login.elections.ca`):

```mermaid
graph TD
    A[Custom Domain Configuration] --> B[Purchase Domain]
    B --> C[Verify Domain Ownership]
    C --> D[Configure DNS Records]
    D --> E[Add Custom Domain in Entra ID]
    E --> F[Configure User Flows]
    F --> G[Update Applications]
    
    C --> C1[Add TXT Record]
    D --> D1[Add CNAME Record]
    D --> D2[Configure SSL Certificate]
```

1. **Verify Domain Ownership**:
   - Add a TXT record to your DNS configuration
   - Microsoft will verify ownership through DNS lookup

2. **Configure DNS Records**:
   - Add a CNAME record pointing to `electcan2.b2clogin.com`
   - Configure SSL certificates if needed

3. **Add Custom Domain in Entra ID**:
   - Navigate to Entra External ID > Custom Domains
   - Add the verified domain
   - Set as primary domain if desired

4. **Update Applications**:
   - Update all application configurations to use the new domain
   - Test SSO flows with the custom domain

### Language Support

Entra External ID provides built-in support for both English and French:

```mermaid
graph TD
    A[Language Configuration] --> B[User Flow Setup]
    B --> C[UI Customization]
    C --> D[Testing]
    
    B --> B1[Enable Languages]
    B --> B2[Set Default Language]
    
    C --> C1[Email Templates]
    C --> C2[Page UI Elements]
    C --> C3[Error Messages]
```

1. **Enable Language Support**:
   - In the user flow properties, enable both English and French
   - Set the default fallback language (typically English)
   - Configure language detection mechanisms

2. **UI Customization**:
   - Create language-specific versions of all UI elements
   - Upload translated versions of:
     - Page content
     - Error messages
     - Email templates

3. **Language Selection**:
   - Add language selector in the user interface
   - Honor browser language preferences
   - Allow users to change language during the authentication process

4. **Testing**:
   - Test the complete user journey in both languages
   - Verify all email communications
   - Ensure accessibility standards are met in both languages

### Monitoring and Reporting

Comprehensive monitoring is implemented using Microsoft's built-in tools:

```mermaid
graph LR
    A[Monitoring Tools] --> B[Microsoft Purview]
    A --> C[Entra ID Insights]
    A --> D[Azure Monitor]
    A --> E[Log Analytics]
    
    B --> B1[Data Governance]
    B --> B2[Compliance Reporting]
    
    C --> C1[Usage Patterns]
    C --> C2[Risk Detections]
    C --> C3[User Behavior]
    
    D --> D1[Performance Metrics]
    D --> D2[Health Status]
    
    E --> E1[Query Logs]
    E --> E2[Custom Dashboards]
    E --> E3[Alert Rules]
```

#### Microsoft Purview
- Data discovery and classification
- Sensitive information monitoring
- Compliance reporting
- Risk assessment

#### Entra ID Insights
- Sign-in activity monitoring
- User risk detection
- Authentication method usage
- Self-service adoption metrics
- Conditional access impact

#### Azure Monitor
- Performance metrics
- Service health
- Resource utilization
- Availability monitoring

#### Log Analytics
- Custom query capabilities
- Long-term log retention
- Cross-service correlation
- Custom alert rules
- Visualization dashboards

#### Key Metrics Monitored
- Authentication success/failure rates
- Account lockouts
- Password reset volumes
- MFA enrollments and usage
- Geographic access patterns
- Suspicious activities
- API access patterns
- User flow completion rates

### User Management

Administrators can manage external users through:

1. Microsoft Entra Admin Portal
2. Microsoft Graph API integration
3. Role-based access control

## Compliance

The implementation adheres to:

- Treasury Board of Canada Secretariat (TBS) security standards
- Privacy Act requirements
- Elections Canada Act provisions
- ITSG-33 security controls
- Government of Canada Cloud Security Profile

## Roadmap

The following future enhancements may be considered for the identity system:

**Disclaimer**: The items listed below are recommendations and may or may not be pursued depending on organizational willingness and budget considerations.

- Enhanced identity verification capabilities
- Expanded multi-factor authentication options
- Additional identity provider integrations
- Implementation of verifiable credentials
- Risk-based authentication policies

## References

- [Microsoft Entra External ID Documentation](https://learn.microsoft.com/en-us/entra/external-id/)
- [Microsoft Entra Monitoring and Reporting](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/)
- [Microsoft Purview Documentation](https://learn.microsoft.com/en-us/purview/)
- [Government of Canada Identity and Access Management Guidelines](https://www.canada.ca/en/government/system/digital-government/online-security-privacy/identity-management.html)
- [Treasury Board Identity Management Policy](https://www.tbs-sct.canada.ca/pol/doc-eng.aspx?id=16577)
- [OIDC Protocol Documentation](https://openid.net/connect/)
- [SAML 2.0 Technical Overview](http://docs.oasis-open.org/security/saml/Post2.0/sstc-saml-tech-overview-2.0.html)