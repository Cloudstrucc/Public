# Temporary Public Configuration of PEPP Portal for External Testing

## Introduction

The Power Platform Environment Protection Program (PEPP) portal is typically configured as a private site, accessible only to internal users authenticated via Azure Active Directory (AD). However, for a limited period, we need to allow external political entities to access and test the site. This document outlines the procedure for temporarily changing the site's visibility from private to public and explains the implications of this change.

### Power Pages Overview

Microsoft Power Pages is a secure, enterprise-grade, low-code platform for creating, hosting, and administering modern external-facing business websites. It offers two primary visibility options:

1. **Private**: Restricts access to authenticated users within the organization's Azure AD.
2. **Public**: Allows access to anyone on the internet, without authentication.

### Security Considerations

Changing a Power Pages site from private to public has significant security implications:

- **Increased Exposure**: The site becomes accessible to anyone on the internet.
- **Authentication Bypass**: Public sites do not require user authentication.
- **Data Sensitivity**: Ensure no sensitive data is exposed on public pages.
- **Temporary Nature**: It's crucial to revert to private status after testing.
- **Monitoring**: Increased vigilance is necessary during the public period.

### Purpose of Temporary Public Access

The site is being set to public temporarily to facilitate:

1. External testing by designated political entities.
2. Validation of site functionality without AD authentication.
3. Gathering feedback from external stakeholders.

**Important**: After the testing period, the site must be reverted to private status to reinstate security measures.

## Procedure for Setting PEPP Portal to "Public" Status

Follow these steps to configure the PEPP portal as a public-facing site:

1. Access the Power Platform Admin Center:

   - Navigate to https://admin.powerplatform.microsoft.com
   - Select "Environments" from the navigation menu
2. Configure Environment Membership:

   - Locate the Dataverse UATX environment
   - Click the ellipsis (...) adjacent to the environment name
   - Select "Membership" from the dropdown menu
   - In the modal window, add yourself as an "Administrator"
   - Click "Save" and close the modal

   ![1725505960882](image/uatx-deploy/1725505960882.png)

   ![1725506023994](image/uatx-deploy/1725506023994.png)
3. Access Power Pages:

   - Go to make.powerpages.microsoft.com
   - Select the Dataverse UATX environment
   - Click edit

   ![1725506911134](image/uatx-deploy/1725506911134.png)

   ![1725507944433](image/uatx-deploy/1725507944433.png)
4. Modify Site Visibility:

   - In the admin portal, locate the "Dataverse UATX - Private" dropdown in the ribbon
   - Select "Manage site visibility" from the dropdown options

   ![1725507999040](image/uatx-deploy/1725507999040.png)
5. Set Site to Public:

   - In the site visibility settings, select the "Public" radio button
   - Click "Sync" to apply the changes

![1725508059855](image/uatx-deploy/1725508059855.png)

![1725508117157](image/uatx-deploy/1725508117157.png)

Upon completion of these steps, the website will be accessible via the public internet.

**Note:** To revert the site to private status after the external testing period:

- Follow steps 1-4 as outlined above
- In step 5, select the "Private" radio button instead of "Public"
- Click "Sync" to apply the changes

![1725508169670](image/uatx-deploy/1725508169670.png)

![1725508210419](image/uatx-deploy/1725508210419.png)

## Conclusion

By following this procedure, you will temporarily set the PEPP portal to public status, allowing external political entities to access and test the site. Remember that this is a temporary measure, and it is crucial to revert the site to private status once the testing period has concluded to maintain the security of your Power Pages site and its data.
