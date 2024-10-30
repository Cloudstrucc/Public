setTimeout(() => {
    let searchButton = document.querySelector('button[data-id="new_fptpoly.fieldControl-LookupResultsDropdown_new_fptpoly_search"]');
    
    if(searchButton) {
        const container = searchButton.closest('[role="presentation"]');
        const inputField = container?.querySelector('input[role="combobox"]');
        
        const findAdvancedLookupButton = () => {
            const advancedButton = document.querySelector('a[aria-label="Advanced lookup"]') || 
                                 document.querySelector('a[id*="lookupDialogLookup"][aria-label="Advanced lookup"]');
            return advancedButton;
        };

        // Function to create and start observing
        const startObserving = () => {
            const observer = new MutationObserver((mutations) => {
                mutations.forEach((mutation) => {
                    if (mutation.type === 'attributes' && 
                        mutation.attributeName === 'aria-expanded' && 
                        inputField.getAttribute('aria-expanded') === 'true') {
                        
                        // Input field is expanded, now click it and look for advanced lookup
                        inputField.click();
                        inputField.focus();
                        
                        // Start attempting to find and click the advanced lookup button
                        const attemptToClickAdvancedLookup = (attempts = 0) => {
                            if(attempts >= 10) {
                                console.log('Max attempts reached trying to find advanced lookup button');
                                observer.disconnect();
                                return;
                            }
                            
                            const advancedButton = findAdvancedLookupButton();
                            
                            if(advancedButton) {
                                console.log('Found and clicking advanced lookup button');
                                advancedButton.click();
                                observer.disconnect();

                                // Wait a bit and start observing again for next time
                                setTimeout(() => {
                                    startObserving();
                                }, 500);
                            } else {
                                setTimeout(() => attemptToClickAdvancedLookup(attempts + 1), 200);
                            }
                        };
                        
                        setTimeout(() => attemptToClickAdvancedLookup(), 200);
                    }
                });
            });

            // Start observing the input field for changes
            observer.observe(inputField, {
                attributes: true,
                attributeFilter: ['aria-expanded']
            });

            return observer;
        };

        // Create new event listener for search button
        const newSearchButton = searchButton.cloneNode(true);
        searchButton.parentNode.replaceChild(newSearchButton, searchButton);
        
        // Add click event listener to new button
        newSearchButton.addEventListener('click', () => {
            // Let the default click behavior happen
            // The observer will handle the rest
        });
        
        // Start initial observation
        startObserving();
        
        console.log('Event handlers and observer attached');
    } else {
        console.log('Search button not found');
    }
}, 1000);