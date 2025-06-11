# API’s

Applications that contain long-running processes or that operate without the presence of a user also need a way to access secured resources such as web APIs. These applications can authenticate and get tokens by using their identities (rather than a user's delegated identity) and by using the OAuth 2.0 client credentials flow. In order to configure this, the administrator will set up a credential flow using the AAD and MIP token endpoint: https://login.microsoftonline.com/{TENANT}.onmicrosoft.com/oauth2/v2.0/token. 
Upon receiving a token, the application (Dameon Apps) can perform subsequent HTTP requests using OAUTH 2.0 with a bearer token in the header of the request.
This means that there is no user interaction and OIDC is therefore not being leveraged in this flow. Instead, the API that connects to B2C to interface with another API is responsible in obtaining tokens automatically. This API will be issued a Client ID, Secret (or perhaps a certificate) that will be used to obtain short lived tokens. It is recommended that the secret or certificate are rolled over (or changed) at regular intervals of 6 months. The diagram below depicts this scenario.

![image info](./../Images/Picture8.png)

