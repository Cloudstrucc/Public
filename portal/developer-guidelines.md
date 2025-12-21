# PEPP Portal Enhancement Library - Usage Guide

**Version:** 1.2

**Last Updated:** December 2025

**Author:** Fred Pearson

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [PEPP-Scripts-Base Functions](#pepp-scripts-base-functions)
4. [PEPP-BasicForm-Library API](#pepp-basicform-library-api)
5. [Configuration Guide](#configuration-guide)
6. [Usage Examples](#usage-examples)
7. [Advanced Scenarios](#advanced-scenarios)
8. [Troubleshooting](#troubleshooting)

---

## Overview

The **PEPP (Portal Enhancement for Power Pages)** library provides three components that are already installed in your environment:

| Component                        | Type                         | Purpose                | Location                  |
| -------------------------------- | ---------------------------- | ---------------------- | ------------------------- |
| **PEPP-Styles-Base**       | Web Template (CSS)           | Modal and form styling | Included in `cs-header` |
| **PEPP-Scripts-Base**      | Web Template (JavaScript)    | Global modal handling  | Included in `cs-footer` |
| **PEPP-BasicForm-Library** | Content Snippet (JavaScript) | Form-specific features | Include on form pages     |

### What PEPP Does Automatically

✅ **Detects modal buttons** - Create, Edit, Delete, Details, Lookup

✅ **Forces modals visible** - Overcomes Power Pages display issues

✅ **Manages z-index** - Ensures correct modal stacking

✅ **Sets responsive widths** - 500px to 1400px based on type

✅ **Supports nested modals** - Lookup inside form modals

✅ **Styles form controls** - Buttons, inputs, date pickers

✅ **Handles lookup selection** - Populates fields automatically

---

## Quick Start

### Basic Implementation

Add this to any page with a Basic Form, Advanced Form, or Entity List:

```liquid
{% comment %} Include the library {% endcomment %}
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
// Initialize with defaults
PEPPBasicForm.init();
</script>
```

### With Configuration

```liquid
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  colors: {
    primary: '#2b4380',
    primaryHover: '#1e2f5a',
    secondary: '#2C5F6F'
  },
  richTextFields: ['cs_description', 'cs_notes'],
  features: {
    lookupButtons: true,
    lookupModals: true,
    calendarButtons: true,
    submitButton: true,
    richTextEditor: true
  }
});
</script>
```

---

## PEPP-Scripts-Base Functions

PEPP-Scripts-Base runs globally and has **no public API** - it works automatically. However, understanding its internal functions helps with debugging and customization.

### Global Behavior

The script automatically:

1. **Monitors click events** on all modal trigger buttons
2. **Detects modals** with the `.show` class
3. **Forces display** with proper dimensions and z-index
4. **Handles nested scenarios** (lookup within form)
5. **Populates lookup fields** when records are selected

### Console Logging

All operations log to console for debugging:

```javascript
// Modal Detection
🔥 PEPP-Scripts-Base LOADED - Version 1.1
🎯 User clicked modal trigger button
🔍 Checking for modals...
Found 10 total modals in DOM

// Modal Display
🎯 Found FIRST modal with show class: modal fade modal-form modal-form-edit show
💪 FORCING modal visible: modal fade modal-form modal-form-edit show
📐 Screen width: 1680
🖥️ Large desktop - setting width: 900px
🔒 Width locked at: 900px
✅ Modal forced visible with proper dimensions

// Nested Modals
🔍 Lookup button - allowing nested modal
👨‍👧 Keeping parent form modal: modal fade modal-form modal-form-edit show
🔍 Found NEW lookup modal with show class

// Lookup Selection
✅ Checkbox clicked
✅ Select button clicked
📝 Selected: John Smith 3fff5fcf-ebc3-ee11-9079-0022483ccb4c
🔍 Field name: cs_contact
✅ Populated visible field
✅ Populated hidden ID
✅ Modal closed
```

### Monitored Trigger Classes

The script automatically detects clicks on:

```javascript
.create-action              // "New" button
.edit-action                // "Edit" button
.delete-action              // "Delete" button
.details-action             // "Details" button
.view-action                // "View" button
.launchentitylookup         // Lookup search icon
a[href*="modal-form-template"]  // Links to form templates
[data-bs-toggle="modal"]    // Bootstrap modal triggers
```

### Modal Type Detection

Automatically identifies and handles:

```javascript
.modal-form         // Create/Edit forms (900px width, z-index 10050)
.modal-lookup       // Record selection (1400px width, z-index 10060)
.modal-delete       // Delete confirmation (500px width, z-index 10050)
.modal-details      // Read-only view (1100px width, z-index 10050)
```

### No Configuration Needed

PEPP-Scripts-Base requires  **no initialization or configuration** . It starts automatically when the page loads.

---

## PEPP-BasicForm-Library API

### Namespace

All functions are available under the `PEPPBasicForm` namespace (aliased as `PEPP` internally).

```javascript
window.PEPPBasicForm.init({...});
window.PEPPBasicForm.applyStyles();
window.PEPPBasicForm.initRichTextEditor('cs_field');
// etc.
```

---

### Core Functions

#### `PEPPBasicForm.init(config)`

**Purpose:** Initialize the library with custom configuration

**Parameters:**

* `config` (Object, optional) - Configuration object

**Returns:** `void`

**Example:**

```javascript
PEPPBasicForm.init({
  colors: {
    primary: '#2b4380',
    primaryHover: '#1e2f5a',
    secondary: '#2C5F6F'
  },
  richTextFields: ['cs_description', 'cs_notes'],
  features: {
    lookupButtons: true,
    lookupModals: true,
    calendarButtons: true,
    submitButton: true,
    richTextEditor: true
  }
});
```

**Configuration Object Schema:**

```typescript
{
  colors?: {
    primary?: string;        // Default: '#2b4380'
    primaryHover?: string;   // Default: '#1e2f5a'
    secondary?: string;      // Default: '#2C5F6F'
  },
  richTextFields?: string[]; // Array of field schema names
  features?: {
    lookupButtons?: boolean;    // Default: true
    lookupModals?: boolean;     // Default: true
    calendarButtons?: boolean;  // Default: true
    submitButton?: boolean;     // Default: true
    richTextEditor?: boolean;   // Default: true
  }
}
```

**What it does:**

1. Merges user config with defaults
2. Applies CSS styles if button features enabled
3. Cleans lookup buttons
4. Initializes lookup modal handlers
5. Initializes rich text editors (delayed 500ms)

---

### Styling Functions

#### `PEPPBasicForm.applyStyles()`

**Purpose:** Inject CSS styles for buttons and form controls

**Parameters:** None

**Returns:** `void`

**Example:**

```javascript
// Called automatically by init(), but can be called manually:
PEPPBasicForm.applyStyles();
```

**Styles Applied:**

* CSS variables for colors
* Lookup button styling (44px icons)
* Calendar button styling
* Submit button styling
* Focus states
* Input group layouts

**When to use manually:**

* After dynamically adding form elements
* When re-initializing forms via AJAX
* For custom form rendering scenarios

---

#### `PEPPBasicForm.cleanLookupButtons()`

**Purpose:** Remove text from lookup buttons, showing only icons

**Parameters:** None

**Returns:** `void`

**Example:**

```javascript
// Called automatically by init(), but can be called manually:
PEPPBasicForm.cleanLookupButtons();

// Or after dynamic content loads:
setTimeout(function() {
  PEPPBasicForm.cleanLookupButtons();
}, 500);
```

**What it does:**

* Finds all `.clearlookupfield` and `.launchentitylookup` buttons
* Removes text nodes from button content
* Preserves Font Awesome icons
* Runs with 500ms delay by default

**When to use manually:**

* After AJAX form updates
* When buttons are dynamically inserted
* If text reappears after page updates

---

### Lookup Modal Functions

#### `PEPPBasicForm.initLookupModalFixes()`

**Purpose:** Initialize styling and text cleanup for lookup modals

**Parameters:** None

**Returns:** `void`

**Example:**

```javascript
// Called automatically by init() when features.lookupModals = true
// Can be called manually:
PEPPBasicForm.initLookupModalFixes();
```

**What it does:**

1. **Cleans modal text:**
   * Removes extra text from close buttons
   * Cleans search button text
   * Removes sort indicators from column headers
2. **Fixes colors:**
   * Sets header background to secondary color
   * Forces white text
   * Styles close button
3. **Removes underlines:**
   * Removes h1 border-bottom
   * Cleans modal titles
4. **Sets up observers:**
   * Watches for lookup button clicks
   * Monitors modal class changes
   * Auto-applies fixes when modals appear

**When to use manually:**

* If lookup modals aren't styled correctly
* After manually creating lookup modals
* For custom modal implementations

---

#### `PEPPBasicForm.initLookupModalDisplay()`

**Purpose:** Handle nested lookup modal display within form modals

**Parameters:** None

**Returns:** `void`

**Example:**

```javascript
// Called automatically by init() when features.lookupModals = true
PEPPBasicForm.initLookupModalDisplay();
```

**What it does:**

1. Detects `.launchentitylookup` button clicks
2. Checks for lookup modals repeatedly (100ms, 300ms, 500ms, 1000ms)
3. Forces modal visible with:
   * `display: flex`
   * `opacity: 1`
   * `z-index: 10060`
   * Width: 1400px (desktop) or 95% (mobile)
4. Creates backdrop if needed
5. Locks body scroll

**When to use manually:**

* Troubleshooting nested modal display
* Custom lookup modal implementations
* After programmatically opening modals

---

#### `PEPPBasicForm.initLookupSelectionHandler()`

**Purpose:** Handle checkbox selection and field population in lookup modals

**Parameters:** None

**Returns:** `void`

**Example:**

```javascript
// Called automatically by init() when features.lookupModals = true
PEPPBasicForm.initLookupSelectionHandler();
```

**What it does:**

1. **Checkbox handling:**
   * Single-select behavior (unchecks others)
   * Toggles `aria-checked` attribute
   * Switches Font Awesome icons
   * Enables "Select" button
2. **Field population:**
   * Extracts record ID from row
   * Gets record name from `fullname` or `emailaddress1` column
   * Finds field name from data attributes
   * Populates visible field (`{fieldname}_name`)
   * Populates hidden field (`{fieldname}`)
   * Hides placeholder dash
   * Triggers change events
   * Closes modal

**Field Population Logic:**

```javascript
// Automatically populates these fields:
input#cs_contact_name          // Visible text (e.g., "John Smith")
input#cs_contact               // Hidden GUID
input#cs_contact_entityname    // Entity logical name (e.g., "contact")
```

**When to use manually:**

* Custom lookup modal implementations
* Troubleshooting field population
* Multi-select lookup scenarios (requires modification)

---

### Rich Text Editor Functions

#### `PEPPBasicForm.initRichTextEditor(fieldName)`

**Purpose:** Initialize Quill.js rich text editor for a specific field

**Parameters:**

* `fieldName` (String, required) - Field schema name (e.g., `'cs_description'`)

**Returns:** `void`

**Example:**

```javascript
// Initialize single field
PEPPBasicForm.initRichTextEditor('cs_description');

// Initialize multiple fields
['cs_description', 'cs_notes', 'cs_comments'].forEach(function(field) {
  PEPPBasicForm.initRichTextEditor(field);
});
```

**What it does:**

1. **Validates field name:**
   * Checks for empty/invalid field names
   * Logs warnings for invalid inputs
2. **Waits for field:**
   * Retries up to 20 times (200ms intervals)
   * Logs each attempt to console
   * Aborts if field not found
3. **Hides original textarea:**
   * Sets `display: none`
   * Positions off-screen
   * Preserves in DOM for form submission
4. **Loads Quill.js:**
   * Injects CSS: `https://cdn.quilljs.com/1.3.6/quill.snow.css`
   * Injects JS: `https://cdn.quilljs.com/1.3.6/quill.js`
   * Uses cached version if already loaded
5. **Creates editor:**
   * Inserts div before textarea
   * Initializes Quill with toolbar
   * Syncs content to hidden textarea
   * Handles form submit events

**Toolbar Configuration:**

```javascript
{
  toolbar: [
    [{ 'header': [1, 2, 3, false] }],  // H1, H2, H3, Normal
    ['bold', 'italic', 'underline'],   // Text formatting
    [{ 'list': 'ordered'}, { 'list': 'bullet' }], // Lists
    ['link'],                           // Hyperlinks
    ['clean']                           // Remove formatting
  ]
}
```

**Field Requirements:**

* Field must be a `<textarea>` element
* Field ID must match schema name exactly
* Field must be in DOM before initialization
* Field must not already be initialized

**When to use manually:**

* Adding rich text to dynamically loaded forms
* Initializing after AJAX updates
* Custom field implementations
* Delayed initialization scenarios

**Error Handling:**

```javascript
try {
  PEPPBasicForm.initRichTextEditor('cs_description');
} catch (error) {
  console.error('Rich text initialization failed:', error);
}
```

---

### Configuration Object

#### `PEPPBasicForm.config`

**Purpose:** Access or modify current configuration

**Type:** `Object`

**Properties:**

```javascript
{
  colors: {
    primary: '#2b4380',
    primaryHover: '#1e2f5a',
    secondary: '#2C5F6F'
  },
  richTextFields: [],
  features: {
    lookupButtons: true,
    lookupModals: true,
    calendarButtons: true,
    submitButton: true,
    richTextEditor: true
  }
}
```

**Example - Reading config:**

```javascript
console.log(PEPPBasicForm.config.colors.primary);
// Output: '#2b4380'

console.log(PEPPBasicForm.config.richTextFields);
// Output: ['cs_description', 'cs_notes']
```

**Example - Modifying config:**

```javascript
// Change primary color
PEPPBasicForm.config.colors.primary = '#0066cc';

// Add rich text field
PEPPBasicForm.config.richTextFields.push('cs_newfield');

// Re-apply styles
PEPPBasicForm.applyStyles();
```

**When to use:**

* Checking current configuration
* Dynamic configuration changes
* Debugging configuration issues
* Building custom extensions

---

## Configuration Guide

### Default Configuration

```javascript
{
  colors: {
    primary: '#2b4380',        // Primary button color (blue)
    primaryHover: '#1e2f5a',   // Primary button hover (darker blue)
    secondary: '#2C5F6F'       // Modal headers (teal)
  },
  richTextFields: [],          // No rich text by default
  features: {
    lookupButtons: true,       // Style lookup buttons
    lookupModals: true,        // Handle lookup modals
    calendarButtons: true,     // Style calendar buttons
    submitButton: true,        // Style submit button
    richTextEditor: true       // Enable rich text (if fields specified)
  }
}
```

### Minimal Configuration

Use defaults for everything:

```javascript
PEPPBasicForm.init();
```

### Color Customization

Change brand colors only:

```javascript
PEPPBasicForm.init({
  colors: {
    primary: '#0066cc',
    primaryHover: '#0052a3',
    secondary: '#2C5F6F'  // Keep modal headers consistent
  }
});
```

### Rich Text Only

Enable rich text editor only:

```javascript
PEPPBasicForm.init({
  richTextFields: ['cs_description', 'cs_notes'],
  features: {
    lookupButtons: false,
    lookupModals: false,
    calendarButtons: false,
    submitButton: false,
    richTextEditor: true
  }
});
```

### Lookup Forms

Forms with lookup fields:

```javascript
PEPPBasicForm.init({
  features: {
    lookupButtons: true,    // Style lookup buttons
    lookupModals: true,     // Handle lookup selection
    calendarButtons: true,
    submitButton: true,
    richTextEditor: false
  }
});
```

### Complete Configuration

All features enabled:

```javascript
PEPPBasicForm.init({
  colors: {
    primary: '#2b4380',
    primaryHover: '#1e2f5a',
    secondary: '#2C5F6F'
  },
  richTextFields: [
    'cs_description',
    'cs_notes',
    'cs_detailednotes',
    'cs_summary'
  ],
  features: {
    lookupButtons: true,
    lookupModals: true,
    calendarButtons: true,
    submitButton: true,
    richTextEditor: true
  }
});
```

---

## Usage Examples

### Example 1: Simple Contact Form

```liquid
{% comment %} Contact form with lookup {% endcomment %}
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  features: {
    lookupButtons: true,
    lookupModals: true,
    submitButton: true
  }
});
</script>
```

### Example 2: Complex Entity Form

```liquid
{% comment %} Form with rich text and lookups {% endcomment %}
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  richTextFields: ['cs_description', 'cs_notes'],
  features: {
    lookupButtons: true,
    lookupModals: true,
    calendarButtons: true,
    submitButton: true,
    richTextEditor: true
  }
});
</script>
```

### Example 3: Read-Only Form

```liquid
{% comment %} Details view - no editor needed {% endcomment %}
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  features: {
    lookupButtons: false,
    lookupModals: false,
    calendarButtons: false,
    submitButton: false,
    richTextEditor: false
  }
});
</script>
```

### Example 4: Custom Brand Colors

```liquid
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  colors: {
    primary: '#d32f2f',       // Red theme
    primaryHover: '#b71c1c',
    secondary: '#2C5F6F'      // Keep teal headers
  },
  features: {
    lookupButtons: true,
    submitButton: true
  }
});
</script>
```

### Example 5: Dynamic Rich Text

```liquid
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
// Initialize without rich text
PEPPBasicForm.init();

// Add rich text to specific fields dynamically
document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelector('#cs_description')) {
    PEPPBasicForm.initRichTextEditor('cs_description');
  }
  
  if (document.querySelector('#cs_notes')) {
    PEPPBasicForm.initRichTextEditor('cs_notes');
  }
});
</script>
```

### Example 6: Multi-Step Form

```liquid
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  colors: {
    primary: '#2b4380'
  },
  features: {
    submitButton: true
  }
});

// Re-initialize on step change
function onStepChange(stepNumber) {
  // Clean buttons on new step
  setTimeout(function() {
    PEPPBasicForm.cleanLookupButtons();
    PEPPBasicForm.applyStyles();
  }, 100);
}
</script>
```

### Example 7: AJAX Form Updates

```liquid
{% include 'snippet' snippet_name:'PEPP-BasicForm-Library' %}

<script>
PEPPBasicForm.init({
  richTextFields: ['cs_description']
});

// After AJAX update
function afterFormUpdate() {
  // Re-apply button styles
  PEPPBasicForm.cleanLookupButtons();
  PEPPBasicForm.applyStyles();
  
  // Re-initialize rich text if field was replaced
  if (document.querySelector('#cs_description')) {
    PEPPBasicForm.initRichTextEditor('cs_description');
  }
}

// Example AJAX call
$.ajax({
  url: '/api/updateform',
  success: function(data) {
    $('#formContainer').html(data);
    afterFormUpdate();
  }
});
</script>
```

---

## Advanced Scenarios

### Conditional Rich Text

Enable rich text based on user role or form state:

```javascript
var isAdmin = {{ user.roles contains 'Administrator' }};
var richTextFields = isAdmin ? ['cs_description', 'cs_notes'] : [];

PEPPBasicForm.init({
  richTextFields: richTextFields,
  features: {
    richTextEditor: isAdmin
  }
});
```

### Custom Quill Toolbar

Modify the library to add custom toolbar options:

```javascript
// In PEPP-BasicForm-Library, find initRichTextEditor function
// Modify the toolbar configuration:

const quill = new Quill(`#${CSS.escape(fieldName)}_editor`, {
  theme: 'snow',
  placeholder: 'Enter text here...',
  modules: {
    toolbar: [
      [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
      [{ 'font': [] }],
      [{ 'size': ['small', false, 'large', 'huge'] }],
      ['bold', 'italic', 'underline', 'strike'],
      [{ 'color': [] }, { 'background': [] }],
      [{ 'script': 'sub'}, { 'script': 'super' }],
      [{ 'list': 'ordered'}, { 'list': 'bullet' }],
      [{ 'indent': '-1'}, { 'indent': '+1' }],
      [{ 'direction': 'rtl' }],
      [{ 'align': [] }],
      ['link', 'image', 'video'],
      ['blockquote', 'code-block'],
      ['clean']
    ]
  }
});
```

### Custom Lookup Field Mapping

Handle custom entity attributes:

```javascript
// After PEPPBasicForm.init(), add custom handler
document.addEventListener('click', function(e) {
  const selectButton = e.target.closest('.modal-lookup .btn.primary');
  
  if (selectButton && selectButton.textContent.trim() === 'Select') {
    const lookupModal = selectButton.closest('.modal-lookup');
    const row = lookupModal.querySelector('.fa[aria-checked="true"]').closest('tr');
  
    // Get custom attributes
    const customField1 = row.querySelector('td[data-attribute="cs_customfield1"]');
    const customField2 = row.querySelector('td[data-attribute="cs_customfield2"]');
  
    // Populate custom fields
    if (customField1) {
      document.querySelector('#cs_relatedfield1').value = customField1.textContent;
    }
    if (customField2) {
      document.querySelector('#cs_relatedfield2').value = customField2.textContent;
    }
  }
});
```

### Form Validation Integration

```javascript
PEPPBasicForm.init({
  richTextFields: ['cs_description']
});

// Add validation before submit
document.querySelector('form').addEventListener('submit', function(e) {
  // Validate rich text has content
  const description = document.querySelector('#cs_description').value;
  
  if (!description || description.trim() === '' || description === '<p><br></p>') {
    e.preventDefault();
    alert('Description is required');
    return false;
  }
  
  return true;
});
```

### Multiple Forms on One Page

```javascript
// Initialize once globally
PEPPBasicForm.init({
  colors: {
    primary: '#2b4380'
  }
});

// Handle form-specific rich text
document.querySelectorAll('.entity-form').forEach(function(form) {
  const formId = form.getAttribute('data-form-id');
  
  if (formId === 'contact-form') {
    PEPPBasicForm.initRichTextEditor('cs_contact_notes');
  } else if (formId === 'account-form') {
    PEPPBasicForm.initRichTextEditor('cs_account_description');
  }
});
```

### Custom Button Styling

Extend with additional button styles:

```javascript
PEPPBasicForm.init();

// Add custom styles after initialization
const customStyle = document.createElement('style');
customStyle.textContent = `
  .custom-lookup-button {
    background-color: #00a86b !important;
    border-color: #00a86b !important;
  }
  
  .custom-lookup-button:hover {
    background-color: #008856 !important;
  }
`;
document.head.appendChild(customStyle);
```

---

## Troubleshooting

### Console Debugging

Enable verbose logging:

```javascript
// Check if library loaded
console.log('PEPP loaded:', typeof PEPPBasicForm !== 'undefined');

// Check configuration
console.log('PEPP config:', PEPPBasicForm.config);

// Check for modals
console.log('Modals in DOM:', document.querySelectorAll('.modal').length);

// Check for active modal
console.log('Active modal:', document.querySelector('.modal.show'));

// Check field exists
console.log('Field exists:', document.querySelector('#cs_description'));
```

### Common Issues

#### Issue: Modal Not Appearing

**Console Check:**

```javascript
// Should see these logs:
// 🎯 User clicked modal trigger button
// 🔍 Checking for modals...
// 💪 FORCING modal visible

// If not, check:
document.querySelector('.create-action');  // Button exists?
document.querySelector('.modal-form');     // Modal exists in DOM?
```

**Solution:**

* Verify PEPP-Scripts-Base is in footer template
* Check console for JavaScript errors
* Ensure modal HTML is in page

#### Issue: Lookup Field Not Populating

**Console Check:**

```javascript
// Should see:
// ✅ Select button clicked in nested lookup
// 📝 Selected: John Smith [GUID]
// ✅ Populated visible field
// ✅ Populated hidden ID

// If not, check field names:
const fieldName = 'cs_contact';
console.log('Visible field:', document.querySelector(`#${fieldName}_name`));
console.log('Hidden field:', document.querySelector(`#${fieldName}`));
```

**Solution:**

* Verify field names match schema names exactly
* Check `features.lookupModals: true`
* Ensure PEPP-BasicForm-Library is included

#### Issue: Rich Text Not Loading

**Console Check:**

```javascript
// Should see:
// 🖊️ Initializing rich text editor for: cs_description
// ✅ Found field: cs_description
// ✅ Rich text editor initialized for: cs_description

// Check Quill loaded:
console.log('Quill loaded:', typeof Quill !== 'undefined');

// Check editor created:
console.log('Editor div:', document.querySelector('#cs_description_editor'));
```

**Solution:**

* Verify field name in `richTextFields` array
* Check field is `<textarea>` not `<input>`
* Ensure field exists before initialization
* Check Quill CDN is accessible

#### Issue: Buttons Not Styled

**Console Check:**

```javascript
// Check styles applied:
console.log('Style tag:', document.querySelector('#pepp-basicform-styles'));

// Check button exists:
console.log('Lookup button:', document.querySelector('.launchentitylookup'));
```

**Solution:**

* Call `PEPPBasicForm.applyStyles()` manually
* Check `features.lookupButtons: true`
* Verify buttons have correct classes

#### Issue: Nested Modal Not Appearing

**Console Check:**

```javascript
// Should see:
// 🎯 Lookup button clicked in form
// 🔍 Checking for lookup modal...
// ✅ Found lookup modal with show class
// 💪 Forcing lookup modal visible

// Check z-index:
const formModal = document.querySelector('.modal-form.show');
const lookupModal = document.querySelector('.modal-lookup.show');
console.log('Form z-index:', window.getComputedStyle(formModal).zIndex);
console.log('Lookup z-index:', window.getComputedStyle(lookupModal).zIndex);
// Should be: Form=10050, Lookup=10060
```

**Solution:**

* Ensure `features.lookupModals: true`
* Check PEPP-Styles-Base loaded (z-index rules)
* Verify both modals in DOM

---

## Function Reference Summary

### PEPP-Scripts-Base (Global, Auto-Running)

| Function             | Type     | Description                                   |
| -------------------- | -------- | --------------------------------------------- |
| Modal Detection      | Internal | Monitors clicks on trigger buttons            |
| Modal Display        | Internal | Forces modals visible with dimensions         |
| Nested Modal Handler | Internal | Manages parent-child modal relationships      |
| Lookup Selection     | Internal | Populates fields after record selection       |
| Width Locking        | Internal | Applies responsive widths with `!important` |
| Z-Index Management   | Internal | Ensures correct modal stacking                |

**No public API** - runs automatically on all pages.

---

### PEPP-BasicForm-Library (Public API)

| Function                          | Parameters            | Returns  | Description                           |
| --------------------------------- | --------------------- | -------- | ------------------------------------- |
| `init(config)`                  | `config?: Object`   | `void` | Initialize library with configuration |
| `applyStyles()`                 | None                  | `void` | Inject button and form styles         |
| `cleanLookupButtons()`          | None                  | `void` | Remove text from lookup buttons       |
| `initLookupModalFixes()`        | None                  | `void` | Initialize lookup modal styling       |
| `initLookupModalDisplay()`      | None                  | `void` | Handle nested lookup display          |
| `initLookupSelectionHandler()`  | None                  | `void` | Handle lookup field population        |
| `initRichTextEditor(fieldName)` | `fieldName: string` | `void` | Initialize Quill editor for field     |

**Property:**

* `config` (Object) - Current configuration object

---

## Support

For issues, questions, or enhancements:

1. **Check Console Logs** - Look for 🔥 PEPP log messages
2. **Review Configuration** - Verify `PEPPBasicForm.config`
3. **Test in Isolation** - Minimal configuration first
4. **Document Issue** - Include browser, console logs, configuration

---

**End of Usage Guide**
