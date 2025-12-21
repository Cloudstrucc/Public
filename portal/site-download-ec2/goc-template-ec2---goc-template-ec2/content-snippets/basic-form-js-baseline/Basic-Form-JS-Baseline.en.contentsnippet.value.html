// Ensure lookup buttons work in iframes
document.addEventListener('click', function(e) {
  // Check if click is on lookup button
  if (e.target.closest('.launchentitylookup')) {
    console.log('Lookup button clicked!');
    
    // Wait a tiny moment for Power Pages to create the modal
    setTimeout(function() {
      // Find the modal section with fade class
      const fadeSection = document.querySelector('section.modal.fade.modal-lookup');
      
      if (fadeSection) {
        console.log('Found fade section, removing fade class');
        fadeSection.classList.remove('fade');
        
        // Force it visible just in case
        fadeSection.style.opacity = '1';
        fadeSection.style.display = 'flex';
        fadeSection.style.alignItems = 'center';
        fadeSection.style.justifyContent = 'center';
      } else {
        console.log('No fade section found yet');
      }
    }, 100);
  }
}, true);

// Listen for modal events
document.addEventListener('DOMNodeInserted', function(e) {
  if (e.target.classList && e.target.classList.contains('modal-lookup')) {
    console.log('Lookup modal added to DOM!');
    
    // Force it visible
    setTimeout(function() {
      e.target.style.display = 'flex';
      e.target.style.zIndex = '10050';
    }, 100);
  }
});

// Fix lookup modal selection and populate parent field
(function() {
  console.log('Lookup modal selection handler initialized');
  
  // Handle Select button clicks in lookup modal
  document.addEventListener('click', function(e) {
    const selectButton = e.target.closest('.modal-lookup .btn.primary, .modal-lookup .btn-primary');
    
    if (selectButton && selectButton.textContent.trim() === 'Select') {
      console.log('Select button clicked in lookup modal');
      
      // Find the selected row (checkbox that's checked)
      const lookupModal = selectButton.closest('.modal-lookup');
      const checkedCheckbox = lookupModal.querySelector('.view-grid tbody .fa[aria-checked="true"]');
      
      if (!checkedCheckbox) {
        console.log('No record selected');
        return;
      }
      
      // Get the row data
      const row = checkedCheckbox.closest('tr');
      const recordId = row.getAttribute('data-id');
      
      // Get name from table cell (not data attribute)
      const nameCell = row.querySelector('td[data-attribute="fullname"]');
      let recordName = nameCell ? nameCell.textContent.trim() : '';
      
      // If no name, try to get email as fallback
      if (!recordName) {
        const emailCell = row.querySelector('td[data-attribute="emailaddress1"]');
        recordName = emailCell ? emailCell.textContent.trim() : 'Selected Record';
      }
      
      console.log('Selected record:', recordName, recordId);
      
      // Find the lookup modal container to get the field name
      const lookupModalContainer = lookupModal.closest('.lookup-modal');
      const entityLookup = lookupModalContainer ? lookupModalContainer.querySelector('.entity-lookup') : null;
      const fieldName = entityLookup ? entityLookup.getAttribute('data-lookup-datafieldname') : '';
      
      console.log('Field name:', fieldName);
      
      // Find the specific lookup input fields for this lookup
      const lookupInput = document.querySelector(`input#${fieldName}_name`);
      const lookupHiddenInput = document.querySelector(`input#${fieldName}`);
      const lookupEntityInput = document.querySelector(`input#${fieldName}_entityname`);
      
      console.log('Found inputs:', {
        visible: lookupInput ? 'yes' : 'no',
        hidden: lookupHiddenInput ? 'yes' : 'no',
        entity: lookupEntityInput ? 'yes' : 'no'
      });
      
      if (lookupInput && recordName) {
        // Populate the visible input
        lookupInput.value = recordName;
        console.log('Populated visible field:', recordName);
        
        // Populate hidden input with ID
        if (lookupHiddenInput && recordId) {
          lookupHiddenInput.value = recordId;
          lookupHiddenInput.classList.add('dirty');
          console.log('Populated hidden ID:', recordId);
        }
        
        // Trigger change event
        lookupInput.dispatchEvent(new Event('change', { bubbles: true }));
        if (lookupHiddenInput) {
          lookupHiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
        }
        
        // Close the modal
        const closeButton = lookupModal.querySelector('[data-bs-dismiss="modal"], .close, .form-close');
        if (closeButton) {
          closeButton.click();
          console.log('Closed modal');
        }
      } else {
        console.log('Could not populate - missing:', {
          input: lookupInput ? 'found' : 'MISSING',
          name: recordName ? recordName : 'MISSING'
        });
      }
    }
  });
  
  // Handle checkbox selection in lookup modal
  document.addEventListener('click', function(e) {
    const checkbox = e.target.closest('.modal-lookup .view-grid tbody .fa');
    
    if (checkbox) {
      console.log('Checkbox clicked in lookup modal');
      
      // Uncheck all other checkboxes in this modal
      const lookupModal = checkbox.closest('.modal-lookup');
      const allCheckboxes = lookupModal.querySelectorAll('.view-grid tbody .fa');
      allCheckboxes.forEach(cb => {
        cb.setAttribute('aria-checked', 'false');
        cb.classList.remove('fa-check-square');
        cb.classList.add('fa-square-o');
      });
      
      // Check this one
      checkbox.setAttribute('aria-checked', 'true');
      checkbox.classList.remove('fa-square-o');
      checkbox.classList.add('fa-check-square');
      
      // Enable Select button
      const selectButton = lookupModal.querySelector('.btn.primary, .btn-primary');
      if (selectButton) {
        selectButton.removeAttribute('disabled');
      }
    }
  });
})();

(function() {
  console.log('🎨 Basic Form styling initialized');
  
  // Apply PEPP color scheme to forms inside modals
  const style = document.createElement('style');
  style.textContent = `
    /* PEPP Primary Color */
    :root {
      --pepp-primary: #2b4380;
      --pepp-primary-hover: #1e2f5a;
      --pepp-secondary: #2C5F6F;
    }
    
    /* === LOOKUP BUTTONS FIX === */
    .control .input-group .btn.clearlookupfield,
    .control .input-group .btn.launchentitylookup {
      background-color: var(--pepp-primary) !important;
      border-color: var(--pepp-primary) !important;
      color: white !important;
      width: 44px !important;
      min-width: 44px !important;
      max-width: 44px !important;
      padding: 0 !important;
      font-size: 0 !important; /* Hide text */
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
    }
    
    .control .input-group .btn.clearlookupfield:hover,
    .control .input-group .btn.launchentitylookup:hover {
      background-color: var(--pepp-primary-hover) !important;
      border-color: var(--pepp-primary-hover) !important;
    }
    
    /* Show ONLY the icon */
    .control .input-group .btn.clearlookupfield .fa,
    .control .input-group .btn.launchentitylookup .fa,
    .control .input-group .btn.clearlookupfield [class*="fa-"],
    .control .input-group .btn.launchentitylookup [class*="fa-"] {
      font-size: 16px !important;
      color: white !important;
      display: block !important;
      margin: 0 !important;
    }
    
    /* Hide button text completely */
    .control .input-group .btn.clearlookupfield .visually-hidden,
    .control .input-group .btn.launchentitylookup .visually-hidden,
    .control .input-group .btn.clearlookupfield .sr-only,
    .control .input-group .btn.launchentitylookup .sr-only {
      display: none !important;
    }
    
    /* If there's text node, hide it */
    .control .input-group .btn.clearlookupfield::before,
    .control .input-group .btn.launchentitylookup::before {
      content: none !important;
    }
    
    /* Calendar button - PEPP blue */
    .control .datetimepicker .input-group-addon {
      background-color: var(--pepp-primary) !important;
      border-color: var(--pepp-primary) !important;
      color: white !important;
      width: 44px !important;
      min-width: 44px !important;
      padding: 0 !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
    }
    
    .control .datetimepicker .input-group-addon:hover {
      background-color: var(--pepp-primary-hover) !important;
      border-color: var(--pepp-primary-hover) !important;
    }
    
    .control .datetimepicker .input-group-addon .fa {
      font-size: 16px !important;
      color: white !important;
    }
    
    /* Submit button - PEPP blue */
    .actions .btn-primary,
    button[type="submit"].btn-primary,
    input[type="submit"].btn-primary {
      background-color: var(--pepp-primary) !important;
      border-color: var(--pepp-primary) !important;
      color: white !important;
      padding: 10px 24px !important;
      font-size: 16px !important;
      font-weight: 500 !important;
    }
    
    .actions .btn-primary:hover,
    button[type="submit"].btn-primary:hover,
    input[type="submit"].btn-primary:hover {
      background-color: var(--pepp-primary-hover) !important;
      border-color: var(--pepp-primary-hover) !important;
    }
    
    /* Focus states - PEPP blue ring */
    .form-control:focus {
      border-color: var(--pepp-primary) !important;
      box-shadow: 0 0 0 0.2rem rgba(43, 67, 128, 0.25) !important;
    }
    
    /* Make inputs full width in modal */
    .control input.form-control:not(.lookup),
    .control textarea.form-control,
    .control select.form-control {
      width: 100% !important;
      max-width: 100% !important;
    }
    
    /* Ensure lookup input + buttons layout properly */
    .control .input-group {
      display: flex !important;
      flex-direction: row !important;
    }
    
    .control .input-group input.lookup {
      flex: 1 1 auto !important;
      border-right: none !important;
      border-radius: 4px 0 0 4px !important;
    }
    
    .control .input-group .btn:first-of-type {
      border-radius: 0 !important;
      border-left: none !important;
      border-right: none !important;
    }
    
    .control .input-group .btn:last-of-type {
      border-radius: 0 4px 4px 0 !important;
      border-left: none !important;
    }
  `;
  
  document.head.appendChild(style);
  
  // JavaScript to clean up button text
  setTimeout(function() {
    const lookupButtons = document.querySelectorAll('.btn.clearlookupfield, .btn.launchentitylookup');
    
    lookupButtons.forEach(function(btn) {
      // Get all child nodes
      const childNodes = Array.from(btn.childNodes);
      
      // Remove text nodes, keep only icon elements
      childNodes.forEach(function(node) {
        if (node.nodeType === Node.TEXT_NODE) {
          node.textContent = ''; // Clear text
        }
      });
      
      console.log('✅ Cleaned lookup button');
    });
  }, 500);
  
  console.log('🎨 PEPP styling applied to Basic Form');
})();

// AGGRESSIVE nested lookup modal text cleaner
(function() {
  console.log('🧼 Aggressive nested lookup cleaner initialized');
  
  const aggressiveClean = function() {
    // Fix close button
    const closeButtons = document.querySelectorAll('.modal-lookup .modal-header .close, .modal-lookup .modal-header .form-close');
    closeButtons.forEach(function(btn) {
      // Remove all child nodes
      while (btn.firstChild) {
        btn.removeChild(btn.firstChild);
      }
      // Add only ×
      btn.textContent = '×';
      btn.style.fontSize = '32px';
      console.log('✅ Cleaned close button');
    });
    
    // Fix search button
    const searchButtons = document.querySelectorAll('.modal-lookup .entitylist-search .btn-default, .modal-lookup .view-search .btn-default');
    searchButtons.forEach(function(btn) {
      // Keep only the icon
      const icon = btn.querySelector('.fa');
      if (icon) {
        // Remove all other content
        const textNodes = Array.from(btn.childNodes).filter(node => node.nodeType === Node.TEXT_NODE);
        textNodes.forEach(node => node.remove());
        
        // Remove visually-hidden spans
        const hiddenSpans = btn.querySelectorAll('.visually-hidden, .sr-only');
        hiddenSpans.forEach(span => span.remove());
        
        console.log('✅ Cleaned search button');
      }
    });
    
    // Clean column headers
    const headers = document.querySelectorAll('.modal-lookup .view-grid table thead th a');
    headers.forEach(function(header) {
      const originalText = header.textContent;
      
      // Extract just the column name
      let cleanText = originalText.split('↑')[0].split('↓')[0];
      cleanText = cleanText.split('.')[0];
      cleanText = cleanText.replace(/\s+sort\s+(ascending|descending)/gi, '');
      cleanText = cleanText.trim();
      
      if (cleanText && cleanText !== originalText) {
        // Clear all content
        while (header.firstChild) {
          header.removeChild(header.firstChild);
        }
        // Add clean text
        header.textContent = cleanText;
        console.log('✅ Cleaned header:', originalText, '→', cleanText);
      }
    });
  };
  
  // Run when ANY lookup button is clicked
  document.addEventListener('click', function(e) {
    if (e.target.closest('.launchentitylookup')) {
      console.log('🔍 Lookup clicked - will clean aggressively');
      setTimeout(aggressiveClean, 100);
      setTimeout(aggressiveClean, 300);
      setTimeout(aggressiveClean, 600);
      setTimeout(aggressiveClean, 1000);
    }
  }, true);
  
  // Watch for modals appearing
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        const target = mutation.target;
        if (target.classList && target.classList.contains('modal-lookup') && target.classList.contains('show')) {
          console.log('👀 Lookup modal shown - cleaning');
          setTimeout(aggressiveClean, 50);
          setTimeout(aggressiveClean, 200);
        }
      }
    });
  });
  
  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ['class'],
    subtree: true
  });
  
  console.log('🧼 Aggressive cleaner ready');
})();

// Force lookup modal header colors when opened from this form
document.addEventListener('click', function(e) {
  if (e.target.closest('.launchentitylookup')) {
    console.log('🎨 Fixing nested lookup modal colors');
    
    const fixColors = function() {
      const lookupModals = document.querySelectorAll('.modal-lookup');
      
      lookupModals.forEach(function(modal) {
        const header = modal.querySelector('.modal-header');
        if (header) {
          // Force teal background
          header.style.setProperty('background-color', '#2C5F6F', 'important');
          header.style.setProperty('background', '#2C5F6F', 'important');
          header.style.setProperty('color', 'white', 'important');
          
          // Force title white
          const title = header.querySelector('.modal-title, h2, h3');
          if (title) {
            title.style.setProperty('color', 'white', 'important');
          }
          
          // Force close button white
          const closeBtn = header.querySelector('.close, .form-close, button[data-bs-dismiss]');
          if (closeBtn) {
            closeBtn.style.setProperty('color', 'white', 'important');
            closeBtn.style.setProperty('opacity', '1', 'important');
          }
          
          console.log('✅ Fixed lookup modal header colors');
        }
      });
    };
    
    // Run multiple times
    setTimeout(fixColors, 100);
    setTimeout(fixColors, 300);
    setTimeout(fixColors, 600);
    setTimeout(fixColors, 1000);
  }
}, true);

// Remove red underline from lookup modal title
document.addEventListener('click', function(e) {
  if (e.target.closest('.launchentitylookup')) {
    console.log('🎨 Removing h1 underline');
    
    const removeUnderline = function() {
      const lookupModals = document.querySelectorAll('.modal-lookup');
      
      lookupModals.forEach(function(modal) {
        const h1Elements = modal.querySelectorAll('h1, .modal-title, h2, h3');
        
        h1Elements.forEach(function(h1) {
          // Remove all border properties
          h1.style.setProperty('border', 'none', 'important');
          h1.style.setProperty('border-bottom', 'none', 'important');
          h1.style.setProperty('border-top', 'none', 'important');
          h1.style.setProperty('text-decoration', 'none', 'important');
          h1.style.setProperty('box-shadow', 'none', 'important');
          h1.style.setProperty('outline', 'none', 'important');
          h1.style.setProperty('background-image', 'none', 'important');
          
          console.log('✅ Removed underline from:', h1.textContent);
        });
      });
    };
    
    // Run multiple times
    setTimeout(removeUnderline, 100);
    setTimeout(removeUnderline, 300);
    setTimeout(removeUnderline, 600);
    setTimeout(removeUnderline, 1000);
  }
}, true);