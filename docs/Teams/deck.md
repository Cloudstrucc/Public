---
marp: true
theme: gaia
paginate: true
size: 16:9
backgroundColor: #0F172A
color: #FFFFFF
headingDivider: 2
style: |
  section {
    font-family: "Segoe UI", sans-serif;
  }
  h1 {
    color:rgb(1, 52, 115);  
    text-align:right;  
  },
  h2, h3 {
    color: #60A5FA;        
  }
  .lead {
    font-size: 1.5rem;
    color: #93C5FD;
  }
---

# Microsoft Teams Secure Implementation
<!-- Title Slide with Microsoft Graphic -->
![bg 100%](https://www.uctoday.com/wp-content/uploads/2022/07/How-Secure-Is-Microsoft-Teams.jpg)

## Elevated Security Approach to M365 Collaboration

> Hardened configuration and control guidance  
> for government and defense sector clients
- Controlled collaboration with external partners  
- End-to-end data confidentiality  
- Compliance with Zero Trust and national security standards  

## Core Security Features

1. 🔐 External User MFA Enforcement  
2. 📵 Restrict External Meeting Access  
3. 🌐 Private Network Egress Control  
4. 🗝️ Customer Managed Encryption Keys (CMK)

## 1. External User MFA Enforcement

### Controls
- Guests must use invited email
- Enforced Conditional Access + MFA
- CAE to monitor session risk
- Prevent link forwarding

### Benefits
✅ Strong identity validation  
✅ Prevents credential misuse  
✅ Blocks hijacked invitations

## 2. Restrict External Meeting Features

### Controls
- Disable recording & transcription for guests
- Apply custom guest policies
- Restrict anonymous access

### Benefits
✅ Stops unauthorized content retention  
✅ Limits data exposure  
✅ Internal users remain in control

## 3. Secure Teams Traffic

- NSGs with `MicrosoftTeams` service tag
- Azure Firewall or secure web gateway
- DNS enforcement & hybrid routing
- Optional: Force tunneling
  
### Benefits
✅ Keeps Teams traffic off the public internet  
✅ Enables perimeter-level inspection  
✅ Aligns with traffic segmentation models

## 4. Customer Managed Keys (CMK)

### Controls
- Azure Key Vault with CMK integration
- Purview + PowerShell configuration
- Role-based access with revocation control

### Benefits
✅ You own your encryption  
✅ Fast key rotation or revocation  
✅ Regulatory-grade security posture

## Results

| Control Area     | Outcome                                 |
|------------------|------------------------------------------|
| Identity         | MFA enforced for guests only            |
| Data Sharing     | External content controls enforced      |
| Network Traffic  | Routed through trusted perimeter        |
| Encryption       | Fully owned with revocation capability  |

## Compliance Alignment

- ✅ **ITSG-33**, **CJIS**, **ISO 27001**  
- ✅ Microsoft 365 E5 Secure Score Optimized  
- ✅ Supports TBS/SSC secure cloud principles

## Visual Summary

![bg right 50%](https://cdn.jsdelivr.net/gh/microsoft/fluentui@master/assets/brand/microsoft-teams.png)

- Multi-layered identity and network control  
- Scalable for large departments  
- Integrates with Microsoft Purview & Sentinel

## How to Deploy

- Follow full configuration guide in build book  
- Use Azure Policy, Defender, and Purview for auditing  
- Integrate changes with change advisory board (CAB)

## Thank You

🛡 Built for secure collaboration  
🔧 Configurable to your tenant  
📂 Full documentation available  

👉 Contact your enterprise architect or visit [Microsoft Teams Security Docs](https://learn.microsoft.com/en-us/microsoftteams/security-compliance-overview)
