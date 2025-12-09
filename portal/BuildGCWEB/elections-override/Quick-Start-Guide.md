# PEPP Color Palette Override - Quick Start Guide

## 🎯 Goal
Replace the default GCWEB/WET-BOEW colors in your Power Pages PEPP portal with the Elections Canada political entities color palette.

## 📋 Prerequisites Checklist

- [ ] Power Pages website is created and active
- [ ] GCWEB WET-BOEW framework is integrated
- [ ] You have System Administrator or Web Administrator role
- [ ] PowerShell 5.1 or higher installed (for automated deployment)
- [ ] Access to Power Pages Management Portal

## ⚡ Quick Implementation (5 Steps)

### Step 1: Download Files ✅
You have already received:
- ✅ `pepp-color-override.css` - The CSS override file
- ✅ `PEPP-Implementation-Guide.md` - Detailed documentation
- ✅ `Color-Reference-Card.md` - Color reference guide
- ✅ `Deploy-PEPP-CSS.ps1` - Automated deployment script

### Step 2: Choose Deployment Method

**Option A: Automated (Recommended) 🤖**
```powershell
.\Deploy-PEPP-CSS.ps1 -Environment "https://yourorg.crm3.dynamics.com" -CSSFilePath ".\pepp-color-override.css" -WebsiteName "PEPP Portal"
```
**Takes:** 2 minutes  
**Skip to:** Step 4 if successful

**Option B: Manual 👨‍💻**
Continue to Step 3 below

### Step 3: Manual Deployment (If not using PowerShell)

1. **Login to Power Pages**
   - Navigate to https://make.powerpages.microsoft.com
   - Select your PEPP Portal website
   - Click **Edit**

2. **Create Web File**
   - Go to **Set up** workspace (left navigation)
   - Click **Web files**
   - Click **+ New**
   - Fill in details:
     ```
     Name: PEPP Color Override CSS
     Website: [Select your website]
     Parent Page: (leave blank)
     Partial URL: /css/pepp-override.css
     Display Order: 100
     Publishing State: Published
     ```
   - Click **Save**

3. **Upload CSS File**
   - In the new Web File record, scroll to **Notes** section
   - Click **+ New Note**
   - Click **Choose File**
   - Select `pepp-color-override.css`
   - Add title: "CSS File"
   - Click **Save**

### Step 4: Add CSS Reference to Header

1. **Open Header Template**
   - In Power Pages Studio, go to **Templates**
   - Find your header template (e.g., "Header" or "PEPP Header")

2. **Add CSS Link**
   Find this section in your header:
   ```html
   <link href="/GCWeb/css/theme.min.css" rel="stylesheet">
   <link href="/wet-boew/css/wet-boew.min.css" rel="stylesheet">
   ```
   
   Add this line **AFTER** the GCWEB CSS:
   ```html
   <link href="/css/pepp-override.css" rel="stylesheet">
   ```

3. **Save Template**

### Step 5: Test & Verify

1. **Clear Cache**
   ```
   - Browser: Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
   - Power Pages: Sync configuration or republish
   ```

2. **Test Pages**
   - [ ] Home page (authenticated)
   - [ ] Home page (anonymous)
   - [ ] Service card colors
   - [ ] Header color
   - [ ] Footer color
   - [ ] Links color

3. **Verify Colors**
   Use browser DevTools (F12) to inspect elements:
   - Application bar should be: `#2C5F6F`
   - Card 1 border should be: `#2C5F6F`
   - Card 2 border should be: `#8B9A46`
   - Card 3 border should be: `#6B1D3C`
   - Card 4 border should be: `#2C4A52`

## 🎨 Color Reference (Quick Look)

| Element | Color | Hex |
|---------|-------|-----|
| Primary (Header/Nav) | Teal | `#2C5F6F` |
| Card 1 - New Filing | Teal | `#2C5F6F` |
| Card 2 - My Filings | Olive | `#8B9A46` |
| Card 3 - Entity Profile | Burgundy | `#6B1D3C` |
| Card 4 - Support | Slate | `#2C4A52` |
| Footer | Slate | `#2C4A52` |
| Links | Teal | `#2C5F6F` |

## 🔧 Troubleshooting

### Issue: Colors not changing
**Solution:**
1. Verify CSS file is uploaded (check Web File > Notes)
2. Confirm `<link>` tag is present in header
3. Clear browser cache (Ctrl+F5)
4. Check browser console for 404 errors (F12 > Console)
5. Verify CSS loads after GCWEB CSS (order matters!)

### Issue: Some colors working, others not
**Solution:**
1. Check CSS specificity - use browser DevTools
2. Ensure `!important` flags are present in CSS
3. Look for inline styles overriding CSS
4. Verify no typos in hex codes

### Issue: PowerShell script fails
**Solution:**
```powershell
# Install required module
Install-Module Microsoft.Xrm.Data.PowerShell -Scope CurrentUser -Force

# Re-run with verbose output
.\Deploy-PEPP-CSS.ps1 -Environment "your-url" -CSSFilePath "path" -Verbose
```

### Issue: 404 error on CSS file
**Solution:**
1. Verify Web File `Partial URL` is exactly: `/css/pepp-override.css`
2. Check Web File `Publishing State` is set to "Published"
3. Ensure note with CSS content is attached
4. Try accessing directly: `https://yoursite.powerappsportals.com/css/pepp-override.css`

## 📱 Testing Checklist

### Desktop Browsers
- [ ] Chrome/Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (if applicable)

### Mobile Devices
- [ ] iPhone/iPad Safari
- [ ] Android Chrome
- [ ] Responsive design mode (browser DevTools)

### Accessibility
- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] Color contrast passes WCAG AA
- [ ] Focus indicators visible

## 🚀 Advanced Customization

Want to modify colors further?

1. **Edit the CSS file**
   - Open `pepp-color-override.css`
   - Find `:root` section at top
   - Change hex values:
   ```css
   :root {
     --pepp-primary: #YOURNEWCOLOR;
   }
   ```

2. **Re-upload**
   - Use PowerShell script again, OR
   - Manually update the note in Web File record

3. **Clear cache and test**

## 📊 Performance Tips

**Current CSS File:**
- Size: ~15KB (unminified)
- ~8KB (minified)
- ~2KB (gzipped)

**To Optimize:**
```powershell
# Minify CSS (optional)
# Use online tool: https://cssminifier.com/
# Or install npm package:
npm install -g csso-cli
csso pepp-color-override.css -o pepp-override.min.css
```

**Browser Caching:**
Add to Web.config if you have access:
```xml
<staticContent>
  <clientCache cacheControlMode="UseMaxAge" cacheControlMaxAge="30.00:00:00" />
</staticContent>
```

## 👥 Team Collaboration

**Share with team members:**
1. **Designers:** Give them `Color-Reference-Card.md`
2. **Developers:** Give them `PEPP-Implementation-Guide.md`
3. **Stakeholders:** Show them before/after screenshots

**Version Control:**
- Store CSS in Git repository
- Document changes in commit messages
- Use semantic versioning (e.g., v1.0.0, v1.1.0)

## 📞 Need Help?

**Internal Team:**
- George Zarif (M365 Security Team)
- Chris Helm (M365 Security Team)
- Adrian Darjan (LCE M365 Team)

**Resources:**
- [Full Implementation Guide](./PEPP-Implementation-Guide.md)
- [Color Reference Card](./Color-Reference-Card.md)
- Power Pages Docs: https://learn.microsoft.com/power-pages/

**Log Location:**
PowerShell deployment logs: `%TEMP%\PEPP-CSS-Deployment-*.log`

## ✅ Success Criteria

Your implementation is successful when:

- [x] CSS file deployed to Power Pages
- [x] Header is Elections Canada teal (#2C5F6F)
- [x] Service cards have correct color borders
- [x] Footer is dark slate (#2C4A52)
- [x] All links are teal (#2C5F6F)
- [x] Colors work on both authenticated and anonymous pages
- [x] Mobile responsive design maintained
- [x] No console errors in browser DevTools
- [x] Accessibility standards met (WCAG AA)

## 🎉 You're Done!

Your PEPP Portal now uses the official Elections Canada political entities color palette. 

**Estimated Total Time:** 15-30 minutes (including testing)

---

## 📅 Next Steps (Optional)

After successful implementation:

1. **Update French Version**
   - Apply same CSS to French language pages
   - Verify color consistency across languages

2. **Create Style Guide**
   - Document color usage patterns
   - Create component library
   - Build design system documentation

3. **Train Team**
   - Walk through color palette with designers
   - Share customization guidelines
   - Document approval process for color changes

4. **Monitor & Maintain**
   - Set calendar reminder to review quarterly
   - Track any Elections Canada branding updates
   - Document any custom modifications

---

**Quick Start Guide Version:** 1.0  
**Last Updated:** December 9, 2024  
**Author:** Leonardo Company - LCE M365 Security Team  
**Status:** ✅ Ready for Implementation
