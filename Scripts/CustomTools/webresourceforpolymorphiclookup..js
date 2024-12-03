// Advanced Search Web Resource
function AdvancedSearchHandler(fieldName) {
    // Configuration object
    const config = {
        searchButtonSelector: `button[data-id="${fieldName}.fieldControl-LookupResultsDropdown_${fieldName}_search"]`,
        maxAttempts: 10,
        retryDelay: 200,
        observerResetDelay: 500
    };

    class AdvancedSearchInitializer {
        constructor(config) {
            this.config = config;
            this.currentObserver = null;
        }

        initialize() {
            try {
                const searchButton = document.querySelector(this.config.searchButtonSelector);
                if (!searchButton) {
                    console.warn(`Search button not found for field: ${fieldName}`);
                    return false;
                }

                const container = searchButton.closest('[role="presentation"]');
                const inputField = container?.querySelector('input[role="combobox"]');
                
                if (!inputField) {
                    console.warn('Input field not found');
                    return false;
                }

                this.setupSearchButtonHandler(searchButton, inputField);
                this.startObserving(inputField);
                return true;
            } catch (error) {
                console.error('Error initializing advanced search:', error);
                return false;
            }
        }

        findAdvancedLookupButton() {
            return document.querySelector('a[aria-label="Advanced lookup"]') || 
                   document.querySelector('a[id*="lookupDialogLookup"][aria-label="Advanced lookup"]');
        }

        setupSearchButtonHandler(searchButton, inputField) {
            const newSearchButton = searchButton.cloneNode(true);
            searchButton.parentNode.replaceChild(newSearchButton, searchButton);
            
            newSearchButton.addEventListener('click', () => {
                // Default click behavior will be handled by observer
            });
        }

        startObserving(inputField) {
            if (this.currentObserver) {
                this.currentObserver.disconnect();
            }

            this.currentObserver = new MutationObserver((mutations) => {
                mutations.forEach((mutation) => {
                    if (mutation.type === 'attributes' && 
                        mutation.attributeName === 'aria-expanded' && 
                        inputField.getAttribute('aria-expanded') === 'true') {
                        
                        inputField.click();
                        inputField.focus();
                        this.attemptToClickAdvancedLookup();
                    }
                });
            });

            this.currentObserver.observe(inputField, {
                attributes: true,
                attributeFilter: ['aria-expanded']
            });
        }

        attemptToClickAdvancedLookup(attempts = 0) {
            if (attempts >= this.config.maxAttempts) {
                console.warn('Max attempts reached trying to find advanced lookup button');
                return;
            }

            const advancedButton = this.findAdvancedLookupButton();
            
            if (advancedButton) {
                advancedButton.click();
                
                // Reset observer for next time
                setTimeout(() => {
                    this.startObserving(document.querySelector(`input[data-id="${fieldName}.fieldControl-LookupResultsDropdown_${fieldName}_textInputBox"]`));
                }, this.config.observerResetDelay);
            } else {
                setTimeout(() => this.attemptToClickAdvancedLookup(attempts + 1), this.config.retryDelay);
            }
        }
    }

    return new AdvancedSearchInitializer(config);
}

// Export for use in forms
if (typeof window !== 'undefined') {
    window.AdvancedSearchHandler = AdvancedSearchHandler;
}