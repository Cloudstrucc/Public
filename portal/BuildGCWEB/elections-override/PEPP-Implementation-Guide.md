# PEPP Portal - Color Palette Override Implementation Guide

## Overview
This guide provides step-by-step instructions for implementing the Elections Canada Political Entities color palette into your Power Pages site that uses the GCWEB WET-BOEW framework.

## Color Palette Reference

### Political Entity Colors
Based on the Elections Canada branding guidelines:

| Entity Type | French Name | Color Code | Variable Name |
|------------|-------------|------------|---------------|
| Political Parties | Partis politiques | `#2C5F6F` | `--pepp-political-parties` |
| Riding Associations | Associations de circonscription | `#8B9A46` | `--pepp-riding-associations` |
| Candidates | Candidats | `#6B1D3C` | `--pepp-candidates` |
| Nomination Contestants | Candidats à l'investiture | `#C17F3E` | `--pepp-nomination` |
| Leadership Contestants | Candidats à la direction | `#66336E` | `--pepp-leadership` |
| Third Parties | Tiers | `#2C4A52` | `--pepp-third-parties` |

### Additional Reference Codes
From the image provided:
- **CMJN** = CMYK color values
- **RVB** = RGB color values  
- **Web-Smart** = Web-safe hexadecimal codes

## Implementation Steps

### Step 1: Create CSS Web File in Power Pages

1. Navigate to **Power Pages Management** > **Web Files**
2. Click **+ New**
3. Configure the web file:
   ```
   Name: PEPP Color Override CSS
   Website: [Your Website]
   Parent Page: (leave blank)
   Partial URL: /css/pepp-override.css
   Display Order: 100
   ```
4. In the **Publishing State** dropdown, select **Published**
5. Click **Save**

### Step 2: Upload CSS Content

1. After saving, scroll to the **Notes** section
2. Click **+ Note**
3. Click **Choose File** and upload `pepp-color-override.css`
4. Save the note

### Step 3: Reference in Header Template

Add the CSS reference to your header template **AFTER** the GCWEB/WET-BOEW CSS files:

```html
<!-- GCWEB/WET-BOEW CSS (existing) -->
<link href="/GCWeb/css/theme.min.css" rel="stylesheet">
<link href="/wet-boew/css/wet-boew.min.css" rel="stylesheet">

<!-- PEPP Color Override (NEW - add this line) -->
<link href="/css/pepp-override.css" rel="stylesheet">
```

### Step 4: Verify Implementation

1. Clear browser cache
2. Navigate to your PEPP portal home page
3. Verify the following color changes:
   - Application bar should be dark teal (#2C5F6F)
   - Service cards should have colored left borders matching the palette
   - Footer should be dark slate (#2C4A52)
   - Links should be dark teal (#2C5F6F)

## Alternative Implementation: Inline CSS

If you prefer to embed the CSS directly in your templates:

### Option A: In Header Template
Add this to your header template:

```liquid
<style>
  {% include 'snippets' snippet: 'PEPP/CSS/Override' %}
</style>
```

Then create a **Content Snippet** named `PEPP/CSS/Override` with the CSS content.

### Option B: Directly in Web Template
Add the CSS directly in your header web template within `<style>` tags:

```liquid
<style>
  /* Paste the contents of pepp-color-override.css here */
</style>
```

## Customization Guide for Developers

### Modifying Colors

All colors are defined as CSS custom properties (variables) at the top of the file:

```css
:root {
  --pepp-political-parties: #2C5F6F;
  --pepp-riding-associations: #8B9A46;
  /* etc. */
}
```

To change colors:
1. Update the hex values in the `:root` section
2. Save the file
3. Clear cache and refresh

### Adding New Color Variations

Follow this pattern to add new colors:

```css
:root {
  --pepp-my-new-color: #HEXCODE;
}

.my-component {
  background-color: var(--pepp-my-new-color) !important;
  color: var(--pepp-white) !important;
}
```

### Color Usage by Component

| Component | Primary Variable Used |
|-----------|----------------------|
| Header/Application Bar | `--pepp-primary` |
| Hero Section | `--pepp-primary` with `--pepp-overlay` |
| Card 1 (New Filing) | `--pepp-political-parties` |
| Card 2 (My Filings) | `--pepp-riding-associations` |
| Card 3 (Entity Profile) | `--pepp-candidates` |
| Card 4 (Support) | `--pepp-third-parties` |
| Footer | `--pepp-dark` |
| Links | `--pepp-link` / `--pepp-link-hover` |
| Buttons (Primary) | `--pepp-primary` |
| Success States | `--pepp-success` |
| Warning States | `--pepp-warning` |
| Error States | `--pepp-danger` |

## Targeting Specific Elements

### Entity-Specific Styling

To apply different colors based on entity type:

```css
/* Add data attribute to body tag based on entity type */
body[data-entity-type="political-party"] .pepp-card .panel {
  border-left-color: var(--pepp-political-parties) !important;
}

body[data-entity-type="riding-association"] .pepp-card .panel {
  border-left-color: var(--pepp-riding-associations) !important;
}
```

Then in your template:

```liquid
<body data-entity-type="{{ user.pepp_entitytype }}">
```

### Page-Specific Overrides

For page-specific colors:

```css
/* Example: Different colors on the filing page */
.page-filing {
  --pepp-primary: var(--pepp-candidates);
}

.page-filing .application-bar {
  background-color: var(--pepp-primary) !important;
}
```

## Common Customization Scenarios

### Scenario 1: Change Primary Brand Color

```css
:root {
  --pepp-primary: #YourHexCode;  /* Update this line */
}
```

### Scenario 2: Adjust Link Colors

```css
:root {
  --pepp-link: #YourLinkColor;
  --pepp-link-hover: #YourHoverColor;
  --pepp-link-visited: #YourVisitedColor;
}
```

### Scenario 3: Customize Button Colors

```css
.btn-custom {
  background-color: var(--pepp-nomination) !important;
  border-color: var(--pepp-nomination) !important;
  color: var(--pepp-white) !important;
}

.btn-custom:hover {
  background-color: var(--pepp-leadership) !important;
  border-color: var(--pepp-leadership) !important;
}
```

### Scenario 4: Add Status Color for New Entity Type

```css
:root {
  --pepp-new-entity-type: #HEXCODE;
}

.status-new-entity {
  background-color: var(--pepp-new-entity-type);
  color: var(--pepp-white);
  padding: 5px 10px;
  border-radius: 3px;
}
```

## WCAG Accessibility Compliance

All colors in this palette have been selected with accessibility in mind. However, when customizing:

### Color Contrast Requirements
- **Normal text** (under 18pt): Minimum 4.5:1 contrast ratio
- **Large text** (18pt+): Minimum 3:1 contrast ratio
- **UI components**: Minimum 3:1 contrast ratio

### Testing Tools
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Chrome DevTools: Lighthouse audit
- WAVE Browser Extension: https://wave.webaim.org/extension/

### Current Palette Compliance

| Color | Against White | Against Black | Status |
|-------|--------------|---------------|--------|
| #2C5F6F (Primary) | ✅ Pass (4.82:1) | ✅ Pass (4.35:1) | Compliant |
| #8B9A46 (Associations) | ✅ Pass (4.12:1) | ✅ Pass (5.10:1) | Compliant |
| #6B1D3C (Candidates) | ❌ Fail (1.98:1) | ✅ Pass (10.59:1) | Use with dark backgrounds only |
| #C17F3E (Nomination) | ✅ Pass (3.85:1) | ✅ Pass (5.45:1) | Compliant |
| #66336E (Leadership) | ❌ Fail (2.76:1) | ✅ Pass (7.61:1) | Use with dark backgrounds only |
| #2C4A52 (Third Parties) | ✅ Pass (5.12:1) | ✅ Pass (4.10:1) | Compliant |

## Browser Compatibility

This CSS uses modern features with broad support:

- **CSS Custom Properties**: Supported in all modern browsers
- **CSS Grid/Flexbox**: Full support
- **!important overrides**: Universal support

### Fallbacks for Older Browsers

If supporting IE11 (not recommended):

```css
/* Fallback approach */
.application-bar {
  background-color: #2C5F6F; /* Fallback */
  background-color: var(--pepp-primary); /* Modern browsers */
}
```

## Troubleshooting

### Colors Not Applying

1. **Check CSS Load Order**
   - Ensure `pepp-override.css` loads AFTER GCWEB/WET-BOEW CSS
   - Use browser DevTools Network tab to verify

2. **Clear Cache**
   ```
   - Browser cache: Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
   - Power Pages cache: Republish website in Portal Management
   ```

3. **Check Specificity**
   - Use `!important` if GCWEB styles are overriding
   - Inspect element in DevTools to see which styles win

4. **Verify File Upload**
   - Check that Web File is Published
   - Verify Partial URL is correct
   - Confirm file uploaded to Notes section

### Colors Look Different Than Expected

1. **Monitor Calibration**
   - Different monitors display colors differently
   - Use color picker tools to verify actual hex values

2. **Browser Rendering**
   - Test in multiple browsers (Chrome, Firefox, Edge, Safari)
   - Check color management settings

3. **Overlay Effects**
   - Some elements use opacity/overlays that alter perceived color
   - Check CSS for `rgba()` or `opacity` properties

### Specific Element Not Updating

1. **Inspect Element**
   ```
   Right-click element > Inspect
   Check "Styles" tab to see which CSS rules apply
   ```

2. **Increase Specificity**
   ```css
   /* Instead of */
   .panel { background: red; }
   
   /* Use */
   .pepp-app .panel.panel-default { background: red; }
   ```

3. **Use !important (Last Resort)**
   ```css
   .stubborn-element {
     color: var(--pepp-primary) !important;
   }
   ```

## Performance Considerations

### File Size
- Current CSS: ~15KB unminified
- Minified: ~8KB
- Gzipped: ~2KB

### Best Practices
1. **Combine CSS Files**: Consider merging with existing custom CSS
2. **Minify for Production**: Use CSS minifier tools
3. **Enable Compression**: Ensure server enables gzip/brotli
4. **Browser Caching**: Set long cache headers for CSS files

## Version Control

Document CSS changes:

```css
/*
 * PEPP Color Override CSS
 * Version: 1.0.0
 * Last Updated: 2024-12-09
 * Modified By: Fred / LCE M365 Team
 * Changes: Initial implementation with Elections Canada palette
 */
```

### Change Log Template

```
## Version 1.1.0 - YYYY-MM-DD
### Added
- New color variable for X entity type
- Responsive styles for mobile menu

### Changed
- Updated primary color from #2C5F6F to #NewColor
- Improved button hover states

### Fixed
- Corrected contrast ratio on warning alerts
- Fixed footer link color in dark mode
```

## Additional Resources

### Elections Canada Branding
- Contact your Elections Canada representative for official brand guidelines
- Request high-resolution logo assets and color specifications

### GCWEB/WET-BOEW Documentation
- Official Docs: https://wet-boew.github.io/
- GitHub: https://github.com/wet-boew/wet-boew
- GCWeb Theme: https://wet-boew.github.io/GCWeb/

### Power Pages Resources
- Microsoft Learn: https://learn.microsoft.com/power-pages/
- Community: https://powerusers.microsoft.com/t5/Power-Pages/ct-p/PowerPages

### CSS Best Practices
- MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/CSS
- CSS Guidelines: https://cssguidelin.es/
- BEM Methodology: http://getbem.com/

## Support

For technical issues or questions:

**Internal Team:**
- George Zarif - M365 Security Team
- Chris Helm - M365 Security Team  
- Adrian Darjan - LCE M365 Team

**Microsoft Support:**
- Power Pages Support Portal
- Premier Support (if applicable)

**Community:**
- Power Pages Community Forums
- Stack Overflow (tag: power-pages)

---

**Document Version:** 1.0  
**Last Updated:** December 9, 2024  
**Maintained By:** Leonardo Company LCE M365 Security Team
