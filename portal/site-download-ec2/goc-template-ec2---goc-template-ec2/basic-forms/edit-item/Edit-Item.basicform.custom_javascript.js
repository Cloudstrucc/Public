{{ snippets['PEPP-BasicForm-Library'] }}

// Initialize with inline config
PEPPBasicForm.init({
  richTextFields: ['cs_richtextfield'],
  features: {
    lookupButtons: true,
    lookupModals: true,
    lookupFieldFunctionality: true,  // NEW - makes lookup fields work
    richTextEditor: true
  }
});