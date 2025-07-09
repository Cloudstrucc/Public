# Power Platform CoE Portal Implementation Guide

## Overview

This implementation provides a modern, accessible home page for the Power Platform Centre of Excellence (CoE) Toolkit, specifically branded for Elections Canada. The design follows Power Pages best practices and integrates with the WET-BOEW (Web Experience Toolkit) framework.

## Files Provided

### 1. Home Page Template (`coe_homepage.html`)

- **Purpose**: Main home page template with Liquid markup
- **Framework**: WET-BOEW GCWeb theme compatible
- **Features**:
  - Responsive design with mobile-first approach
  - Authentication state awareness (anonymous vs authenticated users)
  - Service tiles for CoE features
  - Elections Canada branding
  - Accessibility compliance (WCAG 2.1)
  - Bilingual support structure

### 2. Custom CSS (`coe_custom_css.css`)

- **Purpose**: Modern styling that enhances the WET-BOEW theme
- **Features**:
  - Gradient hero sections
  - Animated service cards with hover effects
  - Statistics counter styling
  - Responsive breakpoints
  - High contrast and reduced motion support
  - Elections Canada color scheme integration

### 3. Custom JavaScript (`coe_custom_js.js`)

- **Purpose**: Enhanced interactivity and accessibility
- **Features**:
  - Animated statistics counters
  - Intersection Observer for progressive enhancement
  - Accessibility keyboard navigation
  - Screen reader announcements
  - Service availability checking
  - Mobile responsiveness handling

### 4. Site Markers Configuration (`sitemarkers_config.md`)

- **Purpose**: Configurable content for easy management
- **Contains**: All text content, URLs, and links as manageable site markers

### 5. Content Snippets Configuration (`snippets_config.md`)

- **Purpose**: Dynamic content elements
- **Contains**: Statistics, benefits list, and other variable content

## Power Platform CoE Services Showcased

The portal highlights key CoE Toolkit features:

1. **Environment Request Management**

   - Streamlined environment provisioning
   - Admin approval workflows
   - Governance controls
2. **DLP Policy Management**

   - Impact analysis tools
   - Policy change requests
   - Connector governance
3. **App Catalog**

   - Centralized app discovery
   - Promoted applications
   - Usage analytics
4. **Developer Compliance Center**

   - Compliance monitoring
   - Audit trails
   - Best practices guidance
5. **Training & Resources**

   - Citizen developer enablement
   - Documentation portal
   - Community forums
6. **Support & Feedback**

   - Help desk integration
   - Feedback collection
   - Admin communication

## Implementation Steps

### Step 1: Portal Setup

1. Create a new Power Pages site or use existing portal
2. Ensure WET-BOEW theme is properly configured
3. Set up authentication providers (Azure AD, B2C, etc.)

### Step 2: Upload Assets

1. Upload Elections Canada logos and branding assets
2. Place custom CSS file in portal's CSS folder
3. Place custom JavaScript file in portal's JavaScript folder

### Step 3: Configure Site Markers

Using the provided site markers configuration:

1. Navigate to Portal Management > Setup > Site Markers
2. Create each site marker with the specified names and default values
3. Customize URLs to match your environment structure
4. Update branding elements with your specific assets

### Step 4: Configure Content Snippets

Using the provided snippets configuration:

1. Navigate to Portal Management > Content > Content Snippets
2. Create each snippet with the specified names and values
3. Update statistics to reflect your actual CoE metrics

### Step 5: Create Page Template

1. In Portal Management, create a new page template
2. Copy the provided HTML template content
3. Ensure proper Liquid syntax and template inheritance
4. Set as the home page template

### Step 6: Service Integration

Map the service URLs to actual applications:

1. **Environment Request**: Connect to CoE Environment Request apps
2. **DLP Management**: Connect to DLP Impact Analysis app
3. **App Catalog**: Connect to App Catalog canvas app
4. **Compliance**: Connect to Developer Compliance Center
5. **Training**: Connect to learning resources
6. **Support**: Connect to help desk or Teams channel

### Step 7: Testing & Validation

1. Test anonymous user experience
2. Test authenticated user experience
3. Validate accessibility compliance
4. Test responsive design on various devices
5. Verify all service links function correctly

## Customization Options

### Branding

- Update color scheme in CSS variables
- Replace Elections Canada logos with your organization's branding
- Modify footer links and content
- Adjust hero section messaging

### Content

- Modify site markers for different messaging
- Update statistics in content snippets
- Add additional service tiles as needed
- Customize welcome messages and descriptions

### Functionality Extensions

- Connect to real-time CoE Toolkit APIs for live data
- Integrate with Power BI dashboards for enhanced analytics
- Add user notification systems
- Implement role-based service visibility
- Connect to Microsoft Graph for user profile data

## Best Practices Implemented

### Power Pages Standards

- Uses Liquid templating engine properly
- Implements site markers for content management
- Follows entity permission model for authenticated content
- Compatible with Power Pages caching mechanisms

### WET-BOEW Integration

- Maintains GCWeb theme compatibility
- Preserves accessibility features
- Uses standard CSS classes and components
- Follows Government of Canada design standards

### Accessibility Compliance

- WCAG 2.1 AA compliant structure
- Proper heading hierarchy
- Keyboard navigation support
- Screen reader optimizations
- High contrast mode support
- Reduced motion preferences

### Performance Optimization

- Progressive enhancement approach
- Lazy loading for animations
- Efficient CSS selectors
- Minimal JavaScript footprint
- Intersection Observer for scroll effects

## Security Considerations

### Authentication

- Proper user state checking with Liquid templates
- Secure service URL routing
- Role-based content visibility

### Data Protection

- No sensitive data in client-side code
- Secure API endpoints for service integration
- Proper CORS configuration for external services

### Content Security

- XSS protection through Liquid escaping
- Secure external resource loading (CDN links)
- Validated input for dynamic content

## Maintenance & Updates

### Regular Updates

- Review and update statistics monthly
- Monitor service availability and update links
- Keep WET-BOEW framework updated
- Update CoE Toolkit integration as features evolve

### Monitoring

- Set up analytics to track usage patterns
- Monitor service tile click-through rates
- Track user authentication success rates
- Monitor page performance metrics

### Content Management

- Establish content review schedule
- Create content approval workflow
- Document any customizations made
- Maintain change log for tracking updates

## Troubleshooting Common Issues

### Authentication Problems

- Verify user object is properly configured in Liquid context
- Check authentication provider configuration
- Validate user permissions and roles

### Styling Issues

- Ensure CSS file is properly linked and loading
- Check for CSS conflicts with WET-BOEW styles
- Validate responsive breakpoints on different devices

### JavaScript Errors

- Check browser console for error messages
- Verify jQuery dependency is loaded (included with WET-BOEW)
- Test JavaScript functionality with and without authentication

### Content Not Displaying

- Verify site markers are created with exact names
- Check content snippets configuration
- Validate Liquid template syntax

## Integration with CoE Toolkit Components

### Core Components

- **Power Platform Admin View**: Link from admin-specific sections
- **DLP Impact Analysis**: Direct integration for policy management
- **Set New App Owner**: Connect to governance workflows

### Governance Components

- **App Archive Process**: Link to cleanup and governance tools
- **Compliance Detail Request**: Integration with compliance workflows

### Nurture Components

- **Welcome Email Flow**: Trigger from new user registrations
- **Training in a Day**: Link to training resources and schedules
- **Community Forums**: Connect to maker community platforms

## Future Enhancements

### Phase 2 Features

- Real-time dashboard widgets
- User activity feeds
- Personalized recommendations
- Advanced search capabilities

### Advanced Integrations

- Microsoft Teams integration for notifications
- Power BI embedded reports
- SharePoint document integration
- Dynamics 365 case management

### Analytics & Reporting

- Usage analytics dashboard
- User journey tracking
- Service adoption metrics
- Performance monitoring

## Support & Documentation

### Additional Resources

- [Power Pages Documentation](https://docs.microsoft.com/en-us/power-pages/)
- [CoE Starter Kit Documentation](https://docs.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [WET-BOEW Framework](https://wet-boew.github.io/)
- [Government of Canada Design System](https://design.canada.ca/)

### Getting Help

- Power Platform Community Forums
- CoE Starter Kit GitHub Issues
- Microsoft Support for Power Pages
- Elections Canada IT Support (internal)

---

## Summary

This implementation provides a complete, production-ready home page for your Power Platform CoE portal that:

✅ **Follows Power Pages best practices** with proper Liquid templating and site marker usage
✅ **Integrates seamlessly with WET-BOEW** maintaining Government of Canada standards
✅ **Provides responsive, accessible design** meeting WCAG 2.1 requirements
✅ **Showcases key CoE Toolkit services** for citizen developers
✅ **Supports both anonymous and authenticated users** with appropriate content
✅ **Branded specifically for Elections Canada** with proper visual identity
✅ **Includes comprehensive configuration** through site markers and snippets
✅ **Provides extensible architecture** for future enhancements

# Annex - Deploy

## **Key Features:**

### 🔧 **Automated Deployment**

* Deploys all 42 site markers and 9 content snippets automatically
* Uses Power Platform CLI for reliable data operations
* Handles both creation of new items and updates to existing ones

### 🛡️ **Error Handling & Validation**

* Checks for Power Platform CLI installation
* Authenticates to your environment securely
* Auto-discovers Power Pages website ID if not provided
* Comprehensive error handling with colored output

### 🎯 **Smart Features**

* **Duplicate Detection** : Checks if markers/snippets already exist
* **Update Mode** : `-UpdateExisting` switch to update existing content
* **Multi-Language Support** : Configurable language codes
* **Auto-Discovery** : Finds your Power Pages site automatically

## **Usage Examples:**

### Basic Deployment:

<pre><div class="relative group/copy rounded-lg"><div class="sticky opacity-0 group-hover/copy:opacity-100 top-2 py-2 h-12 w-0 float-right"><div class="absolute right-0 h-8 px-2 items-center inline-flex"></div></div></div></pre>
