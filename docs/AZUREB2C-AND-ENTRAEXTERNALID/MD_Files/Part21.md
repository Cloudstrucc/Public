# Web Applications

For web applications (including .NET, PHP, Java, Ruby, Python, and Node.js) that are hosted on a server and accessed through a browser, Azure AD B2C supports OpenID Connect for all user experiences. In the Azure AD B2C implementation of OpenID Connect, the web application initiates user experiences by issuing authentication requests to Azure AD. The result of the request is an id_token. This security token represents the user's identity. It also provides information about the user in the form of claims. This also applies to SAAS portal applications such as PowerApps Protals. This technology will abstract the B2C configurations into a user interface to facilitate the integration rather than configuring OIDC parameters and implementing library interfaces and functions in a custom application via code.

Once a JWT is issued to a trusted application, the decrypted version may look like the following:

 ```
// Partial raw id_token
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImtyaU1QZG1Cd...
 ```

```
// Partial content of a decoded id_token
{
    "name": "John Smith",
    "email": "john.smith@gmail.com",
    "oid": "d9674823-dffc-4e3f-a6eb-62fe4bd48a58"
    ...
} 
```
The above is applicable only to a user flow (described in a later section), that is configured to capture claims beyond the baseline ones like OID and IDP. 

For applications that leverage EAB or SIC (GCCF services), and where Azure B2C is acting as a pass through service to broker the authentication request between the web application and the third party IDPs, the id_token will simply include the GCCF persistent anonymous identifier (PAI). Therefore the object may look like the following:

 ```
// Partial content of a decoded id_token
{
    "sub": "3fffreefde54554efdfdfdfdf32113434232", //PAI
    "name": "John Smith",
    "email": "john.smith@gmail.com",
    "oid": "d9674823-dffc-4e3f-a6eb-62fe4bd48a58"
    ...
}
 ```

In a typical web application that is using Azure B2C takes these high-level steps:

* The user browses to the web application.
* The web application redirects the user to Azure AD B2C indicating the policy to execute.
* The user completes policy.
* Azure AD B2C returns an id_token to the browser.
* The id_token is posted to the redirect URI.
* The id_token is validated, and a session cookie is set.
* A secure page is returned to the user.

Validation of the id_token by using a public signing key that is received from Azure AD is sufficient to verify the identity of the user. This process also sets a session cookie that can be used to identify the user on subsequent page requests.



The sequence diagram below depics 

