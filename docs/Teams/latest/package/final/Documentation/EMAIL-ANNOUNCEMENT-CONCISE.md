# Subject: ACTION REQUIRED: New Microsoft 365 Security Controls - Effective [DATE]

Dear Team,

Starting **[DATE]**, we are implementing enhanced security controls across Microsoft 365. This email summarizes the key changes. **Please review the attached User Guide for complete details.**

---

## WHAT'S CHANGING

### 1. Mandatory Sensitivity Labels (NEW)

Sensitivity labels are now **mandatory** across the following applications:

| Application | Requirement |
|-------------|-------------|
| **Teams Meetings** | Must select a label before scheduling |
| **Outlook Email** | Must select a label before sending |
| **Word Documents** | Must select a label before saving |
| **Excel Spreadsheets** | Must select a label before saving |
| **PowerPoint Presentations** | Must select a label before saving |

**Important - Label Inheritance:** When you attach a labeled document to an email, the email's protection level will automatically match the attachment. For example, if you attach a **Protected B** Word document, the email will also be classified as **Protected B**.

---

### 2. Meeting Sensitivity Labels

All Teams meetings require a sensitivity label:

| Label | Use For | Key Features |
|-------|---------|--------------|
| **Protected B - Secure Meeting** *(Default)* | Classified info, contracts, NDA topics, customer data | Watermarks, external user restrictions, organizer-only presenting |
| **General - Regular Meeting** | Team syncs, social calls, non-sensitive training | Standard Teams features, no restrictions |

**Protected B is automatically selected** for all new meetings. Change to General only if content is truly non-sensitive.

---

### 3. Email & Document Sensitivity Labels

When composing emails or creating documents:

| Label | Use For | What It Does |
|-------|---------|--------------|
| **Protected B** | Classified content, contracts, PII | Applies encryption, restricts forwarding/copying |
| **Unclassified** | General business communications | Standard behavior |

**How to apply:** Click the **Sensitivity** button in the ribbon (Outlook, Word, Excel, PowerPoint) and select the appropriate label.

---

### 4. Teams Chat Protection (NEW)

A Data Loss Prevention (DLP) policy now monitors Teams chat for **44 sensitive information types**:

**🇨🇦 Canada**
- Bank Account Number
- Driver's License Number
- Health Service Number
- Passport Number
- Personal Health Identification Number (PHIN)
- Physical Addresses
- Social Insurance Number

**🇺🇸 United States**
- U.S. / U.K. Passport Number
- Bank Account Number
- Driver's License Number
- Individual Taxpayer Identification Number (ITIN)
- Physical Addresses
- Social Security Number (SSN)

**🇬🇧 United Kingdom**
- Driver's License Number
- Electoral Roll Number
- National Health Service Number
- National Insurance Number (NINO)
- Physical Addresses
- Unique Taxpayer Reference Number

**🇪🇺 European Union**
- Debit Card Number
- Driver's License Number
- National Identification Number
- Passport Number
- Social Security Number (SSN) or Equivalent ID
- Tax Identification Number (TIN)

**🇮🇹 Italy**
- Driver's License Number
- Fiscal Code
- Passport Number
- Physical Addresses
- Value Added Tax Number

**🇫🇮 Finland**
- European Health Insurance Number

**💳 Financial**
- Credit Card Number
- SWIFT Code

**🔐 Credentials & Technical**
- Azure Storage Account Key
- Azure Storage Account Key (Generic)
- General Password
- GitHub Personal Access Token
- Google API Key
- IP Address (v4 and v6)
- Microsoft Entra Client Secret
- User Login Credentials
- X.509 Certificate Private Key

**What you'll see:**
- A **policy tip warning** appears if you type sensitive data in chat
- You can **acknowledge and proceed** if there's a legitimate business need
- Incidents are logged for compliance review

**Best Practice:** Use sensitivity-labeled documents or encrypted email for sharing sensitive information rather than chat.

---

### 5. SharePoint Site Labels (NEW)

Key SharePoint sites now have **Protected B** labels applied at the site level, which:
- Controls external sharing settings
- Enforces privacy and security policies
- Ensures consistent protection across all documents in the site

---

### 6. Enhanced Encryption (NEW)

All Microsoft 365 data is now encrypted with **Leonardo Company-controlled encryption keys** (Customer Managed Keys):

| Service | Protection Status |
|---------|------------------|
| Teams Chat & Meetings | ✅ Leonardo-controlled keys |
| Teams Voicemail | ✅ Leonardo-controlled keys |
| Exchange Email & Calendar | ✅ Leonardo-controlled keys |
| SharePoint & OneDrive | ✅ Leonardo-controlled keys |

This provides additional sovereignty and control over our data for Protected B compliance.

---

## QUICK REFERENCE

**When in doubt → Choose Protected B**

| Always Protected B | General/Unclassified is OK |
|-------------------|---------------------------|
| Contract discussions | Team stand-ups |
| Technical specifications | Social gatherings |
| Government communications | Non-classified training |
| NDA-covered topics | Routine admin |
| Customer PII | General announcements |

---

## WHAT TO EXPECT

| Scenario | What You'll See |
|----------|-----------------|
| Creating a Teams meeting | Protected B label auto-selected |
| Composing an email | Must select sensitivity label before sending |
| Creating a Word/Excel/PowerPoint file | Must select sensitivity label before saving |
| Attaching a Protected B document to email | Email automatically inherits Protected B |
| Typing a SIN in Teams chat | Warning policy tip appears |
| Joining a Protected B meeting | Watermark on video/screen share |

---

## ACTION REQUIRED

**Please reply with "Acknowledged" by [DATE].**

---

## RESOURCES

- 📎 **Attached:** Complete User Guide, Quick Reference Card, Decision Tree
- 📹 **Video Tutorial:** [LINK]
- 💬 **Support:** itsupport@leonardocompany.ca or Fred Pearson (fred.pearson@leonardocompany.ca)

---

Thank you for your attention to these critical security enhancements. These controls protect Leonardo Company, our employees, our customers, and national security interests.

**Security is everyone's job.**

Fred Pearson  
Senior Architect  
fred.pearson@leonardocompany.ca

---

**Classification:** Internal Use Only