# GUARDRAILS

Since AB2C creates a new Azure AD Domain that is targeted for external user authentication. A subset of the guardrails the Department would implement for access management by B2C administrators will be implemented. In addition to the access controls, there are a series of settings described in the tables below that need to be configured or activated to ensure that the Department achieves a Protected B posture in its B2C implementation. For the most part, since AB2C is a service that falls within the Departments tenant subscription, the majority of guardrails will be inherited. However, at the AB2C application layer, additional guardrails should be implemented to ensure that the external user and API authentication platform is fully secure and well managed.

|Guardrail|
|---|
|Have a minimum of 2 Global Admins with MFA enabled. The Global Admins should be AD federated accounts and not cloud only accounts.|
|Create Security Group for each web application or API integrating with B2C (segment and separate)|
|Enforce TLS 1.2 by deploying AFD|
|Use a Canada.ca or GC.ca domain by deploying AFD (block the Microsoft domain)|
|Use Entrust TLS Certificate for custom domain|
|(For EAB and SAML implementations) Use Entrust PKI – Encryption and Decryption Certifications|
|Use RSA 2056 or higher for the Tenant Encryption Key (or Use CSE-approved cryptographic algorithms and protocols)|
|(optional) Use JWT signatures for login and logout requests if using IDPs (signature should be done by trusted CA cert – entrust, and not a self-signed certificate)|
|Prohibit the use of implicit flows for applications with the exception of SPA’s (consider leveraging server side for authorization)|
|Do not share Secrets directly with Apps. Instead provide ‘SecretID’ from KeyVaults|
|Enforce Front Channel Logout implementation to client applications |
|Use Risky Users and Risk Detection monitoring services for significantly greater control over risky authentications and access policies. Azure AD B2C Premium P2 is required|
|Ensure one of the Canada regions are set when installing B2C|
|Create multiple environments (Production and non production)|
|Audit log events are only retained for seven days. Integrate with Azure Monitor to retain the logs for long-term use, or integrate with existing (SIEM) tool – extend the retention period to 1 year (instead of 30 days)|
|Setup active alerting and monitoring “Track user behavior” feature in Azure AD B2C using Application Insights.|



