Absolutely. Here's the revised **markdown version**, clean and professional for an IT service request — with no icons and no mention of "Global Administrator":

---

# Power Platform CoE Starter Kit – Service Account Setup (`powerplatform-coe`)

## Service Account Creation

* [ ] Create a dedicated service account in Entra ID named `powerplatform-coe`
  (therefore: `powerplatform-coe@elections.ca`)

## Role Assignment

* [ ] Assign the **Power Platform Service Admin** role
  *Note: Do not assign the Dynamics 365 Service Admin role — it is insufficient for this scenario.*

## License Assignment (non-trial versions)

* [ ] Assign the **Power Apps Per User** license
* [ ] Assign the **Power Automate Per User** license
  *(or Power Automate Per Flow license if applicable)*
* [ ] Assign a **Microsoft 365 license** to enable mailbox access

## Mailbox Configuration

* [ ] Ensure the account has an active **Exchange Online mailbox**
  (required for use with the Office 365 Outlook connector)

## Security Configuration

* [ ] Enable **Multifactor Authentication (MFA)** for this account
  (follow Power Platform and Power Automate conditional access recommendations)

## Azure App Registration (for using audit log-based flows)

* [ ] Create an **Azure AD app registration**
* [ ] Assign API permissions:

  * Microsoft Graph → `AuditLog.Read.All`
  * Exchange Online → `Exchange.ManageAsApp` (if required)
* [ ] Grant **admin consent** to the app registration
* [ ] Use this registration when setting up cloud flows that read the Microsoft 365 audit log

## Environment Requirements

* [ ] Ensure a **Production environment** is available for deploying the CoE Starter Kit
  (Developer or Default environments are not recommended)

---

### Summary Checklist for `powerplatform-coe` Account

| Requirement                        | Status |
| ---------------------------------- | ------ |
| Power Platform Service Admin Role  | ☐      |
| Power Apps Per User License        | ☐      |
| Power Automate License             | ☐      |
| Microsoft 365 License              | ☐      |
| Power BI Pro License (if needed)   | ☐      |
| Power BI Premium (if needed)       | ☐      |
| Exchange Mailbox Available         | ☐      |
| MFA Enabled                        | ☐      |

---
