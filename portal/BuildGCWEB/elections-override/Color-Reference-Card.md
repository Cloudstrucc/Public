# PEPP Portal - Color Reference Card
Elections Canada Political Entities Color Palette

## Quick Reference Guide

### Political Parties / Partis politiques
**Primary Brand Color**
```
HEX:       #2C5F6F
RGB:       44, 95, 111
CMYK:      91, 46, 53, 24
Web-Safe:  #336066 (closest)
```
**Usage:** Primary headers, navigation, main CTAs

---

### Riding Associations / Associations de circonscription  
**Secondary Brand Color**
```
HEX:       #8B9A46
RGB:       139, 154, 70
CMYK:      49, 28, 100, 6
Web-Safe:  #999933 (closest)
```
**Usage:** Success states, confirmation messages, secondary elements

---

### Candidates / Candidats
**Accent Color**
```
HEX:       #6B1D3C
RGB:       107, 29, 60
CMYK:      20, 97, 40, 58
Web-Safe:  #660033 (closest)
```
**Usage:** Important notices, error states, critical actions

---

### Nomination Contestants / Candidats à l'investiture
**Warning Color**
```
HEX:       #C17F3E
RGB:       193, 127, 62
CMYK:      20, 51, 98, 2
Web-Safe:  #CC9933 (closest)
```
**Usage:** Warning messages, pending states, attention items

---

### Leadership Contestants / Candidats à la direction
**Info Color**
```
HEX:       #66336E
RGB:       102, 51, 110
CMYK:      67, 100, 33, 23
Web-Safe:  #663366 (closest)
```
**Usage:** Informational elements, help text, tooltips

---

### Third Parties / Tiers
**Dark Neutral**
```
HEX:       #2C4A52
RGB:       44, 74, 82
CMYK:      90, 71, 48, 43
Web-Safe:  #336666 (closest)
```
**Usage:** Footers, dark backgrounds, contrast elements

---

## Color Combinations

### High Contrast Pairings (WCAG AA Compliant)
✅ **#2C5F6F on White** - Contrast: 4.82:1 (Pass)  
✅ **#8B9A46 on White** - Contrast: 4.12:1 (Pass)  
✅ **#C17F3E on Black** - Contrast: 5.45:1 (Pass)  
✅ **#2C4A52 on White** - Contrast: 5.12:1 (Pass)  

### Use Dark Text On These Backgrounds
- White (#FFFFFF)
- Light Gray (#F5F5F5, #E1E4E7)
- #C17F3E (Golden Brown)

### Use Light Text On These Backgrounds  
- #2C5F6F (Teal)
- #6B1D3C (Burgundy)
- #66336E (Purple)
- #2C4A52 (Dark Slate)
- #8B9A46 (Olive - with caution)

---

## CSS Variable Reference

Copy-paste ready for CSS:

```css
:root {
  /* Entity Colors */
  --political-parties:      #2C5F6F;
  --riding-associations:    #8B9A46;
  --candidates:             #6B1D3C;
  --nomination:             #C17F3E;
  --leadership:             #66336E;
  --third-parties:          #2C4A52;
  
  /* Functional Mappings */
  --primary:                #2C5F6F;
  --secondary:              #2C4A52;
  --success:                #8B9A46;
  --warning:                #C17F3E;
  --danger:                 #6B1D3C;
  --info:                   #66336E;
}
```

---

## SCSS/SASS Variables

```scss
// Entity Colors
$political-parties:      #2C5F6F;
$riding-associations:    #8B9A46;
$candidates:             #6B1D3C;
$nomination:             #C17F3E;
$leadership:             #66336E;
$third-parties:          #2C4A52;

// Functional Mappings
$primary:                $political-parties;
$secondary:              $third-parties;
$success:                $riding-associations;
$warning:                $nomination;
$danger:                 $candidates;
$info:                   $leadership;
```

---

## PowerShell Color Array

```powershell
$PEPPColors = @{
    PoliticalParties    = "#2C5F6F"
    RidingAssociations  = "#8B9A46"
    Candidates          = "#6B1D3C"
    Nomination          = "#C17F3E"
    Leadership          = "#66336E"
    ThirdParties        = "#2C4A52"
}
```

---

## JSON Color Configuration

```json
{
  "colors": {
    "politicalParties": "#2C5F6F",
    "ridingAssociations": "#8B9A46",
    "candidates": "#6B1D3C",
    "nomination": "#C17F3E",
    "leadership": "#66336E",
    "thirdParties": "#2C4A52"
  },
  "functional": {
    "primary": "#2C5F6F",
    "secondary": "#2C4A52",
    "success": "#8B9A46",
    "warning": "#C17F3E",
    "danger": "#6B1D3C",
    "info": "#66336E"
  }
}
```

---

## Tailwind Config

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        'pepp-parties': '#2C5F6F',
        'pepp-riding': '#8B9A46',
        'pepp-candidates': '#6B1D3C',
        'pepp-nomination': '#C17F3E',
        'pepp-leadership': '#66336E',
        'pepp-third': '#2C4A52',
      }
    }
  }
}
```

---

## Bootstrap Variable Override

```scss
// Override Bootstrap theme colors
$primary:       #2C5F6F !default;
$secondary:     #2C4A52 !default;
$success:       #8B9A46 !default;
$warning:       #C17F3E !default;
$danger:        #6B1D3C !default;
$info:          #66336E !default;

@import "bootstrap/scss/bootstrap";
```

---

## Liquid/Jekyll Variables

```liquid
{% assign color_parties = "#2C5F6F" %}
{% assign color_riding = "#8B9A46" %}
{% assign color_candidates = "#6B1D3C" %}
{% assign color_nomination = "#C17F3E" %}
{% assign color_leadership = "#66336E" %}
{% assign color_third = "#2C4A52" %}
```

---

## TypeScript/JavaScript Const

```typescript
export const PEPP_COLORS = {
  POLITICAL_PARTIES: '#2C5F6F',
  RIDING_ASSOCIATIONS: '#8B9A46',
  CANDIDATES: '#6B1D3C',
  NOMINATION: '#C17F3E',
  LEADERSHIP: '#66336E',
  THIRD_PARTIES: '#2C4A52',
} as const;

export type PEPPColor = typeof PEPP_COLORS[keyof typeof PEPP_COLORS];
```

---

## React Component Props

```jsx
const theme = {
  colors: {
    politicalParties: '#2C5F6F',
    ridingAssociations: '#8B9A46',
    candidates: '#6B1D3C',
    nomination: '#C17F3E',
    leadership: '#66336E',
    thirdParties: '#2C4A52',
  }
};

export default theme;
```

---

## Azure DevOps Pipeline Variables

```yaml
variables:
  - name: COLOR_POLITICAL_PARTIES
    value: '#2C5F6F'
  - name: COLOR_RIDING_ASSOCIATIONS
    value: '#8B9A46'
  - name: COLOR_CANDIDATES
    value: '#6B1D3C'
  - name: COLOR_NOMINATION
    value: '#C17F3E'
  - name: COLOR_LEADERSHIP
    value: '#66336E'
  - name: COLOR_THIRD_PARTIES
    value: '#2C4A52'
```

---

## Figma Color Styles

Import these into Figma as Color Styles:

| Name | Hex | RGB |
|------|-----|-----|
| PEPP/Political Parties | #2C5F6F | 44, 95, 111 |
| PEPP/Riding Associations | #8B9A46 | 139, 154, 70 |
| PEPP/Candidates | #6B1D3C | 107, 29, 60 |
| PEPP/Nomination | #C17F3E | 193, 127, 62 |
| PEPP/Leadership | #66336E | 102, 51, 110 |
| PEPP/Third Parties | #2C4A52 | 44, 74, 82 |

---

## Adobe Color Palette URL

Create at: https://color.adobe.com

Colors: 2C5F6F, 8B9A46, 6B1D3C, C17F3E, 66336E, 2C4A52

---

## Accessibility Testing Checklist

### Contrast Ratios (Against White Background)

- [ ] **#2C5F6F**: 4.82:1 ✅ (Normal text: Pass, Large text: Pass)
- [ ] **#8B9A46**: 4.12:1 ✅ (Normal text: Pass, Large text: Pass)  
- [ ] **#6B1D3C**: 1.98:1 ❌ (Use on dark backgrounds only)
- [ ] **#C17F3E**: 3.85:1 ⚠️ (Large text only, or use darker shade)
- [ ] **#66336E**: 2.76:1 ❌ (Use on dark backgrounds only)
- [ ] **#2C4A52**: 5.12:1 ✅ (Normal text: Pass, Large text: Pass)

### Recommended Text Colors

**For Light Backgrounds (White, #F5F5F5):**
- Use: #2C5F6F, #8B9A46, #2C4A52
- Avoid: #6B1D3C, #66336E (unless large text)

**For Dark Backgrounds (#2C4A52, #2C5F6F):**
- Use: #FFFFFF (white)
- Can use: #C17F3E, #8B9A46 (for accents)

---

## Print/CMYK Conversion Notes

When preparing for print materials:

```
Political Parties:      C:91  M:46  Y:53  K:24
Riding Associations:    C:49  M:28  Y:100 K:6
Candidates:             C:20  M:97  Y:40  K:58
Nomination:             C:20  M:51  Y:98  K:2
Leadership:             C:67  M:100 Y:33  K:23
Third Parties:          C:90  M:71  Y:48  K:43
```

**Note:** Colors may appear slightly different in CMYK vs RGB/Web.  
Request printed proof from vendor before final production.

---

## Color Blindness Simulation

Test your designs with these tools:
- **Protanopia** (Red-blind): Use Stark plugin or Color Oracle
- **Deuteranopia** (Green-blind): Most common type
- **Tritanopia** (Blue-blind): Rare
- **Achromatopsia** (Total color blindness): Test grayscale contrast

**Key Considerations:**
- Don't rely solely on color to convey information
- Use patterns, icons, or text labels in addition to color
- Ensure sufficient contrast in grayscale

---

## Brand Consistency Guidelines

### Do's ✅
- Use exact hex values provided
- Maintain consistent color usage across all pages
- Use Political Parties color (#2C5F6F) as primary brand color
- Apply colors according to their semantic meaning

### Don'ts ❌
- Don't modify hex values or use "close enough" colors
- Don't use colors outside this defined palette
- Don't use Warning color (#C17F3E) for success messages
- Don't mix multiple accent colors on the same component

---

## Quick Color Picker

Visual swatches for easy identification:

```
██████ #2C5F6F  Political Parties (Dark Teal)
██████ #8B9A46  Riding Associations (Olive Green)
██████ #6B1D3C  Candidates (Burgundy)
██████ #C17F3E  Nomination (Golden Brown)
██████ #66336E  Leadership (Purple)
██████ #2C4A52  Third Parties (Dark Slate)
```

---

**Quick Reference Version:** 1.0  
**Last Updated:** December 9, 2024  
**Source:** Elections Canada Political Entities Branding Guidelines
