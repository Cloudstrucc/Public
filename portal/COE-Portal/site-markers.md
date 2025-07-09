# Site Markers Configuration for Power Platform CoE Portal

The following site markers need to be configured in your Power Pages portal management interface:

## Core Navigation & Branding
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Page Title` | Power Platform Excellence Centre | Main page title |
| `Skip to Main Content` | Skip to main content | Accessibility skip link |
| `Skip to Footer` | Skip to footer | Accessibility skip link |
| `French Page URL` | /fr/accueil | French version of the page |
| `Elections Canada Home` | https://www.elections.ca | Elections Canada main website |
| `Elections Canada Logo` | /assets/img/ec-logo.png | Elections Canada logo path |
| `Home Page` | / | Portal home page URL |

## Authentication & User Experience
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Sign In URL` | /signin | Portal sign-in page |
| `Sign In Button Text` | Sign In | Sign-in button label |
| `Sign In Prompt` | Please sign in to access citizen developer services and request resources. | Message for anonymous users |

## Hero Section Content
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Hero Title` | Power Platform Excellence Centre | Main hero section title |
| `Hero Subtitle` | Empowering Elections Canada citizen developers with governed, secure, and innovative Power Platform solutions. | Hero section description |

## Anonymous User Welcome
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Anonymous Welcome Title` | Welcome to the Power Platform Excellence Centre | Title for anonymous users |
| `Anonymous Welcome Text` | The Power Platform Excellence Centre (CoE) helps Elections Canada staff leverage Microsoft Power Platform tools to create innovative solutions while maintaining security and governance standards. | Welcome message for anonymous users |

## Service Tiles Configuration
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Services Title` | Available Services | Services section title |
| `Services Description` | Access the tools and resources you need for Power Platform development at Elections Canada. | Services section description |

### Environment Request Service
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Environment Request Title` | Environment Request | Service tile title |
| `Environment Request Description` | Request new development, test, or production environments for your Power Platform projects with proper governance and security controls. | Service description |
| `Environment Request URL` | /environment-request | URL to environment request app |

### DLP Policy Service
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `DLP Request Title` | DLP Policy Request | Service tile title |
| `DLP Request Description` | Request changes to Data Loss Prevention policies or analyze the impact of connector usage on your applications and flows. | Service description |
| `DLP Request URL` | /dlp-request | URL to DLP management app |

### App Catalog Service
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `App Catalog Title` | App Catalog | Service tile title |
| `App Catalog Description` | Browse and discover approved Power Platform applications available for use across Elections Canada departments. | Service description |
| `App Catalog URL` | /app-catalog | URL to app catalog |

### Developer Compliance Service
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Compliance Title` | Developer Compliance | Service tile title |
| `Compliance Description` | Ensure your applications meet Elections Canada standards and compliance requirements through our guided assessment process. | Service description |
| `Compliance URL` | /compliance-center | URL to compliance center |

### Training & Resources Service
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Training Title` | Training & Resources | Service tile title |
| `Training Description` | Access training materials, best practices, templates, and community resources to enhance your Power Platform skills. | Service description |
| `Training URL` | /training | URL to training resources |

### Support Service
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Support Title` | Support & Feedback | Service tile title |
| `Support Description` | Get help with your Power Platform projects, submit feedback, or connect with the CoE team for guidance and support. | Service description |
| `Support URL` | /support | URL to support portal |

## About Section
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `About CoE Title` | About the Power Platform Excellence Centre | About section title |
| `About CoE Text` | The Power Platform Excellence Centre at Elections Canada provides governance, guidance, and support for citizen developers using Microsoft Power Platform tools. Our mission is to enable innovation while maintaining security, compliance, and operational excellence. | About section description |
| `Key Benefits Title` | Key Benefits | Benefits section title |

## Quick Links Section
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Quick Links Title` | Quick Links | Quick links section title |
| `CoE Documentation` | /documentation | Link to CoE documentation |
| `Best Practices` | /best-practices | Link to best practices guide |
| `Governance Policies` | /governance | Link to governance policies |
| `Community Forum` | /community | Link to community forum |

## Footer Links
| Site Marker Name | Default Value | Description |
|------------------|---------------|-------------|
| `Elections Canada Contact` | https://www.elections.ca/content.aspx?section=cont | Contact page URL |
| `Privacy` | /privacy | Privacy policy page |
| `Terms` | /terms | Terms and conditions page |
| `Social Media` | https://www.elections.ca/content.aspx?section=med&dir=soc | Social media links |
| `Mobile App` | https://www.elections.ca/content.aspx?section=vot&dir=mob | Mobile app information |
| `Canada Wordmark` | /assets/img/wmms-blk.svg | Government of Canada wordmark |

## Implementation Notes

1. **Creating Site Markers**: In Power Pages management, navigate to Setup > Site Markers and create each marker with the specified name and default value.

2. **Customization**: Modify the default values to match your specific Elections Canada requirements and URL structure.

3. **Multilingual Support**: Create corresponding French versions of text markers for bilingual support.

4. **Asset Management**: Ensure logo and image assets are uploaded to the portal's file storage and paths are updated accordingly.

5. **URL Mapping**: Map the service URLs to actual Power Pages or external application URLs as appropriate for your CoE implementation.